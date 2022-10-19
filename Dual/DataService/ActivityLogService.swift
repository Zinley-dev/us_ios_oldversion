//
//  AcitivityLogService.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/7/21.
//

import Foundation
import UIKit
import Firebase
import SwiftPublicIP
import Alamofire


class ActivityLogService {
    
    fileprivate static var _instance = ActivityLogService()
    
    static var instance: ActivityLogService {
        return _instance
    }
    
    
    func UpdateFollowNotificationLog(userUID: String, fromUserUID: String, Field: String) {
        
        
        let data = ["userUID": userUID, "fromUserUID": fromUserUID, "timeStamp": FieldValue.serverTimestamp(), "Field": Field, "Device": UIDevice().type.rawValue, "Action": "follow", "is_read": false] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_notification")
        countNotification(userUID: userUID)
        
    }
    
    func updateCommentNotificationLog(Field: String, Highlight_Id: String, category: String, Mux_playbackID: String, CId: String, reply_to_cid: String, type: String, root_id: String, owner_uid: String, isActive: Bool, fromUserUID: String, userUID: String, Action: String) {
        
        
        let data = ["userUID": userUID, "Field": Field, "Highlight_Id": Highlight_Id, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue, "category": category, "type": type, "root_id": root_id, "owner_uid": owner_uid, "reply_to_cid": reply_to_cid, "CId": CId, "Mux_playbackID": Mux_playbackID, "isActive": isActive, "fromUserUID": fromUserUID, "Action": Action, "is_read": false] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_notification")
        countNotification(userUID: userUID)
        
    }
    
    func updateChallengeNotificationLog(mode: String, category: String, userUID: String, challengeid: String, Highlight_Id: String) {
        
        
        let data = ["fromUserUID": Auth.auth().currentUser!.uid, "Action": mode, "userUID": userUID, "timeStamp": FieldValue.serverTimestamp(), "Field": "Challenge", "Device": UIDevice().type.rawValue, "category": category, "challengeid": challengeid, "is_read": false, "Highlight_Id": Highlight_Id] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_notification")
        
        if mode == "Send" {
            countChallengeNotification(userUID: userUID)
        }
        
        
    }
    
    
    func countNotification(userUID: String) {
        
        DataService.init().mainFireStoreRef.collection("Notification_center").whereField("userUID", isEqualTo: userUID).getDocuments{ querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                let data = ["userUID": userUID, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue, "count": 1] as [String : Any]
                
                DataService.init().mainFireStoreRef.collection("Notification_center").addDocument(data: data)
                
            } else {
                
                for item in snapshot.documents {
                    
                    if let count = item.data()["count"] as? Int {
                                       
                        DataService.init().mainFireStoreRef.collection("Notification_center").document(item.documentID).updateData(["count": count + 1])
                        
                    } else {
                        
                        
                        DataService.init().mainFireStoreRef.collection("Notification_center").document(item.documentID).updateData(["count": 1])
                        
                    }
                }
                
            }
            
        }
        
        
    }
    
    
    func countChallengeNotification(userUID: String) {
        
        DataService.init().mainFireStoreRef.collection("Challenge_notification_center").whereField("userUID", isEqualTo: userUID).getDocuments{ querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                let data = ["userUID": userUID, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue, "count": 1] as [String : Any]
                
                DataService.init().mainFireStoreRef.collection("Challenge_notification_center").addDocument(data: data)
                
            } else {
                
                for item in snapshot.documents {
                    
                    if let count = item.data()["count"] as? Int {
                                       
                        DataService.init().mainFireStoreRef.collection("Challenge_notification_center").document(item.documentID).updateData(["count": count + 1])
                        
                    } else {
                        
                        
                        DataService.init().mainFireStoreRef.collection("Challenge_notification_center").document(item.documentID).updateData(["count": 1])
                        
                    }
                }
                
            }
            
        }
        
        
    }
    
    
    func UpdateAccountActivityLog(mode: String, info: String) {
        
        
        let data = ["userUID": Auth.auth().currentUser!.uid, "Action": mode, "info": info, "timeStamp": FieldValue.serverTimestamp(), "Field": "Account", "Device": UIDevice().type.rawValue] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_activity")
        
        
    }
    
    
    func UpdateChallengeActivityLog(mode: String, toUserUID: String, category: String, challengeid: String, Highlight_Id: String) {
        
        let data = ["userUID": Auth.auth().currentUser!.uid, "Action": mode, "toUserUID": toUserUID, "timeStamp": FieldValue.serverTimestamp(), "Field": "Challenge", "Device": UIDevice().type.rawValue, "category": category, "challengeid": challengeid, "Highlight_Id": Highlight_Id] as [String : Any]
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_activity")
        
    }
    
    
    func UpdateHighlightActivityLog(mode: String, Highlight_Id: String, category: String) {
        
        let data = ["userUID": Auth.auth().currentUser!.uid, "Action": mode, "Highlight_Id": Highlight_Id, "timeStamp": FieldValue.serverTimestamp(), "Field": "Highlight", "Device": UIDevice().type.rawValue, "category": category] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_activity")

    }
    
    
    func updateCommentActivytyLog(mode: String, Highlight_Id: String, category: String, Mux_playbackID: String, CId: String, reply_to_cid: String, type: String, root_id: String, owner_uid: String, isActive: Bool, Cmt_user_uid: String, userUID: String) {
        
        
        let data = ["userUID": userUID, "Action": mode, "Highlight_Id": Highlight_Id, "timeStamp": FieldValue.serverTimestamp(), "Field": "Comment", "Device": UIDevice().type.rawValue, "category": category, "type": type, "root_id": root_id, "owner_uid": owner_uid, "reply_to_cid": reply_to_cid, "CId": CId, "Mux_playbackID": Mux_playbackID, "isActive": isActive, "Cmt_user_uid": Cmt_user_uid] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_activity")
        
    }
    
    func UpdateFollowActivityLog(mode: String, toUserUID: String) {
        
        let data = ["userUID": Auth.auth().currentUser!.uid, "Action": mode, "toUserUID": toUserUID, "timeStamp": FieldValue.serverTimestamp(), "Field": "Follow", "Device": UIDevice().type.rawValue] as [String : Any]
        
        
        getNeccesaryInformationAndWrite(data: data, type: "Account_activity")

    }
    
    func getNeccesaryInformationAndWrite(data: [String: Any], type: String) {
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                //DataService.instance.mainFireStoreRef.collection("Account_activity").addDocument(data: data)
                
            } else if let string = string {
                var updateData = data
                updateData.updateValue(string, forKey: "query")
                DataService.instance.mainFireStoreRef.collection(type).addDocument(data: updateData)
                
                
            }
            
            
        }
        
        
    }
    
}

