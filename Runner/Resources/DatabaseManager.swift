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
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
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
    
    /// Register in database that a link with a partner has occured. Must register under both users.
    // Really just need to hold 1 value in "links". There is no point in storing links that are not the current one.
    // Thus we can replace the old link when a new link is updated.
    public func registerLink(with partnerSafeEmail: String, completion: @escaping (Bool) -> Void) {
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when registering link")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerSafeEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)")
        
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found when trying to register link to database")
                return
            }
            
            // Data for insertion for our user
            let newLinkData: [String: Any] = [
                "gate_number": 1,
                "other_user_email": partnerSafeEmail
            ]

            // Register link for our user
            // Creating links array
            userNode["links"] = newLinkData
            
        
            reference.setValue(userNode, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    print("Failed to register first links for current user")
                    return
                }
            })
            
            // Data for insertion for partner user
            let partner_newLinkData: [String: Any] = [
                "gate_number": 2,
                "other_user_email": userSafeEmail
            ]
            
            // Create partner link entry
            self?.database.child("\(partnerSafeEmail)/links").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                self?.database.child("\(partnerSafeEmail)/links").setValue(partner_newLinkData)
            })
            completion(true)
        })
    }
    
    /// Used to clear the linked from database on close and log out.
    // We need to check for link. If there is a link, get partner.
    // Finally, delete link for current user and delete link for partner.
    func clearLinkFromDatabase(with completion: @escaping (Bool) -> Void) {
        
        // First step. Check if there is a link under our user in the database.
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when terminating partner link")
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Checking database for links. If guard statement fails, it means there is no link in database for user.
        database.child("\(userSafeEmail)/links").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let link = snapshot.value as? [String: Any] else {
                print("No link to delete from database")
                completion(true)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            // Step 2. If guard statement doesnt fail, we need to get the partner email.
            guard let partnerSafeEmail = link["other_user_email"] as? String else {
                print("Failed to unwrap partner email")
                return
            }
            
            // Step 3. Delete link from both our user and partner user.
            
            // Remove link from our user in database
            // Create path reference for database
            let reference = strongSelf.database.child("\(userSafeEmail)/links")
            reference.removeValue(completionBlock: { error, _ in
                guard error == nil else {
                    print("Error removing link from our user.")
                    completion(false)
                    return
                }
            })
            
            // Remove link from partner user in database
            strongSelf.database.child("\(partnerSafeEmail)/links").removeValue(completionBlock: { error, _ in
                guard error == nil else {
                    print("Error removing link from partner user.")
                    completion(false)
                    return
                }
            })
            // Successfully removed link from both our user and partner.
            completion(true)
        })
    }
    
    /// Observe if there is a change in users link
    // We are trying to observe when a link has occured
    // Sending the gate number so that the two phones will know which gate is gate 1 and which is gate 2.
    public func observeNewLink(completion: @escaping (Result<Int, Error>) -> Void) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No email found for user when trying to listen for links.")
            // Is it really necessary to call failure here? Call failure in next block when there is no data under links.
           // completion(.failure(DataBaseErrors.failedToFetch))
            return
        }
        
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: email)
        print("user email", userSafeEmail)
        
        let path = database.child("\(userSafeEmail)/links")
        path.observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("No value to get when link changed.")
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            print("value ", value)
            
            print("Observed change in link")
            
            guard let partnerSafeEmail = value["other_user_email"] as? String else {
                print("Could not unwrap partner email when link updated")
                return
            }
            
            // Got partner email from database, save the value to userdefaults for access across the app.
            UserDefaults.standard.setValue(partnerSafeEmail, forKey: "partnerEmail")
            
            // Get gatenumber from snapshot.
            guard let gateNumber = value["gate_number"] as? Int else {
                print("Unable to get gateNumber.")
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            
            // Successfully listened to update in link
            completion(.success(gateNumber))
        })
    }
    
    public enum DataBaseErrors: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "Fail to fetch data from database"
            }
        }
    }
}

// MARK: - Functions related to manageing runs, runtimes etc.

extension DatabaseManager {
    
    // Generates unique run ID
    func createRunID(userSafeEmail: String, partnerSafeEmail: String) -> String {
        let dateString = Self.dateFormatter.string(from: Date())
        let identifier = "\(userSafeEmail)_\(partnerSafeEmail)_\(dateString)"
        return identifier
    }
    
    /// Registers run ID for our user, partner user and creates a seperate run node.
    func registerCurrentRunToDatabase(with completion: @escaping (Bool) -> Void) {
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register run ID to database.")
            completion(false)
            return
        }
        
        guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
            print("No partner email found when trying to register run ID to database.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)
        
        // Get unique run ID
        let runID = createRunID(userSafeEmail: userSafeEmail, partnerSafeEmail: partnerSafeEmail)
        
        // Set run ID for our user
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)")
        
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found when trying to register current run ID to database")
                return
            }
            
            // Data for insertion for our use
            let currentRun: [String: Any] = [
                "current_run_id": runID,
                "start_time": 123
            ]

            userNode["current_run"] = currentRun
            
            // Update database
            reference.setValue(userNode, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    print("Failed to add run ID to our user in database")
                    return
                }
            })
        
            // Set run ID for partner user
            // Data for insertion for our use
            let partnerCurrentRun: [String: Any] = [
                "current_run_id": runID,
                "start_time": 123
            ]
            
            // Create partner link entry
            self?.database.child("\(partnerSafeEmail)/current_run").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                self?.database.child("\(partnerSafeEmail)/current_run").setValue(partnerCurrentRun)
            })
            
            // Create run ID node
            self?.database.child("run").setValue([
                "run_id": runID
            ], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to add run node to database")
                    completion(false)
                    return
                }
            })
            completion(true)
        })
    }
}
