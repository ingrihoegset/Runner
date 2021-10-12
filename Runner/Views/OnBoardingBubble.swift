//
//  OnBoardingBubble.swift
//  Runner
//
//  Created by Ingrid on 11/10/2021.
//

import UIKit

protocol OnBoardingBubbleDelegate {
    func handleDismissal(sender: UIView)
}

class OnBoardingBubble: UIView {
    
    var onBoardingBubbleDelegate: OnBoardingBubbleDelegate?
    
    var pointerDirection = "topLeft"
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "xmark")?.withTintColor(Constants.mainColor!)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        button.isUserInteractionEnabled = true
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.mainFont
        label.textColor = Constants.mainColor
        label.clipsToBounds = true
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.textColorDarkGray
        view.layer.cornerRadius = Constants.smallCornerRadius
        return view
    }()
    
    let pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.textColorDarkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        return view
    }()

    init(frame: CGRect, title: String, pointerPlacement: String) {
        super.init(frame: frame)
        self.pointerDirection = pointerPlacement
        self.backgroundColor = .clear
        self.addSubview(backgroundView)
        self.addSubview(pointerView)
        backgroundView.addSubview(label)
        backgroundView.addSubview(closeButton)
        label.text = title
        
    }
    
    override func layoutSubviews() {
        
        pointerView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        pointerView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        if pointerDirection == "topLeft" {
            pointerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            pointerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.sideMargin).isActive = true
            backgroundView.topAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        if pointerDirection == "topMiddle" {
            pointerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            pointerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        if pointerDirection == "bottomRight" {
            pointerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            pointerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.sideMargin).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
        }
        if pointerDirection == "bottomMiddle" {
            pointerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            pointerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
        }
        if pointerDirection == "bottomLeft" {
            pointerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            pointerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.sideMargin).isActive = true
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
        }
        
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        closeButton.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        label.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDismissal() {
        onBoardingBubbleDelegate?.handleDismissal(sender: self)
    }
}
