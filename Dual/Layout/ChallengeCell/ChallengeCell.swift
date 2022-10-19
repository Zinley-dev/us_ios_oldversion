//
//  ChallengeCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/1/21.
//

import UIKit
import AlamofireImage
import Alamofire
import AsyncDisplayKit

class ChallengeCell: UICollectionViewCell {

    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var gameName: UILabel!
    var imageNode = ASNetworkImageNode()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    
    func configureCell(_ Information: String) {
        
      
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("short_name", isEqualTo: Information).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for item in snap!.documents {
                
                if let url = item.data()["url"] as? String {
                  
                    imageStorage.async.object(forKey: url) { result in
                        if case .value(let image) = result {
                            
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                
                                
                                self.gameImg.image = image
                                
                                //try? imageStorage.setObject(image, forKey: url)
                                
                            }
                            
                        } else {
                            
                            
                         AF.request(url).responseImage { response in
                                
                                
                                switch response.result {
                                case let .success(value):
                                    self.gameImg.image = value
                                   
                                    try? imageStorage.setObject(value, forKey: url)
                                case let .failure(error):
                                    print(error)
                                }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                   
                    
                }
                
                
                if let short_name = item.data()["short_name"] as? String {
                    
                    self.gameName.text = short_name
                    
                } else  {
                    self.gameName.text = "UNK"
                }
                
                
                
            }
            
            
        }
          
    }
    
    

}
