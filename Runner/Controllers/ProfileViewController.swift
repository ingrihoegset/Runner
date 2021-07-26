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
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = Constants.imageSize / 2
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(systemName: "person.circle")
        imageView.layer.borderColor = Constants.accentColorDark?.cgColor
        imageView.layer.borderWidth = Constants.borderWidth
        return imageView
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
        
        // Makes navigation like rest of panel
        self.navigationController?.navigationBar.shadowImage = UIImage()

        navigationController?.navigationBar.barTintColor = Constants.accentColor
        
        profileViewModel.profileViewModelDelegate = self
        profileViewModel.fetchProfilePic()
        
        view.addSubview(headerView)
        headerView.addSubview(profileImageView)
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
        headerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        
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
