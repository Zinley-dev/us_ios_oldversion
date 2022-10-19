//
//  LeaderboardView.swift
//  Dual
//
//  Created by Khoi Nguyen on 5/13/22.
//

import UIKit

class LeaderboardView: UIView {

    
    @IBOutlet weak var ChallengeTextLbl: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var modeImg: UIImageView!
    @IBOutlet weak var pointLbl: UILabel!
    let kCONTENT_XIB_NAME = "LeaderboardView"
    @IBOutlet var contentView: UIView!
    
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
        
            collectionLayout.scrollDirection = .horizontal
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
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
