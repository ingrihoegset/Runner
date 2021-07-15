//
//  SecondGateViewModel.swift
//  Runner
//
//  Created by Ingrid on 15/07/2021.
//

import Foundation
import AVFoundation

class SecondGateViewModel {
    
    let captureSession = AVCaptureSession()
    
    //In order to set up camera
    var cameraDevice: AVCaptureDevice?
    let previewLayer = AVCaptureVideoPreviewLayer()
    var stri: String?
    
    init() {
        cameraSetup()
    }
    
    
    private func sendEndTime(endTime: Double) {
        print("Attempting to send end time.")
        DatabaseManager.shared.sendEndTime(with: endTime, completion: { success in
            if success {
                print("Run updated with end time in database")
            }
            else {
                print("Failed to update run in database with end time")
            }
        })
    }
}




// MARK: - Functions related to Setting up and configuring camera.
extension SecondGateViewModel {
    
    // Sets up the camera for the second gate
    private func cameraSetup() {

           captureSession.sessionPreset = AVCaptureSession.Preset.high

           let videoDeviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)

           for camera in videoDeviceDiscovery.devices as [AVCaptureDevice] {
               if camera.position == .back {
                   cameraDevice = camera
               }
               if cameraDevice == nil {
                   print("Could not find back camera.")
               }
           }
           
           do {
               let videoDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
               if captureSession.canAddInput(videoDeviceInput) {
                   captureSession.addInput(videoDeviceInput)
               }
           } catch {
               print("Could not add camera as input: \(error)")
               return
           }
           
           //Configuration of camera device to a 30 fps camera
           configureDevice()

           previewLayer.session = captureSession
           previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
           if (previewLayer.connection?.isVideoOrientationSupported)! {
               previewLayer.connection?.videoOrientation = .portrait
           }
           
           //starts the camera
           captureSession.startRunning()
       }
    
    // Selects the function of the camera to be 30 fps
    private func configureDevice() {
         if let camera = cameraDevice {

             for vFormat in cameraDevice!.formats {
                 let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                 let frameRates = ranges[0]
                 if frameRates.maxFrameRate == 30 {
                     do {
                         try camera.lockForConfiguration()
                             camera.activeFormat = vFormat as AVCaptureDevice.Format
                             camera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                             camera.activeVideoMaxFrameDuration = frameRates.minFrameDuration
                             camera.unlockForConfiguration()
                     }
                     catch {
                        print("camera not found")
                    }
                 }
             }
         }
     }
}

