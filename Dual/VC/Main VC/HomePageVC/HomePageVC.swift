//
//  HomePageVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/6/20.
//

import UIKit
import Firebase
import Alamofire
import SendBirdUIKit
import SendBirdCalls

class HomePageVC: UITabBarController, UITabBarControllerDelegate {
    

    
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tabBar.barTintColor = .black
        tabBar.isTranslucent = false
        
    
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
        
        }
        
        //self.delegate = self
        self.delegate = self
        SBDMain.add(self, identifier: self.sbu_className)
        
        /*
        SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid)
        
            SBUMain.connectIfNeeded {  user, error in
                  
                    
                if let user = user {
            
                print("SBUMain.connect: \(user)")
                    
                    
            }
        } */
        
        countChallengeNotification()
        countNotification()
        loadStreamingLink()
        loadAllImageForAddVC()
        
        
        

    }
    
    func loadAllImageForAddVC() {
        
        
        DataService.instance.mainFireStoreRef.collection("Support_game").getDocuments { querySnapshot, err in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
                
            }
            
            
            for item in querySnapshot!.documents {
                
                let i = item.data()
                let item = AddModel(postKey: item.documentID, Game_model: i)
                
                
                
                if let url = item.url, url != "" {
                    
                    imageStorage.async.object(forKey: url) { result in
                        if case .value(_) = result {
                            
                            print()
                            
                        } else {
                            
                            
                         AF.request(item.url).responseImage { response in
                                
                                switch response.result {
                                case let .success(value):
                                    
                                    try? imageStorage.setObject(value, forKey: url, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                    
                                case let .failure(error):
                                    print(error)
                                }
                                

                            }
                            
                        }
                        
                    }
                   
                 
                }
                
                
                
            }
            
            
        }
        
        
        
        
    }


    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let tabBarIndex = tabBarController.selectedIndex
        
        if tabBarIndex == 0 {
            
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
            
        }
        
    }
  
    
    func setUnreadMessagesCount(_ totalCount: UInt) {
        
        var badgeValue: String?
        
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
    
        if let tabItems = self.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
           
            let tabItem = tabItems[3]
            
            tabItem.badgeColor = SBUColorSet.error400
            tabItem.badgeValue = badgeValue
            tabItem.setBadgeTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor : SBUColorSet.ondark01,
                    NSAttributedString.Key.font : SBUFontSet.caption4
                ],
                for: .normal
            )
            
        } else {
            
            print("No tabs")
            
        }
        
        
        
    }
    
    
    func countNotification() {
        
        notiListen2 = DataService.init().mainFireStoreRef.collection("Notification_center").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                //notificationBtn.badge = nil
            
            } else {
                
                for item in snapshot.documents {
                    
                    if let cnt = item.data()["count"] as? Int {
                        
                        
                        if cnt == 0 {
                            //notificationBtn.badge = nil
                            self.setNotiProfileTabBar(0)
                            
                        } else {
                            
                            self.setNotiProfileTabBar(UInt(cnt))
                        
                            
                        }
                      
                    }
                    
                }
                
              
                
                
              
            }
            
            
        }
        
    }
    
    func countChallengeNotification() {
        
        notiChallengeListen = DataService.init().mainFireStoreRef.collection("Challenge_notification_center").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                for item in snapshot.documents {
                    
                    if let cnt = item.data()["count"] as? Int {
                        
                        
                        if cnt == 0 {
                            self.setNotiChallengeTabBar(0)
                        } else {
                            
                            self.setNotiChallengeTabBar(UInt(cnt))
                            
                        }
                      
                    }
                    
                }
            
            }
            
        }
        
    }
    
    
    func setNotiProfileTabBar(_ totalCount: UInt) {
        
        var badgeValue: String?
        
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
        
        if let tabItems = self.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
           
            let tabItem = tabItems[0]
            
            tabItem.badgeColor = SBUColorSet.error400
            tabItem.badgeValue = badgeValue
            tabItem.setBadgeTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor : SBUColorSet.ondark01,
                    NSAttributedString.Key.font : SBUFontSet.caption4
                ],
                for: .normal
            )
            
        } else {
            
            print("No tabs")
            
        }
                
    }
    
    func setNotiChallengeTabBar(_ totalCount: UInt) {
        
        var badgeValue: String?
        
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
        
        if let tabItems = self.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
           
            let tabItem = tabItems[1]
            
            tabItem.badgeColor = SBUColorSet.error400
            tabItem.badgeValue = badgeValue
            tabItem.setBadgeTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor : SBUColorSet.ondark01,
                    NSAttributedString.Key.font : SBUFontSet.caption4
                ],
                for: .normal
            )
            
        } else {
            
            print("No tabs")
            
        }
    
                
    }
    
    
    func loadStreamingLink() {
        
        if Auth.auth().currentUser?.uid != nil {
            
            let db = DataService.instance.mainFireStoreRef
            
            addGameAddVC = db.collection("streaming_domain").order(by: "company", descending: true)
                .addSnapshotListener {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
              
                    snapshot.documentChanges.forEach { diff in
                        
                        
                        let item = streamingDomainModel(postKey: diff.document.documentID, streamingDomainModel: diff.document.data())
                        
                        if (diff.type == .modified) {
            
                            let isIn = self.findDataInList(item: item)
                            
                            if isIn == false {
                                
                                if item.status == true {
                                    streaming_domain.insert(item, at: 0)
                                }
                                
                                
                            } else {
                                
                                if item.status == true {
                                    
                                    let index = self.findDataIndex(item: item)
                                    streaming_domain.remove(at: index)
                                    streaming_domain.insert(item, at: index)
                                    
                                } else {
                                    
                                    let index = self.findDataIndex(item: item)
                                    streaming_domain.remove(at: index)
                                    
                                    
                                }
                                
                                    
                            }
                            
                       
                            
                        } else if (diff.type == .removed) {
                            
                            
                            let index = self.findDataIndex(item: item)
                            streaming_domain.remove(at: index)
                            
                            
                            
                            // delete processing goes here
                            
                        } else if (diff.type == .added) {
                            
                            if item.status == true {
                                
                                let isIn = self.findDataInList(item: item)
                                
                                if isIn == false {
                                    
                                    streaming_domain.append(item)
                               
                                    
                                }
                                
                            }
                          
                            
        
                    }
              
                }
            }
            
        }
        
        
    }
    
    func findDataInList(item: streamingDomainModel) -> Bool {
        
        for i in streaming_domain {
            
            if i.company == item.company {
                
                return true
                
            }
            
           
            
        }
        
        return false
        
    }
    
    func findDataIndex(item: streamingDomainModel) -> Int {
        
        var count = 0
        
        for i in streaming_domain {
            
            if i.company == item.company {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
    
    func updateUnreadCount() {
        SBDMain.getTotalUnreadMessageCount { [weak self] totalCount, error in
            guard let self = self else { return }
            self.setUnreadMessagesCount(UInt(totalCount))
        }
    }
    
    
}
extension HomePageVC: SBDUserEventDelegate{
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32,
                                          totalCountByCustomType: [String : NSNumber]?)
    {
        self.setUnreadMessagesCount(UInt(totalCount))
        
        
        
    }
    
}
