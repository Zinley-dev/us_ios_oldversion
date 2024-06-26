//
//  verificationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit
import Alamofire
import Firebase
import SendBirdCalls
import SendBirdUIKit

class verificationVC: UIViewController, UITextFieldDelegate {
    
    
    var finalPhone: String?
    var finalCode: String?
    var finalEmail: String?
    var finalusername: String?
    var type: String?
    
    var border1 = CALayer()
    var border2 = CALayer()
    var border3 = CALayer()
    var border4 = CALayer()
    var border5 = CALayer()
    var border6 = CALayer()

    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var HidenTxtView: UITextField!
    
    
    var selectedColor = UIColor.orange
    var emptyColor = UIColor.white
    var vView = verificationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        border1 = vView.label1.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        border2 = vView.label2.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        border3 = vView.label3.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        border4 = vView.label4.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        border5 = vView.label5.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        border6 = vView.label6.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.frame.width * (45/414))
        
        HidenTxtView.delegate = self
        HidenTxtView.keyboardType = .numberPad
        HidenTxtView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        HidenTxtView.becomeFirstResponder()
        
        
        setupView()
        
    }
    
    
    func setupView() {
        
        //vView.frame = self.contentView.layer.bounds
        //vView.center = CGPoint(x: self.contentView.layer.bounds.width  / 2,
                                         //y: self.contentView.layer.bounds.height / 2)
        
        
        self.contentView.addSubview(vView)
        
        
        self.vView.translatesAutoresizingMaskIntoConstraints = false
        self.vView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.vView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.vView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.vView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        vView.label1.layer.addSublayer(border1)
        vView.label2.layer.addSublayer(border2)
        vView.label3.layer.addSublayer(border3)
        vView.label4.layer.addSublayer(border4)
        vView.label5.layer.addSublayer(border5)
        vView.label6.layer.addSublayer(border6)
        
        //
        
        vView.verifyBtn.addTarget(self, action: #selector(PhoneVerficationVC.verifyBtnPressed), for: .touchUpInside)
        vView.resendCodeBtn.addTarget(self, action: #selector(PhoneVerficationVC.resendCodeBtnPressed), for: .touchUpInside)
        vView.openKeyBoardBtn.addTarget(self, action: #selector(PhoneVerficationVC.openKeyBoardBtnPressed), for: .touchUpInside)
        
        
  
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            self.HidenTxtView.becomeFirstResponder()
            
        }))
        
        
        
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
    
    func getTextInPosition(text: String, position: Int) -> String  {
        
        let arr = Array(text)
        var count = 0
        
        for i in arr {
            
            if count == position {
                return String(i)
            } else {
                
                count += 1
            }
            
        }
        
        return "Fail"
        
    }
    
    

    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if HidenTxtView.text?.count == 1 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            vView.label1.text = getTextInPosition(text: HidenTxtView.text!, position: 0)
            vView.label2.text = ""
            vView.label3.text = ""
            vView.label4.text = ""
            vView.label5.text = ""
            vView.label6.text = ""
            
        } else if HidenTxtView.text?.count == 2 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            vView.label2.text = getTextInPosition(text: HidenTxtView.text!, position: 1)
            vView.label3.text = ""
            vView.label4.text = ""
            vView.label5.text = ""
            vView.label6.text = ""
            
        } else if HidenTxtView.text?.count == 3 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            vView.label3.text = getTextInPosition(text: HidenTxtView.text!, position: 2)
            vView.label4.text = ""
            vView.label5.text = ""
            vView.label6.text = ""
            
        } else if HidenTxtView.text?.count == 4 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            
            vView.label4.text = getTextInPosition(text: HidenTxtView.text!, position: 3)
            vView.label5.text = ""
            vView.label6.text = ""
            
            
        } else if HidenTxtView.text?.count == 5 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            vView.label5.text = getTextInPosition(text: HidenTxtView.text!, position: 4)
            vView.label6.text = ""
            
        } else if HidenTxtView.text?.count == 6 {
            
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = selectedColor.cgColor
            
           
            vView.label6.text = getTextInPosition(text: HidenTxtView.text!, position: 5)
            
            if let code = HidenTxtView.text, code.count == 6 {
                
                verifyBtnPressed()
                
            } else {
                
                border1.backgroundColor = emptyColor.cgColor
                border2.backgroundColor = emptyColor.cgColor
                border3.backgroundColor = emptyColor.cgColor
                border4.backgroundColor = emptyColor.cgColor
                border5.backgroundColor = emptyColor.cgColor
                border6.backgroundColor = emptyColor.cgColor
                
                vView.label1.text = ""
                vView.label2.text = ""
                vView.label3.text = ""
                vView.label4.text = ""
                vView.label5.text = ""
                vView.label6.text = ""
                
                HidenTxtView.text = ""
                
                self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your input again.")
                
                
            }
            
            
        } else if HidenTxtView.text?.count == 0 {
            
            
            border1.backgroundColor = emptyColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            vView.label1.text = ""
            vView.label2.text = ""
            vView.label3.text = ""
            vView.label4.text = ""
            vView.label5.text = ""
            vView.label6.text = ""
            
        }
        
    }
    
    @objc func openKeyBoardBtnPressed() {
        
        self.HidenTxtView.becomeFirstResponder()
        
    }
    
    @objc func resendCodeBtnPressed() {
        
        
        if type != nil {
            
            if type == "phone" {
                
                if finalPhone != nil, finalCode != nil {
                    
                    sendPhoneVerfication(phone: finalPhone!, countryCode: finalCode!)
                    
                } else {
                    
                    self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
                   

                }
                
            } else if type  == "email" {
                
                if finalEmail != nil {
                    
                    sendEmailVerfication(email: finalEmail!)
                    
                } else {
                    
                    self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your email again.")
                   

                }
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your input again.")
                
            }
            
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your input again.")
            
        }
        
    }
    
    
    @objc func verifyBtnPressed() {
        
        if let code = HidenTxtView.text, code.count == 6 {
            
            
            if type != nil {
                
                if type == "phone", self.finalCode != nil, self.finalPhone != nil {
                    
                    verifyPhone(phone: finalPhone!, countryCode: finalCode!, code: code)
                    
                } else if type == "email", self.finalEmail != nil {
                    
                    
                    verifyEmail(email: finalEmail!, code: code)
                    
                } else {
                    
                    self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your input again.")
                    
                    
                }
                
            }
        
        } else {
            
           self.showErrorAlert("Oops!", msg: "Please enter a valid code.")
           
        }
     
    }
    
    func verifyPhone(phone: String, countryCode: String, code: String) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("check")
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "phone": phone,
            "countryCode": countryCode,
            "code": code
            
            
        ])
        .validate(statusCode: 200..<500)
        .responseJSON {  responseJSON in
            
            switch responseJSON.result {
                
            case .success(let json):
                
                SwiftLoader.hide()
                
                if let dict = json as? [String: AnyObject] {
                    
                    if let valid = dict["valid"] as? Bool {
                        
                        if valid == true {
                            
                            self.performSegue(withIdentifier: "moveToPwdChangeVC", sender: nil)
                            
                        } else {
                            
                            self.border1.backgroundColor = self.emptyColor.cgColor
                            self.border2.backgroundColor = self.emptyColor.cgColor
                            self.border3.backgroundColor = self.emptyColor.cgColor
                            self.border4.backgroundColor = self.emptyColor.cgColor
                            self.border5.backgroundColor = self.emptyColor.cgColor
                            self.border6.backgroundColor = self.emptyColor.cgColor
                            
                            self.vView.label1.text = ""
                            self.vView.label2.text = ""
                            self.vView.label3.text = ""
                            self.vView.label4.text = ""
                            self.vView.label5.text = ""
                            self.vView.label6.text = ""
                            
                            self.HidenTxtView.text = ""
                            
                            self.showErrorAlert("Oops!", msg:  "Invalid code, please try again")
                            
                        }
                        
                    } else {
                        
                        print("Can't extract dict")
                        
                    }
                    
                }
                
            case .failure(let err):
                
                SwiftLoader.hide()
                
                self.border1.backgroundColor = self.emptyColor.cgColor
                self.border2.backgroundColor = self.emptyColor.cgColor
                self.border3.backgroundColor = self.emptyColor.cgColor
                self.border4.backgroundColor = self.emptyColor.cgColor
                self.border5.backgroundColor = self.emptyColor.cgColor
                self.border6.backgroundColor = self.emptyColor.cgColor
                
                self.vView.label1.text = ""
                self.vView.label2.text = ""
                self.vView.label3.text = ""
                self.vView.label4.text = ""
                self.vView.label5.text = ""
                self.vView.label6.text = ""
                
                self.HidenTxtView.text = ""
                
                self.showErrorAlert("Oops!", msg:  err.localizedDescription)
             
                
            }
            
        }
        
        
    }
    
    func sendPhoneVerfication(phone: String, countryCode: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("start")
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "phone": phone,
            "countryCode": countryCode,
            "via": "sms"
            
        ])
        .validate(statusCode: 200..<500)
        .responseJSON { responseJSON in
            
            switch responseJSON.result {
                
            case .success( _):
                SwiftLoader.hide()
                
                let alertController = UIAlertController(title: "A new code has been sent to \(countryCode)\(phone)", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Got it", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    func sendEmailVerfication(email: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("email")
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "email": email,
            
        ])
        .validate(statusCode: 200..<500)
        .responseJSON { responseJSON in
            
            switch responseJSON.result {
                
            case .success( _):
                SwiftLoader.hide()
                
                let alertController = UIAlertController(title: "A new code has been sent to \(email)", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Got it", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    
    
    func verifyEmail(email: String, code: String) {
        
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("email-check")
        
        
        self.view.endEditing(true)
        
        swiftLoader()
        
        AF.request(urls!, method: .post, parameters: [
            
            "email": email,
            "code": code

        ])
        .validate(statusCode: 200..<500)
        .responseJSON {  responseJSON in
            
            switch responseJSON.result {
                
            case .success(let json):
                
                SwiftLoader.hide()
                
                if let dict = json as? [String: AnyObject] {
                    
                    if let valid = dict["valid"] as? Bool {
                        
                        if valid == true {
                            
                            self.performSegue(withIdentifier: "moveToPwdChangeVC", sender: nil)
                            
                        } else {
                            
                            self.border1.backgroundColor = self.emptyColor.cgColor
                            self.border2.backgroundColor = self.emptyColor.cgColor
                            self.border3.backgroundColor = self.emptyColor.cgColor
                            self.border4.backgroundColor = self.emptyColor.cgColor
                            self.border5.backgroundColor = self.emptyColor.cgColor
                            self.border6.backgroundColor = self.emptyColor.cgColor
                            
                            self.vView.label1.text = ""
                            self.vView.label2.text = ""
                            self.vView.label3.text = ""
                            self.vView.label4.text = ""
                            self.vView.label5.text = ""
                            self.vView.label6.text = ""
                            
                            self.HidenTxtView.text = ""
                            
                            SwiftLoader.hide()
                            
                            self.showErrorAlert("Oops!", msg:  "Invalid code, please try again")
                            
                        }
                        
                    } else {
                        
                        SwiftLoader.hide()
                        print("Can't extract dict")
                        
                    }
                    
                }
                
            case .failure(let err):
                
                SwiftLoader.hide()
                
                self.border1.backgroundColor = self.emptyColor.cgColor
                self.border2.backgroundColor = self.emptyColor.cgColor
                self.border3.backgroundColor = self.emptyColor.cgColor
                self.border4.backgroundColor = self.emptyColor.cgColor
                self.border5.backgroundColor = self.emptyColor.cgColor
                self.border6.backgroundColor = self.emptyColor.cgColor
                
                self.vView.label1.text = ""
                self.vView.label2.text = ""
                self.vView.label3.text = ""
                self.vView.label4.text = ""
                self.vView.label5.text = ""
                self.vView.label6.text = ""
                
                self.HidenTxtView.text = ""
                
                self.showErrorAlert("Oops!", msg:  err.localizedDescription)
             
                
            }
            
        }
        
        
    }
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToPwdChangeVC"{
            if let destination = segue.destination as? PwdChangeVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.finalEmail = self.finalEmail
                destination.type = self.type
                destination.finalusername = self.finalusername
               
            }
        }
        
    }
    

}
