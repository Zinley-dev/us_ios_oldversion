//
//  forgetWithPhoneView.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit

class forgetWithPhoneView: UIView {

    @IBOutlet weak var areaCodeBtn: UITextField!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var GetCodeBtn: UIButton!
    @IBOutlet weak var usernameLbl: UITextField!
    
    @IBOutlet weak var PhoneNumberLbl: UITextField!
    
    let kCONTENT_XIB_NAME = "forgetWithPhoneView"
     
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
