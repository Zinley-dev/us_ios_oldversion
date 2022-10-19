//
//  VideoNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/25/21.
//

import Foundation
import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase
import AlamofireImage


class VideoNode: ASCellNode {
    
    weak var post: HighlightsModel!
    
    var videoNode: ASNetworkImageNode!
    var thumbnailNode: ASImageNode!
    
    
    init(with post: HighlightsModel) {
        
        self.post = post
        self.videoNode = ASNetworkImageNode()
        self.thumbnailNode = ASNetworkImageNode()
        
       
        super.init()
        
        
        self.selectionStyle = .none
        automaticallyManagesSubnodes = true
        
        self.view.backgroundColor = UIColor.clear
        
   
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldRenderProgressImages = true
        videoNode.backgroundColor = UIColor.clear
        

        self.videoNode.isLayerBacked = true
        self.videoNode.isOpaque = true
        
        let playbackID = post.Mux_playbackID
        let urls = "https://image.mux.com/\(playbackID!)/animated.gif?start=1.0&end=1.35&fit_mode=smartcrop&fps=15"
        self.videoNode.url = URL.init(string: urls)
        
        if let cacheUrl = self.getThumbnailURL(post: post) {
            
            imageStorage.async.object(forKey: cacheUrl) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.thumbnailNode.image = image
    
                        
                    }
                    
                } else {
                    
                    
                 AF.request(cacheUrl).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            self.thumbnailNode.image = value
                            try? imageStorage.setObject(value, forKey: cacheUrl, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                            
                        case let .failure(error):
                            print(error)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
       
        videoNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width)
        
        thumbnailNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: constrainedSize.max.width)
        let firsOverlay = ASOverlayLayoutSpec(child: thumbnailNode, overlay: videoNode)
        
        return firsOverlay
            
    }
    
    func getThumbnailURL(post: HighlightsModel) -> String? {
        
        if let id = post.Mux_playbackID, id != "nil" {
           
            let urlString = "https://image.mux.com/\(id)/thumbnail.png?smartcrop&time=1"
            
            return urlString
            
        } else {
            
            return nil
           
        }
        
    }
    
   
    
}
