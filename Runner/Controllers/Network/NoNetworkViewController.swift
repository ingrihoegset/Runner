//
//  NoNetworkViewController.swift
//  Runner
//
//  Created by Ingrid on 23/10/2021.
//

import UIKit

class NoNetworkViewController: UIViewController {
    
    let noNetworkView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    let network = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        view.addSubview(noNetworkView)
        
        // If the network is reachable show the main controller
        network.reachability.whenReachable = { _ in
            self.showMainController()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        noNetworkView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        noNetworkView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        noNetworkView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noNetworkView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func showMainController() -> Void {
        navigationController?.setNavigationBarHidden(false, animated: false)
        UIView.animate(withDuration: 0.5,
            animations: {
                self.view.alpha = 0
            },
            completion: { _ in
                self.view.isHidden = true
            })
    }
}
