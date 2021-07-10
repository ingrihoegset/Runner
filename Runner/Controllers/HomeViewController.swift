//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For use to check if user is logged in already or not
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        // If user is not logged in, send user to log in view controller
        if !isLoggedIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            // Full screen so the user cannot dismiss login page i fnot logged in
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }

    


}

