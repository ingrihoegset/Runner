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
                self?.resultsViewModelDelegate?.sortedRuns(sortedRuns: sortedRuns)
                completion(false)

            case .failure(let error):
                print("Failed to download runs: \(error)")
                completion(false)
            }
        })
    }
    
    private func sortIdenticalRuns(runs: [[String: Any]], type: String, distance: Int) -> [Double] {
        
        var sortedRuns = [Double]()
        
        for run in runs {
            if let runType = run["run_type"] as? String,
               let runDistance = run["run_distance"] as? Int,
               let endTime = run["end_time"] as? Double,
               let startTime = run["start_time"] as? Double {
                if runType == type && runDistance == distance {
                    let time = endTime - startTime
                    sortedRuns.append(time)
                }
            }
        }
        return sortedRuns
    }
}
    
