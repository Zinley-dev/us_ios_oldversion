//
//  personalCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/25/21.
//

import UIKit
import Firebase

class personalCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    var info: String!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    func configureCell(_ Information: String, category: Int, length: Double, videos: Int, videoswhashtag: Int) {
        
        self.info = Information
        name.text = self.info
        
        if self.info == "Challenges you have sent" {
            loadMadeChallenges()
        } else if self.info == "Challenges you have received" {
            loadReceivedChallenges()
        } else if self.info == "Challenges you have accepted" {
            loadAcceptedChallenges()
        } else if self.info == "Number of categories" {
            self.descLbl.text = "\(formatPoints(num: Double(category)))"
        } else if self.info == "Total videos" {
            self.descLbl.text = "\(formatPoints(num: Double(videos)))"
        } else if self.info == "Total videos with hashtag" {
            self.descLbl.text = "\(formatPoints(num: Double(videoswhashtag)))"
        } else if self.info == "Total length" {
            
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            let formattedString = formatter.string(from: TimeInterval(length))!
            self.descLbl.text = formattedString
            
        } else if self.info == "Total views" {
            loadTotalViews()
        } else if self.info == "Total GG!" {
            loadTotalLikes()
        } else if self.info == "Total link tapped" {
            loadTotalLinkTapped()
        }
        
    }
    
    func loadMadeChallenges() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }
    
    func loadReceivedChallenges() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }
    
    func loadAcceptedChallenges() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("uid_list", arrayContains: Auth.auth().currentUser!.uid).whereField("isAccepted", isEqualTo: true).getDocuments { (snap, err) in
            
            if err != nil {
                
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }
    
    
    func loadTotalViews() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Views")
        
        db.whereField("ownerUID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }
    
    func loadTotalLikes() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Likes")
        
        db.whereField("ownerUID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }
    
    func loadTotalLinkTapped() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Stream_link_record")
        
        db.whereField("ownerUID", isEqualTo: Auth.auth().currentUser!.uid).whereField("userUID", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                self.descLbl.text = "Error"
                
            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.descLbl.text = "0"
                    
                } else {
                    
                    self.descLbl.text = "\(formatPoints(num: Double(snap!.count)))"
                }
                
            }
            
        }
    }

}
