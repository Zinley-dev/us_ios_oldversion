//
//  InterestedModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/3/20.
//

import Foundation


class InterestedModel {
    
    fileprivate var _name: String!
    fileprivate var _url: String!
    fileprivate var _status: Bool!

    var name: String! {
        get {
            if _name == nil {
                _name = ""
            }
            return _name
        }
        
    }
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    
    var status: Bool! {
        get {
            if _status == nil{
                _status = false
            }
            return _status
        }
        
    }
    

    
    init(postKey: String, Game_model: Dictionary<String, Any>) {
        

        if let name = Game_model["name"] as? String {
            self._name = name
            
        }
        
        if let url = Game_model["url"] as? String {
            self._url = url
            
        }
        
        if let status = Game_model["status"] as? Bool {
            self._status = status
            
        }
        
        
        
        
        
    }
    
    
}
