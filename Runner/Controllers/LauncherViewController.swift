//
//  LauncherViewController.swift
//  Runner
//
//  Created by Ingrid on 27/08/2021.
//

import UIKit
import JGProgressHUD

class LauncherViewController: UIViewController {

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.style = .large
        spinner.color = Constants.accentColorDark
        return spinner
    }()

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
        view.backgroundColor = Constants.accentColor
        return view
    }()
    
    private let detailHelperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.addSubview(mainHeaderView)
        mainView.addSubview(spinner)
        mainHeaderView.addSubview(detailHelperView)
        
        view.backgroundColor = Constants.accentColor
        
        spinner.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        
        // Elements related to main view
        mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        spinner.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 50).isActive = true
        spinner.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        mainHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        mainHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        detailHelperView.bottomAnchor.constraint(equalTo: mainHeaderView.bottomAnchor).isActive = true
        detailHelperView.heightAnchor.constraint(equalToConstant: Constants.headerSize/2).isActive = true
        detailHelperView.leadingAnchor.constraint(equalTo: mainHeaderView.leadingAnchor).isActive = true
        detailHelperView.trailingAnchor.constraint(equalTo: mainHeaderView.trailingAnchor).isActive = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
