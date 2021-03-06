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
    func failedToConnectError()
}

class LinkToPartnerViewModel {
    
    weak var linkViewModelDelegate: LinkViewModelDelegate?
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(newLinkOccured), name: NSNotification.Name(rawValue: Constants.linkOccured), object: nil)
    }
    
    func checkIfQRRepresentsUser(partnerUserID: String) {
        DatabaseManager.shared.getAllUsers(completion: { [weak self ] result in
            switch result {
            case .success(let users):
                // check if userkey exists in dictionart of users
                // If so, QR code represents a registered user, go ahead and connect to user
                if users[partnerUserID] != nil {
                    self?.createNewLink(partnerUserID: partnerUserID)
                }
                else {
                    // Show error that couldnt find user
                    self?.linkViewModelDelegate?.failedToConnectError()
                }
                
            case .failure(let error):
                print("Failed to download url: \(error)")
                // Show error that couldnt find user
                self?.linkViewModelDelegate?.failedToConnectError()
            }
        })
    }
    
    /*
    func filterUsers(with term: String, users: [[String: String]]) -> Bool {
        
        let result: [[String: String]] = users.filter({
            guard let email = $0["email"] else {
                return false
            }
            // Returns true if there is an email that matches the term that was passed in. Results will contain the match
            return email.hasPrefix(term.lowercased())
        
        })
        if result.isEmpty {
            // No user found in database to  match QR
            return false
        }
        else {
            //Found match in database for user
            return true
        }
    }*/
    
    /*
    func createNewLink(safePartnerEmail: String) {
        
        DatabaseManager.shared.registerLink(with: safePartnerEmail, completion: { success in
            if success {
                print ("New Link created. And database updated for users")
                UserDefaults.standard.setValue(safePartnerEmail, forKey: "partnerEmail")
            }
            else {
                print("Failed update database with new Link")
                // -- Should show error to user -- //
                self.linkViewModelDelegate?.failedToConnectError()
            }
        })
    }*/
    
    func createNewLink(partnerUserID: String) {
        
        DatabaseManager.shared.registerLinkWithPartnerID(with: partnerUserID, completion: { success in
            if success {
                print ("New Link created. And database updated for users")
                UserDefaults.standard.setValue(partnerUserID, forKey: Constants.partnerUserID)
            }
            else {
                print("Failed update database with new Link")
                // -- Should show error to user -- //
                self.linkViewModelDelegate?.failedToConnectError()
            }
        })
    }
        
    // New Link occured. Notification posted. Should close LinkVC
    @objc func newLinkOccured() {
        self.linkViewModelDelegate?.didUpdateLink()
        self.scanOnboarded()
    }
    
    func fetchProfilePic() {
        print("Fetching picture for linking page")

        guard let userID = UserDefaults.standard.value(forKey: Constants.userID) as? String else {
            print("No userid found when creating linking page")
            return
        }
        
        StorageManager.shared.getProfileImage(userID: userID, completion: { [weak self] result in
            switch result {
            case .success(let image):
                print("Found profile image for linking page")
                self?.linkViewModelDelegate?.didFetchProfileImage(image: image)
            case .failure(_):
                print("Failed to retrieve profil image for linking page")
                self?.linkViewModelDelegate?.failedToConnectError()
            }
        })
        
        
        /*
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        print("image path", path)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("Succeed in downloading url in linking")
                StorageManager.getImage(withURL: url, completion: { resultImage in
                    switch resultImage {
                    case .success(let downloadedImage):
                        self?.linkViewModelDelegate?.didFetchProfileImage(image: downloadedImage)
                    case .failure(_):
                        self?.linkViewModelDelegate?.failedToConnectError()
                    }
                })
                
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })*/
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



