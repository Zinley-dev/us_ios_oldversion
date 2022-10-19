//
//  tutorialModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/15/21.
//

import Foundation

class tutorialModel {
    

    fileprivate var _title: String!
    fileprivate var _url: String!
    fileprivate var _description: String!
    fileprivate var _rank: Int!
    
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    
    var title: String! {
        get {
            if _title == nil {
                _title = ""
            }
            return _title
        }
        
    }
    
    var description: String! {
        get {
            if _description == nil {
                _description = ""
            }
            return _description
        }
        
    }
    
    var rank: Int! {
        get {
            if _rank == nil {
                _rank = 0
            }
            return _rank
        }
        
    }
   


    
    init(postKey: String, tutorialModel : Dictionary<String, Any>) {
        
        if let title = tutorialModel["title"] as? String {
            self._title = title
        }
        
        if let url = tutorialModel["url"] as? String {
            self._url = url
        }
        if let description = tutorialModel["description"] as? String {
            self._description = description
        }
        
        if let rank = tutorialModel["rank"] as? Int {
            self._rank = rank
            
        }
        
    }
    
    
}
