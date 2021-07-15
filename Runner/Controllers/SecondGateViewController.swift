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
        
        let previewLayer = secondGateViewModel.previewLayer
        previewLayer.frame = self.view.bounds
        print(previewLayer)

        self.view.layer.addSublayer(previewLayer)
        

        

    }
    

    

}
