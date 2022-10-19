//
//  KeywordModelFromAlgolia.swift
//  Dual
//
//  Created by Rui Sun on 10/19/21.
//

import Foundation

class KeywordModelFromAlgolia: Codable {
    let objectID: String
//    let type: String?
    let keyword: String
    let count: Int
//    let timeStamp: Dictionary<String,Int>
}

extension KeywordModelFromAlgolia: Equatable {
    static func == (lhs: KeywordModelFromAlgolia, rhs: KeywordModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}

