//
//  searchNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/5/21.
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


class searchNode: ASCellNode {
    
    weak var user: UserSearchModel!
    var followAction : ((ASCellNode) -> Void)?
    
    
    var userNameNode: ASTextNode!
    var NameNode: ASTextNode!
    var AvatarNode: ASNetworkImageNode!
   
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with user: UserSearchModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.NameNode = ASTextNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        

   
        userNameNode.backgroundColor = UIColor.clear
        NameNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
         
        if user.userUID != "" {
            loadInfo(uid: user.userUID)
        }
        
        
        
    }
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        headerSubStack.children = [userNameNode, NameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    func loadInfo(uid: String ) {
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {   querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item["username"] as? String {
                        
                        
                        self.userNameNode.attributedText = NSAttributedString(string: "@\(username)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                        
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            self.AvatarNode.url = URL(string: avatarUrl)
                            
                        }
                        
                        
                        if let name = item["name"] as? String {
                            
                            
                            self.NameNode.attributedText = NSAttributedString(string: "\(name)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }
            
            
            
        }
        
       
    }
    
    
}
