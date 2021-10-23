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
    func didUpdatePartnerUI(partner: String, gateNumber: Int)
    func didGetRunResult(result: RunResults)
    func hasOnboardedConnect()
    func showOnboardConnect()
    func showOnboardedOpenEndGate()
    func hasOnboardedEndGate()
    func launchFinished()
    func alertUserThatIsDisconnectedFromPartner()
}


class HomeViewModel {
    
    weak var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        listenForNewLink()
        // Used to determine when camera should be looking for a break time.
        currentRunOngoing()
    }
    
    // Updates User Selected Run type when user selects a run type from home view
    func updateRunType(type: UserRunSelections.runTypes) {
        UserRunSelections.shared.setUserSelectedType(type: type.rawValue)
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
                self?.homeViewModelDelegate?.launchFinished()
            }
        })
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
                
                // If there is no link, update user selections
                UserRunSelections.shared.setIsRunningWithOneGate(bool: true)
                
                // Tell home that there is no partner and that it is gate 1.
                // Also, if fetch fails in general, show unlinked view on home VC.
                strongSelf.homeViewModelDelegate?.didUpdatePartnerUI(partner: "No partner", gateNumber: 0)
                strongSelf.homeViewModelDelegate?.alertUserThatIsDisconnectedFromPartner()
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
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
