//
//  RunHelper.swift
//  Runner
//
//  Created by Ingrid on 21/11/2021.
//

import Foundation

struct RunHelper {
    
    // MARK: - Properties
    static let sharedInstance = RunHelper()
    
    // MARK: - Methods
    // Converts data of run in database to run result object, taking into considertion users selected units and units applied when the run was saved
    func getCurrentResult(run: [String: Any]) -> RunResults {
        
        // If unit used when this run was set is metric system, unit of run will be true. If nil, will also be true
        var unitOfSavedRun = true
        if let metric = run["metric_system"] as? Bool {
            if metric == false {
                unitOfSavedRun = false
            }
        }
        
        // Convert data in database to values needed to create a run result object
        if let distance = run["run_distance"] as? Int,
           let type = run["run_type"] as? String,
           let date = run["run_date"] as? String,
           let runID = run["run_id"] as? String,
           var times = run["times"] as? [Double] {
            
            // Order times from smallest to largest
            times.sort(by: <)
            
            // Do calculations according to run type
            if type == UserRunSelections.runTypes.Reaction.rawValue {
                let reactionRun = createReactionRun(distance: distance, type: type, date: date, runID: runID, times: times, unitOfSavedRun: unitOfSavedRun)
                return reactionRun
            }
            else if type == UserRunSelections.runTypes.FlyingStart.rawValue {
                let flyingStartRun = createFlyingStartRun(distance: distance, type: type, date: date, runID: runID, times: times, unitOfSavedRun: unitOfSavedRun)
                return flyingStartRun
            }
            else {
                let sprintRun = createSprintRun(distance: distance, type: type, date: date, runID: runID, times: times, unitOfSavedRun: unitOfSavedRun)
                return sprintRun
            }
        }
        else {
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
    
    private func getTimeInHours(totalRunTime: Double) -> Double {
        // Get total race time in seconds
        let totalSeconds = totalRunTime
        let hours = totalSeconds / 3600
        return hours
    }
    
    private func convertToMilliseconds(totalRunTime: Double) -> Int {
        // Find times in min, sec and hundreths
        let totalSeconds = totalRunTime
        let milliseconds = totalSeconds * 100
        let millisecondsInt = Int(milliseconds)
        return millisecondsInt
    }
    
    private func getTimesForSprint(times: [Double]) -> [String: Double] {
        guard let startTime = times.first, let endTime = times.last else {
            return ["totalTime": 0.0]
        }
        let totalTime = endTime - startTime
        return ["totalTime": totalTime]
    }
    
    private func getTimesForReaction(times: [Double]) -> [String: Double] {
        guard let startTime = times.first, let endTime = times.last else {
            return ["totalTime": 0.0]
        }
        // If all times where received, we can calculate the reaction time
        var reactionTime = 0.0
        if times.count == 3 {
            reactionTime = times[1] - startTime
        }
        let totalTime = endTime - startTime
        return ["totalTime": totalTime, "reactionTime": reactionTime]
    }
    
    private func createReactionRun(distance: Int, type: String, date: String, runID: String, times: [Double], unitOfSavedRun: Bool) -> RunResults {
        
        let runTimes = getTimesForReaction(times: times)
        let totalRunTime = runTimes["totalTime"] ?? 0.0
        let reactionTime = runTimes["reactionTime"] ?? 0.0
        
        let timeInDecimals = totalRunTime.round(to: 2)
        let hours = getTimeInHours(totalRunTime: totalRunTime)
        let millisenconds = convertToMilliseconds(totalRunTime: totalRunTime)
        
        // Convert to time components
        let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisenconds)
        
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
        
        let reactionTimeInDecimals = reactionTime.round(to: 2)
        let milliseconds = convertToMilliseconds(totalRunTime: reactionTime)
        let (reactionMinutes, reactionSeconds, reactionHundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: milliseconds)
        let reactionTimeHundreths = String(format: "%02d", reactionHundreths)
        let reactionTimeSeconds = String(format: "%02d", reactionSeconds)
        let _ = String(format: "%02d", reactionMinutes)
        
        let runResult = RunResults(time: timeInDecimals,
                                   minutes: raceTimeMinutes,
                                   seconds: raceTimeSeconds,
                                   hundreths: raceTimeHundreths,
                                   distance: runDistance,
                                   averageSpeed: speed,
                                   type: type,
                                   date: dateAsDate,
                                   runID: runID,
                                   reactionTime: reactionTimeInDecimals,
                                   reactionSeconds: reactionTimeSeconds,
                                   reactionHundreths: reactionTimeHundreths)
        return runResult
    }
    
    private func createSprintRun(distance: Int, type: String, date: String, runID: String, times: [Double], unitOfSavedRun: Bool) -> RunResults {
        
        let runTimes = getTimesForSprint(times: times)
        let totalRunTime = runTimes["totalTime"] ?? 0.0
        
        let timeInDecimals = totalRunTime.round(to: 2)
        let hours = getTimeInHours(totalRunTime: totalRunTime)
        let millisenconds = convertToMilliseconds(totalRunTime: totalRunTime)
        
        // Convert to time components
        let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisenconds)
        
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
    
    private func createFlyingStartRun(distance: Int, type: String, date: String, runID: String, times: [Double], unitOfSavedRun: Bool) -> RunResults {
        
        let runTimes = getTimesForFlyingStart(times: times)
        let totalRunTime = runTimes["totalTime"] ?? 0.0
        
        let timeInDecimals = totalRunTime.round(to: 2)
        let hours = getTimeInHours(totalRunTime: totalRunTime)
        let millisenconds = convertToMilliseconds(totalRunTime: totalRunTime)
        
        // Convert to time components
        let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisenconds)
        
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
    
    
    private func getTimesForFlyingStart(times: [Double]) -> [String: Double] {
        // Start time is not first element, this is just when run has started. times[1] is when runner crosses first gate
        var startTime = 0.0
        if times.count == 3 {
            startTime = times[1]
        }
        // If count not 3 than something went wrong
        // Return 0.0
        else {
            return ["totalTime": 0.0]
        }
        
        guard let endTime = times.last else {
            return ["totalTime": 0.0]
        }
        let totaltime = endTime - startTime
        return ["totalTime": totaltime]
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
    
    private func milliSecondsToMinutesSecondsHundreths (milliseconds : Int) -> (Int, Int, Int) {
      return (milliseconds / 6000, (milliseconds % 6000) / 100, (milliseconds % 60000) % 100)
    }
    
    private func metersToYards(meters: Int) -> Double {
        return Double(meters) * 1.0936133
    }
    
    private func yardsToMeters(yards: Int) -> Double {
        return Double(yards) * 0.9144
    }
    
    private func kmhToMph(kmh: Double) -> Double {
        return kmh * 0.621371192
    }
    
    private func mphToKmh(mph: Double) -> Double {
        return mph * 1.609344
    }
    
    
}
