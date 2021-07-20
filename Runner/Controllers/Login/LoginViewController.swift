//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .orange
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.cornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "Email Address..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = Constants.cornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "Password..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        field.isSecureTextEntry = true
        return field
    }()
    
    private let logginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        return button
    }()
    
    private var googleLoginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleLoginObserver = NotificationCenter.default.addObserver(forName: .didGoogleLoginNotification,
                                                                     object: nil,
                                                                     queue: .main,
                                                                     using: { [weak self] _ in
                                                                        guard let strongSelf = self else {
                                                                            return
                                                                        }
                                                                        
                                                                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                                                     })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log in"
        view.backgroundColor = .link
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        /// Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(logginButton)
        
        // Facebook login button
        scrollView.addSubview(fbLoginButton)
        
        // Google login button
        scrollView.addSubview(googleLoginButton)
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
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                  y: 20,
                                  width: size,
                                  height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: Constants.fieldHeight)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+10,
                                  width: scrollView.width-60,
                                  height: Constants.fieldHeight)
        
        logginButton.frame = CGRect(x: Constants.sideSpacing,
                                 y: passwordField.bottom + 10,
                                 width: scrollView.width - Constants.sideSpacing * 2,
                                 height: Constants.fieldHeight)
        
        fbLoginButton.frame = CGRect(x: Constants.sideSpacing,
                                 y: logginButton.bottom + 20,
                                 width: scrollView.width - Constants.sideSpacing * 2,
                                 height: Constants.fieldHeight)
        
        googleLoginButton.frame = CGRect(x: Constants.sideSpacing,
                                 y: fbLoginButton.bottom + 10,
                                 width: scrollView.width - Constants.sideSpacing * 2,
                                 height: Constants.fieldHeight)
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
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }

            // Checks for error. If error is discover, return.
            guard let result = authResult, error == nil else {
                
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            // Getting user first name and last name and saving it to user defaults
            let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataForPath(path: safeEmail, completion: { [weak self] result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String else {
                    return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to get user firstname and lastname with error \(error)")
                }
            })
            
            // Saving this users email locally
            UserDefaults.standard.set(email, forKey: "email")
            
            
            print("Logged in user: \(user)")
            
            // Dissmiss vc if user authentication succeeds
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
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


extension LoginViewController: LoginButtonDelegate {
    
    // What happens when log in button with facebook is tapped
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
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
                    return
                }
                
                print("Successfully logged user in.")
                // Dismiss navigation controller to lead us to main page
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    
}
