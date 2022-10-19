//
//  LoginView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import Foundation
import AsyncDisplayKit

class LoginView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var SignUpBtn: UIButton!
    
    @IBOutlet weak var loadingImg: UIImageView!
    
    let kCONTENT_XIB_NAME = "LoginView"
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        
        
    }

    
    
}
