
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
}

class StatisticsViewModel {
    
    weak var statisticsViewModelDelegate: StatisticsViewModelDelegate?

    
    init() {

    }
    
    // Get all completed runs from database
    func getCompletedRuns() {

        
        // Gets all completed run ids saved under user
        DatabaseManager.shared.getAllCompletedRuns(completion: { [weak self] result in
            switch result {
            case .success(let runsData):
                guard let strongSelf = self else {
                    return
                }
                let transformedRunData = strongSelf.dataToResults(times: runsData)
                strongSelf.statisticsViewModelDelegate?.reloadTableView(completedRunsArray: transformedRunData)

            case .failure(let error):
                print(error)
            }
        })
    }
    
    // Converts data from database to Runresult
    private func dataToResults(times: [[String: Any]]) -> [RunResults] {
        
        var runResults = [RunResults]()
        
        // Transform all results from database to runresult that is formatted for statistics display
        for x in 0..<times.count {
            if let endTime = times[x]["end_time"] as? Double,
               let startTime = times[x]["start_time"] as? Double,
               let distance = times[x]["run_distance"] as? Int,
               let type = times[x]["run_type"] as? String,
               let date = times[x]["run_date"] as? String {

                // Get total race time in seconds
                let totalSeconds = endTime - startTime
                let timeInDecimals = totalSeconds.round(to: 2)
                
                // Find average time
                let hours = totalSeconds / 3600
                let kilometers = Double(distance) / 1000
                
                let averageSpeed = kilometers / hours
                let averageSpeedInDecimals = averageSpeed.round(to: 2)
                
                // Find times in min, sec and hundreths
                let milliseconds = totalSeconds * 100
                let millisecondsInt = Int(milliseconds)
                
                let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisecondsInt)
                
                let raceTimeHundreths = String(format: "%02d", hundreths)
                let raceTimeSeconds = String(format: "%02d", seconds)
                let raceTimeMinutes = String(format: "%02d", minutes)
                
                // Create run result with data
                let runResult = RunResults(time: timeInDecimals,
                                           minutes: raceTimeMinutes,
                                           seconds: raceTimeSeconds,
                                           hundreths: raceTimeHundreths,
                                           distance: distance,
                                           averageSpeed: averageSpeedInDecimals,
                                           type: type,
                                           date: date)
                
                runResults.append(runResult)
            }
            
            // If something went wrong when converting data
            else {
                print("Something went wrong converting data from run results to a run result object.")
                let runresult = RunResults(time: 00.00,
                                           minutes: "00",
                                           seconds: "00",
                                           hundreths: "00",
                                           distance: 00,
                                           averageSpeed: 00.00,
                                           type: "Speed",
                                           date: "01.01.1900")
                runResults.append(runresult)
            }
        }
        return runResults
    }
    
    func milliSecondsToMinutesSecondsHundreths (milliseconds : Int) -> (Int, Int, Int) {
      return (milliseconds / 6000, (milliseconds % 6000) / 100, (milliseconds % 60000) % 100)
    }
}
