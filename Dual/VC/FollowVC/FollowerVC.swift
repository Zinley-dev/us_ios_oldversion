//
//  FollowerVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/23/21.
//

import UIKit
import FLAnimatedImage

class FollowerVC: UIViewController {
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var nickname: String?
    var uid: String?
    var followerCount = 0
    var followingCount = 0
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    var isMain = false
    var followerBorder = CALayer()
    var followingBorder = CALayer()
    
    
    lazy var FollowerViewController: FollowerViewController = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowerViewController") as? FollowerViewController {
                    
            controller.uid = uid
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! FollowerViewController
        }
       
        
    }()
    
    lazy var FollowingViewController: FollowingViewController = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "FollowingViewController") as? FollowingViewController {
            
            
            controller.uid = uid
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! FollowingViewController
        }
                
        
    }()

    @IBOutlet weak var nicknameLbl: UILabel!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var widthConstant: NSLayoutConstraint!
    
    var disappear = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        FollowerViewController.view.isHidden = false
        FollowingViewController.view.isHidden = true
        
        if nickname != nil, uid != nil {
            
            self.nicknameLbl.text = nickname
            if followerCount == 0 {
                followerBtn.setTitle("0 Follower", for: .normal)
            } else {
                followerBtn.setTitle("\(formatPoints(num: Double(followerCount))) Followers", for: .normal)
            }
            
            
            if followingCount == 0 {
                followingBtn.setTitle("0 Following", for: .normal)
            } else {
                followingBtn.setTitle("\(formatPoints(num: Double(followingCount))) Following", for: .normal)
            }
          
            
        }
        
        followerBorder = followerBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (160/414))
        followingBorder = followingBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (160/414))
        followerBtn.layer.addSublayer(followerBorder)
        
        //
        widthConstant.constant = self.view.frame.width * (160/414)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
        
        delay(1.25) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
   
    func updateFollowerCount() {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: uid!).whereField("status", isEqualTo: "Valid").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                
                self.followerBtn.setTitle("0 Follower", for: .normal)
                
            } else {
                
      
                self.followerBtn.setTitle("\(formatPoints(num: Double(snapshot.count))) Followers", for: .normal)
               
              
            }
            
            
        }
        
        
    }
    
    
    func updateFollowingCount() {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: uid!).whereField("status", isEqualTo: "Valid").getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                
                self.followingBtn.setTitle("0 Following", for: .normal)
                
            } else {
                
                
                self.followingBtn.setTitle("\(formatPoints(num: Double(snapshot.count))) Following", for: .normal)
               
              
            }
            
            
        }
        
        
    
    }
    
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    @IBAction func followerBtnPressed(_ sender: Any) {
        
        
        followingBorder.removeFromSuperlayer()
        followerBtn.layer.addSublayer(followerBorder)
        followerBtn.setTitleColor(UIColor.white, for: .normal)
        followingBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        FollowerViewController.view.isHidden = false
        FollowingViewController.view.isHidden = true
        
    }
    
    @IBAction func followingBtnPressed(_ sender: Any) {
        
        
        followerBorder.removeFromSuperlayer()
        followingBtn.layer.addSublayer(followingBorder)
        followerBtn.setTitleColor(UIColor.lightGray, for: .normal)
        followingBtn.setTitleColor(UIColor.white, for: .normal)
        
        FollowerViewController.view.isHidden = true
        FollowingViewController.view.isHidden = false
    }
    
}
