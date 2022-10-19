//
//  HashtagsModelFromAlgolia.swift
//  Dual
//
//  Created by Rui Sun on 8/9/21.
//

import UIKit

class HashtagsModelFromAlgolia: Codable {
    let objectID: String
    let keyword: String
    let count: Int
//    let category: String
//    let createBy_userUID: String
//    let timeStamp: String
}

extension HashtagsModelFromAlgolia: Equatable {
    static func == (lhs: HashtagsModelFromAlgolia, rhs: HashtagsModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}
