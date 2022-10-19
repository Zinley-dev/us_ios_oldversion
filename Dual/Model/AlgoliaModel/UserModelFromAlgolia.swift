//
//  UserModelFromAlgolia.swift
//  The Dual
//
//  Created by Rui Sun on 6/24/21.
//

import UIKit

class UserModelFromAlgolia: Codable {
    let name: String
    let username: String
    let userUID: String
    //let interaction_list: String
    let objectID: String
    let avatarUrl: String
    let is_suspend: Bool?
    let phone: String?
    
    
    init() {
        self.name = "No results"
        self.username = "N/A"
        self.userUID = ""
        self.objectID = ""
        self.avatarUrl = ""
        self.is_suspend = false
        self.phone = "Unknown"
    }
}

extension UserModelFromAlgolia: Equatable {
    static func == (lhs: UserModelFromAlgolia, rhs: UserModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}

