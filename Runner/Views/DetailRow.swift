//
//  DetailRow.swift
//  Timer
//
//  Created by Ingrid on 16/11/2020.
//  Copyright © 2020 Ingrid. All rights reserved.
//

import Foundation
import UIKit

class DetailRow: UIView {
    
    let unitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.textColor = Constants.textColorWhite
        label.textAlignment = .center
        label.font = Constants.mainFont
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.textColor = Constants.textColorWhite
        label.textAlignment = .center
        label.font = Constants.mainFontLargeSB
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = Constants.textColorWhite
        label.textAlignment = .left
        label.font = Constants.mainFont
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(unitLabel)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProperties(title: String, unit: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
        unitLabel.text = unit
    }
    
    func setConstraints() {
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 9/16).isActive = true
        
        detailLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        detailLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 4/16).isActive = true
        
        unitLabel.leadingAnchor.constraint(equalTo: detailLabel.trailingAnchor).isActive = true
        unitLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        unitLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        unitLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}
