//
//  LoadingBalls.swift
//  Runner
//
//  Created by Ingrid on 28/10/2021.
//

import Foundation
import UIKit

class LoadingBalls: UIView {
    
    var duration: Double = 0
    
    let circle1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1
        return view
    }()
    
    let circle2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1
        return view
    }()
    
    let circle3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1
        return view
    }()
    
    let circle4: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1
        return view
    }()
    
    let circle5: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, color: UIColor, duration: Double) {
        super.init(frame: frame)
        self.isHidden = true
        
        circle1.backgroundColor = color
        circle2.backgroundColor = color
        circle3.backgroundColor = color
        circle4.backgroundColor = color
        circle5.backgroundColor = color
        
        self.addSubview(circle1)
        self.addSubview(circle2)
        self.addSubview(circle3)
        self.addSubview(circle4)
        self.addSubview(circle5)
        
        self.duration = duration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let width = frame.width
        let widthOfCircle = width/8
        let spacing = width/5
        
        circle1.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0 * spacing).isActive = true
        circle1.widthAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle1.heightAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle1.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circle1.layer.cornerRadius = widthOfCircle / 2
        
        circle2.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1 * spacing).isActive = true
        circle2.widthAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle2.heightAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle2.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circle2.layer.cornerRadius = widthOfCircle / 2
        
        circle3.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2 * spacing).isActive = true
        circle3.widthAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle3.heightAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle3.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circle3.layer.cornerRadius = widthOfCircle / 2
        
        circle4.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3 * spacing).isActive = true
        circle4.widthAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle4.heightAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle4.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circle4.layer.cornerRadius = widthOfCircle / 2
        
        circle5.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4 * spacing).isActive = true
        circle5.widthAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle5.heightAnchor.constraint(equalToConstant: widthOfCircle).isActive = true
        circle5.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        circle5.layer.cornerRadius = widthOfCircle / 2
    }
    
    private func animateCircle(circle: UIView, delay: Double) {
        UIView.animate(withDuration: duration, delay: delay, options: [.autoreverse, .repeat], animations: {
            circle.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func animate() {
        self.isHidden = false
        let circleArray = [circle1, circle2, circle3, circle4, circle5]

        var delay: Double = 0
        for circle in circleArray {
            circle.transform = CGAffineTransform.init(scaleX: 0, y: 0)
            animateCircle(circle: circle, delay: delay)
            delay += duration/10
        }
    }
    
    func stop() {
        self.isHidden = true
        self.layer.removeAllAnimations()
    }
}
