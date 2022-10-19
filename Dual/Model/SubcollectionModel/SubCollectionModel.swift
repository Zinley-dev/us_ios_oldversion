//
//  SubCollectionModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/12/22.
//

import Foundation


class SubcollectionModel {
    
   
    fileprivate var _postUID: String!
    fileprivate var _category: String!
    fileprivate var _mainDocID: String!
    
 

    var postUID: String! {
        get {
            if _postUID == nil {
                _postUID = ""
            }
            return _postUID
        }
        
    }
    
    var category: String! {
        get {
            if _category == nil {
                _category = ""
            }
            return _category
        }
        
    }
    
    var mainDocID: String! {
        get {
            if _mainDocID == nil {
                _mainDocID = ""
            }
            return _mainDocID
        }
        
    }

    
    
    init(postKey: String, Highlight_model: Dictionary<String, Any>) {
        
        
        self._mainDocID = postKey
       

        if let category = Highlight_model["category"] as? String {
            self._category = category
        }
        
        
        if let postUID = Highlight_model["postUID"] as? String {
            self._postUID = postUID
        }
        
        
    }
    
}
