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
    func showRunResult(runresult: RunResults)
    func dismissResultsVC()
    func cameraRestricted()
    func cameraDenied()
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
        if Constants.isRunning == true {
            // Gives the camera time to stabilize before evaluating.
            if counter >= 15 {
                let broken = breakObserver.checkIfBreakHasOccured(cvPixelBuffer: pixelBuffer!)
                if (broken == true) {
                    print("Break has been detected.")
                    sendTime(time: breakTime, endTime: true)
                    breakObserver.recentFramesArray = []
                    //self.secondGateViewModelDelegate?.runHasEnded()
                    counter = 0
                }
            }
        }
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
                            let runResult = strongSelf.getCurrentResult(run: runData)
                            
                            // Calls on home VC to open results VC
                            strongSelf.secondGateViewModelDelegate?.showRunResult(runresult: runResult)
                            
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
    
    // Converts data of run in database to run result object, taking into considertion users selected units and units applied when the run was saved
    private func getCurrentResult(run: [String: Any]) -> RunResults {
        
        // If unit used when this run was set is metric system, unit of run will be true. If nil, will also be true
        var unitOfSavedRun = true
        if let metric = run["metric_system"] as? Bool {
            if metric == false {
                unitOfSavedRun = false
            }
        }
        
        // Convert data in database to values needed to create a run result object
        if let endTime = run["end_time"] as? Double,
           let startTime = run["start_time"] as? Double,
           let distance = run["run_distance"] as? Int,
           let type = run["run_type"] as? String,
           let date = run["run_date"] as? String,
           let runID = run["run_id"] as? String {
            
            // Get total race time in seconds
            let totalSeconds = endTime - startTime
            let timeInDecimals = totalSeconds.round(to: 2)
            let hours = totalSeconds / 3600
            
            // Find times in min, sec and hundreths
            let milliseconds = totalSeconds * 100
            let millisecondsInt = Int(milliseconds)
            
            // Convert to time components
            let (minutes, seconds, hundreths) = milliSecondsToMinutesSecondsHundreths(milliseconds: millisecondsInt)
            
            // Get strings for time components
            let raceTimeHundreths = String(format: "%02d", hundreths)
            let raceTimeSeconds = String(format: "%02d", seconds)
            let raceTimeMinutes = String(format: "%02d", minutes)
            
            // Get speed in correct unit
            let speed = calculateSpeed(timeInHours: hours, unitOfSavedRun: unitOfSavedRun, runDistance: distance)
            
            // Get distance in correct unit
            let runDistance = calculateDistance(runDistance: distance, unitOfSavedRun: unitOfSavedRun)
            
            // Get date formatted as date
            let dateAsDate = getDate(date: date)
            
            let runResult = RunResults(time: timeInDecimals,
                                       minutes: raceTimeMinutes,
                                       seconds: raceTimeSeconds,
                                       hundreths: raceTimeHundreths,
                                       distance: runDistance,
                                       averageSpeed: speed,
                                       type: type,
                                       date: dateAsDate,
                                       runID: runID)
            
            return runResult
        }
        
        else {
            return RunResults(time: 0.00,
                              minutes: "00",
                              seconds: "00",
                              hundreths: "00",
                              distance: 00,
                              averageSpeed: 0.00,
                              type: "Sprint",
                              date: Date(),
                              runID: "00")
        }
    }
    
    // Calculates the speed in the units that the user has selected, regardless of the units in which the run is saved in the database. I.e. converts saved run to correct units.
    private func calculateSpeed(timeInHours: Double, unitOfSavedRun: Bool, runDistance: Int) -> Double {
        
        var speedInDecimals = 0.0
        
        // Units currently selecte by user
        var metricSystem = true
        if let selectedSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if selectedSystem == false {
                metricSystem = false
            }
        }
        
        // # 1 Users current selected system is Metric system
        // #1.1 Saved run and selected units are the same, both in metric
        if metricSystem == true && unitOfSavedRun == true {
            
            // Find distance in kilometers from distance in meters
            let kilometers = Double(runDistance) / 1000
            let speed = kilometers / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        // #1.1 Saved run is in imperial units and selected units are in metric
        else if metricSystem == true && unitOfSavedRun == false {
            
            // Convert from distance in yards to distance in kilometers
            let kilometers = Double(runDistance) * 0.0009144
            let speed = kilometers / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        
        // # 2 Users current selected system is Imperial system
        // #2.1 Saved run and selected units are the same, both in imperial
        else if metricSystem == false && unitOfSavedRun == false {
            
            // Find distance in miles from yards
            let miles = Double(runDistance) * 0.000568181818
            let speed = miles / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        // #2.1 Saved run is in metric, but selected units are in imperial
        else if metricSystem == false && unitOfSavedRun == true {
            
            // Find distance in miles from meters
            let miles = Double(runDistance) * 0.000621371192
            let speed = miles / timeInHours
            speedInDecimals = speed.round(to: 2)
            return speedInDecimals
        }
        else {
            return 0.0
        }
    }
    
    private func calculateDistance(runDistance: Int, unitOfSavedRun: Bool) -> Int {
        
        // Units currently selecte by user
        var metricSystem = true
        if let selectedSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if selectedSystem == false {
                metricSystem = false
            }
        }
        
        // # 1 Users current selected system is Metric system
        // #1.1 Saved run and selected units are the same, both in metric
        if metricSystem == true && unitOfSavedRun == true {
            
            // Find distance in meters
            return runDistance
        }
        // #1.1 Saved run is in imperial units and selected units are in metric
        else if metricSystem == true && unitOfSavedRun == false {
            
            // Convert from distance in yards to distance in meters
            let meters = yardsToMeters(yards: runDistance)
            return Int(meters)
        }
        
        // # 2 Users current selected system is Imperial system
        // #2.1 Saved run and selected units are the same, both in imperial
        else if metricSystem == false && unitOfSavedRun == false {
            
            // Find distance in yards
            return runDistance

        }
        // #2.1 Saved run is in metric, but selected units are in imperial
        else if metricSystem == false && unitOfSavedRun == true {
            
            // Find distance in yards from meters
            let yards = metersToYards(meters: runDistance)
            return Int(yards)
        }
        else {
            return 0
        }
    }
    
    private func getDate(date: String) -> Date {
        if let dateAsDate = FirstGateViewModel.dateFormatterShort.date(from: date) {
            return dateAsDate
        }
        else {
            return Date()
        }
    }
    
    func milliSecondsToMinutesSecondsHundreths (milliseconds : Int) -> (Int, Int, Int) {
      return (milliseconds / 6000, (milliseconds % 6000) / 100, (milliseconds % 60000) % 100)
    }
    
    func metersToYards(meters: Int) -> Double {
        return Double(meters) * 1.0936133
    }
    
    func yardsToMeters(yards: Int) -> Double {
        return Double(yards) * 0.9144
    }
    
    func kmhToMph(kmh: Double) -> Double {
        return kmh * 0.621371192
    }
    
    func mphToKmh(mph: Double) -> Double {
        return mph * 1.609344
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
            }
            else {
                strongSelf.secondGateViewModelDelegate?.updateRunningAnimtion(color: Constants.textColorDarkGray.cgColor, label: "Waiting for run to start")
            }
        })
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


