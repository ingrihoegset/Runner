//
//  QRLinkViewController.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import UIKit

class QRLinkViewController: UIViewController {

    var qrLinkViewModel = QRLinkViewModel()
    
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

        qrLinkViewModel.qrLinkViewModelDelegate = self
        
        title = "My QR Code"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Constants.textColorWhite]
        
        // Makes navigation bar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        navigationController?.navigationBar.barTintColor = Constants.accentColor


        view.backgroundColor = Constants.accentColorDark
        qrLinkViewModel.fetchProfilePic()
        
        view.addSubview(detailView)
        detailView.addSubview(userImageView)
        detailView.addSubview(userNameLabel)
        detailView.addSubview(qrImageView)

        createUserSpecificQRCodeIImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalSpacing).isActive = true
        detailView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        detailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.largeVerticalSpacing).isActive = true
        
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
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension QRLinkViewController: QRLinkViewModelDelegate {
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
