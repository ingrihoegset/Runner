//
//  SetUpRunViewController.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import UIKit

class SetUpRunViewController: UIViewController {
    
    var setUpRunViewModel = SetUpRunViewModel()

    let newRaceButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColorDark
        button.setTitle("New Run", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(didTapNewRace), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        return button
    }()
    
    let lengthPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.lengthOfLap, unit: "m", number: 3, initialValue: 30)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    let delayPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.delayTime, unit: "s", number: 2, initialValue: 3)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    let reactionPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.reactionPeriod, unit: "s", number: 2, initialValue: 5)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isHidden = true
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Run Details"
        // Subscribe to delegate
        setUpRunViewModel.setUpRunViewModelDelegate = self
        view.backgroundColor = Constants.mainColor

        view.addSubview(delayPicker)
        view.addSubview(lengthPicker)
        view.addSubview(reactionPicker)
        view.addSubview(newRaceButton)
        
        // Adjusts view for selected type of run
        setUpRunViewModel.selectedRunType()
    }
    
    deinit {
        print("DESTROYED SETUPRUN")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        delayPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        delayPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        delayPicker.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235).isActive = true
        delayPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        lengthPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        lengthPicker.topAnchor.constraint(equalTo: delayPicker.bottomAnchor, constant: Constants.sideMargin).isActive = true
        lengthPicker.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235).isActive = true
        lengthPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        reactionPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.topAnchor.constraint(equalTo: lengthPicker.bottomAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235).isActive = true
        reactionPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        newRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        newRaceButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        newRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
    }
    
    /// Takes us to Start Gate View Contoller and sends run selections to User selections
    @objc private func didTapNewRace() {
        
        // Sets length selection variable
        UserRunSelections.shared.setUserSelectedLength(length: lengthPicker.userSelectedNumber)
        if (lengthPicker.userSelectedNumber == 0) {
            UserRunSelections.shared.setUserSelectedLength(length: 30)
        }
        
        // Sets delay selection variable
        UserRunSelections.shared.setUserSelectedDelay(delay: delayPicker.userSelectedNumber)
        if (delayPicker.userSelectedNumber == 0) {
            UserRunSelections.shared.setUserSelectedDelay(delay: 3)
        }
        
        // Sets reaction selection variable
        UserRunSelections.shared.setUserSelectedReaction(reaction: reactionPicker.userSelectedNumber)
        if (reactionPicker.userSelectedNumber == 0) {
            UserRunSelections.shared.setUserSelectedReaction(reaction: 5)
        }

        let destinationController = FirstGateViewController()
        navigationController?.pushViewController(destinationController, animated: true)
    }
}

extension SetUpRunViewController: SetUpRunViewModelDelegate {
    func showReactionRun() {
        reactionPicker.isHidden = false
    }
}
