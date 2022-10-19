//
//  FindFriendsNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/20/22.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase
import Messages
import MessageUI


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class FindFriendsNode: ASCellNode {
    
    weak var user: FindFriendsModel!
    var followAction : ((ASCellNode) -> Void)?
    lazy var delayItem = workItem()
    var attemptCount = 0
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var followBtnNode: ASButtonNode!
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: FindFriendsModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.followBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true

        //self.backgroundColor = UIColor.red
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        followBtnNode.backgroundColor = UIColor.clear
        
          //
        
        followBtnNode.addTarget(self, action: #selector(UserNode.followBtnPressed), forControlEvents: .touchUpInside)
        
       //
        
        automaticallyManagesSubnodes = true
        
        if user._userUID != nil {
            
            if user._avatarURL != nil {
                
                AvatarNode.url = URL.init(string: user._avatarURL)
                
            }
            
            if user._username != nil {
                
                if let username = user._username {
                    
                    self.userNameNode.attributedText = NSAttributedString(string: "@\(username)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                    
                }
              
            }
            
            
            if user._userUID != Auth.auth().currentUser?.uid {
                
                if !global_block_list.contains(user._userUID) {
                    
                    checkIfFollowing(uid: user._userUID)
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        self.followBtnNode.backgroundColor = UIColor.clear
                        self.followBtnNode.layer.borderWidth = 1.0
                        self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                        self.followBtnNode.layer.cornerRadius = 3.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("Blocked", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.white, for: .normal)
                        
                    }
                    
                }
                
              
                
            } else {
                
                
                DispatchQueue.main.async {
                    
                    self.followBtnNode.backgroundColor = UIColor.clear
                    self.followBtnNode.layer.borderWidth = 1.0
                    self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                    self.followBtnNode.layer.cornerRadius = 3.0
                    self.followBtnNode.clipsToBounds = true
                    self.followBtnNode.setTitle("You", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.white, for: .normal)
                    
                }
                
                
            }
            
    
        } else {
            
            AvatarNode.url = nil
            
            if user.imageData != nil {
               
                AvatarNode.image = UIImage(data: user.imageData)
                
            } else {
                
                AvatarNode.image = UIImage(named: "default")
                
            }
            
            DispatchQueue.main.async {
                
                self.followBtnNode.backgroundColor = self.selectedColor
                self.followBtnNode.layer.borderWidth = 0.0
                self.followBtnNode.layer.borderColor = UIColor.clear.cgColor
                self.followBtnNode.layer.cornerRadius = 3.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Invite", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.black, for: .normal)
                
            }
        
            
            self.userNameNode.attributedText = NSAttributedString(string: "@None", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
        
        if user.firstName != "" || user.familyName != "" {
            
            var firstName = ""
            var familyName = ""
            
            if user.firstName != "" {
                firstName = user.firstName
            }
            
            if user.familyName != "" {
                familyName = user.familyName
            }
            
        
            self.NameNode.attributedText = NSAttributedString(string: "\(firstName) \(familyName)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        } else {
            
            self.NameNode.attributedText = NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
        }
         
        
        
    }
    
    
    
    func checkIfUserDidFollowMe(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: uid).whereField("Follower_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
               
                self.followBtnNode.backgroundColor = self.selectedColor
                self.followBtnNode.layer.borderWidth = 0.0
                self.followBtnNode.layer.borderColor = UIColor.clear.cgColor
                self.followBtnNode.layer.cornerRadius = 3.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Follow", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.black, for: .normal)
                
                self.desc = "Follow"
               
            
            } else {
                
                self.followBtnNode.backgroundColor = self.selectedColor
                self.followBtnNode.layer.borderWidth = 0.0
                self.followBtnNode.layer.borderColor = UIColor.clear.cgColor
                self.followBtnNode.layer.cornerRadius = 3.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Follow back", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.black, for: .normal)
                
             
                self.desc = "Follow back"
            }
            
            
        }
        
    }
    
    func checkIfFollowing(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Follower_uid", isEqualTo: uid).getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.checkIfUserDidFollowMe(uid: uid)
            
            } else {
                
                self.followBtnNode.backgroundColor = UIColor.clear
                self.followBtnNode.layer.borderWidth = 1.0
                self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.followBtnNode.layer.cornerRadius = 3.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Following", with: UIFont(name:"Roboto-Regular",size: FontSize), with: UIColor.white, for: .normal)
                
                self.desc = "Following"
               
                
            }
            
            
        }
        
    }
    
  
    @objc func followBtnPressed() {
        
        if desc != "" {
            
            if self.user._userUID != nil {
                  
                if self.user._userUID != Auth.auth().currentUser?.uid {
                    
                    delayItem.perform(after: 0.25) {
                        
                        self.attemptCount += 1
                        
                        if self.attemptCount <= 3 {
                            
                            let uid = self.user._userUID
                            
                            if uid != "" {
                                
                                if self.desc == "Follow" {
                                            
                                    self.performCheckAndAdFollow(uid: uid!)
                            
                                } else if self.desc == "Follow back" {
                                    
                                    self.performCheckAndAdFollow(uid: uid!)
                                    
                                } else if self.desc == "Following" {
                                 
                                    self.unfollow(uid: uid!)
                                    
                                }
                                
                            }
                     
                        }
                        
                    }
                    
                }
                
                
            }
                  
        } else {
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is FindFriendsVC {
                    
                    if let update1 = vc as? FindFriendsVC {
                        
                        let composeVC = MFMessageComposeViewController()
                        composeVC.messageComposeDelegate = update1.self

                        // Configure the fields of the interface.
                        composeVC.recipients = [user.phoneNumber]
                        composeVC.body = "[Dual] I am \(global_name) on Dual. To download the app and watch more gaming videos. tap:https://apps.apple.com/us/app/dual/id1576592262"

                        // Present the view controller modally.
                        if MFMessageComposeViewController.canSendText() {
                            update1.present(composeVC, animated: true, completion: nil)
                        } else {
                            print("Can't send messages.")
                        }
                        
                    }
                    
                }
            }
            
          
            
        }
        
    }
    
    
    
    func performCheckAndAdFollow(uid: String) {
        
        if global_block_list.contains(uid) == false {
            
            let db = DataService.instance.mainFireStoreRef
            
            db.collection("Users").document(uid).getDocument {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let is_suspend = item["is_suspend"] as? Bool {
                            
                            if is_suspend == false {
                                
                                
                                if let username = item["username"] as? String, let name = item["name"] as? String {
                                    
                                    
                                    self.addFollow(uid: uid, Follower_username: username, Follower_name: name)
                                    
                                }
                              
                                
                            } else {
                                
                                self.followBtnNode.isHidden = true
                                
                            }
                            
                        } else {
                            
                            self.followBtnNode.isHidden = true
                           
                        }
                        
                        
                    }
                    
                    
                }
                
    
            }
            
            
        }
        
    }
    
    func addFollow(uid: String, Follower_username: String, Follower_name: String) {
        
        let db = DataService.init().mainFireStoreRef.collection("Follow")
        
        let data = ["Following_uid": Auth.auth().currentUser!.uid as Any, "Follower_uid": uid as Any, "follow_time": FieldValue.serverTimestamp(), "status": "Valid", "Follower_username": Follower_username, "Follower_name": Follower_name, "Following_username": global_username, "Following_name": global_name, "following_documentID": Auth.auth().currentUser!.uid]
        
        db.addDocument(data: data) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            } else {
                
                //addFollowPostIntoFollowee(targetUID: uid)
                addToAvailableChatList(uid: [uid])
                
                ActivityLogService.instance.UpdateFollowNotificationLog(userUID: uid, fromUserUID: Auth.auth().currentUser!.uid, Field: "Follow")
                ActivityLogService.instance.UpdateFollowActivityLog(mode: "Follow", toUserUID: uid)
                InteractionLogService.instance.UpdateLastedInteractUID(id: uid)
                //UI
                
                self.followBtnNode.backgroundColor = UIColor.clear
                self.followBtnNode.layer.borderWidth = 1.0
                self.followBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.followBtnNode.layer.cornerRadius = 3.0
                self.followBtnNode.clipsToBounds = true
                self.followBtnNode.setTitle("Following", with: UIFont.systemFont(ofSize: FontSize), with: UIColor.white, for: .normal)
                
                self.desc = "Following"
                
                if let vc = UIViewController.currentViewController() {
                    
                    
                    if vc is FollowerVC {
                        
                        if let update1 = vc as? FollowerVC {
                            if update1.isMain {
                                update1.updateFollowingCount()
                            }
                           
                        }
                        
                    }
                    
                }
                
                
                
            }
        }
        
    }
    
    
    func unfollow(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Follower_uid", isEqualTo: uid).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                
                for item in snapshot.documents {
                    
                    
                    let key = item.documentID
                    
                    DataService.init().mainFireStoreRef.collection("Follow").document(key).delete {  (err) in
                        if err != nil {
                            print(err!.localizedDescription)
                            return
                        }
                        
                        //removeFollowPostIntoFollowee(targetUID: uid)
                        ActivityLogService.instance.UpdateFollowActivityLog(mode: "Unfollow", toUserUID: uid)
                        
                        //UI
                        self.followBtnNode.backgroundColor = self.selectedColor
                        self.followBtnNode.layer.borderWidth = 0.0
                        self.followBtnNode.layer.borderColor = UIColor.clear.cgColor
                        self.followBtnNode.layer.cornerRadius = 3.0
                        self.followBtnNode.clipsToBounds = true
                        self.followBtnNode.setTitle("Follow", with: UIFont.systemFont(ofSize: FontSize), with: UIColor.black, for: .normal)
                        
                        self.desc = "Follow"
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            
                            if vc is FollowerVC {
                                
                                if let update1 = vc as? FollowerVC {
                                    if update1.isMain {
                                        update1.updateFollowingCount()
                                    }
                                   
                                }
                                
                            }
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        followBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [AvatarNode, headerSubStack, followBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
}
