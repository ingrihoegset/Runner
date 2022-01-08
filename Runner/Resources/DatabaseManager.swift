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
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]  {
                    // User array exists, so append new user to collection
                    let newUser = [
                        "first_name": user.firstName,
                        "last_name": user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newUser)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    // Create user array
                    let newCollection: [[String: String]] = [
                        [
                            "first_name": user.firstName,
                            "last_name": user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            
            
            
            // Create matching data for security purposes for firebase rules
            
            self.database.child("matches").observeSingleEvent(of: .value, with: { snapshot in
                if var matches = snapshot.value as? [String: String]  {
                    // User array exists, so append new user to collection
                    matches[user.safeEmail] =  user.userID
                    
                    self.database.child("matches").setValue(matches, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Error: Setting match value failed.")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                // No match array exists
                else {
                    // Create match array
                    var matches = [String: String]()
                    matches[user.safeEmail] = user.userID
                    self.database.child("matches").setValue(matches, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Error: Setting up matches array failed.")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }

    
    
    // MARK: - Linking with Partner
    
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
            UserDefaults.standard.setValue(nil, forKey: "partnerEmail")
            
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
    
    ///Delete value at a given database path
    func deleteAllValuesAtPath(path: String, completion: @escaping (Bool) -> Void) {
        
        let reference = database.child(path)
        reference.removeValue(completionBlock: { error, _ in
            if let error = error {
                print("Failed to remove value from database \(error)")
                completion(false)
            }
            else {
                print("Successfully removed value from database")
                completion(true)
            }
        })
    }

    /// Registers current run to user and partner user
    func registerCurrentRunToDatabase(time: Double, runType: String, runDate: String, runDistance: Int, userIsRunning: Bool, with completion: @escaping (Bool) -> Void) {
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register run ID to database.")
            completion(false)
            return
        }
        
        // Find units of run
        var metricSystem = true
        if let selectedSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if selectedSystem == false {
                metricSystem = false
            }
        }

        // Create run ID
        let runID = createRunID()
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Set run ID for our user
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)")
        
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found when trying to register current run ID to database")
                return
            }
            
            let times: [Double] = [time]
            
            // Data for insertion for our use
            let currentRun: [String: Any] = [
                "run_id": runID,
                "start_time": time,
                "run_type": runType,
                "run_date": runDate,
                "run_distance": runDistance,
                "user_is_running": userIsRunning,
                "metric_system": metricSystem,
                "times": times
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
            
            // If there is a partner user, update current run in database for partner user
            if let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String {
                
                let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)
            
                let times: [Double] = [time]
                
                // Data for insertion for partner user
                let partnerCurrentRun: [String: Any] = [
                    "run_id": runID,
                    "start_time": time,
                    "run_type": runType,
                    "run_date": runDate,
                    "run_distance": runDistance,
                    "user_is_running": !userIsRunning,
                    "metric_system": metricSystem,
                    "times": times
                ]
                
                // Create partner link entry
                self?.database.child("\(partnerSafeEmail)/current_run").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    self?.database.child("\(partnerSafeEmail)/current_run").setValue(partnerCurrentRun)
                })
                completion(true)
            }
            // No partner, complete task
            else {
                completion(true)
            }
        })
    }
    
    /// Creates run ID
    func createRunID() -> String {
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            let dateString = Self.dateFormatter.string(from: Date())
            let identifier = "\(dateString)"
            return identifier
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let identifier = "\(safeEmail)_\(dateString)"
        
        return identifier
    }
    
    /// Sends time timestamp (MUST IMPLEMENT LOGIC FOR BOOL)
    // Registers time to both user and partners current run
    func sendTime(time: Double, endTime: Bool, completion: @escaping (Bool) -> Void) {
        
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
            
            guard let strongSelf = self else {
                completion(false)
                return
            }
            
            // Get current run node for user
            guard var currentRunNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("Current run not found when attempting to get run ID")
                return
            }
            
            if endTime == true {
                currentRunNode["ended"] = true
            }
            
            // Append new registered time to times array
            guard var allRunTimes = currentRunNode["times"] as? [Double] else {
                completion(false)
                print("Times rray not as expected")
                return
            }
            allRunTimes.append(time)
            currentRunNode["times"] = allRunTimes

            // Save updated node to database
            reference.setValue(currentRunNode, withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed when updating array of runs for our user.")
                    completion(false)
                    return
                }
            })
            
            // Step 2: If there is a partner user, update en time for partner user current run
            if let partnerEmail = UserDefaults.standard.value(forKey: "partnerEmail") as? String {
                
                // Get safe email version of emails.
                let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)
                
                // Create path reference for database
                let partnerReference = strongSelf.database.child("\(partnerSafeEmail)/current_run")
                
                partnerReference.observeSingleEvent(of: .value, with: { snapshot in

                    // Get current run node for user
                    guard var partnerCurrentRunNode = snapshot.value as? [String: Any] else {
                        completion(false)
                        print("Current run not found when attempting to get run ID")
                        return
                    }
                    
                    // Append end time
                    if endTime == true {
                        partnerCurrentRunNode["ended"] = true
                    }

                    // Append new registered time to times array
                    guard var allRunTimes = partnerCurrentRunNode["times"] as? [Double] else {
                        completion(false)
                        print("Times rray not as expected")
                        return
                    }
                    allRunTimes.append(time)
                    partnerCurrentRunNode["times"] = allRunTimes
                    
                    // Save updated node to database
                    partnerReference.setValue(partnerCurrentRunNode, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Failed when updating array of runs for our user.")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                })
            }
            // No partner, complete task
            else {
                completion(true)
            }
        })
    }

    /// Function that listens for if an end time has been uploaded to current race.
    func listenForEndOfCurrentRun(completion: @ escaping (Bool) -> Void) {

        print("Listening for end time")
        
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register end time to database.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Step 2: Get the path where the end time appears
        let reference = database.child("\(userSafeEmail)/current_run/ended")
        
        // Step 3: Set listener end time
        reference.observe(.value, with: { snapshot in
            
            // End time value is no-nil, so this mean run has completed
            guard let ended = snapshot.value as? Bool else {
                print("Could not find end bool")
                // Something went wrong unwrapping
                completion(false)
                return
            }
            
            if ended == true {
                // Successfully observed an end time.
                print("Successfully observed an end time")
                completion(true)
            }
        })
    }
    
    // Removes listener for end of run
    func removeEndOfRunListener() {
        print("Removed end of run listener")
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register end time to database.")
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Step 2: Get the path where the end time appears
        let reference = database.child("\(userSafeEmail)/current_run/ended")
        
        reference.removeAllObservers()
    }
    
    /// Function saves current run to completed run and deletes current run from current run
    // Only needs to clean up after user because function is called when a race end time is observed. Both user and partner
    // have functions in place that listen for an end time.
    // Check if our user is the one who ran, if so, run should be saved in completed runs. If not, discard run.
    func cleanUpAfterRunCompleted(completion: @ escaping (Bool) -> Void) {
        
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to save run to users array of runs.")
            completion(false)
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child(userSafeEmail)
        
        reference.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                print("Something went wrong when trying to save ended race.")
                completion(false)
                return
            }
            
            guard let currentRun = userNode["current_run"] as? [String: Any] else {
                print("Couldnt get current run")
                completion(false)
                return
            }
            
            // Get bool value of whether user is running or not
            guard let userIsRunning = currentRun["user_is_running"] as? Bool else {
                print("Couldnt get Bool-value of runner")
                completion(false)
                return
            }
            
            // Check if user is running, if so, save run to completed runs, if not, discard run
            if userIsRunning == true {
                
                // Step 2: Update completed runs array
                // If true - means that array of runs already exists - append to array
                if var completedRuns = userNode["completed_runs"] as? [[String: Any]] {
                    completedRuns.append(currentRun)
                    userNode["completed_runs"] = completedRuns
                }
                // Else, there is no existing completed runs array, so create one
                else {
                    userNode["completed_runs"] = [
                        currentRun
                    ]
                }
            }
            
            // Step 3: Delete current run
            userNode["current_run"] = nil
            
            // Update database with changes
            reference.setValue(userNode, withCompletionBlock: { error, _ in
                print("setting user values in completed")
                guard error == nil else {
                    print("Failed to set completed run array first time.")
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
    
    /// Function is intended to check if there is a current race under user node. If there is, first and second gate viewmodel must execute functions for observing a break when appropriate.
    // If the current run id is nil, the camera should stop looking for breaks.
    func currentRunOngoing(completion: @escaping (Bool) -> Void) {
        
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            print("Failed to get user email when attempting to listen for whether or not there is a current run")
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        let reference = database.child("\(safeEmail)/current_run/start_time")
        
        // This code fires every time reference path changes
        reference.observe(.value, with: { snapshot in
            print("current run id child changed")
            if !snapshot.exists() {
                print("No current run. Stopped recording")
                completion(false)
                return
            }
            else {
                print("Found current run. Started recording")
                completion(true)
            }
        })
    }
    
    func removeCurrentRunOngoingListener() {
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Failed to get user email when attempting to listen for whether or not there is a current run")
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        let reference = database.child("\(safeEmail)/current_run/start_time")
        
        print("Removed current run listener")
        reference.removeAllObservers()
    }
    
    func getCurrentRunData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to save run to users array of runs.")
            completion(.failure(DataBaseErrors.failedToFetch))
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        // Create path reference for database
        let reference = database.child("\(userSafeEmail)/current_run")
        
        reference.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                print("No data found")
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            
            guard let runData = snapshot.value as? [String: Any] else {
                print("Failed to unwrap times.")
                //completion(.failure(DataBaseErrors.failedToFetch))
                return
            }

            completion(.success(runData))
        })
    }
    
    /// This function removes the current run node from both users
    func removeCurrentRun(completion: (Bool) -> Void) {
        
        print("removing run")

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
            completion(true)
            return
        }
        
        let partnerSafeEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)
        
        let partnerReference = database.child("\(partnerSafeEmail)/current_run")
        
        // Remove current run from partner
        partnerReference.removeValue()

        completion(true)
    }
}


// MARK: - Functions related to statistics

extension DatabaseManager {
    
    public func getAllCompletedRuns(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        
        // Step 1: Get user
        guard let userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("No user email found when trying to register end time to database.")
            completion(.failure(DataBaseErrors.failedToFetch))
            return
        }
        
        // Get safe email version of emails.
        let userSafeEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        
        database.child("\(userSafeEmail)/completed_runs").observe( .value, with: { snapshot in
            
            guard let completedRuns = snapshot.value as? [[String: Any]] else {
                completion(.failure(DataBaseErrors.failedToFetch))
                return
            }
            completion(.success(completedRuns))
            return
        })
    }
    
    public func deleteRun(runID: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        
        print("Deleting conversation with id: \(runID)")
        
        // Get all runs for current user
        // Delete the conversation with the given run ID
        // Reset the runs for the user
        
        let ref = database.child("\(safeEmail)/completed_runs")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var runs = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for run in runs {
                    if let id = run["run_id"] as? String,
                       id == runID {
                        print("Found run to delete.")
                        break
                    }
                    positionToRemove += 1
                }
                
                runs.remove(at: positionToRemove)
                ref.setValue(runs, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("Failed to write new run array")
                        return
                    }
                    print("Deleted run")
                    completion(true)
                })
            }
        })
    }
    
    public func getAllSimilarRuns(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        
        print("Getting all runs on type")
        
        // Get all runs for current user
        // Sort out runs of identical type
        // Put these in an array for presentation
        
        let ref = database.child("\(safeEmail)/completed_runs")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let runs = snapshot.value as? [[String: Any]] {
                completion(.success(runs))
            }
            else {
                completion(.failure(DataBaseErrors.failedToFetch))
            }
        })
    }
}

