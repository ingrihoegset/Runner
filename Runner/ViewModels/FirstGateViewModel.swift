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
    func updateCountDownLabelText(firstCount: String, secondCount: String)
    func updateTimeElapsed(firstMin: String, secondMin: String, firstSec: String, secondSec: String, firstHun: String, secondHun: String)
    func resetUIOnRunEnd()
    func updateRunningAnimtion(color: CGColor, label: String)
    func removeCountDownLabel()
    func showOnboardFinishLineOneUser()
    func hasOnboardedFinishLineOneUser()
    func showOnboardStartLineTwoUsers()
    func hasOnboardedStartLineTwoUsers()
    func showRunResult(runresult: RunResults, photoFinishImage: UIImage)
    func cameraRestricted()
    func cameraDenied()
}

class FirstGateViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var firstGateViewModelDelegate: FirstGateViewModelDelegate?
    let userSelectionsModel = UserRunSelections.shared
    
    // In order to set up camera
    let captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    // Breakobserver that helps us detect whether or not break has occured.
    let breakObserver = BreakObserver()
    var breakTime: Double = 0
    var videoCounter = 0
    var isRunning = false
    
    //Photo finish image
    var photoFinishImage = UIImage()
    
    public static let dateFormatterShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = .none
        return formatter
    }()
    
    // Objects that are selected by user for transmittion to database
    var userSelectedLength = UserRunSelections.shared.getUserSelectedLength()
    var userSelectedType = UserRunSelections.shared.getUserSelectedType()
    var userSelectedDelay = UserRunSelections.shared.getUserSelectedDelay()
    var userSelectedRunner = UserRunSelections.shared.getUserIsRunning()
    
    // Objects related to countdown
    var timer = Timer()
    var audioPlayer: AVAudioPlayer?
    var counter = UserRunSelections.shared.getUserSelectedDelay()
    
    // Objects related to Reaction Count Down
    var reactionTimer = Timer()
    var reactionTime = UserRunSelections.shared.getUserSelectedReaction()
    var randomWait = 0
    
    // Objects related to showing time elapsed since run started
    var timeElapsed = 0
    var showTimer = Timer()
        
    override init() {
        super.init()
        // Listens for cancelled or completed run so that UI is reset for user
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: NSNotification.Name(rawValue: "reset"), object: nil)
        
        // Make sure visual timer is not counting
        resetShowTimer()
        
        currentRunOngoing()
        
        listenForEndOfCurrentRun()
        
        // Starts Camera if User has selected to run with one gate only
        let isRunningWithOneGate = UserRunSelections.shared.getIsRunningWithOneGate()
        if isRunningWithOneGate == true {
            // Sets up camera, after checking if camera is accessible
            goToCamera()
        }
        else {
            // If running with 2 gates and user has selected false start - should show camera also at first gate
            if userSelectionsModel.getUserSelectedFalseStart() == true {
                goToCamera()
            }
        }
        
        userSelectedLength = userSelectionsModel.getUserSelectedLength()
        userSelectedType = userSelectionsModel.getUserSelectedType()
        userSelectedDelay = userSelectionsModel.getUserSelectedDelay()
    }
    
    // Resets UI from cancel to start run when runs is completed
    @objc func reset() {
        firstGateViewModelDelegate?.resetUIOnRunEnd()
        resetShowTimer()
    }
    
    // Creates timer object and tells the timer which function to preform for every time interval.
    @objc func startCountDown() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        counter = userSelectedDelay
        
        // Starts break analysis
        if userSelectionsModel.userSelectedFalseStart == true {
            startCountDownWithFalseStart()
        }
    }
    
    // During count down with false start, the break analysis starts when count down starts and finishes when count down is complete
    func startCountDownWithFalseStart() {
        startBreakAnalysis()
    }
    
    //Is trigger for every timer interval (1 second)
    @objc func countDown() {
        
        //Updates count down label in start VC
        let count = String(counter)
        var first = "0"
        var second = "0"
        if count.count == 2 {
            first = count[0]
            second = count[1]
        }
        else {
            first = "0"
            second = count
        }
        firstGateViewModelDelegate?.updateCountDownLabelText(firstCount: first, secondCount: second)

        //Related to playing sounds on count down
        if (counter % 10 == 0 && counter > 0) {
            if counter == 90 {
                playSound(filename: "90")
            }
            else if counter == 80 {
                playSound(filename: "80")
            }
            else if counter == 70 {
                playSound(filename: "70")
            }
            else if counter == 60 {
                playSound(filename: "60")
            }
            else if counter == 50 {
                playSound(filename: "50")
            }
            else if counter == 40 {
                playSound(filename: "40")
            }
            else if counter == 30 {
                playSound(filename: "30")
            }
            else if counter == 20 {
                playSound(filename: "20")
            }
            else if counter == 10 {
                playSound(filename: "10")
            }
            else {
                playSound(filename: "shortBeep")
            }
            counter = counter - 1
        }
        else if (counter > 3) {
            counter = counter - 1
        }
        else if (counter <= 3 && counter > 0) {
            playSound(filename: "shortBeep")
            counter = counter - 1
        }
        // Start the race with signal and create run in database
        else {
            // Stop timer
            timer.invalidate()
            firstGateViewModelDelegate?.updateCountDownLabelText(firstCount: "0", secondCount: "0")
            firstGateViewModelDelegate?.removeCountDownLabel()
            counter = 3
            
            if userSelectionsModel.getUserSelectedType() == String(UserRunSelections.runTypes.Reaction.rawValue) {
                // Creat the random wait time for the reaction
                randomWait = Int.random(in: 0...reactionTime)
                // Run should start right away
                if randomWait == 0 {
                    reactionCountDown()
                }
                // Run will start with delay, play short beep first and wait for start signal
                else {
                    playSound(filename: "shortBeep")
                    runReactionStart()
                }
            }
            else {
                runSprintStart()
            }
        }
    }
    
    private func runSprintStart() {
        // Stop false start monitor
        stopBreakAnalysis()
        
        playSound(filename: "longBeep")
        
        // Create run and distrbute to database
        createRun()

        // Start visual timer
        showTime()
    }
    
    private func runReactionStart() {
        reactionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reactionCountDown), userInfo: nil, repeats: true)
    }
    
    @objc func reactionCountDown() {
        if randomWait == 0 {
            // Stop false start monitor
            stopBreakAnalysis()
            
            playSound(filename: "longBeep")
            reactionTimer.invalidate()
            
            // Create run and distrbute to database
            createRun()

            // Start visual timer
            showTime()
        }
        else {
            randomWait -= 1
        }
    }
        
    private func playSound(filename: String) {
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
        resetShowTimer()
        
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
    
    private func createRun() {
        // Create data to include in run node
        let startTime = Date().currentTimeMillis()
        let date = FirstGateViewModel.dateFormatterShort.string(from: Date())
        let type = userSelectedType
        let distance = userSelectedLength
        let userRunning = userSelectedRunner
        
        DatabaseManager.shared.registerCurrentRunToDatabase(time: startTime, runType: type, runDate: date, runDistance: distance, userIsRunning: userRunning, with: { success in
            if success  {
            }
            else {
                // Should show error to user!!! //
            }
        })
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
                            strongSelf.firstGateViewModelDelegate?.showRunResult(runresult: runResult, photoFinishImage: strongSelf.photoFinishImage)
                            
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
            var id = "00"
            if let runID = run["run_id"] as? String {
                id = runID
            }
            return RunResults(time: 0.00,
                              minutes: "00",
                              seconds: "00",
                              hundreths: "00",
                              distance: 00,
                              averageSpeed: 0.00,
                              type: "Sprint",
                              date: Date(),
                              runID: id)
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
                
                // Update UI to state
                print("ongoing")
                strongSelf.firstGateViewModelDelegate?.updateRunningAnimtion(color: Constants.accentColorDark!.cgColor, label: "Running")
                
                // Start camera analysis if appropriate
                let oneGate = strongSelf.userSelectionsModel.getIsRunningWithOneGate()
                
                if oneGate == true {
                    strongSelf.startBreakAnalysis()
                }
            }
            else {
                print("waiting")
                strongSelf.firstGateViewModelDelegate?.updateRunningAnimtion(color: Constants.textColorAccent!.cgColor, label: "Waiting")
                
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
    
    // Creates timer object used to keep track of ongoing race time for user interface
    @objc func showTime() {
        showTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateShownTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateShownTime() {
        
        timeElapsed += 1
        
        //Updates count down label in start VC
        let numbers = String(timeElapsed)
        
        // if numbers.count > 6 the run has been going for more than 99 minutes. This is unrealistic for practical use.
        // Discard counter and reset timer
        if numbers.count > 6 {
            resetShowTimer()

        }
        else {
            var min10 = "0"
            var min1 = "0"
            var sec10 = "0"
            var sec1 = "0"
            var hund10 = "0"
            var hund1 = "0"
            
            if numbers.count - 6 >= 0 {
                min10 = numbers[numbers.count - 6]
            }
            if numbers.count - 5 >= 0 {
                min1 = numbers[numbers.count - 5]
            }
            if numbers.count - 4 >= 0 {
                sec10 = numbers[numbers.count - 4]
            }
            if numbers.count - 3 >= 0 {
                sec1 = numbers[numbers.count - 3]
            }
            if numbers.count - 2 >= 0 {
                hund10 = numbers[numbers.count - 2]
            }
            if numbers.count - 1 >= 0 {
                hund1 = numbers[numbers.count - 1]
            }
            
            firstGateViewModelDelegate?.updateTimeElapsed(firstMin: min10, secondMin: min1, firstSec: sec10, secondSec: sec1, firstHun: hund10, secondHun: hund1)
        }
    }
    
    private func resetShowTimer() {
        showTimer.invalidate()
        timeElapsed = 0
        firstGateViewModelDelegate?.updateTimeElapsed(firstMin: "0", secondMin: "0", firstSec: "0", secondSec: "0", firstHun: "0", secondHun: "0")
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
        if isRunning == true {
            // Gives the camera time to stabilize before evaluating.
            if videoCounter >= 15 {
                let broken = breakObserver.checkIfBreakHasOccured(cvPixelBuffer: pixelBuffer!)
                if (broken == true) {
                    print("Break has been detected.")
                    if userSelectionsModel.userSelectedFalseStart == true {
                        falseStartDected()
                    }
                    else {
                        sendTime(time: breakTime, endTime: true)
                    }
                    resetShowTimer()
                    breakObserver.recentFramesArray = []
                    videoCounter = 0
                    
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
        
        photoFinishImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
    }
    
    func falseStartDected() {
        playSound(filename: "error")
        cancelRun()
        stopBreakAnalysis()
        firstGateViewModelDelegate?.resetUIOnRunEnd()
    }
    
    /// Related to onboarding
    func hasOnboardedFinishLineOneUser() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedFinishLineOneUser)
        firstGateViewModelDelegate?.hasOnboardedFinishLineOneUser()
        
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardingFinishLineOneUser() {
        let onboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedFinishLineOneUser)
        let runningWithOneGate = UserRunSelections.shared.getIsRunningWithOneGate()
        if runningWithOneGate == true {
            if onboarded == false {
                firstGateViewModelDelegate?.showOnboardFinishLineOneUser()
            }
        }
    }
    
    func hasOnboardedStartLineTwoUsers() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedStartLineTwoUsers)
        firstGateViewModelDelegate?.hasOnboardedStartLineTwoUsers()
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardingStartLineTwoUsers() {
        let onboarded = UserDefaults.standard.bool(forKey: Constants.hasOnboardedStartLineTwoUsers)
        let runningWithOneGate = UserRunSelections.shared.getIsRunningWithOneGate()
        if runningWithOneGate == false {
            if onboarded == false {
                firstGateViewModelDelegate?.showOnboardStartLineTwoUsers()
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


// Handles access to camera
extension FirstGateViewModel {
    //Makes sure that user has given access to camera before setting up a camerasession
    func goToCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            self.cameraSetup()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if (granted)
                {
                    self.cameraSetup()
                }
                else
                {
                    self.firstGateViewModelDelegate?.cameraDenied()
                }
            }

        case .denied:
            self.firstGateViewModelDelegate?.cameraDenied()

        case .restricted:
            self.firstGateViewModelDelegate?.cameraRestricted()
        }
    }
}


