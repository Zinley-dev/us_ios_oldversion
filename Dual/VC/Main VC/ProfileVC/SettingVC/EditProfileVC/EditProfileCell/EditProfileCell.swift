//
//  EditProfileCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/3/20.
//

import UIKit

class EditProfileCell: UITableViewCell {

    //@IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var deleteRequestLabel: UILabel!
    
    var info: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(_ Information: String) {
        
        self.info = Information
        name.text = self.info
        
        if self.info == "Account deletion request" {
            
            
            
            if isPending_deletion == true {
                
                deleteRequestLabel.text = "Cancel account deletion"
                
            } else {
                
                deleteRequestLabel.text = "Account deletion request"
                
            }
            
            deleteRequestLabel.isHidden = false
            name.isHidden = true
            //icon.isHidden = true
               
        } else {
            
            deleteRequestLabel.isHidden = true
            name.isHidden = false
            //icon.isHidden = false
            
            if self.info == "General information" {
                
                //icon.image = UIImage(named: "SelectedOnlyMe")
                
            } else if self.info == "Password" {
                
                //icon.image = UIImage(named: "Icon awesome-lock")
                
            } else if self.info == "About me" {
                
                //icon.image = UIImage(named: "calendar")
                
            } else {
                
                //icon.image = UIImage(named: "\(Information)")
                
            }
            
        }
        
        
        
    }

}
