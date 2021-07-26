//
//  LinkToPartnerViewController.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import UIKit
import JGProgressHUD
import AVFoundation

// This class is tasked with presenting the camera that allows the user to scan a partners QR-code.
// When a QR-code is successfully scanned, we are provided with the partners email.
// The class dismisses itself and returns the safeemail of the partner so that furter operations can be completed from the home VC.
class LinkToPartnerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
// MARK:- Views related to scanning partner QR code
    
    let linkViewModel = LinkToPartnerViewModel()
    
    var startControlSegment = 0
    
    var video = AVCaptureVideoPreviewLayer()
    
    var completion: ((String) -> (Void))?
    
    var overlay: UIView = UIView()
    
    //Create capture session
    let session = AVCaptureSession()
    
    private let spinner = JGProgressHUD()
    
    let segmentControlPanel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Scan Partner QR","My QR Code"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = Constants.mainColor
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = Constants.accentColor
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorMain,
            NSAttributedString.Key.font as NSObject : Constants.mainFontSB!
        ]
        control.setTitleTextAttributes(normalTextAttributes as? [NSAttributedString.Key : Any], for: .normal)
        let selectedAttributes: [NSObject : AnyObject] = [
            NSAttributedString.Key.foregroundColor as NSObject: Constants.textColorWhite,
        ]
        control.setTitleTextAttributes(selectedAttributes as? [NSAttributedString.Key : Any], for: .selected)
        control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        return control
    }()
    
    // MARK:- Views related to Users own QR Code
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    private let detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Constants.mainColor
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
        label.textColor = Constants.textColorMain
        label.font = Constants.mainFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrImageView: UIImageView = {
        let qrImageView = UIImageView()
        qrImageView.backgroundColor = Constants.mainColor
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.contentMode = .scaleAspectFill
        qrImageView.layer.masksToBounds = true
        let image = UIImage(systemName: "qrcode")
        qrImageView.isUserInteractionEnabled = true
        qrImageView.layer.cornerRadius = Constants.cornerRadius
        return qrImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkViewModel.linkViewModelDelegate = self
        linkViewModel.fetchProfilePic()
        
        title = "Connect to Partner"
        view.backgroundColor = Constants.accentColor
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Constants.mainFontLargeSB!,
                                                                         NSAttributedString.Key.foregroundColor: Constants.textColorWhite]
        
        // Makes navigation like rest of panel
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.accentColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        startCameraSession()

        view.addSubview(segmentControlPanel)
        segmentControlPanel.addSubview(segmentControl)
        // Should start on different page depending on sender from home VC
        segmentControl.selectedSegmentIndex = startControlSegment

        segmentControl(segmentControl.self)


        
        
        // Create details to indicate QR-scanning to user
        let x: CGFloat = 60
        let widthOfSquare: CGFloat = view.frame.width - x*2
        let y: CGFloat = (view.frame.height - widthOfSquare) / 2
        let rect = CGRect(x: x, y: y, width: widthOfSquare, height: widthOfSquare)
        //addTransparentOverlayWithCirlce(rect: rect)
        drawFoucusSquare(rect: rect, view: self.view)
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(detailView)
        detailView.addSubview(userImageView)
        detailView.addSubview(userNameLabel)
        detailView.addSubview(qrImageView)
        
        createUserSpecificQRCodeIImage()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        session.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Related to scanning partner users qr code
        
        segmentControlPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        segmentControlPanel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        segmentControlPanel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        segmentControlPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        
        segmentControl.centerYAnchor.constraint(equalTo: segmentControlPanel.centerYAnchor).isActive = true
        segmentControl.centerXAnchor.constraint(equalTo: segmentControlPanel.centerXAnchor).isActive = true
        segmentControl.widthAnchor.constraint(equalTo: segmentControlPanel.widthAnchor, multiplier: 0.9).isActive = true
        segmentControl.heightAnchor.constraint(equalTo: segmentControlPanel.heightAnchor, multiplier: 0.7).isActive = true
        
        // Related to users own QR code
        
        backgroundView.topAnchor.constraint(equalTo: segmentControlPanel.bottomAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        detailView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.verticalSpacing).isActive = true
        detailView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        detailView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.9).isActive = true
        detailView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Constants.largeVerticalSpacing).isActive = true
        
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
        qrImageView.widthAnchor.constraint(equalTo: detailView.widthAnchor, multiplier: 0.65).isActive = true
        qrImageView.heightAnchor.constraint(equalTo: detailView.widthAnchor, multiplier: 0.65).isActive = true
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
        session.stopRunning()
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
             backgroundView.isHidden = true
             session.startRunning()
          break
          case 1:
             backgroundView.isHidden = false
             session.stopRunning()
          break
          default:
            backgroundView.isHidden = true
            session.startRunning()
          break
       }
    }
    
    /// Creates a QR-code for the User, based on the user email.
    func createUserSpecificQRCodeIImage() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String
        else {
            print("No email found")
            return
        }
        print("Email for QR-code", email)
        DispatchQueue.main.async {
            self.qrImageView.image = self.generateQRCodeImage(userIdentifier: email)
            self.qrImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
        }
    }
    
    /// Generates a QR-image based on the passed in string. This should be user email.
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
                    guard let partnerEmail = object.stringValue else {
                        return
                    }
                    // Convert to safe email formate
                    let safePartnerEmail = RaceAppUser.safeEmail(emailAddress: partnerEmail)

                    // We have the data we need, stop the camera from capturing more frames
                    session.stopRunning()
                    
                    print("Found QR-code of partner: ", safePartnerEmail)
                    
                    // Call on viewmodel to update database with new link
                    self.linkViewModel.createNewLink(safePartnerEmail: safePartnerEmail)
                    
                    // Dismiss this view controller and pass on data to HomeViewController
                    dismiss(animated: true, completion: { [weak self] in
                        self?.completion?(safePartnerEmail)
                    })
                }
            }
        }
    }
    
    /// Creates a shaded out area an leaves a prominent square so user should know to look for QR code
    func createOverlay(rect: CGRect) -> UIView {
        
        let overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        let path = CGMutablePath()

        path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)

        path.closeSubpath()
        
        let shape = CAShapeLayer()
        shape.path = path

        overlayView.layer.addSublayer(shape)
        
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
    
    /// Draws the camera focus square
    func drawFoucusSquare(rect: CGRect, view: UIView) -> Void {

        let cornerWidth: CGFloat = 35.0

        let topLeftBezierPath = UIBezierPath()
        topLeftBezierPath.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + cornerWidth))
        topLeftBezierPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
        topLeftBezierPath.addLine(to: CGPoint(x: rect.origin.x + cornerWidth, y: rect.origin.y))

        let topRightBezierPath = UIBezierPath()
        topRightBezierPath.move(to: CGPoint(x: rect.maxX, y: rect.origin.y + cornerWidth))
        topRightBezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.origin.y))
        topRightBezierPath.addLine(to: CGPoint(x: rect.maxX - cornerWidth, y: rect.origin.y))

        let bottomRightBezierPath = UIBezierPath()
        bottomRightBezierPath.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerWidth))
        bottomRightBezierPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        bottomRightBezierPath.addLine(to: CGPoint(x: rect.maxX - cornerWidth, y: rect.maxY))

        let bottomLeftBezierPath = UIBezierPath()
        bottomLeftBezierPath.move(to: CGPoint(x: rect.origin.x, y: rect.maxY - cornerWidth))
        bottomLeftBezierPath.addLine(to: CGPoint(x: rect.origin.x, y: rect.maxY))
        bottomLeftBezierPath.addLine(to: CGPoint(x: rect.origin.x + cornerWidth, y: rect.maxY))

        func cornerLayer(with bezierPath: UIBezierPath) -> CAShapeLayer {
            let shape = CAShapeLayer()
            shape.path = bezierPath.cgPath
            shape.lineWidth = 5.0
            shape.strokeColor = UIColor.white.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.lineCap = .round
            return shape
        }

        let topLeftShape = cornerLayer(with: topLeftBezierPath)
        view.layer.addSublayer(topLeftShape)

        let topRightShape = cornerLayer(with: topRightBezierPath)
        view.layer.addSublayer(topRightShape)

        let bottomRightShape = cornerLayer(with: bottomRightBezierPath)
        view.layer.addSublayer(bottomRightShape)

        let bottomLeftShape = cornerLayer(with: bottomLeftBezierPath)
        view.layer.addSublayer(bottomLeftShape)
        
        return
    }

    func addTransparentOverlayWithCirlce(rect: CGRect){
        overlay = createOverlay(rect: rect)
        view.addSubview(overlay)
    }
}

extension LinkToPartnerViewController: LinkViewModelDelegate {
    // Dismiss this VC when a link has occured. Only checks for all kinds of changes, but should suffice.
    func didUpdateLink() {
        dismiss(animated: true, completion: nil)
    }
    
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.userImageView.image = image
        }
    }
}
