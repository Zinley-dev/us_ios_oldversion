//
//  FollowModelFromAlgolia.swift
//  Dual
//
//  Created by Rui Sun on 12/21/21.
//

import UIKit

class FollowModelFromAlgolia: Codable {
    
    let objectID: String
    let Follower_uid: String
    let Following_uid: String
    let status: String
    let Follower_username: String
    let Following_username: String
    let follow_time: Dictionary<String,Int>
}

extension FollowModelFromAlgolia: Equatable {
    static func == (lhs: FollowModelFromAlgolia, rhs: FollowModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}

extension FollowModelFromAlgolia {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
