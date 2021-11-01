//
//  ForgotPasswordViewController.swift
//  Runner
//
//  Created by Ingrid on 23/10/2021.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    private let resetLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Reset password"
        label.font = Constants.mainFontXLargeSB
        label.textColor = Constants.textColorDarkGray
        label.textAlignment = .center
        return label
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
        field.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return field
    }()

    private let sendPasswordButton: BounceButton = {
        let button = BounceButton()
        button.animationColor = Constants.accentColorDark
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.backgroundColor = Constants.accentColorDark
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapSendPassword), for: .touchUpInside)
        return button
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
        
        view.addSubview(resetLabel)
        view.addSubview(emailField)
        view.addSubview(sendPasswordButton)
        
        // Makes keyboard disappear when tapped outside of keyboard
        self.dismissKeyboard()
    }
    
    /// Lay out constraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        resetLabel.bottomAnchor.constraint(equalTo: emailField.topAnchor, constant: -Constants.verticalSpacing).isActive = true
        resetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        resetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        resetLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        emailField.bottomAnchor.constraint(equalTo: sendPasswordButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        sendPasswordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: Constants.sideMargin).isActive = true
        sendPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        sendPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        sendPasswordButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
    }
    
    @objc func didTapSendPassword() {
        let auth = Auth.auth()
        
        auth.sendPasswordReset(withEmail: emailField.text!, completion: { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .cancel,
                                              handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            let alert = UIAlertController(title: "Hurray",
                                          message: "A password reset email has been sent to your email!",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
            
        })
    }
}
