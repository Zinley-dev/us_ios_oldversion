//
//  ChallengeView.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/19/22.
//

import UIKit

class ChallengeView: UIView {

    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    let kCONTENT_XIB_NAME = "ChallengeView"
    @IBOutlet var contentView: UIView!
    
    
   
    
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
