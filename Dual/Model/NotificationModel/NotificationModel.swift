//
//  NotificationModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 7/26/21.
//

import Foundation
import Firebase

class NotificationModel {
    
   
    var is_read: Bool!
    
    fileprivate var _notificationID: String!
   
   
    fileprivate var _challengeid: String!
    fileprivate var _fromUserUID: String!
    fileprivate var _userUID: String!
    fileprivate var _category: String!
    fileprivate var _Action: String!
    fileprivate var _info: String!
    fileprivate var _Field: String!
    fileprivate var _toUserUID: String!
    fileprivate var _Highlight_Id: String!
    fileprivate var _Device: String!
    fileprivate var _type: String!
    fileprivate var _root_id: String!
    fileprivate var _owner_uid: String!
    fileprivate var _reply_to_cid: String!
    fileprivate var _CId: String!
    fileprivate var _Mux_playbackID: String!
    fileprivate var _isActive: Bool!
    fileprivate var _Cmt_user_uid: String!
    
    
 
    fileprivate var _timeStamp: Timestamp!
    
    var notificationID: String! {
        get {
            if _notificationID == nil {
                _notificationID = ""
            }
            return _notificationID
        }
    }
    

    var isActive: Bool! {
        get {
            if _isActive == nil {
                _isActive = false
            }
            return _isActive
        }
    }
    
    var challengeid: String! {
        get {
            if _challengeid == nil {
                _challengeid = ""
            }
            return _challengeid
        }
    }
    
    var fromUserUID: String! {
        get {
            if _fromUserUID == nil {
                _fromUserUID = ""
            }
            return _fromUserUID
        }
    }
    
    
    
    var Cmt_user_uid: String! {
        get {
            if _Cmt_user_uid == nil {
                _Cmt_user_uid = ""
            }
            return _Cmt_user_uid
        }
    }
    
    var type: String! {
        get {
            if _type == nil {
                _type = ""
            }
            return _type
        }
    }
    
    var root_id: String! {
        get {
            if _root_id == nil {
                _root_id = ""
            }
            return _root_id
        }
    }
    
    var owner_uid: String! {
        get {
            if _owner_uid == nil {
                _owner_uid = ""
            }
            return _owner_uid
        }
    }
    
    var reply_to_cid: String! {
        get {
            if _reply_to_cid == nil {
                _reply_to_cid = ""
            }
            return _reply_to_cid
        }
    }
    
    var CId: String! {
        get {
            if _CId == nil {
                _CId = ""
            }
            return _CId
        }
    }
    
    var Mux_playbackID: String! {
        get {
            if _Mux_playbackID == nil {
                _Mux_playbackID = ""
            }
            return _Mux_playbackID
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
    
    var Device: String! {
        get {
            if _Device == nil {
                _Device = ""
            }
            return _Device
        }
    }
    
    var userUID: String! {
        get {
            if _userUID == nil {
                _userUID = ""
            }
            return _userUID
        }
        
    }
    
    var Action: String! {
        get {
            if _Action == nil {
                _Action = ""
            }
            return _Action
        }
        
    }
    
    var info: String! {
        get {
            if _info == nil {
                _info = ""
            }
            return _info
        }
        
    }
    
    var Field: String! {
        get {
            if _Field == nil {
                _Field = ""
            }
            return _Field
        }
        
    }
    
    var toUserUID: String! {
        get {
            if _toUserUID == nil {
                _toUserUID = ""
            }
            return _toUserUID
        }
        
    }
    
    var Highlight_Id: String! {
        get {
            if _Highlight_Id == nil {
                _Highlight_Id = ""
            }
            return _Highlight_Id
        }
        
    }
    
    
    var timeStamp: Timestamp! {
        get {
            if _timeStamp == nil {
                _timeStamp = Timestamp.init(date: NSDate() as Date)
            }
            return _timeStamp
        }
    }
    
    init(postKey: String, UserNotificationModel: Dictionary<String, Any>) {
        
        self._notificationID = postKey

        if let category = UserNotificationModel["category"] as? String {
            self._category = category
        }
        
        if let userUID = UserNotificationModel["userUID"] as? String {
            self._userUID = userUID
        }
        
        if let Device = UserNotificationModel["Device"] as? String {
            self._Device = Device
        }
        
        if let Action = UserNotificationModel["Action"] as? String {
            self._Action = Action
        }
        
        if let info = UserNotificationModel["info"] as? String {
            self._info = info
        }
        
        if let Field = UserNotificationModel["Field"] as? String {
            self._Field = Field
        }
        
        if let toUserUID = UserNotificationModel["toUserUID"] as? String {
            self._toUserUID = toUserUID
        }
        
        if let Highlight_Id = UserNotificationModel["Highlight_Id"] as? String {
            self._Highlight_Id = Highlight_Id
        }
        
        if let Cmt_user_uid = UserNotificationModel["Cmt_user_uid"] as? String {
            self._Cmt_user_uid = Cmt_user_uid
        }
       
        if let isActive = UserNotificationModel["isActive"] as? Bool {
            self._isActive = isActive
        }
        
        if let is_read = UserNotificationModel["is_read"] as? Bool {
            self.is_read = is_read
        } else {
            self.is_read = false
        }
        
        if let timeStamp = UserNotificationModel["timeStamp"] as? Timestamp {
            self._timeStamp = timeStamp
        }
        
        if let type = UserNotificationModel["type"] as? String {
            self._type = type
        }
        
        if let CId = UserNotificationModel["CId"] as? String {
            self._CId = CId
        }
        
        if let Mux_playbackID = UserNotificationModel["Mux_playbackID"] as? String {
            self._Mux_playbackID = Mux_playbackID
        }
        
        if let root_id = UserNotificationModel["root_id"] as? String {
            self._root_id = root_id
        }
        
        if let reply_to_cid = UserNotificationModel["reply_to_cid"] as? String {
            self._reply_to_cid = reply_to_cid
        }
        
        if let fromUserUID = UserNotificationModel["fromUserUID"] as? String {
            self._fromUserUID = fromUserUID

        }
        
        if let owner_uid = UserNotificationModel["owner_uid"] as? String {
            self._owner_uid = owner_uid
        }
        
        if let challengeid = UserNotificationModel["challengeid"] as? String {
            self._challengeid = challengeid

        }
                  
        
    }
    
    
    
    
}
