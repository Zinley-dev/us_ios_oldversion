//
//  HighlightSearchNode.swift
//  The Dual
//
//  Created by Rui Sun on 6/23/21.
//

import UIKit
import AsyncDisplayKit

class HighlightSearchNode: ASCellNode {
    
    weak var post: HighlightsModelFromAlgolia!
    
    var videoNode: ASNetworkImageNode!
    var cityNode: ASTextNode!
    var infoView: ASDisplayNode!
    
    
    init(with post: HighlightsModelFromAlgolia) {
        self.post = post
        self.infoView = ASDisplayNode()
        self.cityNode = ASTextNode()
        self.videoNode = ASNetworkImageNode()
        super.init()
        
        self.view.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        automaticallyManagesSubnodes = true
        
        let playbackID = post.Mux_playbackID
        let url = "https://image.mux.com/\(playbackID)/animated.gif?start=0&end=1&fit_mode=pad"
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldRenderProgressImages = true
        videoNode.animatedImagePaused = false
        videoNode.url = URL.init(string: url)
        
                
        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        let location = NSAttributedString(string: post.city ?? "Unkown", attributes: attrs as [NSAttributedString.Key : Any])
        cityNode.attributedText = location
        cityNode.textColorFollowsTintColor = true
        cityNode.tintColor = .white
        
        
        videoNode.backgroundColor = UIColor.clear
        infoView.backgroundColor = UIColor.clear
        cityNode.backgroundColor = UIColor.clear
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        print("this")
        let headerSubStack = ASStackLayoutSpec.vertical()

        cityNode.frame = CGRect(x: 0, y: 0, width: 60, height: 20)
        infoView.addSubnode(cityNode)
        
        videoNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: constrainedSize.min.width - 20)
        infoView.style.preferredSize = CGSize(width: constrainedSize.min.width, height: 20)
        headerSubStack.children = [videoNode, infoView]
        
        return headerSubStack
            
    }
    

    
    

}
