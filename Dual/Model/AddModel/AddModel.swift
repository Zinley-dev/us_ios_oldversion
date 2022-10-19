//
//  AddModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import Foundation


class AddModel {
    
    fileprivate var _short_name: String!
    fileprivate var _name: String!
    fileprivate var _url: String!
    fileprivate var _status: Bool!
    var _isSelected: Bool!
    
    
    var isSelected: Bool! {
        get {
            if _isSelected == nil {
                _isSelected = false
            }
            return _isSelected
        }
        
    }
    
    var short_name: String! {
        get {
            if _short_name == nil {
                _short_name = ""
            }
            return _short_name
        }
        
    }
    
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
        
        
        if let short_name = Game_model["short_name"] as? String {
            self._short_name = short_name
            
        }
        
        
        if let isSelected = Game_model["isSelected"] as? Bool{
            self._isSelected = isSelected
            
        }
        
        if let url = Game_model["url"] as? String {
            self._url = url
            
        }

        if let status = Game_model["status"] as? Bool {
            self._status = status
            
        }
 
        
    }
    
}
