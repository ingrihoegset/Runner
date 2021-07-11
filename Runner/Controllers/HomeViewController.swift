//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if user is logged in already
        validateAuth()
    }
    
    /// Function checks if user is logged in or not
    private func validateAuth() {
        // If there is no current user, send user to log in view controller
        // Current user is set automatically when you instantiate firebase auth, and log a user in.
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            // Full screen so the user cannot dismiss login page if not logged in
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
}

