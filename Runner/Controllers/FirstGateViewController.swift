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
    
    /// Other
    var showslider = false
    
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
        button.setTitleColor(Constants.textColorAccent, for: .normal)
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
        button.setTitleColor(Constants.textColorAccent, for: .normal)
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
        label.textColor = Constants.textColorAccent
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
        view.isHidden = true
        return view
    }()
    
    let focusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.image = UIImage(named: "Focus")?.withTintColor(Constants.contrastColor!)
        view.isUserInteractionEnabled = true
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
        picker.detail1.textColor = Constants.accentColorDarkest
        picker.detail2.textColor = Constants.accentColorDarkest
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
        let bubble = OnBoardingBubble(frame: .zero, title: "Place phone at your finish line and start count down. Make sure you have enough time to get into position!", pointerPlacement: "topMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 0
        bubble.isHidden = true
        return bubble
    }()
    
    let onBoardConnectedStart: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Place your phone at starting line and listen for starting signal!", pointerPlacement: "bottomMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 1
        bubble.isHidden = true
        return bubble
    }()
    
    let noConnectionView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    let onboardSensitivitySlider: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Click me to adjust sensitivity of sensor", pointerPlacement: "topMiddle", dismisser: false)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 2
        bubble.isHidden = true
        return bubble
    }()
    
    let sensitivitySliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Sensor sensitivity"
        label.textColor = Constants.textColorAccent
        label.font = Constants.mainFontSB
        label.textAlignment = .center
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = Constants.contrastColor
        slider.minimumTrackTintColor = Constants.contrastColor
        slider.maximumValue = 1
        slider.minimumValue = 0
        slider.isContinuous = false
        // Must convert value to match 0 to 1 scale (from 0.4 to 0.025 scale for actual camera sensitivity)
        let value = (UserDefaults.standard.value(forKey: Constants.cameraSensitivity) as? CGFloat)!
        let visualValue = (Constants.minSensitivity - value) / (Constants.minSensitivity - Constants.maxSensitivity)
        slider.setValue(Float(visualValue), animated: false)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(slider)
        slider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        slider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
        slider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        
        let plusImage = UIImage(systemName: "plus.circle.fill")?.withTintColor(Constants.textColorAccent!, renderingMode: .alwaysOriginal)
        let plusImageView = UIImageView()
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.image = plusImage
        
        view.addSubview(plusImageView)
        plusImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        plusImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        plusImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        
        let minusImage = UIImage(systemName: "minus.circle.fill")?.withTintColor(Constants.textColorAccent!, renderingMode: .alwaysOriginal)
        let minusImageView = UIImageView()
        minusImageView.translatesAutoresizingMaskIntoConstraints = false
        minusImageView.image = minusImage
        
        view.addSubview(minusImageView)
        minusImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        minusImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        minusImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        minusImageView.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        
        let pointerView = UIView()
        pointerView.backgroundColor = view.backgroundColor
        pointerView.translatesAutoresizingMaskIntoConstraints = false
        pointerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        
        view.addSubview(pointerView)
        pointerView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        pointerView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        pointerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pointerView.centerYAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        view.sendSubviewToBack(pointerView)
        
        view.isHidden = true
        return view
    }()

    deinit {
        print("DESTROYED \(self)")
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
            
            activateSwitchCameraButton()
        }
        else {
            title = "Start gate"
        }
        
        // Subscribe to delegates
        firstGateViewModel.firstGateViewModelDelegate = self
        onBoardFinishLine.onBoardingBubbleDelegate = self
        onBoardConnectedStart.onBoardingBubbleDelegate = self
        onboardSensitivitySlider.onBoardingBubbleDelegate = self
        
        // Add top displays
        view.addSubview(displayView)
        displayView.addSubview(displayLabel1)
        displayView.addSubview(displayLabel2)
        view.addSubview(cameraView)

        cameraView.addSubview(focusView)
        focusView.addSubview(focusImageView)
        cameraView.addSubview(onBoardFinishLine)
        cameraView.addSubview(sensitivitySliderView)
        
        // Add other elements to view
        view.addSubview(pulsingLabelView)
        pulsingLabelView.addSubview(pulsingLabel)
        pulsingLabelView.addSubview(pulsingView)
        view.addSubview(startButton)
        view.addSubview(onboardSensitivitySlider)
        view.addSubview(onBoardConnectedStart)
        view.addSubview(cancelRaceButton)
        view.addSubview(countDownPickerView)
        view.addSubview(timerView)
        
        // Set tekst in top labels
        setDisplayLabelText()
        
        // Related to onboarding
        firstGateViewModel.showOnboardingFinishLineOneUser()
        firstGateViewModel.showOnboardingStartLineTwoUsers()
        
        // Set up camera
        firstGateViewModel.setUpCamera()
        
        // Related to internet connection
        view.addSubview(noConnectionView)
        
        NetworkManager.isUnreachable { _ in
            self.showNoConnection()
        }
        NetworkManager.isReachable { _ in
            self.showConnection()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showConnection),
            name: NSNotification.Name(Constants.networkIsReachable),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showNoConnection),
            name: NSNotification.Name(Constants.networkIsNotReachable),
            object: nil
        )
        
        // Add tap for sensor slider
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeSliderVisibility))
        focusImageView.addGestureRecognizer(gesture)
        
        setConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.firstGateViewModel.captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.firstGateViewModel.captureSession.startRunning()
        pulsingView.addAnimations()
        
        // Make sure screen doesnt close when camera is on. This is necessary so that the camera is active and analyzing during thee whole run
        if UserRunSelections.shared.getIsRunningWithOneGate() == true {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("View is disappearing")

        if self.isMovingFromParent {
            
            print("is moving from parent")
            // Cancel current run if gate is exited
            cancelRun()
            // Removes listeners so that http calls arent duplicated
            firstGateViewModel.removeEndOfRunListener()
            firstGateViewModel.removeCurrentRunOngoingListener()
        }
        
        // Make sure screen locking goes back into action, in order to not use too much battery power
        UIApplication.shared.isIdleTimerDisabled = false
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
        
        onboardSensitivitySlider.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 10).isActive = true
        onboardSensitivitySlider.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        onboardSensitivitySlider.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.5).isActive = true
        onboardSensitivitySlider.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        
        onBoardFinishLine.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 10).isActive = true
        onBoardFinishLine.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        onBoardFinishLine.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.8).isActive = true
        onBoardFinishLine.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        
        sensitivitySliderView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.75).isActive = true
        sensitivitySliderView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        sensitivitySliderView.widthAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 0.7).isActive = true
        sensitivitySliderView.bottomAnchor.constraint(equalTo: focusView.topAnchor, constant: -15).isActive = true
        
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
        onBoardConnectedStart.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -5).isActive = true
        
        countDownPickerView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        countDownPickerView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor, constant: -Constants.sideMargin).isActive = true
        countDownPickerView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.6).isActive = true
        countDownPickerView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - 2 * Constants.sideMargin).isActive = true
        
        cancelRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        cancelRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelRaceButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        cancelRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        noConnectionView.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        noConnectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noConnectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noConnectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        DispatchQueue.main.async {
            // Set up for camera view. Has to happen after constraints are set.
            let previewLayer = self.firstGateViewModel.previewLayer
            previewLayer.frame = self.cameraView.bounds
            self.cameraView.layer.addSublayer(previewLayer)
            self.cameraView.bringSubviewToFront(self.focusView)
            self.cameraView.bringSubviewToFront(self.onBoardFinishLine)
            self.cameraView.bringSubviewToFront(self.onboardSensitivitySlider)
            self.cameraView.bringSubviewToFront(self.sensitivitySliderView)
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
    // Checks if camera access has been granted first - if not should present sheet to set up camera access.
    @objc func startCountDown() {
        
        // Check if there is a camera running
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
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
        default:
            firstGateViewModel.goToCamera()
        }
        
        // Hide sensor if showing
        showslider = false
        sensitivitySliderView.isHidden = true
        
        // Onboard Finish line
        firstGateViewModel.hasOnboardedFinishLineOneUser()
        
        // Onboard Start line if connected.
        if onBoardConnectedStart.isHidden == false {
            firstGateViewModel.hasOnboardedStartLineTwoUsers()
        }
        
        // Increase counter to onboard sensitivity slider. Will show after 3 time user has started a run
        firstGateViewModel.addCountToSenitivitySliderCount()
        
        // Hide sensitivity onboarding if showing
        onboardSensitivitySlider.isHidden = true
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
        DispatchQueue.main.async {
            self.animateCancel()
        }
    }
    
    func updateRunningAnimtion(color: CGColor, label: String) {
        DispatchQueue.main.async {
            self.pulsingLabel.text = label
            self.pulsingView.setColor(color: color)
        }
    }
    
    func showFocusView() {
        focusView.isHidden = false
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
            self.onBoardFinishLine.animateOnboardingBubble()
        }
    }
    
    func showOnboardSensitivitySlider() {
        DispatchQueue.main.async {
            self.onboardSensitivitySlider.isHidden = false
        }
    }
    
    func hasOnboardedSensitivitySlider() {
        DispatchQueue.main.async {
            self.onboardSensitivitySlider.isHidden = true
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
            self.onBoardConnectedStart.animateOnboardingBubble()
        }
    }
    
    func hasOnboardedStartLineTwoUsers() {
        DispatchQueue.main.async {
            self.onBoardConnectedStart.isHidden = true
        }
    }
    
    func showRunResult(runresult: RunResults, photoFinishImage: UIImage?) {
        DispatchQueue.main.async {
            let vc = ResultsViewController()
            vc.result = runresult
            vc.photoFinishImage = photoFinishImage
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true)
        }
    }
    
    @objc func changeSliderVisibility() {
        if showslider == false {
            firstGateViewModel.hasOnboardedSensitivitySlider()
            sensitivitySliderView.isHidden = false
            showslider = true
        }
        else {
            showslider = false
            sensitivitySliderView.isHidden = true
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let currentValue = Constants.minSensitivity - CGFloat(sender.value) * (Constants.minSensitivity - Constants.maxSensitivity)
        UserDefaults.standard.setValue(CGFloat(currentValue), forKey: Constants.cameraSensitivity)
        // Tell breakobserver to update camera sensitivity
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Constants.cameraSensitivity), object: nil)
        sensitivitySliderView.isHidden = true
        showslider = false
    }
    
    // Related to checking camera access
    func cameraRestricted() {
        let alert = UIAlertController(title: "Restricted",
                                      message: "You've been restricted from using the camera on this device. Without camera access this app won't work. Please contact the device owner so they can give you access.",
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraDenied() {
        DispatchQueue.main.async {
                var alertText = "It looks like your privacy settings are preventing us from accessing your camera. This app needs to access your camera to track your run. You can fix this error by doing the following steps:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the camera on.\n\n5. Open this app and try again."

                var alertButton = "OK"
                var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)

                if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
                {
                    alertText = "It looks like your privacy settings are preventing us from accessing your camera. This app needs to access the camera to work. You can fix this error by doing the following steps:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."

                    alertButton = "Go"

                    goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                }
                let alert = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
                alert.addAction(goAction)
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func activateSwitchCameraButton() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .notDetermined:
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .restricted:
            navigationItem.rightBarButtonItem?.isEnabled = false
        case .denied:
            navigationItem.rightBarButtonItem?.isEnabled = false
        @unknown default:
            navigationItem.rightBarButtonItem?.isEnabled = false
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
        if sender.tag == 2 {
            firstGateViewModel.hasOnboardedSensitivitySlider()
        }
    }
}

/// Related to internet connection
extension FirstGateViewController {
    @objc func showConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 0
        })
    }
    
    @objc func showNoConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 1
        })
    }
}
