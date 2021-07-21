//
//  ProfileViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol ProfileViewModelDelegate {
    func didFetchProfileImage(image: UIImage)
}


class ProfileViewModel {
    
    var profileViewModelDelegate: ProfileViewModelDelegate?
    
    init() {
        
    }
    
    func fetchProfilePic() {
        print("Fetching picture")

        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No email saved to user defaults")
            return
        }
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
                        self?.profileViewModelDelegate?.didFetchProfileImage(image: downloadedImage)
                    }
                })
                
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })
    }
    
    // Clears link with partner from database upon user log out
    func clearPartnerLinkFromDatabase() {
        DatabaseManager.shared.clearLinkFromDatabase(with: { success in
            if success {
                print ("Successfully deleted link from database for user and partner")
            }
            else {
                print("Failed to remove link from database.")
            }
        })
    }
}
