//
//  ViewVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/9/21.
//

import UIKit

class ViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var selected_item: HighlightsModel!
    
    struct setting {
       let name : String
       var items : [String]
    }
   
    var window: UIWindow?
    
    var sections = [setting(name:"Views", items: ["Total views", "Views in 60 mins", "Views in 24 hours"]), setting(name:"GG!", items: ["Total GG!","GG! in 60 mins", "GG! in 24 hours"])]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
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
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell") as? ViewCell {
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.black
                cell.addSubview(line)
                
            }
            
    
            //cell.configureCell(item, category: highlight.category, length: highlight.length, videos: highlight.videos, videoswhashtag: highlight.videoswhashtag)
    
            cell.configureCell(item, item: selected_item)
            
            return cell
            
        } else {
            
            return ViewCell()
            
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
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
