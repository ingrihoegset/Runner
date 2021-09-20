//
//  SetUpRunViewController.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import UIKit

class SetUpRunViewController: UIViewController {
    
    var setUpRunViewModel = SetUpRunViewModel()
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
    
    let runnerSegmentControl: RoundedSegmentedControl = {
        let name = UserDefaults.standard.value(forKey: "name") as? String
        let control = RoundedSegmentedControl(items: ["Partner", name])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.accentColorDark
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorDarkGray,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorWhite,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        control.addTarget(self, action: #selector(runnerSegmentControl(_:)), for: .valueChanged)
        return control
    }()
    
    let falseStartSegmentControl: RoundedSegmentedControl = {
        let control = RoundedSegmentedControl(items: ["Off","On"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.accentColorDark
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorDarkGray,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorWhite,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        //control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        return control
    }()
    
    let runnerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.accentColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        label.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.text = "Running"
        label.textAlignment = .left
        label.textColor = Constants.textColorDarkGray
        label.font = Constants.mainFontLarge
        return view
    }()
    
    let falseStartView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.accentColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        label.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.text = "False start"
        label.textAlignment = .left
        label.textColor = Constants.textColorDarkGray
        label.font = Constants.mainFontLarge
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Run Details"
        // Subscribe to delegate
        setUpRunViewModel.setUpRunViewModelDelegate = self
        view.backgroundColor = Constants.mainColor

        view.addSubview(topView)
        
        topView.addSubview(delayPicker)
        topView.addSubview(lengthPicker)
        topView.addSubview(reactionPicker)
        
        view.addSubview(falseStartView)
        falseStartView.addSubview(falseStartSegmentControl)
        view.addSubview(runnerView)
        runnerView.addSubview(runnerSegmentControl)
        
        view.addSubview(newRaceButton)
        
        // Adjusts view for selected type of run
        setUpRunViewModel.selectedRunType()
    }
    
    deinit {
        print("DESTROYED SETUPRUN")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topView.bottomAnchor.constraint(equalTo: falseStartView.topAnchor, constant: -Constants.sideMargin).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        delayPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        delayPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        delayPicker.heightAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        delayPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        lengthPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        lengthPicker.topAnchor.constraint(equalTo: delayPicker.bottomAnchor, constant: Constants.sideMargin).isActive = true
        lengthPicker.heightAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        lengthPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        reactionPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.topAnchor.constraint(equalTo: lengthPicker.bottomAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.heightAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        reactionPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        newRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        newRaceButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        newRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        runnerView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        runnerView.bottomAnchor.constraint(equalTo: newRaceButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        runnerView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        runnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        runnerSegmentControl.leadingAnchor.constraint(equalTo: runnerView.centerXAnchor, constant: Constants.sideMargin/4).isActive = true
        runnerSegmentControl.bottomAnchor.constraint(equalTo: runnerView.bottomAnchor, constant: -Constants.sideMargin/4).isActive = true
        runnerSegmentControl.topAnchor.constraint(equalTo: runnerView.topAnchor, constant: Constants.sideMargin/4).isActive = true
        runnerSegmentControl.trailingAnchor.constraint(equalTo: runnerView.trailingAnchor, constant: -Constants.sideMargin/4).isActive = true
        
        falseStartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        falseStartView.bottomAnchor.constraint(equalTo: newRaceButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        falseStartView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        falseStartView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        
        falseStartSegmentControl.leadingAnchor.constraint(equalTo: falseStartView.centerXAnchor, constant: Constants.sideMargin/4).isActive = true
        falseStartSegmentControl.bottomAnchor.constraint(equalTo: falseStartView.bottomAnchor, constant: -Constants.sideMargin/4).isActive = true
        falseStartSegmentControl.topAnchor.constraint(equalTo: falseStartView.topAnchor, constant: Constants.sideMargin/4).isActive = true
        falseStartSegmentControl.trailingAnchor.constraint(equalTo: falseStartView.trailingAnchor, constant: -Constants.sideMargin/4).isActive = true
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
    
    /// Sets who is running when runner segment control is used. True implies our user is running, false implies partner is running
    @objc func runnerSegmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
            setUpRunViewModel.setUserSelectedRunner(userIsRunning: true)
          break
          case 1:
            setUpRunViewModel.setUserSelectedRunner(userIsRunning: false)
          break
          default:
            setUpRunViewModel.setUserSelectedRunner(userIsRunning: true)
          break
       }
    }
}

extension SetUpRunViewController: SetUpRunViewModelDelegate {
    func showReactionRun() {
        reactionPicker.isHidden = false
    }
}
