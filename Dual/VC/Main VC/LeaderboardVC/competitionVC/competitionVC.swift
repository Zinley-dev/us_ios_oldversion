//
//  competitionVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/25/21.
//

import UIKit
import Firebase
import SafariServices
import AsyncDisplayKit

class competitionVC: UIViewController {

    @IBOutlet weak var competitionTitle: UILabel!
    
    @IBOutlet weak var BannerImg: UIImageView!
    @IBOutlet weak var descTxtView: UITextView!
    
    @IBOutlet weak var timeFramelbl: UILabel!
    var selectedItem = [String: Any]()
    
    var info_url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if selectedItem.isEmpty != true {
            
            if let title = selectedItem["Title"] as? String {
                
                
                //self.competitionTitle.text = title
                
            }
            
            if let start_date = selectedItem["start date"] as? Timestamp {
                
                if let end_date = selectedItem["end date"] as? Timestamp {
                    
                    
                    self.timeFramelbl.text = "From \(getReadableDate(timeStamp: start_date.dateValue().timeIntervalSince1970)!) to \(getReadableDate(timeStamp: end_date.dateValue().timeIntervalSince1970)!)"
               
                    
                }
                
            }
            
            
            
            if let desc = selectedItem["description"] as? String {
                
                //self.descTxtView.text = ""
                
            }
            
            
            if let url = selectedItem["url"] as? String {
                
                let imageNode = ASNetworkImageNode()
                imageNode.contentMode = .scaleAspectFill
                imageNode.shouldRenderProgressImages = true
                imageNode.url = URL.init(string: url)
                //imageNode.frame = BannerImg.layer.bounds
                
                
                
                BannerImg.backgroundColor = UIColor.clear
                BannerImg.addSubnode(imageNode)
                
                
                imageNode.view.translatesAutoresizingMaskIntoConstraints = false
                imageNode.view.topAnchor.constraint(equalTo: self.BannerImg.topAnchor, constant: 0).isActive = true
                imageNode.view.leadingAnchor.constraint(equalTo: self.BannerImg.leadingAnchor, constant: 0).isActive = true
                imageNode.view.trailingAnchor.constraint(equalTo: self.BannerImg.trailingAnchor, constant: 0).isActive = true
                imageNode.view.bottomAnchor.constraint(equalTo: self.BannerImg.bottomAnchor, constant: 0).isActive = true
                
            }
            
            if let info_url = selectedItem["info_url"] as? String {
                
                self.info_url = info_url
                
            }
             
            
        }
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
  
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func openCompetitionLinkBtnPressed(_ sender: Any) {
    
        
        if info_url != ""
        {
            guard let urls = URL(string: info_url) else {
                return //be safe
            }
            
            let vc = SFSafariViewController(url: urls)
            
            
            self.present(vc, animated: true, completion: nil)
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't open this current link")
            
        }
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
