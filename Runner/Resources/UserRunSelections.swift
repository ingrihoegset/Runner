//
//  UserRunSelections.swift
//  Runner
//
//  Created by Ingrid on 30/07/2021.
//

import Foundation

final class UserRunSelections {
    
    // Singelton for easy read and write access. Returns an instance of the UserSelections.
    static let shared = UserRunSelections()
    
    var isRunningWithOneGate = true
    var userSelectedType = "Sprint"
    var userSelectedLength = 60
    var userSelectedDelay = 3
    
    private init() {    }
    
    func getIsRunningWithOneGate() -> Bool {
        return isRunningWithOneGate
    }
    
    func setIsRunningWithOneGate(bool: Bool) {
        self.isRunningWithOneGate = bool
    }
    
    func getUserSelectedType() -> String {
        return userSelectedType
    }
    
    func setUserSelectedType(type: String) {
        self.userSelectedType = type
    }
    
    func getUserSelectedLength() -> Int {
        return userSelectedLength
    }
    
    func setUserSelectedLength(length: Int) {
        self.userSelectedLength = length
    }
    
    func getUserSelectedDelay() -> Int {
        return userSelectedDelay
    }
    
    func setUserSelectedDelay(delay: Int) {
        self.userSelectedDelay = delay
    }
}
