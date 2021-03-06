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
    let onboardingViewController = OnboardingViewController()
    
    private let logo: UIImageView = {
        let label = UIImageView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.image = UIImage(named: "RUNSNAPPER")
        label.contentMode = .scaleAspectFit
        return label
    }()
        
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
        view.backgroundColor = .clear
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        let image = UIImage(named: "Image")
        imageView.image = image
        return view
    }()
    
    // MARK: - Elements related to temporary views while loading
    let gradientLayerProfile = CAGradientLayer()
    let gradientLayerQrButton = CAGradientLayer()
    
    private let loadingProfileImageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    private let loadingQrButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.clipsToBounds = true
        view.alpha = 0
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
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Constants.textColorDarkGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        return imageView
    }()

    private let qrButton: BounceButton = {
        let qrButton = BounceButton()
        qrButton.backgroundColor = Constants.contrastColor
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.layer.masksToBounds = false
        qrButton.clipsToBounds = false
        qrButton.animationColor = Constants.contrastColor
        let image = UIImage(named: "QrCode")?.withTintColor(Constants.mainColor!, renderingMode: .alwaysOriginal)
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
        qrButton.alpha = 0
        qrButton.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.4, x: 0, y: 0, blur: Constants.sideMargin / 1.5 , spread: 0)
        return qrButton
    }()
    
    private let qrImage: UIImage = {
        let qrImage = UIImage()
        return qrImage
    }()
    
    let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let setUpSprintButton: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.animationColor = Constants.mainColor
        button.imageview.image = UIImage(named: "Sprint")?.withTintColor(Constants.mainColorDarkest!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.title.text = "Sprint"
        button.title.textColor = Constants.mainColorDarkest
        button.addTarget(self, action: #selector(didTapSetUpRun), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        button.alpha = 0
        return button
    }()
    
    let setUpReactionButton: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.animationColor = Constants.mainColor
        button.tag = 1
        let image = UIImage(named: "Reaction")
        button.imageview.image = UIImage(named: "Reaction")?.withTintColor(Constants.mainColorDarkest!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.title.text = "Reaction run"
        button.title.textColor = Constants.mainColorDarkest
        button.addTarget(self, action: #selector(didTapSetUpRun), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        button.alpha = 0
        return button
    }()
    
    let setUpFlyingStartButton: LargeImageButton = {
        let button = LargeImageButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColor
        button.animationColor = Constants.mainColor
        button.tag = 2
        button.imageview.image = UIImage(named: "Flying")?.withTintColor(Constants.mainColorDarkest!)
        button.imageview.isOpaque = true
        button.imageview.alpha = 1
        button.title.text = "Flying start"
        button.title.textColor = Constants.mainColorDarkest
        button.addTarget(self, action: #selector(alertUserThatFlyingStartOnlyAvailableWhenConnected), for: .touchUpInside)
        button.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        button.alpha = 0
        return button
    }()

    // MARK: - Elements related to linked view, first gate
    private let linkedHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private let linkedProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = Constants.textColorDarkGray
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let partnerProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Constants.mainColor
        imageView.tintColor = Constants.textColorDarkGray
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Elements related to linked view, second gate
    private let secondGateHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private let secondGateProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = Constants.textColorDarkGray
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let secondGatePartnerProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = Constants.mainColorDark?.cgColor
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
        view.alpha = 0
        return view
    }()
    
    private let openSecondGatesButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColorDark
        button.setTitle("Open end gate", for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(didSelectOpenSecondGate), for: .touchUpInside)
        return button
    }()
    
    let segmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " Number of timing gates"
        label.font = Constants.mainFont
        label.textColor = Constants.textColorAccent
        label.textAlignment = .left
        label.alpha = 0
        return label
    }()
    
    let segmentControl: RoundedSegmentedControl = {
        let control = RoundedSegmentedControl(items: ["1 Gate","2 Gates"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.contrastColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorAccent!,
            NSAttributedString.Key.font as NSObject : Constants.mainFontLargeSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.mainColor!,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        control.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        control.alpha = 0
        return control
    }()
    
    /// Views related to onboarding
    let onBoardConnect: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Connect to partner to add second timing gate and unlock more features!", pointerPlacement: "topMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.isHidden = true
        bubble.tag = 0
        return bubble
    }()
    
    let onBoardEndGate: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Open end gate to create a finish line!", pointerPlacement: "bottomMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.isHidden = true
        bubble.tag = 1
        return bubble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Constants.mainColor
        
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        
        homeViewModel.homeViewModelDelegate = self
        onBoardConnect.onBoardingBubbleDelegate = self
        onBoardEndGate.onBoardingBubbleDelegate = self
        onboardingViewController.onboardingViewControllerDelegate = self

        // Related to main view
        view.addSubview(mainView)
        mainView.addSubview(mainHeaderView)
        
        // Set loading view
        mainView.addSubview(loadingProfileImageView)
        mainView.addSubview(loadingQrButton)
        
        // Set profile header, that is active when not linked
        mainView.addSubview(unconnectedHeaderView)
        mainView.addSubview(qrButton)
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
        
        mainView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(setUpSprintButton)
        contentView.addSubview(setUpReactionButton)
        contentView.addSubview(setUpFlyingStartButton)
        
        // Related to view show when user is second gate
        mainView.addSubview(secondGateView)
        secondGateView.addSubview(openSecondGatesButton)
        secondGateView.addSubview(onBoardEndGate)
        
        view.addSubview(logo)
        
        mainView.bringSubviewToFront(qrButton)
        mainView.bringSubviewToFront(onBoardConnect)

        // Remove in case there are lingering links or "ongoing" runs
        homeViewModel.clearLinkFromDatabase()
        homeViewModel.removeCurrentRun()
        
        // Related to onboarding
        homeViewModel.showOnboardEndGate()
        
        // Set camera sensitivity
        setCameraSensitivity()
        
        // Show onboarding images
        showOnboardingImages()
    }
    
    func showOnboardingImages() {
        if UserDefaults.standard.bool(forKey: Constants.firstLaunch) == true {
            let popupController = onboardingViewController
            popupController.view.alpha = 1
            popupController.modalPresentationStyle = .overFullScreen
            self.present(popupController, animated: false, completion: nil)
        }
        else {
            startAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Skeleton loading setup
        setup()
        
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
        super.viewDidAppear(true)
        // For skeleton loading of header images
        
        gradientLayerProfile.frame = loadingProfileImageView.bounds
        gradientLayerQrButton.frame = loadingQrButton.bounds
        loadingProfileImageView.layer.cornerRadius = Constants.imageSize / 2
        loadingQrButton.layer.cornerRadius = (Constants.imageSize * 0.6) / 2

        if let userID = UserDefaults.standard.value(forKey: Constants.userID) as? String {
            homeViewModel.fetchProfilePicture(userID: userID)
        }
        else {
            print("No userID found when trying to initiate profile pic download")
        }
        
        // Will show onboard connect if ready for it
        homeViewModel.showOnboardConnect()
    }
    
    deinit {
        print("DESTROYING")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.sideMargin * 1.5).isActive = true
        logo.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        logo.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.6).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Elements related to main view
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        mainHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        mainHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        // Loading views
        loadingProfileImageView.centerYAnchor.constraint(equalTo: mainHeaderView.bottomAnchor).isActive = true
        loadingProfileImageView.centerXAnchor.constraint(equalTo: mainHeaderView.centerXAnchor).isActive = true
        loadingProfileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        loadingProfileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
    
        loadingQrButton.leadingAnchor.constraint(equalTo: loadingProfileImageView.trailingAnchor, constant: -Constants.borderWidth).isActive = true
        loadingQrButton.centerYAnchor.constraint(equalTo: loadingProfileImageView.centerYAnchor).isActive = true
        loadingQrButton.widthAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        loadingQrButton.heightAnchor.constraint(equalToConstant: Constants.imageSize * 0.6).isActive = true
        
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
        
        onBoardConnect.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 5).isActive = true
        onBoardConnect.centerXAnchor.constraint(equalTo: segmentControl.centerXAnchor).isActive = true
        onBoardConnect.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 0.85).isActive = true
        onBoardConnect.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2.25).isActive = true
        
        // Selections shown when no link
        scrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: Constants.sideMargin / 2).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        setUpSprintButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        setUpSprintButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.sideMargin / 2).isActive = true
        setUpSprintButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        setUpSprintButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        
        setUpReactionButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        setUpReactionButton.topAnchor.constraint(equalTo: setUpSprintButton.bottomAnchor, constant: Constants.sideMargin).isActive = true
        setUpReactionButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        setUpReactionButton.heightAnchor.constraint(equalTo: setUpSprintButton.heightAnchor).isActive = true

        setUpFlyingStartButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        setUpFlyingStartButton.topAnchor.constraint(equalTo: setUpReactionButton.bottomAnchor, constant: Constants.sideMargin).isActive = true
        setUpFlyingStartButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        setUpFlyingStartButton.heightAnchor.constraint(equalTo: setUpSprintButton.heightAnchor).isActive = true
        setUpFlyingStartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        
        // Elements related to second gate view
        secondGateView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
        secondGateView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        secondGateView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        secondGateView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        openSecondGatesButton.bottomAnchor.constraint(equalTo: secondGateView.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        openSecondGatesButton.leadingAnchor.constraint(equalTo: secondGateView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        openSecondGatesButton.trailingAnchor.constraint(equalTo: secondGateView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        openSecondGatesButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        onBoardEndGate.bottomAnchor.constraint(equalTo: openSecondGatesButton.topAnchor, constant: -5).isActive = true
        onBoardEndGate.widthAnchor.constraint(equalTo: openSecondGatesButton.widthAnchor, multiplier: 0.6).isActive = true
        onBoardEndGate.centerXAnchor.constraint(equalTo: openSecondGatesButton.centerXAnchor).isActive = true
        onBoardEndGate.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
    }
    
    /// QR-button is tapped. It should reveal the users QR-code for scanning.
    @objc func didTapQRButton() {
        // Onboarding of connect is completed when user selects this button
        homeViewModel.hasOnboardedConnect()
        // Send user to linking views
        let vc = LinkToPartnerViewController()
        vc.startControlSegment = 1
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func didFetchProfileImage(image: UIImage, fetchedUserID: String) {
        print("Fetched home profile image")
        
        guard let userID = UserDefaults.standard.value(forKey: Constants.userID) as? String else {
            return
        }

        // If userID used in call doesnt match our users email, then we update partner image.
        // Otherwise, update our users image.
        DispatchQueue.main.async {
            if fetchedUserID != userID {
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
        }
    }
    
    func failedToFetchProfileImage() {
        animateUnlink()
    }
    
    private func setup() {
        
        gradientLayerProfile.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayerProfile.endPoint = CGPoint(x: 1, y: 0.5)
        loadingProfileImageView.layer.addSublayer(gradientLayerProfile)
        
        gradientLayerQrButton.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayerQrButton.endPoint = CGPoint(x: 1, y: 0.5)
        loadingQrButton.layer.addSublayer(gradientLayerQrButton)
        
        let titleGroup = makeAnimationGroup()
        titleGroup.beginTime = 0.0
        gradientLayerProfile.add(titleGroup, forKey: "backgroundColor")
        gradientLayerQrButton.add(titleGroup, forKey: "backgroundColor")
    }
    
    private func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.0
        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = Constants.superLightGrey?.cgColor
        anim1.toValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0
        
        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim2.toValue = Constants.superLightGrey?.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration
        
        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false
        
        return group
    }
    
    func startAnimation() {
        
        segmentLabel.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay / 2)
        segmentControl.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay / 2)
        setUpSprintButton.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay / 2)
        setUpReactionButton.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay / 2)
        setUpFlyingStartButton.transform = CGAffineTransform(translationX: 0, y: Constants.heightOfDisplay / 2)
        qrButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        qrButton.alpha = 1
        
        UIView.animate(withDuration: 0.3,
            animations: {
                self.loadingProfileImageView.alpha = 1
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
                    self.segmentLabel.transform = CGAffineTransform.identity
                    self.segmentControl.transform = CGAffineTransform.identity
                    self.segmentLabel.alpha = 1
                    self.segmentControl.alpha = 1
                    UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut) {
                        self.setUpSprintButton.transform = CGAffineTransform.identity
                        self.setUpSprintButton.alpha = 1
                    }
                    UIView.animate(withDuration: 0.4, delay: 0.4, options: .curveEaseOut) {
                        self.setUpReactionButton.transform = CGAffineTransform.identity
                        self.setUpReactionButton.alpha = 1
                    }
                    UIView.animate(withDuration: 0.4, delay: 0.6, options: .curveEaseOut) {
                        self.setUpFlyingStartButton.transform = CGAffineTransform.identity
                        self.setUpFlyingStartButton.alpha = 1
                    }
                })
            })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState,
            animations: {
                self.qrButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2,
                    animations: {
                        self.qrButton.transform = CGAffineTransform.identity
                    })
            })
    }

    
    // Gets and updates UI elements in accordance with successful link with partner
    // Is triggered by home view model when a change to link occurs. If a link is found, else is activated, view shows linked view.
    func updateUiUnconnected() {
        print("Show UI as not connected")
        // Show
        self.loadingProfileImageView.alpha = 1
        self.loadingQrButton.alpha = 1
        self.unconnectedHeaderView.alpha = 1
        self.scrollView.alpha = 1
        self.qrButton.alpha = 1
        // Hide
        self.linkedHeaderView.alpha = 0
        self.secondGateHeaderView.alpha = 0
        self.secondGateView.alpha = 0
        // Update segment Controller as well
        self.segmentControl.selectedSegmentIndex = 0
        
        // Make sure user cannot select flying start when not connected
        self.setUpFlyingStartButton.backgroundColor = Constants.superLightGrey
        self.setUpFlyingStartButton.removeTarget(nil, action: #selector(didTapSetUpRun(sender:)), for: .touchUpInside)
        self.setUpFlyingStartButton.addTarget(self, action: #selector(alertUserThatFlyingStartOnlyAvailableWhenConnected), for: .touchUpInside)
    }
    
    func updateUiConnectedStartGate() {
        UIView.animate(withDuration: 0.3) {
            // Show
            self.linkedHeaderView.alpha = 1
            self.scrollView.alpha = 1
            
            // Hide
            self.loadingProfileImageView.alpha = 0
            self.loadingQrButton.alpha = 0
            self.unconnectedHeaderView.alpha = 0
            self.secondGateHeaderView.alpha = 0
            self.secondGateView.alpha = 0
            self.qrButton.alpha = 0
        }
        
        // Update segment Controller as well
        self.segmentControl.selectedSegmentIndex = 1
        
        // Make sure user CAN select flying start when not connected
        self.setUpFlyingStartButton.backgroundColor = Constants.mainColor
        self.setUpFlyingStartButton.removeTarget(nil, action: #selector(alertUserThatFlyingStartOnlyAvailableWhenConnected), for: .touchUpInside)
        self.setUpFlyingStartButton.addTarget(self, action: #selector(didTapSetUpRun(sender:)), for: .touchUpInside)
    }
    
    func updateUiConnectedEndGate() {
        UIView.animate(withDuration: 0.3) {
            // Show
            self.secondGateHeaderView.alpha = 1
            self.secondGateView.alpha = 1
            
            // Hide
            self.loadingProfileImageView.alpha = 0
            self.loadingQrButton.alpha = 0
            self.unconnectedHeaderView.alpha = 0
            self.linkedHeaderView.alpha = 0
            self.scrollView.alpha = 0
            self.qrButton.alpha = 0
        }

        // Update segment Controller as well
        self.segmentControl.selectedSegmentIndex = 1
        
        // Make sure user CAN select flying start when not connected
        self.setUpFlyingStartButton.backgroundColor = Constants.mainColor
        self.setUpFlyingStartButton.removeTarget(nil, action: #selector(alertUserThatFlyingStartOnlyAvailableWhenConnected), for: .touchUpInside)
        self.setUpFlyingStartButton.addTarget(self, action: #selector(didTapSetUpRun(sender:)), for: .touchUpInside)
    }
    
    func updatePartnerImage(image: UIImage) {
        DispatchQueue.main.async {
            self.partnerProfileImageView.image = image
            self.secondGatePartnerProfileImageView.image = image
        }
    }
    
    func updateUserImage(image: UIImage) {
        DispatchQueue.main.async {
            self.unconnectedprofileImageView.image = image
            self.linkedProfileImageView.image = image
            self.secondGateProfileImageView.image = image
        }
    }
    
    func animateUnlink() {
        DispatchQueue.main.async {
            self.unconnectedprofileImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.unconnectedprofileImageView.alpha = 1
            UIView.animate(withDuration: 0.4,
                animations: {
                    self.unconnectedprofileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.15,
                        animations: {
                            self.unconnectedprofileImageView.transform = CGAffineTransform.identity
                        })
                })
        }
    }
    
    func animateLinkedPartnerUI() {
        print("animate linked")
        
        //linkedProfileImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        partnerProfileImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        //secondGateProfileImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        secondGatePartnerProfileImageView.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: 0.4, animations: {
           // self.linkedProfileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.partnerProfileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
           // self.secondGateProfileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.secondGatePartnerProfileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (_) in
            UIView.animate(withDuration: 0.2) {
                //self.linkedProfileImageView.transform = CGAffineTransform.identity
                self.partnerProfileImageView.transform = CGAffineTransform.identity
                //self.secondGateProfileImageView.transform = CGAffineTransform.identity
                self.secondGatePartnerProfileImageView.transform = CGAffineTransform.identity

            }
        }
    }
    
    func alertUserThatIsDisconnectedFromPartner() {
        let actionSheet = UIAlertController(title: "You've been disconnected from partner. \nRunning with 1 gate.",
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
    
    @objc func alertUserThatFlyingStartOnlyAvailableWhenConnected() {
        let actionSheet = UIAlertController(title: "Add second gate",
                                            message: "You must be connected to second gate to set up flying start.",
                                            preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popToRootViewController(animated: true)
        }))
        present(actionSheet, animated: true)
    }
    
    func didGetRunResult(result: RunResults) {
        /*let vc = ResultsViewController()
        vc.result = result
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)*/
    }
    
    func hasOnboardedConnect() {
        DispatchQueue.main.async {
            self.onBoardConnect.isHidden = true
        }
    }
    
    func showOnboardConnect() {
        DispatchQueue.main.async {
            self.onBoardConnect.isHidden = false
            self.onBoardConnect.animateOnboardingBubble()
        }
    }
    
    func showOnboardedOpenEndGate() {
        DispatchQueue.main.async {
            self.onBoardEndGate.isHidden = false
            self.onBoardEndGate.animateOnboardingBubble()
        }
    }
    
    func hasOnboardedEndGate() {
        DispatchQueue.main.async {
            self.onBoardEndGate.isHidden = true
        }
    }
    func setCameraSensitivity() {
        if UserDefaults.standard.value(forKey: Constants.cameraSensitivity) == nil {
            UserDefaults.standard.setValue(CGFloat(0.1), forKey: Constants.cameraSensitivity)
        }
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
        // Makes onboarding bubble disappear or never appear since user has already tested feature
        homeViewModel.hasOnboardedConnect()
        // Switch to connect to partner or disconnect from partner
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
        else if sender.tag == 2 {
            homeViewModel.updateRunType(type: UserRunSelections.runTypes.FlyingStart)
        }
        else {
            homeViewModel.updateRunType(type: UserRunSelections.runTypes.Sprint)
        }
        // Create SetUp View Controller
        let vc = SetUpRunViewController()
        vc.navigationItem.largeTitleDisplayMode = .always      
        navigationController?.pushViewController(vc, animated: true)
        
        // Tell Home view that it is ready to show connect to partner onboarding next time it appears
        homeViewModel.readyToOnboardConnect()
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

    
    
    // MARK: - Functions related to second gate
    @objc private func didSelectOpenSecondGate(sender: UIButton) {
        let vc = SecondGateViewController()
        
        navigationController?.pushViewController(vc, animated: true)
        
        // User has been onboarded to end gate
        homeViewModel.hasOnboardedEndGate()
    }
}

/// Related to onboarding the user
extension HomeViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        sender.isHidden = true
        // Update user defaults so that these bubbles are never shown again
        if sender.tag == 0 {
            homeViewModel.hasOnboardedConnect()
        }
        if sender.tag == 1 {
            homeViewModel.hasOnboardedEndGate()
        }
    }
}

extension HomeViewController: OnboardingViewControllerDelegate {
    func onboardingComplete() {
        UserDefaults.standard.set(false, forKey: Constants.firstLaunch)
        UIView.animate(withDuration: 0.3,
            animations: {
                self.onboardingViewController.view.alpha = 0
            },
            completion: { _ in
                self.onboardingViewController.dismiss(animated: false, completion: nil)
                self.startAnimation()
            })
    }
}
