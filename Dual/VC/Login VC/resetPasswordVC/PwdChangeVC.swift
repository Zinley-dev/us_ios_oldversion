//
//  PwdChangeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit
import Firebase

class PwdChangeVC: UIViewController {
    
    
    var finalPhone: String?
    var finalCode: String?
    var finalEmail: String?
    var finalusername: String?
    var type: String?
   

    @IBOutlet weak var newPwdLbl: UITextField!
    @IBOutlet weak var confirmedNewPwdLbl: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        newPwdLbl.attributedPlaceholder = NSAttributedString(string: "Enter your new password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        confirmedNewPwdLbl.attributedPlaceholder = NSAttributedString(string: "Confirm your new password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if let newPwd = newPwdLbl.text, newPwd != "", let confirmedNewPwd = confirmedNewPwdLbl.text, confirmedNewPwd != "", newPwd.count >= 5, confirmedNewPwd.count >= 6, newPwd == confirmedNewPwd {
            
            if self.type != nil {
                
                if type == "phone" {
                    
                    processSignIn(newpwd: newPwd, phone: finalPhone!, code: finalCode!, username: finalusername!, email: "", type: type!)
                    
                } else if type == "email" {
                    
                    processSignIn(newpwd: newPwd, phone: "", code: "", username: finalusername!, email: finalEmail!, type: type!)
                    
                } else {
                    
                    
                    self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
                }
                
                
                
            }
            
            
            
        } else {
            
            
            self.showErrorAlert("Oops!", msg: "You password may be not matched or not sastify the length.")
            
        }
        
        
    }
    
    func processSignIn(newpwd: String,phone: String, code: String, username: String, email: String, type: String) {
                
        var query: Query!
             
        if type == "phone" {
            
            query = DataService.instance.mainFireStoreRef.collection("Users").whereField("phone", isEqualTo: phone).whereField("code", isEqualTo: code).whereField("username", isEqualTo: username)
        } else if type  == "email" {
            query = DataService.instance.mainFireStoreRef.collection("Users").whereField("Email", isEqualTo: email).whereField("username", isEqualTo: username)
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
            return
            
        }
        
        swiftLoader()
        
        Auth.auth().signInAnonymously { result, err in
            if err != nil {
                
                print(err!.localizedDescription)
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            
            query.getDocuments { (snap, err) in
                
                if err != nil {
                    
                    SwiftLoader.hide()
                    try? Auth.auth().signOut()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    return
                }
                
                if snap?.isEmpty == true {
                    
                    SwiftLoader.hide()
                    try? Auth.auth().signOut()
                    self.showErrorAlert("Oops!", msg: "Can't load user, unable to update password now!")
                    //self.performSegue(withIdentifier: "moveToDetailInfoVC", sender: nil)
                    
                } else {
                    
                    for item in snap!.documents {
               
                        let i = item.data()
                        
                        if let encryptedKey = i["encryptedKey"] as? String  {
                            
                            self.processFinalSignIn(newpwd: newpwd, key: encryptedKey, update_key: item.documentID)
                            
                            
                        }
                        
                    }
                               
                }
                
         
                
            }
            
        }
        
        
        
        
    }
    
    func processFinalSignIn(newpwd: String, key: String, update_key: String) {
        
        DataService.instance.mainFireStoreRef.collection("Pwd_users").whereField("secret_key", isEqualTo: key).getDocuments { (snap, err) in
            
            if err != nil {
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
       
                let i = item.data()
                
                if let pwd = i["password"] as? String {
                    
                   let encryptedRandomEmail = "\(key)@credential-dual.so"
                    
                    try? Auth.auth().signOut()
                    
                    Auth.auth().signIn(withEmail: encryptedRandomEmail, password: pwd) { (result, error) in
                        
                        if error != nil {
                            
                            SwiftLoader.hide()
                            try? Auth.auth().signOut()
                            self.showErrorAlert("Opss !", msg: error!.localizedDescription)
                            return
                            
                        }
                       
                        if let pwd = i["password"] as? String {
                            
                            if newpwd != pwd {
                                
                                Auth.auth().currentUser?.updatePassword(to: newpwd, completion: { errs in
                                    
                                    if errs != nil {
                                        
                                        SwiftLoader.hide()
                                        try? Auth.auth().signOut()
                                        self.showErrorAlert("Ops!", msg: errs!.localizedDescription)
                                        return
                                    }
                                    
                                    
                                    let id = item.documentID
                                    DataService.instance.mainFireStoreRef.collection("Pwd_users").document(id).updateData(["password": newpwd]) { (error) in
                                        
                                        if error != nil {
                                            
                                            SwiftLoader.hide()
                                            try? Auth.auth().signOut()
                                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                                            return
                                            
                                        }
                                                                  
                                        self.confirmedNewPwdLbl.text = ""
                                        self.newPwdLbl.text = ""
                                        
                                        ActivityLogService.instance.UpdateAccountActivityLog(mode: "Update", info: "Password")
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1000)) {
                                            
                                            
                                            try? Auth.auth().signOut()
                                            SwiftLoader.hide()
                                            showNote(text: "Your new passsord is updated!")
                                            self.performSegue(withIdentifier: "moveToMainVC400", sender: nil)
                                            
                                        }
                                                                         
                                    }
                                    
                                })
                                
                                
                                
                                
                            } else {
                                
                                self.confirmedNewPwdLbl.text = ""
                                self.newPwdLbl.text = ""
                                SwiftLoader.hide()
                                try? Auth.auth().signOut()
                                self.showErrorAlert("Opss !", msg: "Your new password can't be same as any of your previous password.")
                                
                            }
                            
                        } else {
                            
                            self.confirmedNewPwdLbl.text = ""
                            self.newPwdLbl.text = ""
                            
                            SwiftLoader.hide()
                            try? Auth.auth().signOut()
                            self.showErrorAlert("Opss !", msg: "Can't update your password now.")
                            
                            
                        }
                     
                    }
                    
                    
                }
                
            }
            
            
            
            
        }
        
        
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
