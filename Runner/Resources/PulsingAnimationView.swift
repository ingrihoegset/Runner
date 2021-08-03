//
//  PulsingAnimationView.swift
//  Runner
//
//  Created by Ingrid on 03/08/2021.
//

import Foundation
import UIKit

class PulsingAnimationView: UIView {
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(pulsingLayer)
        layer.addSublayer(mainLayer)
        pulsingLayer.add(animationGroup, forKey: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var animationGroup: CAAnimationGroup = {
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [expandingAnimation,
                                     fadingAnimation]
        animationGroup.duration = 1.2
        animationGroup.repeatCount = .infinity
        return animationGroup
    }()
    
    private lazy var fadingAnimation: CABasicAnimation = {
        let fadingAnimation = CABasicAnimation(keyPath: "opacity")
        fadingAnimation.fromValue = 1
        fadingAnimation.toValue = 0
        return fadingAnimation
    }()
    
    private lazy var expandingAnimation: CABasicAnimation = {
        let expandingAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandingAnimation.fromValue = 1
        expandingAnimation.toValue = 1.5
        return expandingAnimation
    }()
    
    private let mainLayer: CAShapeLayer = circleLayer(color: PulsConstants.mainColor)
    private let pulsingLayer: CAShapeLayer = circleLayer(color: PulsConstants.pulsingColor)
    
    private static func circleLayer(color: CGColor) -> CAShapeLayer {
        let circleLayer = CAShapeLayer()
        circleLayer.path = PulsConstants.bezierPath.cgPath
        circleLayer.lineWidth = 5
        circleLayer.strokeColor = color
        circleLayer.fillColor = UIColor.clear.cgColor
        // positions animation in center of 40 x 40 frame
        circleLayer.position = CGPoint(x: 20, y: 20)
        return circleLayer
    }
    
    private enum PulsConstants {
        static let bezierPath: UIBezierPath = .init(arcCenter: CGPoint.zero,
                                                    radius: 15,
                                                    startAngle: -(CGFloat.pi / 2),
                                                    endAngle: -(CGFloat.pi / 2) + (2 * CGFloat.pi),
                                                    clockwise: true)
        static let mainColor: CGColor = UIColor.red.cgColor
        static let pulsingColor: CGColor = UIColor.red.cgColor
    }
    
    func setColor(color: CGColor) {
        mainLayer.strokeColor = color
        pulsingLayer.strokeColor = color
    }
}

