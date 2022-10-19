//
//  verificationView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//
 
import UIKit

class verificationView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var openKeyBoardBtn: UIButton!
    @IBOutlet weak var label1: RoundedLabel!
    @IBOutlet weak var label2: RoundedLabel!
    @IBOutlet weak var label3: RoundedLabel!
    @IBOutlet weak var label4: RoundedLabel!
    @IBOutlet weak var label5: RoundedLabel!
    @IBOutlet weak var label6: RoundedLabel!
    
    
    @IBOutlet weak var resendCodeBtn: UIButton!
    @IBOutlet weak var verifyBtn: UIButton!
    let kCONTENT_XIB_NAME = "verificationView"
     
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
