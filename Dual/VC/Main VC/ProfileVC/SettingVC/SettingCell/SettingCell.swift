//
//  SettingCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/2/20.
//

import UIKit
import Firebase

class SettingCell: UITableViewCell {

    @IBOutlet var icon: UIImageView!
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
        
        
        if self.info == "Edit profile" {
            
            icon.image = UIImage(named: "SelectedOnlyMe")
            
            modeSwitch.isHidden = true
            
        } else if self.info == "Find friends" {
            
            icon.image = UIImage(named: "contact")
            
            modeSwitch.isHidden = true
            
            
        } else if self.info == "Challenge" {
        
            modeSwitch.isHidden = false
            icon.image = UIImage(named: "selectedChallenge")
            
            if isChallenge == true {
                
                self.modeSwitch.setOn(true, animated: false)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: false)
                
            }
            
        
        } else if self.info == "Push notification" {
            
            icon.image = UIImage(named: "pushnoti")
            modeSwitch.isHidden = true
            
        } else if self.info == "Referral code" {
            
            icon.image = UIImage(named: "referCode")
            modeSwitch.isHidden = true
            
        } else if self.info == "Discord link"{
            
            modeSwitch.isHidden = false
            icon.image = UIImage(named: "discord")
            
            
            if isDiscord == true {
                
                self.modeSwitch.setOn(true, animated: false)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: false)
                
            }
            
        } else if self.info == "Social link" {
            
            icon.image = UIImage(named: "Social")
            modeSwitch.isHidden = true
                    
        } else if self.info == "Sound" {
            
           
            icon.image = UIImage(named: "3xunmute")
            modeSwitch.isHidden = false
            
            if isSound == true {
                
                self.modeSwitch.setOn(true, animated: false)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: false)
                
            }
            
            
        } else if self.info == "Automatic minimize" {
            
            
            icon.image = UIImage(named: "down")
            modeSwitch.isHidden = false
            
            if isMinimize == true {
                
                self.modeSwitch.setOn(true, animated: false)
                
            } else {
                
                self.modeSwitch.setOn(false, animated: false)
                
            }
            
            
        } else {
            
            modeSwitch.isHidden = true
            icon.image = UIImage(named: "\(Information)")
            
        }
        
        

        
    }
 
    @IBAction func modeBtnPressed(_ sender: Any) {
        
        if self.info == "Challenge" {
            
            if isChallenge == true {
                
                //isChallenge = false
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["ChallengeStatus": false])
                
            } else {
                
                //isChallenge = true
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["ChallengeStatus": true])
                
            }
            
        } else if self.info == "Discord link" {
            
            if isDiscord == true {
                
                //isDiscord = false
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["DiscordStatus": false])
                
            } else {
                
                //isDiscord = true
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["DiscordStatus": true])
                
            }
            
        } else if self.info == "Social link" {
            
            if isSocial == true {
                
                //isSocial = false
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["SocialStatus": false])
                
            } else {
                
                //isSocial = true
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["SocialStatus": true])
                
            }
            
        } else if self.info == "Sound" {
            
            if isSound == true {
                
               
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isSound": false])
                
            } else {
                
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isSound": true])
                
            }
            
            
            
        } else if self.info == "Automatic minimize" {
            
            
            if isMinimize == true {
                
               
                self.modeSwitch.setOn(false, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isMinimize": false])
                
            } else {
                
                
                self.modeSwitch.setOn(true, animated: true)
                DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isMinimize": true])
                
            }
            
            
        }
        
        
        
        
    }

    
}
