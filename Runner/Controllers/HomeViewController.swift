//
//  ViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var homeViewModel = HomeViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .orange
        return scrollView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let qrImageView: UIImageView = {
        let qrImageView = UIImageView()
        qrImageView.backgroundColor = .red
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.contentMode = .scaleAspectFill
        qrImageView.layer.borderColor = Constants.accentColorDark?.cgColor
        qrImageView.layer.borderWidth = Constants.borderWidth
        qrImageView.layer.masksToBounds = true
        let image = UIImage(systemName: "qrcode")
        qrImageView.image = image?.imageWithInsets(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        qrImageView.isUserInteractionEnabled = true
        return qrImageView
    }()
    
    private let qrImage: UIImage = {
        let qrImage = UIImage()
        return qrImage
    }()
    
    private let addSecondGateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Add Second Gate", for: .normal)
        button.addTarget(self, action: #selector(didTapAddSecondGateButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewModel.homeViewModelDelegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(headerView)
        headerView.addSubview(profileImageView)
        scrollView.addSubview(qrImageView)
        scrollView.addSubview(addSecondGateButton)
        
        setConstraints()
        
        homeViewModel.fetchProfilePic()
        
        let qrButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapQRButton))
        qrImageView.addGestureRecognizer(qrButtonTapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Check if user is logged in already
        validateAuth()
    }
    
    func setConstraints() {
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        headerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.layer.cornerRadius = Constants.imageSize / 2
    
        qrImageView.leadingAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 20).isActive = true
        qrImageView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 5).isActive = true
        qrImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrImageView.layer.cornerRadius = (Constants.imageSize * 0.6) / 2
        
        addSecondGateButton.anchor(top: headerView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: Constants.verticalSpacing, left: Constants.sideMargin, bottom: 0, right: Constants.sideMargin))
        addSecondGateButton.heightAnchor.constraint(equalTo: headerView.heightAnchor, multiplier: 0.3).isActive = true
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
    
    /// QR-button is tapped. It should reveal the users QR-code for scanning.
    @objc func didTapQRButton(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let vc = QRLinkViewController()
            let navVC = UINavigationController(rootViewController: vc)
            present(navVC, animated: true)
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}

// MARK: - Functions relating to connecting with second gate
extension HomeViewController {

    @objc private func didTapAddSecondGateButton() {
        let vc = LinkToPartnerViewController()
        vc.completion = { [weak self] result in
            print("result \(result)")
            self?.goToSetUpWithPartner(partnerSafeEmail: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func goToSetUpWithPartner(partnerSafeEmail: String) {
        /*let vc = RaceTypeViewController()
        vc.partnerId = partnerId
        vc.raceId = raceId
        vc.title = "Select Race Type"
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)*/
    }
    
    // Gets and updates UI elements in accordance with successful link with partner
    func setUpPartnerDisplay() {
        
    }
}

