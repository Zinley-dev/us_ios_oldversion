//
//  ReferralCodeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/23/21.
//

import UIKit
import Firebase
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices
import AlamofireImage
import Alamofire

class ReferralCodeVC: UIViewController, ZSWTappableLabelTapDelegate {
    
    

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var referralCode: UIButton!
    @IBOutlet weak var dualreferralcodepolicy: ZSWTappableLabel!
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
        case Privacy = "Privacy"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "https://dual.live")!
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dualreferralcodepolicy.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                ReferralCodeVC.URLAttributeName: type.URL
            ]
        })

        
        let string = NSLocalizedString("Learn more about the Dual referral program by click \n <link type='Privacy'>the Dual referral program policy</link>.", comment: "")
        
        
        
        
        dualreferralcodepolicy.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        dualreferralcodepolicy.isUserInteractionEnabled = true
        
        loadcode()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //imageHeight.constant = self.view.frame.height * (250/707)
        
        self.avatarImage.borderColors = selectedColor
        
        if global_avatar_url != "" {
            
            imageStorage.async.object(forKey: global_avatar_url) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.avatarImage.image = image
                        
                    }
                    
                } else {
                    
                    
                 AF.request(global_avatar_url).responseImage { response in
                        
                        switch response.result {
                        case let .success(value):
                            
                            self.avatarImage.image = value
                            try? imageStorage.setObject(value, forKey: global_avatar_url, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                            
                        case let .failure(error):
                            print(error)
                        }
                        

                    }
                    
                }
                
            }
            
            
            
        }
        
    }
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
       
        guard let URL = attributes[ReferralCodeVC.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            show(SFSafariViewController(url: URL), sender: self)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    
    
    func loadcode() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let referral_code = item["referral code"] as? String, referral_code != "" {
                        
                       
                        self.referralCode.setTitle(referral_code, for: .normal)
                       
                    } else {
                        
                        
                        self.create_Code_And_Update(id: snapshot.documentID)
                        
                        
                    }
                    
                    
                }
                
            }
            
            
            
        }
        
     
    }
    
    @IBAction func referalCodeBtnPressed2(_ sender: Any) {
        
        if let text = referralCode.titleLabel?.text, text != "", text != "Referral code" {
            
            UIPasteboard.general.string = text
            showNote(text: "Referral code is copied")
            
        } else {
            
            showNote(text: "Error: can't copy code")
            
        }
        
    }
    func create_Code_And_Update(id: String) {
        
        
        let hashids = Hashids(salt: Auth.auth().currentUser!.uid);
        let hash = hashids.encode(1, 2, 3);
        
        
        referralCode.setTitle(hash, for: .normal)
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(id).updateData(["referral code": hash!])
        
        
    }
    
    
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func referalCodeBtnPressed(_ sender: Any) {
        
        if let text = referralCode.titleLabel?.text, text != "", text != "Referral code" {
            
            UIPasteboard.general.string = text
            showNote(text: "Referral code copied")
            
        } else {
            
            showNote(text: "Error: can't copy code")
            
        }
        
        
    }
    
}
