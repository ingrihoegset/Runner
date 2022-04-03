//
//  BounceButton.swift
//  Runner
//
//  Created by Ingrid on 16/09/2021.
//

import Foundation
import UIKit


class BounceButton: UIButton {
    
    var animationColor: UIColor?
    
    /// Does animation before "forwarding" button action as specified elsewhere
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        startAnimation(completion: {_ in
            super.sendAction(action, to: target, for: event)
        })
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
