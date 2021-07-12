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
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
