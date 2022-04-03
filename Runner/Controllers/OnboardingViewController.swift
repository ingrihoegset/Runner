//
//  OnboardingViewController.swift
//  Runner
//
//  Created by Ingrid on 25/12/2021.
//

import Foundation
import UIKit

protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingComplete()
}

class OnboardingViewController: UIViewController {
    
    weak var onboardingViewControllerDelegate: OnboardingViewControllerDelegate?
    var counter = 0

    let readyButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.mainColorDark
        button.setTitle("Ready...?", for: .normal)
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.addTarget(self, action: #selector(onboard), for: .touchUpInside)
        return button
    }()
    
    let introView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let headerlabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Precision timing"
            label.font = Constants.mainFontXXLargeSB
            label.textColor = Constants.contrastColor
            label.textAlignment = .center
            return label
        }()
        
        let image: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "RunnerOne")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let infoLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.text = "Transform your device into a timing gate for precise measurement of speed and run time."
            label.textAlignment = .center
            label.font = Constants.mainFontSB
            label.numberOfLines = 0
            return label
        }()
        
        view.addSubview(headerlabel)
        view.addSubview(image)
        view.addSubview(infoLabel)

        headerlabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        headerlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        headerlabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        headerlabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        image.topAnchor.constraint(equalTo: headerlabel.bottomAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: Constants.mainButtonSize * 0.5).isActive = true
        image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        infoLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * Constants.sideMargin).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * Constants.sideMargin).isActive = true
                
        return view
    }()
    
    let connectView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0

        let headerlabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Connect"
            label.font = Constants.mainFontXXLargeSB
            label.textColor = Constants.contrastColor
            label.textAlignment = .center
            return label
        }()
        
        let image: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "RunnerTwoColor")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let infoLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.text = "Connect with friends to add more timing gates and more features."
            label.textAlignment = .center
            label.font = Constants.mainFontSB
            label.numberOfLines = 0
            return label
        }()
        
        view.addSubview(headerlabel)
        view.addSubview(image)
        view.addSubview(infoLabel)

        headerlabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        headerlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        headerlabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        headerlabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        image.topAnchor.constraint(equalTo: headerlabel.bottomAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: Constants.mainButtonSize * 0.5).isActive = true
        image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        infoLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * Constants.sideMargin).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * Constants.sideMargin).isActive = true
                
        return view
    }()
    
    let statsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0

        let headerlabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Track"
            label.font = Constants.mainFontXXLargeSB
            label.textColor = Constants.contrastColor
            label.textAlignment = .center
            return label
        }()
        
        let image: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "RunnerStats")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let infoLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = .clear
            label.text = "Track and analyze your performance to see how you improve!"
            label.textAlignment = .center
            label.font = Constants.mainFontSB
            label.numberOfLines = 0
            return label
        }()
        
        view.addSubview(headerlabel)
        view.addSubview(image)
        view.addSubview(infoLabel)

        headerlabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        headerlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        headerlabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        headerlabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        image.topAnchor.constraint(equalTo: headerlabel.bottomAnchor).isActive = true
        image.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: Constants.mainButtonSize * 0.5).isActive = true
        image.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sideMargin).isActive = true
        image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        
        infoLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2).isActive = true
        infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * Constants.sideMargin).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * Constants.sideMargin).isActive = true
                
        return view
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        view.addSubview(readyButton)
        view.addSubview(introView)
        view.addSubview(statsView)
        view.addSubview(connectView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        readyButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin * 2).isActive = true
        readyButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        introView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        introView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        introView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        introView.bottomAnchor.constraint(equalTo: readyButton.topAnchor).isActive = true
        
        statsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        statsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        statsView.bottomAnchor.constraint(equalTo: readyButton.topAnchor).isActive = true
        
        connectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        connectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        connectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        connectView.bottomAnchor.constraint(equalTo: readyButton.topAnchor).isActive = true
    }
    
    @objc func onboard() {
        if counter == 0 {
            DispatchQueue.main.async {
                self.readyButton.backgroundColor = Constants.contrastColor
                self.readyButton.setTitle("Set...", for: .normal)
                self.connectView.transform = CGAffineTransform(translationX: 250, y: 0)
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut,
                               animations: {
                                self.introView.transform = CGAffineTransform(translationX: -250, y: 0)
                                self.introView.alpha = 0
                                self.connectView.alpha = 1
                                self.connectView.transform = CGAffineTransform(translationX: 0, y: 0)}, completion: nil)
            }
        }
        else if counter == 1 {
            DispatchQueue.main.async {
                self.readyButton.backgroundColor = Constants.accentGreen
                self.readyButton.setTitle("Go!", for: .normal)
                self.statsView.transform = CGAffineTransform(translationX: 250, y: 0)
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut,
                               animations: {
                                self.connectView.transform = CGAffineTransform(translationX: -250, y: 0)
                                self.connectView.alpha = 0
                                self.statsView.alpha = 1
                                self.statsView.transform = CGAffineTransform(translationX: 0, y: 0)}, completion: nil)
            }
        }
        else {
            onboardingViewControllerDelegate?.onboardingComplete()
        }
        counter += 1
    }
}
