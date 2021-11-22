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
    func showReactionOnboarding()
    func hideOnboardReaction()
    func showScrollOnboardingFirstTime()
    func hideScrollOnboarding()
    func setDistancePickerTitle(title: String)
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
    
    /// Sets User false start selections after segment control is altered
    func setFalseStartSelection(falseStart: Bool) {
        selectionModel.setUserSelectedFalseStart(falseStart: falseStart)
        print("False selected ", selectionModel.getUserSelectedFalseStart())
    }
    
    func setDistancePickerTitle() {
        if UserRunSelections.shared.getUserSelectedType() == UserRunSelections.runTypes.FlyingStart.rawValue {
            setUpRunViewModelDelegate?.setDistancePickerTitle(title: "Distance between gates")
        }
        else {
            setUpRunViewModelDelegate?.setDistancePickerTitle(title: "Distance to end gate")
        }
    }
    
    func showScrollOnboardingFirstTime() {
        if UserDefaults.standard.bool(forKey: Constants.hasOnBoardedScroll) == false {
            setUpRunViewModelDelegate?.showScrollOnboardingFirstTime()
        }
    }
    
    func scrollOnboarded() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnBoardedScroll)
        setUpRunViewModelDelegate?.hideScrollOnboarding()
        showReactionOnboarding()
    }
    
    func reactionOnboarded() {
        setUpRunViewModelDelegate?.hideOnboardReaction()
        setUpRunViewModelDelegate?.hideScrollOnboarding()
        UserDefaults.standard.set(true, forKey: Constants.hasOnBoardedReaction)
    }
    
    func showReactionOnboarding() {
        let selectedRunType = selectionModel.getUserSelectedType()
        let scrollOnboarded = UserDefaults.standard.bool(forKey: Constants.hasOnBoardedScroll)
        let reactionOnboarded = UserDefaults.standard.bool(forKey: Constants.hasOnBoardedReaction)
        if selectedRunType == String(UserRunSelections.runTypes.Reaction.rawValue) {
            if scrollOnboarded == true && reactionOnboarded == false {
                setUpRunViewModelDelegate?.showReactionOnboarding()
            }
        }
    }
}
    
