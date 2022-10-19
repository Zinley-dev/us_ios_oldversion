//
//  ChallengeNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/19/22.
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



class ChallengeNode: ASCellNode {
    
    weak var user: ChallengeModel!
   
    var infoView: ASDisplayNode!

    var desc = ""
    
    var ChallengeViews: ChallengeView!
    
    var gameTimer: Timer?
    
    var currentMode = 0
    
    init(with user: ChallengeModel) {
        
        self.user = user
        self.infoView = ASDisplayNode()
        
        super.init()
        
        self.backgroundColor = UIColor.clear
        self.infoView.backgroundColor = UIColor.clear
        self.automaticallyManagesSubnodes = true
        
        self.infoView.isOpaque = true
        self.selectionStyle = .none
        
        
        DispatchQueue.main.async {
            
            self.ChallengeViews = ChallengeView()
          
           
            self.infoView.view.addSubview(self.ChallengeViews)
            
            self.ChallengeViews.translatesAutoresizingMaskIntoConstraints = false
            self.ChallengeViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.ChallengeViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.ChallengeViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.ChallengeViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true

          
            if user.challenge_status == "Pending" {

               
                self.loadInfo(uid: user.sender_ID)
                
                self.ChallengeViews.messageLbl.text = user.messages
                
            } else if user.challenge_status == "Active" {
                
                user.started_timeStamp.dateValue()
                let date = user.started_timeStamp.dateValue()
                self.ChallengeViews.messageLbl.text = "Actives \(timeAgoSinceDate(date, numericDates: true))"
                
                
                if user.started_timeStamp != nil {
                    
                    let date = user.started_timeStamp.dateValue()
                    let mode = timeForReloadScheduler(date, numericDates: true)
                    
                    if mode != 0 {
                       
                        self.currentMode = mode
                        self.gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ChallengeNode.updateActiveTimeStamp), userInfo: nil, repeats: true)
                        
                    }
                    
                    
                    
                }
                
                
                
                for uid in user.uid_list {
                    
                    if uid != user.current_ID {
               
                        
                        self.loadInfo(uid: uid)
                        
                    }
                    
                    
                }
                
            } else {
                
                
                let date = user.updated_timeStamp.dateValue()
                self.ChallengeViews.messageLbl.text = "Expired \(timeAgoSinceDate(date, numericDates: true))"
                
                //Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(ChallengeNode.updateExpiredTimeStamp), userInfo: nil, repeats: true)
                
                if user.updated_timeStamp != nil {
                    
                    let date = user.updated_timeStamp.dateValue()
                    let mode = timeForReloadScheduler(date, numericDates: true)
                    
                    if mode != 0 {
                       
                        self.currentMode = mode
                        self.gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ChallengeNode.updateExpiredTimeStamp), userInfo: nil, repeats: true)
                        
                    }
                    
                    
                    
                }
                
                
                for uid in user.uid_list {
                    
                    if uid != user.current_ID {
                        
        
                        self.loadInfo(uid: uid)
                        
                    }
                    
                    
                }
                
            }
            
            
        }
   
    }
    
    @objc func updateExpiredTimeStamp() {
        
        if user != nil {
            
            if user.updated_timeStamp != nil {
                
                let date = user.updated_timeStamp.dateValue()
                let mode = timeForReloadScheduler(date, numericDates: true)
                
                if mode != 0 {
                    
                    if mode != self.currentMode {
                        
                        self.currentMode = mode
                        gameTimer?.invalidate()
                        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ChallengeNode.updateExpiredTimeStamp), userInfo: nil, repeats: true)
                        
                    }
                    
                    
                    
                    if user.started_timeStamp != nil {
                        
                        let date = user.updated_timeStamp.dateValue()
                        ChallengeViews.messageLbl.text = "Expired \(timeAgoSinceDate(date, numericDates: true))"
                        
                    } else {
                    
                        ChallengeViews.messageLbl.text = "Challenge is just expired"
                        
                    }
                    
                } else {
                    
                    gameTimer?.invalidate()
                    
                }
                
            } else {
                
                if gameTimer != nil {
                    
                    gameTimer?.invalidate()
                    
                }
                
            }
            
            
        } else {
            
            if gameTimer != nil {
                
                gameTimer?.invalidate()
                
            }
            
        }
        
    }
    
    @objc func updateActiveTimeStamp() {
        
        
        if user.started_timeStamp != nil {
            
            let date = user.started_timeStamp.dateValue()
            let mode = timeForReloadScheduler(date, numericDates: true)
            
            if mode != 0 {
                
                if mode != self.currentMode {
                    
                    self.currentMode = mode
                    gameTimer?.invalidate()
                    gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ChallengeNode.updateActiveTimeStamp), userInfo: nil, repeats: true)
                    
                }
                
                if user.started_timeStamp != nil {
                    
                    let date = user.started_timeStamp.dateValue()
                    ChallengeViews.messageLbl.text = "Actives \(timeAgoSinceDate(date, numericDates: true))"
                    
                } else {
                
                    ChallengeViews.messageLbl.text = "Challenge is just active"
                    
                }
                
            } else {
                
                gameTimer?.invalidate()
                
            }
            
        } else {
            
            if gameTimer != nil {
                
                gameTimer?.invalidate()
                
            }
            
            
        }
        
     
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        infoView.style.preferredSize = CGSize(width: constrainedSize.max.width , height: 70)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: infoView)
        
    }
    
    


    func loadInfo(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                
                if let item = snapshot.data() {
                    
                    
                        if let usern = item["username"] as? String {
                            
                            //ChallengeViews.nameLbl
                            
                            self.getstar(user: usern, uid: uid)
                            
                            if let avatarUrl = item["avatarUrl"] as? String {
                                
                                imageStorage.async.object(forKey: avatarUrl) { result in
                                    if case .value(let image) = result {
                                        
                                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                            
                                            
                                            self.ChallengeViews.avatarImg.image = image
                                            
                            
                                        }
                                        
                                    } else {
                                        
                                        
                                     AF.request(avatarUrl).responseImage { response in
                                            
                                            
                                            switch response.result {
                                            case let .success(value):
                                                self.ChallengeViews.avatarImg.image = value
                                                try? imageStorage.setObject(value, forKey: avatarUrl, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                               
                                            case let .failure(error):
                                                print(error)
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            
                                
                            }
                            
       
                        }
                    
                }
                
                
                
            } else {
                
                self.ChallengeViews.nameLbl.text = "Undefined"
                
            }
            
            
        }
    }

    func getstar(user: String, uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Challenge_rate").whereField("to_uid", isEqualTo: uid).limit(to: 100).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            if snapshot.isEmpty != true {
                
                var rate_lis = [Int]()
                
                for item in snapshot.documents {
                    
                    if let current_rate = item.data()["rate_value"] as? Int {
                        
                        
                        rate_lis.append(current_rate)
                        
                    }
                    
                }
                
                
                let average = calculateMedian(array: rate_lis)
                let usernameAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white]
                let starAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                
                let usertext = NSMutableAttributedString(string: "\(user) ", attributes: usernameAttributes)
                let rate = NSAttributedString(string: " \(String(format:"%.1f", average))", attributes: starAttributes)

                // create our NSTextAttachment
                let image1Attachment = NSTextAttachment()
                image1Attachment.image = UIImage(named: "shapes-and-symbols")

                // wrap the attachment in its own attributed string so we can append it
                let image1String = NSAttributedString(attachment: image1Attachment)

                // add the NSTextAttachment wrapper to our full string, then add some more text.
                usertext.append(image1String)
                usertext.append(rate)
                
                self.ChallengeViews.nameLbl.attributedText = usertext
                
            } else {
                
                
                self.ChallengeViews.nameLbl.text = user
                
            }
            
           
            
            
        }
        
        
    }
    
    
    
}
