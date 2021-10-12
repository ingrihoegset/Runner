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
    let launcherViewController = LauncherViewController()
    var firstLaunch = true
    
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
        view.backgroundColor = Constants.accentColor
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.contentMode = .scaleToFill
        imageView.alpha = 0.7
        let image = UIImage(named: "Track")
        imageView.image = image


        let imageViewColor = UIView()
        view.addSubview(imageViewColor)
        imageViewColor.translatesAutoresizingMaskIntoConstraints = false
        imageViewColor.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageViewColor.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageViewColor.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageViewColor.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        imageViewColor.backgroundColor = Constants.textColorDarkGray
        imageViewColor.alpha = 0.3
        
        view.bringSubviewToFront(imageViewColor)
        
        return view
    }()
    
    // MARK: - Elements related to unconnected user
    private let unconnectedHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let unconnectedprofileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.accentColor?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")?.withTintColor(Constants.lightGray!)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let qrButton: BounceButton = {
        let qrButton = BounceButton()
        qrButton.backgroundColor = Constants.accentColor
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.layer.masksToBounds = false
        qrButton.animationColor = Constants.accentColorDark
        let image = UIImage(named: "QrCode")?.withTintColor(Constants.accentColorDark!, renderingMode: .alwaysOriginal)
        let imageview = UIImageView()
        qrButton.addSubview(imageview)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.topAnchor.constraint(equalTo: qrButton.topAnchor).isActive = true
        imageview.bottomAnchor.constraint(equalTo: qrButton.bottomAnchor).isActive = true
        imageview.leadingAnchor.constraint(equalTo: qrButton.leadingAnchor).isActive = true
        imageview.trailingAnchor.constraint(equalTo: qrButton.trailingAnchor).isActive = true
        imageview.contentMode = .scaleAspectFit
        imageview.image = image?.imageWithInsets(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        qrButton.addTarget(self, action: #selector(didTapQRButton), for: .touchUpInside)
        qrButton.isUserInteractionEnabled = true
        qrButton.isHidden = true
        qrButton.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5 / 1.5, spread: 0)
        return qrButton
    }()
    
    private let qrImage: UIImage = {
        let qrImage = UIImage()
        return qrImage
    }()
    
    let unconnectedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let setUpSprintButton: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColor
        button.animationColor = Constants.accentColorDark
        button.imageview.image = UIImage(named: "Sprint")?.withTintColor(Constants.accentColorDark!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.title.text = "Sprint"
        button.title.textColor = Constants.textColorDarkGray
        button.addTarget(self, action: #selector(didTapSetUpRun), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()
    
    let setUpReactionButton: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColor
        button.animationColor = Constants.accentColorDark
        button.tag = 1
        let image = UIImage(named: "Reaction")
        button.imageview.image = UIImage(named: "Reaction")?.withTintColor(Constants.accentColorDark!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.title.text = "Reaction run"
        button.title.textColor = Constants.textColorDarkGray
        button.addTarget(self, action: #selector(didTapSetUpRun), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()

    
    // MARK: - Elements related to linked view, first gate
    private let linkedHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let linkedProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
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
        imageView.backgroundColor = Constants.mainColor
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // MARK: - Elements related to linked view, second gate
    private let secondGateHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let secondGateProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
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
        imageView.backgroundColor = Constants.mainColor
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let secondGateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private let openSecondGatesButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.accentColorDark
        button.setTitle("Open end gate", for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didSelectOpenSecondGate), for: .touchUpInside)
        return button
    }()
    
    private let unLinkFromSecondGateButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.setTitle("Disconnect", for: .normal)
        button.setTitleColor(Constants.accentColorDark, for: .normal)
        button.animationColor = Constants.mainColor
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didTapButtonToUnlinkFromPartner), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return button
    }()
    
    let segmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " Number of timing gates"
        label.font = Constants.mainFont
        label.textColor = Constants.textColorDarkGray
        label.textAlignment = .left
        return label
    }()
    
    let segmentControl: RoundedSegmentedControl = {
        let control = RoundedSegmentedControl(items: ["1 Gate","2 Gates"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.mainColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorDarkGray,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.accentColorDark!,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        control.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return control
    }()
    
    /// Views related to onboarding
    let onBoardConnect: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Connect to partner to add second timing gate and unlock more features!", pointerPlacement: "bottomMiddle")
        bubble.translatesAutoresizingMaskIntoConstraints = false
        return bubble
    }()
    
    let onBoardEndGate: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Open end gate to create a finish line!", pointerPlacement: "topMiddle")
        bubble.translatesAutoresizingMaskIntoConstraints = false
        return bubble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.accentColor
        
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        
        homeViewModel.homeViewModelDelegate = self
        onBoardConnect.onBoardingBubbleDelegate = self
        onBoardEndGate.onBoardingBubbleDelegate = self
        
        if let email = UserDefaults.standard.value(forKey: "email") as? String {
            homeViewModel.fetchProfilePic(email: email)
        }
        else {
            print("No user email found when trying to initiate profile pic download")
        }

        // Related to main view
        view.addSubview(mainView)
        mainView.addSubview(mainHeaderView)
        
        // Set profile header, that is active when not linked
        mainView.addSubview(unconnectedHeaderView)
        unconnectedHeaderView.addSubview(qrButton)
        unconnectedHeaderView.addSubview(unconnectedprofileImageView)
        
        // Header when user is first gate
        mainView.addSubview(linkedHeaderView)
        linkedHeaderView.addSubview(partnerProfileImageView)
        linkedHeaderView.addSubview(linkedProfileImageView)
        
        // Header when user is second gate
        mainView.addSubview(secondGateHeaderView)
        secondGateHeaderView.addSubview(secondGatePartnerProfileImageView)
        secondGateHeaderView.addSubview(secondGateProfileImageView)
        
        // Controller used to switch between two gate and  one gate
        mainView.addSubview(segmentLabel)
        mainView.addSubview(segmentControl)
        mainView.addSubview(onBoardConnect)
        
        mainView.addSubview(unconnectedView)
        unconnectedView.addSubview(setUpSprintButton)
        unconnectedView.addSubview(setUpReactionButton)
        
        // Related to view show when user is second gate
        mainView.addSubview(secondGateView)
        secondGateView.addSubview(openSecondGatesButton)
        secondGateView.addSubview(unLinkFromSecondGateButton)
        secondGateView.addSubview(onBoardEndGate)
        
        view.bringSubviewToFront(qrButton)

        homeViewModel.clearLinkFromDatabase()
        
        let unlinkFromPartnerTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapToUnlinkFromPartner))
        partnerProfileImageView.addGestureRecognizer(unlinkFromPartnerTapGesture)
        
        addChildController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Open email app here on verification of email on registration
        if Setup.shouldOpenMailApp {
            Setup.shouldOpenMailApp = false
            if let url = URL(string: "message://") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                // Could not open email app
                else {
                    let cancelAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    let alert = UIAlertController(title: "Error",
                                                  message: "Could not open email app on your phone.",
                                                  preferredStyle: .alert)
 
                    alert.addAction(cancelAlertAction)
                    present(alert, animated: true)
                }
            }
        }
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
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        mainHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        mainHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        // Unlinked header
        unconnectedHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        unconnectedHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        unconnectedHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        unconnectedHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        unconnectedprofileImageView.centerYAnchor.constraint(equalTo: unconnectedHeaderView.bottomAnchor).isActive = true
        unconnectedprofileImageView.centerXAnchor.constraint(equalTo: unconnectedHeaderView.centerXAnchor).isActive = true
        unconnectedprofileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        unconnectedprofileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        unconnectedprofileImageView.layer.cornerRadius = Constants.imageSize / 2
    
        qrButton.leadingAnchor.constraint(equalTo: unconnectedprofileImageView.trailingAnchor, constant: -Constants.borderWidth).isActive = true
        qrButton.centerYAnchor.constraint(equalTo: unconnectedprofileImageView.centerYAnchor).isActive = true
        qrButton.widthAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrButton.heightAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        qrButton.layer.cornerRadius = (Constants.imageSize * 0.6) / 2
        
        // Linked header first gate
        linkedHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        linkedHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        linkedHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        linkedHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        linkedProfileImageView.trailingAnchor.constraint(equalTo: linkedHeaderView.centerXAnchor).isActive = true
        linkedProfileImageView.centerYAnchor.constraint(equalTo: linkedHeaderView.bottomAnchor).isActive = true
        linkedProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        linkedProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        linkedProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        partnerProfileImageView.leadingAnchor.constraint(equalTo: linkedHeaderView.centerXAnchor).isActive = true
        partnerProfileImageView.centerYAnchor.constraint(equalTo: linkedHeaderView.bottomAnchor).isActive = true
        partnerProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        partnerProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        partnerProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        // Linked header second gate
        secondGateHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        secondGateHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        secondGateHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        secondGateHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        secondGateProfileImageView.trailingAnchor.constraint(equalTo: secondGateHeaderView.centerXAnchor).isActive = true
        secondGateProfileImageView.centerYAnchor.constraint(equalTo: secondGateHeaderView.bottomAnchor).isActive = true
        secondGateProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGateProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGateProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        secondGatePartnerProfileImageView.leadingAnchor.constraint(equalTo: secondGateHeaderView.centerXAnchor).isActive = true
        secondGatePartnerProfileImageView.centerYAnchor.constraint(equalTo: secondGateHeaderView.bottomAnchor).isActive = true
        secondGatePartnerProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGatePartnerProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        secondGatePartnerProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        
        // Segment control, common to all states / views
        segmentLabel.heightAnchor.constraint(equalToConstant: Constants.sideMargin * 1.35).isActive = true
        segmentLabel.topAnchor.constraint(equalTo: unconnectedprofileImageView.bottomAnchor, constant: Constants.sideMargin / 2).isActive = true
        segmentLabel.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor).isActive = true
        segmentLabel.trailingAnchor.constraint(equalTo: segmentControl.trailingAnchor).isActive = true
        
        segmentControl.topAnchor.constraint(equalTo: segmentLabel.bottomAnchor).isActive = true
        segmentControl.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        segmentControl.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        segmentControl.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        onBoardConnect.bottomAnchor.constraint(equalTo: segmentControl.topAnchor).isActive = true
        onBoardConnect.trailingAnchor.constraint(equalTo: segmentControl.trailingAnchor).isActive = true
        onBoardConnect.leadingAnchor.constraint(equalTo: segmentControl.centerXAnchor).isActive = true
        onBoardConnect.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 3).isActive = true
        
        // Selections shown when no link
        unconnectedView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
        unconnectedView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        unconnectedView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        unconnectedView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        
        setUpSprintButton.topAnchor.constraint(equalTo: unconnectedView.topAnchor, constant: Constants.sideMargin).isActive = true
        setUpSprintButton.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay / 2 - Constants.sideMargin * 1.5).isActive = true
        setUpSprintButton.heightAnchor.constraint(equalTo: setUpSprintButton.widthAnchor).isActive = true
        setUpSprintButton.leadingAnchor.constraint(equalTo: unconnectedView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        
        setUpReactionButton.topAnchor.constraint(equalTo: unconnectedView.topAnchor, constant: Constants.sideMargin).isActive = true
        setUpReactionButton.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay / 2 - Constants.sideMargin * 1.5).isActive = true
        setUpReactionButton.heightAnchor.constraint(equalTo: setUpSprintButton.widthAnchor).isActive = true
        setUpReactionButton.trailingAnchor.constraint(equalTo: unconnectedView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        // Elements related to second gate view
        secondGateView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
        secondGateView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        secondGateView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        secondGateView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        unLinkFromSecondGateButton.topAnchor.constraint(equalTo: secondGateView.topAnchor, constant: Constants.verticalSpacing).isActive = true
        unLinkFromSecondGateButton.leadingAnchor.constraint(equalTo: secondGateView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        unLinkFromSecondGateButton.trailingAnchor.constraint(equalTo: secondGateView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        unLinkFromSecondGateButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        openSecondGatesButton.topAnchor.constraint(equalTo: unLinkFromSecondGateButton.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        openSecondGatesButton.leadingAnchor.constraint(equalTo: secondGateView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        openSecondGatesButton.trailingAnchor.constraint(equalTo: secondGateView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        openSecondGatesButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        onBoardEndGate.topAnchor.constraint(equalTo: openSecondGatesButton.bottomAnchor).isActive = true
        onBoardEndGate.widthAnchor.constraint(equalTo: openSecondGatesButton.widthAnchor, multiplier: 0.6).isActive = true
        onBoardEndGate.centerXAnchor.constraint(equalTo: openSecondGatesButton.centerXAnchor).isActive = true
        onBoardEndGate.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
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
                self.unconnectedprofileImageView.image = image
                self.linkedProfileImageView.image = image
                self.secondGateProfileImageView.image = image
            }
            if self.firstLaunch == true {
                self.launchFinished()
                self.firstLaunch = false
            }
        }
    }
    
    func launchFinished() {
        
        UIView.animate(withDuration: 0.2,
            animations: {
                self.launcherViewController.view.alpha = 0
            },
            completion: { _ in
                self.unconnectedprofileImageView.isHidden = false
                self.qrButton.isHidden = false
                self.animateUnlink()
            })
    }
    
    // Gets and updates UI elements in accordance with successful link with partner
    // Is triggered by home view model when a change to link occurs. If a link is found, else is activated, view shows linked view.
    func didUpdatePartnerUI(partner: String, gateNumber: Int) {
        DispatchQueue.main.async {
            print("Updating UI")
            print("gate number", gateNumber)
            // Show connected view, but for first gate
            if gateNumber == 1 {
                // Show
                self.linkedHeaderView.isHidden = false
                self.unconnectedView.isHidden = false
                
                // Hide
                self.unconnectedHeaderView.isHidden = true
                self.secondGateHeaderView.isHidden = true
                self.secondGateView.isHidden = true
                
                // Update segment Controller as well
                self.segmentControl.selectedSegmentIndex = 1
    
                self.animateLinkedPartnerUI()
            }
            // Show connected view, but for second gate
            else if gateNumber == 2 {
                // Show
                self.secondGateHeaderView.isHidden = false
                self.secondGateView.isHidden = false
                // Hide
                self.unconnectedHeaderView.isHidden = true
                self.linkedHeaderView.isHidden = true
                self.unconnectedView.isHidden = true

                // Update segment Controller as well
                self.segmentControl.selectedSegmentIndex = 1
                
                self.animateLinkedPartnerUI()
            }
            // Show main view, no connection
            else {
                // Show
                self.unconnectedHeaderView.isHidden = false
                self.unconnectedView.isHidden = false
                // Hide
                self.linkedHeaderView.isHidden = true
                self.secondGateHeaderView.isHidden = true
                self.secondGateView.isHidden = true
                // Alert
                self.alertThatPartnerHasDisconnected()
                // Update segment Controller as well
                self.segmentControl.selectedSegmentIndex = 0
                
                self.animateUnlink()
            }
        }
    }
    
    func animateUnlink() {
        unconnectedprofileImageView.transform = CGAffineTransform(translationX: -200, y: 0)
        qrButton.transform = CGAffineTransform(translationX: 200, y: 0)
        
        UIView.animate(withDuration: 0.25,
            animations: {
                self.unconnectedprofileImageView.transform = CGAffineTransform.identity
                self.qrButton.transform = CGAffineTransform.identity
            },
            completion: { _ in
                UIView.animate(withDuration: 0.10,
                    animations: {
                        self.unconnectedprofileImageView.transform = CGAffineTransform(translationX: -10, y: 0)
                        self.qrButton.transform = CGAffineTransform(translationX: 10, y: 0)
                    },
                    completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.unconnectedprofileImageView.transform = CGAffineTransform.identity
                            self.qrButton.transform = CGAffineTransform.identity
                        }
                    })
            })
    }
    
    func animateLinkedPartnerUI() {
        linkedProfileImageView.transform = CGAffineTransform(translationX: Constants.imageSize/2, y: 0)
        partnerProfileImageView.transform = CGAffineTransform(translationX: -Constants.imageSize/2, y: 0)
        secondGateProfileImageView.transform = CGAffineTransform(translationX: Constants.imageSize/2, y: 0)
        secondGatePartnerProfileImageView.transform = CGAffineTransform(translationX: -Constants.imageSize/2, y: 0)

        UIView.animate(withDuration: 0.25, animations: {
            self.linkedProfileImageView.transform = CGAffineTransform.identity
            self.partnerProfileImageView.transform = CGAffineTransform.identity
            self.secondGateProfileImageView.transform = CGAffineTransform.identity
            self.secondGatePartnerProfileImageView.transform = CGAffineTransform.identity
        }) { (_) in
            UIView.animate(withDuration: 0.3) {

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

    @objc private func didTapAddSecondGate() {
        let vc = LinkToPartnerViewController()

        vc.startControlSegment = 0
        vc.onDoneBlock = { [weak self] success in
            
            guard let strongSelf = self else {
                return
            }
            
            if success {
                // Nothing happens here, set up to two gates is fine
            }
            else {
                // Failed to set up second gate, show user a warning and revert to on gate selection
                strongSelf.didNotFindPartnerToLinkTo()
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
            revertToOneGate()
            print("0", UserRunSelections.shared.getIsRunningWithOneGate())

          break
          case 1:
            didTapAddSecondGate()
            print("1", UserRunSelections.shared.getIsRunningWithOneGate())

          break
          default:
            print("DEFAULT", UserRunSelections.shared.getIsRunningWithOneGate())
          break
       }
    }
}


// MARK: - Functions relating to view when linked to partner
extension HomeViewController {
    
    /// Takes us to new view controller where race can be set up.
    @objc private func didTapSetUpRun(sender: UIButton) {
        // Update user selected run type
        if sender.tag == 1 {
            homeViewModel.updateRunType(type: UserRunSelections.runTypes.Reaction)
        }
        else {
            homeViewModel.updateRunType(type: UserRunSelections.runTypes.Sprint)
        }
        // Create SetUp View Controller
        let vc = SetUpRunViewController()
        vc.navigationItem.largeTitleDisplayMode = .always      
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Partner profile pic is tapped. It should show a prompt to ask user if they want to disconnet from partner.
    @objc func didTapToUnlinkFromPartner(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let actionSheet = UIAlertController(title: "Do you wish to disconnect from second gate?",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Disconnect", style: .destructive, handler: { [weak self] _ in
                
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
    
    @objc func didNotFindPartnerToLinkTo() {
        let actionSheet = UIAlertController(title: "Couldn't to find partner to link to.",
                                            message: "",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Run with one gate",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    strongSelf.segmentControl.selectedSegmentIndex = 0
                                                }
                                            }))
        
        present(actionSheet, animated: true)
    }
    
    @objc func revertToOneGate() {
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
                                            handler: { [weak self] _ in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    strongSelf.segmentControl.selectedSegmentIndex = 1
                                                }
                                            }))
        
        present(actionSheet, animated: true)
    }
    
    /// Partner profile pic is tapped. It should show a prompt to ask user if they want to disconnet from partner.
    private func alertThatPartnerHasDisconnected() {
        let actionSheet = UIAlertController(title: "You've been disconnected from partner.",
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

extension HomeViewController {
    
    func addChildController() {
        addChild(launcherViewController)
        view.addSubview(launcherViewController.view)
        launcherViewController.view.frame = view.bounds
        launcherViewController.didMove(toParent: self)
        launcherViewController.view.isHidden = false
    }
}

/// Related to onboarding the user
extension HomeViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        sender.isHidden = true
    }
}
