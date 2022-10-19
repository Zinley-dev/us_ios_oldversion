//
//  CategoryModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/22/20.
//

import Foundation

class CategoryModel {
    
    fileprivate var _name: String!
    fileprivate var _url: String!
    fileprivate var _url2: String!
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
    
    var url2: String! {
        get {
            if _url2 == nil{
                _url2 = ""
            }
            return _url2
        }
        
    }


    
    init(postKey: String, Game_model: Dictionary<String, Any>) {
        

        if let isSelected = Game_model["isSelected"] as? Bool {
            self._isSelected = isSelected
            
        }
        
        if let name = Game_model["name"] as? String {
            self._name = name
            
        }
        
        if let url = Game_model["url"] as? String {
            self._url = url
            
        }
        
        if let url2 = Game_model["url2"] as? String {
            self._url2 = url2
            
        }
        
        if let status = Game_model["status"] as? Bool {
            self._status = status
            
        }
 
        
    }
    
}
