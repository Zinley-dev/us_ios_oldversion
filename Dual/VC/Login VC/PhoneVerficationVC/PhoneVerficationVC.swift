//
//  PhoneVerficationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//

import UIKit
import Alamofire
import Firebase
import SendBirdCalls
import SendBirdUIKit

class PhoneVerficationVC: UIViewController, UITextFieldDelegate {
    
    var finalPhone: String?
    var finalCode: String?
    
    var border1 = CALayer()
    var border2 = CALayer()
    var border3 = CALayer()
    var border4 = CALayer()
    var border5 = CALayer()
    var border6 = CALayer()
    
    
    @IBOutlet weak var HidenTxtView: UITextField!
    
    
    var selectedColor = UIColor.orange
    var emptyColor = UIColor.white
    
    @IBOutlet weak var contentView: UIView!
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
        
       // vView.frame = self.contentView.layer.bounds
        
        
        
        
        
        
       // vView.center = CGPoint(x: self.contentView.layer.bounds.width  / 2,y: self.contentView.layer.bounds.height / 2)
        
        
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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {  action in
            
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
            
            if let code = HidenTxtView.text, code.count == 6, finalPhone != nil, finalCode != nil {
                
                verifyPhone(phone: finalPhone!, countryCode: finalCode!, code: code)
                
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
                
                self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
                
                
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
        
        if finalPhone != nil, finalCode != nil {
            
            sendPhoneVerfication(phone: finalPhone!, countryCode: finalCode!)
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
           

        }
        
        
    }
    
    
    @objc func verifyBtnPressed() {
        
        if let code = HidenTxtView.text, code.count == 6, finalPhone != nil, finalCode != nil {
            
            verifyPhone(phone: finalPhone!, countryCode: finalCode!, code: code)
        
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
                
                //SwiftLoader.hide()
                
                if let dict = json as? [String: AnyObject] {
                    
                    if let valid = dict["valid"] as? Bool {
                        
                        if valid == true {
                            
                            print("processSignIn")
                            self.processSignIn(phone: phone, code: countryCode)
                            
                        } else {
                            
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToDetailInfoVC"{
            if let destination = segue.destination as? DetailInfoVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
               
            }
        }
        
    }
    
    func processSignIn(phone: String, code: String) {
        
        //swiftLoader()
        
        Auth.auth().signInAnonymously { result, err in
            if err != nil {
                
                print(err!.localizedDescription)
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                SwiftLoader.hide()
                return
            }
            
            let phones = code + phone
            
            DataService.instance.mainFireStoreRef.collection("Users").whereField("phone", isEqualTo: phones).getDocuments { (snap, err) in
                
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Opss !", msg: err!.localizedDescription)
                    try? Auth.auth().signOut()
                    return
                }
                
                if snap?.isEmpty == true {
                    
                    SwiftLoader.hide()
                    try? Auth.auth().signOut()
                    self.performSegue(withIdentifier: "moveToDetailInfoVC", sender: nil)
                    
                    
                } else {
                    
                    for item in snap!.documents {
               
                        let i = item.data()
                        
                        if let encryptedKey = i["encryptedKey"] as? String, let avatarUrl = i["avatarUrl"] as? String, let username = i["username"] as? String {
                            
                            if let is_suspend = i["is_suspend"] as? Bool {
                                
                                if is_suspend == true {
                                 
                                 
                                    if let suspend_time = i["suspend_time"] as? Timestamp {
                                        
                                        let current_suspend_time = suspend_time.dateValue()
                                        let current_time = Date()
                                        
                                        if current_time >= current_suspend_time {
                                            
                                            if let avatarUrl = i["avatarUrl"] as? String, let username = i["username"] as? String {
                                                
                                                
                                                if let MessageNotiStatus = i["MessageNotiStatus"] as? Bool {
                                                    
                                                    self.processFinalSignIn(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, username: username, overwrite_suspend: true, message_noti: MessageNotiStatus)
                                                    
                                                } else {
                                                    
                                                    self.processFinalSignIn(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, username: username, overwrite_suspend: true, message_noti: false)
                                                    
                                                    
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
                                    
                                    
                                    if let MessageNotiStatus = i["MessageNotiStatus"] as? Bool {
                                        
                                        self.processFinalSignIn(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, username: username, overwrite_suspend: true, message_noti: MessageNotiStatus)
                                        
                                    } else {
                                        
                                        self.processFinalSignIn(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, username: username, overwrite_suspend: true, message_noti: false)
                                        
                                        
                                    }
                                    
                                  
                                    
                                    
                                }
                                
                            }
                            
                            
                           
                                                   
                            
                        }
                        
                    }
                               
                }
                
         
                
            }
            
            
            
        }
        
        
        
    }
    
    
    
    
    func processFinalSignIn(updatefid: String, key: String, avatarUrl: String, username: String, overwrite_suspend: Bool, message_noti: Bool) {
        
        
        
        DataService.instance.mainFireStoreRef.collection("Pwd_users").whereField("secret_key", isEqualTo: key).getDocuments { (snap, err) in
            
            if err != nil {
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
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
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                            return
                            
                        }
                        
                        if overwrite_suspend == true {
                            DataService.instance.mainFireStoreRef.collection("Users").document(updatefid).updateData(["is_suspend": false, "suspend_reason": FieldValue.delete(), "suspend_time": FieldValue.delete()])
                            recoverAllPost(userUID: Auth.auth().currentUser!.uid)
                            recoverAllFollower(userUID: Auth.auth().currentUser!.uid)
                            recoverAllFollowing(userUID: Auth.auth().currentUser!.uid)
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
                        appDelegate?.loadProfileAndSendBird()
                        appDelegate?.trackProfile()
                        
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
                                
                                
                                
                                let params = AuthenticateParams(userId: Auth.auth().currentUser!.uid)
                                
                                SendBirdCall.authenticate(with: params) { (cuser, err) in
                                    
                                    guard cuser != nil else {
                                        // Failed
                                        showNote(text: err!.localizedDescription)
                                        return
                                    }
                                                   
                                    
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
                                
                            }
                            
                            
                            //
                            ActivityLogService.instance.UpdateAccountActivityLog(mode: "Login", info: "nil")
                            
                            
                            self.getToken()
                  
                            SwiftLoader.hide()
                            self.performSegue(withIdentifier: "moveToMainVC4", sender: nil)
                            
                        }
                        
         
                        
                    }
                    
                    
                }
                
            }
            

            
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

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

