//
//  CommentView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/5/21.
//

import UIKit

class CommentView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var CmtLbl: UITextView!
    @IBOutlet weak var ReplyLbl: UILabel!
    @IBOutlet weak var LikeCount: UILabel!
    
     
    let kCONTENT_XIB_NAME = "CommentView"
     
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
