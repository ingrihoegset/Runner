//
//  SlantedView.swift
//  Runner
//
//  Created by Ingrid on 24/10/2021.
//

import UIKit

class SlantedView: UIImageView {

    @IBInspectable var slantHeight: CGFloat = 50 { didSet { updatePath() } }

    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 0
        shapeLayer.fillColor = UIColor.yellow.cgColor    // with masks, the color of the shape layer doesn’t matter; it only uses the alpha channel; the color of the view is dictate by its background color
        return shapeLayer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    private func updatePath() {
        let path = UIBezierPath()
        path.move(to: bounds.origin)
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY - self.frame.height / 1.33))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.close()
        shapeLayer.path = path.cgPath
        layer.mask = shapeLayer
    }
}
