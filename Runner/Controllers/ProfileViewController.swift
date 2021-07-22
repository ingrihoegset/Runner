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
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
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
        view.backgroundColor = Constants.mainColor
        
        profileViewModel.profileViewModelDelegate = self
        profileViewModel.fetchProfilePic()
        
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileViewModel.fetchProfilePic()
    }
    
    func createTableHeader() -> UIView? {     
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: self.view.width,
                                              height: 200))
        
        headerView.backgroundColor = .link
        
        profileImageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: 25,
                                                  width: 150,
                                                  height: 150))
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderColor = Constants.accentColorDark?.cgColor
        profileImageView.layer.borderWidth = Constants.borderWidth
        profileImageView.layer.cornerRadius = profileImageView.width / 2
        profileImageView.layer.masksToBounds = true
        headerView.addSubview(profileImageView)
        
        
        
        return headerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
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
}

extension ProfileViewController: ProfileViewModelDelegate {
    func didFetchProfileImage(image: UIImage) {
        DispatchQueue.main.async {
            self.profileImageView.image = image
        }
    }
}
