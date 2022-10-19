//
//  ContactUsImageCell.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/24/21.
//

import UIKit

class ContactUsImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    
    func configureCell(img: UIImage) {
        
        imgView.image = img
        
        
    }
    
}
