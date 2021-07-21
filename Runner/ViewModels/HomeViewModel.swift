//
//  HomeViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate {
    func didFetchProfileImage(image: UIImage, safeEmail: String)
    func didUpdatePartnerUI(partner: String, gateNumber: Int)
    func didGetRunTimes(totalSeconds: Double)
}


class HomeViewModel {
    
    var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        listenForNewLink()
        listenForCurrentRunID()
        currentRunOngoing()
    }
    
    /// Call on storageManager to fetch profil pic for our user
    func fetchProfilePic(email: String) {
        
        print("Fetching picture")
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        print("image path", path)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("Succeed in downloading url")

                StorageManager.getImage(withURL: url, completion: { image in
                    if let downloadedImage = image {
                        self?.homeViewModelDelegate?.didFetchProfileImage(image: downloadedImage, safeEmail: safeEmail)
                    }
                })
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })
    }
    
    // Clears link with partner from database upon app opening from terminate state
    func clearLinkFromDatabase() {
        DatabaseManager.shared.clearLinkFromDatabase(with: { success in
            if success {
                print ("Successfully deleted link from database for user and partner")
            }
            else {
                print("Failed to remove link from database.")
            }
        })
    }
    
    // Start listening for new link
    // When a link is found
    func listenForNewLink() {
        print("Started listening for link with partner")
        DatabaseManager.shared.listenForNewLink(completion: { [weak self] result in
            switch result {
            
            // In success case we are returned a gateNumber. Send this to home view to update UI in accordance with correct gate number.
            case .success(let gateNumber):
                guard let strongSelf = self else {
                    return
                }
                
                guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
                    print("")
                    return
                }
                // Send partner email to home view as test to update UI. Should really get and send name. Send gate number for UI update.
                strongSelf.homeViewModelDelegate?.didUpdatePartnerUI(partner: partnerEmail, gateNumber: gateNumber)
               
                // Start fetching partner profile pic
                strongSelf.fetchProfilePic(email: partnerEmail)
                print ("Successfully detected update to link")
                
            case .failure(_):
                guard let strongSelf = self else {
                    return
                }
                print("No link to detect.")
                
                // Tell home that there is no partner and that it is gate 1.
                // Also, if fetch fails in general, show unlinked view on home VC.
                strongSelf.homeViewModelDelegate?.didUpdatePartnerUI(partner: "No partner", gateNumber: 0)
            }
        })
    }
    
    /// Function called on build (?) to set up listener for current race ID
    // One can question if this is the correct place to call such essential code...
    private func listenForCurrentRunID() {
        DatabaseManager.shared.listenForCurrentRunID(completion: { [weak self] result in
            switch result {
                case .success(let times):
                    guard let strongSelf = self else {
                        return
                    }
                    // Convert times to total time
                    let totalSeconds = strongSelf.timesToResult(times: times)
                    // Calls on home VC to open results VC
                    strongSelf.homeViewModelDelegate?.didGetRunTimes(totalSeconds: totalSeconds)
                        
                case .failure(let error):
                    print(error)
            }
        })
    }
    
    private func currentRunOngoing() {
        DatabaseManager.shared.currentRunOngoing(completion: { success in
            if success {
                print("Listening for ongoing race")
            }
            else {
                print("no onging race")
            }
        })
    }
    
    private func timesToResult(times: [String: Double]) -> Double {
        let endTime = times["end_time"] ?? 0.0
        let startTime = times["start_time"] ?? 0.0
        let totalSeconds = endTime - startTime
        return totalSeconds
    }
}
