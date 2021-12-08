//
//  RegisterViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    private let slantedView: SlantedViewBottom = {
        let view = SlantedViewBottom()
        view.backgroundColor = Constants.contrastColor
        //view.image = UIImage(named: "3tracks")
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let helperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.layer.applySketchShadow(color: Constants.lightGray!, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        view.alpha = 0
        return view
    }()
    
    private let imageViewBackground: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.badge.plus")
        imageView.tintColor = Constants.textColorAccent
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = .clear
        imageView.alpha = 0
        return imageView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Constants.textColorAccent
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.alpha = 0
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
        field.placeholder = "Email address..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = Constants.accentColor
        field.layer.applySketchShadow(color: Constants.lightGray!, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        field.alpha = 0
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
        field.layer.applySketchShadow(color: Constants.lightGray!, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        field.alpha = 0
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
        field.layer.applySketchShadow(color: Constants.lightGray!, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        field.alpha = 0
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
        field.layer.applySketchShadow(color: Constants.lightGray!, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        field.alpha = 0
        return field
    }()
    
    private let logginButton: BounceButton = {
        let button = BounceButton()
        button.animationColor = Constants.accentColorDark
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = Constants.accentColorDark
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    private let loadingBalls: LoadingBalls = {
        let loadingBalls = LoadingBalls(frame: .zero, color: Constants.contrastColor!, duration: 0.8)
        loadingBalls.translatesAutoresizingMaskIntoConstraints = false
        return loadingBalls
    }()
    
    // Related to internet connection. Show this to user when connection is lost
    let noConnectionView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        view.setText(text: "You must be online to sign up for this app. \nCheck your connection and try again.")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        
        // Makes the nav bar blend in with the background
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        navBar?.tintColor = Constants.accentColorDark
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backTapped))
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        /// Adding subviews
        view.addSubview(slantedView)
        view.addSubview(helperView)
        helperView.addSubview(imageViewBackground)
        helperView.addSubview(imageView)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(logginButton)
        
        // Loading indicator
        view.addSubview(loadingBalls)
        
        // Makes keyboard disappear when tapped outside of keyboard
        self.dismissKeyboard()
        
        // Related to internett connection
        view.addSubview(noConnectionView)
        
        NetworkManager.isUnreachable { _ in
            self.showNoConnection()
        }
        NetworkManager.isReachable { _ in
            self.showConnection()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showConnection),
            name: NSNotification.Name(Constants.networkIsReachable),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showNoConnection),
            name: NSNotification.Name(Constants.networkIsNotReachable),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        imageView.image = nil
        animateRegister()
    }
    
    @objc func backTapped(sender: UIBarButtonItem) {
        animateReturn()
    }
    
    /// Lay out constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        slantedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
        slantedView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        slantedView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        slantedView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        helperView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        helperView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helperView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        helperView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.3).isActive = true
        helperView.layer.cornerRadius = Constants.widthOfDisplay * 0.3 / 2
        
        imageViewBackground.topAnchor.constraint(equalTo: helperView.topAnchor, constant: 20).isActive = true
        imageViewBackground.bottomAnchor.constraint(equalTo: helperView.bottomAnchor, constant: -20).isActive = true
        imageViewBackground.leadingAnchor.constraint(equalTo: helperView.leadingAnchor, constant: 20).isActive = true
        imageViewBackground.trailingAnchor.constraint(equalTo: helperView.trailingAnchor, constant: -20).isActive = true

        imageView.topAnchor.constraint(equalTo: helperView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: helperView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: helperView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: helperView.trailingAnchor).isActive = true
        imageView.layer.cornerRadius = helperView.layer.cornerRadius
        
        firstNameField.topAnchor.constraint(equalTo: helperView.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        firstNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        firstNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: Constants.sideMargin).isActive = true
        lastNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        lastNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: Constants.sideMargin).isActive = true
        emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: Constants.sideMargin).isActive = true
        passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        logginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: Constants.sideMargin).isActive = true
        logginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        logginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        logginButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        loadingBalls.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingBalls.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingBalls.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.6).isActive = true
        loadingBalls.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        // View related to internet connection
        noConnectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noConnectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        noConnectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        noConnectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func clearTextFields() {
        firstNameField.text?.removeAll()
        lastNameField.text?.removeAll()
        emailField.text?.removeAll()
        passwordField.text?.removeAll()
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
        
        animateLogin()
        
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
                    strongSelf.loadingBalls.stop()
                    strongSelf.animateLoginFailed()
                }
                return
            }
            
            // CASE: User does not already exist
            /// Firebase log in. Creating a new user in Firebase
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                // checks if returns an error, if so return.
                guard authResult != nil, error == nil else {
                    print("Error creating user")
                    self?.alertUserError()
                    self?.loadingBalls.stop()
                    self?.animateLoginFailed()
                    return
                }
                
                // cache values related to user
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                
                // Make sure there is no lingering partner email
                UserDefaults.standard.setValue(nil, forKey: "partnerEmail")
                
                // Set userdefaults related to Onboarding
                UserDefaults.standard.set(false, forKey: Constants.hasOnBoardedScroll)
                UserDefaults.standard.set(false, forKey: Constants.hasOnBoardedReaction)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedStartLineTwoUsers)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedFinishLineOneUser)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedConnectToPartner)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedTableViewClickMe)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedScanPartnerQR)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedOpenEndGate)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedFinishLineTwoUsers)
                UserDefaults.standard.set(false, forKey: Constants.hasOnboardedSensitivitySlider)
                UserDefaults.standard.set(1, forKey: Constants.sensitivityOnboardingSliderCounter)
                UserDefaults.standard.set(false, forKey: Constants.readyToShowOnboardConnect)
                
                // Insert user into database with properties given in text fields
                let raceAppUser = RaceAppUser(firstName: firstName,
                                              lastName: lastName,
                                              emailAddress: email)
                DatabaseManager.shared.insertUser(with: raceAppUser, completion: { success in
                    if success {
                        // upload image
                        // Might be image or might be nil
                        let image = strongSelf.imageView.image
                        
                        let filename = raceAppUser.profilePictureFileName
                        
                        // Upload profile picture to Firebase
                        // with image png data or nil, if nil, user has not selected image and no image is uploaded to database
                        StorageManager.shared.uploadProfilPicture(with: image?.pngData(), fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                // Open tabbar if all succeeds.
                                strongSelf.prepareTabBar()
                                strongSelf.clearTextFields()
                                DispatchQueue.main.async {
                                    strongSelf.loadingBalls.stop()
                                }
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                                // Open tabbar even if image upload fails
                                strongSelf.prepareTabBar()
                                strongSelf.clearTextFields()
                                DispatchQueue.main.async {
                                    strongSelf.loadingBalls.stop()
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
        
        tabBarVC.tabBar.barTintColor = Constants.accentColorDarkest
        tabBarVC.tabBar.isTranslucent = false
        tabBarVC.tabBar.tintColor = Constants.contrastColor
        tabBarVC.tabBar.unselectedItemTintColor = Constants.accentColor
        
        let home = HomeViewController()
        let navVC = UINavigationController(rootViewController: home)
        navVC.navigationBar.prefersLargeTitles = true
        navVC.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent!, NSAttributedString.Key.font: Constants.mainFontExtraBold!]
        navVC.navigationBar.tintColor = Constants.accentColorDark
        
        let stats = StatisticsViewController()
        let navVCStats = UINavigationController(rootViewController: stats)
        navVCStats.navigationBar.prefersLargeTitles = true
        navVCStats.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent!, NSAttributedString.Key.font: Constants.mainFontExtraBold!]
        navVCStats.navigationBar.tintColor = Constants.accentColorDark
        
        let profile = ProfileViewController()
        let navVCProfile = UINavigationController(rootViewController: profile)
        navVCProfile.navigationBar.prefersLargeTitles = true
        navVCProfile.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent!, NSAttributedString.Key.font: Constants.mainFontExtraBold!]
        navVCProfile.navigationBar.tintColor = Constants.accentColorDark
        
        tabBarVC.setViewControllers([navVC, navVCStats, navVCProfile], animated: false)
        
        guard let items = tabBarVC.tabBar.items else {
            return
        }
        
        items[0].image = UIImage(named: "Home")
        items[1].image = UIImage(named: "Stats")
        items[2].image = UIImage(named: "Settings")
        
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: false)
    }
    
    
    /// Alerts user if something is wrong with login inputs
    private func alertUserLoginError(message: String = "Please enter all information to create a new account. Password must be at least 8 characters.") {
        let alert = UIAlertController(title: "Whoops!",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    /// Alerts user that there was an error creating user
    private func alertUserError(message: String = "Error creating user. \nCheck that you entered a valid email.") {
        let alert = UIAlertController(title: "Whoops!",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    private func animateSlantedView(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5,
            animations: {
                self.slantedView.transform = CGAffineTransform.identity
            },
            completion: completion)
    }
    
    private func animateRegister() {
        slantedView.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.firstNameField.alpha = 1
                self.lastNameField.alpha = 1
                self.emailField.alpha = 1
                self.passwordField.alpha = 1
                self.logginButton.alpha = 1
                self.imageViewBackground.alpha = 1
                self.imageView.alpha = 1
                self.helperView.alpha = 1
            },
            completion: {_ in
                self.animateSlantedView(completion: nil)
            })
    }
    
    private func animateReturn() {
        slantedView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.3,
            animations: {
                self.firstNameField.alpha = 0
                self.lastNameField.alpha = 0
                self.emailField.alpha = 0
                self.passwordField.alpha = 0
                self.logginButton.alpha = 0
                self.imageViewBackground.alpha = 0
                self.imageView.alpha = 0
                self.helperView.alpha = 0
            },
            completion: {_ in
                UIView.animate(withDuration: 0.5,
                    animations: {
                        self.slantedView.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay)
                    },
                    completion: {_ in
                        self.navigationController?.popViewController(animated: false)
                    })
            })
    }
    
    private func hideViews(show: Bool) {
        var alpha: CGFloat = 0
        if show == true {
            alpha = 1
        }
        else {
            alpha = 0
        }
        self.helperView.alpha = alpha
        self.imageView.alpha = alpha
        self.imageViewBackground.alpha = alpha
        self.emailField.alpha = alpha
        self.passwordField.alpha = alpha
        self.logginButton.alpha = alpha
        self.firstNameField.alpha = alpha
        self.lastNameField.alpha = alpha
        self.logginButton.alpha = alpha
    }
    
    private func removeSlantedView(completion: ((Bool) -> Void)?) {
        slantedView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.5,
            animations: {
                self.slantedView.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay)
            },
            completion: completion)
    }
    
    private func animateLogin() {
        UIView.animate(withDuration: 0.3,
            animations: {
                self.hideViews(show: false)
            },
            completion: {_ in
                self.removeSlantedView(completion: {_ in
                    self.loadingBalls.animate()
                })
            })
        
    }
    
    private func animateLoginFailed() {
        UIView.animate(withDuration: 0.3,
            animations: {
                self.hideViews(show: true)
            },
            completion: {_ in
                self.animateSlantedView(completion: { _ in
                    self.loadingBalls.stop()
                })
            })
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
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
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

/// Related to internet connection
extension RegisterViewController {
    @objc func showConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 0
        })
    }
    
    @objc func showNoConnection() {
        self.noConnectionView.alpha = 1
    }
}
