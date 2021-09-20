//
//  CounterView.swift
//  Runner
//
//  Created by Ingrid on 02/09/2021.
//

import Foundation
import UIKit


class CounterView: UIView {
    
    let minsView: CounterPart = {
        let view = CounterPart()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.masksToBounds = false
        return view
    }()
    
    let secsView: CounterPart = {
        let view = CounterPart()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.masksToBounds = false
        return view
    }()
    
    let hundrethsView: CounterPart = {
        let view = CounterPart()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.masksToBounds = false
        return view
    }()
    
    /*let minutes10s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    
    let minutes1s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    
    let seconds10s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    
    let seconds1s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    
    let hundreths10s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()
    
    let hundreths1s: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.contrastColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textAlignment = .center
        return label
    }()*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(minsView)
        self.addSubview(secsView)
        self.addSubview(hundrethsView)

    }
    
    init() {
        super.init(frame: .zero)
        self.addSubview(minsView)
        self.addSubview(secsView)
        self.addSubview(hundrethsView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        secsView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        secsView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        secsView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        secsView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
        
        minsView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        minsView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        minsView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        minsView.trailingAnchor.constraint(equalTo: secsView.leadingAnchor, constant: -6).isActive = true
        
        hundrethsView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        hundrethsView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        hundrethsView.leadingAnchor.constraint(equalTo: secsView.trailingAnchor, constant: 6).isActive = true
        hundrethsView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}



class CounterPart: UIView {
    
    let first: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textColor = Constants.accentColorDark
        label.textAlignment = .center
        return label
    }()
    
    let second: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Constants.accentColor
        label.font = Constants.mainFontLargeSB
        label.layer.cornerRadius = Constants.smallCornerRadius
        label.clipsToBounds = true
        label.text = "0"
        label.textColor = Constants.accentColorDark
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubview(first)
        self.addSubview(second)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        first.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        first.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        first.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -0.5).isActive = true
        first.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        second.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        second.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        second.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.5).isActive = true
        second.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    
}

