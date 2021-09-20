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
        view.backgroundColor = Constants.mainColor
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
        label.textColor = Constants.textColorMain
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar appearance
        title = "End Gate"
        self.navigationController?.navigationBar.backgroundColor = Constants.mainColor
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        // Delegates
        secondGateViewModel.secondGateViewModelDelegate = self
        
        // Set up for camera view
        let previewLayer = secondGateViewModel.previewLayer
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
        self.view.addSubview(focusView)
        focusView.addSubview(focusImageView)

        // Top View
        view.addSubview(displayView)
        //displayView.addSubview(pulsingView)
        displayView.addSubview(pulsingLabel)
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
        
        displayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        displayView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        displayView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        displayView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        pulsingView.leadingAnchor.constraint(equalTo: displayView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        pulsingView.centerYAnchor.constraint(equalTo: displayView.centerYAnchor).isActive = true
        pulsingView.widthAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        pulsingView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
        pulsingLabel.centerYAnchor.constraint(equalTo: pulsingView.centerYAnchor).isActive = true
        pulsingLabel.leadingAnchor.constraint(equalTo: pulsingView.trailingAnchor, constant: Constants.sideMargin / 2).isActive = true
        pulsingLabel.trailingAnchor.constraint(equalTo: displayView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        pulsingLabel.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        
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
    }
    
    deinit {
        print("DESTROYED SECOND GATE")
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
        self.secondGateViewModel.captureSession.stopRunning()
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
}
