//
//  SocialVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 7/15/21.
//

import UIKit
import Firebase

class SocialVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var DiscordUrlTxtField: UITextField!
   
    var updateID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadSocialInfo()
        
    }

    func loadSocialInfo() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        self.updateID = snapshot.documentID
                    
                        if let discord_link = item["discord_link"] as? String, discord_link != "nil", discord_link != "" {
                            
                            self.DiscordUrlTxtField.attributedPlaceholder = NSAttributedString(string: discord_link,
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                           
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
       
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if DiscordUrlTxtField.text != "" {
            
            print("Updating")
            
            var updateData = [String: Any]()
            
            
            if DiscordUrlTxtField.text != "" {
                
                
                if verifyUrl(urlString: DiscordUrlTxtField.text) != true {
                    
                    DiscordUrlTxtField.text = ""
                    self.showErrorAlert("Oops!", msg: "Seem like your discord link is not a valid url, please correct it.")
                    return
                    
                } else {
                    
                    if let urlString = DiscordUrlTxtField.text {
                        
                        if let url = URL(string: urlString) {
                            
                            if let domain = url.host {
                                
                                print(domain)
                                
                                if discord_verify(host: domain) == true {
                                    
                                    
                                    updateData.updateValue(self.DiscordUrlTxtField.text as Any, forKey: "discord_link")
                                    self.DiscordUrlTxtField.attributedPlaceholder = NSAttributedString(string: self.DiscordUrlTxtField.text!,
                                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                                    
                                    let db = DataService.instance.mainFireStoreRef.collection("Users")
                                    
                                    //
                                    db.document(self.updateID).updateData(updateData) { (err) in
                                        
                                        if err != nil {
                                            
                                            self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                                            return
                                        }
                                        
                                        
                                        self.DiscordUrlTxtField.text = ""
                                      
                                       
                                        self.view.endEditing(true)
                                        
                                        ActivityLogService.instance.UpdateAccountActivityLog(mode: "Update", info: "General information")
                                        let alertController = UIAlertController(title: "Your information has been saved!", message: nil, preferredStyle: .alert)
                                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alertController.addAction(defaultAction)
                                        self.present(alertController, animated: true, completion: nil)
                                        
                                    }
                                  
                                    
                                } else {
                                    
                                    DiscordUrlTxtField.text = ""
                                    self.showErrorAlert("Oops!", msg: "Your current discord link isn't valid/supported now, please check and correct it.")
                                    return
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                }
                
                
                
               
                
            }
            
            
            
            
            
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't find any change.")
            
            
        }
        
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        
        return false
    }
    
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
