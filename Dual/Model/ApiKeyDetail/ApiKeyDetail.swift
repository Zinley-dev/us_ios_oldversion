//
//  ApiKeyDetail.swift
//  Dual
//
//  Created by Rui Sun on 12/26/21.
//

import Foundation

class ApiKeyDetail {
    
    fileprivate var _serviceName: String!
    fileprivate var _appId: String!
    fileprivate var _key: String!
    fileprivate var _timestamp: String!
    fileprivate var _isActive: Bool!
    
    
    var serviceName: String! {
        get {
            return _serviceName == nil ? "" : _serviceName
        }
    }
    
    var appId: String! {
        get {
            return _appId == nil ? "" : _appId
        }
    }
    
    var key: String! {
        get {
            return _key == nil ? "" : _key
        }
    }
    
    var timestamp: String! {
        get {
            return _timestamp == nil ? "" : _timestamp
        }
    }
    
    var isActive: Bool! {
        get {
            return _isActive == nil ? false : _isActive
        }
    }
    
    
    init(apiKeyModel: Dictionary<String, Any>) {
        

        if let serviceName = apiKeyModel["service_name"] as? String {
            self._serviceName = serviceName
        }
        
        if let appId = apiKeyModel["app_id"] as? String {
            self._appId = appId
        }
        
        if let key = apiKeyModel["key"] as? String {
            self._key = key
        }
        
        if let timestamp = apiKeyModel["timestamp"] as? String {
            self._timestamp = timestamp
        }
        
        if let isActive = apiKeyModel["is_active"] as? Bool {
            self._isActive = isActive
        }
 
        
    }
    
}
