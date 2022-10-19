//
//  ViewCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/10/21.
//

import UIKit

class ViewCell: UITableViewCell {

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
    
    
    func configureCell(_ Information: String, item: HighlightsModel) {
        
        self.info = Information
        name.text = self.info
        
        if self.info == "Total views" {
            loadTotalViews(item: item)
        } else if self.info == "Views in 60 mins" {
            loadTotalViewsIn60Mins(item: item)
        } else if self.info == "Views in 24 hours" {
            loadTotalViewsIn24Hours(item: item)
        } else if self.info == "Total GG!" {
            loadTotalLikes(item: item)
        } else if self.info == "GG! in 60 mins" {
           loadTotalLikesIn60Mins(item: item)
        } else if self.info == "GG! in 24 hours" {
           loadTotalLikesIn24Hours(item: item)
        }
        
        
    }
    
    func loadTotalViews(item: HighlightsModel) {
        
        DataService.instance.mainFireStoreRef.collection("Views").whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    func loadTotalViewsIn60Mins(item: HighlightsModel) {
        
        let timeNow = Date().timeIntervalSince1970
        let time24hoursBeforeNow = timeNow - 60 * 60
        let date = NSDate(timeIntervalSince1970: time24hoursBeforeNow)
        
        DataService.instance.mainFireStoreRef.collection("Views").whereField("post_time", isGreaterThan: date).whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    
    func loadTotalViewsIn24Hours(item: HighlightsModel) {
        
        let timeNow = Date().timeIntervalSince1970
        let time24hoursBeforeNow = timeNow - 24 * 60 * 60
        let date = NSDate(timeIntervalSince1970: time24hoursBeforeNow)
        
        DataService.instance.mainFireStoreRef.collection("Views").whereField("post_time", isGreaterThan: date).whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    func loadTotalLikes(item: HighlightsModel) {
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    func loadTotalLikesIn60Mins(item: HighlightsModel) {
        
        let timeNow = Date().timeIntervalSince1970
        let time24hoursBeforeNow = timeNow - 60 * 60
        let date = NSDate(timeIntervalSince1970: time24hoursBeforeNow)
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("timeStamp", isGreaterThan: date).whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    
    func loadTotalLikesIn24Hours(item: HighlightsModel) {
        
        let timeNow = Date().timeIntervalSince1970
        let time24hoursBeforeNow = timeNow - 24 * 60 * 60
        let date = NSDate(timeIntervalSince1970: time24hoursBeforeNow)
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("timeStamp", isGreaterThan: date).whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.descLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.descLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
        
    }
    
    
    

}
