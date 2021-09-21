//
//  InfoPlistParser.swift
//  Runner
//
//  Created by Ingrid on 21/09/2021.
//

import Foundation
import UIKit

struct InfoPlistParser {
    
    static func getStringValue(forKey: String) -> String {
        guard let value = Bundle.main.infoDictionary?[forKey] as? String else {
            fatalError("No value found for key '\(forKey)' in the Info.plist file")
        }
        return value
    }
}


struct Setup {
    static let kFirebaseOpenAppScheme = "FirebaseOpenAppScheme"
    static let kFirebaseOpenAppURIPrefix = "FirebaseOpenAppURIPrefix"
    static let kFirebaseOpenAppQueryItemEmailName = "FirebaseOpenAppQueryItemEmailName"
    static let kEmail = "Email"
    static var shouldOpenMailApp = false
}


extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
