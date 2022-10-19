//
//  ProcessVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/26/21.
//

import UIKit
import Firebase
import SendBirdSDK
import SendBirdUIKit

class ProcessVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil{
            
            return
        
        }
        
      
    

        sendBirdValidation()
        
    }
    
    func sendBirdValidation() {
        
        
        if Auth.auth().currentUser?.uid != nil {
            
                   
            SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid)
            

        }
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil{
            
            self.performSegue(withIdentifier: "moveToLoginVC100", sender: nil)
            
        } else {
            
            if Auth.auth().currentUser?.isAnonymous == true {
                
                try? Auth.auth().signOut()
                self.performSegue(withIdentifier: "moveToLoginVC100", sender: nil)
                
            } else {
                self.performSegue(withIdentifier: "moveToMainVC", sender: nil)
            }
            
            
            
        }
        
        
        
    }
    
    

}
