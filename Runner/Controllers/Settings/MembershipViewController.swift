//
//  MembershipViewController.swift
//  Runner
//
//  Created by Ingrid on 01/11/2021.
//

import UIKit

class MembershipViewController: UIViewController {
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let titleLabel: UITextView = {
        let label = UITextView()
        let firstLineAttributes = [NSAttributedString.Key.foregroundColor: Constants.contrastColor, NSAttributedString.Key.font: Constants.mainFontXLargeSB]
        let secondLineAttributes = [NSAttributedString.Key.foregroundColor: Constants.textColorAccent, NSAttributedString.Key.font: Constants.mainFontLargeSB]
        let firstLine = NSMutableAttributedString(string: "Free eddition\n", attributes: firstLineAttributes as [NSAttributedString.Key : Any])
        let secondLine = NSMutableAttributedString(string: "Available for a limited test periode", attributes: secondLineAttributes as [NSAttributedString.Key : Any])
        let text = NSMutableAttributedString()
        text.append(firstLine)
        text.append(secondLine)
        label.attributedText = text
        label.isScrollEnabled = false
        label.isEditable = false
        label.isSelectable = false
        label.textAlignment = .center
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.mainColor
        return label
    }()
    
    let purchaseButton: BounceButton = {
        let button = BounceButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Constants.contrastColor
        button.setTitle("Upgrade now", for: .normal)
        button.layer.cornerRadius = Constants.smallCornerRadius
        button.clipsToBounds = true
        button.titleLabel?.font = Constants.mainFontLargeSB
        button.animationColor = button.backgroundColor
        button.isHidden = true
        return button
    }()
    
    let row1: CheckView = {
        let view = CheckView(frame: .zero, title: "A selection of running modes", imageName: "checkmark.seal.fill", imageColor: Constants.mainColorDark!)
        view.titleLabel.font = Constants.mainFontLarge
        view.titleLabel.textColor = Constants.textColorAccent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let row2: CheckView = {
        let view = CheckView(frame: .zero, title: "False start", imageName: "checkmark.seal.fill", imageColor: Constants.mainColorDark!)
        view.titleLabel.font = Constants.mainFontLarge
        view.titleLabel.textColor = Constants.textColorAccent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let row3: CheckView = {
        let view = CheckView(frame: .zero, title: "Photo finish", imageName: "checkmark.seal.fill", imageColor: Constants.mainColorDark!)
        view.titleLabel.font = Constants.mainFontLarge
        view.titleLabel.textColor = Constants.textColorAccent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let row4: CheckView = {
        let view = CheckView(frame: .zero, title: "Access to all run data", imageName: "checkmark.seal.fill", imageColor: Constants.mainColorDark!)
        view.titleLabel.font = Constants.mainFontLarge
        view.titleLabel.textColor = Constants.textColorAccent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.mainColor
        view.addSubview(titleLabel)
        view.addSubview(contentView)
        view.addSubview(row1)
        view.addSubview(row2)
        view.addSubview(row3)
        view.addSubview(row4)
        view.addSubview(purchaseButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7).isActive = true
        //titleLabel.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize * 2).isActive = true

        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        contentView.bottomAnchor.constraint(equalTo: purchaseButton.topAnchor, constant: -Constants.sideMargin).isActive = true
        contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        
        row1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        row1.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        row1.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        row1.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        row2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        row2.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        row2.topAnchor.constraint(equalTo: row1.bottomAnchor, constant: Constants.sideMargin).isActive = true
        row2.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        row3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        row3.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        row3.topAnchor.constraint(equalTo: row2.bottomAnchor, constant: Constants.sideMargin).isActive = true
        row3.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        row4.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        row4.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        row4.topAnchor.constraint(equalTo: row3.bottomAnchor, constant: Constants.sideMargin).isActive = true
        row4.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        
        purchaseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        purchaseButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -Constants.sideMargin * 2).isActive = true
        purchaseButton.heightAnchor.constraint(equalToConstant: Constants.mainButtonSize).isActive = true
        purchaseButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.sideMargin).isActive = true
        
    }
}
