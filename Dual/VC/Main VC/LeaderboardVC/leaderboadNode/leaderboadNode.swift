//
//  leaderboadNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/25/21.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase

fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13

class leaderboadNode: ASCellNode {
    
    weak var user: leaderboardModel!
   
    var infoView: ASDisplayNode!

    var desc = ""
    
    var LeaderboardViews: LeaderboardView!
    
    init(with user: leaderboardModel) {
        
        self.user = user
        self.infoView = ASDisplayNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        self.infoView.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        DispatchQueue.main.async {
            self.LeaderboardViews = LeaderboardView()
            
            self.infoView.view.addSubview(self.LeaderboardViews)
           
            self.LeaderboardViews.translatesAutoresizingMaskIntoConstraints = false
            self.LeaderboardViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.LeaderboardViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.LeaderboardViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.LeaderboardViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true
            
            if user.mode != "" {
                
                if user.mode == "increase" {
                    self.LeaderboardViews.modeImg.image = UIImage(named: "Green")
                } else if user.mode == "decrease" {
                    self.LeaderboardViews.modeImg.image = UIImage(named: "Red")
                } else {
                    self.LeaderboardViews.modeImg.image = nil
                }
                
            } else {
                self.LeaderboardViews.modeImg.image = nil
            }
            
            self.LeaderboardViews.pointLbl.text = "\(self.user.point ?? 0)"
            self.LeaderboardViews.ChallengeTextLbl.text = "#\(self.user.rank ?? 0)"
            
        }
        
        loadInfo(uid: user.userUID)
      
        
    }
    
  
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        infoView.style.preferredSize = CGSize(width: constrainedSize.max.width , height: 180)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: infoView)
    }
    
    
    func loadInfo(uid: String ) {
    
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item["username"] as? String {
                        
                        self.LeaderboardViews.usernameLbl.text = "@\(username)"

                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            imageStorage.async.object(forKey: avatarUrl) { result in
                                if case .value(let image) = result {
                                    
                                    DispatchQueue.main.async { // Make sure you're on the main thread here
                                        
                                        self.LeaderboardViews.avatarImg.image = image
                                       
                                    }
                                    
                                } else {
                                    
                                    
                                 AF.request(avatarUrl).responseImage { response in
                                        
                                        
                                        switch response.result {
                                        case let .success(value):
                                            self.LeaderboardViews.avatarImg.image = value
                                            try? imageStorage.setObject(value, forKey: avatarUrl, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                           
                                        case let .failure(error):
                                            print(error)
                                        }
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        
                            
                        }
                        
                        
                        if let name = snapshot.data()!["name"] as? String {
                            
                            self.LeaderboardViews.nameLbl.text = name
                        
                            
                        }
                        
                        
                    }
                    
                }
                
                
            }
               
            
        }
        
       
    }
    
    
}

extension leaderboadNode {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
    
    
        LeaderboardViews.collectionView.delegate = dataSourceDelegate
        LeaderboardViews.collectionView.dataSource = dataSourceDelegate
        LeaderboardViews.collectionView.tag = row
        LeaderboardViews.collectionView.setContentOffset(LeaderboardViews.collectionView.contentOffset, animated:true) // Stops collection view if it was scrolling.
        LeaderboardViews.collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
        LeaderboardViews.collectionView.reloadData()
        
    }

}
