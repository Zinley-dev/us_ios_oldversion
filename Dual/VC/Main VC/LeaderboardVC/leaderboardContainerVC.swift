//
//  leaderboardContainerVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/23/21.
//

import UIKit
import FLAnimatedImage

class leaderboardContainerVC: UIViewController {
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    var leaderboardBorder = CALayer()
    var personalBorder = CALayer()

    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var personalBtn: UIButton!
    @IBOutlet weak var leaderboadBtn: UIButton!
    @IBOutlet weak var widthConstant: NSLayoutConstraint!
    
   
    
    lazy var personalVC: personalVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "personalVC") as? personalVC {
            
            self.addVCAsChildVC(childViewController: controller)

            
            return controller
            
        } else {
            return UIViewController() as! personalVC
        }
       
        
    }()
    
    lazy var leaderboardVC: leaderboardVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "leaderboardVC") as? leaderboardVC {
                  
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! leaderboardVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        leaderboardBorder = leaderboadBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (160/414))
        personalBorder = personalBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (160/414))
        
        //
        leaderboadBtn.layer.addSublayer(leaderboardBorder)
        
        widthConstant.constant = self.view.frame.width * (160/414)
        
        
        leaderboardVC.view.isHidden = false
        personalVC.view.isHidden = true
     
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
    
    @IBAction func leadboardBtnPressed(_ sender: Any) {
        
        personalBorder.removeFromSuperlayer()
        leaderboadBtn.layer.addSublayer(leaderboardBorder)
        leaderboadBtn.setTitleColor(UIColor.white, for: .normal)
        personalBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        //
        leaderboardVC.view.isHidden = false
        personalVC.view.isHidden = true
        
    }
    
    
    @IBAction func personalBtnPressed(_ sender: Any) {
        
        leaderboardBorder.removeFromSuperlayer()
        personalBtn.layer.addSublayer(personalBorder)
        personalBtn.setTitleColor(UIColor.white, for: .normal)
        leaderboadBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        //
        
        
        leaderboardVC.view.isHidden = true
        personalVC.view.isHidden = false
        
        
        
    }
    
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
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
