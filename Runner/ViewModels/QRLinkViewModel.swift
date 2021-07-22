//
//  QRVM.swift
//  Runner
//
//  Created by Ingrid on 13/07/2021.
//

import Foundation

protocol QRLinkViewModelDelegate: AnyObject {
    func didUpdateLink()
}

class QRLinkViewModel {
    
    weak var qrLinkViewModelDelegate: QRLinkViewModelDelegate?
    
    init() {
        listenForNewLink()
    }
    
    // Start listening for new link
    func listenForNewLink() {
        DatabaseManager.shared.listenForNewLink(completion: { [weak self] result in
            switch result {
            case .success(_):
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.qrLinkViewModelDelegate?.didUpdateLink()
                print ("Link updated. Close QR view controller")
                
            case .failure(_):
                print("Do not close QR-code VC automatically.")
            }
        })
    }
}
