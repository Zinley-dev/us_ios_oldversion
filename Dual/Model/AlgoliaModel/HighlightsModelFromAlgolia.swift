//
//  HighlightsModelFromAlgolia.swift
//  The Dual
//
//  Created by Rui Sun on 6/23/21.
//

import UIKit

class HighlightsModelFromAlgolia: Codable {
    let objectID: String
    let category: String?
    let url: String
    let status: String?
    let mode: String?
    let music: String?
    let Mux_processed: Bool?
    let Mux_playbackID: String
    let Mux_assetID: String
    let Allow_comment: Bool
    let userUID: String
    let highlight_title: String?
    let post_time: Dictionary<String,Int>
//    let ratio: CGFloat?
    let city: String?
    let stream_link: String?
    let hashtag_list: [String]?
}

//extension HighlightsModelFromAlgolia {
//  func asDictionary() throws -> [String: Any] {
//    let data = try JSONEncoder().encode(self)
//    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//      throw NSError()
//    }
//    return dictionary
//  }
//}

extension HighlightsModelFromAlgolia {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension HighlightsModelFromAlgolia: Equatable {
    static func == (lhs: HighlightsModelFromAlgolia, rhs: HighlightsModelFromAlgolia) -> Bool {
        return lhs.objectID == rhs.objectID
    }
}
