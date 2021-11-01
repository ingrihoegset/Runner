//
//  HomeViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    func didFetchProfileImage(image: UIImage, safeEmail: String)
    func didGetRunResult(result: RunResults)
    func hasOnboardedConnect()
    func showOnboardConnect()
    func showOnboardedOpenEndGate()
    func hasOnboardedEndGate()
    func alertUserThatIsDisconnectedFromPartner()
    
    func updateUiUnconnected()
    func updateUiConnectedStartGate()
    func updateUiConnectedEndGate()
    
    func updatePartnerImage(image: UIImage)
    func updateUserImage(image: UIImage)
    
    func animateUnlink()
    func animateLinkedPartnerUI()
}


class HomeViewModel {
    
    weak var homeViewModelDelegate: HomeViewModelDelegate?
    var firstLaunch = true
    
    init() {
        listenForNewLink()
    }
    
    // Updates User Selected Run type when user selects a run type from home view
    func updateRunType(type: UserRunSelections.runTypes) {
        UserRunSelections.shared.setUserSelectedType(type: type.rawValue)
    }
    
    // Returns image if succeeds, error if not
    func fetchProfilePic(email: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        // Get database path for image
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename

        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                StorageManager.getImage(withURL: url, completion: { image in
                    if let downloadedImage = image {
                        completion(.success(downloadedImage))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
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
                print("Failed to download url: \(error), or no image is saved for user.")
                // What should happen here????
            }
        })
    }
    
    func removeCurrentRun() {
        DatabaseManager.shared.removeCurrentRun(completion: { _ in })
    }
    
    /// Related to managing the progressive onboarding.
    func hasOnboardedConnect() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedConnectToPartner)
        homeViewModelDelegate?.hasOnboardedConnect()
    }
    
    func hasOnboardedEndGate() {
        UserDefaults.standard.set(true, forKey: Constants.hasOnboardedOpenEndGate)
        homeViewModelDelegate?.hasOnboardedEndGate()
    }
    
    // If onboarding of connect hasnt already occured, show onboardconnect bubble
    func showOnboardConnect() {
        let onboardConnect = UserDefaults.standard.bool(forKey: Constants.hasOnboardedConnectToPartner)
        if onboardConnect == false {
            homeViewModelDelegate?.showOnboardConnect()
        }
    }
    
    // If onboarding of connect hasnt already occured, show onboardendgate bubble
    func showOnboardEndGate() {
        let onboardConnect = UserDefaults.standard.bool(forKey: Constants.hasOnboardedOpenEndGate)
        if onboardConnect == false {
            homeViewModelDelegate?.showOnboardedOpenEndGate()
        }
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
                
                // If there is a link, update user selections
                UserRunSelections.shared.setIsRunningWithOneGate(bool: false)
                
                // Tell link VC to close
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Constants.linkOccured), object: nil)
                
                // Can only be 1 or 2 if case is success
                if gateNumber == 1 {
                    strongSelf.homeViewModelDelegate?.updateUiConnectedStartGate()
                }
                else if gateNumber == 2 {
                    strongSelf.homeViewModelDelegate?.updateUiConnectedEndGate()
                }
                else {
                    strongSelf.homeViewModelDelegate?.updateUiUnconnected()
                }
               
                // Start fetching partner profile pic
                strongSelf.fetchProfilePic(email: partnerEmail, completion: { result in
                    switch result {
                    case .success(let image):
                        strongSelf.homeViewModelDelegate?.updatePartnerImage(image: image)
                        strongSelf.homeViewModelDelegate?.animateLinkedPartnerUI()
                    case .failure(let error):
                        strongSelf.homeViewModelDelegate?.animateLinkedPartnerUI()
                        print("error when retreiving partner image from database")
                        print(error)
                    }
                })
                
                print ("Successfully detected update to link")
                
            case .failure(_):
                guard let strongSelf = self else {
                    return
                }
                print("No link to detect.")
                
                // If there is no link, update user selections
                UserRunSelections.shared.setIsRunningWithOneGate(bool: true)
                
                // Tell home that there is no partner and that it is gate 1.
                // Also, if fetch fails in general, show unlinked view on home VC.
                strongSelf.homeViewModelDelegate?.updateUiUnconnected()
                
                // Start fetching user profile pic
                guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                    print("No user email found")
                    return
                }
                
                strongSelf.fetchProfilePic(email: userEmail, completion: { result in
                    switch result {
                    case .success(let image):
                        strongSelf.homeViewModelDelegate?.updateUserImage(image: image)
                        strongSelf.homeViewModelDelegate?.animateUnlink()
                        strongSelf.alertUserOfDisconnectionFromPartner()
                    case .failure(let error):
                        strongSelf.homeViewModelDelegate?.animateUnlink()
                        strongSelf.alertUserOfDisconnectionFromPartner()
                        print("Error when retreiving user profile pic from database")
                        print(error)
                    }
                })

            }
        })
    }
    
    // Will alert user of disconnection, except when disconnection is on maintainance clearing of links on opening of app
    private func alertUserOfDisconnectionFromPartner() {
        if self.firstLaunch == true {
            self.firstLaunch = false
        }
        else {
            self.homeViewModelDelegate?.alertUserThatIsDisconnectedFromPartner()
        }
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
