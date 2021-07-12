//
//  DatabaseManager.swift
//  Runner
//
//  Created by Ingrid on 11/07/2021.
//

import Foundation
import FirebaseDatabase

// final class so cannot be subclassed
final class DatabaseManager {
    
    // Singelton for easy read and write access. Returns an instance to the database manager.
    static let shared = DatabaseManager()
    
    // Reference to the database
    private let database = Database.database().reference()
    

}

// MARK: - Account Management

extension DatabaseManager {
    
    /// Checking for duplicate emails
    // The functions to get data out of the database are asyncronous, therefore we need a completion block.
    // Will return true if the user email already exists.
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        // Get safe email
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // Observe value changes on entry related to the specified child you want to observe changes for.
        // We are observing a single event, which means we are asking the database only once.
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                // Called when email does not already exist.
                completion(false)
                return
            }
            
            // If we found an email we get to this point and return true to signal that the email already exists.
            completion(true)
        })
    }
    
    /// Insert user into database. Completion handler in order to alert caller when the function is done. If returns true, then we have successfully created new user and written to database.
    public func insertUser(with user: RaceAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            completion(true)
        })
    }
}
