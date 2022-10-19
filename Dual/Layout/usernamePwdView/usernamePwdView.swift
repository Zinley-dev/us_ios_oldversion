//
//  usernamePwdView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit

class usernamePwdView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var passwordBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var userNameCheck: UIImageView!
    @IBOutlet weak var pwdLbl: UITextField!
    @IBOutlet weak var usernameLbl: UITextField!
    let kCONTENT_XIB_NAME = "usernamePwdView"
     
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
