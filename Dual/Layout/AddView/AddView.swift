//
//  AddView.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/19/22.
//

import UIKit

class AddView: UIView {

    @IBOutlet var contentView: UIView!
    let kCONTENT_XIB_NAME = "AddView"
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var otherImageView: UIImageView!
    @IBOutlet var name: UILabel!
   // @IBOutlet weak var fullName: UILabel!
    @IBOutlet var shadowView: UIView!
    
    @IBOutlet weak var textWidthConstant: NSLayoutConstraint!
 

    
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
