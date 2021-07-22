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
            guard snapshot.value as? [String: Any] != nil else {
                // Called when email does not already exist.
                completion(false)
                return
            }
            
            // If we found an email we get to this point and return true to signal that the email already exists.
            completion(true)
        })
    }
    
    /// Returns data for a given database path
    func getDataForPath(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
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
    public func listenForNewLink(completion: @escaping (Result<Int, Error>) -> Void) {
        
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
            
            print("gatenumber", gateNumber)
            
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
    
    
    /// Generates unique run ID
    func createRunID(userSafeEmail: String, partnerSafeEmail: String) -> String {
        let dateString = Self.dateFormatter.string(from: Date())
        let identifier = "\(userSafeEmail)_\(partnerSafeEmail)_\(dateString)"
        return identifier
    }
    
    /// Function that listens for the run id. We need it to be able to listen for an end time at the right run node.
    // Whenever a new run is created, a new current run ID is created. We need to create a listener on the run node with this run id.
    // At the end of the function we use the run id we got to create a listener on that run id. This so we can observe changes to end time.
    func listenForCurrentRunID(completion: @escaping (Result<[String: Any], Error>) -> Void)  {
        
        // Step 1: Get current run id for user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register start time database.")
            completion(.failure(DataBaseErrors.failedToFetch))
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)/current_run")
        
        // Get snapshot of vaue at given path
        // The code that is in this closure is the code that is run whenever the database changes at this path.
        // Must create a listener on the run id node as well when the closure is called, so that we can listen for updates to end time.
        
        // Here we are listening to the current run path.
        reference.observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            // When a change occurs, we get the value at the current run path
            guard let currentRun = snapshot.value as? [String: Any] else {
                completion(.failure(DataBaseErrors.failedToFetch))
                print("Current run not found when attempting to get run ID")
                return
            }
            
            // Then we retreive the run id for the current run
            guard let runID = currentRun["current_run_id"] as? String else {
                completion(.failure(DataBaseErrors.failedToFetch))
                print("Could not unwrapp run id to string")
                return
            }
            
            // Then we create a listener for this run node. We need to listen to the run node because the start and end times are linked to this node.
            strongSelf.listenForEndOfCurrentRun(currentRunID: runID, with: { success in
                if success {
                    // There was an update in the end time if success. Thus, we can get array of times.
                    strongSelf.getAllTimes(currentRunID: runID, completion: { result in
                        switch result {
                        case .success(let times):
                            print(times)
                            completion(.success(times))
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    })
                }
                else {
                    print("Failed to create listener for end time")
                    completion(.failure(DataBaseErrors.failedToFetch))
                }
            })
        })
    }

    /// Registers run ID for our user, partner user and creates a seperate run node.
    func registerCurrentRunToDatabase(runType: String, runDate: String, runDistance: Int, with completion: @escaping (Bool) -> Void) {
        
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
            ]
            
            // Create partner link entry
            self?.database.child("\(partnerSafeEmail)/current_run").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                self?.database.child("\(partnerSafeEmail)/current_run").setValue(partnerCurrentRun)
            })
            
            // Create run ID node. And set 
            self?.database.child(runID).setValue([
                "run_type": runType,
                "run_date": runDate,
                "run_distance": runDistance
            ], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to add run node to database")
                    completion(false)
                    return
                }
            })
            
            // Registering current run ID to database succeeded, Save run ID locally.
            UserDefaults.standard.setValue(runID, forKey: Constants.currentRunID)
            
            completion(true)
        })
    }
    
    /// Sends start time timestamp when run begins
    // Function works by getting the current run id from our user and then using this id
    // to find the correct path to set the start time for the run.
    func sendStartTime(with startTime: Double, completion: @escaping (Bool) -> Void) {
        
        // Step 1: Get current run id for user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register start time database.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)/current_run")
        
        // Get snapshot of vaue at given path
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("Current run not found when attempting to get run ID")
                return
            }
            
            // This is the ID for our run node
            guard let runID = userNode["current_run_id"] as? String else {
                completion(false)
                print("Could not unwrapp run id to string")
                return
            }
        
            // Step 2: Set start time under run node
            self?.database.child(runID).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                self?.database.child("\(runID)/start_time").setValue(startTime)
            })
            completion(true)
        })
    }
    
    /// Send end time of run signalling that someone has passed the gate
    func sendEndTime(with endTime: Double, completion: @escaping (Bool) -> Void) {
        
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register end time to database.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)/current_run")
        
        // Get snapshot of vaue at given path
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            guard let userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("Current run not found when attempting to get run ID")
                return
            }
            
            // This is the ID for our run node
            guard let runID = userNode["current_run_id"] as? String else {
                completion(false)
                print("Could not unwrap run id to string")
                return
            }
        
            // Step 2: Set end time under run node
            strongSelf.database.child(runID).observeSingleEvent(of: .value, with: { snapshot in
                strongSelf.database.child("\(runID)/end_time").setValue(endTime)
            })
            
            // Step 3: Run is completed. Clean up after this run
            strongSelf.runIsCompleted(completion: { success in
                if success {
                    print("Removed current run id after race")
                }
                else {
                    print("Failed to remove current run id after race")
                }
            })
            completion(true)
        })
    }
    
    /// Function that listens for if an end time has been uploaded to current race.
    // This listener must be created each time a new run id is created so that it listens to the correct ID.
    // It only needs to listen once, for when the end time is changed.
    func listenForEndOfCurrentRun(currentRunID: String, with completion: @ escaping (Bool) -> Void) {
        
        // Step 1: Get recently created run ID, an find end time node.
        let reference = database.child("\(currentRunID)/end_time")
        
        // Step 2: Set opp listener for change in end time
        reference.observe(.value, with: { [weak self] snapshot in
            
            guard snapshot.value as? Double != nil else {
                print("No end time exists yet.")
                // This is fine. Should happen every time a new listener is created (each time a new run is created)
                completion(false)
                return
            }
            
            // End time value is no-nil, so this mean run has completed
            guard let endTime = snapshot.value as? Double else {
                print("Could not unwrap snapshot value to double.")
                // Something went wrong unwrapping
                completion(false)
                return
            }
            
            // Successfully observed an end time.
            print("Successfully observed an end time: ", endTime)
            completion(true)
        })
    }
    
    /// Function is intended to check if there is a current race under user node. If there is, the isRunning boolean should be true so that the camera knows it should look for breaks.
    // If the current run id is nil, the camera should stop looking for breaks.
    func currentRunOngoing(completion: @escaping (Bool) -> Void) {
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            print("Failed to get user email when attempting to listen for whether or not there is a current run")
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        let reference = database.child("\(safeEmail)/current_run")
        
        // This code fires every time reference path changes
        reference.observe(.value, with: { snapshot in
            print("current run id child changed")
            if !snapshot.exists() {
                print("No current run. Stopped recording")
                Constants.isRunning = false
                completion(false)
                return
                
            }
            else {
                print("Found current run. Started recording")
                Constants.isRunning = true
            }
        })
        completion(true)
    }
    private func getAllTimes(currentRunID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        // Step 1: Get current run ID
        let reference = database.child(currentRunID)
        
        reference.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                print("No times found")
               // completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            
            guard let times = snapshot.value as? [String: Any] else {
                print("Failed to unwrap times.")
                //completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            
            print("returning times: ", times)
            completion(.success(times))
        })
    }
    
    func deleteCurrentRun(completion: @escaping (Bool) -> Void) {
        
        // Remove current run from database
        guard let currentRunID = UserDefaults.standard.value(forKey: Constants.currentRunID) as? String else {
            print("No current run found when attempting to remove current run.")
            completion(false)
            return
        }
        
        let currentRunIDreference = database.child(currentRunID)
        
        // Remove run node from database
        
        currentRunIDreference.removeValue()
        currentRunIDreference.removeAllObservers()
        
        // Removes run id from users
        runIsCompleted(completion: { success in
            if success {
                print("Removed current run ID from users")
            }
            else {
                print("Failed to remove run ID from users")
            }
        })
    }
    
    /// This function is meant to tidy up after a race has been completed, so that there is no current run id if there is no active run.
    func runIsCompleted(completion: (Bool) -> Void) {
        
        // Step 1: Get user som that we can remove current run from our user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register end time to database.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)/current_run")
        
        // Remove current run from our user
        reference.removeValue()
        
        // Step 2: Get partner email som that we can remove current run from partner user
        guard let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String else {
            print("No partner email found when trying to remove current run from database")
            completion(false)
            return
        }
        
        let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)
        
        let partnerReference = database.child("\(partnerSafeEmail)/current_run")
        
        // Remove current run from partner
        partnerReference.removeValue()
        
        // Step 3: Remove listener from current run
        guard let currentRunID = UserDefaults.standard.value(forKey: Constants.currentRunID) as? String else {
            print("No current run found when attempting to remove current run.")
            completion(false)
            return
        }
        
        let currentRunIDreference = database.child(currentRunID)
        
        // Remove run node from database
        currentRunIDreference.removeAllObservers()
        
        // Step 3: Reset current run id to nil in user defaults
        UserDefaults.standard.setValue(nil, forKey: Constants.currentRunID)
        completion(true)
    }
}
