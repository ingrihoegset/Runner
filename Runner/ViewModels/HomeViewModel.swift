//
//  HomeViewModel.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import UIKit

protocol HomeViewModelDelegate {
    func didFetchProfileImage(image: UIImage)
}


class HomeViewModel {
    
    var homeViewModelDelegate: HomeViewModelDelegate?
    
    init() {
        
    }
    
    func fetchProfilePic() {
        print("fetching")
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No email saved to user defaults")
            return
        }
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/"+filename
        print("image path", path)
        
        StorageManager.shared.downloadURL(for: path, completion: { [weak self ] result in
            switch result {
            case .success(let url):
                print("success")
                self?.downloadImage(url: url)
            case .failure(let error):
                print("Failed to download url: \(error)")
            }
        })
    }
    
    private func downloadImage(url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            print("downloading image")
            guard let data = data, error == nil else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            print("calling delegate")
            self.homeViewModelDelegate?.didFetchProfileImage(image: image)
        }).resume()
    }
}
