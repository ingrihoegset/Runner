//
//  LinkToPartnerViewModel.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import Foundation
import UIKit

protocol LinkViewModelDelegate: AnyObject {
    func didUpdateLink()
    func didFetchProfileImage(image: UIImage)
}

class LinkToPartnerViewModel {
    
    weak var linkViewModelDelegate: LinkViewModelDelegate?
    
    init() {
        listenForNewLink()
    }
    
    func createNewLink(safePartnerEmail: String) {
        
        DatabaseManager.shared.registerLink(with: safePartnerEmail, completion: { success in
            if success {
                print ("New Link created. And database updated for users")
                UserDefaults.standard.setValue(safePartnerEmail, forKey: "partnerEmail")
            }
            else {
                print("Failed update database with new Link")
            }
        })
    }
    
    // Start listening for new link
    func listenForNewLink() {
        DatabaseManager.shared.listenForNewLink(completion: { [weak self] result in
            switch result {
            case .success(_):
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.linkViewModelDelegate?.didUpdateLink()
                print ("Link updated. Close QR view controller")
                
            case .failure(_):
                print("Do not close QR-code VC automatically.")
            }
        })
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
                        self?.linkViewModelDelegate?.didFetchProfileImage(image: downloadedImage)
                    }
                })
                
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })
    }
}

