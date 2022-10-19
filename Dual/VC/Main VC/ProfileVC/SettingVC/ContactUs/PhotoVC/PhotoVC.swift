//
//  PhotoVC.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/24/21.
//

import UIKit

class PhotoVC: UIViewController {

    
    var selectedImg: UIImage!
    var selectedIndex: Int!
    @IBOutlet weak var selectedImgView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let img = selectedImg {
            
            
            selectedImgView.image = img
            
        }
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func DeleteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
}
