//
//  StartGateViewModel.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import Foundation
import AVFoundation

protocol StartGateViewModelDelegate: AnyObject {
    func updateCountDownLabelText(count: String)
    func resetUIOnRunEnd()
}

class StartGateViewModel {
    
    public static let dateFormatterShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = .none
        return formatter
    }()
    
    /// Objects that are selected by user for transmittion to database
    var userSelectedLength = 60
    var userSelectedType = "Speed"
    
    /// Objects related to countdown
    var timer = Timer()
    var audioPlayer: AVAudioPlayer?
    var counter = 3
    
    weak var startGateViewModelDelegate: StartGateViewModelDelegate?
        
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: NSNotification.Name(rawValue: "reset"), object: nil)

    }
    
    // Resets UI from cancel to start run when runs is completed
    @objc func reset() {
        startGateViewModelDelegate?.resetUIOnRunEnd()
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
        startGateViewModelDelegate?.updateCountDownLabelText(count: count)

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
            startGateViewModelDelegate?.updateCountDownLabelText(count: "GO!")
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
        let date = StartGateViewModel.dateFormatterShort.string(from: Date())
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
}
