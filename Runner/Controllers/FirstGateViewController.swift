//
//  FirstGateViewController.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import UIKit
import AVFoundation

class FirstGateViewController: UIViewController {
    
    var firstGateViewModel = FirstGateViewModel()

    /// Objects related to countdown
    var timer = Timer()
    var audioPlayer: AVAudioPlayer?
    var counter = 3
    
    /// Top display elements
    let displayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let displayLabel1: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.clipsToBounds = true
        button.setTitleColor(Constants.textColorDarkGray, for: .normal)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let displayLabel2: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColor
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.clipsToBounds = true
        button.setTitleColor(Constants.textColorDarkGray, for: .normal)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        button.isUserInteractionEnabled = false
        return button
    }()
      
    let pulsingView: PulsingAnimationView = {
        let view = PulsingAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    let pulsingLabelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.backgroundColor = Constants.accentColor
        view.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        return view
    }()
    
    let pulsingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Waiting"
        label.font = Constants.mainFontLargeSB
        label.clipsToBounds = true
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.textColor = Constants.textColorDarkGray
        return label
    }()
    
    let cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Represents part of view that is analyze in breakobserver
    let focusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor?.withAlphaComponent(0.3)
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = Constants.contrastColor?.cgColor
        if UserRunSelections.shared.getIsRunningWithOneGate() == true {
            view.isHidden = false
        }
        else {
            view.isHidden = true
        }
        return view
    }()
    
    let focusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.image = UIImage(named: "Focus")?.withTintColor(Constants.contrastColor!)
        if UserRunSelections.shared.getIsRunningWithOneGate() == true {
            view.isHidden = false
        }
        else {
            view.isHidden = true
        }
        return view
    }()
    
    let startButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColorDark
        button.setTitle("Start count down", for: .normal)
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(startCountDown), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        return button
     }()
    
    let cancelRaceButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.contrastColor
        button.alpha = 0
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(Constants.textColorWhite, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(cancelRun), for: .touchUpInside)
        return button
    }()
    
    let countDownPickerView: CountDownPicker = {
        let picker = CountDownPicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.alpha = 0
        picker.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        return picker
    }()
    
    let timerView: CounterView = {
        let view = CounterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin, spread: 0)
        return view
    }()
    
    /// Views related to onboarding
    let onBoardFinishLine: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Place phone at your finish line and start count down. Make sure you have enough time to get into position!", pointerPlacement: "topMiddle")
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 0
        bubble.isHidden = true
        return bubble
    }()
    
    let onBoardConnectedStart: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Place your phone at starting line and listen for starting signal!", pointerPlacement: "bottomMiddle")
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 1
        bubble.isHidden = true
        return bubble
    }()
    
    
    deinit {
        print("DESTROYED FIRST GATE")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        
        // Tells Gate whether user is running with one or two gates
        let runningWithOneGate = UserRunSelections.shared.getIsRunningWithOneGate()
        if runningWithOneGate == true {
            title = "End gate"
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.rotate"),
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(switchCameraDirection))
        }
        else {
            title = "Start run"
        }
        
        // Subscribe to delegates
        firstGateViewModel.firstGateViewModelDelegate = self
        onBoardFinishLine.onBoardingBubbleDelegate = self
        onBoardConnectedStart.onBoardingBubbleDelegate = self
        
        // Add top displays
        view.addSubview(displayView)
        displayView.addSubview(displayLabel1)
        displayView.addSubview(displayLabel2)
        view.addSubview(cameraView)

        cameraView.addSubview(focusView)
        focusView.addSubview(focusImageView)
        cameraView.addSubview(onBoardFinishLine)
        
        // Add other elements to view
        view.addSubview(pulsingLabelView)
        pulsingLabelView.addSubview(pulsingLabel)
        pulsingLabelView.addSubview(pulsingView)
        view.addSubview(startButton)
        view.addSubview(onBoardConnectedStart)
        view.addSubview(cancelRaceButton)
        view.addSubview(countDownPickerView)
        view.addSubview(timerView)
        
        // Set tekst in top labels
        setDisplayLabelText()
        setConstraints()
        
        //Related to onboarding
        firstGateViewModel.showOnboardingFinishLineOneUser()
        firstGateViewModel.showOnboardingStartLineTwoUsers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.firstGateViewModel.captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.firstGateViewModel.captureSession.startRunning()
        pulsingView.addAnimations()
    }
    
    
    // Using setConstraints because didlayoutsubview caused memory leak after i implemented the live counter.
    func setConstraints() {
        
        displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        displayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        displayView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        displayLabel1.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        displayLabel1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        displayLabel1.bottomAnchor.constraint(equalTo: displayView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        displayLabel1.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        displayLabel2.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        displayLabel2.bottomAnchor.constraint(equalTo: displayView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        displayLabel2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        displayLabel2.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        pulsingLabelView.topAnchor.constraint(equalTo: displayView.bottomAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        pulsingLabelView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        pulsingLabelView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true

        pulsingView.leadingAnchor.constraint(equalTo: pulsingLabelView.leadingAnchor).isActive = true
        pulsingView.centerYAnchor.constraint(equalTo: pulsingLabelView.centerYAnchor).isActive = true
        pulsingView.widthAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        pulsingView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        pulsingLabel.centerYAnchor.constraint(equalTo: pulsingLabelView.centerYAnchor).isActive = true
        pulsingLabel.leadingAnchor.constraint(equalTo: pulsingView.trailingAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabel.trailingAnchor.constraint(equalTo: pulsingLabelView.trailingAnchor).isActive = true
        pulsingLabel.heightAnchor.constraint(equalTo: pulsingLabelView.heightAnchor).isActive = true
        
        cameraView.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        timerView.topAnchor.constraint(equalTo: displayView.bottomAnchor, constant: Constants.sideMargin / 2).isActive = true
        timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        timerView.widthAnchor.constraint(equalToConstant: (Constants.widthOfDisplay / 2) - 1.5 * Constants.sideMargin).isActive = true
        timerView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        // Must match size of focus frame in breakobserver
        let width = Constants.widthOfDisplay / 6

        focusView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor).isActive = true
        focusView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        focusView.widthAnchor.constraint(equalToConstant: width).isActive = true
        focusView.heightAnchor.constraint(equalToConstant: width).isActive = true
        focusView.layer.cornerRadius = width / 2
        
        onBoardFinishLine.topAnchor.constraint(equalTo: focusView.bottomAnchor).isActive = true
        onBoardFinishLine.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        onBoardFinishLine.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.8).isActive = true
        onBoardFinishLine.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        
        focusImageView.centerYAnchor.constraint(equalTo: focusView.centerYAnchor).isActive = true
        focusImageView.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        focusImageView.widthAnchor.constraint(equalTo: focusView.widthAnchor).isActive = true
        focusImageView.heightAnchor.constraint(equalTo: focusView.heightAnchor).isActive = true
        
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        startButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        onBoardConnectedStart.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2).isActive = true
        onBoardConnectedStart.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        onBoardConnectedStart.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.7).isActive = true
        onBoardConnectedStart.bottomAnchor.constraint(equalTo: startButton.topAnchor).isActive = true
        
        countDownPickerView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        countDownPickerView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor, constant: -Constants.sideMargin).isActive = true
        countDownPickerView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.6).isActive = true
        countDownPickerView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        
        cancelRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        cancelRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelRaceButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        cancelRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        DispatchQueue.main.async {
            // Set up for camera view. Has to happen after constraints are set.
            let previewLayer = self.firstGateViewModel.previewLayer
            previewLayer.frame = self.cameraView.bounds
            self.cameraView.layer.addSublayer(previewLayer)
            self.cameraView.bringSubviewToFront(self.focusView)
            self.cameraView.bringSubviewToFront(self.onBoardFinishLine)
        }
    }
    
    /// Set text in top labels
    func setDisplayLabelText() {
        DispatchQueue.main.async {
            let countDown = "Count down: " + String(self.firstGateViewModel.userSelectedDelay)
            let distance = "Distance: " + String(self.firstGateViewModel.userSelectedLength)
            self.displayLabel1.setTitle(countDown, for: .normal)
            self.displayLabel2.setTitle(distance, for: .normal)
        }
    }
    
    /// Activates Count down When user taps to start run
    @objc func startCountDown() {
        firstGateViewModel.startCountDown()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.focusView.alpha = 0
            self.focusView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.startButton.alpha = 0
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (_) in
            self.cancelRaceButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.cancelRaceButton.alpha = 0.5
            self.countDownPickerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.countDownPickerView.alpha = 0.5
            UIView.animate(withDuration: 0.3) {
                self.cancelRaceButton.alpha = 1
                self.cancelRaceButton.transform = CGAffineTransform.identity
                self.countDownPickerView.alpha = 1
                self.countDownPickerView.transform = CGAffineTransform.identity
            }
        }
    }
    
    @objc private func cancelRun() {
        firstGateViewModel.cancelRun()
        animateCancel()
    }
    
    @objc private func switchCameraDirection() {
        firstGateViewModel.switchCamera()
    }
    
    private func animateCancel() {
        
        // Show start run button when run is cancelled.
        UIView.animate(withDuration: 0.3, animations: {
            self.cancelRaceButton.alpha = 0
            self.cancelRaceButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (_) in
            self.cancelRaceButton.alpha = 0
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.startButton.alpha = 0.5
            UIView.animate(withDuration: 0.3) {
                self.startButton.alpha = 1
                self.startButton.transform = CGAffineTransform.identity
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            }
        }
        
        // Hide count down label on cancel
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: {
                self.countDownPickerView.alpha = 0
            },
            completion: { _ in
                self.countDownPickerView.detail1.text = ""
                self.countDownPickerView.detail2.text = ""
            }
        )
    }
}

extension FirstGateViewController: FirstGateViewModelDelegate {

    func updateCountDownLabelText(firstCount: String, secondCount: String) {
        DispatchQueue.main.async {
            self.countDownPickerView.detail1.text = firstCount
            self.countDownPickerView.detail2.text = secondCount
        }
    }
    
    func updateTimeElapsed(firstMin: String, secondMin: String, firstSec: String, secondSec: String, firstHun: String, secondHun: String) {
       
        DispatchQueue.main.async {
            self.timerView.minsView.first.text = firstMin
            self.timerView.minsView.second.text = secondMin
            self.timerView.secsView.first.text = firstSec
            self.timerView.secsView.second.text = secondSec
            self.timerView.hundrethsView.first.text = firstHun
            self.timerView.hundrethsView.second.text = secondHun
        }
    }
    
    func resetUIOnRunEnd() {
        animateCancel()
    }
    
    func updateRunningAnimtion(color: CGColor, label: String) {
        DispatchQueue.main.async {
            self.pulsingLabel.text = label
            self.pulsingView.setColor(color: color)
        }
    }
    
    func removeCountDownLabel() {
        
        // Hide count down label when count down complete
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: {
                self.countDownPickerView.alpha = 0
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            },
            completion: { _ in
                self.countDownPickerView.detail1.text = ""
                self.countDownPickerView.detail2.text = ""
            }
        )
    }
    
    // Related to onboarding
    func showOnboardFinishLineOneUser() {
        DispatchQueue.main.async {
            self.onBoardFinishLine.isHidden = false
        }
    }
    
    func hasOnboardedFinishLineOneUser() {
        DispatchQueue.main.async {
            self.onBoardFinishLine.isHidden = true
        }
    }
    
    func showOnboardStartLineTwoUsers() {
        DispatchQueue.main.async {
            self.onBoardConnectedStart.isHidden = false
        }
    }
    
    func hasOnboardedStartLineTwoUsers() {
        DispatchQueue.main.async {
            self.onBoardConnectedStart.isHidden = true
        }
    }
    
    func showRunResult(runresult: RunResults) {
        DispatchQueue.main.async {
            let vc = ResultsViewController()
            vc.result = runresult
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true)
        }
    }
}

/// Related to onboarding the user
extension FirstGateViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        if sender.tag == 0 {
            firstGateViewModel.hasOnboardedFinishLineOneUser()
        }
        if sender.tag == 1 {
            firstGateViewModel.hasOnboardedStartLineTwoUsers()
        }
    }
}
