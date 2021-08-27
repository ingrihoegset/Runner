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
     Filename: /images/ingrihoegset-gmail-com_profile_picture.png
     */
    
    /// Uploads picture to firebase storage and returns completion with URL string to download. On successful completion returns url as string.
    public func uploadProfilPicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
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
                
                let urlString = url.absoluteString
                print("Downloading url returned: \(urlString)")
                
                let uploadedImage = UIImage(data: data)
                StorageManager.cache.setObject(uploadedImage!, forKey: urlString as NSString)

                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
    
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
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            // Saves a the url for a given path.
            UserDefaults.standard.set(url, forKey: path)
            completion(.success(url))
        })
    }

    // Checks if image is already cached
    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        // If there is a cached image
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            print("URL", url.absoluteString)
            completion(image)
            print("Getting cached image")
        }
        // If no image is cached
        else {
            downloadImage(withURL: url, completion: completion)
            print("downloading image")
        }
    }
    
    static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responsURL, error in
            
            var downloadedImage: UIImage?
            
            if let data = data  {
                downloadedImage = UIImage(data: data)
            }
            
            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        dataTask.resume()
    }
}
