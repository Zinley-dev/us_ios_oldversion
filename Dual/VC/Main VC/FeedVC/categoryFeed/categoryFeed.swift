//
//  categoryFeed.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/25/22.
//

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



class categoryFeed: ASCellNode {
    
    weak var category: AddModel!
    
    
    var infoView: ASDisplayNode!

    var desc = ""
    
    var CategoryViews: CategoryView!
    
   
    init(with category: AddModel) {
        
        self.category = category
        self.infoView = ASDisplayNode()
        
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        self.infoView.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        DispatchQueue.main.async { 
            self.CategoryViews = CategoryView()
            
            self.infoView.view.addSubview(self.CategoryViews)
           
            self.CategoryViews.translatesAutoresizingMaskIntoConstraints = false
            self.CategoryViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.CategoryViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.CategoryViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.CategoryViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true
            
            
            self.layer.cornerRadius = self.frame.width / 2
            
            self.configureCell(info: category)
            
        }
        
    
        

    }
    
    func configureCell(info: AddModel) {
        
        
        if category.isSelected == true {
            
            if category.short_name == "General" {
                
                self.CategoryViews.backView.backgroundColor = selectedColor
                
                
            } else {
                
                if category.short_name == "Others" {
                    self.CategoryViews.backView.backgroundColor = selectedColor
                    self.CategoryViews.CategoryLbl.textColor = UIColor.black
                } else {
                    self.CategoryViews.CategoryLbl.textColor = selectedColor
                }
              
                
            }
            
           
        } else {
            

            if category.short_name == "General" {
                
                self.CategoryViews.backView.backgroundColor = UIColor.darkGray
                
            } else if category.short_name == "Others" {
                
                self.CategoryViews.backView.backgroundColor = UIColor.darkGray
                self.CategoryViews.CategoryLbl.textColor = UIColor.white
                
            } else {
                
                self.CategoryViews.CategoryLbl.textColor = UIColor.white
                
            }
            
          
            
        }
       
        
        if info.short_name == "General" {
            CategoryViews.CategoryImg.contentMode = .scaleAspectFit
            CategoryViews.blurView.isHidden = true
            CategoryViews.leftConstraint.constant = 8
            CategoryViews.rightConstraint.constant = 8
            CategoryViews.topConstraint.constant = 8
            CategoryViews.bottomConstraint.constant = 8
            
            CategoryViews.CategoryLbl.text = ""
        } else if info.short_name == "Others" {
            
            CategoryViews.CategoryImg.isHidden = true
            CategoryViews.blurView.isHidden = true
            CategoryViews.leftConstraint.constant = 0
            CategoryViews.rightConstraint.constant = 0
            CategoryViews.topConstraint.constant = 0
            CategoryViews.bottomConstraint.constant = 0
            
            CategoryViews.CategoryLbl.text = "Others"
            
        } else {
            CategoryViews.CategoryImg.contentMode = .scaleAspectFill
            CategoryViews.blurView.isHidden = false
            
            CategoryViews.leftConstraint.constant = 0
            CategoryViews.rightConstraint.constant = 0
            CategoryViews.topConstraint.constant = 0
            CategoryViews.bottomConstraint.constant = 0
            
            CategoryViews.CategoryLbl.text = info.short_name
        }
      
        if let url = info.url, url != "", url != "nil" {
            
            self.CategoryViews.CategoryImg.image = UIImage(named: info.short_name)

            
         
        }
        
 
    }
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        if category.isSelected == true {
            
            
            infoView.style.preferredSize = CGSize(width: 42 , height: 42)
            
        } else {
            
           
            infoView.style.preferredSize = CGSize(width: 37 , height: 37)
            
        }
       
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: infoView)
       
            
    }
    
   
    
    
}
