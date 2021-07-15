//
//  StartGateViewModel.swift
//  Runner
//
//  Created by Ingrid on 14/07/2021.
//

import Foundation
import AVFoundation

protocol StartGateViewModelDelegate {
    func updateCountDownLabelText(count: String)
}

class StartGateViewModel {
    
    /// Objects related to countdown
    var timer = Timer()
    var audioPlayer: AVAudioPlayer?
    var counter = 3
    
    var startGateViewModelDelegate: StartGateViewModelDelegate?
        
    init() {

    }
    
    // Creates timer object and tells the timer which function to preform for every time interval.
    @objc func startCountDown(countDownTime: Int) {
        
        // Create race ID and distrbute to database
        createRaceIDs(with: { [weak self] success in
            if success {
                guard let strongSelf = self else {
                    return
                }
                print("Uploading run ids succeeded, activating timer.")
                strongSelf.timer = Timer.scheduledTimer(timeInterval: 1, target: strongSelf, selector: #selector(strongSelf.countDown), userInfo: nil, repeats: true)
                strongSelf.counter = countDownTime
            }
            else {
                print("Uploading run ids to database failed. Show fail message to user.")
            }
        })

    }
    
    //Is trigger for every timer interval (1 second)
    @objc func countDown() {

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
            timer.invalidate()
            startGateViewModelDelegate?.updateCountDownLabelText(count: "GO!")
            counter = 3
            
            // Send start time time stamp to database
            let startTime = Date().currentTimeMillis()
            sendStartTime(startTime: startTime)
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
    }
    
    func createRaceIDs(with completion: @ escaping (Bool) -> Void) {
        print("Creating race IDs")
        
        DatabaseManager.shared.registerCurrentRunToDatabase(with: { success in
            if success  {
                completion(true)
            }
            else {
                // Should show error to user and spinne while waiting!!!!! //
                completion(false)
            }
        })
        
    }
    
    private func sendStartTime(startTime: Double) {
        print("Attempting to send start time")
        DatabaseManager.shared.sendStartTime(with: startTime, completion: { success in
            if success {
                print("Run updated with start time in database")
            }
            else {
                print("Failed to update run in database with start time")
            }
        })
    }
}
