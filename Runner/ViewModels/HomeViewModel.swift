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
                            let runResult = strongSelf.timesToResult(times: runData)
                            
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
    
    private func timesToResult(times: [String: Any]) -> RunResults {
        if let endTime = times["end_time"] as? Double,
           let startTime = times["start_time"] as? Double,
           let distance = times["run_distance"] as? Int,
           let type = times["run_type"] as? String,
           let date = times["run_date"] as? String,
           let runID = times["run_id"] as? String {
            
            // Get total race time in seconds
            let totalSeconds = endTime - startTime
            let timeInDecimals = totalSeconds.round(to: 2)
            
            // Find average time
            let hours = totalSeconds / 3600
            let kilometers = Double(distance) / 1000

            print(hours, kilometers)
            
            let averageSpeed = kilometers / hours
            let averageSpeedInDecimals = averageSpeed.round(to: 2)
            
            // Find times in min, sec and hundreths
            let milliseconds = totalSeconds * 100
            let millisecondsInt = Int(milliseconds)
            
            let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisecondsInt)
            
            let raceTimeHundreths = String(format: "%02d", hundreths)
            let raceTimeSeconds = String(format: "%02d", seconds)
            let raceTimeMinutes = String(format: "%02d", minutes)
            
            if let dateAsDate = FirstGateViewModel.dateFormatterShort.date(from: date) {
                
                // Create run result with data
                let runResult = RunResults(time: timeInDecimals,
                                           minutes: raceTimeMinutes,
                                           seconds: raceTimeSeconds,
                                           hundreths: raceTimeHundreths,
                                           distance: distance,
                                           averageSpeed: averageSpeedInDecimals,
                                           type: type,
                                           date: dateAsDate,
                                           runID: runID)
                return runResult
            }
            else {
                // Create run result with data
                let runResult = RunResults(time: timeInDecimals,
                                           minutes: raceTimeMinutes,
                                           seconds: raceTimeSeconds,
                                           hundreths: raceTimeHundreths,
                                           distance: distance,
                                           averageSpeed: averageSpeedInDecimals,
                                           type: type,
                                           date: Date(),
                                           runID: runID)
                return runResult
            }
        }
        
        // If something went wrong when converting data
        else {
            print("Something went wrong converting data from run results to a run result object.")
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
    
    func milliSecondsToMinutesSecondsHundreths (milliseconds : Int) -> (Int, Int, Int) {
      return (milliseconds / 6000, (milliseconds % 6000) / 100, (milliseconds % 60000) % 100)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
