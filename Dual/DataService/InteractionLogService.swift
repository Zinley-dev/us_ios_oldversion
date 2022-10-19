//
//  InteractionLogService.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/7/21.
//

import Foundation
import Firebase

class InteractionLogService {
    
    fileprivate static var _instance = InteractionLogService()
    
    static var instance: InteractionLogService {
        return _instance
    }
    
    func UpdateLastedInteractUID(id: String) {
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
        
        db.collection("Users").whereField("userUID", isEqualTo: uid!).getDocuments { (snap, err) in
            
            if err != nil {
                
                return
            }
                
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    var lis = [String]()
                    
                    if let interaction_list = item.data()["interaction_list"] as? [String] {
                     
                        
                        if interaction_list.contains(id) {
                            
                            lis = self.removeID(list: interaction_list, uid: id)
                            
                        } else {
                                                     
                            lis = interaction_list
                            
                        }
                        
                        lis.insert(id, at: 0)
                        
                        if lis.count > 10 {
                            
                            lis.removeLast()
                        }
                        
                        self.updateData(key: item.documentID, list: lis)

                    } else {
                       
                        lis.insert(id, at: 0)
                        
                        self.updateData(key: item.documentID, list: lis)
                        
                    }
                    
                    
                }
                
                
            }
            
            
            
            
            
        }
            
   
        
    }
    
    func removeID(list: [String], uid: String) -> [String] {
        
        var count = 0
        var lis = list
        
        for item in lis {
            
            if item == uid {
                
                lis.remove(at: count)
                break
                
            }
            
            count += 1
            
            
        }
        
        return lis
        
    }
    
    
    func updateData(key: String, list: [String]) {
        
        let db = DataService.instance.mainFireStoreRef
        db.collection("Users").document(key).updateData(["interaction_list": list])
        
    }
    
    
}
