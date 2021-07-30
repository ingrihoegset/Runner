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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.secondGateViewModel.captureSession.stopRunning()
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
}
