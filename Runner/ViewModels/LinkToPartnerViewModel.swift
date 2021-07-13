//
//  LinkToPartnerViewModel.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import Foundation

class LinkToPartnerViewModel {
    
    
    init() {
        
    }
    
    func createNewLink(safePartnerEmail: String) {
        
        DatabaseManager.shared.registerLink(with: safePartnerEmail, completion: { success in
            if success {
                print ("New Link created. And database updated for users")
            }
            else {
                print("Failed update database with new Link")
            }
        })
    }
}

