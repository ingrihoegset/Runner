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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        secondGateViewModel.secondGateViewModelDelegate = self
        
        // Set up for camera view
        let previewLayer = secondGateViewModel.previewLayer
        previewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.secondGateViewModel.captureSession.stopRunning()
    }
    
    
    deinit {
        print("DESTROYED SECOND GATE")
    }
}


extension SecondGateViewController: SecondGateViewModelDelegate {
    
    @objc func runHasEnded() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.secondGateViewModel.captureSession.stopRunning()
        }
    }
}
