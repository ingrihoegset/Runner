//
//  ResultDetailsViewModel.swift
//  Runner
//
//  Created by Ingrid on 20/08/2021.
//

import Foundation

protocol ResultDetailsViewModelDelegate: AnyObject {
    func sortedRuns(sortedRuns: [Double])
}

class ResultDetailsViewModel {
    
    weak var resultsViewModelDelegate: ResultDetailsViewModelDelegate?
    
    init() {

    }
    
    func getAllIdenticalRuns(type: String, distance: Int, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.getAllSimilarRuns(completion: { [weak self ] result in
            switch result {
            case .success(let runs):
                guard let sortedRuns = self?.sortIdenticalRuns(runs: runs, type: type, distance: distance) else {
                    completion(false)
                    return
                }
                print("sorted runs: ", sortedRuns)
                self?.resultsViewModelDelegate?.sortedRuns(sortedRuns: sortedRuns)
                completion(true)

            case .failure(let error):
                print("Failed to download runs: \(error)")
                completion(false)
            }
        })
    }
    
    private func sortIdenticalRuns(runs: [[String: Any]], type: String, distance: Int) -> [Double] {

        var sortedRuns = [Double]()
        
        for run in runs {
            
            // If unit used when this run was set is metric system, unit of run will be true. If nil, will also be true
            var unitOfSavedRun = true
            if let metric = run["metric_system"] as? Bool {
                if metric == false {
                    unitOfSavedRun = false
                }
            }
            
            if let runType = run["run_type"] as? String,
               let runDistance = run["run_distance"] as? Int,
               let endTime = run["end_time"] as? Double,
               let startTime = run["start_time"] as? Double {
                
                let distanceComparableUnit = calculateDistance(runDistance: runDistance, unitOfSavedRun: unitOfSavedRun)
                
                print(runType, type, distanceComparableUnit, runDistance, distance)
                
                if runType == type && distanceComparableUnit == distance {
                    let time = endTime - startTime
                    sortedRuns.append(time)
                }
            }
        }
        return sortedRuns
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
    
    func metersToYards(meters: Int) -> Double {
        return Double(meters) * 1.0936133
    }
    
    func yardsToMeters(yards: Int) -> Double {
        return Double(yards) * 0.9144
    }
}
    
