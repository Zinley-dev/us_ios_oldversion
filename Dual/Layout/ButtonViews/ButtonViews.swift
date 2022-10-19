//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class ButtonViews: UIView {
    
    
    @IBOutlet weak var challengeHeight: NSLayoutConstraint!
   
    
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var shawdowView: UIView!
    @IBOutlet weak var controlAction: UIButton!
    
    
    @IBOutlet weak var controlHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var botConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowHeight: NSLayoutConstraint!
    @IBOutlet weak var moveStackView: UIStackView!
    @IBOutlet weak var viewStackView: UIStackView!
    @IBOutlet weak var likeStackView: UIStackView!
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var viewBtn: UIButton!
    
    @IBOutlet weak var viewLbl: UILabel!
    @IBOutlet weak var shareStackView: UIStackView!
    
    @IBOutlet weak var soundBtn: UIButton!
    @IBOutlet weak var soundLbl: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!

    @IBOutlet weak var shareBtn: UIButton!

    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet var animationView: UIView!
    @IBOutlet var animationImg: UIImageView!
    @IBOutlet var animationTxt: UILabel!
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var commentBtn: UIButton!
    let kCONTENT_XIB_NAME = "ButtonViews"
    
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
