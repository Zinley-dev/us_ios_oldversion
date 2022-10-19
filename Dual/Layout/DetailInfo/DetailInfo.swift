//
//  DetailInfo.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit

class DetailInfo: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var NameLbl: UITextField!
    @IBOutlet weak var BirthdayLbl: UITextField!
    let kCONTENT_XIB_NAME = "DetailInfo"
     
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
