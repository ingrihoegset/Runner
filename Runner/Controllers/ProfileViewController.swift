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
    case restore, help, privacy, units, logout
}

struct SettingSelectionViewModel {
    let viewModelType: SettingsSelectionViewModelType
    let title: String
    let handler: (() -> Void)?
}

class ProfileViewController: UIViewController {
    
    let sectionTitles: [String] = ["About app","Preferences","Account"]
    var section1Data = [SettingSelectionViewModel]()
    var section2Data = [SettingSelectionViewModel]()
    var section3Data = [SettingSelectionViewModel]()
    var sectionData: [Int: [SettingSelectionViewModel]] = [:]
    
    var data = [SettingSelectionViewModel]()
    var profileViewModel = ProfileViewModel()
    
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
        tableView.backgroundColor = Constants.textColorDarkGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        view.backgroundColor = Constants.accentColor
        
        profileViewModel.profileViewModelDelegate = self
        profileViewModel.fetchProfilePic()
        
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
        
        // Configure data for table view
        section1Data.append(SettingSelectionViewModel(viewModelType: .help,
                                              title: "Help",
                                              handler: nil))
        section1Data.append(SettingSelectionViewModel(viewModelType: .privacy,
                                              title: "Privacy policy",
                                              handler: nil))
        section2Data.append(SettingSelectionViewModel(viewModelType: .units,
                                              title: "Units of measurement",
                                              handler: nil))
        section3Data.append(SettingSelectionViewModel(viewModelType: .restore,
                                              title: "Restore purchase",
                                              handler: nil))
        section3Data.append(SettingSelectionViewModel(viewModelType: .logout, title: "Log out", handler: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let actionSheet = UIAlertController(title: "Are you sure you wish to log out?",
                                                message: "",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                
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
        print("DESTROYED PROFIL")
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
        view.backgroundColor = Constants.textColorDarkGray
        
        let label = UILabel()
        label.text = sectionTitles[section]
        label.textColor = Constants.textColorWhite
        label.font = Constants.mainFontSB
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: Constants.widthOfDisplay, height: 60)
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        60
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
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .default,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .cancel,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentPhotoPicker()
        }))
        
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
    
    public func setUp(with viewModel: SettingSelectionViewModel) {

        // Set cell label
        self.textLabel?.text = viewModel.title
        self.textLabel?.font = Constants.mainFont
        self.textLabel?.textAlignment = .center
        self.backgroundColor = Constants.accentColor
        
        // Set appearance for type of cell
        switch viewModel.viewModelType {
        case .help:
            self.textLabel?.textColor = Constants.textColorDarkGray
        case .privacy:
            self.textLabel?.textColor = Constants.textColorDarkGray
        case .units:
            self.textLabel?.textColor = Constants.textColorDarkGray
        case .restore:
            self.textLabel?.textColor = Constants.textColorDarkGray
        case .logout:
            self.textLabel?.textColor = .systemRed
        }
    }
}

