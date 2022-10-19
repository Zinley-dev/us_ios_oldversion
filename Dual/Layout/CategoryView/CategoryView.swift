//
//  CategoryView.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/25/22.
//

import UIKit

class CategoryView: UIView {

    let kCONTENT_XIB_NAME = "CategoryView"
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var CategoryImg: UIImageView!
    @IBOutlet weak var CategoryLbl: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
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
