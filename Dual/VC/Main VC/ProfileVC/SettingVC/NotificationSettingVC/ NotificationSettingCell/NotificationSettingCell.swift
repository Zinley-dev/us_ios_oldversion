//
//  NotificationSettingCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/27/21.
//

import UIKit
import Firebase
import SendBirdSDK
import SendBirdCalls
import SendBirdUIKit

class NotificationSettingCell: UITableViewCell {
    

    @IBOutlet var name: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    
    var info: String!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    func configureCell(_ Information: String) {
        
        self.info = Information
        name.text = self.info
        
        
        if self.info == "Challenge" {
            
            //icon.image = UIImage(named: "selectedChallenge")
            
            if isChallengeNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
            
        } else if self.info == "Comment" {
            //icon.image = UIImage(named: "Icon awesome-comment-alt")
            
            if isCommentNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        } else if self.info == "Message" {
            //icon.image = UIImage(named: "selectedMessage")
            
            if isMessageNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        } else if self.info == "Follow" {
            //icon.image = UIImage(named: "selectedFriends")
            
            if isFollowNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        } else if self.info == "Call" {
            
            //icon.image = UIImage(named: "callnoti")
            
            if isCallNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        } else if self.info == "Highlight" {
            
            //icon.image = UIImage(named: "Highlight")
            
            if isHighlightNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        } else if self.info == "Mention" {
            //icon.image = UIImage(named: "mentioned")
            
            if isMentionNoti == true {
                
                self.modeSwitch.setOn(true, animated: true)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: true)
                
            }
            
        }
            
    }
    
    @IBAction func modeBtnPressed(_ sender: Any) {
        
        if self.info == "Challenge" {
            
            if isChallengeNoti == true {
                
                
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["ChallengeNotiStatus": false])
                
            } else {
                
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["ChallengeNotiStatus": true])
                
            }
            
        } else if self.info == "Highlight" {
            
            if isHighlightNoti == true {
                
                
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["HighlightNotiStatus": false])
                
            } else {
                
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["HighlightNotiStatus": true])
                
            }
            
        } else if self.info == "Comment" {
            
            if isCommentNoti == true {
                
                
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["CommentNotiStatus": false])
                
            } else {
                
               
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["CommentNotiStatus": true])
                
            }
            
        } else if self.info == "Follow" {
            
            if isFollowNoti == true {
                
                
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["FollowNotiStatus": false])
                
            } else {
                
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["FollowNotiStatus": true])
                
            }
            
        } else if self.info == "Message" {
            
            if isMessageNoti == true {
                              
                
                SBUMain.connect { user, error in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                        showNote(text: error!.localizedDescription)
                        return
                    }
                    
                    if user != nil {
                        
                        SBDMain.setPushTriggerOption(.off) { err in
                            if err != nil {
                                
                                showNote(text: err!.localizedDescription)
                                
                            } else {
                                self.modeSwitch.setOn(false, animated: true)
                                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["MessageNotiStatus": false])
                            }
                        }
                        
                    }
                }
                                 
                
            } else {
                
                SBUMain.connect { user, error in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                        showNote(text: error!.localizedDescription)
                        return
                    }
                    
                    if user != nil {
                        
                        SBDMain.setPushTriggerOption(.all) { err in
                            if err != nil {
                                showNote(text: err!.localizedDescription)
                                
                            } else {
                                
                                self.modeSwitch.setOn(true, animated: true)
                                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["MessageNotiStatus": true])
                                
                            }
                        }
                        
                    }
                }
                
                
                
                
        }
            
        } else if self.info == "Mention" {
            

            if isMentionNoti == true {
                
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["MentionNotiStatus": false])
                
            } else {
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["MentionNotiStatus": true])
                
            }
            
        }
        
    }
    

}
