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

class ProfileViewController: UIViewController {
    
    let data = ["Log Out"]
    var profileViewModel = ProfileViewModel()
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    let detailHelperView: UIView = {
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
        imageView.layer.borderColor = Constants.mainColor?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.cornerRadius = Constants.imageSize / 2
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        let name = UserDefaults.standard.value(forKey: "name") as? String
        label.text = name
        label.textAlignment = .center
        label.textColor = Constants.textColorMain
        label.backgroundColor = Constants.mainColor
        label.font = Constants.mainFontLargeSB
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        view.backgroundColor = Constants.accentColor
        
        profileViewModel.profileViewModelDelegate = self
        profileViewModel.fetchProfilePic()
        
        view.addSubview(headerView)
        headerView.addSubview(detailHelperView)
        headerView.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        // To make line separator go edge to egde
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileViewModel.fetchProfilePic()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        detailHelperView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        detailHelperView.heightAnchor.constraint(equalToConstant: Constants.headerSize/2).isActive = true
        detailHelperView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        detailHelperView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        
        userNameLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor).isActive = true
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
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // To make cell divider lines to from edge to edge
        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
                self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
            }
            catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ProfileViewController: ProfileViewModelDelegate {
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}
