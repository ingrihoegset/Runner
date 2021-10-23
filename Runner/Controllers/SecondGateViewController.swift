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
    
    let displayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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
        label.textColor = Constants.textColorDarkGray
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
        return view
    }()
    
    /// Views related to onboarding
    let onBoardPlace: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Place phone at finish line. Set pointer so the camera can see you run across the finish line!", pointerPlacement: "topMiddle")
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.tag = 0
        bubble.isHidden = true
        return bubble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar appearance
        navigationItem.title = "End gate"
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        self.navigationController?.navigationBar.backgroundColor = Constants.mainColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = Constants.accentColorDark
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(dismissSelf))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.rotate"),
                                                              style: .done,
                                                              target: self,
                                                              action: #selector(switchCameraDirection))
        
        // Delegates
        secondGateViewModel.secondGateViewModelDelegate = self
        onBoardPlace.onBoardingBubbleDelegate  = self
        
        // Set up for camera view
        let previewLayer = secondGateViewModel.previewLayer
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(focusView)
        focusView.addSubview(focusImageView)
        view.addSubview(onBoardPlace)

        // Top View
        view.addSubview(displayView)
        //displayView.addSubview(pulsingView)
        displayView.addSubview(pulsingLabelView)
        pulsingLabelView.addSubview(pulsingLabel)
        pulsingLabelView.addSubview(pulsingView)
        
        // Related to onboarding
        secondGateViewModel.showOnboardingFinishLine()
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
        self.secondGateViewModel.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Made height / 3 because for some reason the view didnt want to constrain to top of view, but only to safe area.
        displayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        displayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        displayView.heightAnchor.constraint(equalToConstant: Constants.headerSize / 3).isActive = true
        
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

        focusView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        focusView.widthAnchor.constraint(equalToConstant: width).isActive = true
        focusView.heightAnchor.constraint(equalToConstant: width).isActive = true
        focusView.layer.cornerRadius = width / 2
        
        focusImageView.centerYAnchor.constraint(equalTo: focusView.centerYAnchor).isActive = true
        focusImageView.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        focusImageView.widthAnchor.constraint(equalTo: focusView.widthAnchor).isActive = true
        focusImageView.heightAnchor.constraint(equalTo: focusView.heightAnchor).isActive = true
        
        onBoardPlace.topAnchor.constraint(equalTo: focusView.bottomAnchor).isActive = true
        onBoardPlace.centerXAnchor.constraint(equalTo: focusView.centerXAnchor).isActive = true
        onBoardPlace.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        onBoardPlace.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2.5).isActive = true
    }
    
    deinit {
        print("DESTROYED SECOND GATE")
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
        self.secondGateViewModel.captureSession.stopRunning()
    }
    
    @objc private func switchCameraDirection() {
        secondGateViewModel.switchCamera()
    }
}


extension SecondGateViewController: SecondGateViewModelDelegate {
    
    @objc func runHasEnded() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.secondGateViewModel.captureSession.stopRunning()
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
        }
    }
}

/// Related to onboarding the user
extension SecondGateViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        secondGateViewModel.hasOnboardedFinishLine()
    }
}

