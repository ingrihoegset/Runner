//
//  LaunchViewController.swift
//  Runner
//
//  Created by Ingrid on 03/04/2022.
//

import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    func launchComplete()
}

class LaunchViewController: UIViewController {
    
    weak var launchViewControllerDelegate: LaunchViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple

        // Do any additional setup after loading the view.
    }
    


}
