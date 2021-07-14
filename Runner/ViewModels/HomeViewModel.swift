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
    func didUpdatePartnerUI(partner: String)
}


class HomeViewModel {
    
    var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        listenForNewLink()
    }
    
    /// Call on storageManager to fetch profil pic for our uesr
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
    func listenForNewLink() {
        print("started listening")
        DatabaseManager.shared.observeNewLink(completion: { success in
            if success {
                guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
                    return
                }
                // Send partner email to home view as test to update UI. Should really get and send name.
                self.homeViewModelDelegate?.didUpdatePartnerUI(partner: partnerEmail)
                // Start fetching partner profile pic
                self.fetchProfilePic(email: partnerEmail)
                print ("Successfully detected update to link")
            }
            else {
                print("No link to detect.")
                self.homeViewModelDelegate?.didUpdatePartnerUI(partner: "No partner")
            }
        })
    }
}
