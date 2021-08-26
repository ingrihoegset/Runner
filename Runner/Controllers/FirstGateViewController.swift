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
    
    let displayLabel1: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColor
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.textAlignment = .center
        label.font = Constants.mainFontLargeSB
        label.clipsToBounds = true
        label.textColor = .white
        return label
    }()
    
    let displayLabel2: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColor
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.textAlignment = .center
        label.font = Constants.mainFontLargeSB
        label.clipsToBounds = true
        label.textColor = .white
        return label
    }()
      
    let pulsingView: PulsingAnimationView = {
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
        label.textColor = Constants.textColorMain
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
        view.image = UIImage(named: "Focus")
        if UserRunSelections.shared.getIsRunningWithOneGate() == true {
            view.isHidden = false
        }
        else {
            view.isHidden = true
        }
        return view
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColorDark
        button.setTitle("Start Count Down", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        button.setTitleColor(.white, for: .normal)
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
        return picker
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
            title = "End Gate"
        }
        else {
            title = "Start Gate"
        }
        
        // Subscribe to delegate
        firstGateViewModel.firstGateViewModelDelegate = self
        
        // Add top displays
        view.addSubview(displayView)
        displayView.addSubview(displayLabel1)
        displayView.addSubview(displayLabel2)
        displayView.addSubview(pulsingView)
        displayView.addSubview(pulsingLabel)
        view.addSubview(cameraView)
        cameraView.addSubview(focusView)
        focusView.addSubview(focusImageView)
        
        // Add other elements to view
        view.addSubview(startButton)
        view.addSubview(cancelRaceButton)
        view.addSubview(countDownPickerView)
        
        // Set tekst in top labels
        setDisplayLabelText()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.firstGateViewModel.captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        displayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        displayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        displayView.heightAnchor.constraint(equalToConstant: Constants.displayViewHeight).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        displayLabel1.trailingAnchor.constraint(equalTo: displayView.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        displayLabel1.leadingAnchor.constraint(equalTo: displayView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        displayLabel1.topAnchor.constraint(equalTo: displayView.topAnchor).isActive = true
        displayLabel1.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        displayLabel2.leadingAnchor.constraint(equalTo: displayView.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        displayLabel2.topAnchor.constraint(equalTo: displayView.topAnchor).isActive = true
        displayLabel2.trailingAnchor.constraint(equalTo: displayView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        displayLabel2.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true

        pulsingView.leadingAnchor.constraint(equalTo: displayLabel1.leadingAnchor).isActive = true
        pulsingView.topAnchor.constraint(equalTo: displayLabel1.bottomAnchor, constant: Constants.verticalSpacing / 2).isActive = true
        pulsingView.widthAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        pulsingView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        pulsingLabel.centerYAnchor.constraint(equalTo: pulsingView.centerYAnchor).isActive = true
        pulsingLabel.leadingAnchor.constraint(equalTo: pulsingView.trailingAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabel.trailingAnchor.constraint(equalTo: displayLabel2.trailingAnchor).isActive = true
        pulsingLabel.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        cameraView.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Must match size of focus frame in breakobserver
        let width = Constants.widthOfDisplay / 6

        focusView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor).isActive = true
        focusView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor).isActive = true
        focusView.widthAnchor.constraint(equalToConstant: width).isActive = true
        focusView.heightAnchor.constraint(equalToConstant: width).isActive = true
        focusView.layer.cornerRadius = width / 2
        
        focusImageView.centerYAnchor.constraint(equalTo: focusView.centerYAnchor).isActive = true
        focusImageView.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        focusImageView.widthAnchor.constraint(equalTo: focusView.widthAnchor).isActive = true
        focusImageView.heightAnchor.constraint(equalTo: focusView.heightAnchor).isActive = true
        
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        startButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
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
        }
    }
    
    /// Set text in top labels
    func setDisplayLabelText() {
        DispatchQueue.main.async {
            let countDown = "Count Down: " + String(self.firstGateViewModel.userSelectedDelay)
            let distance = "Distance: " + String(self.firstGateViewModel.userSelectedLength)
            self.displayLabel1.text = countDown
            self.displayLabel2.text = distance
        }
    }
    
    /// Activates Count down When user taps to start run
    @objc func startCountDown() {
        firstGateViewModel.startCountDown(countDownTime: self.firstGateViewModel.userSelectedDelay)
        
        // Show cancel button and countdown label when start is clicked
        UIView.animate(withDuration: 0.5, animations: {
            self.focusView.alpha = 0
            self.focusView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.startButton.alpha = 0
            self.startButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (_) in
            self.cancelRaceButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.cancelRaceButton.alpha = 0
            self.countDownPickerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.countDownPickerView.alpha = 0
            UIView.animate(withDuration: 0.5) {
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
    
    
    private func animateCancel() {
        
        // Show start run button when run is cancelled.
        UIView.animate(withDuration: 0.5, animations: {
            self.cancelRaceButton.alpha = 0
            self.cancelRaceButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }) { (_) in
            self.cancelRaceButton.alpha = 0
            self.startButton.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.startButton.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.startButton.alpha = 1
                self.startButton.transform = CGAffineTransform.identity
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            }
        }
        
        // Hide count down label on cancel
        UIView.animate(
            withDuration: 0.5,
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
            withDuration: 0.5,
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
}
