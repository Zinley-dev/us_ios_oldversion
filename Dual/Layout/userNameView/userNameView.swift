//
//  userNameView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/26/20.
//

import UIKit

class userNameView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var usernameLbl: UITextField!
    @IBOutlet weak var forgetBtn: UIButton!
    
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var passwordLbl: UITextField!
    
    let kCONTENT_XIB_NAME = "userNameView"
     
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
