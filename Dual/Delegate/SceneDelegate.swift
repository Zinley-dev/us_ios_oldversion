//
//  SceneDelegate.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/21/20.
//

import UIKit
import FBSDKCoreKit
//import TwitterKit
import Firebase
import Swifter
import SendBirdSDK
import SendBirdUIKit
import SendBirdCalls

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        

    
    }
    

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        pauseVideoIfNeed()
        background = true
        
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        resumeVideoIfNeed()
        removeUnFollowUserDaily()
        
        
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
              
              if Auth.auth().currentUser?.uid != nil {
                  
                  checkregistrationTokenAndPerformUpload(token: token)
                  checkAndRegisterForFCMDict(token: token)
                  loadInActiveFCMToken()
                  
                  if  Auth.auth().currentUser?.uid != nil {
                      
                      DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["Last_activeTimeStamp": FieldValue.serverTimestamp()])
                      
                  }
                  
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
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        print(error.localizedDescription)
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        pauseVideoIfNeed()
        
        
        
    
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        resumeVideoIfNeed()
        
        delay(5) {
            checkUserCreateTimeAndPerformRateRequest()
        }
        
    }
    

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        pauseVideoIfNeed()
       
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
       
        
        if login_type == "Twitter" {
            
            guard let context = URLContexts.first else { return }
                    let callbackUrl = URL(string: TwitterConstants.CALLBACK_URL)!
                    Swifter.handleOpenURL(context.url, callbackURL: callbackUrl)
            
        }

   
        
        
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        if let incomingUrl = userActivity.webpageURL {
            print("Incomming URL is \(incomingUrl)")
           
            
            guard let components = URLComponents(url: incomingUrl, resolvingAgainstBaseURL: false),let queryItems = components.queryItems else {
                
                return
                
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

 


}

