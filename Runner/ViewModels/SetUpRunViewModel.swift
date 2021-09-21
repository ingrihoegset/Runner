//
//  SetUpRunViewModel.swift
//  Runner
//
//  Created by Ingrid on 15/09/2021.
//

import Foundation


protocol SetUpRunViewModelDelegate: AnyObject {
    func showReactionRun()
    func showLinkedFeatures(isRunningWithOneGate: Bool)
}

class SetUpRunViewModel {
    
    weak var setUpRunViewModelDelegate: SetUpRunViewModelDelegate?
    let selectionModel = UserRunSelections.shared
    
    init() {

    }
    
    /// Checks selected run type so that UI is correct
    func selectedRunType() {
        let selectedRunType = selectionModel.getUserSelectedType()

        if selectedRunType == String(UserRunSelections.runTypes.Reaction.rawValue) {
            self.setUpRunViewModelDelegate?.showReactionRun()
        }
        else {

        }
    }
    
    /// Checks if linked to a partner or not. If not linked runner selection and false start selection not necessary
    func isConnectedToParter() {
        let isRunningWithOneGate = selectionModel.getIsRunningWithOneGate()

        if isRunningWithOneGate == true {
            setUpRunViewModelDelegate?.showLinkedFeatures(isRunningWithOneGate: isRunningWithOneGate)
        }
        else {
            setUpRunViewModelDelegate?.showLinkedFeatures(isRunningWithOneGate: false)
        }
    }
    
    /// Sets User selections after segment control is altered
    func setUserSelectedRunner(userIsRunning: Bool) {
        selectionModel.setUserIsRunning(running: userIsRunning)
    }
    
   
}
    
