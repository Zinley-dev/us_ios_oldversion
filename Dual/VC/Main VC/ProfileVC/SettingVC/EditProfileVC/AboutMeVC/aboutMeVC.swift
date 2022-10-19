//
//  aboutMeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 7/24/21.
//

import UIKit
import Firebase

class aboutMeVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var aboutMeTxtView: UITextView!
    
    var refId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        aboutMeTxtView.delegate = self
        
        
        if let uid = Auth.auth().currentUser?.uid {
            
            loadAboutMeProfile(uid: uid)
            
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if aboutMeTxtView.text != "" {
            
            updateBtn.isHidden = false
           
            
        } else {
            
            updateBtn.isHidden = true
        }
        
    }
    
    
    
    func loadAboutMeProfile(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").whereField("userUID", isEqualTo: uid).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    self.refId = item.documentID

                    if let aboutMe = item.data()["aboutMe"] as? String {
                        
                        self.aboutMeTxtView.text = aboutMe
                        
                       
                    }
                    
                    self.aboutMeTxtView.becomeFirstResponder()
                    
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
    
    @IBAction func dismiss1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func dismiss2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        
        if let text = aboutMeTxtView.text, text != "" {
            
            if refId != "" {
                
                DataService.instance.mainFireStoreRef.collection("Users").document(refId).updateData(["aboutMe": text]) { err in
                    
                    if err != nil {
                        self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    }
                    
                    self.view.endEditing(true)
                    self.showErrorAlert("Great!", msg: "Your information is updated.")
                    
                }
                
            } else {
                
                showErrorAlert("Oops!", msg: "Can't update your information right now, please try again.")
            }
            
        }
        
    }
    
}
