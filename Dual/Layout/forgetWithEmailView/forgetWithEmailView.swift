//
//  forgetWithEmailView.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit

class forgetWithEmailView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var GetCodeBtn: UIButton!
    @IBOutlet weak var usernameLbl: UITextField!
    @IBOutlet weak var emailLbl: UITextField!
    
    let kCONTENT_XIB_NAME = "forgetWithEmailView"
     
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
