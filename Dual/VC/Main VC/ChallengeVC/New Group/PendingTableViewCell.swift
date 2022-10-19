//
//  ChallengeTableViewCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/21/20.
//

import UIKit
import MGSwipeTableCell

class PendingTableViewCell: MGSwipeTableCell {
    
    
    @IBOutlet var avatarImg: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messages: UILabel!
    
        
    var info: ChallengeModel!

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
        
        loadInfo(uid: self.info.sender_ID)
        messages.text = self.info.messages
        
    }
    
    func loadInfo(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
                if snapshot.isEmpty == true {
                    
                    username.text = "Undefined"
                    return
                }
                
                for item in snapshot.documents {
                
                    if let usern = item.data()["username"] as? String {
                        
                        //
                        
                        getstar(user: usern, uid: uid)
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            let imageNode = ASNetworkImageNode()
                            imageNode.contentMode = .scaleAspectFit
                            imageNode.shouldRenderProgressImages = true
                            imageNode.url = URL.init(string: avatarUrl)
                            imageNode.frame = avatarImg.layer.bounds
                            avatarImg.image = nil
                            
                            
                            avatarImg.addSubnode(imageNode)
                            
                        }
                        
   
                    }
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
                
                print(rate_lis.count)
                
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
