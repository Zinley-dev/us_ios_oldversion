//
//  KeywordSearchNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/20/21.
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



class KeywordSearchNode: ASCellNode {
    
    weak var keyword: KeywordModelFromAlgolia!

    var keywordTextNode: ASTextNode!
    var keywordSymbolImg: ASImageNode!
    var coutNode: ASTextNode!
   
   
    var desc = ""
    
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    init(with keyword: KeywordModelFromAlgolia) {
        
        self.keyword = keyword
        self.keywordTextNode = ASTextNode()
        self.keywordSymbolImg = ASImageNode()
        self.coutNode = ASTextNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none

        keywordTextNode.isLayerBacked = true
        keywordTextNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        
        if !keyword.keyword.isEmpty {
            
            keywordSymbolImg.image = UIImage(named: "search")?.resize(targetSize: CGSize(width: 10, height: 10))

            keywordTextNode.attributedText = NSAttributedString(string: String(self.keyword.keyword), attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                 
        }
        
        coutNode.backgroundColor = UIColor.clear
        
        
    }
    
    func loadKeywordCount(keyword: String) {
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .right
        
        DataService.instance.mainFireStoreRef.collection("Video_searchWords").whereField("searchWord", isEqualTo: keyword).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                
                self.coutNode.attributedText = NSAttributedString(string: "0 searches", attributes: [NSAttributedString.Key.font:UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                 
                    self.coutNode.attributedText = NSAttributedString(string: "\(formatPoints(num: Double(cnt))) searches", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Regular",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                    
                }
                
            }
                
            
        }
        
    }
    
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        
        coutNode.style.preferredSize = CGSize(width: 120.0, height: 15.0)
        keywordSymbolImg.style.preferredSize = CGSize(width: 15, height: 15)
        //
      
        
        let mainStack = ASStackLayoutSpec(direction: .horizontal,
                                            spacing: 5.0,
                                          justifyContent: .start,
                                          alignItems: .center,
                                            children: [keywordSymbolImg, keywordTextNode])
        
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

