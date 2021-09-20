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
        label.textAlignment = .center
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
        imageview.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageview.bottomAnchor.constraint(equalTo: title.topAnchor).isActive = true
        imageview.widthAnchor.constraint(equalTo: imageview.heightAnchor).isActive = true
        
        title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        title.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.3).isActive = true
        title.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        title.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9).isActive = true
    }
    
    
    
    

}
