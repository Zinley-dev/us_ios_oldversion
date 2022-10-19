//
//  UserSearchModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/5/21.
//
import Foundation


class UserSearchModel {
    
    fileprivate var _userUID: String!
    fileprivate var _interaction_list: [String]!

      
    var userUID: String! {
        get {
            if _userUID == nil {
                _userUID = ""
            }
            return _userUID
        }
    }
    
    var interaction_list: [String]! {
        get {
            if _interaction_list.isEmpty == true {
                return _interaction_list
            }
            
            return _interaction_list
        }
        
    }
    
    
    
    init(postKey: String, UserSearchModel: Dictionary<String, Any>) {
        
        if let userUID = UserSearchModel["userUID"] as? String {
            self._userUID = userUID
        }
              
        
        if let interaction_list = UserSearchModel["interaction_list"] as? [String] {
            self._interaction_list = interaction_list
        }
        
        
        
    }
    
    
    
}
