//
//  SetUpRunViewController.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import UIKit

class SetUpRunViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        button.backgroundColor = Constants.mainColorDark
        button.setTitle("New run", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(didTapNewRace), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        return button
    }()
    
    let lengthPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.lengthOfLap, unit: "m", number: 3, initialValue: 30)
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == false {
                picker.unitLabel.text = "yd"
            }
        }
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.tag = 0
        return picker
    }()
    
    let delayPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.delayTime, unit: "s", number: 2, initialValue: 3)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.tag = 0
        return picker
    }()

    let reactionPicker: CustomPickerView = {
        let picker = CustomPickerView(subTitle: Constants.reactionPeriod, unit: "s", number: 2, initialValue: 5)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isHidden = true
        picker.tag = 1
        return picker
    }()
    
    let runnerSegmentControl: RoundedSegmentedControl = {
        let control = RoundedSegmentedControl(items: ["Me", "You"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.mainColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorAccent!,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.mainColorDark!,
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
        control.selectedSegmentTintColor = Constants.mainColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorAccent!,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.mainColorDark!,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        return control
    }()
    
    let runnerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let runnerViewLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " Who's running?"
        label.textAlignment = .left
        label.textColor = Constants.textColorAccent
        label.font = Constants.mainFont
        label.isHidden = true
        return label
    }()
    
    let falseStartView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    let falseViewLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " False start?"
        label.textAlignment = .left
        label.textColor = Constants.textColorAccent
        label.font = Constants.mainFont
        label.isHidden = true
        return label
    }()
    
    /// Views related to onboarding
    let onBoardScroll: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Scroll us!", pointerPlacement: "topMiddle", dismisser: false)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 0
        bubble.alpha = 0
        return bubble
    }()
    
    let onBoardReaction: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Select interval for random starting signal!", pointerPlacement: "bottomLeft", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 1
        bubble.isHidden = true
        return bubble
    }()
    
    let onboardBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.lightGray?.withAlphaComponent(0.6)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set run"
        
        // Subscribe to delegates
        setUpRunViewModel.setUpRunViewModelDelegate = self
        onBoardScroll.onBoardingBubbleDelegate = self
        onBoardReaction.onBoardingBubbleDelegate = self
        delayPicker.customPickerDelegate = self
        reactionPicker.customPickerDelegate = self
        lengthPicker.customPickerDelegate = self
        
        view.backgroundColor = Constants.mainColor

        view.addSubview(falseStartView)
        view.addSubview(falseViewLabel)

        falseStartView.addSubview(falseStartSegmentControl)
        view.addSubview(runnerView)
        view.addSubview(runnerViewLabel)
        runnerView.addSubview(runnerSegmentControl)
        
        view.addSubview(newRaceButton)
        view.bringSubviewToFront(falseViewLabel)
        
        // Adjusts view for selected type of run
        setUpRunViewModel.selectedRunType()
        setUpRunViewModel.isConnectedToParter()
        setUpRunViewModel.showReactionOnboarding()
        
        view.addSubview(topView)
        
        view.addSubview(lengthPicker)
        view.addSubview(reactionPicker)
        view.addSubview(onboardBackground)
       // topView.addSubview(onboardBackground)
        view.addSubview(delayPicker)
        
        onboardBackground.bringSubviewToFront(delayPicker)

        //Add onboarding view
        view.addSubview(onBoardScroll)
        view.addSubview(onBoardReaction)
        
        // Will show onboard scroll if not onboarded yet
        setUpRunViewModel.showScrollOnboardingFirstTime()
        
        // Set correct title for distance picker
        setUpRunViewModel.setDistancePickerTitle()
        
        // Make sure run selections are always reset when loaded
        setUpRunViewModel.setFalseStartSelection(falseStart: false)
        setUpRunViewModel.setUserSelectedRunner(userIsRunning: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        print(lengthPicker.frame)
        print(lengthPicker.detail1.frame)
        
        // Adjusts metrics on opening of view if units change
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == true {
                lengthPicker.unitLabel.text = "m"
            }
            else {
                lengthPicker.unitLabel.text = "yd"
            }
        }
        else {
            lengthPicker.unitLabel.text = "m"
        }
    }
    
    deinit {
        print("DESTROYED SETUPRUN")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topView.bottomAnchor.constraint(equalTo: falseStartView.topAnchor, constant: -Constants.sideMargin * 2).isActive = true
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
        
        onboardBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        onboardBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        onboardBackground.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        onboardBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        onBoardScroll.centerXAnchor.constraint(equalTo: delayPicker.detail2.centerXAnchor).isActive = true
        onBoardScroll.topAnchor.constraint(equalTo: delayPicker.detail2.bottomAnchor, constant: 5).isActive = true
        onBoardScroll.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        onBoardScroll.widthAnchor.constraint(equalTo: delayPicker.widthAnchor, multiplier: 0.5).isActive = true
        
        reactionPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.topAnchor.constraint(equalTo: lengthPicker.bottomAnchor, constant: Constants.sideMargin).isActive = true
        reactionPicker.heightAnchor.constraint(equalTo: topView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true
        reactionPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        onBoardReaction.leadingAnchor.constraint(equalTo: reactionPicker.detail2.leadingAnchor).isActive = true
        onBoardReaction.bottomAnchor.constraint(equalTo: reactionPicker.detail2.topAnchor, constant: -5).isActive = true
        onBoardReaction.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        onBoardReaction.trailingAnchor.constraint(equalTo: reactionPicker.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        newRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        newRaceButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        newRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        runnerView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        runnerView.bottomAnchor.constraint(equalTo: newRaceButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        runnerView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        runnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        runnerViewLabel.leadingAnchor.constraint(equalTo: runnerView.leadingAnchor).isActive = true
        runnerViewLabel.bottomAnchor.constraint(equalTo: runnerView.topAnchor).isActive = true
        runnerViewLabel.heightAnchor.constraint(equalToConstant: Constants.sideMargin).isActive = true
        runnerViewLabel.trailingAnchor.constraint(equalTo: runnerView.trailingAnchor).isActive = true
        
        runnerSegmentControl.leadingAnchor.constraint(equalTo: runnerView.leadingAnchor).isActive = true
        runnerSegmentControl.bottomAnchor.constraint(equalTo: runnerView.bottomAnchor).isActive = true
        runnerSegmentControl.heightAnchor.constraint(equalTo: runnerView.heightAnchor).isActive = true
        runnerSegmentControl.trailingAnchor.constraint(equalTo: runnerView.trailingAnchor).isActive = true
        
        falseStartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        falseStartView.bottomAnchor.constraint(equalTo: newRaceButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        falseStartView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        falseStartView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        
        falseViewLabel.leadingAnchor.constraint(equalTo: falseStartView.leadingAnchor).isActive = true
        falseViewLabel.bottomAnchor.constraint(equalTo: falseStartView.topAnchor).isActive = true
        falseViewLabel.heightAnchor.constraint(equalToConstant: Constants.sideMargin).isActive = true
        falseViewLabel.trailingAnchor.constraint(equalTo: falseStartView.trailingAnchor).isActive = true
        
        falseStartSegmentControl.leadingAnchor.constraint(equalTo: falseStartView.leadingAnchor).isActive = true
        falseStartSegmentControl.bottomAnchor.constraint(equalTo: falseStartView.bottomAnchor).isActive = true
        falseStartSegmentControl.heightAnchor.constraint(equalTo: falseStartView.heightAnchor).isActive = true
        falseStartSegmentControl.trailingAnchor.constraint(equalTo: falseStartView.trailingAnchor).isActive = true
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
    
    /// Determines if false start has been selected. True implies our user selected false start
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
            setUpRunViewModel.setFalseStartSelection(falseStart: false)
          break
          case 1:
            setUpRunViewModel.setFalseStartSelection(falseStart: true)
          break
          default:
            setUpRunViewModel.setFalseStartSelection(falseStart: false)
          break
       }
    }
}

extension SetUpRunViewController: SetUpRunViewModelDelegate {
    
    func setDistancePickerTitle(title: String) {
        DispatchQueue.main.async {
            self.lengthPicker.label.text = title
        }
    }
    
    func showScrollOnboardingFirstTime() {
        onBoardScroll.animateOnboardingBubble()
        onBoardScroll.isHidden = false
        animateOnboardingLockScreen()
    }
    
    func hideScrollOnboarding() {
        onBoardScroll.isHidden = true
        animateHideOnboardingLockScreen()
    }
    
    func showReactionRun() {
        reactionPicker.isHidden = false
    }
    
    func showLinkedFeatures(isRunningWithOneGate: Bool) {
        if isRunningWithOneGate == false {
            runnerView.isHidden = false
            runnerViewLabel.isHidden = false
            falseStartView.isHidden = false
            falseViewLabel.isHidden = false
        }
    }
    
    func showReactionOnboarding() {
        DispatchQueue.main.async {
            self.onBoardReaction.isHidden = false
            self.onBoardReaction.animateOnboardingBubble()
        }
    }
    
    func hideOnboardReaction() {
        DispatchQueue.main.async {
            self.onBoardReaction.isHidden = true
        }
    }
    
    func animateOnboardingLockScreen() {
        UIView.animate(withDuration: 0.4,
            animations: {
                self.onboardBackground.alpha = 1
            })
    }
    
    func animateHideOnboardingLockScreen() {
        UIView.animate(withDuration: 0.3,
            animations: {
                self.onboardBackground.alpha = 0
            })
    }
}

extension SetUpRunViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        sender.isHidden = true
        
        // Check if has been onboarded. When onboarded, set user default to true, this will prevent message from showing again
        // Scroller
        if sender.tag == 0 {
            setUpRunViewModel.scrollOnboarded()
        }
        // Reaction
        if sender.tag == 1 {
            setUpRunViewModel.reactionOnboarded()
        }
    }
}

extension SetUpRunViewController: CustomPickerDelegate {
    
    func pickerScrollOnboarded(sender: UIView) {

        if sender.tag == 0 {
            setUpRunViewModel.scrollOnboarded()
        }
        if sender.tag == 1 {
            setUpRunViewModel.reactionOnboarded()
        }
    }
}
