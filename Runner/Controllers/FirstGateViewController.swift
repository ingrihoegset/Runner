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
        label.font = Constants.mainFontLarge
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
        label.font = Constants.mainFontLarge
        label.clipsToBounds = true
        label.textColor = .white
        return label
    }()
    
    let cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        return button
     }()
    
    let countDownLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.whiteColor
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = false
        label.font = Constants.countDownFont
        label.layer.cornerRadius = Constants.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()
    
    let cancelRaceButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.alpha = 0
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(cancelRun), for: .touchUpInside)
        return button
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
        view.addSubview(cameraView)
        
        // Add other elements to view
        view.addSubview(startButton)
        view.addSubview(countDownLabel)
        view.addSubview(cancelRaceButton)
        
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
        displayView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.125).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        displayLabel1.trailingAnchor.constraint(equalTo: displayView.centerXAnchor, constant: -Constants.sideMargin / 2).isActive = true
        displayLabel1.widthAnchor.constraint(equalTo: displayView.widthAnchor, multiplier: 0.4).isActive = true
        displayLabel1.centerYAnchor.constraint(equalTo: displayView.centerYAnchor).isActive = true
        displayLabel1.heightAnchor.constraint(equalTo: displayView.heightAnchor, multiplier: 0.65).isActive = true
        
        displayLabel2.leadingAnchor.constraint(equalTo: displayView.centerXAnchor, constant: Constants.sideMargin / 2).isActive = true
        displayLabel2.centerYAnchor.constraint(equalTo: displayView.centerYAnchor).isActive = true
        displayLabel2.widthAnchor.constraint(equalTo: displayView.widthAnchor, multiplier: 0.4).isActive = true
        displayLabel2.heightAnchor.constraint(equalTo: displayView.heightAnchor, multiplier: 0.65).isActive = true
        
        cameraView.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        startButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        countDownLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        countDownLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -Constants.sideMargin).isActive = true
        countDownLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
        countDownLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75).isActive = true
        
        cancelRaceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        cancelRaceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancelRaceButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.235/2).isActive = true
        cancelRaceButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        DispatchQueue.main.async {
            // Set up for camera view. Has to happen after constraints are set.
            let previewLayer = self.firstGateViewModel.previewLayer
            previewLayer.frame = self.cameraView.bounds
            self.cameraView.layer.addSublayer(previewLayer)
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
        
        // Start showin count down label
        countDownLabel.alpha = 1
        countDownLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
        if let color = Constants.accentColor {
            countDownLabel.backgroundColor = color.withAlphaComponent(0.5)
        }
        else {
            countDownLabel.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.5)
        }

        
        // Show cancel button when start is clicked
        UIView.animate(withDuration: 0.5, animations: {
            self.startButton.alpha = 0
            self.startButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { (_) in
            self.cancelRaceButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.cancelRaceButton.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.cancelRaceButton.alpha = 1
                self.cancelRaceButton.transform = CGAffineTransform.identity
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
            }
        }
        
        // Hide count down label on cancel
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: {
                self.countDownLabel.alpha = 0
                
            },
            completion: { _ in
                self.countDownLabel.text = ""
            }
        )
        
    }
}

extension FirstGateViewController: FirstGateViewModelDelegate {
    
    func updateCountDownLabelText(count: String) {
        DispatchQueue.main.async {
            self.countDownLabel.text = count
        }
    }
    
    func resetUIOnRunEnd() {
        animateCancel()
    }
}
