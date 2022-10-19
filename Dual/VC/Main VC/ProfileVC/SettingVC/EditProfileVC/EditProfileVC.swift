//
//  EditProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var feature = ["General information", "About me", "Email address", "Phone number", "Password", "Account deletion request"]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
       // tableView.reloadData()
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = feature[indexPath.row]
        

        if let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell") as? EditProfileCell {
            
            
            if indexPath.row != 0 {
                
                let lineFrame = CGRect(x:0, y:-10, width: self.view.frame.width, height: 11)
                let line = UIView(frame: lineFrame)
                line.backgroundColor = UIColor.black
                cell.addSubview(line)
                
            }
            
            
            if item == "Account deletion request", indexPath.row == 5 {
                
                cell.contentView.backgroundColor = self.view.backgroundColor
               
            }
                
                
                
            
           cell.configureCell(item)
            
            return cell
            
        } else {
            
            return EditProfileCell()
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let item = feature[indexPath.row]
        
        if item == "General information" {
            
            self.performSegue(withIdentifier: "moveToGeneralInfomationVC", sender: nil)
            
        } else if item == "Email address" {
            
            self.performSegue(withIdentifier: "moveToChangeEmailVC", sender: nil)
            
        } else if item == "Phone number" {
            
            self.performSegue(withIdentifier: "moveToChangePhoneVC", sender: nil)
            
        } else if item == "Password" {
            
            self.performSegue(withIdentifier: "moveToChangePwdVC", sender: nil)
            
        } else if item == "Social" {
            
            //moveToSocialVC
            self.performSegue(withIdentifier: "moveToSocialVC", sender: nil)
            
        } else if item == "About me" {
            
            self.performSegue(withIdentifier: "moveToInfoVC", sender: nil)
            
        } else if item == "Account deletion request" {
            
            if isPending_deletion == false {
                
                
                let alert = UIAlertController(title: "Hi \(global_username), are you sure you want to delete the account?", message: "We're so sorry to see you go. If it's been less than 30 days since you initiated the deletion, you can cancel your account deletion. After 30 days, your account and all your information will be permanently deleted, and you won't be able to retrieve your information. It may take up to 90 days from the beginning of the deletion process to delete all the things you've posted. While we're deleting this information, it's not accessible to other people using Dual.", preferredStyle: UIAlertController.Style.actionSheet)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to delete", style: UIAlertAction.Style.destructive, handler: { action in
                    
                
                    DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isPending_deletion": true, "isPending_deletion_timeStamp":  FieldValue.serverTimestamp()]) { err in
                        if err != nil {
                            self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                        }
                        
                        self.tableView.reloadRows(at: [IndexPath(row: self.feature.count - 1, section: 0)], with: .automatic)
                        
                    }
                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                let alert = UIAlertController(title: "Hi \(global_username),", message: "If you choose to cancel, all of your information is still safe and protected. Nothing needs to be done to keep using all available services at Dual. Let's enjoy and have fun.", preferredStyle: UIAlertController.Style.actionSheet)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to cancel", style: UIAlertAction.Style.destructive, handler: { action in
                    
                    DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["isPending_deletion": false]) { err in
                        if err != nil {
                            self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                        }
                        
                        self.tableView.reloadRows(at: [IndexPath(row: self.feature.count - 1, section: 0)], with: .automatic)
                        
                        
                    }
                    
                   
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
            }
        
        
        }
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
}
