//
//  infoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/29/21.
//

import UIKit

class infoVC: UIViewController {

    @IBOutlet weak var aboutMeTxtView: UITextView!
    
    var uid: String?
    
    var istrack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if istrack == true {
            
            trackInfo()
            
        } else {
            
            loadInfoWithouTrack()
            
        }
        
    }
    
    func trackInfo() {
        
        let db = DataService.instance.mainFireStoreRef
        
        infoListen = db.collection("Users").document(uid!).addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let aboutMe = item["aboutMe"] as? String, aboutMe != "" {
                        
                        self.aboutMeTxtView.text = aboutMe
                                  
                    } else {
                        
                        self.aboutMeTxtView.text = "Let everyone get to know you better!"
                        
                    }
                    
                }
                
            } else {
                
                self.aboutMeTxtView.text = "Let everyone get to know you better!"
                
            }
            
            
                
         
        }
        
    }
    
    func loadInfoWithouTrack() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(uid!).getDocument { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let aboutMe = item["aboutMe"] as? String, aboutMe != "" {
                        
                        self.aboutMeTxtView.text = aboutMe
                        
                       
                    } else {
                        
                        self.aboutMeTxtView.text = "No information yet."
                        
                        
                    }
                    
                }
                
            } else {
                
                self.aboutMeTxtView.text = "No information yet."
                
            }
        
            
        }
        
       
    }
    

  

}
