//
//  SetUpRunViewModel.swift
//  Runner
//
//  Created by Ingrid on 15/09/2021.
//

import Foundation


protocol SetUpRunViewModelDelegate: AnyObject {
    func showReactionRun()
}

class SetUpRunViewModel {
    
    weak var setUpRunViewModelDelegate: SetUpRunViewModelDelegate?
    let selectionModel = UserRunSelections.shared
    
    init() {

    }
    
    func selectedRunType() {
        let selectedRunType = selectionModel.getUserSelectedType()

        if selectedRunType == String(UserRunSelections.runTypes.Reaction.rawValue) {
            self.setUpRunViewModelDelegate?.showReactionRun()
        }
        else {

        }
    }
    
    /// Sets User selections after segment control is altered
    func setUserSelectedRunner(userIsRunning: Bool) {
        selectionModel.setUserIsRunning(running: userIsRunning)
    }
    
   
}
    
