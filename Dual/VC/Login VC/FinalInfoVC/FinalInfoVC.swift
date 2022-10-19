//
//  FinalInfoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire
import SendBirdCalls
import SendBirdUIKit
import SCLAlertView

class FinalInfoVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    
    var avatarUrl: String?
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
    var Create_mode: String?
    var keyId: String?
    
    var isNameValid = false
    var fView = usernamePwdView()
    var phone_verified = false
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        setupView()
        
    }
    
    func setupView() {
        
        fView.frame = CGRect(x: self.contentView.layer.bounds.minX + 16, y: self.contentView.layer.bounds.minY, width: self.contentView.layer.bounds.width - 32, height: self.contentView.layer.bounds.height)
        
        fView.usernameLbl.attributedPlaceholder = NSAttributedString(string: "Username",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        fView.pwdLbl.attributedPlaceholder = NSAttributedString(string: "Password (Optional?)",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
       
       
        
        self.fView.userNameCheck.image = nil
        fView.usernameLbl.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fView.nextBtn.addTarget(self, action: #selector(FinalInfoVC.NextBtnPressed), for: .touchUpInside)
        fView.passwordBtn.addTarget(self, action: #selector(FinalInfoVC.PasswordBtnPressed), for: .touchUpInside)
        
        self.contentView.addSubview(fView)
        
        fView.usernameLbl.delegate = self
        fView.usernameLbl.keyboardType = .default
        fView.usernameLbl.becomeFirstResponder()
        
        
        if finalCode != nil, finalPhone != nil {
            phone_verified = true
        }
        
        
    }
    
    func checkAvailableName(name: String) {
        
        
        Auth.auth().signInAnonymously { result, err in
            if err != nil {
                
                print(err!.localizedDescription)
                self.isNameValid = false
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: name).getDocuments { (snap, err) in
       
                if err != nil {
                    
                    print(err!.localizedDescription)
                    self.isNameValid = false
                    
                    return
                }
            
                if snap?.isEmpty == true {
                    
                    self.isNameValid = true
                    self.fView.userNameCheck.image = UIImage(named: "wtick")
                    
                    
                } else {
                    
                    self.isNameValid = false
                    self.fView.userNameCheck.image = UIImage(named: "no")
                   
                    
                }
                
            }
            
            
        }
        
        
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == fView.usernameLbl {
            
            fView.usernameLbl.text = fView.usernameLbl.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let username = fView.usernameLbl.text, username != "" {
                
                if username != "" {
                    
                    checkAvailableName(name: username)
                    
                } else {
                    
                    self.isNameValid = false
                    self.fView.userNameCheck.image = nil
                    
                }
                
                
                
            } else {
                
                self.isNameValid = false
                self.fView.userNameCheck.image = nil
                
            }
            
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
    
    @objc func PasswordBtnPressed() {
        
        self.view.endEditing(true)
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
            kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
            showCloseButton: true,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
      
        let alert = SCLAlertView(appearance: appearance)
        
        
     
        

        let icon = UIImage(named:"logo123")
        
        
        
        _ = alert.showCustom("Hello new users,", subTitle: "This is a signup process, we have password option for users conveniently login in the future in case he/she forgets or loses access to any of his/her phone number or social account.", color: UIColor.black, icon: icon!)
        
    }
    
    
    @objc func NextBtnPressed() {
        
        fView.nextBtn.isEnabled = false
        if let username = fView.usernameLbl.text, username != "", isNameValid == true {
            
  
            if let pwd = fView.pwdLbl.text {
                
                if pwd != "" {
                    
                    if pwd.count >= 6 {
                        
                        try? Auth.auth().signOut()
                                        
                                        showCodeDialog(subtitle: "If any of your friends refer you here, enter their referral code so both you and your friends will get reward points.",
                                                       actionTitle: "Enter",
                                                       cancelTitle: "Skip",
                                                       inputPlaceholder: "Referral code",
                                                       inputKeyboardType: .default, actionHandler:
                                                               { (input:String?) in
                                                                
                                                                
                                                                if input == "Skip Code" {
                                                                    
                                                                        self.view.endEditing(true)
                                                                        self.startRegister(refer_code: "nil", pwd: pwd, username: username)
                                                                    
                                                                } else if input != "" {
                                                                    
                                                                    if let code = input {
                                                                        
                                                                        self.view.endEditing(true)
                                                                        self.startRegister(refer_code: code, pwd: pwd, username: username)
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                } else {
                                                                    
                                                                    self.fView.nextBtn.isEnabled = true
                                                                    self.showErrorAlert("Oops!", msg: "Please input your referral code.")
                                                                    
                                                                    
                                                                }
                                            
                                        })
                        
                    } else {
                        
                        
                        fView.nextBtn.isEnabled = true
                        showErrorAlert("Oops!", msg: "There is something wrong with your provided information. Please ensure that your password is longer than 6 characters.")
                        
                        
                    }
                    
                } else {
                    
                    if pwd == "" {
                        
                        try? Auth.auth().signOut()
                                        
                                        showCodeDialog(subtitle: "If any of your friends refer you here, enter their referral code so both you and your friends will get reward points.",
                                                       actionTitle: "Enter",
                                                       cancelTitle: "Skip",
                                                       inputPlaceholder: "Referral code",
                                                       inputKeyboardType: .default, actionHandler:
                                                               { (input:String?) in
                                                                
                                                                
                                                                if input == "Skip Code" {
                                                                    
                                                                        self.view.endEditing(true)
                                                                        self.startRegister(refer_code: "nil", pwd: pwd, username: username)
                                                                    
                                                                } else if input != "" {
                                                                    
                                                                    if let code = input {
                                                                        
                                                                        self.view.endEditing(true)
                                                                        self.startRegister(refer_code: code, pwd: pwd, username: username)
                                                                        
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                } else {
                                                                    
                                                                    self.fView.nextBtn.isEnabled = true
                                                                    self.showErrorAlert("Oops!", msg: "Please input your referral code.")
                                                                    
                                                                    
                                                                }
                                            
                                        })
                        
                        
                    }
                    
                }
            
                
            
            }
                      
            
        } else {
           
            
            fView.nextBtn.isEnabled = true
            showErrorAlert("Oops!", msg: "There is something wrong with your provided information. Please ensure that your username is valid")
            
            
        }
 
        
        
    }
    
    func startRegister(refer_code: String, pwd: String, username: String) {
        
        
        var encryptedRandomEmail = ""
        
        
        let id = UUID().uuidString
        let altPwd = Hashids(salt: id).encode(1,2,3)! + Hashids(salt: id).encode(1,2,3)!
        
        swiftLoader()
        
       
        
        if avatarUrl == nil || avatarUrl == "nil" {
            avatarUrl = "https://firebasestorage.googleapis.com/v0/b/dual-71608.appspot.com/o/Avatar%2Fdefault.jpg?alt=media&token=9ee4820e-d98a-4091-9689-6844840b1e26"
        }

        encryptedRandomEmail = "\(id)@credential-dual.so"
        
        var finalPwd = ""
        
        if pwd == "" {
            
            finalPwd = altPwd
            
        } else {
            
            finalPwd = pwd
            
        }
        
        if finalPwd.count >= 6 {
            
            
            Auth.auth().createUser(withEmail: encryptedRandomEmail, password: finalPwd) { authCredential, err in
                
                if err != nil {
                    
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    self.fView.nextBtn.isEnabled = true
                    return
                    
                } else {
                    
                    let device = UIDevice().type.rawValue
                    
                    var userInfomation = ["name": self.finalName as Any, "birthday": self.finalBirthday as Any, "create_time": FieldValue.serverTimestamp(), "username": username, "avatarUrl": self.avatarUrl as Any, "Email": "nil", "account_verified": false, "userUID": Auth.auth().currentUser!.uid, "email_verified": false, "encryptedKey": id, "Create_mode": self.Create_mode as Any, "Device": device, "ChallengeStatus": true, "DiscordStatus": false, "SocialStatus": false, "is_suspend": false, "phone_verified": self.phone_verified, "referral code": Hashids(salt:Auth.auth().currentUser!.uid).encode(1,2,3)!, "ChallengeNotiStatus": true, "HighlightNotiStatus": true, "CommentNotiStatus": true, "FollowNotiStatus": true, "MessageNotiStatus": true, "CallNotiStatus": true, "MentionNotiStatus": true, "isSound": false, "isMinimize": true, "isAnimating": false, "isPending_deletion": false, "languageCode": Locale.current.languageCode!, "platform": "IOS"]
                
                    isMinimize = true
                    isSound = false
                    
                    
                    if self.finalPhone != nil, self.finalCode != nil, self.finalPhone != "nil" {
                        userInfomation.updateValue(self.finalCode! + self.finalPhone!, forKey: "phone")
                    } else {
                        userInfomation.updateValue("nil", forKey: "phone")
                    }
                    
                    if let mode = self.Create_mode, let lKey = self.keyId {
                        
                        let loginKey = lKey
                        userInfomation.updateValue(loginKey, forKey: "\(mode)_id")
                        
                    }
                    
                    
                    
                    var user_sensitive_information = ["password": finalPwd, "secret_key": id, "create_time": FieldValue.serverTimestamp()] as [String : Any]
                    
                    if pwd == "" {
                    
                        user_sensitive_information.updateValue(false, forKey: "isPasswordSet")
                    } else {
                       
                        user_sensitive_information.updateValue(true, forKey: "isPasswordSet")
                    }
         
                    print("Writing user information to database")
                      
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                            
                            userInfomation.updateValue(string, forKey: "query")
                            if refer_code != "nil" {
                                
                                self.refer_code_process(code: refer_code)
                                
                            }
                            
                            self.writeToDb(userInfomation: userInfomation, user_sensitive_information: user_sensitive_information)
                           
                           
                        }
                    }
                    
                }
               
            }
            
            
        }
        
        
        
        
        
    }
    
    
    func refer_code_process(code: String) {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").whereField("referral code", isEqualTo: code).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
            if snapshot.isEmpty != true {
                
                
                    for item in snapshot.documents {
                        
                        
                        if let userUID = item.data()["userUID"] as? String, userUID != "" {
                            
                           
                            let data = ["register_uid": Auth.auth().currentUser?.uid as Any, "refer_uid": userUID as Any, "referral code": code as Any, "timeStamp": FieldValue.serverTimestamp()]
                            
                            DataService.instance.mainFireStoreRef.collection("Referral code").addDocument(data: data)
                            
                            DataService.instance.mainFireStoreRef.collection("Referral code rewards").addDocument(data: ["uid": Auth.auth().currentUser?.uid as Any, "timeStamp": FieldValue.serverTimestamp()])
                            DataService.instance.mainFireStoreRef.collection("Referral code rewards").addDocument(data: ["uid": userUID, "timeStamp": FieldValue.serverTimestamp()])
                           
                        }
                        
                    
                    }
                
                
                
            }
            
               
        
        }
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    func writeToDb(userInfomation: [String: Any], user_sensitive_information: [String:Any]) {
        

        let db = DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid)
        
        db.setData(userInfomation) { error in
            
            if error != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                return
                
            }
            
            DataService.instance.mainFireStoreRef.collection("Pwd_users").addDocument(data: user_sensitive_information)
            SwiftLoader.hide()
            print("Finished writting")
            
            
            // request sendbird process new account with access token
            
            var profile_url = ""
            
            if userInfomation["avatarUrl"] as! String == "nil" {
                
                profile_url = ""
            } else {
                
                profile_url = userInfomation["avatarUrl"] as! String
                
            }
            
            if let username = userInfomation["username"] as? String {
                
                
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
                
                SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid, nickname: username, profileUrl: profile_url)
                
                SBUMain.connect { user, error in
                    if error != nil {
                        print(error!.localizedDescription)
                        
                    }
                    
                    if let user = user {
                    
                        print("SBUMain.connect: \(user)")
                        
                    
                        
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
                    self.performSegue(withIdentifier: "moveToTutorialVC", sender: nil)
                    
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
    
    
}

