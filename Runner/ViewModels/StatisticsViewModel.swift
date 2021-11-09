
//
//  StatisticsViewModel.swift
//  Runner
//
//  Created by Ingrid on 23/07/2021.
//

import Foundation
import UIKit


protocol StatisticsViewModelDelegate: AnyObject {
    func reloadTableView(completedRunsArray: [RunResults])
    func reloadTableView()
    func loadYears(years: [String])
    func showOnboardClickMe()
    func hasOnboardedClickMe()
    func showNoRunDataView()
    func hideNoRunDataView()
    func hideSkeletonLoadView()
}

class StatisticsViewModel {
    
    weak var statisticsViewModelDelegate: StatisticsViewModelDelegate?
    
    public static let dateFormatterYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    init() {
        // Listens for if units change and immidiately updates table by downloading date again and converting to correct units
        NotificationCenter.default.addObserver(self, selector: #selector(getCompletedRuns), name: NSNotification.Name(rawValue: "reloadOnUnitChange"), object: nil)

    }
    
    // Listen for update to completed runs
    @objc func getCompletedRuns() {
        
        // Gets all completed run ids saved under user
        DatabaseManager.shared.getAllCompletedRuns(completion: { [weak self] result in
            switch result {
            case .success(let runsData):
                guard let strongSelf = self else {
                    return
                }
                var transformedRunData = strongSelf.dataToResults(times: runsData)
                // Get all years for runs (for Date sorting function)
                let years = strongSelf.createDatesForSorter(runs: transformedRunData)
                // Present newest runs first
                transformedRunData.sort {
                    $0.date > $1.date
                }
                strongSelf.statisticsViewModelDelegate?.reloadTableView(completedRunsArray: transformedRunData)
                strongSelf.statisticsViewModelDelegate?.loadYears(years: years)
                
                // Related to onboarding
                if runsData.count >= 1 {
                    let onboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedTableViewClickMe)
                    if onboarded == false {
                        strongSelf.statisticsViewModelDelegate?.showOnboardClickMe()
                    }
                    // When data is retrieved hide loading view and hide no run view.
                    strongSelf.statisticsViewModelDelegate?.hideSkeletonLoadView()
                    strongSelf.statisticsViewModelDelegate?.hideNoRunDataView()
                }

            case .failure(let error):
                guard let strongSelf = self else {
                    return
                }
                // When no data is retrieved, hide loading view and show no data view
                strongSelf.statisticsViewModelDelegate?.hideSkeletonLoadView()
                strongSelf.statisticsViewModelDelegate?.showNoRunDataView()
                print(error)
            }
        })
    }
    
    // Deletes a saved and completed run from the database.
    func deleteRun(runID: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.deleteRun(runID: runID, completion: { success in
            if success {
                completion(true)
            }
            else {
                completion(false)
            }
        })
    }
    
    // Converts data from database to Runresult
    private func dataToResults(times: [[String: Any]]) -> [RunResults] {
        
        var runResults = [RunResults]()
        
        // Transform all results from database to runresult that is formatted for statistics display
        for x in times {
            let runResult = getCurrentResult(run: x)
            runResults.append(runResult)
        }
        return runResults
    }
    
    private func createDatesForSorter(runs: [RunResults]) -> [String] {
        var years = [String]()
        for run in runs {
            let yearString = StatisticsViewModel.dateFormatterYear.string(from: run.date)

            if years.contains(yearString) {
                // Do nothing
            }
            else {
                years.append(yearString)
            }
        }
        return years
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
           let date = run["run_date"] as? String,
           let runID = run["run_id"] as? String {
            
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
                                       runID: runID)
            
            return runResult
        }
        
        // If something goes wrong in getting data
        else {
            // Important to hav an id - otherwise, run cannot be deleted if something goes wrong
            var id = "00"
            if let runID = run["run_id"] as? String {
                id = runID
            }
            return RunResults(time: 0.00,
                              minutes: "00",
                              seconds: "00",
                              hundreths: "00",
                              distance: 00,
                              averageSpeed: 0.00,
                              type: "Sprint",
                              date: Date(),
                              runID: id)
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
        // #1.2 Saved run is in imperial units and selected units are in metric
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
        // #2.2 Saved run is in metric, but selected units are in imperial
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
        // #1.2 Saved run is in imperial units and selected units are in metric
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
        // #2.2 Saved run is in metric, but selected units are in imperial
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
    
    /// Related to onboarding
    func hasOnboardedClickMe() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedTableViewClickMe)
        statisticsViewModelDelegate?.hasOnboardedClickMe()
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardClickMe() {
        let onboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedTableViewClickMe)
        if onboarded == false {
            statisticsViewModelDelegate?.showOnboardClickMe()
        }
    }
}
