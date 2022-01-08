//
//  RaceAppUser.swift
//  Runner
//
//  Created by Ingrid on 11/07/2021.
//

import Foundation

struct RaceAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let userID: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        //ingrihoegset-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
