//
//  GeneralInfomationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit
import Firebase
import SendBirdUIKit
import SendBirdSDK

class GeneralInfomationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var birthdayLbl: UITextField!
   
    
    var datePicker = UIDatePicker()
    var updateID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         
        loadProfile()
    
    }

    func loadProfile() {
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        
                        self.updateID = snapshot.documentID
                    
                        
                        
                        if let birthday = item["birthday"] as? String, birthday != "nil" {
                            
                            self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: birthday,
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                            
                        } else {
                            
                            
                            self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: "Birthday (not set)",
                                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
                        }
                        
                        
                        if let name = item["name"] as? String {
                                                    
                                                    self.nameLbl.attributedPlaceholder = NSAttributedString(string: name,
                                                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                                                    
                                                
                                                    
                                        }
                        
                        
                    }
                    
                    
                }
                
               
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
    
    @IBAction func BirthdayBtnPressed(_ sender: Any) {
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -8, to: Date())
        birthdayLbl.inputView = datePicker
        datePicker.addTarget(self, action: #selector(DetailInfoVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayLbl.text = dateFormatter.string(from: sender.date)

    }
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        if nameLbl.text != "" || birthdayLbl.text != "" {
            
            print("Updating")
            
            var updateData = [String: Any]()
                 
            if nameLbl.text != "" {
                
                updateData.updateValue(nameLbl.text as Any, forKey: "name")
                self.nameLbl.attributedPlaceholder = NSAttributedString(string: nameLbl.text!,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                
            }
            
            
            if birthdayLbl.text != "" {
                
                updateData.updateValue(birthdayLbl.text as Any, forKey: "birthday")
                self.birthdayLbl.attributedPlaceholder = NSAttributedString(string: birthdayLbl.text!,
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                
            }
            
            let db = DataService.instance.mainFireStoreRef.collection("Users")
            db.document(self.updateID).updateData(updateData) { (err) in
                
                if err != nil {
                    
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    return
                }
                
                
                self.nameLbl.text = ""
               
                self.birthdayLbl.text = ""
                
                
                self.view.endEditing(true)
                
                
                ActivityLogService.instance.UpdateAccountActivityLog(mode: "Update", info: "General information")
                let alertController = UIAlertController(title: "Your information has been saved!", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't find any change.")
            
            
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
