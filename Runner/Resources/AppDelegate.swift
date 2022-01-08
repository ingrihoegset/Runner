//
//  AppDelegate.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var tabBarController: UITabBarController?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
          
        // So screen can enter auto lock mode.
        UIApplication.shared.isIdleTimerDisabled = false
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self

        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Failed to sign in with Google: \(error)")
            }
            return
        }
        
        guard let user = user else {
            return
        }
        
        print("Did sign in with Google: \(user)")
        
        // Get profile data from user object
        guard let email = user.profile.email,
              let firstName = user.profile.givenName,
              let lastName = user.profile.familyName else {
                return
        }
        
        // Saving this users email locally
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        
        // Check if email already exists in database. If not, create new user in database.
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                // Insert in to database
                let raceAppUser = RaceAppUser(firstName: firstName,
                                              lastName: lastName,
                                              emailAddress: email,
                                              userID: user.userID)
                DatabaseManager.shared.insertUser(with: raceAppUser, completion: { success in
                    if success {
                        // upload image
                        
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                
                                let filename = raceAppUser.profilePictureFileName
                                
                                // Upload profile picture to Firebase
                                StorageManager.shared.uploadProfilPicture(with: data, fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume() // Tells the URL data task to begin...
                        }
                    }
                })
            }
        })
        
        // Trade access token from Google for a Firebase credential
        guard let authentication = user.authentication else {
            print("Missing Auth object off of Google user")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Use Firebase Auth to sign user in to Firebase session
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("Failed to log in to Firebase session with Google credentials.")
                return
            }
            print("Successfully logged in with Google credential.")
            // Notify Login VC that login was successful in order to dismiss login view.
            NotificationCenter.default.post(name: .didGoogleLoginNotification, object: nil)
        })
    }
    
    // Called when user logs out
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

    

