//
//  QRLinkViewController.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import UIKit

class QRLinkViewController: UIViewController {
    
    private let linkToLabel: UILabel = {
        let label = UILabel()
        label.text = "Link to"
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        let name = UserDefaults.standard.value(forKey: "name") as? String
        label.text = name
        label.textAlignment = .center
        label.textColor = Constants.textColorWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let qrImageView: UIImageView = {
        let qrImageView = UIImageView()
        qrImageView.backgroundColor = .red
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

        view.backgroundColor = Constants.accentColorDark
        // Makes navigation bar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        view.addSubview(qrImageView)
        view.addSubview(userNameLabel)
        view.addSubview(linkToLabel)
        
        createUserSpecificQRCodeIImage()
        setConstraints()
        
        
    }
    
    private func setConstraints() {
        qrImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        qrImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        qrImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        qrImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        
        userNameLabel.bottomAnchor.constraint(equalTo: qrImageView.topAnchor, constant: Constants.verticalSpacing).isActive = true
        userNameLabel.heightAnchor.constraint(equalTo: qrImageView.heightAnchor, multiplier: 0.4).isActive = true
        userNameLabel.widthAnchor.constraint(equalTo: qrImageView.widthAnchor).isActive = true
        userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        linkToLabel.bottomAnchor.constraint(equalTo: userNameLabel.topAnchor, constant: Constants.verticalSpacing).isActive = true
        linkToLabel.heightAnchor.constraint(equalTo: userNameLabel.heightAnchor).isActive = true
        linkToLabel.widthAnchor.constraint(equalTo: userNameLabel.widthAnchor).isActive = true
        linkToLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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

}
