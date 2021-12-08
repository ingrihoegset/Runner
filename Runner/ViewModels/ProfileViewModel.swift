//
//  ProfileViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol ProfileViewModelDelegate: AnyObject {
    func didFetchProfileImage(image: UIImage)
}


class ProfileViewModel {
    
    weak var profileViewModelDelegate: ProfileViewModelDelegate?
    
    init() {
        fetchProfilePic()
    }
    
    func fetchProfilePic() {
        print("Fetching picture in Settings")

        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No email saved to user defaults")
            return
        }
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("Returned image url for settings")
                StorageManager.getImage(withURL: url, completion: { imageResult in
                    switch imageResult {
                    // Succeeded in getting user name. Proceed to generate views
                    case .success(let downloadedImage):
                        self?.profileViewModelDelegate?.didFetchProfileImage(image: downloadedImage)
                    case .failure(let imageError):
                        print(imageError)
                    }
                })
            case .failure(let error):
                print("Failed to download url for settings: \(error)")
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
    
    func updateProfilePicture(data: Data, fileName: String, completion: @escaping (Bool) -> Void) {
        StorageManager.shared.uploadProfilPicture(with: data, fileName: fileName, completion: { result in
            switch result {
            case .success(let url):
                completion(true)
                
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    print("No user found")
                    return
                }
                let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
                let filename = safeEmail + "_profile_picture.png"
                let path = "images/" + filename
                // By removing this from user defaults fetching picture will fetch from database and not from cached image
                UserDefaults.standard.removeObject(forKey: path)
                
            case .failure(let error):
                completion(false)
            }
        })
    }
    
}
