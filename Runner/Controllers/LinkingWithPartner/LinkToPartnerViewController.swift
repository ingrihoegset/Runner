//
//  LinkToPartnerViewController.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import UIKit
import AVFoundation

class RoundedSegmentedControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Constants.smallCornerRadius
    }
}

// This class is tasked with presenting the camera that allows the user to scan a partners QR-code.
// When a QR-code is successfully scanned, we are provided with the partners email.
// The class dismisses itself and returns the safeemail of the partner so that furter operations can be completed from the home VC.
class LinkToPartnerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIAdaptivePresentationControllerDelegate {
    
// MARK:- Views related to scanning partner QR code
    
    let linkViewModel = LinkToPartnerViewModel()
    
    // For all users of app to check if QR represents a user of the app or just random qr
    private var users = [[String: String]]()
    private var hasFetchedUsers = false
    
    var startControlSegment = 0
    
    var video = AVCaptureVideoPreviewLayer()
    
    var completion: ((String) -> (Void))?
    
    var onDoneBlock: ((Bool) -> (Void))?
    
    var linked = false
    
    var overlay: UIView = UIView()
    
    //Create capture session
    let session = AVCaptureSession()
    
    let segmentControlPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let segmentControl: RoundedSegmentedControl = {
        let control = RoundedSegmentedControl(items: ["Scan partner QR","My QR code"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.superLightGrey
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.mainColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorAccent!,
            NSAttributedString.Key.font as NSObject : Constants.mainFontSB!
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
    
    private let qrIndicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.tintColor = Constants.accentColor
        let image = UIImage(named: "QrScanner")
        imageView.image = image
        imageView.alpha = 0.7
        return imageView
    }()
    
    // MARK:- Views related to Users own QR Code
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    private let detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.applySketchShadow(color: Constants.textColorDarkGray, alpha: 0.2, x: 0, y: 0, blur: Constants.sideMargin / 1.5, spread: 0)
        return view
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.accentColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        let image = UIImage(systemName: "person.circle")
        imageView.image = image
        imageView.layer.cornerRadius = Constants.widthOfDisplay * 0.2 / 2
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        let name = UserDefaults.standard.value(forKey: "name") as? String
        label.text = name
        label.textAlignment = .center
        label.textColor = Constants.textColorAccent
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrImageView: UIImageView = {
        let qrImageView = UIImageView()
        qrImageView.backgroundColor = Constants.accentColor
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.contentMode = .scaleAspectFill
        qrImageView.layer.masksToBounds = true
        let image = UIImage(systemName: "qrcode")
        qrImageView.isUserInteractionEnabled = true
        qrImageView.layer.cornerRadius = Constants.cornerRadius
        return qrImageView
    }()
    
    // Is shown when there is no internet connection
    let noConnectionView: NoConnectionView = {
        let view = NoConnectionView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    /// Views related to onboarding
    let onBoardConnect: OnBoardingBubble = {
        let bubble = OnBoardingBubble(frame: .zero, title: "Let partner scan your QR-code to add a second running gate.", pointerPlacement: "topMiddle", dismisser: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.isHidden = true
        return bubble
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkViewModel.linkViewModelDelegate = self
        linkViewModel.fetchProfilePic()
        onBoardConnect.onBoardingBubbleDelegate = self
        
        title = "Add second gate"
        view.backgroundColor = Constants.accentColor
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.textColorAccent!]
        
        // Makes navigation like rest of panel
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.mainColor
        
        navigationController?.navigationBar.tintColor = Constants.accentColorDark
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        // Check if camera is accesible and starts camera session if accessible.
        goToCamera()
        
        view.addSubview(qrIndicatorImageView)
        view.addSubview(segmentControlPanel)
        segmentControlPanel.addSubview(segmentControl)
        // Should start on different page depending on sender from home VC
        segmentControl.selectedSegmentIndex = startControlSegment

        segmentControl(segmentControl.self)
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(detailView)
        detailView.addSubview(userImageView)
        detailView.addSubview(userNameLabel)
        detailView.addSubview(qrImageView)
        
        createUserSpecificQRCodeIImage()
        
        // Views related to onboarding use
        linkViewModel.showOnboardConnect()
        view.addSubview(onBoardConnect)
        
        // Views related to no connection
        view.addSubview(noConnectionView)
        NetworkManager.isUnreachable { _ in
            self.showNoConnection()
        }
        NetworkManager.isReachable { _ in
            self.showConnection()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showConnection),
            name: NSNotification.Name(Constants.networkIsReachable),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showNoConnection),
            name: NSNotification.Name(Constants.networkIsNotReachable),
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        session.stopRunning()
        onDoneBlock?(linked)
    }
    
    deinit {
        print("DESTROYING \(self)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Related to scanning partner users qr code
        
        segmentControlPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        segmentControlPanel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        segmentControlPanel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        segmentControlPanel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize + 2 * Constants.sideMargin).isActive = true
        
        segmentControl.centerYAnchor.constraint(equalTo: segmentControlPanel.centerYAnchor).isActive = true
        segmentControl.centerXAnchor.constraint(equalTo: segmentControlPanel.centerXAnchor).isActive = true
        segmentControl.widthAnchor.constraint(equalTo: segmentControlPanel.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        segmentControl.heightAnchor.constraint(equalTo: segmentControlPanel.heightAnchor, constant: -Constants.sideMargin * 2).isActive = true
        
        // Related to centering QR-image in visible space in video preview layer
        let g = UILayoutGuide()
        self.view.addLayoutGuide(g)
        g.topAnchor.constraint(equalTo: segmentControlPanel.bottomAnchor).isActive = true
        g.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        g.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        g.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true

        qrIndicatorImageView.centerYAnchor.constraint(equalTo:g.centerYAnchor).isActive = true
        qrIndicatorImageView.centerXAnchor.constraint(equalTo: g.centerXAnchor).isActive = true
        qrIndicatorImageView.heightAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.8).isActive = true
        qrIndicatorImageView.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.8).isActive = true
        
        // Related to users own QR code
        
        backgroundView.topAnchor.constraint(equalTo: segmentControlPanel.bottomAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        detailView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 0.8).isActive = true
        detailView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.sideMargin).isActive = true
        detailView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detailView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        userImageView.topAnchor.constraint(equalTo: detailView.topAnchor, constant: Constants.verticalSpacing).isActive = true
        userImageView.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.2).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: Constants.widthOfDisplay * 0.2).isActive = true
        
        userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalTo: detailView.heightAnchor, multiplier: 0.1).isActive = true
        userNameLabel.widthAnchor.constraint(equalTo: detailView.widthAnchor, multiplier: 0.9).isActive = true
        userNameLabel.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        
        qrImageView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: Constants.verticalSpacing).isActive = true
        qrImageView.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        qrImageView.widthAnchor.constraint(equalTo: detailView.heightAnchor, multiplier: 0.45).isActive = true
        qrImageView.heightAnchor.constraint(equalTo: detailView.heightAnchor, multiplier: 0.45).isActive = true
        
        onBoardConnect.topAnchor.constraint(equalTo: qrImageView.bottomAnchor).isActive = true
        onBoardConnect.centerXAnchor.constraint(equalTo: qrImageView.centerXAnchor).isActive = true
        onBoardConnect.widthAnchor.constraint(equalTo: detailView.widthAnchor, multiplier: 0.85).isActive = true
        onBoardConnect.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.mainButtonSize).isActive = true
        
        noConnectionView.topAnchor.constraint(equalTo: segmentControlPanel.bottomAnchor).isActive = true
        noConnectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        noConnectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        noConnectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
        session.stopRunning()
    }
    
    // To check that QR represents a user of the app
    func searchUsers(query: String) {
        // check if the array has firebase results
        // if it does, filter
        // if it doesnt, fetch then filter
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
             backgroundView.isHidden = true
             session.startRunning()
             onBoardConnect.label.text = "Scan your partners QR-Code to add a second timing gate!"
          break
          case 1:
             backgroundView.isHidden = false
             session.stopRunning()
             onBoardConnect.label.text = "Let partner scan your QR-code to add a second timing gate."
          break
          default:
            backgroundView.isHidden = true
            session.startRunning()
          break
       }
    }
    
    /// Creates a QR-code for the User, based on the user email.
    func createUserSpecificQRCodeIImage() {
        
        guard let userID = UserDefaults.standard.value(forKey: Constants.userID) as? String
        else {
            print("No email found")
            return
        }
        print("Generated QR-code for: ", userID)
        DispatchQueue.main.async {
            self.qrImageView.image = self.generateQRCodeImage(userIdentifier: userID)
            self.qrImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
        }
    }
    
    /// Generates a QR-image based on the passed in string. This should be userID.
    private func generateQRCodeImage(userIdentifier: String) -> UIImage {
        let data = userIdentifier.data(using: .ascii, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        let qrImage = UIImage(ciImage: (filter?.outputImage)!)
        return qrImage
    }
    
    /// Starts camera session
    private func startCameraSession() -> Void {

        //Define capture device
        guard let captureDevice =  AVCaptureDevice.default(for: AVMediaType.video)
        else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        }
        catch {
            print("Error establishing video session")
        }
        
        //The output that is going to come out of our session
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //We are only interested in objects that are of type QR-code
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //Creating a video representation of what we are doing, i.e. we are showing what we are filming
        video = AVCaptureVideoPreviewLayer(session: session)
        
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        session.startRunning()
    }
    
    /// Called each time a frame is received
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    guard let partnerUserID = object.stringValue else {
                        return
                    }
                    
                    // Should check if QR represents a user of the app
                    //If so, proceed to creating a link. Call happens in view model
                    self.linkViewModel.checkIfQRRepresentsUser(partnerUserID: partnerUserID)

                    // We have the data we need, stop the camera from capturing more frames
                    session.stopRunning()
                    
                    print("Found QR-code of partner: ", partnerUserID)
                }
            }
        }
    }
}

extension LinkToPartnerViewController: LinkViewModelDelegate {
    // Dismiss this VC when a link has occured. Only checks for all kinds of changes, but should suffice.
    func didUpdateLink() {
        linked = true
        dismiss(animated: true, completion: nil)
    }
    
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.userImageView.image = image
        }
    }
    
    // Hide onboaring bubble when bubble is closed by user or when a link has occured
    func scanOnboarded() {
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
    
    func failedToConnectError() {
        let failedToConnectAlert = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            // Restart camera so user can scan again
            self.session.startRunning()
        })
        
        let alert = UIAlertController(title: "Couldn't connect second gate",
                                      message: "Something went wrong when trying to connect to a second gate. Check your internet connection and try again.",
                                      preferredStyle: .alert)

        alert.addAction(failedToConnectAlert)
        present(alert, animated: true)
    }
    
    
}

extension LinkToPartnerViewController: OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView) {
        sender.isHidden = true
        linkViewModel.scanOnboarded()
    }
}

/// Related to internet connection
extension LinkToPartnerViewController {
    
    /// Shows the "not connected to internet view" to user
    @objc func showConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 0
        })
    }
    
    @objc func showNoConnection() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noConnectionView.alpha = 1
        })
    }
}

/// Related to checking access to camera
extension LinkToPartnerViewController {
    
    //Makes sure that user has given access to camera before setting up a camerasession
    func goToCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
        case .authorized:
            self.startCameraSession()

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if (granted)
                {
                    self.startCameraSession()
                }
                else
                {
                    self.cameraDenied()
                }
            }

        case .denied:
            self.cameraDenied()

        case .restricted:
            self.cameraRestricted()
        }
    }
    
    // Related to checking camera access
    func cameraRestricted() {
        let alert = UIAlertController(title: "Restricted",
                                      message: "You've been restricted from using the camera on this device. Without camera access this app won't work. Please contact the device owner so they can give you access.",
                                      preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraDenied() {
        DispatchQueue.main.async {
                var alertText = "It looks like your privacy settings are preventing us from accessing your camera. This app needs to access your camera to track your run. You can fix this error by doing the following steps:\n\n1. Close this app.\n\n2. Open the Settings app.\n\n3. Scroll to the bottom and select this app in the list.\n\n4. Turn the camera on.\n\n5. Open this app and try again."

                var alertButton = "OK"
                var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)

                if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
                {
                    alertText = "It looks like your privacy settings are preventing us from accessing your camera. This app needs to access the camera to work. You can fix this error by doing the following steps:\n\n1. Touch the Go button below to open the Settings app.\n\n2. Turn the Camera on.\n\n3. Open this app and try again."

                    alertButton = "Go"

                    goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    })
                }
                let alert = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
                alert.addAction(goAction)
                self.present(alert, animated: true, completion: nil)
        }
    }
}
