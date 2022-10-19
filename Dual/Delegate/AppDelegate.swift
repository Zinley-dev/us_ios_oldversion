//
//  AppDelegate.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/21/20.
//

import UIKit
import Firebase
import PixelSDK
import Alamofire
import FBSDKCoreKit
import GoogleSignIn
//import TwitterKit
import SendBirdSDK
import SendBirdCalls
import UserNotifications
import PushKit
import CallKit
import SendBirdUIKit
import GooglePlaces
import GoogleMaps
import Swifter
import FirebaseAppCheck
import AlgoliaSearchClient
import MediaPlayer
import AppsFlyerLib
import AppTrackingTransparency
import FBSDKLoginKit
import FBSDKCoreKit



var versionInfo: String {
    let sampleVersion = Bundle.main.version
    return "QuickStart \(sampleVersion)   SDK \(SendBirdCall.sdkVersion)"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {
    
    
    var window: UIWindow?
    private let baseURLString: String = "https://desolate-woodland-21996.herokuapp.com/"
 
    var volumeOutputList = [Float]()
    var firstNoti = false
    var firstMantain = false
    var firstProfile = false
    
    var receivedPushChannelUrl: String?
    var pushReceivedGroupChannel: String?
    
    lazy var delayItem = workItem()
    private var audioLevel : Float = 0.0

    //var window: UIWindow?
    var voipRegistry: PKPushRegistry?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        
        let providerFactory = YourSimpleAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        AppsFlyerLib.shared().appsFlyerDevKey = "RvjSzWL2nP9ZHkjwiUsJSa"
        AppsFlyerLib.shared().appleAppID = "id1576592262"
        
        // firebase configure
        FirebaseApp.configure()
        
        sessionId = UUID().uuidString
         
        let userDefaults = UserDefaults.standard
        
        if Auth.auth().currentUser?.isAnonymous == true {
            try? Auth.auth().signOut()
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "hasGuideLandScapeBefore")
            userDefaults.removeObject(forKey: "hasGuideSwipePlaySpeed")
            userDefaults.removeObject(forKey: "hasGuideLandscapeAnimation")
            userDefaults.removeObject(forKey: "hasGuideHideInformation")
            userDefaults.removeObject(forKey: "hasAlertContentBefore")
            userDefaults.removeObject(forKey: "hasGuideChallengefore")
            userDefaults.removeObject(forKey: "hasGuideEditChallengefore")
            
        }
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            print("The app is launching for the first time. Setting UserDefaults...")
            
            do {
                try Auth.auth().signOut()
                let userDefaults = UserDefaults.standard
                userDefaults.removeObject(forKey: "hasGuideLandScapeBefore")
                userDefaults.removeObject(forKey: "hasGuideSwipePlaySpeed")
                userDefaults.removeObject(forKey: "hasGuideLandscapeAnimation")
                userDefaults.removeObject(forKey: "hasGuideHideInformation")
                userDefaults.removeObject(forKey: "hasAlertContentBefore")
                userDefaults.removeObject(forKey: "hasGuideChallengefore")
                userDefaults.removeObject(forKey: "hasGuideEditChallengefore")
                
            } catch {
                
            }
            
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
            
            // Run code here for the first launch
            
        } else {
            print("The app has been launched before. Loading UserDefaults...")
            // Run code here for every other launch but the first
        }
        
        DispatchQueue.main.async() {
            guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { ifhasNotch = false
                return
            }
            
            ifhasNotch = window.safeAreaInsets.top >= 44
            
        }
        
        activeSpeaker()
        self.voipRegistration()
        self.addDirectCallSounds()
        
        attemptRegisterForNotifications(application: application)
        setupStyle()
    
        getAppMaintaince()
        
       
       
        
        SBDMain.initWithApplicationId(sendbird_applicationID, useCaching: true) {
            print("initWithApplicationId")
        }
        
        //SBDMain.initWithApplicationId(sendbird_applicationID)
        SendBirdCall.configure(appId: sendbird_applicationID)
        SendBirdCall.addDelegate(self, identifier: "Dual.LLC.DualTeam2020.delegate")
        SendBirdCall.executeOn(queue: DispatchQueue.main)
        UserDefaults.standard.designatedAppId = sendbird_applicationID
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        
        
        if Auth.auth().currentUser?.uid != nil {
            
            self.loadProfileAndSendBird()
            self.trackProfile()
            self.listenToApiKeyUpdates()
            
        }
        
        listenVolumeButton()
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        return true
    }
    
    @objc func sendLaunch() {
       
        AppsFlyerLib.shared().start()
        
    }
    
    
    func listenVolumeButton(){
        
         let audioSession = AVAudioSession.sharedInstance()
         do {
              try audioSession.setActive(true, options: [])
         audioSession.addObserver(self, forKeyPath: "outputVolume",
                                  options: NSKeyValueObservingOptions.new, context: nil)
              audioLevel = audioSession.outputVolume
         } catch {
              print("Error")
         }
    }

   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume"{
              let audioSession = AVAudioSession.sharedInstance()
             
             
              if audioSession.outputVolume > audioLevel {
                   unmuteVideoIfNeed()
              } else {
                  volumeOutputList.append(audioSession.outputVolume)
                  
                  
                  delayItem.perform(after: 0.6) {
                      
                      if self.volumeOutputList.count == 2 {
                          muteVideoIfNeed()
                      }
                      
                      self.volumeOutputList.removeAll()
                      
                  }
              }
            
            audioLevel = audioSession.outputVolume
         }
    }
    
    
    
    func setupStyle() {
        
        SBUTheme.set(theme: .dark)
        SBUTheme.channelListTheme.navigationBarTintColor = UIColor(red: 40, green: 42, blue: 48)
        SBUTheme.channelTheme.navigationBarTintColor = UIColor(red: 40, green: 42, blue: 48)
        SBUTheme.channelSettingsTheme.navigationBarTintColor = UIColor(red: 40, green: 42, blue: 48)
        
        //SBUStringSet.Empty_No_Channels = "No messages"
        SBUStringSet.User_No_Name = "Dual user"
        SBUStringSet.User_Operator = "Leader"
        
        //
        SBUGlobals.UsingImageCompression = true
        SBUGlobals.imageCompressionRate = 0.65
        SBUGlobals.imageResizingSize = CGSize(width: 480, height: 480)
        
        
    }


    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
   
    
    func applicationWillTerminate(_ application: UIApplication) {
        // This method will be called when the app is forcefully terminated.
        // End all ongoing calls in this method.
        let callManager = CXCallManager.shared
        let ongoingCalls = callManager.currentCalls.compactMap { SendBirdCall.getCall(forUUID: $0.uuid) }
        
        ongoingCalls.forEach { directCall in
            // Sendbird Calls: End call
            directCall.end()
            
            // CallKit: Request End transaction
            callManager.endCXCall(directCall)
            
            // CallKit: Report End if uuid is valid
            if let uuid = directCall.callUUID {
                callManager.endCall(for: uuid, endedAt: Date(), reason: .none)
            }
        }
        // However, because iOS gives a limited time to perform remaining tasks,
        // There might be some calls failed to be ended
        // In this case, I recommend that you register local notification to notify the unterminated calls.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        checkCall()
        resumeVideoIfNeed()
        removeUnFollowUserDaily()
        
        delay(5) {
            checkUserCreateTimeAndPerformRateRequest()
        }
        
       
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
              
              checkregistrationTokenAndPerformUpload(token: token)
              checkAndRegisterForFCMDict(token: token)
              loadInActiveFCMToken()
              
              if Auth.auth().currentUser?.uid != nil {
                  
                  DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["Last_activeTimeStamp": FieldValue.serverTimestamp()])
                  
              }
              
            }
        }
        
        
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                return
                
            }
            
            if call.isEnded == true {
                
                activeSpeaker()
                
            }
            
        } else {
             
            if general_room != nil {
                
                
               
                
                
            } else {
                
                activeSpeaker()
                
            }
            
            
            
            
        }
     
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if let vc = UIViewController.currentViewController() {
       
            if vc is FeedVC || vc is UserHighlightFeedVC {
                return [.portrait, .landscape]
            } else {
                return .portrait
            }
            
        } else {
            
            return .portrait
            
        }
            
            
            
            
    }
    func checkCall() {
        
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                return
                
            }
            
            if call.isEnded == true {
                
                general_call = nil
                call.end()
                CXCallManager.shared.endCXCall(call)
                
            }
            
        }
        
    }
    
    
    func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if login_type == "Facebook" {
            
           return ApplicationDelegate.shared.application (
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
        } else if login_type == "Google" {
            
            var handled: Bool

              handled = GIDSignIn.sharedInstance.handle(url)
              if handled {
                return true
              }
            
            return false
            
        } else if login_type == "Twitter" {
            
            
            
            let callbackUrl = URL(string: TwitterConstants.CALLBACK_URL)!
                    Swifter.handleOpenURL(url, callbackURL: callbackUrl)
                    return true
            
        } else {
            
            // handle later dynamic link
            
            return false
        }

            

    }
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    


    override init() {
        super.init()
        
        // Main API client configuration
        MainAPIClient.shared.baseURLString = baseURLString
              
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications:", deviceToken)
        
        SBDMain.registerDevicePushToken(deviceToken, unique: false) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    print("Push registration is pending.")
                }
                else {
                    print("APNS Token is registered.")
                }
            }
            else {
                print("APNS registration failed with error: \(String(describing: error))")
            }
        }
        
        
    }
    
   
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        if let token = fcmToken {
            if Auth.auth().currentUser?.uid != nil {
                
                checkregistrationTokenAndPerformUpload(token: token)
                checkAndRegisterForFCMDict(token: token)
                loadInActiveFCMToken()
                
            }
          
            
        }
        
        ///checkregistrationTokenAndPerformUpload(token: fcmToken)
    }

    
    private func attemptRegisterForNotifications(application: UIApplication) {
        print("Attempting to register APNS...")
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            // user notifications auth
            // all of this works for iOS 10+
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
                if let err = err {
                    print("Failed to request auth:", err)
                    return
                }
                
                if granted {
                    print("Auth granted.")
                  
                } else {
                    print("Auth denied")
                }
            }
        } else {
            
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            
            
        }
        
 
        application.registerForRemoteNotifications()
       
       
    }
    

    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        
     
        let userInfo = response.notification.request.content.userInfo
        
        if let payload: NSDictionary = userInfo["sendbird"] as? NSDictionary, let channel = payload["channel"] as? NSDictionary, let channelUrl = channel["channel_url"] as? String {
            
            SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid)
            
            
            SBUMain.connectIfNeeded { usr, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                if usr != nil {
                    
                    if let vc = UIViewController.currentViewController() {
                        
                       
                        if vc == UINavigationController.currentViewController() as? ChannelViewController {
                            
                            if let current = UINavigationController.currentViewController() as? ChannelViewController {
                                
                               
                                                              
                                if current.channelUrl != channelUrl {
                                    
                                    
                                    current.navigationController?.popViewController(animated: false)
                                    
                                    
                                    if let next = UIViewController.currentViewController() {
                                        
                                        let channelVC = ChannelViewController(
                                            channelUrl: channelUrl,
                                            messageListParams: nil
                                        )
                                        
                                        if next is FeedVC {
                                            
                                            if let update = next as? FeedVC {
                                                update.setPortrait()
                                            }
                                            
                                        } else if next is UserHighlightFeedVC {
                                            
                                            if let update = next as? UserHighlightFeedVC {
                                                update.setPortrait()
                                            }
                                            
                                        }
                                        
                                                   
                                        let navigationController = UINavigationController(rootViewController: channelVC)
                                        navigationController.modalPresentationStyle = .fullScreen
                                        next.present(navigationController, animated: true, completion: nil)
                                        
                                        
                                    }
                                    
                                } else {
                                    
                                    current.scrollToBottom(animated: true)
                                    
                                }
                                
                            }
                            
                        } else {
                            
               
                            let channelVC = ChannelViewController(
                                channelUrl: channelUrl,
                                messageListParams: nil
                            )
                            
                            if vc is FeedVC {
                                
                                if let update = vc as? FeedVC {
                                    update.setPortrait()
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update = vc as? UserHighlightFeedVC {
                                    update.setPortrait()
                                }
                                
                            }
                            
                                       
                            let navigationController = UINavigationController(rootViewController: channelVC)
                            navigationController.modalPresentationStyle = .fullScreen
                            vc.present(navigationController, animated: true, completion: nil)
                            
                        }
                             
                         
                    } else {
                        
                        
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? HomePageVC {
                            
                            
                            let channelVC = ChannelViewController(
                                channelUrl: channelUrl,
                                messageListParams: nil
                            )
                            
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            if let window = self.window {
                                window.rootViewController = viewController
                                window.makeKeyAndVisible()
                            }
                            
                            let navigationController = UINavigationController(rootViewController: channelVC)
                            navigationController.modalPresentationStyle = .fullScreen
                            viewController.present(navigationController, animated: true, completion: nil)
                            
                        }
                        
                                  
                    }
                    
                }
                
            }
            

                
                
                
            
            
            
        } else {
            
            if let type = userInfo["type"] as? String {
                
                if type == "Follow" {
                    
                    
                    if let Following_uid = userInfo["Following_uid"] as? String {
                        
                        
                        MoveToUserProfileVC(uid: Following_uid)
                        
                        
                    }
                    
                } else if type == "Challenge" {
                    
                    if let sender_ID = userInfo["sender_ID"] as? String {
                        
                        
                        MoveToUserProfileVC(uid: sender_ID)
                        
                        
                    }
                    
                } else if type == "Reply" {
                    
                    // process Reply
                    
                    
                    if let CId = userInfo["CId"] as? String, let reply_to_cid = userInfo["reply_to_cid"] as? String, let Mux_playbackID = userInfo["Mux_playbackID"] as? String, let root_id = userInfo["root_id"] as? String, let Highlight_Id = userInfo["Highlight_Id"] as? String, let category = userInfo["category"] as? String, let owner_uid = userInfo["owner_uid"] as? String {
                        
                
                        processComment(Mux_playbackID: Mux_playbackID, CId: CId, reply_to_cid: reply_to_cid, type: "Reply", root_id: root_id, Highlight_Id: Highlight_Id, category: category, owner_uid: owner_uid)
                        
                    } else {
                        
                        print("Not enough data - reply")
                        
                    }
                        
                    
                }  else if type == "Comment" {
                    
                    // process Comment
                
                    
                    if let CId = userInfo["CId"] as? String, let Mux_playbackID = userInfo["Mux_playbackID"] as? String, let Highlight_Id = userInfo["Highlight_Id"] as? String, let category = userInfo["category"] as? String, let owner_uid = userInfo["owner_uid"] as? String {
                        
                        
                        processComment(Mux_playbackID: Mux_playbackID, CId: CId, reply_to_cid: "", type: "Comment", root_id: "", Highlight_Id: Highlight_Id, category: category, owner_uid: owner_uid)
                        
                    } else {
                        
                        
                        print("Not enough data - comment")
                    }
                    
                }
                
                
            }  else {
                
                print("Can't activity type")
                
            }
            
            
        }
    
    }
    
    
    func processComment(Mux_playbackID: String, CId: String, reply_to_cid: String, type: String, root_id: String, Highlight_Id: String, category: String, owner_uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_playbackID", isEqualTo: Mux_playbackID).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                
                return
            }
            
            if snap?.isEmpty == true {
                
                
                return
                
            }
            
            
            let slideVC = CommentNotificationVC()
            slideVC.CId = CId
            slideVC.get_reply_to_cid = reply_to_cid
            slideVC.type = type
            slideVC.root_id = root_id
            slideVC.Highlight_Id = Highlight_Id
            slideVC.Mux_playbackID = Mux_playbackID
            slideVC.category = category
            slideVC.owner_uid = owner_uid
            slideVC.modalPresentationStyle = .custom
            
            
            if let vc = UIViewController.currentViewController() {
                
                if vc is FeedVC {
                    
                    if let update = vc as? FeedVC {
                        update.setPortrait()
                        
                        if update.currentIndex != nil {
                            
                            if let cell = update.collectionNode.nodeForItem(at: IndexPath(row: update.currentIndex, section: 0)) as? PostNode {
                                
                                cell.videoNode.pause()
                                
                            }
                        }
                        
                        //
                    }
                    
                } else if vc is UserHighlightFeedVC {
                    
                    if let update = vc as? UserHighlightFeedVC {
                        update.setPortrait()
                        
                        
                        if update.currentIndex != nil {
                            
                            if let cell = update.collectionNode.nodeForItem(at: IndexPath(row: update.currentIndex, section: 0)) as? PostNode {
                                
                                cell.videoNode.pause()
                                
                            }
                        }
                        
                        
                        //
                    }
                    
                }
                
                slideVC.transitioningDelegate = vc.self
                vc.present(slideVC, animated: true, completion: nil)
                
                 
            } else {
                
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? HomePageVC {
                    
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    if let window = self.window {
                        window.rootViewController = viewController
                        window.makeKeyAndVisible()
                    }
                    
                    
                    slideVC.transitioningDelegate = viewController.self
                    viewController.present(slideVC, animated: true, completion: nil)
                    
                }
                
                          
            }
            
        }
        
        
        
    }
    
    
    
    
    
    func MoveToUserProfileVC(uid: String) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            if let vc = UIViewController.currentViewController() {
                
                if vc is FeedVC {
                    
                    if let update = vc as? FeedVC {
                        update.setPortrait()
                    }
                    
                } else if vc is UserHighlightFeedVC {
                    
                    if let update = vc as? UserHighlightFeedVC {
                        update.setPortrait()
                    }
                    
                }
                
                controller.uid = uid
                
                vc.present(controller, animated: true, completion: nil)
                 
            } else {
                
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? HomePageVC {
                    
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    if let window = self.window {
                        window.rootViewController = viewController
                        window.makeKeyAndVisible()
                    }
                    
                    
                    controller.uid = uid
                   
                    viewController.present(controller, animated: true, completion: nil)
                    
                }
                
                          
            }
            
            
        }
        
    }
    

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        
        if let incomingUrl = userActivity.webpageURL {
            print("Incomming URL is \(incomingUrl)")
           
            
            guard let components = URLComponents(url: incomingUrl, resolvingAgainstBaseURL: false),let queryItems = components.queryItems else {
                
                return false
                
            }
            
            
            for queryItem in queryItems {
                
                if queryItem.name == "p" {
                    
                    if let id = queryItem.value {
                        
                        let db = DataService.instance.mainFireStoreRef
                        
                        
                        db.collection("Highlights").document(id).getDocument { (snap, err) in
                            
                            if err != nil {
                                
                                print(err!.localizedDescription)
                                return
                            }
                            
                            
                            if snap?.exists != false {
                                
                                if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String, let mode = snap!.data()!["mode"] as? String {
                                    
                                    if status == "Ready", !global_block_list.contains(owner_uid) {
                                           
                                        if mode != "Only me" {
                                            
                                            if mode == "Followers"  {
                                                
                                                if global_following_list.contains(owner_uid) ||  owner_uid == Auth.auth().currentUser?.uid {
                                                    
                                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                    self.presentViewController(id: id, items: [i])
                                                    
                                                }
                                                
                                            } else if mode == "Public" {
                                                
                                                let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                self.presentViewController(id: id, items: [i])
                                                
                                            }
                                            
                                        } else{
                                            
                                            if owner_uid == Auth.auth().currentUser?.uid {
                                                
                                                let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                self.presentViewController(id: id, items: [i])
                                                
                                                
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }

                            
                        }
                        
                    }
    
                } else if queryItem.name == "up" {
                    
                    if let id = queryItem.value {
                        
                        if !global_block_list.contains(id) {
                            
                            MoveToUserProfileVC(uid: id)
                        }
                        
                    }
                    
                 
                }
                
                
            }
            
            
        }
        
        return false
        
    }
    
    
    func presentViewController(id: String, items: [HighlightsModel]) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            controller.video_list = items
            controller.userid = items[0].userUID
            controller.startIndex = 0
            
       
            
            if let vc = UIViewController.currentViewController() {
                
                if vc is FeedVC {
                    
                    if let update = vc as? FeedVC {
                        update.setPortrait()
                    }
                    
                } else if vc is UserHighlightFeedVC {
                    
                    if let update = vc as? UserHighlightFeedVC {
                        update.setPortrait()
                    }
                    
                }
                
                vc.present(controller, animated: true, completion: nil)
                 
            } else {
                
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? HomePageVC {
                    
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    if let window = self.window {
                        window.rootViewController = viewController
                        window.makeKeyAndVisible()
                    }
                    
            
                    viewController.present(controller, animated: true, completion: nil)
                    
                }
                
                          
            }
            
            
        }
 
        
    }

    
    // listen to api key info in firebase and update info accordingly in constant
    func listenToApiKeyUpdates() {
        
        apiKeyInfoListener = DataService.instance.mainFireStoreRef.collection("Api_keys").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching algolia snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                // do we really need this?
                if (diff.type == .added) {
                    let apiKeyDetail = ApiKeyDetail(apiKeyModel: diff.document.data())
                    api_key_dict[apiKeyDetail.serviceName] = apiKeyDetail
                    print("New service api info added: \(String(describing: apiKeyDetail.serviceName))")
                    
                    self.registerServicesWithKey(apiKeyDetail: apiKeyDetail)
                    /*
                     1/ Sendbird
                     2/ Google Map
                     */
                    
                    
                }
                // could be useful to update info
                if (diff.type == .modified) {
                    let apiKeyDetail = ApiKeyDetail(apiKeyModel: diff.document.data())
                    api_key_dict[apiKeyDetail.serviceName] = apiKeyDetail
                    print("Existing service api info modified: \(String(describing: apiKeyDetail.serviceName))")
                    
                    // re-register service with new key
                    self.registerServicesWithKey(apiKeyDetail: apiKeyDetail)
                }
   
            }
            
        }
    }
    
    func registerServicesWithKey(apiKeyDetail: ApiKeyDetail) {
        // if this apikey is not in active status, do not register the service
        if !apiKeyDetail.isActive {
            // do anything here necessary to deactivate the service
            // disableService()
            return
        }
        if apiKeyDetail.serviceName == "Algolia" {
           
            //register algolia service if the api key is in active status
            algoliaSearchClient = SearchClient(appID: ApplicationID(rawValue: apiKeyDetail.appId), apiKey: APIKey(rawValue: apiKeyDetail.key))
        }
        if apiKeyDetail.serviceName == "GoogleMap" {
            
            GMSServices.provideAPIKey(apiKeyDetail.key)
            GMSPlacesClient.provideAPIKey(apiKeyDetail.key)
        }
        if apiKeyDetail.serviceName == "Twitter" {
            
            /*
            var swifter = Swifter(consumerKey: apiKeyDetail.appId, consumerSecret: apiKeyDetail.key)
            
            swifter.aut
            */
            
            /*
            swifter.authorize(with: callbackURL, success: { accessToken, response in
                print("Success")
            }, failure: { error in
                print(error.localizedDescription)
            })*/
            
            
            //TWTRTwitter.sharedInstance().start(withConsumerKey: apiKeyDetail.appId, consumerSecret: apiKeyDetail.key)
        }
        if apiKeyDetail.serviceName == "Pixel" {
            
            PixelSDK.setup(apiKeyDetail.key)
            PixelSDK.shared.maxVideoDuration = 180
            PixelSDK.shared.primaryFilters = PixelSDK.defaultStandardFilters + PixelSDK.defaultVisualEffectFilters
        }

        
    }
    
    
    func getAppMessage() {
        
        let db = DataService.instance.mainFireStoreRef
        
        messageListen = db.collection("Notification_control").addSnapshotListener {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty == true {
                
                
                self.firstNoti = true
                return
                
                
                
            } else {
                
                if self.firstNoti == false {
                    
                    self.firstNoti = true
                    
                    for item in snapshot.documents {
                        
                        
                        if item.data()["status"] as? Bool  == true, item.data()["message"] as! String != "", item.data()["title"] as! String != "" {
                            
                            
                            
                            if let vc = UIViewController.currentViewController() {
                                
                                let alert = UIAlertController(title: (item.data()["title"] as! String), message: (item.data()["message"] as! String), preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(action)
                                
                                if vc is FeedVC {
                                    
                                    if let update = vc as? FeedVC {
                                        update.setPortrait()
                                    }
                                    
                                } else if vc is UserHighlightFeedVC {
                                    
                                    if let update = vc as? UserHighlightFeedVC {
                                        update.setPortrait()
                                    }
                                    
                                }
                                
                                                                                                               
                                vc.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                        
                    }
                    
                }
                     
            }
            
            snapshot.documentChanges.forEach { diff in
                
                if (diff.type == .modified) {
                   
                    if diff.document.data()["status"] as? Bool == true, diff.document.data()["message"] as! String != "", diff.document.data()["title"] as! String != "" {
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            let alert = UIAlertController(title: (diff.document.data()["title"] as! String), message: (diff.document.data()["message"] as! String), preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(action)
                            
                            
                            if vc is FeedVC {
                                
                                if let update = vc as? FeedVC {
                                    update.setPortrait()
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update = vc as? UserHighlightFeedVC {
                                    update.setPortrait()
                                }
                                
                            }
                            
                                                                                                           
                            vc.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func getAppMaintaince() {
        
        let db = DataService.instance.mainFireStoreRef
        
         maintanenceListen = db.collection("Maintenance_control").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty == true {
                                
                self.firstMantain = true
                return
             
            } else {
                
                if self.firstMantain == false {
                    
                    self.firstMantain = true
                    
                    for item in snapshot.documents {
                        
                        if item.data()["status"] as? Bool  == true {
                            
                            self.logoutandreset(text: "We're down for scheduled maintenance right now!")
                                                                    
                            
                        }
                        
                        
                    }
                    
                }
                     
            }
            
            snapshot.documentChanges.forEach { diff in
                
                if (diff.type == .modified) {
                   
                    if diff.document.data()["status"] as? Bool == true {
                        
                        self.logoutandreset(text: "We're down for scheduled maintenance right now!")
                        
                    }
                    
                }
            }
            
            
        }
        
    }
    
    func logoutandreset(text: String) {
          
        if let vc = UIViewController.currentViewController() {
            
            if let uid = Auth.auth().currentUser?.uid, uid != "" {
                
                
                
                if let uid = Auth.auth().currentUser?.uid {
                    removeFCMToken(userUID: uid) {
                        
                        
                        SBUMain.connectIfNeeded { usr, error in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                            
                                if usr != nil {
                                    
                                    SBDMain.setPushTriggerOption(.off) { err in
                                        if err != nil {
                                            
                                            showNote(text: err!.localizedDescription)
                                            
                                        } else {
                                            print("Noti off")
                                        }
                                    }
                                    
                                    if let pushToken = SBDMain.getPendingPushToken() {
                                        SBDMain.unregisterPushToken(pushToken, completionHandler: { (response, error) in
                                            /// Fixed Optional Problem(.getPendingPushToken()! -> pushToken)
                                            if error != nil {
                                                showNote(text: error!.localizedDescription)
                                                print(error!.localizedDescription)
                                            } else {
                                                print("SendBirdChat 1 disconnect")
                                                SBDMain.disconnect {
                                                    
                                                }
                                            }
                                        })
                                    }
                                    
                                    //
                                    
                                    SendBirdCall.unregisterVoIPPush(token: UserDefaults.standard.voipPushToken) { (error) in
                                        
                                        if error != nil {
                                            
                                            print(error!.localizedDescription)
                                            
                                        } else {
                                            
                                            SendBirdCall.deauthenticate { err in
                                                if err != nil {
                                                    
                                                    print(err!.localizedDescription)
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        print("SendBirdCall disconnect")

                                            // The VoIP push token has been unregistered successfully.
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        SBDMain.removeAllChannelDelegates()
                        SBDMain.removeAllUserEventDelegates()
                        SBDMain.removeSessionDelegate()
                        SBDMain.removeAllUserEventDelegates()
                        removeAllListen()
                        try? Auth.auth().signOut()
                
                        let userDefaults = UserDefaults.standard
                        userDefaults.removeObject(forKey: "hasGuideLandScapeBefore")
                        userDefaults.removeObject(forKey: "hasGuideSwipePlaySpeed")
                        userDefaults.removeObject(forKey: "hasGuideLandscapeAnimation")
                        userDefaults.removeObject(forKey: "hasGuideHideInformation")
                        userDefaults.removeObject(forKey: "hasAlertContentBefore")
                        userDefaults.removeObject(forKey: "hasGuideChallengefore")
                        userDefaults.removeObject(forKey: "hasGuideEditChallengefore")
                        
                        
                        let loginManager = LoginManager()
                        loginManager.logOut()
                        
                        let alert = UIAlertController(title: "Notice!", message: text, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
                            
                            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProcessVC") as? ProcessVC {
                                
                                
                                if vc is FeedVC {
                                    
                                    if let update = vc as? FeedVC {
                                        update.setPortrait()
                                    }
                                    
                                } else if vc is UserHighlightFeedVC {
                                    
                                    if let update = vc as? UserHighlightFeedVC {
                                        update.setPortrait()
                                    }
                                    
                                }
                                
                                
                                viewController.modalPresentationStyle = .fullScreen
                                
                                vc.present(viewController, animated: true, completion: nil)
                                                   
                                
                            }
                            
                        
                        })
                        
                        
                        
                        alert.addAction(action)
                        
                        
                        
                                                                                                       
                        vc.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
                
                
                
            }
            
            
            
            
        } else {
            
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as? HomePageVC {
                
                self.window = UIWindow(frame: UIScreen.main.bounds)
                if let window = self.window {
                    window.rootViewController = viewController
                    window.makeKeyAndVisible()
                    
                    
                    if let uid = Auth.auth().currentUser?.uid, uid != "" {
                        
                        if let uid = Auth.auth().currentUser?.uid {
                            removeFCMToken(userUID: uid) {
                                
                               
                                SBUMain.connectIfNeeded { usr, error in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                    
                                        if usr != nil {
                                            
                                            SBDMain.setPushTriggerOption(.off) { err in
                                                if err != nil {
                                                    
                                                    showNote(text: err!.localizedDescription)
                                                    
                                                } else {
                                                    print("Noti off")
                                                }
                                            }
                                            
                                            if let pushToken = SBDMain.getPendingPushToken() {
                                                SBDMain.unregisterPushToken(pushToken, completionHandler: { (response, error) in
                                                    /// Fixed Optional Problem(.getPendingPushToken()! -> pushToken)
                                                    if error != nil {
                                                        showNote(text: error!.localizedDescription)
                                                        print(error!.localizedDescription)
                                                    } else {
                                                        print("SendBirdChat 1 disconnect")
                                                        SBDMain.disconnect {
                                                            
                                                        }
                                                    }
                                                })
                                            }
                                            
                                            //
                                            
                                            SendBirdCall.unregisterVoIPPush(token: UserDefaults.standard.voipPushToken) { (error) in
                                                
                                                if error != nil {
                                                    
                                                    print(error!.localizedDescription)
                                                    
                                                } else {
                                                    
                                                    SendBirdCall.deauthenticate { err in
                                                        if err != nil {
                                                            
                                                            print(err!.localizedDescription)
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                }
                                                
                                                print("SendBirdCall disconnect")

                                                    // The VoIP push token has been unregistered successfully.
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                                SBDMain.removeAllChannelDelegates()
                                SBDMain.removeAllUserEventDelegates()
                                SBDMain.removeSessionDelegate()
                                SBDMain.removeAllUserEventDelegates()
                                removeAllListen()
                                try? Auth.auth().signOut()
                                
                                let userDefaults = UserDefaults.standard
                                userDefaults.removeObject(forKey: "hasGuideLandScapeBefore")
                                userDefaults.removeObject(forKey: "hasGuideSwipePlaySpeed")
                                userDefaults.removeObject(forKey: "hasGuideLandscapeAnimation")
                                userDefaults.removeObject(forKey: "hasGuideHideInformation")
                                userDefaults.removeObject(forKey: "hasAlertContentBefore")
                                userDefaults.removeObject(forKey: "hasGuideChallengefore")
                                userDefaults.removeObject(forKey: "hasGuideEditChallengefore")
                                
                                
                                let alert = UIAlertController(title: "Notice!", message: text, preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                
                                
                                
                                alert.addAction(action)
                                
                                
                                viewController.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
                
        
                
                
            }
            
        }
        
    }
    
    
    func loadProfileAndSendBird() {
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
       
        
        db.collection("Users").document(uid!).getDocument {  querySnapshot, error in
             guard let snapshot = querySnapshot else {
                 print("Error fetching snapshots: \(error!)")
                 return
             }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    
                    if let is_suspend = item["is_suspend"] as? Bool {
                        
                        if is_suspend == true {
                         
                        
                         
                        } else {
                         
                            if let avatarUrl = item["avatarUrl"] as? String, let username = item["username"] as? String, let name = item["name"] as? String {
                                 
                                 
                                 global_avatar_url = avatarUrl
                                 global_username = username
                                 global_name = name
                                 self.validateSendBird(avatarUrl: avatarUrl, nickName: username)
                                 
                             }
                            
                            
                            
                            if let isMinimizeGET = item["isMinimize"] as? Bool {
                                
                                if isMinimizeGET == true {
                                    
                                    isMinimize = true
                                   
                                } else {
                                    
                                    isMinimize = false
                                    
                                }
                             
                                
                            } else {
                                
                                isMinimize = false
                                
                            }
                            
                          
                            
                            
                            if let isPending_deletionGET = item["isPending_deletion"] as? Bool {
                                
                                if isPending_deletionGET == true {
                                    
                                    isPending_deletion = true
                                   
                                } else {
                                    
                                    isPending_deletion = false
                                    
                                }
                                
                              
                            } else {
                                
                                isPending_deletion = false
                                
                                
                            }
                         
                        }
                     
                    }
                    
                    
                }
               
                
            } else {
                
                self.logoutandreset(text: "Your account is not found or deleted, please login again or contact our support for more information.")
                
            }
         
    
        }
        
    }
    
    
   func trackProfile() {
       
       let db = DataService.instance.mainFireStoreRef
       let uid = Auth.auth().currentUser?.uid
       
       profileDelegateListen = db.collection("Users").document(uid!).addSnapshotListener {  querySnapshot, error in
               guard let snapshot = querySnapshot else {
                   print("Error fetching snapshots: \(error!)")
                   return
               }
           
           
           if snapshot.exists {
               
               if let item = snapshot.data() {
                   
                   
                   if let is_suspend = item["is_suspend"] as? Bool {
                       
                       if is_suspend == true {
                        
                        
                           if let suspend_time = item["suspend_time"] as? Timestamp {
                            
                            let current_suspend_time = suspend_time.dateValue()
                            
                            let format = current_suspend_time.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
                            
                               if let suspend_reason = item["suspend_reason"] as? String, suspend_reason != "" {
                                
                                
                                self.logoutandreset(text: "Your account is suspended because of \(suspend_reason) reason until \(format), if you have any question please contact our support at support@dual.video")
                                
                            } else {
                                
                                
                                self.logoutandreset(text: "Your account is suspended until \(format), please contact our support for more information at support@dual.video.")
                                        
                            }
                            
                        } else {
                            
                            
                            if let suspend_reason = item["suspend_reason"] as? String, suspend_reason != "" {
                                
                                self.logoutandreset(text: "Your account is suspended because of \(suspend_reason) reason, if you have any question please contact our support at support@dual.video")
                                
                            } else {
                                
                                self.logoutandreset(text: "Your account is suspended, please contact our support for more information.")
                                
                            }
                            
                            
                        }
                        
                       }
                    
                   }
                   
               }
               
               
               
               
               
           } else {
               
               self.logoutandreset(text: "Your account is not found or deleted, please login again or contact our support for more information.")
               
           }
    
        
       }
 
   }
    
    func validateSendBird(avatarUrl: String, nickName: String) {
        
        if Auth.auth().currentUser?.uid != nil {
            
            SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid, nickname: nickName, profileUrl: avatarUrl)
            
          
            SBUMain.connectIfNeeded { [weak self] user, error in
                if error != nil {
                    
                    print(error!.localizedDescription)
                    return
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
                                       
                        
                        self!.voipRegistration()
                        self!.addDirectCallSounds()
                        
                       
                        
                    }
                    
                   
                    SBDMain.setChannelInvitationPreferenceAutoAccept(false, completionHandler: { (error) in
                        guard error == nil else {
                            // Handle error.
                            showNote(text: error!.localizedDescription)
                            return
                        }

                       
                    })
             
                }
            }
            
            
        }
        
       
        
        
    }
    

  
 
    
}


