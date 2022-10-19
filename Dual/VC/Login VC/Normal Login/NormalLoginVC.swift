//
//  NormalLoginVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import UIKit
import Firebase
import Alamofire
import SendBirdCalls
import SendBirdUIKit

class NormalLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var widthconstant: NSLayoutConstraint!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    
    var phoneBook = [PhoneBookModel]()

    var finalPhone: String?
    var finalCode: String?
    
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    var usernameBorder = CALayer()
    var phoneBtnBorder = CALayer()
    var Pview = PhoneView()
    var Uview = userNameView()
    var dayPicker = UIPickerView()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
  
        loadPhoneBook()
        
        
        //
        
        phoneBtnBorder = phoneBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (150/414))
        usernameBorder = usernameBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (150/414))
        phoneBtn.layer.addSublayer(phoneBtnBorder)
        
        
        setUpPhoneView()
        widthconstant.constant = self.view.frame.width * (150/414)
    }
    
    
    

    func setUpPhoneView() {
        
        //Pview.frame = self.ContentView.layer.bounds
        
        
        
        self.ContentView.addSubview(Pview)
        
        
        self.Pview.translatesAutoresizingMaskIntoConstraints = false
        self.Pview.topAnchor.constraint(equalTo: self.ContentView.topAnchor, constant: 0).isActive = true
        self.Pview.leadingAnchor.constraint(equalTo: self.ContentView.leadingAnchor, constant: 0).isActive = true
        self.Pview.trailingAnchor.constraint(equalTo: self.ContentView.trailingAnchor, constant: 0).isActive = true
        self.Pview.bottomAnchor.constraint(equalTo: self.ContentView.bottomAnchor, constant: 0).isActive = true
        
        Pview.areaCodeBtn.attributedPlaceholder = NSAttributedString(string: "Code",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Pview.PhoneNumberLbl.attributedPlaceholder = NSAttributedString(string: "Phone number",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        // btn
        
        Pview.areaCodeBtn.addTarget(self, action: #selector(NormalLoginVC.openPhoneBookBtnPressed), for: .editingDidBegin)
        Pview.GetCodeBtn.addTarget(self, action: #selector(NormalLoginVC.getCodeBtnPressed), for: .touchUpInside)
        
        Pview.PhoneNumberLbl.delegate = self
        Pview.PhoneNumberLbl.keyboardType = .numberPad
        Pview.PhoneNumberLbl.becomeFirstResponder()
        
        
    }
    
    @objc func getCodeBtnPressed() {
        
        if let phone = Pview.PhoneNumberLbl.text, phone != "", phone.count >= 7, let code = Pview.areaCodeBtn.text, code != "" {
                
            sendPhoneVerfication(phone: phone, countryCode: code)
            
        }
       
        
    }
    
    @objc func openPhoneBookBtnPressed() {
        
        createDayPicker()
        
    }
    
    func setUpUsernameView() {
        
        Uview.frame = CGRect(x: self.ContentView.layer.bounds.minX , y: self.ContentView.layer.bounds.minY + 15, width: self.ContentView.layer.bounds.width, height: self.ContentView.layer.bounds.height)
        
        self.ContentView.addSubview(Uview)
       
        Uview.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        Uview.passwordLbl.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        Uview.NextBtn.addTarget(self, action: #selector(NormalLoginVC.userNameBtnPressed), for: .touchUpInside)
        Uview.forgetBtn.addTarget(self, action: #selector(NormalLoginVC.forgetPwdPressed), for: .touchUpInside)
        Uview.forgetBtn.isUserInteractionEnabled = true
        
        Uview.usernameLbl.delegate = self
        Uview.usernameLbl.keyboardType = .default
        
        Uview.passwordLbl.delegate = self
        Uview.passwordLbl.keyboardType = .default
        Uview.passwordLbl.isHidden = false
        
        
        Uview.usernameLbl.becomeFirstResponder()
        
        
    }
    
    @objc func forgetPwdPressed() {
        
        self.performSegue(withIdentifier: "moveToResetPasswordVC", sender: nil)
        
    }
    
    @objc func userNameBtnPressed() {
        
        if let username = Uview.usernameLbl.text, username != "", let pwd = Uview.passwordLbl.text, pwd != "", pwd.count >= 5 {
            
            let finalUsername = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            swiftLoader()
            
            Auth.auth().signInAnonymously { result, err in
                if err != nil {
                    
                    print(err!.localizedDescription)
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    return
                }
                
                
                DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: finalUsername).getDocuments { (snap, err) in
                    
                    if err != nil {
                        SwiftLoader.hide()
                        self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                        try? Auth.auth().signOut()
                        return
                    }
                    
                    if snap?.isEmpty == true {
                        
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "It seems like your username isn't signed up yet, let's continue using phone number to create your account.")
                        try? Auth.auth().signOut()
                        return
                    }
                    
                    for item in snap!.documents {
               
                        let i = item.data()
                        
                        if let encryptedKey = i["encryptedKey"] as? String {
                            
                            
                            if let is_suspend = i["is_suspend"] as? Bool {
                                
                                if is_suspend == true {
                                 
                                 
                                    if let suspend_time = i["suspend_time"] as? Timestamp {
                                        
                                        let current_suspend_time = suspend_time.dateValue()
                                        let current_time = Date()
                                        
                                        if current_time >= current_suspend_time {
                                            
                                            if let avatarUrl = i["avatarUrl"] as? String, let username = i["username"] as? String {
                                                
                                                if let MessageNotiStatus = i["MessageNotiStatus"] as? Bool {
                                                    
                                                    self.processSignIn(updatefid: item.documentID, encryptedKey: encryptedKey, pwd: pwd, username: username, avatarUrl: avatarUrl, overwrite_suspend: true, message_noti: MessageNotiStatus)
                                                    
                                                } else {
                                                    
                                                    self.processSignIn(updatefid: item.documentID, encryptedKey: encryptedKey, pwd: pwd, username: username, avatarUrl: avatarUrl, overwrite_suspend: true, message_noti: false)
                                                    
                                                }
                                             
                                                
                                            }
                                            
                                        } else {
                                            
                                            
                                            let format = current_suspend_time.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
                                            
                                            if let suspend_reason = i["suspend_reason"] as? String, suspend_reason != "" {
                                                
                                                SwiftLoader.hide()
                                                try? Auth.auth().signOut()
                                                self.showErrorAlert("Your account is suspended", msg: "Your account is suspended because of \(suspend_reason) reason until \(format), if you have any question please contact our support at support@stitchbox.gg")
                                                
                                            } else {
                                                
                                                SwiftLoader.hide()
                                                try? Auth.auth().signOut()
                                                self.showErrorAlert("Your account is suspended", msg: "Your account is suspended until \(format), please contact our support for more information at support@stitchbox.gg.")
                                                
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    } else {
                                        
                                        if let suspend_reason = i["suspend_reason"] as? String, suspend_reason != "" {
                                            
                                            
                                            SwiftLoader.hide()
                                            try? Auth.auth().signOut()
                                            self.showErrorAlert("Your account is suspended", msg: "Your account is suspended because of \(suspend_reason) reason with unknown time, if you have any question please contact our support at support@stitchbox.gg")
                                            
                                        } else {
                                            
                                            SwiftLoader.hide()
                                            try? Auth.auth().signOut()
                                            self.showErrorAlert("Your account is suspended", msg: "Your account is suspended with unknown time, please contact our support for more information at support@stitchbox.gg.")
                                            
                                            
                                        }
                                        
                                    }
                                
                                } else {
                                    
                                    if let avatarUrl = i["avatarUrl"] as? String, let username = i["username"] as? String {
                                        
                                        
                                        if let MessageNotiStatus = i["MessageNotiStatus"] as? Bool {
                                            
                                            self.processSignIn(updatefid: item.documentID, encryptedKey: encryptedKey, pwd: pwd, username: username, avatarUrl: avatarUrl, overwrite_suspend: true, message_noti: MessageNotiStatus)
                                            
                                        } else {
                                            
                                            self.processSignIn(updatefid: item.documentID, encryptedKey: encryptedKey, pwd: pwd, username: username, avatarUrl: avatarUrl, overwrite_suspend: true, message_noti: false)
                                            
                                        }
               
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
            
            
        } else {
            self.showErrorAlert("Oops!", msg: "Please input your valid username and password.")
        }
        
    }
    
    
    func processSignIn(updatefid: String,encryptedKey: String, pwd: String, username: String, avatarUrl: String, overwrite_suspend: Bool, message_noti: Bool) {
        
        
        let encryptedRandomEmail = "\(encryptedKey)@credential-dual.so"
        try? Auth.auth().signOut()
        Auth.auth().signIn(withEmail: encryptedRandomEmail, password: pwd) { (result, error) in
            
            if error != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Opss !", msg: error!.localizedDescription)
                
                return
                
            }
            
            if overwrite_suspend == true {
                DataService.instance.mainFireStoreRef.collection("Users").document(updatefid).updateData(["is_suspend": false, "suspend_reason": FieldValue.delete(), "suspend_time": FieldValue.delete()])
                recoverAllPost(userUID: Auth.auth().currentUser!.uid)
                recoverAllFollower(userUID: Auth.auth().currentUser!.uid)
                recoverAllFollowing(userUID: Auth.auth().currentUser!.uid)
            }
            
            SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid, nickname: username, profileUrl: avatarUrl)
            
            
            SBUMain.connect { user, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                if let user = user {
                
                    print("SBUMain.connect: \(user)")
                    
                    if message_noti == true {
                        
                        SBDMain.setPushTriggerOption(.all) { err in
                            if err != nil {
                                
                                showNote(text: err!.localizedDescription)
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
            // verify call id
            
            let params = AuthenticateParams(userId: Auth.auth().currentUser!.uid)
            
            SendBirdCall.authenticate(with: params) { (user, err) in
                
                guard user != nil else {
                    // Failed
                    
                    return
                }
                
                Messaging.messaging().token { token, error in
                  if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                  } else if let token = token {
                    print("FCM registration token: \(token)")
                      
                      checkregistrationTokenAndPerformUpload(token: token)
                      checkAndRegisterForFCMDict(token: token)
                      loadInActiveFCMToken()
          
                    }
                }
                
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                
                appDelegate?.listenToApiKeyUpdates()
                appDelegate?.voipRegistration()
                appDelegate?.addDirectCallSounds()
                
            }
            
            SBDMain.setChannelInvitationPreferenceAutoAccept(false, completionHandler: { (error) in
                guard error == nil else {
                    // Handle error.
                    showNote(text: error!.localizedDescription)
                    return
                }

               
            })
            
            if let pushToken: Data = SBDMain.getPendingPushToken() {
                SBDMain.registerDevicePushToken(pushToken, unique: false, completionHandler: { (status, error) in
                    guard let _: SBDError = error else {
                        print("APNS registration failed.")
                        return
                    }
                    
                    if status == .pending {
                        print("Push registration is pending.")
                    }
                    else {
                        print("APNS Token is registered.")
                    }
                })
            }

            
            ActivityLogService.instance.UpdateAccountActivityLog(mode: "Login", info: "nil")
            
            
            self.getToken()
            SwiftLoader.hide()
            self.performSegue(withIdentifier: "moveToMainVC5", sender: nil)
            
        }
        
    }
   
    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        
        
        Uview.removeFromSuperview()
        setUpPhoneView()
        
        usernameBorder.removeFromSuperlayer()
        phoneBtn.layer.addSublayer(phoneBtnBorder)
        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
    }
    
    
    @IBAction func usernameBtnPressed(_ sender: Any) {
        
        
        Pview.removeFromSuperview()
        setUpUsernameView()

        phoneBtnBorder.removeFromSuperlayer()
        usernameBtn.layer.addSublayer(usernameBorder)
        phoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        usernameBtn.setTitleColor(UIColor.white, for: .normal)
        
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
    
    func loadPhoneBook() {
        
        DataService.instance.mainFireStoreRef.collection("Global phone book").whereField("status", isEqualTo: true).order(by: "country", descending: false).getDocuments {  (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
        
            for item in snap!.documents {
                
            
                let i = item.data()
                
                let items  = PhoneBookModel(postKey: item.documentID, phone_model: i)
                self.phoneBook.append(items)
                
                
            }
            
            self.dayPicker.delegate = self
            
        }
        
        
        
    }
    
    
    
    func createDayPicker() {

        Pview.areaCodeBtn.inputView = dayPicker

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
                self.performSegue(withIdentifier: "moveToPhoneVeriVC", sender: nil)
                
            case .failure(let error):
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                
            }
            
        }
    }
    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToPhoneVeriVC"{
            if let destination = segue.destination as? PhoneVerficationVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
               
            }
        } else if segue.identifier == "moveToResetPasswordVC" {
            
            if let destination = segue.destination as? resetPasswordVC {
                
                destination.phoneBook = self.phoneBook
                
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

extension NormalLoginVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    
    func getToken() {
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            self.addToken(token: token)
            
          }
        }
        
    }
    
    func addToken(token: String) {
        
        
        if let userUID = Auth.auth().currentUser?.uid, Auth.auth().currentUser?.isAnonymous != true {
            
            DataService.instance.mainFireStoreRef.collection("Users").document(userUID).getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let fcm_tokenList = item["FCM_Token_List"] as? [String] {
                            
                            if !fcm_tokenList.contains(token) {
                                
                                var new_fcm_tokenList = fcm_tokenList
                                new_fcm_tokenList.append(token)
                                
                                DataService.instance.mainFireStoreRef.collection("Users").document(snapshot.documentID).updateData(["FCM_Token_List": new_fcm_tokenList]) { (err) in
                                    if err != nil {
                                        print(err!.localizedDescription)
                                        return
                                    }
                                    
                                    print("Update fcm token to server with userUID: \(userUID)  token: \(token)")
                                }
                                
                                
                            } else {
                                
                                
                                print("Token is already registered to user: \(userUID)")
                                
                            }
                            
                            
                        } else {
                            
                            let FCM_Token_List = [token]
                            DataService.instance.mainFireStoreRef.collection("Users").document(snapshot.documentID).updateData(["FCM_Token_List": FCM_Token_List]) { (err) in
                                if err != nil {
                                    print(err!.localizedDescription)
                                    return
                                }
                                
                                print("First push fcm token to server with userUID: \(userUID)  token: \(token)")
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
             
            }
            
          
        }
        
        
    }
    
    
    
    
}

