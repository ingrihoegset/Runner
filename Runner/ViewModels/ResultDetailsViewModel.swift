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
    
    func getAllIdenticalRunsLocally(selectedRun: RunResults, allruns: [RunResults]) {
        var sortedRuns = [Double]()
        let selectedRunType = selectedRun.type
        let selectedRunDistance = selectedRun.distance
        
        for run in allruns {
            
            let distance = run.distance
            let type = run.type
            
            if type == selectedRunType && distance == selectedRunDistance {
                sortedRuns.append(run.time)
            }
        }
        resultsViewModelDelegate?.sortedRuns(sortedRuns: sortedRuns)
    }
}
    
