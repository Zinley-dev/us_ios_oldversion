//
//  AccountActivityNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/7/21.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 12

class AccountActivityNode: ASCellNode {
    
    
    var activity: UserActivityModel
    var userNameNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with activity: UserActivityModel) {
        
        self.activity = activity
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        AvatarNode.contentMode = .scaleAspectFill
        userNameNode.isLayerBacked = true
        
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true
        
        //
        paragraphStyles.alignment = .left

   
        userNameNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let date = self.activity.timeStamp.dateValue()
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
    
        timeNode.attributedText = time
        
        if activity.Field == "Account" {
            
            loadAvatar(uid: activity.userUID)
            
            //Create, updateInfo(phone, email, password, general information), login, logout
            if activity.Action == "Create" {
                
                userNameNode.attributedText = NSAttributedString(string: "Your account is created", attributes: textAttributes)
                
            } else if activity.Action == "Update" {
                
                if let info = activity.info {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have updated \(info.lowercased())", attributes: textAttributes)
                    
                }
                             
            } else if activity.Action == "Login" {
                
                if let device = activity.Device {
                    
                    userNameNode.attributedText = NSAttributedString(string: "Your account has been logged in from \(device)", attributes: textAttributes)
                    
                }
                
            } else if activity.Action == "Logout" {
                
                if let device = activity.Device {
                    
                    userNameNode.attributedText = NSAttributedString(string: "Your account has been logged out from \(device)", attributes: textAttributes)
                    
                }
                
                
            }
            
            
        } else if activity.Field == "Challenge" {
             
           //Challenge (Accept, reject, send)
            
            if let uid = activity.toUserUID {
                
                DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments {  querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                    
                    
                    if snapshot.isEmpty != true {
                        
                        for item in snapshot.documents {
                            
                            if let avatarUrl = item.data()["avatarUrl"] as? String, let username = item.data()["username"] as? String {
                                
                                self.AvatarNode.url = URL(string: avatarUrl)
                                
                                if activity.Action == "Send" {
                              
                                    if let category = activity.category {
                                        
                                        self.userNameNode.attributedText = NSAttributedString(string: "You have sent a new \(category) challenge to @\(username)", attributes: textAttributes)
                                        
                                    }
                                    
                                    
                                } else if activity.Action == "Accept" {
                                    
                                    if let category = activity.category {
                                        
                                        self.userNameNode.attributedText = NSAttributedString(string: "You have accepted a \(category) challenge from @\(username)", attributes: textAttributes)
                                        
                                    }
                                    
                                } else if activity.Action == "Reject" {
                                    
                                    
                                    if let category = activity.category {
                                        
                                        self.userNameNode.attributedText = NSAttributedString(string: "You have rejected a \(category) challenge from @\(username)", attributes: textAttributes)
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
  
        } else if activity.Field == "Highlight" {
            
            loadLogo(category: activity.category)
     
            if activity.Action == "Create" {
          
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have created a new \(category) highlight", attributes: textAttributes)
                    
                }
                
                
            } else if activity.Action == "Update" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have updated a \(category) highlight", attributes: textAttributes)
                    
                }
            
            } else if activity.Action == "Delete" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have deleted a \(category) highlight", attributes: textAttributes)
                    
                }
            } else if activity.Action == "Like-post" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have liked a \(category) highlight", attributes: textAttributes)
                    
                }
                
                
            } else if activity.Action == "Like-comment" {
                
                if let category = activity.category {
                    
                    userNameNode.attributedText = NSAttributedString(string: "You have liked a comment from the \(category) highlight", attributes: textAttributes)
                    
                }
                
            }
            
            
        } else if activity.Field == "Follow" {
            
            
            if let uid = activity.toUserUID {
                
                DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments {  querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                    
                    
                    if snapshot.isEmpty != true {
                        
                        for item in snapshot.documents {
                            
                            if let avatarUrl = item.data()["avatarUrl"] as? String, let username = item.data()["username"] as? String {
                                
                                self.AvatarNode.url = URL(string: avatarUrl)
                                
                                if activity.Action == "Follow" {
                              
                                    self.userNameNode.attributedText = NSAttributedString(string: "You have followed @\(username)", attributes: textAttributes)
                                    
                                    
                                } else if activity.Action == "Unfollow" {
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "You have unfollowed @\(username)", attributes: textAttributes)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
            
            
        } else if activity.Field == "Comment" {
            
            if let category = activity.category {
                 
                if let id = activity.Cmt_user_uid {
                    
                    DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: id).getDocuments {  querySnapshot, error in
                            guard let snapshot = querySnapshot else {
                                print("Error fetching snapshots: \(error!)")
                                return
                            }
                        
                        
                        if snapshot.isEmpty != true {
                            
                            for item in snapshot.documents {
                                
                                if let avatarUrl = item.data()["avatarUrl"] as? String {
                                    
                                    self.AvatarNode.url = URL(string: avatarUrl)
                                    
                                }
                                
                                
                                if activity.isActive == true {
                                    
                                    
                                    if activity.type == "Comment" {
                                        
                                        self.userNameNode.attributedText = NSAttributedString(string: "You commented on a \(category) highlight", attributes: textAttributes)
                                        
                                        
                                    } else if activity.type == "Reply" {
                                        
                                        self.userNameNode.attributedText = NSAttributedString(string: "You replied on a \(category) highlight", attributes: textAttributes)
                                        
                                    }
                                    
                                    
                                } else {
                                    
                                    if let username = item.data()["username"] as? String {
                                        
                                        
                                        if activity.type == "Comment" {
                                            
                                            self.userNameNode.attributedText = NSAttributedString(string: "@\(username) commented on your \(category) highlight", attributes: textAttributes)
                                            
                                            
                                        } else if activity.type == "Reply" {
                                            
                                            self.userNameNode.attributedText = NSAttributedString(string: "@\(username) replied on your \(category) highlight", attributes: textAttributes)
                                            
                                        }
                                        
                                        
                                    }
                                                
                                    
                                }
                                
                                
                            }}
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
            }
            
            
        } else if activity.Field == "Challenge" {
            
            if let uid = activity.toUserUID, let category = activity.category {
                
                DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments {  querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            return
                        }
                    
                    
                    if snapshot.isEmpty != true {
                        
                        for item in snapshot.documents {
                            
                            if let avatarUrl = item.data()["avatarUrl"] as? String, let username = item.data()["username"] as? String {
                                
                                self.AvatarNode.url = URL(string: avatarUrl)
                                
                                if activity.Action == "Send" {
                              
                                    self.userNameNode.attributedText = NSAttributedString(string: "You have sent a challenge to @\(username) in \(category)", attributes: textAttributes)
                                    
                                    
                                } else if activity.Action == "Accept" {
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "You have accepted a challenge to @\(username) in \(category)", attributes: textAttributes)
                                    
                                } else if activity.Action == "Reject" {
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "You have rejected a challenge to @\(username) in \(category)", attributes: textAttributes)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
            
        }
         
        
        
    }
    
    func loadLogo(category: String) {
        
        if category == "Others" {
            
            self.AvatarNode.image = UIImage(named: "more")
            
        } else {
            
            DataService.instance.mainFireStoreRef.collection("Support_game").whereField("short_name", isEqualTo: category).getDocuments { (snap, err) in
                
                
                if err != nil {
                    
                    print(err!.localizedDescription)
                    return
                }
                
                for itemsed in snap!.documents {
                    
                    if let url = itemsed.data()["url"] as? String {
                        
                        self.AvatarNode.url = URL(string: url)
                        
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
    func loadAvatar(uid: String) {
        
        
        if global_avatar_url != "" {
            
            AvatarNode.url = URL(string: global_avatar_url)
            
        } else {
            
            DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            self.AvatarNode.url = URL(string: avatarUrl)
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
              
        }
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
       
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, timeNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
