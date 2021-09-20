//
//  RegisterViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Constants.accentColorDark
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Constants.accentColor
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = Constants.mainFontLarge
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.smallCornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "Email Address..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = Constants.accentColor
        return field
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = Constants.mainFontLarge
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.smallCornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "First name..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = Constants.accentColor
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = Constants.mainFontLarge
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.smallCornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "Last name..."
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
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
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
        button.setTitle("Register", for: .normal)
        button.backgroundColor = Constants.contrastColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        
        // Makes the nav bar blend in with the background
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Constants.accentColorDark
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        /// Adding subviews
        view.addSubview(imageView)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(logginButton)
    }
    
    /// Lay out constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        imageView.layer.cornerRadius = Constants.widthOfDisplay * 0.3 / 2
        
        firstNameField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        firstNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        firstNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        lastNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        lastNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        logginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Constants.verticalSpacingSmall).isActive = true
        logginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        logginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        logginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func clearTextFields() {
        firstNameField.text?.removeAll()
        lastNameField.text?.removeAll()
        emailField.text?.removeAll()
        passwordField.text?.removeAll()
    }
    
    /// Makes Buttons blink dark blue on click
    @objc func holdDown(sender:UIButton){
        sender.backgroundColor = Constants.accentColorDark
    }
    
    @objc func release(sender:UIButton){
        sender.backgroundColor = Constants.contrastColor
    }
    
    /// When user taps image view to set profile pic
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    /// When user taps log in button
    @objc private func registerButtonTapped() {
        
        //Think this gets rid of the keyboard when log in is tapped, regardless of where the cursor is at the given moment
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        //Checks if email field or password field is empty and that password is longer than or equal to 8. If empty, show warning to user.
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 8
        else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Log In
        
        /// Check if user already exists. If not, create new user.
        // Exists is the boolean for our completion handler.
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
                
            // CASE: User already exists
            guard !exists else {
                strongSelf.alertUserLoginError(message: "Looks like a user account for that email already exists.")
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                return
            }
            
            // CASE: User does not already exist
            /// Firebase log in. Creating a new user in Firebase
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                // checks if returns an error, if so return.
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    return
                }
                
                // cache values related to user
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                // Make sure there is no lingering partner email
                UserDefaults.standard.setValue(nil, forKey: "partnerEmail")
                
                // Insert user into database with properties given in text fields
                let raceAppUser = RaceAppUser(firstName: firstName,
                                              lastName: lastName,
                                              emailAddress: email)
                DatabaseManager.shared.insertUser(with: raceAppUser, completion: { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let filename = raceAppUser.profilePictureFileName
                        
                        // Upload profile picture to Firebase
                        StorageManager.shared.uploadProfilPicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                // Open tabbar if all succeeds.
                                strongSelf.prepareTabBar()
                                strongSelf.clearTextFields()
                                DispatchQueue.main.async {
                                    strongSelf.spinner.dismiss()
                                }
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                                // Open tabbar even if image upload fails
                                strongSelf.prepareTabBar()
                                strongSelf.clearTextFields()
                                DispatchQueue.main.async {
                                    strongSelf.spinner.dismiss()
                                }
                            }
                        })
                    }
                })
            })
        })
    }
    
    /// Creates the Tab bar that will be presented on log in -- Make sure function is identical in RegisterVC
    private func prepareTabBar() {
        let tabBarVC = UITabBarController()
        let tabButtonImages = ["Home", "Stats" ,"Settings"]
        
        tabBarVC.tabBar.barTintColor = Constants.textColorDarkGray
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = Constants.contrastColor
        tabBarVC.tabBar.unselectedItemTintColor = Constants.accentColor
        
        let home = HomeViewController()
        home.title = ""
        let navVC = UINavigationController(rootViewController: home)
        navVC.navigationBar.prefersLargeTitles = true
        navVC.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        navVC.navigationBar.tintColor = Constants.accentColorDark
        
        let stats = StatisticsViewController()
        stats.title = "My Runs"
        let navVCStats = UINavigationController(rootViewController: stats)
        navVCStats.navigationBar.prefersLargeTitles = true
        navVCStats.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorDarkGray]
        navVCStats.navigationBar.tintColor = Constants.accentColorDark
        
        let profile = ProfileViewController()
        profile.title = "Settings"
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
    
    
    /// Alerts user if something is wrong with login inputs
    private func alertUserLoginError(message: String = "Please enter all information to create a new account. Password must be at least 8 characters.") {
        let alert = UIAlertController(title: "Whoops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
}

/// Controls what happens when "return" is pressed inside a text field. Send to password if in the email field, calls "registerButtontapped" if in password field.
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

/// All code assosiated with selecting a profile picture
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Called when user cancels the taking of a picture
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Called when user takes a photo or selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
    }
    
    /// Creates an action sheet that allows the user to pick whether to take a photo or select a photo from library
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture for your profile?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .default,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .cancel,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}
