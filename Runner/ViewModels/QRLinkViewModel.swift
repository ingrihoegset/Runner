//
//  QRVM.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import Foundation

protocol QRLinkViewModelDelegate {
    func didUpdateLink()
}

class QRLinkViewModel {
    
    var qrLinkViewModelDelegate: QRLinkViewModelDelegate?
    
    init() {
        listenForNewLink()
    }
    
    // Start listening for new link
    func listenForNewLink() {
        DatabaseManager.shared.observeNewLink(completion: { success in
            if success {
                self.qrLinkViewModelDelegate?.didUpdateLink()
                print ("Link updated. Close QR view controller")
            }
            else {
                self.qrLinkViewModelDelegate?.didUpdateLink()
                print ("Link updated. Close QR view controller")
            }
        })
    }
}
