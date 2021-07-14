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
    
    private let mainHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()
    
    private let linkedHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .yellow
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
    
    private let linkedProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let partnerProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
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
    
    private let partnerUILabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Constants.accentColor
        label.text = "No partner"
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeViewModel.homeViewModelDelegate = self
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            homeViewModel.fetchProfilePic(email: email)
        }
        else {
            print("No user email found when trying to initiate profile pic download")
        }

        view.addSubview(scrollView)
        scrollView.addSubview(mainHeaderView)
        // Set main header, that is active when not linked
        mainHeaderView.addSubview(profileImageView)
        mainHeaderView.addSubview(qrImageView)
        
        // Set linked header view, that is active when linked to partner
        scrollView.addSubview(linkedHeaderView)
        linkedHeaderView.addSubview(partnerProfileImageView)
        linkedHeaderView.addSubview(linkedProfileImageView)
        // Should be hidden on activiation of app, as all links are discarded on opening
        linkedHeaderView.isHidden = true

        scrollView.addSubview(addSecondGateButton)
        scrollView.addSubview(partnerUILabel)
        setConstraints()
        
        homeViewModel.clearLinkFromDatabase()
        
        let qrButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapQRButton))
        qrImageView.addGestureRecognizer(qrButtonTapGesture)
        
        let unlinkFromPartnerTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapToUnlinkFromParnter))
        partnerProfileImageView.addGestureRecognizer(unlinkFromPartnerTapGesture)
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
        
        mainHeaderView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        mainHeaderView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: mainHeaderView.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: mainHeaderView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.layer.cornerRadius = Constants.imageSize / 2
    
        qrImageView.leadingAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 20).isActive = true
        qrImageView.topAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 5).isActive = true
        qrImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrImageView.layer.cornerRadius = (Constants.imageSize * 0.6) / 2
        
        linkedHeaderView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        linkedHeaderView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        linkedHeaderView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        linkedHeaderView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        linkedProfileImageView.trailingAnchor.constraint(equalTo: linkedHeaderView.centerXAnchor).isActive = true
        linkedProfileImageView.centerYAnchor.constraint(equalTo: linkedHeaderView.centerYAnchor).isActive = true
        linkedProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        linkedProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        linkedProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        partnerProfileImageView.leadingAnchor.constraint(equalTo: linkedHeaderView.centerXAnchor).isActive = true
        partnerProfileImageView.centerYAnchor.constraint(equalTo: linkedHeaderView.centerYAnchor).isActive = true
        partnerProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        partnerProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        partnerProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        addSecondGateButton.anchor(top: mainHeaderView.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: Constants.verticalSpacing, left: Constants.sideMargin, bottom: 0, right: Constants.sideMargin))
        addSecondGateButton.heightAnchor.constraint(equalTo: mainHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        partnerUILabel.anchor(top: addSecondGateButton.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: Constants.verticalSpacing, left: Constants.sideMargin, bottom: 0, right: Constants.sideMargin))
        partnerUILabel.heightAnchor.constraint(equalTo: mainHeaderView.heightAnchor, multiplier: 0.3).isActive = true
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
    
    /// Partner profile pic is tapped. It should show a prompt to ask user if they want to disconnet from partner.
    @objc func didTapToUnlinkFromParnter(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let actionSheet = UIAlertController(title: "Do you wish to unlink from second gate?",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Unlink from second gate", style: .destructive, handler: { [weak self] _ in
                
                guard let strongSelf = self else {
                    return
                }
                
                // Clear any partner link from database
                strongSelf.homeViewModel.clearLinkFromDatabase()

            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            present(actionSheet, animated: true)
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didFetchProfileImage(image: UIImage, safeEmail: String) {
        guard var userEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        userEmail = RaceAppUser.safeEmail(emailAddress: userEmail)
        // If email used in call doesnt match our users email, then we update partner image.
        // Otherwise, update our users image.
        DispatchQueue.main.async {
            if safeEmail != userEmail {
                print("not a match")
                self.partnerProfileImageView.image = image
            }
            else { 
                print("match")
                self.profileImageView.image = image
                self.linkedProfileImageView.image = image
            }
        }
    }
}

// MARK: - Functions relating to connecting with second gate
extension HomeViewController {

    @objc private func didTapAddSecondGateButton() {
        let vc = LinkToPartnerViewController()/*
        vc.completion = { [weak self] result in
            print("result \(result)")
            self?.goToSetUpWithPartner(partnerSafeEmail: result)
        }*/
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    /*
    func goToSetUpWithPartner(partnerSafeEmail: String) {
        let vc = RaceTypeViewController()
        vc.partnerId = partnerId
        vc.raceId = raceId
        vc.title = "Select Race Type"
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }*/
    
    // Gets and updates UI elements in accordance with successful link with partner
    func didUpdatePartnerUI(partner: String) {
        DispatchQueue.main.async {
            if partner == "No partner" {
                self.partnerUILabel.text = partner
                self.linkedHeaderView.isHidden = true
                self.mainHeaderView.isHidden = false
            }
            else {
                self.partnerUILabel.text = partner
                self.linkedHeaderView.isHidden = false
                self.mainHeaderView.isHidden = true
            }
        }
    }
}

