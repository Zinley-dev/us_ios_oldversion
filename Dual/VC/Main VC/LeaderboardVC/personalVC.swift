//
//  personalVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/23/21.
//

import UIKit
import Firebase
import SafariServices

class personalVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    struct setting {
       let name : String
       var items : [String]
    }
   
    var window: UIWindow?
    
    var sections = [setting(name:"Challenges", items: ["Challenges you have sent", "Challenges you have received", "Challenges you have accepted"]), setting(name:"Highlights", items: ["Number of categories","Total videos", "Total videos with hashtag", "Total length"]),  setting(name:"Highlight interactions", items: ["Total views", "Total GG!", "Total link tapped"])]
    
    var highlight: HighlightStatisticModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadNumberOfCategories {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.allowsSelection = false
            self.tableView.reloadData()
        }
        
    }
    
    
    
    func loadNumberOfCategories(completed: @escaping DownloadComplete) {
        
        var category_list = [String]()
        var video_count: Int!
        var length_list = [Double]()
        var videoswhashtag_list = 0
        
        let db = DataService.instance.mainFireStoreRef.collection("Highlights")
        
        db.whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).whereField("h_status", isEqualTo: "Ready").getDocuments { (snap, err) in
            
            if err != nil {
                
                self.highlight = HighlightStatisticModel(postKey: "key", HighlightStatisticModel: ["category": 0, "videos": 0, "length": 0, "videoswhashtag": 0])
                completed()

            } else {
                
                
                if snap!.isEmpty == true {
                    
                    self.highlight = HighlightStatisticModel(postKey: "key", HighlightStatisticModel: ["category": 0, "videos": 0, "length": 0, "videoswhashtag": 0])
                    completed()
                    
                } else {
                    
                    video_count = snap?.count
                    
                    
                    for item in snap!.documents {
                        
                        if let category = item.data()["category"] as? String {
                            
                            if !category_list.contains(category) {
                                category_list.append(category)
                            }
                            
                        }
                        
                        if let length = item.data()["length"] as? Double {
                            
                            length_list.append(length)
                            
                        }
                        
                        
                        if let hashtag_list = item.data()["hashtag_list"] as? [String] {
                            
                            if !hashtag_list.isEmpty, hashtag_list.count > 2 {
                                
                                videoswhashtag_list+=1
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    self.highlight = HighlightStatisticModel(postKey: "key", HighlightStatisticModel: ["category": category_list.count, "videos": video_count!, "length": length_list.reduce(0, +), "videoswhashtag": videoswhashtag_list])
                    
                    completed()
                    
                }
                
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
         
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.black
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
        
        if let frame = (view as! UITableViewHeaderFooterView).textLabel?.frame {
            
            (view as! UITableViewHeaderFooterView).textLabel?.frame = CGRect(x: -15, y: 0, width: frame.width, height: frame.height)
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let i = self.sections[indexPath.section].items
        let item = i[indexPath.row]
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "personalCell") as? personalCell {
            
            cell.backgroundColor = UIColor.darkGray
            
            if indexPath.row != 0 {
                
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.black
                cell.addSubview(line)
                
            }
            
    
            cell.configureCell(item, category: highlight.category, length: highlight.length, videos: highlight.videos, videoswhashtag: highlight.videoswhashtag)
    
            
            return cell
            
        } else {
            
            return SettingCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                                                                      
        
    }
    
}
