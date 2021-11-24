//
//  NoConnectionView.swift
//  Runner
//
//  Created by Ingrid on 23/10/2021.
//

import UIKit

class NoConnectionView: UIView {
    
    let view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.mainColor
        return view
    }()
    
    let imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.contentMode = .scaleAspectFit
        let image = UIImage(systemName: "wifi.slash")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        imageview.image = image
        imageview.backgroundColor = .clear
        return imageview
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.text = "You are offline.\nConnect to the internet in order to use this app!"
        textView.font = Constants.mainFontLarge
        textView.textColor = .gray
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Constants.mainColor
        self.addSubview(view)
        view.addSubview(imageView)
        view.addSubview(textView)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        textView.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        textView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setText(text: String) {
        textView.text = text
    }
}
