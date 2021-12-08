
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
    func hideOnboardClickMe()
    func showNoRunDataView()
    func hideNoRunDataView()
    func hideSkeletonLoadView()
}

class StatisticsViewModel {
    
    weak var statisticsViewModelDelegate: StatisticsViewModelDelegate?
    let runHelper = RunHelper.sharedInstance
    
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
                else {
                    strongSelf.statisticsViewModelDelegate?.hideOnboardClickMe()
                }

            case .failure(let error):
                guard let strongSelf = self else {
                    return
                }
                // When no data is retrieved, hide loading view and show no data view
                strongSelf.statisticsViewModelDelegate?.hideSkeletonLoadView()
                strongSelf.statisticsViewModelDelegate?.showNoRunDataView()
                strongSelf.statisticsViewModelDelegate?.hideOnboardClickMe()
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
        for run in times {
            let runResult = runHelper.getCurrentResult(run: run)
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
    
    /// Related to onboarding
    func hasOnboardedClickMe() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedTableViewClickMe)
        statisticsViewModelDelegate?.hideOnboardClickMe()
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardClickMe() {
        let onboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedTableViewClickMe)
        if onboarded == false {
            statisticsViewModelDelegate?.showOnboardClickMe()
        }
    }
}
