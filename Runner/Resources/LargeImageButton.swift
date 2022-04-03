//
//  LargeImageButton.swift
//  Runner
//
//  Created by Ingrid on 20/09/2021.
//

import UIKit

class LargeImageButton: UIButton {
    
    
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = Constants.mainFontLargeSB
        label.textColor = Constants.textColorWhite
        return label
    }()
    
    let imageview: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.backgroundColor = .clear
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    
    var animationColor: UIColor?
    
    /// Does animation before "forwarding" button action as specified elsewhere
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        startAnimation(completion: {_ in
            super.sendAction(action, to: target, for: event)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageview)
        self.addSubview(title)
        self.layer.cornerRadius = Constants.smallCornerRadius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        imageview.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageview.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageview.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7).isActive = true
        imageview.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        title.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9).isActive = true
        title.leadingAnchor.constraint(equalTo: imageview.trailingAnchor).isActive = true
        title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Constants.sideMargin).isActive = true
    }
    
    func startAnimation(completion: @ escaping (Bool) -> Void) {

        let originalColor = self.backgroundColor
        let transitionColor = animationColor ?? Constants.mainColor
        self.backgroundColor = transitionColor

        UIView.animate(withDuration: 0.15,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.15,
                    animations: {
                        self.transform = CGAffineTransform.identity
                        self.backgroundColor = originalColor
                    },
                    completion: { _ in
                        completion(true)
                        
                    })
            })
    }
}
