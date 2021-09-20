//
//  countDownPicker.swift
//  Runner
//
//  Created by Ingrid on 25/08/2021.
//

import Foundation
import UIKit

class CountDownPicker: UIView {
    
    var thousandthLengthValue = 0
    var hundredthLengthValue = 0
    var tenthLengthValue = 0
    var singleLengthValue = 0
    var userSelectedNumber = 0
    
    let pickerLengthBackgroundDetail: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.smallCornerRadius
        view.layer.masksToBounds = false
        return view
    }()
        
    let detail1: UILabel = {
        let detail1 = UILabel()
        detail1.translatesAutoresizingMaskIntoConstraints = false
        detail1.backgroundColor = Constants.accentColor
        detail1.alpha = 1
        detail1.layer.cornerRadius = Constants.smallCornerRadius
        detail1.clipsToBounds = true
        detail1.font = Constants.countDownFont
        detail1.textColor = Constants.textColorDarkGray
        detail1.textAlignment = .center
        return detail1
    }()
        
    let detail2: UILabel = {
        let detail2 = UILabel()
        detail2.translatesAutoresizingMaskIntoConstraints = false
        detail2.backgroundColor = Constants.accentColor
        detail2.alpha = 1
        detail2.layer.cornerRadius = Constants.smallCornerRadius
        detail2.clipsToBounds = true
        detail2.font = Constants.countDownFont
        detail2.textColor = Constants.textColorDarkGray
        detail2.textAlignment = .center
        return detail2
    }()

    init() {
        super.init(frame: .zero)
        self.addSubview(pickerLengthBackgroundDetail)
        pickerLengthBackgroundDetail.addSubview(detail1)
        pickerLengthBackgroundDetail.addSubview(detail2)

        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConstraints() {
        
        pickerLengthBackgroundDetail.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        pickerLengthBackgroundDetail.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        pickerLengthBackgroundDetail.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        pickerLengthBackgroundDetail.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        detail1.leadingAnchor.constraint(equalTo: pickerLengthBackgroundDetail.leadingAnchor, constant: Constants.sideMargin).isActive = true
        detail1.trailingAnchor.constraint(equalTo: pickerLengthBackgroundDetail.centerXAnchor, constant: -2.5).isActive = true
        detail1.topAnchor.constraint(equalTo: pickerLengthBackgroundDetail.topAnchor, constant: Constants.sideMargin).isActive = true
        detail1.bottomAnchor.constraint(equalTo: pickerLengthBackgroundDetail.bottomAnchor, constant: -Constants.sideMargin * 1.5).isActive = true
        
        detail2.leadingAnchor.constraint(equalTo: pickerLengthBackgroundDetail.centerXAnchor, constant: 2.5).isActive = true
        detail2.trailingAnchor.constraint(equalTo: pickerLengthBackgroundDetail.trailingAnchor, constant: -Constants.sideMargin).isActive = true
        detail2.topAnchor.constraint(equalTo: pickerLengthBackgroundDetail.topAnchor, constant: Constants.sideMargin).isActive = true
        detail2.bottomAnchor.constraint(equalTo: pickerLengthBackgroundDetail.bottomAnchor, constant: -Constants.sideMargin * 1.5).isActive = true
    }
}




