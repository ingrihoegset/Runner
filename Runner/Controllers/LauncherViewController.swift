//
//  LauncherViewController.swift
//  Runner
//
//  Created by Ingrid on 27/08/2021.
//

import UIKit
import JGProgressHUD

class LauncherViewController: UIViewController {
    
    let gradientLayerLeft = CAGradientLayer()
    let gradientLayerRight = CAGradientLayer()
    let gradientLayerController = CAGradientLayer()

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
        view.backgroundColor = Constants.superLightGrey
        return view
    }()
    
    private let fakeSegmentControl: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeButtonLeft: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    private let fakeButtonRight: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.superLightGrey
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.addSubview(mainHeaderView)
        mainView.addSubview(fakeSegmentControl)
        mainView.addSubview(fakeButtonLeft)
        mainView.addSubview(fakeButtonRight)
        
        view.backgroundColor = Constants.accentColor
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gradientLayerLeft.frame = fakeButtonLeft.bounds
        gradientLayerRight.frame = fakeButtonRight.bounds
        gradientLayerController.frame = fakeSegmentControl.bounds
        
        gradientLayerLeft.cornerRadius = Constants.smallCornerRadius
        gradientLayerRight.cornerRadius = Constants.smallCornerRadius
        gradientLayerController.cornerRadius = Constants.smallCornerRadius
    }
    
    override func viewDidLayoutSubviews() {
        
        // Elements related to main view
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        mainHeaderView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        mainHeaderView.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        mainHeaderView.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        mainHeaderView.heightAnchor.constraint(equalToConstant: Constants.headerSize).isActive = true
        
        fakeSegmentControl.topAnchor.constraint(equalTo: mainHeaderView.bottomAnchor, constant: Constants.sideMargin * 1.35 + Constants.sideMargin / 2 + Constants.imageSize / 2).isActive = true
        fakeSegmentControl.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        fakeSegmentControl.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: Constants.sideMargin).isActive = true
        fakeSegmentControl.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        fakeButtonLeft.topAnchor.constraint(equalTo: fakeSegmentControl.bottomAnchor, constant: Constants.sideMargin).isActive = true
        fakeButtonLeft.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - Constants.sideMargin * 2).isActive = true
        fakeButtonLeft.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        fakeButtonLeft.centerXAnchor.constraint(equalTo: fakeSegmentControl.centerXAnchor).isActive = true
        
        fakeButtonRight.topAnchor.constraint(equalTo: fakeButtonLeft.bottomAnchor, constant: Constants.sideMargin).isActive = true
        fakeButtonRight.widthAnchor.constraint(equalToConstant: Constants.widthOfDisplay - Constants.sideMargin * 2).isActive = true
        fakeButtonRight.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 1.5).isActive = true
        fakeButtonRight.centerXAnchor.constraint(equalTo: fakeSegmentControl.centerXAnchor).isActive = true
    }
    
    private func setup() {
        
        gradientLayerLeft.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayerLeft.endPoint = CGPoint(x: 1, y: 0.5)
        fakeButtonLeft.layer.addSublayer(gradientLayerLeft)
        
        gradientLayerRight.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayerRight.endPoint = CGPoint(x: 1, y: 0.5)
        fakeButtonRight.layer.addSublayer(gradientLayerRight)
        
        gradientLayerController.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayerController.endPoint = CGPoint(x: 1, y: 0.5)
        fakeSegmentControl.layer.addSublayer(gradientLayerController)
        
        let titleGroup = makeAnimationGroup()
        titleGroup.beginTime = 0.0
        gradientLayerLeft.add(titleGroup, forKey: "backgroundColor")
        gradientLayerRight.add(titleGroup, forKey: "backgroundColor")
        gradientLayerController.add(titleGroup, forKey: "backgroundColor")
    }
    
    private func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.0
        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = Constants.superLightGrey?.cgColor
        anim1.toValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0
        
        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1).cgColor
        anim2.toValue = Constants.superLightGrey?.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration
        
        let group = CAAnimationGroup()
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false
        
        return group
    }
}
