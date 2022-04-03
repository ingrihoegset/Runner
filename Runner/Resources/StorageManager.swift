//
//  StorageManager.swift
//  Runner
//
//  Created by Ingrid on 12/07/2021.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    // Instance of Storage Manager
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    static let cache = NSCache<NSString, UIImage>()
    
    /*
     Filename: /images/userID_profile_picture.png
     */
    
    /// Uploads picture to firebase storage and returns completion with URL string to download. On successful completion returns url as string.
    public func uploadProfilPicture(with data: Data?, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        if let data = data {
            
            storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
                guard error == nil else {
                    print("Failed to upload data to Firebase for picture storage.")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                
                self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                    guard let url = url else {
                        print("Failed to get download URL")
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        return
                    }
                    
                    // Update user profile url every time image is uploaded
                    // This is done so we can easily fetch cached image when one exists
                    // When it doesnt exist, we need to download image from database
                    // We use the path way to the user image to make cahcing flexible "images/\(userID)_profile_picture.png"
                    
                    // Caching key
                    guard let userID = UserDefaults.standard.value(forKey: Constants.userID) as? String else {
                        print("No user id found when attempting to cache image during upload")
                        return
                    }
                    let cacheKey = "images/\(userID)_profile_picture.png"
                    
                    // Save url string with cache key
                    UserDefaults.standard.set(url.absoluteString, forKey: cacheKey)
                    
                    // Get same url string
                    guard let urlString = UserDefaults.standard.value(forKey: cacheKey) as? String else {
                        print("No profile image url found in user defaults")
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        return
                    }
                    print("Downloading url returned: \(urlString)")
                    
                    // Caching image
                    let uploadedImage = UIImage(data: data)
                    StorageManager.cache.setObject(uploadedImage!, forKey: urlString as NSString)

                    completion(.success(urlString))
                })
            })
        }
        
        else {
            completion(.failure(StorageErrors.failedToUpload))
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    /// Get users profile image using cached image or downloading with user pathway
    public func getProfileImage(userID: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        // profile image path and image cache key
        let profileImagePath = "images/\(userID)_profile_picture.png"
     
        // Check for cached image string
        guard let profileImageString = UserDefaults.standard.value(forKey: profileImagePath) as? NSString else {
            // No cached image string found, download image from database with user pathway
            print("No cached image string found")
            downloadImage(for: profileImagePath, completion: { [weak self] result in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
            return
        }
        
        // If there is a cached image
        if let image = StorageManager.cache.object(forKey: profileImageString) {
            print("Using cached image")
            completion(.success(image))
        }
        else {
            // No cached image found even though there was an image string, download from database
            print("No cached image found")
            downloadImage(for: profileImagePath, completion: { [weak self] result in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
    }
    
    /// Downloads image from given pathway and caches image on same pathway
    public func downloadImage(for path: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        print("Downloading image")
        let reference = storage.child(path)
        
        // Firebase function to download image URL
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("Failed to get URL")
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            // Got URL, download image from URL
            let dataTask = URLSession.shared.dataTask(with: url) { data, responsURL, error in
                
                var downloadedImage: UIImage?
                
                if let data = data  {
                    print("Download image succeeded")
                    downloadedImage = UIImage(data: data)
                    
                    // Cache image on cache key provided by user image path
                    // Save url string with cache key
                    UserDefaults.standard.set(url.absoluteString, forKey: path)
                    
                    // Get same url string
                    guard let urlString = UserDefaults.standard.value(forKey: path) as? String else {
                        print("No profile image url found in user defaults")
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        return
                    }
                    
                    // Caching image
                    let uploadedImage = UIImage(data: data)
                    StorageManager.cache.setObject(uploadedImage!, forKey: urlString as NSString)
                    print("Image cached")
                    
                    if downloadedImage != nil {
                        DispatchQueue.main.async {
                            completion(.success(downloadedImage!))
                        }
                    }
                }
                
                // Something went wrong when downloading image
                if let error = error {
                    print("Failed to download image")
                    completion(.failure(error))
                }
            }
            dataTask.resume()
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    
    
    
    
    
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        
        // We have saved this url to userdefaults before, thus no need to call download url again
        if let haveURL = UserDefaults.standard.url(forKey: path) {
            print("Using already downloaded URL, no need to download again")
            completion(.success(haveURL))
            return
        }
        
        print("Downloading URL")
        let reference = storage.child(path)
        
        // Firebase function
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                print("Failed to get URL")
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            // Saves a the url for a given path.
            UserDefaults.standard.set(url, forKey: path)
            completion(.success(url))
        })
    }

    // Checks if image is already cached
    static func getImage(withURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // If there is a cached image
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            print("Getting cached image for \(url.absoluteString)")
            completion(.success(image))
        }
        // If no image is cached
        else {
            print("No image cached, downloading image with url \(url.absoluteString)")
            downloadImage(withURL: url, completion: completion)
        }
    }
    
    static func downloadImage(withURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responsURL, error in
            
            var downloadedImage: UIImage?
            
            if let data = data  {
                downloadedImage = UIImage(data: data)
                
                if downloadedImage != nil {
                    cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
                    DispatchQueue.main.async {
                        completion(.success(downloadedImage!))
                    }
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }*/
}
