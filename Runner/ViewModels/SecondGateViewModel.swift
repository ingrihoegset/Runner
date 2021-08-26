//
//  SecondGateViewModel.swift
//  Runner
//
//  Created by Ingrid on 15/07/2021.
//

import Foundation
import AVFoundation
import UIKit

protocol SecondGateViewModelDelegate: AnyObject {
    func runHasEnded()
    func updateRunningAnimtion(color: CGColor, label: String)
}

class SecondGateViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    weak var secondGateViewModelDelegate: SecondGateViewModelDelegate?
    
    // In order to set up camera
    let captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Breakobserver that helps us detect whether or not break has occured.
    let breakObserver = BreakObserver()
    var breakTime: Double = 0
    var counter = 0
    
    override init() {
        super.init()
        cameraSetup()
        currentRunOngoing()
    }
    
    func getVideoOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        
        let videoOutputQueue = DispatchQueue(label: "VideoQueue")
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Could not add video data as output.")
        }
    }
    
    /// FIs called each time new frame is recieved from the camera.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        counter = counter + 1
        
        breakTime = Date().currentTimeMillis()
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!

        print(breakObserver.recentFramesArray)
        
        //Dont know what this does, but dont move
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        print(Constants.isRunning)
        // Will only check for breaks after the run has begun. Is running is set to true after the database has received a start time.
        if Constants.isRunning == true {
            // Gives the camera time to stabilize before evaluating.
            if counter >= 15 {
                let broken = breakObserver.checkIfBreakHasOccured(cvPixelBuffer: pixelBuffer!)
                if (broken == true) {
                    print("Break has been detected.")
                    sendTime(time: breakTime, endTime: true)
                    breakObserver.recentFramesArray = []
                    self.secondGateViewModelDelegate?.runHasEnded()
                    counter = 0
                }
            }
        }
    }
    
    
    private func sendTime(time: Double, endTime: Bool) {
        print("Attempting to send end time.")
        DatabaseManager.shared.sendTime(time: time, endTime: endTime, completion: { success in
            if success {

                
            }
            else {
                
            }
        })
    }
    
    /// Checks if race ongoing, updates UI on true / false
    private func currentRunOngoing() {
        DatabaseManager.shared.currentRunOngoing(completion: { [weak self] success in
            guard let strongSelf = self else {
                return
            }
            if success {
                print("ongoing")
                strongSelf.secondGateViewModelDelegate?.updateRunningAnimtion(color: Constants.accentColor!.cgColor, label: "Run ongoing")
            }
            else {
                print("waiting")
                strongSelf.secondGateViewModelDelegate?.updateRunningAnimtion(color: Constants.contrastColor!.cgColor, label: "Waiting for run to start")
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
        
        // Configuration of camera device to a 30 fps camera
        configureDevice()
        
        // Set spesifications for preview layer
        previewLayer.session = captureSession
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        if (previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = .portrait
        }
        
        // Starts the camera
        captureSession.startRunning()
        
        // Starts recieving frames
        getVideoOutput()
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

