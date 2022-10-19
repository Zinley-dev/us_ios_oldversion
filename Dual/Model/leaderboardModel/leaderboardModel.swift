//
//  leaderboardModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/25/21.
//

import Foundation
import Firebase

class leaderboardModel {
    
    fileprivate var _status: Bool!
    fileprivate var _timeStamp: Timestamp!
    fileprivate var _userUID: String!
    fileprivate var _point: Int!
    fileprivate var _rank: Int!
    fileprivate var _mode: String!
    
    fileprivate var most_playDict = [String:Int]()
    fileprivate var final_most_playDict = [Dictionary<String, Int>.Element]()
    var final_most_playList = [String]()
    
    var mode: String! {
        get {
            if _mode == nil {
                _mode = ""
            }
            return _mode
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
    
    var status: Bool! {
        get {
            if _status == nil {
                _status = false
            }
            return _status
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
    
    var userUID: String! {
        get {
            if _userUID == nil {
                _userUID = ""
            }
            return _userUID
        }
        
    }
    
    var point: Int! {
        get {
            if _point == nil {
                _point = 0
            }
            return _point
        }
        
    }


    
    init(postKey: String, leaderboardModel : Dictionary<String, Any>) {
        
    
        if let userUID = leaderboardModel["userUID"] as? String {
            self._userUID = userUID
            loadMostPlayedList(uid: userUID)
        }
        
        if let mode = leaderboardModel["mode"] as? String {
            self._mode = mode
            
        }
        
        if let point = leaderboardModel["points"] as? Int {
            self._point = point
            
        }
        
        if let status = leaderboardModel["status"] as? Bool {
            self._status = status
            
        }
        
        if let timeStamp = leaderboardModel["timeStamp"] as? Timestamp {
            self._timeStamp = timeStamp
        }
        
        
        if let rank = leaderboardModel["rank"] as? Int {
            self._rank = rank
            
        }

        
        
        
    }
    
    
    func loadMostPlayedList(uid: String) {
        
        //MostPlayed_history
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("MostPlayed_history").whereField("userUID", isEqualTo: uid).limit(to: 500)
            
            .getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }

                for item in snapshot.documents {
                    
                    if let category = item.data()["category"] as? String, category != "Others" {
                        
                        
                        if most_playDict[category] == nil {
                            most_playDict[category] = 1
                        } else {
                            if let val = most_playDict[category] {
                                most_playDict[category] = val + 1
                            }
                        }
                        
                    }
                
                }
                
            
                let dct = most_playDict.sorted(by: { $0.value > $1.value })
                final_most_playDict = dct
                
                
                
                var count = 0
                
                for (key, _) in final_most_playDict {
                    
                    if count < 4 {
                        final_most_playList.append(key)
                        count += 1
                    } else {
                        break
                    }
                    
                    
                }
                
                print(final_most_playList.count)
                
            }
        
   
        
    }
    
}


