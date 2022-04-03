//
//  infoCell.swift
//  Runner
//
//  Created by Ingrid on 03/12/2021.
//

import UIKit

class InfoCell: UITableViewCell {
    
    static let identifier = "InfoCell"
    
    let label: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        label.isScrollEnabled = false
        label.isUserInteractionEnabled = false
        label.backgroundColor = Constants.mainColor
        label.font = Constants.mainFont
        label.textColor = Constants.mainColorDarkest
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
    }
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, infoText: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        label.text = infoText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}
