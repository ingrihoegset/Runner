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
    
    // MARK: - Elements related to main view
    private let mainView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let mainHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
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
        qrImageView.backgroundColor = Constants.mainColor
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
        button.setTitle("Run with two gates", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapAddSecondGateButton), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    @objc func holdDown(sender:UIButton)
    {
        sender.backgroundColor = Constants.accentColorDark
    }
    
    @objc func release(sender:UIButton)
    {
        sender.backgroundColor = Constants.accentColor
    }

    private let runWithOneGateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Run with one gate", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        //button.addTarget(self, action: #selector(didTapAddSecondGateButton), for: .touchUpInside)
        return button
    }()
    
    private let partnerUILabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = Constants.accentColor
        label.text = "No partner"
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Elements related to linked view, first gate
    
    private let partnerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let setUpRaceWithTwoGatesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Set up run", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapAddSetUpRunWithTwoGates), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    private let unLinkFromPartnerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Remove second gate", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapButtonToUnlinkFromPartner), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    private let linkedHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
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
    
    // MARK: - Elements related to linked view, second gate
    
    private let secondGateView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let openSecondGatesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Open second gate", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didSelectOpenSecondGate), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    private let unLinkFromSecondGateButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.accentColor
        button.setTitle("Disconnet from second gate", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapButtonToUnlinkFromPartner), for: .touchUpInside)
        button.addTarget(self, action: #selector(holdDown(sender:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(release(sender:)), for: UIControl.Event.touchDragExit)
        return button
    }()
    
    private let secondGateHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let secondGateProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let secondGatePartnerProfileImageView: UIImageView = {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        view.backgroundColor = Constants.mainColor
        
        homeViewModel.homeViewModelDelegate = self
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            homeViewModel.fetchProfilePic(email: email)
        }
        else {
            print("No user email found when trying to initiate profile pic download")
        }

        // Related to main view
        view.addSubview(mainView)
        mainView.addSubview(mainHeaderView)
        // Set main header, that is active when not linked
        mainHeaderView.addSubview(profileImageView)
        mainHeaderView.addSubview(qrImageView)
        mainView.addSubview(addSecondGateButton)
        mainView.addSubview(runWithOneGateButton)

        // Related to view shown when linked to a partner
        view.addSubview(partnerView)
        partnerView.addSubview(linkedHeaderView)
        linkedHeaderView.addSubview(partnerProfileImageView)
        linkedHeaderView.addSubview(linkedProfileImageView)
        partnerView.addSubview(setUpRaceWithTwoGatesButton)
        partnerView.addSubview(unLinkFromPartnerButton)
        partnerView.addSubview(partnerUILabel)
        
        // Should be hidden on activiation of app, as all links are discarded on opening
        partnerView.isHidden = true
        
        // Relatd to view show when user is second gate
        view.addSubview(secondGateView)
        secondGateView.addSubview(secondGateHeaderView)
        secondGateHeaderView.addSubview(secondGatePartnerProfileImageView)
        secondGateHeaderView.addSubview(secondGateProfileImageView)
        secondGateView.addSubview(openSecondGatesButton)
        secondGateView.addSubview(unLinkFromSecondGateButton)
        
        // Should be hidden on activiation of app, as all links are discarded on opening
        secondGateView.isHidden = true
        
        homeViewModel.clearLinkFromDatabase()
        
        let qrButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapQRButton))
        qrImageView.addGestureRecognizer(qrButtonTapGesture)
        
        let unlinkFromPartnerTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapToUnlinkFromPartner))
        partnerProfileImageView.addGestureRecognizer(unlinkFromPartnerTapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Check if user is logged in already
        validateAuth()
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            homeViewModel.fetchProfilePic(email: email)
        }
        else {
            print("No user email found when trying to initiate profile pic download")
        }
    }
    
    deinit {
        print("DESTROYING")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Elements related to main view
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        mainHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
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

        runWithOneGateButton.anchor(top: mainHeaderView.bottomAnchor, leading: mainView.leadingAnchor, bottom: nil, trailing: mainView.trailingAnchor, padding: UIEdgeInsets(top: Constants.verticalSpacing, left: Constants.sideMargin, bottom: 0, right: Constants.sideMargin))
        runWithOneGateButton.heightAnchor.constraint(equalTo: mainHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        addSecondGateButton.anchor(top: runWithOneGateButton.bottomAnchor, leading: mainView.leadingAnchor, bottom: nil, trailing: mainView.trailingAnchor, padding: UIEdgeInsets(top: Constants.verticalSpacing, left: Constants.sideMargin, bottom: 0, right: Constants.sideMargin))
        addSecondGateButton.heightAnchor.constraint(equalTo: mainHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        

        // Elements related to linked view
        partnerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        partnerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        partnerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        partnerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        linkedHeaderView.topAnchor.constraint(equalTo: partnerView.topAnchor).isActive = true
        linkedHeaderView.centerXAnchor.constraint(equalTo: partnerView.centerXAnchor).isActive = true
        linkedHeaderView.widthAnchor.constraint(equalTo: partnerView.widthAnchor).isActive = true
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
        
        setUpRaceWithTwoGatesButton.anchor(top: linkedHeaderView.bottomAnchor,
                                           leading: partnerView.leadingAnchor, bottom: nil,
                                           trailing: partnerView.trailingAnchor,
                                           padding: UIEdgeInsets(top: Constants.verticalSpacing,
                                                                 left: Constants.sideMargin, bottom: 0,
                                                                 right: Constants.sideMargin))
        setUpRaceWithTwoGatesButton.heightAnchor.constraint(equalTo: linkedHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        unLinkFromPartnerButton.anchor(top: setUpRaceWithTwoGatesButton.bottomAnchor,
                              leading: partnerView.leadingAnchor,
                              bottom: nil, trailing: partnerView.trailingAnchor,
                              padding: UIEdgeInsets(top: Constants.verticalSpacing,
                                                    left: Constants.sideMargin, bottom: 0,
                                                    right: Constants.sideMargin))
        unLinkFromPartnerButton.heightAnchor.constraint(equalTo: linkedHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        partnerUILabel.anchor(top: unLinkFromPartnerButton.bottomAnchor,
                              leading: partnerView.leadingAnchor,
                              bottom: nil, trailing: partnerView.trailingAnchor,
                              padding: UIEdgeInsets(top: Constants.verticalSpacing,
                                                    left: Constants.sideMargin, bottom: 0,
                                                    right: Constants.sideMargin))
        partnerUILabel.heightAnchor.constraint(equalTo: linkedHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        // Elements related to second gate view
        secondGateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        secondGateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        secondGateView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        secondGateView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        secondGateHeaderView.topAnchor.constraint(equalTo: secondGateView.topAnchor).isActive = true
        secondGateHeaderView.centerXAnchor.constraint(equalTo: secondGateView.centerXAnchor).isActive = true
        secondGateHeaderView.widthAnchor.constraint(equalTo: secondGateView.widthAnchor).isActive = true
        secondGateHeaderView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        secondGateProfileImageView.trailingAnchor.constraint(equalTo: secondGateHeaderView.centerXAnchor).isActive = true
        secondGateProfileImageView.centerYAnchor.constraint(equalTo: secondGateHeaderView.centerYAnchor).isActive = true
        secondGateProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGateProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGateProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        secondGatePartnerProfileImageView.leadingAnchor.constraint(equalTo: secondGateHeaderView.centerXAnchor).isActive = true
        secondGatePartnerProfileImageView.centerYAnchor.constraint(equalTo: secondGateHeaderView.centerYAnchor).isActive = true
        secondGatePartnerProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGatePartnerProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGatePartnerProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        openSecondGatesButton.anchor(top: secondGateHeaderView.bottomAnchor,
                                           leading: secondGateView.leadingAnchor, bottom: nil,
                                           trailing: secondGateView.trailingAnchor,
                                           padding: UIEdgeInsets(top: Constants.verticalSpacing,
                                                                 left: Constants.sideMargin, bottom: 0,
                                                                 right: Constants.sideMargin))
        openSecondGatesButton.heightAnchor.constraint(equalTo: secondGateHeaderView.heightAnchor, multiplier: 0.3).isActive = true
        
        unLinkFromSecondGateButton.anchor(top: openSecondGatesButton.bottomAnchor,
                              leading: secondGateView.leadingAnchor,
                              bottom: nil, trailing: secondGateView.trailingAnchor,
                              padding: UIEdgeInsets(top: Constants.verticalSpacing,
                                                    left: Constants.sideMargin, bottom: 0,
                                                    right: Constants.sideMargin))
        unLinkFromSecondGateButton.heightAnchor.constraint(equalTo: secondGateHeaderView.heightAnchor, multiplier: 0.3).isActive = true
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
    @objc func didTapQRButton() {
        let vc = LinkToPartnerViewController()
        vc.startControlSegment = 1
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
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
                self.secondGatePartnerProfileImageView.image = image
            }
            else { 
                print("match")
                self.profileImageView.image = image
                self.linkedProfileImageView.image = image
                self.secondGateProfileImageView.image = image
            }
        }
    }
    
    // Gets and updates UI elements in accordance with successful link with partner
    // Is triggered by home view model when a change to link occurs. If a link is found, else is activated, view shows linked view.
    func didUpdatePartnerUI(partner: String, gateNumber: Int) {
        DispatchQueue.main.async {
            print("Updating UI")
            print("gate number", gateNumber)
            // Show connected view, but for first gate
            if gateNumber == 1 {
                self.partnerUILabel.text = partner
                self.partnerView.isHidden = false
                self.mainView.isHidden = true
                self.secondGateView.isHidden = true
            }
            // Show connected view, but for second gate
            else if gateNumber == 2 {
                self.partnerUILabel.text = partner
                self.secondGateView.isHidden = false
                self.partnerView.isHidden = true
                self.mainView.isHidden = true
            }
            // Show main view, no connection
            else {
                self.partnerUILabel.text = partner
                self.partnerView.isHidden = true
                self.secondGateView.isHidden = true
                self.mainView.isHidden = false
                self.alertThatPartnerHasDisconnected()
            }
        }
    }
    
    func didGetRunResult(result: RunResults) {
        let vc = ResultsViewController()
        vc.result = result
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

// MARK: - Functions relating to connecting with second gate
extension HomeViewController {

    @objc private func didTapAddSecondGateButton(sender: UIButton) {
        let vc = LinkToPartnerViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.startControlSegment = 0
        present(navVC, animated: true)
    }
}


// MARK: - Functions relating to view when linked to partner
extension HomeViewController {
    
    /// Takes us to new view controller where race can be set up. Only available when linked to partner.
    @objc private func didTapAddSetUpRunWithTwoGates() {
        let vc = SetUpRunViewController()
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
           
        
    }
    
    /// Partner profile pic is tapped. It should show a prompt to ask user if they want to disconnet from partner.
    @objc func didTapToUnlinkFromPartner(sender: UIGestureRecognizer) {
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
    
    @objc func didTapButtonToUnlinkFromPartner() {
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
    
    /// Partner profile pic is tapped. It should show a prompt to ask user if they want to disconnet from partner.
    private func alertThatPartnerHasDisconnected() {
        let actionSheet = UIAlertController(title: "You've been partner has disconnected from you.",
                                            message: "",
                                            preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }))
        present(actionSheet, animated: true)
    }
    
    
    // MARK: - Functions related to second gate
    @objc private func didSelectOpenSecondGate(sender: UIButton) {
        let vc = SecondGateViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}
