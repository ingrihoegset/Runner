//
//  RegisterViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit

class RegisterViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .orange
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Constants.accentColorDark
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
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
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.cornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "First name..."
        // Creates buffer to make space between edge and text in textfield
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .clear
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = Constants.cornerRadius
        field.layer.borderWidth = Constants.borderWidth
        field.layer.borderColor = Constants.accentColorDark?.cgColor
        field.placeholder = "Last name..."
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
        button.setTitle("Register", for: .normal)
        button.backgroundColor = Constants.accentColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /*
    private let fbregisterButton: FBregisterButton = {
        let button = FBregisterButton()
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleregisterButton: GIDSignInButton = {
        let button = GIDSignInButton()
        // To override height property inherent in fb button
        button.removeConstraints(button.constraints)
        return button
    }()*/

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .link
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        /// Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(logginButton)
        
        /*
        // Facebook login button
        scrollView.addSubview(fbregisterButton)
        
        // Google login button
        scrollView.addSubview(googleregisterButton)
         */
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
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: Constants.fieldHeight)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom+10,
                                  width: scrollView.width-60,
                                  height: Constants.fieldHeight)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+10,
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
        
        /*
        fbregisterButton.frame = CGRect(x: Constants.sideSpacing,
                                 y: logginButton.bottom + 20,
                                 width: scrollView.width - Constants.sideSpacing * 2,
                                 height: Constants.fieldHeight)
        
        googleregisterButton.frame = CGRect(x: Constants.sideSpacing,
                                 y: fbregisterButton.bottom + 10,
                                 width: scrollView.width - Constants.sideSpacing * 2,
                                 height: Constants.fieldHeight)
         */
    }
    
    /// When user taps image view to set profile pic
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    /// When user taps to register new user, send user to register view controller
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
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
    }
    
    /// Alerts user if something is wrong with login inputs
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Whoops",
                                      message: "Please enter all information to create a new account. Password must be at least 8 characters.",
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
