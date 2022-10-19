//
//  SettingVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/2/20.
//

import UIKit
import Firebase
import SafariServices
import SendBirdUIKit
import SendBirdCalls
import FBSDKLoginKit
import FBSDKCoreKit

class SettingVC: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    struct setting {
       let name : String
       var items : [String]
    }
   
    var window: UIWindow?
    
    var sections = [setting(name:"Challenge", items: ["Challenge"]), setting(name:"Social", items: ["Discord link", "Referral code", "Find friends"]), setting(name:"Video", items: ["Sound", "Automatic minimize"]),  setting(name:"Account", items: ["Edit profile", "Push notification", "Account activity", "Social link", "Blocked Accounts", "Contact Us", "Term of Service", "About Us", "Logout"])]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tableView.reloadData()
        tableView.backgroundColor = UIColor.clear
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
         
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = self.view.backgroundColor
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
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell {
          
           cell.configureCell(item)
    
            
            return cell
            
        } else {
            
            return SettingCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let i = self.sections[indexPath.section].items
        let item = i[indexPath.row]
        
        if item == "Edit profile" {
            
            self.performSegue(withIdentifier: "moveToEditProfileVC", sender: nil)
            
        } else if item == "Account activity" {
                        
            self.performSegue(withIdentifier: "moveToAccountActivityVC", sender: nil)
            
        }  else if item == "Term of Service" {
            
            openTermOfService()
            
            
        } else if item == "About Us" {
            
            openAboutUs()
            
            
        } else if item == "Blocked Accounts" {
            
            self.performSegue(withIdentifier: "moveToBlockVC", sender: nil)
        }
        
        else if item == "Logout" {
            
            
            let alert = UIAlertController(title: "Hi \(global_username), are you sure you want to logout?", message: "We and all gamers will miss you and always welcome you back.", preferredStyle: UIAlertController.Style.actionSheet)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: { action in
                
                self.logout()
        
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
            
        
            
 
            //disconnect()
        
        } else if item == "Contact Us" {
            
            self.performSegue(withIdentifier: "moveToContactUsVC", sender: nil)
             
            
        } else if item == "Social link" {
            
            self.performSegue(withIdentifier: "moveToSocialVC", sender: nil)
            
            
        } else if item == "Referral code" {
            
            self.performSegue(withIdentifier: "moveToReferralCodeVC", sender: nil)
            
        } else if item == "Push notification" {
            
            self.performSegue(withIdentifier: "moveToNotificationSettingVC", sender: nil)
            
        } else if item == "Find friends" {
            
            self.performSegue(withIdentifier: "moveToFindFriendsVC", sender: nil)
            
        }
    
    
        
    }
    
    func logout() {
        
        swiftLoader(text: "Logging out")
        
        if let uid = Auth.auth().currentUser?.uid {
            
            removeFCMToken(userUID: uid) {
                removetargetFCMToken() {
        
                    SBUMain.connect { usr, error in
                        if error != nil {
                            print(error!.localizedDescription)
                            SwiftLoader.hide()
                        } else {
                        
                            if usr != nil {
                                
                                if let pushToken = SBDMain.getPendingPushToken() {
                                    SBDMain.unregisterPushToken(pushToken, completionHandler: { (response, error) in
                                        /// Fixed Optional Problem(.getPendingPushToken()! -> pushToken)
                                        if error != nil {
                                            showNote(text: error!.localizedDescription)
                                            print(error!.localizedDescription)
                                        } else {
                                            print("SendBirdChat 1 disconnect")
                                            SBDMain.disconnect {
                                                
                                            }
                                        }
                                    })
                                }
                                
                                //
                                
                                SendBirdCall.unregisterVoIPPush(token: UserDefaults.standard.voipPushToken) { (error) in
                                    
                                    if error != nil {
                                        
                                        print(error!.localizedDescription)
                                        
                                    } else {
                                        
                                        SendBirdCall.deauthenticate { err in
                                            if err != nil {
                                                
                                                print(err!.localizedDescription)
                                                
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                    print("SendBirdCall disconnect")

                                        // The VoIP push token has been unregistered successfully.
                                }
                                
                            }
                            
                        }
                        
                        SBDMain.removeAllChannelDelegates()
                        SBDMain.removeAllUserEventDelegates()
                        SBDMain.removeSessionDelegate()
                        SBDMain.removeAllUserEventDelegates()
                        
                        ActivityLogService.instance.UpdateAccountActivityLog(mode: "Logout", info: "nil")
                        let userDefaults = UserDefaults.standard
                        userDefaults.removeObject(forKey: "hasGuideLandScapeBefore")
                        userDefaults.removeObject(forKey: "hasGuideSwipePlaySpeed")
                        userDefaults.removeObject(forKey: "hasGuideLandscapeAnimation")
                        userDefaults.removeObject(forKey: "hasGuideHideInformation")
                        userDefaults.removeObject(forKey: "hasAlertContentBefore")
                        userDefaults.removeObject(forKey: "hasGuideChallengefore")
                        userDefaults.removeObject(forKey: "hasGuideEditChallengefore")
                        
                        removeAllListen()
                        
                        
                        
                        let loginManager = LoginManager()
                        loginManager.logOut()
                        
                        
                        
                        imageStorage.async.removeAll(completion: { result in
                            
                            DispatchQueue.main.async() {
                                
                                
                                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProcessVC") as? ProcessVC {
                                    viewController.modalPresentationStyle = .fullScreen
                                    delay(1.0) {
                                        
                                        SwiftLoader.hide()
                                        try? Auth.auth().signOut()
                                        
                                        self.present(viewController, animated: true, completion: nil)
                                    }
                                   
                                }
                                
                            }
                            
                        })
                        
                        
                        
                    }
                    
                }
            }
          
        }
        

        
    }
    
    
    func openTermOfService() {
        
        
        guard let urls = URL(string: "https://dual.live/terms-of-service/") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func openAboutUs() {
        
        guard let urls = URL(string: "https://dual.live/support/") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        
        
        self.present(vc, animated: true, completion: nil)
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
    
    func swiftLoader(text: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: text, animated: true)
        
                                                                                                                                      
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
   
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    func findIndex(target: String, list: [String]) -> Int{
        
        var count = 0
        
        for item in list {
            
            if item == target {
                
                break
                
            }
            
            count+=1
        }
        
        return count
        
    }
    
}
