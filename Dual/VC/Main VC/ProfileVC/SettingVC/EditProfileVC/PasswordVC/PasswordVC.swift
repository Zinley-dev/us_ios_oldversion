//
//  PasswordVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit
import Firebase

class PasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentPwdLbl: UITextField!
    @IBOutlet weak var newPwdLbl: UITextField!
    var refKey = ""
    var isSet = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         
        newPwdLbl.delegate = self
        currentPwdLbl.delegate = self
        
        newPwdLbl.attributedPlaceholder = NSAttributedString(string: "Your new password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        currentPwdLbl.attributedPlaceholder = NSAttributedString(string: "Your current password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        checkisSet()
        
    }
    
    func checkisSet() {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let encryptedKey = item["encryptedKey"] as? String {
                        
                        DataService.instance.mainFireStoreRef.collection("Pwd_users").whereField("secret_key", isEqualTo: encryptedKey).getDocuments { (snap, err) in
                            
                            if err != nil {
                                SwiftLoader.hide()
                                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                                return
                            }
                            
                            for item in snap!.documents {
                       
                                self.refKey = item.documentID
                                let i = item.data()
                                
                                if let isPasswordSet = i["isPasswordSet"] as? Bool {
                                    
                                    if isPasswordSet == true {
                                        self.isSet = true
                                    } else {
                                        self.isSet = false
                                    }
                                    
                                } else {
                                    self.isSet = false
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if self.isSet == true {
            
            if let currentPwd = currentPwdLbl.text, currentPwd != "", let newPwd = newPwdLbl.text, newPwd != "", currentPwd.count >= 6, newPwd.count >= 6 {
                
                swiftLoader()
                checkForCurrentPwd(currentInput: currentPwd, newInput: newPwd, shouldCheckCurrentInput: true)
                
                
            } else {
                
                self.newPwdLbl.text = ""
                self.currentPwdLbl.text = ""
                showErrorAlert("Oops!", msg: "Your input is wrong, please check and submit again.")
                
            }
            
        } else {
            
            if let newPwd = newPwdLbl.text, newPwd != "", newPwd.count >= 6 {
                
                swiftLoader()
                checkForCurrentPwd(currentInput: "", newInput: newPwd, shouldCheckCurrentInput: false)
                
                
            } else {
                
                self.newPwdLbl.text = ""
                self.currentPwdLbl.text = ""
                showErrorAlert("Oops!", msg: "Your input is wrong, please check and submit again.")
                
            }
            
            
        }
        
        
        
    }
    
    func checkForCurrentPwd(currentInput: String, newInput: String, shouldCheckCurrentInput: Bool) {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            if shouldCheckCurrentInput == true {
                
                
                DataService.instance.mainFireStoreRef.collection("Users").document(uid).getDocument { (snap, err) in
                    
                    if err != nil {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                        return
                    }
                    
                    if snap!.exists {
                        
                        if let i = snap!.data() {
                            
                            if let encryptedKey = i["encryptedKey"] as? String {
                                
                                    
                                self.checkKeyAndPerformChanges(currentInput: currentInput, newInput: newInput, key: encryptedKey)
                                
                            }
                            
                        }
                        
                        
                        
                    } else {
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Can't find your user.")
                        
                    }
                    
                }
                
            } else {
                
                if self.refKey != "" {
                    
                    Auth.auth().currentUser?.updatePassword(to: newInput, completion: { errs in
                        
                        if errs != nil {
                            
                            SwiftLoader.hide()
                            self.showErrorAlert("Ops!", msg: errs!.localizedDescription)
                            return
                        }
                        
                        
                        
                        DataService.instance.mainFireStoreRef.collection("Pwd_users").document(self.refKey).updateData(["password": newInput, "isPasswordSet": true]) { (error) in
                            
                            if error != nil {
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                                return
                                
                            }
                                                      
                            self.currentPwdLbl.text = ""
                            self.newPwdLbl.text = ""
                            self.isSet = true
                            
                            ActivityLogService.instance.UpdateAccountActivityLog(mode: "Update", info: "Password")
                            
                            
                            SwiftLoader.hide()
       
                            let alertController = UIAlertController(
                                title: "Your password has been updated!",
                                message: nil,
                                preferredStyle: .alert
                            )
                            let DismissAction = UIAlertAction(title: "Got it", style: .default) { _ in
                                // Perform deletion
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                           
                            alertController.addAction(DismissAction)
                            self.present(alertController, animated: true)
                            
                        }
                        
                    })
                    
                }
                
                
                
            }
            
            
           
        }
         
        
    }
    
    func checkKeyAndPerformChanges(currentInput: String, newInput: String, key: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Pwd_users").whereField("secret_key", isEqualTo: key).getDocuments { (snap, err) in
            
            if err != nil {
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
       
                let i = item.data()
                
                if let pwd = i["password"] as? String {
                    
                    if currentInput == pwd {
                        
                        
                        Auth.auth().currentUser?.updatePassword(to: newInput, completion: { errs in
                            
                            if errs != nil {
                                
                                SwiftLoader.hide()
                                self.showErrorAlert("Ops!", msg: errs!.localizedDescription)
                                return
                            }
                            
                            
                            let id = item.documentID
                            DataService.instance.mainFireStoreRef.collection("Pwd_users").document(id).updateData(["password": newInput, "isPasswordSet": true]) { (error) in
                                
                                if error != nil {
                                    
                                    SwiftLoader.hide()
                                    self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                                    return
                                    
                                }
                                                          
                                self.currentPwdLbl.text = ""
                                self.newPwdLbl.text = ""
                                self.isSet = true
                                
                                ActivityLogService.instance.UpdateAccountActivityLog(mode: "Update", info: "Password")
                                
                                
                                SwiftLoader.hide()
           
                                let alertController = UIAlertController(
                                    title: "Your password has been updated!",
                                    message: nil,
                                    preferredStyle: .alert
                                )
                                let DismissAction = UIAlertAction(title: "Got it", style: .default) { _ in
                                    // Perform deletion
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }
                               
                                alertController.addAction(DismissAction)
                                self.present(alertController, animated: true)
                                
                            }
                            
                        })
                        
                        
                    } else {
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Your current password isn't correct.")
                        return
                        
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
