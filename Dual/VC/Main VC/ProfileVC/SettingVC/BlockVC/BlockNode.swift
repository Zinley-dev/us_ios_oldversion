//
//  BlockNode.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/11/21.
//


import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase
import SendBirdUIKit

fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class BlockNode: ASCellNode {
    
    
    weak var user: UserModel!
    var UnBlockAction : ((ASCellNode) -> Void)?
    
    
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
    var UnBlockBtnNode: ASButtonNode!
    lazy var delayItem = workItem()
    var desc = ""
    var attemptCount = 0
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: UserModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.UnBlockBtnNode = ASButtonNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        

   
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        UnBlockBtnNode.backgroundColor = UIColor.clear
        
        //
        
        UnBlockBtnNode.addTarget(self, action: #selector(BlockNode.UnblockBtnPressed), forControlEvents: .touchUpInside)
        
        //
        
        automaticallyManagesSubnodes = true
        
        
        
        DispatchQueue.main.async {
            
            self.UnBlockBtnNode.backgroundColor = UIColor.clear
            self.UnBlockBtnNode.layer.borderWidth = 1.0
            self.UnBlockBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.UnBlockBtnNode.layer.cornerRadius = 3.0
            self.UnBlockBtnNode.clipsToBounds = true
            
            self.UnBlockBtnNode.setTitle("Unblock", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
        }
        
        
        
        desc = "Block"

        loadInfo(uid: user.Block_uid)
        
        
    }
    
    
    @objc func UnblockBtnPressed() {
        
        delayItem.perform(after: 0.25) {
            
            self.attemptCount += 1
            
            if self.attemptCount <= 3 {
                
                if self.desc == "Block" {
                    
                    self.unblock()
                    
                } else {
                    
                    
                    if self.desc == "Follow" {
                                
                        self.performCheckAndAdFollow(uid: self.user.Block_uid)
                       
                    } else if self.desc == "Follow back" {
                        
                        self.performCheckAndAdFollow(uid: self.user.Block_uid)
                        
                    } else if self.desc == "Following" {
                     
                        self.unfollow(uid: self.user.Block_uid)
                        
                    }
                    
                    
                    
                }
                
            } else {
                
                
                if let vc = UIViewController.currentViewController() {
                    
                    
                    if vc is BlockVC {
                        
                        if let update1 = vc as? BlockVC {
                            
                            update1.showErrorAlert("Oops!", msg: "The system detects some unusual actions, the function is temporarily disabled for this current user. Please contact our support for more information.")
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
                                
                                self.UnBlockBtnNode.isHidden = true
                                
                            }
                            
                        } else {
                            
                            self.UnBlockBtnNode.isHidden = true
                           
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
                
                
               // addFollowPostIntoFollowee(targetUID: uid)
                
                addToAvailableChatList(uid: [uid])
                
                ActivityLogService.instance.UpdateFollowActivityLog(mode: "Follow", toUserUID: uid)
                ActivityLogService.instance.UpdateFollowNotificationLog(userUID: uid, fromUserUID: Auth.auth().currentUser!.uid, Field: "Follow")
                InteractionLogService.instance.UpdateLastedInteractUID(id: uid)
                //UI
                
                self.UnBlockBtnNode.backgroundColor = UIColor.clear
                self.UnBlockBtnNode.layer.borderWidth = 1.0
                self.UnBlockBtnNode.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.UnBlockBtnNode.layer.cornerRadius = 3.0
                self.UnBlockBtnNode.clipsToBounds = true
                self.UnBlockBtnNode.setTitle("Following", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                
                self.desc = "Following"
                
               
                
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
                    
                    DataService.init().mainFireStoreRef.collection("Follow").document(key).delete { (err) in
                        if err != nil {
                            print(err!.localizedDescription)
                            return
                        }
                        
                        //removeFollowPostIntoFollowee(targetUID: uid)
                        ActivityLogService.instance.UpdateFollowActivityLog(mode: "Unfollow", toUserUID: uid)
                        
                        
                        //UI
                        self.UnBlockBtnNode.backgroundColor = self.selectedColor
                        self.UnBlockBtnNode.layer.borderWidth = 0.0
                        self.UnBlockBtnNode.layer.borderColor = UIColor.clear.cgColor
                        self.UnBlockBtnNode.layer.cornerRadius = 3.0
                        self.UnBlockBtnNode.clipsToBounds = true
                        self.UnBlockBtnNode.setTitle("Follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                        
                        self.desc = "Follow"
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    func unblock() {
        
        SBDMain.unblockUserId(user.Block_uid!) { error in
            
            if error != nil {
                
                print(error!.localizedDescription)
                return
                
            } else {
                
                
                DataService.init().mainFireStoreRef.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Block_uid", isEqualTo: self.user.Block_uid!).getDocuments { (snap, err) in
                    
                    if err != nil {
                        
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        
                        for item in snap!.documents {
                            
                          
                            DataService.init().mainFireStoreRef.collection("Block").document(item.documentID).delete {  error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    return
                                }
                                
                                self.desc = "Follow"
                                
                                DispatchQueue.main.async {
                                    
                                    self.UnBlockBtnNode.backgroundColor = self.selectedColor
                                    self.UnBlockBtnNode.layer.borderWidth = 0.0
                                    self.UnBlockBtnNode.layer.borderColor = UIColor.clear.cgColor
                                    self.UnBlockBtnNode.layer.cornerRadius = 3.0
                                    self.UnBlockBtnNode.clipsToBounds = true
                                    self.UnBlockBtnNode.setTitle("Follow", with: UIFont(name: "Avenir-Medium", size: FontSize)!, with: UIColor.white, for: .normal)
                                    
                                    
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
        UnBlockBtnNode.style.preferredSize = CGSize(width: 120.0, height: 25.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack, UnBlockBtnNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    func loadInfo(uid: String ) {
    
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item["username"] as? String {
                        

                        self.userNameNode.attributedText = NSAttributedString(string: "@\(username)", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                        
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            self.AvatarNode.url = URL(string: avatarUrl)
                            
                        }
                        
                        
                        if let name = item["name"] as? String {
                            
                            
                            self.NameNode.attributedText = NSAttributedString(string: "\(name)", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
                 
            
        }
        
    }
    
    
    
    
    
}
