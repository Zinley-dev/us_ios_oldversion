//
//  ActiveTableViewCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/21/20.
//

import UIKit
import Firebase
import AsyncDisplayKit

class ActiveTableViewCell: UITableViewCell {
    
    @IBOutlet var avatarImg: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messages: UILabel!
    
    var info: ChallengeModel!
    var gameTimer: Timer?
   
    var currentMode = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func configureCell(_ Information: ChallengeModel) {
        
        self.info = Information
        for uid in self.info.uid_list {
            
            if uid != Auth.auth().currentUser?.uid {
                
                
                loadInfo(uid: uid)
                
            }
            
            
        }
        
        if self.info.started_timeStamp != nil {
            
            let date = self.info.started_timeStamp.dateValue()
            messages.text = "Actives \(timeAgoSinceDate(date, numericDates: true))"
            
        } else {
        
            messages.text = "Challenge is active"
            
        }
        
        
        if self.info.started_timeStamp != nil {
            
            let date = self.info.started_timeStamp.dateValue()
            let mode = timeForReloadScheduler(date, numericDates: true)
            
            if mode != 0 {
                
                self.currentMode = mode
                gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ActiveTableViewCell.updateTimeStamp), userInfo: nil, repeats: true)
                
            }
            
            
            
        }
        
        
        
    }
    
    
    @objc func updateTimeStamp() {
        
        if self.info.started_timeStamp != nil {
            
            let date = self.info.started_timeStamp.dateValue()
            let mode = timeForReloadScheduler(date, numericDates: true)
            
            if mode != 0 {
                
                if mode != self.currentMode {
                    
                    self.currentMode = mode
                    gameTimer?.invalidate()
                    gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(mode), target: self, selector: #selector(ActiveTableViewCell.updateTimeStamp), userInfo: nil, repeats: true)
                    
                }
                
                
                
                if self.info.started_timeStamp != nil {
                    
                    let date = self.info.started_timeStamp.dateValue()
                    messages.text = "Actives \(timeAgoSinceDate(date, numericDates: true))"
                    
                } else {
                
                    messages.text = "Challenge is active"
                    
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
    
    func loadInfo(uid: String) {
        
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let usern = item["username"] as? String {
                        
                        //
                        
                        self.getstar(user: usern, uid: uid)
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            let imageNode = ASNetworkImageNode()
                            imageNode.contentMode = .scaleAspectFill
                            imageNode.shouldRenderProgressImages = true
                            imageNode.url = URL.init(string: avatarUrl)
                            imageNode.frame = self.avatarImg.layer.bounds
                            self.avatarImg.image = nil
                            
                            
                            self.avatarImg.addSubnode(imageNode)
                            
                        }
                        

                    }
                    
                }
                
                
            } else {
                
                self.username.text = "Undefined"
                
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
                
                self.username.attributedText = usertext
                
            } else {
                
                
                self.username.text = user
                
            }
            
           
            
            
        }
        
        
    }


}
