//
//  HighlightStatisticModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/25/21.
//

import Foundation


class HighlightStatisticModel {
    
    fileprivate var _category: Int!
    fileprivate var _videoswhashtag: Int!
    fileprivate var _videos: Int!
    fileprivate var _length: Double!
    
    
    var videoswhashtag: Int! {
        get {
            if _videoswhashtag == nil {
                _videoswhashtag = 0
            }
            return _videoswhashtag
        }
        
    }
    
    var category: Int! {
        get {
            if _category == nil {
                _category = 0
            }
            return _category
        }
        
    }
    
    var videos: Int! {
        get {
            if _videos == nil {
                _videos = 0
            }
            return _videos
        }
        
    }
    
    var length: Double! {
        get {
            if _length == nil {
                _length = 0.0
            }
            return _length
        }
        
    }


    
    init(postKey: String, HighlightStatisticModel : Dictionary<String, Any>) {
        

        if let category = HighlightStatisticModel["category"] as? Int {
            self._category = category
            
        }
        
        if let videos = HighlightStatisticModel["videos"] as? Int {
            self._videos = videos
            
        }
        
        if let length = HighlightStatisticModel["length"] as? Double {
            self._length = length
            
        }
        
        if let videoswhashtag = HighlightStatisticModel["videoswhashtag"] as? Int {
            self._videoswhashtag = videoswhashtag
            
        }
        
        
    }
    
}

