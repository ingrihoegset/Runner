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
}


class HomeViewModel {
    
    var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        listenForNewLink()
    }
    
    /// Call on storageManager to fetch profil pic for our user
    func fetchProfilePic(email: String) {
        print("Fetching a profile pic")

        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        print("image path", path)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("Successfully downloaded profile url")
                self?.downloadImage(url: url, safeEmail: safeEmail)
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })
    }
    
    private func downloadImage(url: URL, safeEmail: String) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            print("downloading image")
            guard let data = data, error == nil else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            self.homeViewModelDelegate?.didFetchProfileImage(image: image, safeEmail: safeEmail)
        }).resume()
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
        print("Started listening")
        DatabaseManager.shared.observeNewLink(completion: { [weak self] result in
            switch result {
            
            // In success case we are returned a gateNumber. Send this to home view to update UI in accordance with correct gate number.
            case .success(let gateNumber):
                guard let strongSelf = self else {
                    return
                }
                
                guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
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
}
