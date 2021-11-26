//
//  SecondGateViewController.swift
//  Runner
//
//  Created by Ingrid on 15/07/2021.
//

import UIKit
import JGProgressHUD
import AVFoundation


class SecondGateViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let secondGateViewModel = SecondGateViewModel()
    
    /// Other
    var showslider = false
    
    /// Views
    let displayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let pulsingLabelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    lazy var pulsingView: PulsingAnimationView = {
        let view = PulsingAnimationView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let pulsingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "Waiting for run to start"
        label.font = Constants.mainFontLargeSB
        label.clipsToBounds = true
        label.textColor = Constants.textColorAccent
        return label
    }()
    
    // Represents part of view that is analyze in breakobserver
    let focusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor?.withAlphaComponent(0.3)
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = Constants.contrastColor?.cgColor
        return view
    }()
    
    let focusImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.image = UIImage(named: "Focus")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    /// Views related to onboarding
    let onBoardPlace: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Place phone at finish line. Set pointer so the camera can see you run across the finish line!", pointerPlacement: "topMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 0
        bubble.isHidden = true
        return bubble
    }()
    
    let onboardSensitivitySlider: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Click me to adjust sensitivity of sensor", pointerPlacement: "topMiddle", dismisser: false)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 1
        bubble.isHidden = true
        return bubble
    }()
    
    /// View related to internet connection
    // Is shown when there is no internet connection
    let noConnectionView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    /// Lets user decide how sensitiv the sensor should be
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar appearance
        navigationItem.title = "End gate"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        view.backgroundColor = Constants.mainColor

        self.navigationController?.navigationBar.tintColor = Constants.accentColorDark
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.rotate"),
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(switchCameraDirection))
        activateSwitchCameraButton()
        
        // Delegates
        secondGateViewModel.secondGateViewModelDelegate = self
        onBoardPlace.onBoardingBubbleDelegate  = self
        onboardSensitivitySlider.onBoardingBubbleDelegate = self
        
        // Set up for camera view
        let previewLayer = secondGateViewModel.previewLayer
        previewLayer.frame = self.view.safeAreaLayoutGuide.layoutFrame
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(focusView)
        focusView.addSubview(focusImageView)
        view.addSubview(onBoardPlace)
        view.addSubview(sensitivitySliderView)
        view.addSubview(onboardSensitivitySlider)

        // Top View
        view.addSubview(displayView)
        //displayView.addSubview(pulsingView)
        displayView.addSubview(pulsingLabelView)
        pulsingLabelView.addSubview(pulsingLabel)
        pulsingLabelView.addSubview(pulsingView)
        
        // Related to onboarding
        secondGateViewModel.showOnboardingFinishLine()
        
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.secondGateViewModel.captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        displayView.addSubview(pulsingView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.checkCamera()
        //self.secondGateViewModel.goToCamera()
        
        // Make sure screen doesnt lock while run is ongoing. Camera needs to be available during complete run
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Onboard sensitivity slider if hasent been onboarded yet
        secondGateViewModel.showOnboardSensitivitySlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            // Removes listeners so that http calls arent duplicated
            secondGateViewModel.removeEndOfRunListener()
            secondGateViewModel.removeCurrentRunOngoingListener()
        }
        
        // Allow screen to lock again - in order to limit battery impact
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        displayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        displayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        pulsingLabelView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        pulsingLabelView.trailingAnchor.constraint(equalTo: displayView.trailingAnchor, constant:  -Constants.sideMargin).isActive = true
        pulsingLabelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabelView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true

        pulsingView.leadingAnchor.constraint(equalTo: pulsingLabelView.leadingAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingView.centerYAnchor.constraint(equalTo: pulsingLabelView.centerYAnchor).isActive = true
        pulsingView.widthAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        pulsingView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        pulsingLabel.centerYAnchor.constraint(equalTo: pulsingView.centerYAnchor).isActive = true
        pulsingLabel.leadingAnchor.constraint(equalTo: pulsingView.trailingAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabel.trailingAnchor.constraint(equalTo: pulsingLabelView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        pulsingLabel.heightAnchor.constraint(equalTo: pulsingLabelView.heightAnchor).isActive = true
        
        // Must match size of focus frame in breakobserver
        let width = Constants.widthOfDisplay / 6

        focusView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        focusView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        focusView.widthAnchor.constraint(equalToConstant: width).isActive = true
        focusView.heightAnchor.constraint(equalToConstant: width).isActive = true
        focusView.layer.cornerRadius = width / 2
        
        focusImageView.centerYAnchor.constraint(equalTo: focusView.centerYAnchor).isActive = true
        focusImageView.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        focusImageView.widthAnchor.constraint(equalTo: focusView.widthAnchor).isActive = true
        focusImageView.heightAnchor.constraint(equalTo: focusView.heightAnchor).isActive = true
        
        sensitivitySliderView.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.75).isActive = true
        sensitivitySliderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sensitivitySliderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        sensitivitySliderView.bottomAnchor.constraint(equalTo: focusView.topAnchor, constant: -15).isActive = true
        
        onboardSensitivitySlider.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 10).isActive = true
        onboardSensitivitySlider.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        onboardSensitivitySlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        onboardSensitivitySlider.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        
        onBoardPlace.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 10).isActive = true
        onBoardPlace.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        onBoardPlace.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        onBoardPlace.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2.5).isActive = true
        
        noConnectionView.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        noConnectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noConnectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noConnectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    deinit {
        print("DESTROYED \(self)")
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
        self.secondGateViewModel.captureSession.stopRunning()
    }
    
    @objc private func switchCameraDirection() {
        secondGateViewModel.switchCamera()
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
    
    @objc func changeSliderVisibility() {
        if showslider == false {
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
        
        // Has onboarded sensitivity slider
        secondGateViewModel.hasOnboardedSensitivitySlider()
        
        // Hide slider after value changed
        sensitivitySliderView.isHidden = true
        showslider = false
    }
}


extension SecondGateViewController: SecondGateViewModelDelegate {
    
    @objc func runHasEnded() {
        DispatchQueue.main.async {
            self.secondGateViewModel.captureSession.stopRunning()
        }
    }
    
    func showRunResult(runresult: RunResults, photoFinishImage: UIImage) {
        DispatchQueue.main.async {
            let vc = ResultsViewController()
            vc.result = runresult
            vc.photoFinishImage = photoFinishImage
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: {
                self.secondGateViewModel.captureSession.startRunning()
            })
        }
    }
    
    // Remove results VC when new run is started
    func dismissResultsVC() {
        DispatchQueue.main.async {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateRunningAnimtion(color: CGColor, label: String) {
        DispatchQueue.main.async {
            self.pulsingLabel.text = label
            self.pulsingView.setColor(color: color)
        }
    }
    
    /// Related to onboarding the user
    func hasOnboardedFinsihLine() {
        DispatchQueue.main.async {
            self.onBoardPlace.isHidden = true
        }
    }
    
    func showOnboardingFinishLine() {
        DispatchQueue.main.async {
            self.onBoardPlace.isHidden = false
            self.onBoardPlace.animateOnboardingBubble()
        }
    }
    
    func showOnboardingSensitivitySlider() {
        DispatchQueue.main.async {
            self.onboardSensitivitySlider.isHidden = false
            self.onboardSensitivitySlider.animateOnboardingBubble()
        }
    }
    
    //Makes sure that user has given access to camera before setting up a camerasession
    func checkCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            print("Authorized")
        case .notDetermined:
            print("not determinded")
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if (granted)
                {
                }
                else
                {
                    self.cameraDenied()
                }
            }
        case .denied:
            print("Denied")
            self.cameraDenied()
        case .restricted:
            print("Restricted")
            self.cameraRestricted()
        }
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
}

/// Related to onboarding the user
extension SecondGateViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        if sender.tag == 0 {
            secondGateViewModel.hasOnboardedFinishLine()
        }
        if sender.tag == 1 {
            secondGateViewModel.hasOnboardedSensitivitySlider()
        }
    }
}

/// Related to internet connection
extension SecondGateViewController {
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

