//
//  PhoneChangeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit
import Alamofire
import Firebase


class PhoneChangeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    
    var Pview = PhoneView()
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    var phoneBook = [PhoneBookModel]()

    var finalPhone: String?
    var finalCode: String?
    var UserCode: String?
    var dayPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPhoneBook()
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
                        
                        
                        self.UserCode = snapshot.documentID
                    
                        if let phone = item["phone"] as? String, let code = item["code"] as? String {
                            
                            if phone != "nil", code != "nil" {
                                
                                self.setUpPhoneView(code: code, phone: phone)
                                
                            } else {
                                
                                self.setUpPhoneView(code: "Code", phone: "Phone number")
                                
                                
                            }
                            
                        } else {
                            
                            self.setUpPhoneView(code: "Code", phone: "Phone number")
                            
                        }
                        
                    }
                    
                    
                }
                
                

                
            }
            
           
        }
        
        
        
        
    }
    
    func setUpPhoneView(code: String, phone: String) {
        
        //Pview.frame = self.contentView.layer.bounds
        self.contentView.addSubview(Pview)
        
        self.Pview.translatesAutoresizingMaskIntoConstraints = false
        self.Pview.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.Pview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.Pview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.Pview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        Pview.areaCodeBtn.attributedPlaceholder = NSAttributedString(string: code,
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Pview.PhoneNumberLbl.attributedPlaceholder = NSAttributedString(string: phone,
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        // btn
        
        Pview.areaCodeBtn.addTarget(self, action: #selector(PhoneChangeVC.openPhoneBookBtnPressed), for: .editingDidBegin)
        Pview.GetCodeBtn.addTarget(self, action: #selector(PhoneChangeVC.getCodeBtnPressed), for: .touchUpInside)
        
        Pview.PhoneNumberLbl.delegate = self
        Pview.PhoneNumberLbl.keyboardType = .numberPad
        Pview.PhoneNumberLbl.becomeFirstResponder()
        
        
    }
    
    
    @objc func getCodeBtnPressed() {
        
        if let phone = Pview.PhoneNumberLbl.text, phone != "", phone.count >= 7, let code = Pview.areaCodeBtn.text, code != "" {
                
         
            checkPhoneNumber(phone: phone, countryCode: code)
            
        }
       
        
    }
    
    func checkPhoneNumber(phone: String, countryCode: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("phone", isEqualTo: phone).whereField("code", isEqualTo: countryCode).getDocuments { querySnapshot, error in
            guard querySnapshot != nil else {
                    print("Error fetching snapshots: \(error!)")
                    return
            }
            
            if querySnapshot?.isEmpty == true {
                
                self.sendPhoneVerfication(phone: phone, countryCode: countryCode)
                
            } else
            {
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: "This phone number has been used, please check or use another instead.")
                
            }
            
            
            
        }
        
        
        
    }
    
    func sendPhoneVerfication(phone: String, countryCode: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("start")
        
        
        self.view.endEditing(true)
        
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
                self.performSegue(withIdentifier: "moveToPhoneVerificationChangeVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToPhoneVerificationChangeVC"{
            if let destination = segue.destination as? PhoneVerificationChangeVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.UserCode = self.UserCode
               
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    @objc func openPhoneBookBtnPressed() {
        
        createDayPicker()
        
    }
    
    func createDayPicker() {

        Pview.areaCodeBtn.inputView = dayPicker

    }
    
    func loadPhoneBook() {
        
        DataService.instance.mainFireStoreRef.collection("Global phone book").order(by: "country", descending: false).getDocuments {  (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
        
            for item in snap!.documents {
                
            
                let i = item.data()
                
                let item  = PhoneBookModel(postKey: item.documentID, phone_model: i)
                
                self.phoneBook.append(item)
                
                
            }
            
            self.dayPicker.delegate = self
            
        }
        
        
        
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
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
extension PhoneChangeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
