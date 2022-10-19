//
//  resetPasswordVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit
import Firebase
import Alamofire
import SendBirdCalls
import SendBirdUIKit

class resetPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var widthconstant: NSLayoutConstraint!
    
    var finalPhone: String?
    var finalCode: String?
    var finalEmail: String?
    var veriType: String?
    var finalusername: String?
    //

    @IBOutlet weak var EmailBtn: UIButton!
    @IBOutlet weak var PhoneBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    var phoneBook = [PhoneBookModel]()
    
    //
    
    var emailBorder = CALayer()
    var phoneBtnBorder = CALayer()
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    //
    
    var Eview = forgetWithEmailView()
    var Pview = forgetWithPhoneView()
    var dayPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        PhoneBtn.setTitleColor(UIColor.white, for: .normal)
        EmailBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
  
        //
        
        phoneBtnBorder = PhoneBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (150/414))
        emailBorder = EmailBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (150/414))
        PhoneBtn.layer.addSublayer(phoneBtnBorder)
        
        setUpPhoneView()
        self.dayPicker.delegate = self
        
        widthconstant.constant = self.view.frame.width * (150/414)
       
    }

    
    func setUpPhoneView() {
        
       // Pview.frame = self.contentView.layer.bounds
        self.contentView.addSubview(Pview)
        
    
        self.Pview.translatesAutoresizingMaskIntoConstraints = false
        self.Pview.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.Pview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.Pview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.Pview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        Pview.areaCodeBtn.attributedPlaceholder = NSAttributedString(string: "Code",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Pview.PhoneNumberLbl.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Pview.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        // btn
        
        Pview.areaCodeBtn.addTarget(self, action: #selector(resetPasswordVC.openPhoneBookBtnPressed), for: .editingDidBegin)
        Pview.GetCodeBtn.addTarget(self, action: #selector(resetPasswordVC.getCodePhoneBtnPressed), for: .touchUpInside)
        
        Pview.PhoneNumberLbl.delegate = self
        Pview.PhoneNumberLbl.keyboardType = .numberPad
        Pview.usernameLbl.becomeFirstResponder()
        
        
    }
    
    func setUpEmailView() {
        
        Eview.frame = self.contentView.layer.bounds
        self.contentView.addSubview(Eview)
        
        
        Eview.emailLbl.attributedPlaceholder = NSAttributedString(string: "Email",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Eview.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        // btn
        
        
        Eview.GetCodeBtn.addTarget(self, action: #selector(resetPasswordVC.getCodeEmailBtnPressed), for: .touchUpInside)
        
        Eview.usernameLbl.delegate = self
        Eview.usernameLbl.keyboardType = .default
        Eview.usernameLbl.becomeFirstResponder()
        
        //
        
        Eview.emailLbl.delegate = self
        Eview.emailLbl.keyboardType = .default
       
        
        
    }
    
    
    @objc func getCodeEmailBtnPressed() {
        
        if let email = Eview.emailLbl.text, email != "", let username = Eview.usernameLbl.text, username != "" {
            
            
            Auth.auth().signInAnonymously { result, err in
                if err != nil {
                    
                    print(err!.localizedDescription)
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    return
                }
                
                DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: username).whereField("Email", isEqualTo: email.lowercased().stringByRemovingWhitespaces).getDocuments { (snap, err) in
                    
                    if err != nil {
                        
                        SwiftLoader.hide()
                        try? Auth.auth().signOut()
                        self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                        return
                    }
                    
                    if snap?.isEmpty == true {
                        
                        SwiftLoader.hide()
                        try? Auth.auth().signOut()
                        self.showErrorAlert("Opss !", msg: "The username and email don't match.")
                        
                    } else {
                        
                        self.finalusername = username
                        self.sendEmailVerfication(email: email.lowercased().stringByRemovingWhitespaces)
                                   
                    }
                    
             
                    
                }
                
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
                self.veriType = "email"
                try? Auth.auth().signOut()
                self.performSegue(withIdentifier: "moveToVeriVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                try? Auth.auth().signOut()
                self.showErrorAlert("Oops !", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    
    @objc func getCodePhoneBtnPressed() {
        
        if let phone = Pview.PhoneNumberLbl.text, phone != "", phone.count >= 7, let code = Pview.areaCodeBtn.text, code != "", let username = Pview.usernameLbl.text, username != "" {
            
            
            Auth.auth().signInAnonymously { result, err in
                if err != nil {
                    
                    print(err!.localizedDescription)
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    return
                }
                
                DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: username).whereField("phone", isEqualTo: code + phone).getDocuments { (snap, err) in
                    
                    if err != nil {
                        
                        SwiftLoader.hide()
                        try? Auth.auth().signOut()
                        self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                        return
                    }
                    
                    if snap?.isEmpty == true {
                        
                        SwiftLoader.hide()
                        try? Auth.auth().signOut()
                        self.showErrorAlert("Opss !", msg: "The username and phone number don't match.")
                        
                    } else {
                        
                        
                        self.finalusername = username
                        self.sendPhoneVerfication(phone: phone, countryCode: code)
                                   
                    }
                    
             
                    
                }
                
            }
                
            
            
        }
        
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
                self.finalPhone = phone
                self.finalCode = countryCode
                self.veriType = "phone"
                
                try? Auth.auth().signOut()
                self.performSegue(withIdentifier: "moveToVeriVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                try? Auth.auth().signOut()
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                
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
    
    @objc func openPhoneBookBtnPressed() {
        
        createDayPicker()
        
    }
    
    func createDayPicker() {

        Pview.areaCodeBtn.inputView = dayPicker

    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //
    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        
        Eview.removeFromSuperview()
        setUpPhoneView()
        
        emailBorder.removeFromSuperlayer()
        PhoneBtn.layer.addSublayer(phoneBtnBorder)
        PhoneBtn.setTitleColor(UIColor.white, for: .normal)
        EmailBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    @IBAction func emailBtnPressed(_ sender: Any) {
        
        Pview.removeFromSuperview()
        setUpEmailView()

        phoneBtnBorder.removeFromSuperlayer()
        EmailBtn.layer.addSublayer(emailBorder)
        PhoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        EmailBtn.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVeriVC"{
            if let destination = segue.destination as? verificationVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.finalEmail = self.finalEmail
                destination.type = self.veriType
                destination.finalusername = self.finalusername
               
            }
        }
        
    }
    
}

extension resetPasswordVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return phoneBook.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if let code = phoneBook[row].code, let country = phoneBook[row].country {
            pickerLabel?.text = "\(country)            +\(code)"
        } else {
            pickerLabel?.text = "Error loading"
        }
     
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        
        if let code = phoneBook[row].code {
            
            Pview.areaCodeBtn.text = "+\(code)"
            
        }
    
        
    }
    
    
    
    
}
