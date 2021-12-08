//
//  ProfileViewController.swift
//  Runner
//
//  Created by Ingrid on 10/07/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

enum SettingsSelectionViewModelType {
    case restore, faq, privacy, units, logout, profilePic, about, contact, membership, shareApp
}

struct SettingSelectionViewModel {
    let viewModelType: SettingsSelectionViewModelType
    var title: String
    let handler: (() -> Void)?
}

class ProfileViewController: UIViewController {
    
    let sectionTitles: [String] = ["Account","Preferences","About app"]
    var section1Data = [SettingSelectionViewModel]()
    var section2Data = [SettingSelectionViewModel]()
    var section3Data = [SettingSelectionViewModel]()
    var sectionData: [Int: [SettingSelectionViewModel]] = [:]
    
    var data = [SettingSelectionViewModel]()
    var profileViewModel = ProfileViewModel()
    var unitTitle = "Units: Metric system"
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = Constants.accentColorDark
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Constants.mainColor
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        let name = UserDefaults.standard.value(forKey: "name") as? String
        label.text = name
        label.textAlignment = .left
        label.textColor = Constants.accentColorDark
        label.backgroundColor = .clear
        label.font = Constants.mainFontLargeSB
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Constants.mainColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        view.backgroundColor = Constants.mainColor
        
        profileViewModel.profileViewModelDelegate = self
        
        view.addSubview(headerView)
        headerView.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(tableView)
        
        tableView.register(SettingsTableViewCell.self,
                           forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        // To make line separator go edge to egde
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        
        // Add gesture to profile image
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentPhotoActionSheet))
        profileImageView.addGestureRecognizer(gesture)
        
        // Units title depends on user preferences
        if let metricSystem = UserDefaults.standard.value(forKey: "unit") as? Bool {
            if metricSystem == true {
                unitTitle = "Units: Metric system"
            }
            else {
                unitTitle = "Units: Imperial system"
            }
        }
        else {
            unitTitle = "Units: Metric system"
        }
        
        // Configure data for table view
        section3Data.append(SettingSelectionViewModel(viewModelType: .faq,
                                              title: "FAQ",
                                              handler: { [weak self] in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                let destinationController = HelpViewController()
                                                strongSelf.navigationController?.pushViewController(destinationController, animated: true)
                                              }))
        /*section3Data.append(SettingSelectionViewModel(viewModelType: .about,
                                              title: "About",
                                              handler: { [weak self] in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                let destinationController = AboutViewController()
                                                strongSelf.navigationController?.pushViewController(destinationController, animated: true)
                                              }))*/
        section3Data.append(SettingSelectionViewModel(viewModelType: .privacy,
                                                      title: "Privacy policy",
                                                      handler: {
                                                        if let url = URL(string: "https://ingrihoegset.wixsite.com/website/services-3-1") {
                                                            UIApplication.shared.open(url)
                                                        }
                                                      }))
        section3Data.append(SettingSelectionViewModel(viewModelType: .contact,
                                                      title: "Contact us",
                                                      handler: {
                                                        if let url = URL(string: "https://ingrihoegset.wixsite.com/website") {
                                                            UIApplication.shared.open(url)
                                                        }
                                                      }))
        section3Data.append(SettingSelectionViewModel(viewModelType: .shareApp,
                                                      title: "Share XXXXX with a friend",
                                                      handler: {
                                                        if let url = URL(string: "https://apps.apple.com/no/app/headlight-flicker-detector/id1528745497?I=nb") {
                                                            let urlToShare = [url]
                                                            let activityController = UIActivityViewController(activityItems: urlToShare, applicationActivities: nil)
                                                            self.present(activityController, animated: true, completion: nil)
                                                        }
                                                      }))
        section2Data.append(SettingSelectionViewModel(viewModelType: .units, title: unitTitle, handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Select preferred units of measurement",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Metric system", style: .default, handler: { [weak self] _ in
                //Metric system is selected
                UserDefaults.standard.set(true, forKey: "unit")
                strongSelf.unitTitle = "Units: Metric system"
                strongSelf.sectionData[1]?[0].title = strongSelf.unitTitle
                self?.tableView.reloadData()
                // Tell My runs to update table so that tableveiw of all runs shows runs in correct unit
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadOnUnitChange"), object: nil)
            }))
            actionSheet.addAction(UIAlertAction(title: "Imperial system", style: .default, handler: { [weak self] _ in
                //Imperial system is selected
                UserDefaults.standard.set(false, forKey: "unit")
                strongSelf.unitTitle = "Units: Imperial system"
                strongSelf.sectionData[1]?[0].title = strongSelf.unitTitle
                self?.tableView.reloadData()
                // Tell My runs to update table so that tableveiw of all runs shows runs in correct unit
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadOnUnitChange"), object: nil)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            strongSelf.present(actionSheet, animated: true)
            

        }))
        section1Data.append(SettingSelectionViewModel(viewModelType: .profilePic,
                                              title: "Change profile picture",
                                              handler: { [weak self] in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                strongSelf.presentPhotoActionSheet()
                                              }))
        section1Data.append(SettingSelectionViewModel(viewModelType: .membership,
                                              title: "My membership",
                                              handler: { [weak self] in
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                let destinationController = MembershipViewController()
                                                strongSelf.navigationController?.pushViewController(destinationController, animated: true)
                                              }))
        section1Data.append(SettingSelectionViewModel(viewModelType: .restore,
                                              title: "Restore purchase",
                                              handler: nil))
        section3Data.append(SettingSelectionViewModel(viewModelType: .logout, title: "Log out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Are you sure you wish to log out?",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self] _ in
                
                guard let strongSelf = self else {
                    return
                }
                
                // Clear any partner link from database
                strongSelf.profileViewModel.clearPartnerLinkFromDatabase()
                
                // Get ride of cached values related to user
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                UserDefaults.standard.setValue(nil, forKey: "partnerEmail")
                UserDefaults.standard.setValue(nil, forKey: Constants.profileImageURL)
                
                // Log Out From Facebook
                FBSDKLoginKit.LoginManager().logOut()
                
                // Log Out From Google
                GIDSignIn.sharedInstance()?.signOut()
                
                // Log out of Firebase session
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    
                    // Dismisses and destroys all view controllers as long as no memory cycle. Can se if VC are destroyed by checking that "deinit" is called.
                    strongSelf.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                }
                catch {
                    print("Failed to log out")
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            
            strongSelf.present(actionSheet, animated: true)
        }))
        
        
        // Add data to sections data
        sectionData = [0: section1Data, 1: section2Data, 2: section3Data]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileViewModel.fetchProfilePic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        profileImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Constants.sideMargin / 2).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constants.displayButtonHeight).isActive = true
        profileImageView.layer.cornerRadius = Constants.displayButtonHeight / 2
        
        userNameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: Constants.sideMargin).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    deinit {
        print("DESTROYED \(self)")
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = sectionData[section]?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Constants.mainColor
        
        let label = UILabel()
        label.text = sectionTitles[section]
        label.textColor = Constants.accentColorDark
        label.font = Constants.mainFontSB
        label.textAlignment = .left
        label.frame = CGRect(x: Constants.sideMargin, y: 15, width: Constants.widthOfDisplay - Constants.sideMargin, height: Constants.mainButtonSize-15)
        view.layer.borderColor = Constants.superLightGrey?.cgColor
        view.layer.borderWidth = 1
        view.addSubview(label)
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = sectionData[indexPath.section]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
        cell.setUp(with: viewModel)
        cell.layoutMargins = UIEdgeInsets(top: 0, left: Constants.sideMargin, bottom: 0, right: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.mainButtonSize
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Call cells handler if one exists
        sectionData[indexPath.section]![indexPath.row].handler?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.mainButtonSize
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}

/// All code assosiated with selecting a profile picture
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Called when user cancels the taking of a picture
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// Called when user takes a photo or selects a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        // Upload Image
        guard let data = selectedImage.pngData() else {
            return
        }
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = RaceAppUser.safeEmail(emailAddress: email)
        let filename = "\(safeEmail)_profile_picture.png"
        
        profileViewModel.updateProfilePicture(data: data, fileName: filename, completion: { [weak self] success in
            if success {
                self?.profileImageView.image = selectedImage
            }
            else {
                self?.alertThatProfilePictureUpdateFailed()
            }
        })
    }
    
    /// Alert that profile picture fail to update.
    private func alertThatProfilePictureUpdateFailed() {
        let actionSheet = UIAlertController(title: "Failed to update profile picture.",
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
    
    /// Creates an action sheet that allows the user to pick whether to take a photo or select a photo from library
    @objc func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Update Profile Picture",
                                            message: "How would you like to select a picture for your profile?",
                                            preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}

class SettingsTableViewCell: UITableViewCell {
    
    // Identifier
    static let identifier = "SettingsTableViewCell"
    
    let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chevron: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(icon)
        contentView.addSubview(label)
        contentView.addSubview(chevron)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        icon.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        icon.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        icon.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        icon.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor).isActive = true
        
        chevron.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        chevron.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        chevron.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        chevron.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    public func setUp(with viewModel: SettingSelectionViewModel) {
        
        let iconColor = Constants.textColorAccent!

        // Set cell label
        self.label.text = viewModel.title
        self.label.font = Constants.mainFont
        self.label.textAlignment = .left
        self.label.textColor = Constants.textColorAccent
        self.backgroundColor = Constants.mainColor
        
        self.chevron.image = UIImage(systemName: "chevron.right")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20))
        
        // Set appearance for type of cell
        switch viewModel.viewModelType {
        case .faq:
            self.icon.image = UIImage(systemName: "questionmark.circle")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .privacy:
            self.icon.image = UIImage(systemName: "lock")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .units:
            self.icon.image = UIImage(systemName: "gauge")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .restore:
            self.icon.image = UIImage(systemName: "tag")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .logout:
            self.label.textColor = .systemRed
            self.icon.image = UIImage(systemName: "nosign")?.withTintColor(UIColor.red, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .profilePic:
            self.icon.image = UIImage(systemName: "person")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .about:
            self.icon.image = UIImage(systemName: "info")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .contact:
            self.icon.image = UIImage(systemName: "quote.bubble")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .membership:
            self.icon.image = UIImage(systemName: "star")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        case .shareApp:
            self.icon.image = UIImage(systemName: "square.and.arrow.up")?.withTintColor(iconColor, renderingMode: .alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15))
        }
    }
}

