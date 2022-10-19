//
//  EmailChangeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/7/20.
//

import UIKit
import Firebase
import Alamofire

class EmailChangeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddressLbl: UITextField!
    var finalEmail: String?
    var UserCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        loadProfile()
        
        emailAddressLbl.delegate = self
        emailAddressLbl.becomeFirstResponder()
        
        
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
                        
                        self.UserCode = snapshot.documentID
                    
                        if let Email = item["Email"] as? String, Email != "nil" {
                            
                            self.emailAddressLbl.attributedPlaceholder = NSAttributedString(string: Email,
                                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
                            
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        
        if let email = emailAddressLbl.text, email != "", email.contains("@") == true, email.contains(".") == true {
                
            checkEmail(email: email)
            
        } else {
            
            showErrorAlert("Oops !", msg: "Please enter your valid email.")
            
        }
        
    }
    
    func checkEmail(email: String) {
        
        let lowercaseEmail = email.lowercased().stringByRemovingWhitespaces
        
   
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("Email", isEqualTo: lowercaseEmail).getDocuments { querySnapshot, error in
            guard querySnapshot != nil else {
                    print("Error fetching snapshots: \(error!)")
                    return
            }
            
            if querySnapshot?.isEmpty == true {
                
                self.sendEmailVerfication(email: lowercaseEmail)
                
            } else
            {
                
                self.showErrorAlert("Oops !", msg: "This email has been used, please check or use another instead.")
                
            }
            
        }
        
        
        
    }
    
    func sendEmailVerfication(email: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("email")
        
        
        self.view.endEditing(true)
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "email": email,
            
        ])
        .validate(statusCode: 200..<500)
        .responseJSON { responseJSON in
            
            switch responseJSON.result {
                
            case .success( _):
                SwiftLoader.hide()
                self.finalEmail = email
               
                self.performSegue(withIdentifier: "moveToChangeEmailVeriVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops !", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToChangeEmailVeriVC"{
            if let destination = segue.destination as? EmailVerificationVC
            {
                
                destination.finalEmail = self.finalEmail
                destination.UserCode = self.UserCode
               
            }
        }
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
