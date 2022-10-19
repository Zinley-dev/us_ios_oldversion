//
//  AddNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/19/22.
//

import Foundation

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase
import ActiveLabel
import SendBirdSDK
import AVFoundation
import AVKit

class AddNode: ASCellNode {
    
    weak var category: AddModel!
    
    
    var infoView: ASDisplayNode!

    var desc = ""
    
    var AddViews: AddView!
    
   
    init(with category: AddModel) {
        
        self.category = category
        self.infoView = ASDisplayNode()
        
        
        super.init()
        
        self.backgroundColor = UIColor.blue
        self.infoView.backgroundColor = UIColor.clear
    
        
        automaticallyManagesSubnodes = true
        
        DispatchQueue.main.async {
            
            self.AddViews = AddView()
            
            self.infoView.view.addSubview(self.AddViews)
           
            self.AddViews.translatesAutoresizingMaskIntoConstraints = false
            self.AddViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.AddViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.AddViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.AddViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true
            
            self.layer.cornerRadius = 20
           
            
            if category.status == true {
                self.AddViews.shadowView.backgroundColor = UIColor.clear
            } else {
                self.AddViews.shadowView.backgroundColor = UIColor.black
            }
            
      
            self.configureCell(info: category)
            
        }
        
    
        

    }
    
    func configureCell(info: AddModel) {
       
        let estimatedWidth = info.name.width(withConstrainedHeight: 27, font: UIFont.systemFont(ofSize: 15))
        
        self.AddViews.name.text = info.name
        
        AddViews.textWidthConstant.constant = estimatedWidth + 2
        
        
        if info.short_name == "Others" {
            
            AddViews.otherImageView.isHidden = false
            
        } else {
            
            AddViews.otherImageView.isHidden = true
            
            
            if let url = info.url, url != "" {
                
                self.AddViews.imageView.image = UIImage(named: info.short_name)
                
             
            }
            
        }
       
        
 
    }
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        infoView.style.preferredSize = CGSize(width: constrainedSize.max.width , height: constrainedSize.max.height)
       
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: infoView)
       
            
    }
    
    
    
    
    
    
    
    
}
