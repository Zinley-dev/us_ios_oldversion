//
//  ReportHistoryModelFromAlgolia.swift
//  Dual
//
//  Created by Rui Sun on 11/1/21.
//

import Foundation

class ReportHistoryModelFromAlgolia: Codable {

    let objectID: String
    let id: String
    let nickname: String
    let userUID: String
    let category: String
    let timeStamp: Dictionary<String,Int>
}

extension ReportHistoryModelFromAlgolia: Equatable {
    static func == (lhs: ReportHistoryModelFromAlgolia, rhs: ReportHistoryModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}
