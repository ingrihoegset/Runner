//
//  OnBoardingBubble.swift
//  Runner
//
//  Created by Ingrid on 11/10/2021.
//

import UIKit

protocol OnBoardingBubbleDelegate {
    func handleDismissal()
}

class OnBoardingBubble: UIView {
    
    var onBoardingBubbleDelegate: OnBoardingBubbleDelegate?
    
    var pointerDirection = "topLeft"
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.textColorDarkGray
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
        label.backgroundColor = Constants.textColorDarkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.mainFont
        label.textColor = Constants.mainColor
        label.clipsToBounds = true
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        label.textAlignment = .center
        return label
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
        self.backgroundColor = .clear
        self.addSubview(pointerView)
        self.addSubview(label)
        self.addSubview(closeButton)
        label.text = title
        
    }
    
    override func layoutSubviews() {
        
        if pointerDirection == "topLeft" {
            pointerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            pointerView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            pointerView.widthAnchor.constraint(equalToConstant: 15).isActive = true
            pointerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.sideMargin).isActive = true
        }
        
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
        
        label.topAnchor.constraint(equalTo: pointerView.centerYAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleDismissal() {
        onBoardingBubbleDelegate?.handleDismissal()
    }
}
