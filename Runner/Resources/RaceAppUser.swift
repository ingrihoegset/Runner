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
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    // let profilePictureUrl: String
}
