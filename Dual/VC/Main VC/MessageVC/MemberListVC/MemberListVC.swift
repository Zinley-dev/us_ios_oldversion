//
//  MemberListVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 3/28/21.
//

import UIKit
import SendBirdUIKit

class MemberListVC: SBUMemberListViewController {
    
    
    var joinedUserIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //navigationItem.rightBarButtonItem = nil
        
        if let channelLink = self.channelUrl {
            
            if channelLink.contains("challenge") {
                
                rightBarButton = nil
                
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        
    }
    
    override func showInviteUser() {
        
        if let CCV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InviteUserVC") as? InviteUserVC {
                
            for item in memberList {
                
                let uid = item.userId
                joinedUserIds.append(uid)
                
            }
            
            
            CCV.channelUrl = self.channelUrl
            CCV.joinedUserIds = joinedUserIds
            navigationController?.pushViewController(CCV, animated: true)
        }
        
        
    }
    

}
