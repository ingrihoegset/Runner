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
    func hasOnboardedFinsihLine()
    func showOnboardingFinishLine()
    func showOnboardingSensitivitySlider()
    func showRunResult(runresult: RunResults, photoFinishImage: UIImage)
    func dismissResultsVC()
    func cameraRestricted()
    func cameraDenied()
}

class SecondGateViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate  {
    
    weak var secondGateViewModelDelegate: SecondGateViewModelDelegate?
    let runHelper = RunHelper.sharedInstance
    
    // In order to set up camera
    let captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Breakobserver that helps us detect whether or not break has occured.
    let breakObserver = BreakObserver()
    var breakTime: Double = 0
    var counter = 0
    var isRunning = false
    
    //Photo finish image
    var photoFinishImage = UIImage()
    
    override init() {
        super.init()
        // Check if camera access is given, set up camera if access OK, otherwise, prompt user for access.
        goToCamera()
        currentRunOngoing()
        listenForEndOfCurrentRun()
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
        
        //Dont know what this does, but dont move
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)

        // Will only check for breaks after the run has begun. Is running is set to true after the database has received a start time.
        if isRunning == true {
            // Gives the camera time to stabilize before evaluating.
            if counter >= 15 {
                let broken = breakObserver.checkIfBreakHasOccured(cvPixelBuffer: pixelBuffer!)
                if (broken == true) {
                    print("Break has been detected.")
                    sendTime(time: breakTime, endTime: true)
                    breakObserver.recentFramesArray = []
                    //self.secondGateViewModelDelegate?.runHasEnded()
                    counter = 0
                    
                    // Get photofinish image
                    getPhotoFinish(pixelBuffer: pixelBuffer!)
                }
            }
        }
    }
    
    private func getPhotoFinish(pixelBuffer: CVImageBuffer) {
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        
        print(UIDevice.current.orientation.isPortrait)
        photoFinishImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
    }
    
    private func listenForEndOfCurrentRun() {
        DatabaseManager.shared.listenForEndOfCurrentRun(completion: { [weak self] success in
            if success {
                print("listened for end")
                DatabaseManager.shared.getCurrentRunData(completion: { [weak self] result in
                    switch result {
                        case .success(let runData):
                            guard let strongSelf = self else {
                                return
                            }
                            // Convert times to total time
                            let runResult = strongSelf.runHelper.getCurrentResult(run: runData)
                            
                            // Calls on home VC to open results VC
                            strongSelf.secondGateViewModelDelegate?.showRunResult(runresult: runResult, photoFinishImage: strongSelf.photoFinishImage)
                            
                            // Clean up after completed run
                            DatabaseManager.shared.cleanUpAfterRunCompleted(completion: { _ in
                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reset"), object: nil)
                            })
                                
                        case .failure(let error):
                            print(error)
                            // Should show error to user!!!
                            // Clean up after completed run regardless of success or not
                            DatabaseManager.shared.cleanUpAfterRunCompleted(completion: { _ in
                                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reset"), object: nil)
                            })
                    }
                })
            }
            else {

            }
        })
    }
    
    func removeEndOfRunListener() {
        DatabaseManager.shared.removeEndOfRunListener()
    }
    
    func removeCurrentRunOngoingListener() {
        DatabaseManager.shared.removeCurrentRunOngoingListener()
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
                strongSelf.secondGateViewModelDelegate?.updateRunningAnimtion(color: Constants.accentColorDark!.cgColor, label: "Run ongoing")
                strongSelf.secondGateViewModelDelegate?.dismissResultsVC()
                
                // Start camera analysis if appropriate
                strongSelf.startBreakAnalysis()
            }
            else {
                strongSelf.secondGateViewModelDelegate?.updateRunningAnimtion(color: Constants.textColorAccent!.cgColor, label: "Waiting for run to start")
                
                // Stop camera analysis
                strongSelf.stopBreakAnalysis()
            }
        })
    }
    
    func startBreakAnalysis() {
        isRunning = true
    }
    
    func stopBreakAnalysis() {
        isRunning = false
    }
    
    /// Related to onboarding
    func hasOnboardedFinishLine() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedFinishLineTwoUsers)
        secondGateViewModelDelegate?.hasOnboardedFinsihLine()
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardingFinishLine() {
        let onboardConnect = UserDefaults.standard.bool(forKey: Constants.hasOnboardedFinishLineTwoUsers)
        if onboardConnect == false {
            secondGateViewModelDelegate?.showOnboardingFinishLine()
        }
    }
    
    func hasOnboardedSensitivitySlider() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedSensitivitySlider)
    }
    
    func showOnboardSensitivitySlider() {
        let sliderOnboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedSensitivitySlider)
        let finishLineOnboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedFinishLineTwoUsers)
        print(sliderOnboarded, finishLineOnboarded)
        if sliderOnboarded == false && finishLineOnboarded == true {
            secondGateViewModelDelegate?.showOnboardingSensitivitySlider()
        }
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
    
    // Switches camera between front and back
    func switchCamera() {
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        captureSession.removeInput(currentInput!)
        let newCameraDevice = currentInput?.device.position == .back ? getCamera(with: .front) : getCamera(with: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        captureSession.addInput(newVideoInput!)
        captureSession.commitConfiguration()
    }
    
    private func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] else {
            return nil
        }
        
        return devices.filter {
            $0.position == position
            }.first
    }
}


/// Related to checking access to camera
extension SecondGateViewModel {
    
    //Makes sure that user has given access to camera before setting up a camerasession
    func goToCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            print("Authorized")
            self.cameraSetup()

        case .notDetermined:
            print("not determinded")
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if (granted)
                {
                    self.cameraSetup()
                }
                else
                {
                    self.secondGateViewModelDelegate?.cameraDenied()
                }
            }

        case .denied:
            print("Denied")
            self.secondGateViewModelDelegate?.cameraDenied()

        case .restricted:
            print("Restricted")
            self.secondGateViewModelDelegate?.cameraRestricted()
        }
    }
}


