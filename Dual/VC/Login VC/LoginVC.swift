//
//  LoginVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices
import FBSDKLoginKit
import FBSDKCoreKit
import AlamofireImage
import Alamofire
import FirebaseStorage
import Firebase
import GoogleSignIn
//import TwitterKit
import SendBirdCalls
import SendBirdUIKit
import Swifter
import AuthenticationServices


@available(iOS 13.0, *)
class LoginVC: UIViewController, ZSWTappableLabelTapDelegate, LoginButtonDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    
    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
    var Create_mode: String?
    var keyId: String?
    var avatarUrl: String?
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    var fbButton = FBLoginButton()
    
    enum LinkType: String {
        case Privacy = "Privacy"
        case TermsOfUse = "TOU"
       
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "https://dual.live/privacy-policy/")!
            case .TermsOfUse:
                return Foundation.URL(string: "https://dual.live/terms-of-service/")!
           
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        termOfUseLbl.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                LoginVC.URLAttributeName: type.URL
            ]
        })
       
        let string = NSLocalizedString("By using any of these login options above, you agree to our <link type='TOU'>Terms of use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
        
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
        setupFBBtn()

        
    }
    
    
    
    
    func setupFBBtn() {
         
        fbButton.center = facebookBtn.center
        fbButton.delegate = self
        fbButton.isHidden = true
        fbButton.permissions = ["public_profile"]
        facebookBtn.addSubview(fbButton)
        
    }
    
    
    //
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[LoginVC.URLAttributeName] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // handle login
    
    @IBAction func PhoneUsernameBtnPressed(_ sender: Any) {
        
        DataService.instance.mainFireStoreRef.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty != true {
                self.showErrorAlert("Oops!", msg: "We're down for scheduled maintenance right now!")
                return
             
            }
    
            self.performSegue(withIdentifier: "MoveToNormalLoginVC", sender: nil)
            
        }
        
      
    }
    
    @IBAction func fbBtnPressed(_ sender: Any) {
        
        
        DataService.instance.mainFireStoreRef.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty != true {
                     
                self.showErrorAlert("Oops!", msg: "We're down for scheduled maintenance right now!")
                return
             
            }
    
            login_type = "Facebook"
            self.fbButton.sendActions(for: .touchUpInside)
            
        }
        
    }
    
    @IBAction func GgBtnPressed(_ sender: Any) {
        
        
        DataService.instance.mainFireStoreRef.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty != true {
                          
                self.showErrorAlert("Oops!", msg: "We're down for scheduled maintenance right now!")
                return
             
            }
            
            
            login_type = "Google"
            let signInConfig = GIDConfiguration.init(clientID: (FirebaseApp.app()?.options.clientID)!)
            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                guard error == nil else { return }
                
                if let error = error {
                  if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
                    print("The user has not signed in before or they have since signed out.")
                  } else {
                    print("\(error.localizedDescription)")
                  }
                  return
                }
                  
               
                // Perform any operations on signed in user here.
                let userId = user?.userID                  // For client-side use only!
                let fullName = user?.profile!.name
                let tokenAccess = user?.authentication.accessToken
                let tokenID = user?.authentication.idToken
               
                // ...
                  
                
                  
                if let id = userId, fullName != nil, tokenAccess != nil, tokenID != nil  {
                      
                  let dict = ["fullName": fullName as Any, "tokenAccess": tokenAccess as Any, "tokenID": tokenID as Any] as Dictionary<String, Any>
                  
                    self.checkForAlreadyAccount(field: "Google_id", id: "gg\(id)", dict: dict)
                      
                } else {
                  
                  
                  self.showErrorAlert("Oops!", msg: "Can't gather your information")
                  
                }

                // If sign in succeeded, display the app's main content View.
              }
            
           
    
        }
        
        
        
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        getDataFromFacebook()
        
    
    }
    
    func getDataFromFacebook() {
      
        swiftLoader()
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email,age_range,gender, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                if let fbDetails = result as? Dictionary<String, Any> {
               
                    if let id = fbDetails["id"] {
                        self.checkForAlreadyAccount(field: "Facebook_id", id: "fb\(id)", dict: fbDetails)
                    }
                    
                }
                
            } else {
                
                // error
                SwiftLoader.hide()
                print(error!.localizedDescription)
                
            }
        
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
         
        print("Facebook logged out")
        
    }
    

    func checkForAlreadyAccount(field: String,id: String, dict: Dictionary<String, Any>) {
        
        swiftLoader()
        Auth.auth().signInAnonymously { result, err in
            if err != nil {
                
                print(err!.localizedDescription)
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                SwiftLoader.hide()
                return
            }
            
            DataService.instance.mainFireStoreRef.collection("Users").whereField(field, isEqualTo: id).getDocuments { (snap, err) in
                
                if err != nil {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    SwiftLoader.hide()
                    return
                }
                
                
                self.keyId = id
                       
                
                if snap?.isEmpty == true {
                                     
                    print("Process new login")
                    
                    
                    
                    if login_type == "Facebook" {
                        self.processNewFBLogin(dict: dict)
                    } else if login_type == "Google" {
                        self.processNewGGLogin(dict: dict)
                    } else if login_type == "Twitter"{
                        self.processNewTwLogin(dict: dict)
                    } else if login_type == "Apple" {
                        self.processNewAppleLogin(dict: dict)
                    }
                    
                } else {
                    
                    print("Process already login")
                    
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
                                                    
                                                    self.performNormalLogin(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, nickName: username, overwrite_suspend: true, message_noti: MessageNotiStatus)
                                                    
                                                } else {
                                                    
                                                    self.performNormalLogin(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, nickName: username, overwrite_suspend: true, message_noti: false)
                                                    
                                                }
                                            
                                                
                                                
                                                
                                            }
                                            
                                        } else {
                                            
                                            
                                            let format = current_suspend_time.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
                                            
                                            if let suspend_reason = i["suspend_reason"] as? String, suspend_reason != "" {
                                                
                                                SwiftLoader.hide()
                                                try? Auth.auth().signOut()
                                                self.showErrorAlert("Your account is suspended", msg: "Your account is suspended because of \(suspend_reason) until \(format), if you have any question please contact our support at support@stitchbox.gg")
                                                
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
                                            
                                            self.performNormalLogin(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, nickName: username, overwrite_suspend: false, message_noti: MessageNotiStatus)
                                            
                                        } else {
                                            
                                            self.performNormalLogin(updatefid: item.documentID, key: encryptedKey, avatarUrl: avatarUrl, nickName: username, overwrite_suspend: false, message_noti: false)
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            }
                            
                            
            
                            
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            
        }
        
        
        
        
        
        
    }
    
    func performNormalLogin(updatefid: String ,key: String, avatarUrl: String, nickName: String, overwrite_suspend: Bool, message_noti: Bool) {
        
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
                        
                        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                        
                        appDelegate?.listenToApiKeyUpdates()
                        appDelegate?.trackProfile()
                        
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
                        
                        SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid, nickname: nickName, profileUrl: avatarUrl)
                        
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
                                    appDelegate?.loadProfileAndSendBird()
                                    appDelegate?.trackProfile()
                                   
                                    
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
                            self.performSegue(withIdentifier: "moveToMainVC500", sender: nil)
                            
                        }
                        
         
                        
                    }
                    
                    
                }
                
            }
            

            
        }
        
        
    }
    
    func processNewTwLogin(dict: Dictionary<String, Any>) {
        
        if let name = dict["fullName"] as? String {
            finalName = name
        } else {
            finalName = "Defaults"
        }
        
        
        if let url = dict["img_url"] as? String {
            
            self.downloadImgAndPerformSegue(url: url)
            
        }
        
    }
    
    func processNewGGLogin(dict: Dictionary<String, Any>) {
        
        if let name = dict["fullName"] as? String {
            finalName = name
        } else {
            finalName = "Defaults"
        }
        
        if let tokenAccess = dict["tokenAccess"] as? String {
            
            let Url_Base = "https://www.googleapis.com/oauth2/v3/userinfo?access_token="
            let _UrlProfile = "\(Url_Base)\(tokenAccess)"
            AF.request(_UrlProfile).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let result = response.value as? [String: Any] {
                        
                        if  let photoUrl = result["picture"] as? String {
                            
                            self.downloadImgAndPerformSegue(url: photoUrl)
                            
                            
                        }
                    }
                        
                case .failure:
                    self.showErrorAlert("Oops!", msg: "Can't get information from Google")
                    return
                        
                    }
                }
                
            }
            
    
    
    }
        
    
    func downloadImgAndPerformSegue(url: String) {
        
        AF.request(url).responseImage { response in
               
               
               switch response.result {
               case let .success(value):
                    let metaData = StorageMetadata()
                   
                    let imageUID = UUID().uuidString
                    metaData.contentType = "image/jpeg"
                    var imgData = Data()
                    imgData = value.jpegData(compressionQuality: 1.0)!
                    
                    DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
                        
                        if err != nil {
                            SwiftLoader.hide()
                            print(err?.localizedDescription as Any)
                            return
                        }
                        
                        DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                            
                            guard let Url = url?.absoluteString else {
                                SwiftLoader.hide()
                                return
                                
                            }
                            
                            let downUrl = Url as String
                            let downloadUrl = downUrl as NSString
                            let downloadedUrl = downloadUrl as String
                            
                            self.avatarUrl = downloadedUrl
                            self.performMovingTransaction()
                            
                        })
                        
                    }
                    
               case let .failure(error):
                    print(error.localizedDescription)
                    self.avatarUrl = "nil"
                    self.performMovingTransaction()
               }
               
               
               
           }
        
    }
   
        
        
    
    
    func processNewFBLogin(dict: Dictionary<String, Any>) {
        
        
        if let name = dict["name"] as? String {
           finalName = name
        } else {
            finalName = "Defaults"
        }
        
        if let picture = dict["picture"] as? Dictionary<String, Any> {
            
            if let data = picture["data"] as? Dictionary<String, Any> {
                
                if let url = data["url"] as? String {
                    
                    AF.request(url).responseImage { response in
                           
                           
                           switch response.result {
                           case let .success(value):
                                let metaData = StorageMetadata()
                               
                                let imageUID = UUID().uuidString
                                metaData.contentType = "image/jpeg"
                                var imgData = Data()
                                imgData = value.jpegData(compressionQuality: 1.0)!
                                
                                DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
                                    
                                    if err != nil {
                                        print(err?.localizedDescription as Any)
                                        return
                                    }
                                    
                                    DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
                                        
                                        guard let Url = url?.absoluteString else { return }
                                        
                                        let downUrl = Url as String
                                        let downloadUrl = downUrl as NSString
                                        let downloadedUrl = downloadUrl as String
                                        
                                        self.avatarUrl = downloadedUrl
                                        self.performMovingTransaction()
                                        
                                    })
                                    
                                }
                                
                           case let .failure(error):
                                print(error.localizedDescription)
                                self.avatarUrl = "nil"
                                self.performMovingTransaction()
                           }
                           
                           
                           
                       }
                    
                }
            }
            
        }
        
        
    }
    
    func processNewAppleLogin(dict: Dictionary<String, Any>) {
        
        if let name = dict["name"] as? String {
           finalName = name
        } else {
            finalName = "Defaults"
        }
        
        self.avatarUrl = "nil"
        self.performMovingTransaction()
        
    }
    
    func performMovingTransaction() {
        
        finalPhone = "nil"
        finalCode = "nil"
        finalBirthday = "nil"
        Create_mode = login_type
        
        SwiftLoader.hide()
        try? Auth.auth().signOut()
        self.performSegue(withIdentifier: "MoveToFinalInfo2", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToFinalInfo2"{
            if let destination = segue.destination as? FinalInfoVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.finalName = self.finalName
                destination.finalBirthday = self.finalBirthday
                destination.Create_mode = self.Create_mode
                destination.avatarUrl = self.avatarUrl
                destination.keyId = self.keyId
                
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
    
    // google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInError.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
        
     
      // Perform any operations on signed in user here.
      let userId = user.userID                  // For client-side use only!
      let fullName = user.profile!.name
      let tokenAccess = user.authentication.accessToken
      let tokenID = user.authentication.idToken
     
      // ...
        
      
        
      if let id = userId, tokenID != nil  {
            
        let dict = ["fullName": fullName as Any, "tokenAccess": tokenAccess as Any, "tokenID": tokenID as Any] as Dictionary<String, Any>
        
        checkForAlreadyAccount(field: "Google_id", id: "gg\(id)", dict: dict)
            
      } else {
        
        
        self.showErrorAlert("Oops!", msg: "Can't gather your information")
        
      }
        
   
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func appleBtnPressed(_ sender: Any) {
        
        login_type = "Apple"
        
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        //request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
        
    }
    

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if error._code != 1001 {
            self.showErrorAlert("Oops!", msg: error.localizedDescription)
        }
       
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
          
            let userIdentifier = appleIDCredential.user
            
            
            let fullName = appleIDCredential.fullName
            

            let dict = ["fullName": fullName as Any, "img_url": "nil"] as Dictionary<String, Any>
            
            print(dict)
            
            self.checkForAlreadyAccount(field: "Apple_id", id: "appl\(userIdentifier)", dict: dict)
            
        }
    }
    
    //twitter
    @IBAction func twitterBtnPressed(_ sender: Any) {
        
        DataService.instance.mainFireStoreRef.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty != true {
                           
                
                self.showErrorAlert("Oops!", msg: "We're down for scheduled maintenance right now!")
                return
             
            }
            
            
            login_type = "Twitter"
            
            var swifter: Swifter!
            //var accToken: Credential.OAuthAccessToken?
            
            
            swifter = Swifter(consumerKey: TwitterConstants.CONSUMER_KEY, consumerSecret: TwitterConstants.CONSUMER_SECRET_KEY)
            
            swifter.authorize(withCallback: URL(string: TwitterConstants.CALLBACK_URL)!, presentingFrom: self, success: { accessToken, _ in
                        //accToken = accessToken
                        
                swifter.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true, success: { json in
                            // Twitter Id
                    
                            var twitterId = ""
                            var name = ""
                            var url = ""
                    
                    
                            if let twitterIds = json["id_str"].string {
                                twitterId = twitterIds
                            } else {
                                twitterId = "Not exists"
                            }


                            // Twitter Name
                            if let twitterName = json["name"].string {
                                name = twitterName
                            } else {
                                name = ""
                            }


                            // Twitter Profile Pic URL
                            if let twitterProfilePic = json["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil) {
                                url =  twitterProfilePic
                            } else {
                                url = ""
                            }
                            
                    
                        let dict = ["fullName": name as Any, "img_url": url] as Dictionary<String, Any>
                    
                        self.checkForAlreadyAccount(field: "Twitter_id", id: "tw\(twitterId)", dict: dict)

                        }) { error in
                            print("ERROR: \(error.localizedDescription)")
                        }
                
                
                    }, failure: { _ in
                        self.showErrorAlert("Oops!", msg: "ERROR: Trying to authorize.")
                    })
            
           
             
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
    
    
    func checkAppMaintaince() {
  
        
        DataService.instance.mainFireStoreRef.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty == true {
                            
                return
             
            }
    
        }
        
    }
    
}


