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
    func scanOnboarded()
    func showOnboardConnect()
}

class LinkToPartnerViewModel {
    
    weak var linkViewModelDelegate: LinkViewModelDelegate?
    
    init() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(newLinkOccured), name: NSNotification.Name(rawValue: Constants.linkOccured), object: nil)
    }
    
    func createNewLink(safePartnerEmail: String) {
        
        DatabaseManager.shared.registerLink(with: safePartnerEmail, completion: { success in
            if success {
                print ("New Link created. And database updated for users")
                UserDefaults.standard.setValue(safePartnerEmail, forKey: "partnerEmail")
            }
            else {
                print("Failed update database with new Link")
                
                // -- Should show error to user -- //
            }
        })
    }
        
    // New Link occured. Notification posted. Should close LinkVC
    @objc func newLinkOccured() {
        self.linkViewModelDelegate?.didUpdateLink()
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
    
    /// Related to onboarding of scanning functions
    func showOnboardConnect() {
        let onboardedConnect = UserDefaults.standard.bool(forKey: Constants.hasOnboardedScanPartnerQR)
        if onboardedConnect == false {
            linkViewModelDelegate?.showOnboardConnect()
        }
    }
    
    func scanOnboarded() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedScanPartnerQR)
        linkViewModelDelegate?.scanOnboarded()
    }
}

