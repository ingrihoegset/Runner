//
//  HomeViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    func didFetchProfileImage(image: UIImage, safeEmail: String)
    func didUpdatePartnerUI(partner: String, gateNumber: Int)
    func didGetRunResult(result: RunResults)
    func launchFinished()
}


class HomeViewModel {
    
    weak var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        listenForNewLink()
        // Used to trigger certain functions when end of run is detected.
        listenForEndOfCurrentRun()
        // Used to determine when camera should be looking for a break time.
        currentRunOngoing()
    }
    
    // Updates User Selected Run type when user selects a run type from home view
    func updateRunType(type: UserRunSelections.runTypes) {
        UserRunSelections.shared.setUserSelectedType(type: type.rawValue)
    }
    
    /// Call on storageManager to fetch profil pic for our user
    func fetchProfilePic(email: String) {
        
        print("Fetching picture")
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        print("image path", path)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("Succeed in downloading url")

                StorageManager.getImage(withURL: url, completion: { image in
                    if let downloadedImage = image {
                        self?.homeViewModelDelegate?.didFetchProfileImage(image: downloadedImage, safeEmail: safeEmail)
                    }
                })
            case .failure(let error):
                print("Failed to download url: \(error)")
                self?.homeViewModelDelegate?.launchFinished()
            }
        })
    }
    
    // Clears link with partner from database upon app opening from terminate state
    func clearLinkFromDatabase() {
        DatabaseManager.shared.clearLinkFromDatabase(with: { success in
            if success {
                print ("Successfully deleted link from database for user and partner")
            }
            else {
                print("Failed to remove link from database.")
            }
        })
    }
    
    // Start listening for new link
    // When a link is found
    func listenForNewLink() {
        print("Started listening for link with partner")
        DatabaseManager.shared.listenForNewLink(completion: { [weak self] result in
            switch result {
            
            // In success case we are returned a gateNumber. Send this to home view to update UI in accordance with correct gate number.
            case .success(let gateNumber):
                guard let strongSelf = self else {
                    return
                }
                
                guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
                    print("")
                    return
                }
                
                // If there is a link, update user selections
                UserRunSelections.shared.setIsRunningWithOneGate(bool: false)
                
                // Send partner email to home view as test to update UI. Should really get and send name. Send gate number for UI update.
                strongSelf.homeViewModelDelegate?.didUpdatePartnerUI(partner: partnerEmail, gateNumber: gateNumber)
               
                // Start fetching partner profile pic
                strongSelf.fetchProfilePic(email: partnerEmail)
                print ("Successfully detected update to link")
                
            case .failure(_):
                guard let strongSelf = self else {
                    return
                }
                print("No link to detect.")
                
                // If there is no link, update user selections
                UserRunSelections.shared.setIsRunningWithOneGate(bool: true)
                
                // Tell home that there is no partner and that it is gate 1.
                // Also, if fetch fails in general, show unlinked view on home VC.
                strongSelf.homeViewModelDelegate?.didUpdatePartnerUI(partner: "No partner", gateNumber: 0)
            }
        })
    }
    
    private func listenForEndOfCurrentRun() {
        DatabaseManager.shared.listenForEndOfCurrentRun(completion: { [weak self] success in
            if success {
                print("listened for end")
                DatabaseManager.shared.getCurrentRunData(completion: { [weak self] result in
                    switch result {
                        case .success(let runData):
                            guard let strongSelf = self else {
                                return
                            }
                            // Convert times to total time
                            let runResult = strongSelf.getCurrentResult(run: runData)
                            
                            // Calls on home VC to open results VC
                            strongSelf.homeViewModelDelegate?.didGetRunResult(result: runResult)
                            
                            // Clean up after completed run
                            DatabaseManager.shared.cleanUpAfterRunCompleted(completion: { _ in
                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reset"), object: nil)
                            })
                                
                        case .failure(let error):
                            print(error)
                            // Should show error to user!!!
                            // Clean up after completed run regardless of success or not
                            DatabaseManager.shared.cleanUpAfterRunCompleted(completion: { _ in
                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reset"), object: nil)
                            })
                    }
                })
            }
            else {

            }
        })
    }
    
    private func currentRunOngoing() {
        DatabaseManager.shared.currentRunOngoing(completion: { success in
            if success {
                print("Listening for ongoing race")
            }
            else {
                print("no onging race")
            }
        })
    }
    
    // Converts data of run in database to run result object, taking into considertion users selected units and units applied when the run was saved
    private func getCurrentResult(run: [String: Any]) -> RunResults {
        
        // If unit used when this run was set is metric system, unit of run will be true. If nil, will also be true
        var unitOfSavedRun = true
        if let metric = run["metric_system"] as? Bool {
            if metric == false {
                unitOfSavedRun = false
            }
        }
        
        // Convert data in database to values needed to create a run result object
        if let endTime = run["end_time"] as? Double,
           let startTime = run["start_time"] as? Double,
           let distance = run["run_distance"] as? Int,
           let type = run["run_type"] as? String,
           let date = run["run_date"] as? String {
            
            // Get total race time in seconds
            let totalSeconds = endTime - startTime
            let timeInDecimals = totalSeconds.round(to: 2)
            let hours = totalSeconds / 3600
            
            // Find times in min, sec and hundreths
            let milliseconds = totalSeconds * 100
            let millisecondsInt = Int(milliseconds)
            
            // Convert to time components
            let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisecondsInt)
            
            // Get strings for time components
            let raceTimeHundreths = String(format: "%02d", hundreths)
            let raceTimeSeconds = String(format: "%02d", seconds)
            let raceTimeMinutes = String(format: "%02d", minutes)
            
            // Get speed in correct unit
            let speed = calculateSpeed(timeInHours: hours, unitOfSavedRun: unitOfSavedRun, runDistance: distance)
            
            // Get distance in correct unit
            let runDistance = calculateDistance(runDistance: distance, unitOfSavedRun: unitOfSavedRun)
            
            // Get date formatted as date
            let dateAsDate = getDate(date: date)
            
            let runResult = RunResults(time: timeInDecimals,
                                       minutes: raceTimeMinutes,
                                       seconds: raceTimeSeconds,
                                       hundreths: raceTimeHundreths,
                                       distance: runDistance,
                                       averageSpeed: speed,
                                       type: type,
                                       date: dateAsDate,
                                       runID: "")
            
            return runResult
        }
        
        else {
            return RunResults(time: 0.00,
                              minutes: "00",
                              seconds: "00",
                              hundreths: "00",
                              distance: 00,
                              averageSpeed: 0.00,
                              type: "Sprint",
                              date: Date(),
                              runID: "00")
        }
    }
    
    // Calculates the speed in the units that the user has selected, regardless of the units in which the run is saved in the database. I.e. converts saved run to correct units.
    private func calculateSpeed(timeInHours: Double, unitOfSavedRun: Bool, runDistance: Int) -> Double {
        
        var speedInDecimals = 0.0
        
        // Units currently selecte by user
        var metricSystem = true
        if let selectedSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if selectedSystem == false {
                metricSystem = false
            }
        }
        
        // # 1 Users current selected system is Metric system
        // #1.1 Saved run and selected units are the same, both in metric
        if metricSystem == true && unitOfSavedRun == true {
            
            // Find distance in kilometers from distance in meters
            let kilometers = Double(runDistance) / 1000
            let speed = kilometers / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        // #1.1 Saved run is in imperial units and selected units are in metric
        else if metricSystem == true && unitOfSavedRun == false {
            
            // Convert from distance in yards to distance in kilometers
            let kilometers = Double(runDistance) * 0.0009144
            let speed = kilometers / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        
        // # 2 Users current selected system is Imperial system
        // #2.1 Saved run and selected units are the same, both in imperial
        else if metricSystem == false && unitOfSavedRun == false {
            
            // Find distance in miles from yards
            let miles = Double(runDistance) * 0.000568181818
            let speed = miles / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        // #2.1 Saved run is in metric, but selected units are in imperial
        else if metricSystem == false && unitOfSavedRun == true {
            
            // Find distance in miles from meters
            let miles = Double(runDistance) * 0.000621371192
            let speed = miles / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        else {
            return 0.0
        }
    }
    
    private func calculateDistance(runDistance: Int, unitOfSavedRun: Bool) -> Int {
        
        // Units currently selecte by user
        var metricSystem = true
        if let selectedSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if selectedSystem == false {
                metricSystem = false
            }
        }
        
        // # 1 Users current selected system is Metric system
        // #1.1 Saved run and selected units are the same, both in metric
        if metricSystem == true && unitOfSavedRun == true {
            
            // Find distance in meters
            return runDistance
        }
        // #1.1 Saved run is in imperial units and selected units are in metric
        else if metricSystem == true && unitOfSavedRun == false {
            
            // Convert from distance in yards to distance in meters
            let meters = yardsToMeters(yards: runDistance)
            return Int(meters)
        }
        
        // # 2 Users current selected system is Imperial system
        // #2.1 Saved run and selected units are the same, both in imperial
        else if metricSystem == false && unitOfSavedRun == false {
            
            // Find distance in yards
            return runDistance

        }
        // #2.1 Saved run is in metric, but selected units are in imperial
        else if metricSystem == false && unitOfSavedRun == true {
            
            // Find distance in yards from meters
            let yards = metersToYards(meters: runDistance)
            return Int(yards)
        }
        else {
            return 0
        }
    }
    
    private func getDate(date: String) -> Date {
        if let dateAsDate = FirstGateViewModel.dateFormatterShort.date(from: date) {
            return dateAsDate
        }
        else {
            return Date()
        }
    }
    
    func milliSecondsToMinutesSecondsHundreths (milliseconds : Int) -> (Int, Int, Int) {
      return (milliseconds / 6000, (milliseconds % 6000) / 100, (milliseconds % 60000) % 100)
    }
    
    func metersToYards(meters: Int) -> Double {
        return Double(meters) * 1.0936133
    }
    
    func yardsToMeters(yards: Int) -> Double {
        return Double(yards) * 0.9144
    }
    
    func kmhToMph(kmh: Double) -> Double {
        return kmh * 0.621371192
    }
    
    func mphToKmh(mph: Double) -> Double {
        return mph * 1.609344
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
