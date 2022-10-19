//
//  DetailView.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/24/20.
//

import UIKit

class DetailView: UIView {
    
    @IBOutlet weak var challengeCardBtn: UIButton!
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var gameLbl: UILabel!
    @IBOutlet weak var streamLinkLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var hashTagCollectionHeight: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var openCommentBtn: UIButton!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    

   let kCONTENT_XIB_NAME = "DetailView"
    
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
