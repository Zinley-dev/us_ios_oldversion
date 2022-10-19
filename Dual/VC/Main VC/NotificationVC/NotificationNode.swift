//
//  NotificationNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 7/26/21.
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


class NotificationNode: ASCellNode {
    
    weak var notification: NotificationModel!
    var userNameNode: ASTextNode!
    var timeNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    let paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with notification: NotificationModel) {
        
        self.notification = notification
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.timeNode = ASTextNode()
        
        super.init()
        
        if self.notification.is_read == false {
            
            self.backgroundColor = UIColor.darkHeaderBackground
            
        } else {
            
            self.backgroundColor = UIColor.clear
            
        }
        
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.contentMode = .scaleAspectFill
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.isLayerBacked = true
       
        
        //
        paragraphStyles.alignment = .left

   
        userNameNode.backgroundColor = UIColor.clear
        timeNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let date = self.notification.timeStamp.dateValue()
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyles]
        
        let time = NSAttributedString(string: "\(timeAgoSinceDate(date, numericDates: true))", attributes: timeAttributes)
    
        timeNode.attributedText = time
        
      
       if notification.Field == "Follow" {
               
            if let uid = notification.fromUserUID {
                
                DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshot.exists {
                        
                        if let item = snapshot.data() {
                            
                            if let avatarUrl = item["avatarUrl"] as? String, let username = item["username"] as? String {
                                
                                self.AvatarNode.url = URL(string: avatarUrl)
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "@\(username) started following you.", attributes: textAttributes)
                                
                            }
                            
                            
                        }
                        
                        
                        
                    }
                    
                }
                

            }
            
        
       } else if notification.Field == "Comment" {
        
            if let uid = notification.fromUserUID {
                
                DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshot.exists {
                        
                        if let item = snapshot.data() {
                            
                            if let avatarUrl = item["avatarUrl"] as? String, let username = item["username"] as? String {
                                
                                self.AvatarNode.url = URL(string: avatarUrl)
                                
                                if notification.type == "Comment" {
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "@\(username) commented on your post.", attributes: textAttributes)
                                    
                                } else if notification.type == "Reply" {
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "@\(username) replied your comment.", attributes: textAttributes)
                                    
                                } else if notification.type == "Mention" {
                                    
                                    
                                    self.userNameNode.attributedText = NSAttributedString(string: "@\(username) mentioned you in a comment.", attributes: textAttributes)
                                }
                                
                            }
                            
                            
                        }
                        
                        
                    }
                             
                }
                
            }
        
        
       } else if notification.Field == "Challenge" {
        
           
        if let uid = notification.fromUserUID, let category = notification.category {
                
            
            DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        
                        if let avatarUrl = item["avatarUrl"] as? String, let username = item["username"] as? String {
                            
                            self.AvatarNode.url = URL(string: avatarUrl)
                            
                            if notification.Action == "Send" {
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "@\(username) challenged you - \(category).", attributes: textAttributes)
                                
                            } else if notification.Action == "Accept"  {
                                self.userNameNode.attributedText = NSAttributedString(string: "@\(username) accepted your challenge.", attributes: textAttributes)
                                
                            }
                            
                        }
                        
                        
                    }
                    
                }
                
                
                
                
                
            }
                
               
                
            }
        
        
       }
        
    }
    
    func loadAvatar(uid: String) {
        
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {   querySnapshot, error in
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
