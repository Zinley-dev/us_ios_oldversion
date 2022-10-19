//
//  HashTagSearchNode.swift
//  The Dual
//
//  Created by Rui Sun on 6/18/21.
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

class HashTagSearchNode: ASCellNode {
    
    weak var hashtag: HashtagsModelFromAlgolia!

    var hashtagTextNode: ASTextNode!
    var hashtagSymbolImg: ASTextNode!
    var coutNode: ASTextNode!
   
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with hashtag: HashtagsModelFromAlgolia) {
        
        self.hashtag = hashtag
        self.hashtagTextNode = ASTextNode()
        self.hashtagSymbolImg = ASTextNode()
        self.coutNode = ASTextNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none

        hashtagTextNode.isLayerBacked = true
        hashtagTextNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        
        if !hashtag.keyword.isEmpty {
            
            hashtagSymbolImg.attributedText = NSAttributedString(string: "#", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 5)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            

            hashtagTextNode.attributedText = NSAttributedString(string: String(self.hashtag.keyword.dropFirst(1)), attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
           
            loadHashTagCount(hashtag: self.hashtag.keyword)
            
        }
        
        coutNode.backgroundColor = UIColor.clear
        
        
    }
    
    
    func loadHashTagCount(hashtag: String) {
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("h_status", isEqualTo: "Ready").whereField("hashtag_list", arrayContains: hashtag).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                
                self.coutNode.attributedText = NSAttributedString(string: "0 post", attributes: [NSAttributedString.Key.font:UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
            } else {
                
                if let cnt = querySnapshot?.count {
                 
                    self.coutNode.attributedText = NSAttributedString(string: "\(formatPoints(num: Double(cnt))) posts", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                    
                }
                
            }
                
            
        }
        
    }
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        coutNode.style.preferredSize = CGSize(width: 60.0, height: 15.0)
    
        //
      
        
        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 0.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                            children: [hashtagSymbolImg, hashtagTextNode])
        
        let verticalStack = ASStackLayoutSpec.vertical()
        
        
            
        verticalStack.style.flexShrink = 16.0
        verticalStack.style.flexGrow = 16.0
        verticalStack.spacing = 8.0
            
            
        verticalStack.children = [mainStack]

    
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [verticalStack, coutNode]


        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
        
    }
    
    

}
