//
//  StartGateViewModel.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import Foundation
import AVFoundation
import UIKit

protocol FirstGateViewModelDelegate: AnyObject {
    func updateCountDownLabelText(count: String)
    func resetUIOnRunEnd()
    func updateRunningAnimtion(color: CGColor, label: String)
    func removeCountDownLabel()
}

class FirstGateViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var firstGateViewModelDelegate: FirstGateViewModelDelegate?
    
    // In order to set up camera
    let captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Breakobserver that helps us detect whether or not break has occured.
    let breakObserver = BreakObserver()
    var breakTime: Double = 0
    var videoCounter = 0
    
    public static let dateFormatterShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = .none
        return formatter
    }()
    
    // Objects that are selected by user for transmittion to database
    var userSelectedLength = 60
    var userSelectedType = "Sprint"
    var userSelectedDelay = 3
    
    // Objects related to countdown
    var timer = Timer()
    var audioPlayer: AVAudioPlayer?
    var counter = 3
        
    override init() {
        super.init()
        // Listens for canceled or completed run so that UI is reset for user
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: NSNotification.Name(rawValue: "reset"), object: nil)
        
        currentRunOngoing()
        
        // Starts Camera if User has selected to run with one gate only
        let isRunningWithOneGate = UserRunSelections.shared.getIsRunningWithOneGate()
        if isRunningWithOneGate == true {
            cameraSetup()
        }
        
        let userSelections = UserRunSelections.shared
        userSelectedLength = userSelections.getUserSelectedLength()
        userSelectedType = userSelections.getUserSelectedType()
        userSelectedDelay = userSelections.getUserSelectedDelay()
    }
    
    // Resets UI from cancel to start run when runs is completed
    @objc func reset() {
        firstGateViewModelDelegate?.resetUIOnRunEnd()
    }
    
    // Creates timer object and tells the timer which function to preform for every time interval.
    @objc func startCountDown(countDownTime: Int) {
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        counter = countDownTime
    }
    
    //Is trigger for every timer interval (1 second)
    @objc func countDown() {
        
        //Updates count down label in start VC
        let count = String(counter)
        firstGateViewModelDelegate?.updateCountDownLabelText(count: count)

        if (counter % 10 == 0 && counter > 0) {
            playSound(filename: "shortBeep")
            counter = counter - 1
        }
        else if (counter > 3) {
            counter = counter - 1
        }
        else if (counter <= 3 && counter > 0) {
            playSound(filename: "shortBeep")
            counter = counter - 1
        }
        else {
            playSound(filename: "longBeep")
            // Stop timer
            timer.invalidate()
            firstGateViewModelDelegate?.updateCountDownLabelText(count: "GO!")
            firstGateViewModelDelegate?.removeCountDownLabel()
            counter = 3
                        
            // Create race ID and distrbute to database
            createRun()
        }
    }

    func playSound(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let audioPlayer = audioPlayer else { return }

            audioPlayer.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func cancelRun() {
        timer.invalidate()
        
        // Remove current run id from database
        DatabaseManager.shared.removeCurrentRun(completion: { success in
            if success {
                print("Removed current run")
            }
            else {
                print("Failed to remove current run")
            }
        })
    }
    
    func createRun() {
        print("Creating race IDs")
        
        // Create data to include in run node
        let startTime = Date().currentTimeMillis()
        let date = FirstGateViewModel.dateFormatterShort.string(from: Date())
        let type = userSelectedType
        let distance = userSelectedLength
        
        DatabaseManager.shared.registerCurrentRunToDatabase(time: startTime, runType: type, runDate: date, runDistance: distance, with: { success in
            if success  {
            }
            else {
                // Should show error to user!!! //
            }
        })
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
                strongSelf.firstGateViewModelDelegate?.updateRunningAnimtion(color: Constants.accentColor!.cgColor, label: "Run ongoing")
            }
            else {
                print("waiting")
                strongSelf.firstGateViewModelDelegate?.updateRunningAnimtion(color: Constants.contrastColor!.cgColor, label: "Waiting for run to start")
            }
        })
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
    
    /// Is called each time new frame is recieved from the camera.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        videoCounter = videoCounter + 1
        
        breakTime = Date().currentTimeMillis()
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        //Dont know what this does, but dont move
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))

        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // Will only check for breaks after the run has begun. Is running is set to true after the database has received a start time.
        if Constants.isRunning == true {
            // Gives the camera time to stabilize before evaluating.
            if videoCounter >= 15 {
                let broken = breakObserver.checkIfBreakHasOccured(cvPixelBuffer: pixelBuffer!)
                if (broken == true) {
                    print("Break has been detected.")
                    sendTime(time: breakTime, endTime: true)
                    breakObserver.recentFramesArray = []
                    videoCounter = 0
                }
            }
        }
    }
}



// MARK: - Functions related to Setting up and configuring camera.

extension FirstGateViewModel {
    
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


