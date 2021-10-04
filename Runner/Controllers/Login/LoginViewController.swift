//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//


// Created custom FB login button. If something fails with this, remove commenting out related to fbloginbutton.

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Constants.accentColorDark
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome!"
        label.font = Constants.mainFontXLargeSB
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.smallCornerRadius
        field.font = Constants.mainFontLarge
        field.placeholder = "Email Address..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = Constants.accentColor
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.font = Constants.mainFontLarge
        field.layer.cornerRadius = Constants.smallCornerRadius
        field.placeholder = "Password..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = Constants.accentColor
        field.isSecureTextEntry = true
        return field
    }()
    
    private let logginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = Constants.contrastColor
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    /*
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.layer.cornerRadius = Constants.mainButtonSize / 2
        button.backgroundColor = Constants.mainColor
        button.translatesAutoresizingMaskIntoConstraints = false
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        button.permissions = ["public_profile", "email"]
        return button
    }()*/
    
    private let orLogInLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "- or, sign in with -"
        label.font = Constants.mainFont
        label.textColor = Constants.accentColorDark
        label.textAlignment = .center
        return label
    }()
    
    private let customFBLoginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.addTarget(self, action: #selector(customFBLoginButtonTapped(_:)), for: .touchUpInside)
        button.layer.cornerRadius = Constants.mainButtonSize / 2
        let image = UIImage(named: "Facebook_F")?.withTintColor(UIColor(named: "Facebook_Blue") ?? UIColor.link)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(image, for: .normal)
        return button
    }()
    
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        return button
    }()
    
    private var googleLoginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Makes the nav bar blend in with the background
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = Constants.mainColor
        
        googleLoginObserver = NotificationCenter.default.addObserver(forName: .didGoogleLoginNotification,
                                                                     object: nil,
                                                                     queue: .main,
                                                                     using: { [weak self] _ in
                                                                        guard let strongSelf = self else {
                                                                            return
                                                                        }
                                                                        
                                                                        strongSelf.prepareTabBar()
                                                                     })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        view.backgroundColor = Constants.mainColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        navigationItem.rightBarButtonItem?.tintColor = Constants.accentColorDark
        
        emailField.delegate = self
        passwordField.delegate = self
        // fbLoginButton.delegate = self
        
        /// Adding subviews
        view.addSubview(imageView)
        view.addSubview(welcomeLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(orLogInLabel)
        view.addSubview(logginButton)
        
        // Facebook login button
        // view.addSubview(fbLoginButton)
        
        // Custom Facebook login button
        view.addSubview(customFBLoginButton)
        
        // Google login button
        view.addSubview(googleLoginButton)
        
        // Present welcome animation
        presentWelcome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Check if user is logged in already
        validateAuth()
    }
    
    /// Removes login observer after login notification has fired. Just in order to save som memory.
    deinit {
        if let observer = googleLoginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Lay out constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        imageView.layer.cornerRadius = Constants.widthOfDisplay * 0.3 / 2
        
        welcomeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        welcomeLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        emailField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        logginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        logginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        logginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        logginButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        /*
        fbLoginButton.topAnchor.constraint(equalTo: logginButton.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        fbLoginButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        fbLoginButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        */
        
        orLogInLabel.topAnchor.constraint(equalTo: logginButton.bottomAnchor).isActive = true
        orLogInLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        orLogInLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        orLogInLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        googleLoginButton.topAnchor.constraint(equalTo: orLogInLabel.bottomAnchor).isActive = true
        googleLoginButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: Constants.sideMargin).isActive = true
        googleLoginButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        customFBLoginButton.topAnchor.constraint(equalTo: orLogInLabel.bottomAnchor).isActive = true
        customFBLoginButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        customFBLoginButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -Constants.sideMargin).isActive = true
        customFBLoginButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
    }
    
    /// Present Welcome text with animation
    func presentWelcome() {
        UIView.animate(withDuration: 1) {
            self.welcomeLabel.alpha = 1
        }
    }
    
    /// Makes Buttons blink dark blue on click
    @objc func holdDown(sender:UIButton){
        sender.backgroundColor = Constants.accentColorDark
    }
    
    @objc func release(sender:UIButton){
        sender.backgroundColor = Constants.contrastColor
    }
    
    /// When user taps to register new user, send user to register view controller
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// When user taps log in button
    @objc private func loginButtonTapped() {
        
        //Think this gets rid of the keyboard when log in is tapped, regardless of where the cursor is at the given moment
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        //Checks if email field or password field is empty and that password is longer than or equal to 8. If empty, show warning to user.
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            // Saving this users email locally
            UserDefaults.standard.set(email, forKey: "email")

            // Checking for error during login. If error is discover, return.
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            // Getting user first name and last name and saving it to user defaults
            let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataForPath(path: safeEmail, completion: { [weak self] result in
                switch result {
                // Succeeded in getting user name. Proceed to generate views
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    print("Logged in user: \(user)")
                    // Stopping spinner
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    self?.prepareTabBar()
                    self?.clearTextFields()
                // Failed to get user name. Proceed to generate views with empty name.
                case .failure(let error):
                    print("Failed to get user firstname and lastname with error \(error)")
                    UserDefaults.standard.setValue("No username found", forKey: "name")
                    print("Logged in user: \(user)")
                    // Stopping spinner
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    self?.prepareTabBar()
                    self?.clearTextFields()
                }
            })
        })
    }
    
    /// Alerts user if something is wrong with login inputs
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Whoops",
                                      message: "Please enter all information to log in. Password must be at least 8 characters.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    /// Alerts user if something is wrong with login inputs
    private func alertFBLoginError() {
        let alert = UIAlertController(title: "Whoops",
                                      message: "Something went wrong when attempting to log in with Facebook.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    /// Creates the Tab bar that will be presented on log in -- Make sure function is identical in RegisterVC
    private func prepareTabBar() {
        print("Preparing Tab Bar")
        
        let tabBarVC = UITabBarController()
        let tabButtonImages = ["Home", "Stats" ,"Settings"]
        
        tabBarVC.tabBar.barTintColor = Constants.textColorDarkGray
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = Constants.contrastColor
        tabBarVC.tabBar.unselectedItemTintColor = Constants.accentColor
        
        let home = HomeViewController()
        let navVC = UINavigationController(rootViewController: home)
        navVC.navigationBar.prefersLargeTitles = true
        navVC.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        navVC.navigationBar.tintColor = Constants.accentColorDark
        
        let stats = StatisticsViewController()
        let navVCStats = UINavigationController(rootViewController: stats)
        navVCStats.navigationBar.prefersLargeTitles = true
        navVCStats.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        navVCStats.navigationBar.tintColor = Constants.accentColorDark
        
        let profile = ProfileViewController()
        let navVCProfile = UINavigationController(rootViewController: profile)
        navVCProfile.navigationBar.prefersLargeTitles = true
        navVCProfile.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        navVCProfile.navigationBar.tintColor = Constants.accentColorDark
        
        tabBarVC.setViewControllers([navVC, navVCStats, navVCProfile], animated: false)
        
        guard let items = tabBarVC.tabBar.items else {
            return
        }
        
        for x in 0..<items.count {
            items[x].image = UIImage(named: tabButtonImages[x])
        }
        
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: false)
    }
    
    /// Function checks if user is logged in or not
    private func validateAuth() {
        // If there is no current user, send user to log in view controller
        // Current user is set automatically when you instantiate firebase auth, and log a user in.
        if FirebaseAuth.Auth.auth().currentUser != nil {
            self.prepareTabBar()
            // Make sure there is no lingering partner email
            UserDefaults.standard.setValue(nil, forKey: "partnerEmail")
        }
    }
    
    /// Related to Facebook login
    @objc private func customFBLoginButtonTapped(_ sender: Any) {
        
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            // Accesss token is available - user is already logged in
            // Preform log out
            
            loginManager.logOut()
        }
        else {
            // Access token is not available -- user already logged out
            // Perform log in
            self.spinner.show(in: view)
            
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
                
                // Checking for error
                guard error == nil else {
                    print(error?.localizedDescription)
                    return
                }
                
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("User cancelled login.")
                    // Stopping spinner
                    DispatchQueue.main.async {
                        self?.spinner.dismiss()
                    }
                    return
                }
                
                // Getting token from Facebook
                guard let token = result.token?.tokenString else {
                    print("User failed to log in with facebook")
                    return
                }
                
                // Getting user data from Facebook using the token (login result)
                let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                                 parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                                 tokenString: token,
                                                                 version: nil,
                                                                 httpMethod: .get)
                
                // Execute the request
                facebookRequest.start(completionHandler: { _, result, error in
                    guard let result = result as? [String: Any], error == nil else {
                        print("Failed to make facebook graph request.")
                        return
                    }
                    
                    // Unwrapping data from request
                    guard let firstName = result["first_name"] as? String,
                          let lastName = result["last_name"] as? String,
                          let picture = result["picture"] as? [String: Any],
                          let data = picture["data"] as? [String: Any],
                          let pictureUrl = data["url"] as? String,
                          let email = result["email"] as? String else {
                        print("Failed to get email and name from FB results.")
                        return
                    }
                    
                    // Saving this users email locally
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                    // Check if the user exists already. If not, we want to register a new user.
                    DatabaseManager.shared.userExists(with: email, completion: { exists in
                        if !exists {
                            // Insert user into database
                            let raceAppUser = RaceAppUser(firstName: firstName,
                                                          lastName: lastName,
                                                          emailAddress: email)
                            DatabaseManager.shared.insertUser(with: raceAppUser, completion: { success in
                                if success {
                                    
                                    // Must do this because url is optional
                                    guard let url = URL(string: pictureUrl) else {
                                        return
                                    }
                                    
                                    print("Downloading data from Facebook image.")
                                    
                                    URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                        guard let data = data else {
                                            print("Failed to get data from Facebook.")
                                            return
                                        }
                                        
                                        print("Got data from Facebook, uploading image to Firebase")
                                        
                                        // upload image
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
                            })
                        }
                    })
                    
                    // Trading token to get a Firebase credential
                    let credential = FacebookAuthProvider.credential(withAccessToken: token)
                    
                    // Signs user in with third party credentials
                    FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authresult, error in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        guard authresult != nil, error == nil else {
                            print("Facebook credential login failed, MFA may be required.")
                            // Stopping spinner
                            DispatchQueue.main.async {
                                strongSelf.spinner.dismiss()
                            }
                            self?.alertFBLoginError()
                            return
                        }
                        
                        print("Successfully logged user in.")
                        
                        // Stopping spinner
                        DispatchQueue.main.async {
                            strongSelf.spinner.dismiss()
                        }
                        
                        // Create tab navigation and go to tab bar
                        strongSelf.prepareTabBar()
                        strongSelf.clearTextFields()
                    })
                })
            }
        }
    }
    
    private func clearTextFields() {
        emailField.text?.removeAll()
        passwordField.text?.removeAll()
    }
}

/// Controls what happens when "return" is pressed inside a text field. Send to password if in the email field, calls "loginbuttontapped" if in password field.
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

/*
// Related to Facebook Login
extension LoginViewController: LoginButtonDelegate {
    
    /// What happens when log in button with facebook is tapped
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        spinner.show(in: view)
        
        // Getting token from Facebook
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        // Getting user data from Facebook using the token (login result)
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        // Execute the request
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request.")
                return
            }
            
            // Unwrapping data from request
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String,
                  let email = result["email"] as? String else {
                print("Failed to get email and name from FB results.")
                return
            }
            
            // Saving this users email locally
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            // Check if the user exists already. If not, we want to register a new user.
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    // Insert user into database
                    let raceAppUser = RaceAppUser(firstName: firstName,
                                                  lastName: lastName,
                                                  emailAddress: email)
                    DatabaseManager.shared.insertUser(with: raceAppUser, completion: { success in
                        if success {
                            
                            // Must do this because url is optional
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from Facebook image.")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from Facebook.")
                                    return
                                }
                                
                                print("Got data from Facebook, uploading image to Firebase")
                                
                                // upload image
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
                    })
                }
            })
            
            // Trading token to get a Firebase credential
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            // Signs user in with third party credentials
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authresult, error in
                guard let strongSelf = self else {
                    return
                }
                
                guard authresult != nil, error == nil else {
                    print("Facebook credential login failed, MFA may be required.")
                    // Stopping spinner
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    self?.alertFBLoginError()
                    return
                }
                
                print("Successfully logged user in.")
                
                // Stopping spinner
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                // Create tab navigation and go to tab bar
                strongSelf.prepareTabBar()
                strongSelf.clearTextFields()
            })
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    private func clearTextFields() {
        emailField.text?.removeAll()
        passwordField.text?.removeAll()
    }
}*/
