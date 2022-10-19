//
//  UserProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import CoreLocation
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class UserProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var BigProfileImg: UIImageView!
    @IBOutlet weak var cardHeigh1: NSLayoutConstraint!
    var most_playDict = [String:Int]()
    var final_most_playDict = [Dictionary<String, Int>.Element]()
    var final_most_playList = [String]()
    
    //
    
    lazy var delayItem1 = workItem()
    
    
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var widthconstant: NSLayoutConstraint!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var sideButtonStackView: UIStackView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var rateLbl: UILabel!
    var ChallengeView = ChallengeCard()
    var isRestrict = false
    var isFollow = false
    //
    var getUsername = ""
    var attemptCount = 0
    
    @IBOutlet weak var followHeight: NSLayoutConstraint!
    
    @IBOutlet weak var settingBtn2: UIButton!
    @IBOutlet weak var SettingBtn1: UIButton!
    
    
    @IBOutlet weak var challengeCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followCountView: UIStackView!
    @IBOutlet weak var challengeView: UIStackView!
    
    //
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    var highlightBorder = CALayer()
    var challengeBorder = CALayer()
    var aboutBorder = CALayer()
    
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var highlightsBtn: UIButton!
    
    @IBOutlet weak var avatarImg: borderAvatarView!
    
    
    var collectionNode: ASCollectionNode!

    var nickname = ""
    var discord_url = ""
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var FollowerBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var FollowView: UIView!
    
    
    var followCnt = 0
    var followingCnt = 0

    var uid: String!
    lazy var delayItem = workItem()
    var keyList = [String]()
    
    var Highlight_list = [HighlightsModel]()
    private var pullControl = UIRefreshControl()
    
    
    var Follower_username = ""
    var Follower_name = ""
    
    lazy var videoVC: videoVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoVC") as? videoVC {
            
            
            controller.isTrack = false
            controller.userUID = uid!
            
            if uid == Auth.auth().currentUser?.uid {
                
                controller.ismain = true
            } else {
                controller.ismain = false
            }
            
            
            self.addVCAsChildVC(childViewController: controller)
            
            
            
            return controller
            
        } else {
            return UIViewController() as! videoVC
        }
       
        
    }()
    
    lazy var infoVC: infoVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "infoVC") as? infoVC {
            
            controller.istrack = false
            controller.uid = uid!
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! infoVC
        }
                
        
    }()
    
    lazy var ViewAllChallengeVC: ViewAllChallengeVC = {
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewAllChallengeVC") as? ViewAllChallengeVC {
            controller.viewUID = uid!
            controller.type = "Expired"
            self.addVCAsChildVC(childViewController: controller)
            
            controller.enabledSetting = false
            controller.dismissBtn1.isHidden = true
            controller.dismissBtn2.isHidden = true
            controller.topConstraint.constant = -70.0
            controller.challengeTitle.isHidden = true
            
            return controller
            
        } else {
            return UIViewController() as! ViewAllChallengeVC
        }
                
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if uid != nil, !global_block_list.contains(uid!), uid != "" {
            

            if uid != nil {
                
                avatarImg.contentMode = .scaleAspectFill
                
                loadProfile(uid: uid)
              
                let imageTap = UITapGestureRecognizer(target: self, action: #selector(UserProfileVC.showProfileImage))
                avatarImg.isUserInteractionEnabled = true
                avatarImg.addGestureRecognizer(imageTap)
                            
                
            } else {
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
            // layout message btn
            
            self.messageBtn.backgroundColor = UIColor.clear
            self.messageBtn.layer.borderWidth = 1.0
            self.messageBtn.layer.borderColor = UIColor.dimmedLightBackground.cgColor
            self.messageBtn.clipsToBounds = true
            
        } else {
            
            hideAllView()
            
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageHeight.constant = self.view.frame.height * (250/707)
        
    }
    
    @objc func showProfileImage() {
        
        self.backgroundView.isHidden = false
        self.BigProfileImg.alpha = 1.0
        self.BigProfileImg.image = self.avatarImg.image
        self.BigProfileImg.borderColors = selectedColor
        
        UIView.transition(with: self.BigProfileImg, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.BigProfileImg.isHidden = false
            
        })
        
    }
    
    
    @IBAction func openDualCardBtnPressed(_ sender: Any) {
        
        self.backgroundView.isHidden = false
        self.cardView.alpha = 1.0
        
        UIView.transition(with: cardView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.cardView.isHidden = false
        })
        
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }

        if cardView.isHidden == false {
            
           
            if !cardView.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.cardView.alpha = 0
                }) { (finished) in
                    self.cardView.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
            }
            
        } else if BigProfileImg.isHidden == false {
            
            if !BigProfileImg.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.BigProfileImg.alpha = 0
                }) { (finished) in
                    self.BigProfileImg.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
            }
            
        }
        
    }
    
    
    
    func checkRestrict() {
        
        
        if uid != Auth.auth().currentUser?.uid {
            
            DataService.instance.mainFireStoreRef.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Followers").getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    
                    self.isRestrict = false
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty != true {
                    
                    self.isRestrict = true
                    
                } else {
                    
                    self.isRestrict = false
                    
                }
                
            }
            
            
            
            
        }
        

        
    }

    
    func getstar(uid: String) {
        
        DataService.instance.mainFireStoreRef.collection("Challenge_rate").whereField("to_uid", isEqualTo: uid).limit(to: 200).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            if snapshot.isEmpty != true {
                
                var rate_lis = [Int]()
                
                for item in snapshot.documents {
                    
                    if let current_rate = item.data()["rate_value"] as? Int {
                        
                        
                        rate_lis.append(current_rate)
                        
                    }
                    
                }
               
                
                let average = calculateMedian(array: rate_lis)
                self.rateLbl.isHidden = false
                self.rateLbl.text = " \(String(format:"%.1f", average))"
               
                
            } else {
                
                self.rateLbl.isHidden = true
                
            }
            
            
        }
        
        
    }
    
    
    
    
    @objc func didTapFollow(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "moveToFollowVC2", sender: nil)
    }
    
    func makeGradientViewForUsername(username: String) {
        
        getUsername = username
        
        usernameLbl.text = "@\(username)"
        usernameLbl.sizeToFit()
        
        // Create a gradient layer
        let gradient = CAGradientLayer()

        // gradient colors in order which they will visually appear
        gradient.colors = [selectedColor.cgColor, movedColor.cgColor]

        // Gradient from left to right
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        // set the gradient layer to the same size as the view
        gradient.frame = usernameLbl.bounds
        // add the gradient layer to the views layer for rendering
        usernameLbl.layer.addSublayer(gradient)
        
        
        // Create a label and add it as a subview
        let label = UILabel(frame: usernameLbl.bounds)
        label.text = "@\(username)".lowercased()
        label.font = .robotoRegular(size: 20)
        label.textAlignment = .center
        usernameLbl.addSubview(label)

        // Tha magic! Set the label as the views mask
        usernameLbl.mask = label
        
        
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
    
    func setupView() {
        
        
        self.highlightBorder = self.highlightsBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        self.challengeBorder = self.challengeBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        self.aboutBorder = self.aboutBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        
        //
        
        self.highlightsBtn.layer.addSublayer(self.highlightBorder)
        
    }
    
    // setting button
    @IBAction func setting1BtnPressed(_ sender: Any) {
        
        
        if uid == Auth.auth().currentUser?.uid {
            
            self.performSegue(withIdentifier: "moveToSettingVC2", sender: nil)
            
        } else {
            
            setting()
            
        }
            
    }
    
    @IBAction func setting2BtnPressed(_ sender: Any) {
        
        if uid == Auth.auth().currentUser?.uid {
            
            self.performSegue(withIdentifier: "moveToSettingVC2", sender: nil)
            
        } else {
            
            setting()
            
        }
        
    }
    
    func setting() {
        
        if getUsername != "" {
            
           
            
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let profile = UIAlertAction(title: "Copy profile", style: .default) { (alert) in
                
                if let id = self.uid {
                 
                    let link = "https://dualteam.page.link/dual?up=\(id)"
                    UIPasteboard.general.string = link
                    showNote(text: "User profile link is copied")
                    
                }
                
            }
            
            let report = UIAlertAction(title: "Report", style: .destructive) { (alert) in
                
                let slideVC =  reportView()
                
                slideVC.user_report = true
                slideVC.user_id = self.uid!
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self

                self.present(slideVC, animated: true, completion: nil)
                
                
            }
            
            let block = UIAlertAction(title: "Block", style: .destructive) { (alert) in
                
                self.confirmBlock()
                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                
            }
            
            
            sheet.addAction(profile)
            sheet.addAction(report)
            sheet.addAction(block)
            sheet.addAction(cancel)

            
            self.present(sheet, animated: true, completion: nil)
            
            
        }
        
       
        
    }
    
    func confirmBlock() {
        
        let alert = UIAlertController(title: "Are you sure to block \(getUsername)!", message: "If you confirm to block, you can always unblock \(getUsername) from your block list any time.", preferredStyle: UIAlertController.Style.actionSheet)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Block", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.initBlock(uid: self.uid)
    
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func removeFollowFromCurrentUser() {
        
        
        DataService.instance.mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Following_uid", isEqualTo: uid!).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Follow").document(id).delete()
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    func removeFollowFromUID() {
        
        
        DataService.instance.mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: uid!).whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Follow").document(id).delete()
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    
    func addToBlockList() {
        
        
        DataService.init().mainFireStoreRef.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Block_uid", isEqualTo: uid!).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.addToList()
                
            } else {
                print("Already block! \(self.uid!)")
            }
                
            
        }
        
        
        
   
    }
    
    func addToList() {
        
        
        let db = DataService.init().mainFireStoreRef.collection("Block")
        
        let data = ["User_uid": Auth.auth().currentUser!.uid as Any, "Block_uid": uid as Any, "block_time": FieldValue.serverTimestamp()]
        
        db.addDocument(data: data) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
        }
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        
        //isBack = true
        
        if global_block_list.contains(uid!) {
            
            NoticeBlockAndDismiss()
            
        }
        
        
        
    }
    
    
    func countFollow(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: uid).whereField("status", isEqualTo: "Valid").getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.followCount.text = "0"
                self.followCnt = 0
            
            } else {
                
                self.followCount.text = "\(formatPoints(num: Double(snapshot.count)))"
                self.followCnt = snapshot.count
                
            }
            
            
        }
        
    }
    
    func countFollowing(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: uid).whereField("status", isEqualTo: "Valid").getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
              
                self.followingCnt = 0
            
            } else {
                
                
                self.followingCnt = snapshot.count
                
            }
            
            
        }
        
    }
    
    func countChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("isAccepted", isEqualTo: true).whereField("current_status", isEqualTo: "Valid").whereField("uid_list", arrayContains: uid)
            
            .getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                let fullString = NSMutableAttributedString(string: "")
                let image1Attachment = NSTextAttachment()
                image1Attachment.image = UIImage(named: "challenge")?.resize(targetSize: CGSize(width: 20, height: 20))
                image1Attachment.bounds = CGRect(x: 0, y: -6, width: 20, height: 20)
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullString.append(image1String)
                
                if snapshot.isEmpty == true {
                    
                    fullString.append(NSAttributedString(string: " 0"))
                    
                    self.challengeCount.text = "0"
                    self.ChallengeView.challengeCount.attributedText = fullString
                    
                } else {
                    
                    fullString.append(NSAttributedString(string: " \(formatPoints(num: Double(snapshot.count)))"))
                    
                    self.challengeCount.text = "\(formatPoints(num: Double(snapshot.count)))"
                    self.ChallengeView.challengeCount.attributedText = fullString
                }
                
            }
    }
 
  
    func addFollow(Follower_username: String, Follower_name: String) {
        
        let db = DataService.init().mainFireStoreRef.collection("Follow")
        
        let data = ["Following_uid": Auth.auth().currentUser!.uid as Any, "Follower_uid": self.uid! as Any, "follow_time": FieldValue.serverTimestamp(), "status": "Valid", "Follower_username": Follower_username, "Follower_name": Follower_name, "Following_username": global_username, "Following_name": global_name, "global_documentID": Auth.auth().currentUser!.uid]
        
        db.addDocument(data: data) { (err) in
            if err != nil {
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                
            } else {
                
                
                ActivityLogService.instance.UpdateFollowActivityLog(mode: "Follow", toUserUID: self.uid!)
                ActivityLogService.instance.UpdateFollowNotificationLog(userUID: self.uid!, fromUserUID: Auth.auth().currentUser!.uid, Field: "Follow")
                
                InteractionLogService.instance.UpdateLastedInteractUID(id: self.uid!)
                // UI
                self.FollowerBtn.backgroundColor = UIColor.clear
                self.FollowerBtn.layer.borderWidth = 1.0
                self.FollowerBtn.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.FollowerBtn.clipsToBounds = true
                self.FollowerBtn.setTitle("Following", for: .normal)
                self.FollowerBtn.setTitleColor(UIColor.white, for: .normal)
                self.FollowerBtn.isHidden = false
                self.FollowerBtn.isEnabled = true
                self.messageBtn.isHidden = false
                
                //addFollowPostIntoFollowee(targetUID: self.uid!)
                
                addToAvailableChatList(uid: [self.uid!])
                
            }
        }
        
    }
    
    
    func unfollow() {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Follower_uid", isEqualTo: uid!).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                
                for item in snapshot.documents {
                    
                    
                    let key = item.documentID
                    
                    DataService.init().mainFireStoreRef.collection("Follow").document(key).delete {  (err) in
                        if err != nil {
                            self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                            return
                        }
                        
                       // self.videoVC.isFollow = false
                        
                        if self.isRestrict {
                            //self.videoVC.refreshRequest()
                        }
                        
                        //UI
                        self.FollowerBtn.backgroundColor = selectedColor
                        self.FollowerBtn.layer.borderWidth = 0.0
                        self.FollowerBtn.layer.borderColor = UIColor.clear.cgColor
                        self.FollowerBtn.clipsToBounds = true
                        self.FollowerBtn.setTitle("Follow", for: .normal)
                        self.FollowerBtn.setTitleColor(UIColor.black, for: .normal)
                        self.FollowerBtn.isHidden = false
                        self.messageBtn.isHidden = true
                        self.FollowerBtn.isEnabled = true
                       
                        //removeFollowPostIntoFollowee(targetUID: self.uid!)
                        ActivityLogService.instance.UpdateFollowActivityLog(mode: "Unfollow", toUserUID: self.uid!)
                        
                        
                        
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func checkIfUserDidFollowMe() {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: uid!).whereField("Follower_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.FollowerBtn.isHidden = false
                self.FollowerBtn.setTitle("Follow", for: .normal)
                self.FollowerBtn.setTitleColor(UIColor.black, for: .normal)
                self.FollowerBtn.backgroundColor = selectedColor
                self.FollowerBtn.layer.borderWidth = 0.0
                self.FollowerBtn.layer.borderColor = UIColor.clear.cgColor
                self.FollowerBtn.clipsToBounds = true
                self.messageBtn.isHidden = true
            
            } else {
                
                self.FollowerBtn.isHidden = false
                self.FollowerBtn.setTitle("Follow back", for: .normal)
                self.FollowerBtn.setTitleColor(UIColor.black, for: .normal)
                self.FollowerBtn.backgroundColor = selectedColor
                self.FollowerBtn.layer.borderWidth = 0.0
                self.FollowerBtn.layer.borderColor = UIColor.clear.cgColor
                self.FollowerBtn.clipsToBounds = true
                self.messageBtn.isHidden = true
            }
            
            
        }
        
    }
    
    func checkIfFollowing() {
        
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Follower_uid", isEqualTo: uid!).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.videoVC.isFollow = false
                self.videoVC.startLoading()
                
                self.checkIfUserDidFollowMe()
            
            } else {
                
                self.isFollow = true
                
                self.videoVC.isFollow = true
                self.videoVC.startLoading()
                
                
                self.messageBtn.isHidden = false
                self.FollowerBtn.backgroundColor = UIColor.clear
                self.FollowerBtn.layer.borderWidth = 1.0
                self.FollowerBtn.layer.borderColor = UIColor.dimmedLightBackground.cgColor
                self.FollowerBtn.clipsToBounds = true
                self.FollowerBtn.setTitle("Following", for: .normal)
                self.FollowerBtn.setTitleColor(UIColor.white, for: .normal)
                self.FollowerBtn.isHidden = false
                
              
                
            }
            
            
        }
        
        
    }

    
    func setupChallengeView(){
        
        var newHeight = (self.view.bounds.height - 83) * (230/759)
        if newHeight > 235 {
            newHeight = 240
        } else if newHeight < 235, newHeight > 179 {
            newHeight = 230
        } else {
            newHeight = 220
        }
        
        cardHeigh1.constant = newHeight
        
        self.cardView.frame = CGRect(x: 0, y: 0, width: self.cardView.bounds.width, height: newHeight)
        
        
        ChallengeView.collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
       
        
        ChallengeView.collectionView.delegate = self
        ChallengeView.collectionView.dataSource = self
       
        
        //
        self.cardView.addSubview(ChallengeView)
        
        cardView.backgroundColor = UIColor.red
        

        ChallengeView.frame = self.cardView.frame
       
    
        ChallengeView.badgeWidth.constant = self.view.bounds.width * (150/428)
        ChallengeView.infoHeight.constant = self.view.bounds.height * (24/759)
        ChallengeView.userImgWidth.constant = self.view.bounds.width * (85/428)
        ChallengeView.userImgHeight.constant = self.view.bounds.width * (85/428)
        
    
        
  
    }
    
    
    func loadMostPlayedList(uid: String) {
        
        
        //MostPlayed_history
        let db = DataService.instance.mainFireStoreRef
    
        
        db.collection("MostPlayed_history").whereField("userUID", isEqualTo: uid).limit(to: 500)
            
            .getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                self.most_playDict.removeAll()
                
                for item in snapshot.documents {
                    
                    if let category = item.data()["category"] as? String, category != "Others" {
                        
                        if self.most_playDict[category] == nil {
                            self.most_playDict[category] = 1
                        } else {
                            if let val = self.most_playDict[category] {
                                self.most_playDict[category] = val + 1
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
            
                let dct = self.most_playDict.sorted(by: { $0.value > $1.value })
                self.final_most_playDict = dct
                
                
                self.final_most_playList.removeAll()
                var count = 0
                
                for (key, _) in self.final_most_playDict {
                    
                    if count < 4 {
                        self.final_most_playList.append(key)
                        count += 1
                    } else {
                        break
                    }
                    
                    
                }
                
                
                self.ChallengeView.collectionView.reloadData()

            }
        
   
        
    }
   
    func loadProfile(uid: String) {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let is_suspend = item["is_suspend"] as? Bool {
                        
                        if is_suspend == false {
                            
                            
                            self.loadMostPlayedList(uid: uid)
                            self.delayItem.perform(after: 0.25) {
                                
                               
                                self.setupChallengeView()
                                
                            }
                            
                            
                            self.widthconstant.constant = self.view.frame.width * (120/414)
                            
                            self.setupView()
                            
                            self.stackview.spacing = self.view.bounds.width * (35/414)
                            
                            //
                            
                            let followGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapFollow(_:)))

                            // Configure Tap Gesture Recognizer
                            followGestureRecognizer.numberOfTapsRequired = 1

                            // Add Tap Gesture Recognizer
                            self.followCountView.addGestureRecognizer(followGestureRecognizer)
                            
                            self.contentView.isHidden = false
                            
                            self.videoVC.view.isHidden = false
                            self.infoVC.view.isHidden = true
                            self.ViewAllChallengeVC.view.isHidden = true
                            
                            
                            
                            if uid == Auth.auth().currentUser?.uid {
                                
                                self.FollowView.isHidden = true
                                self.followHeight.constant = 0.0
                                self.videoVC.startLoading()
                                
                            } else {
                                
                                self.FollowView.isHidden = false
                                self.followHeight.constant = 40.0
                                self.checkIfFollowing()
                            }
                            
                            
                            self.countFollow(uid: uid)
                            self.countFollowing(uid: uid)
                            self.countChallenge(uid: uid)
                            self.getstar(uid: uid)
                            self.checkRestrict()
                            
                           
                            self.assignProfile (item: snapshot.data()!)
                            
                        } else {
                            
                            self.hideAllView()
                            
                        }
                        
                    } else {
                        
                        self.hideAllView()
                        
                    }
                    
                } else {
                    
                    self.hideAllView()
                    
                }
                
            } else {
                
                self.hideAllView()
                
            }
            
            
            
        }
        
      
    }
    
    func hideAllView() {
        
        contentView.isHidden = true
        settingBtn2.isEnabled = false
        SettingBtn1.isEnabled = false
        challengeBtn.isEnabled = false
        highlightsBtn.isEnabled = false
        aboutBtn.isEnabled = false
        sideButtonStackView.isHidden = true
        //
        
        followCountView.isHidden = true
        challengeView.isHidden = true
        
    }
    
    
    
    
    func assignProfile(item: [String: Any]) {
        
        if let username = item["username"] as? String, let name = item["name"] as? String, let avatarUrl = item["avatarUrl"] as? String, let create_time = item["create_time"] as? Timestamp  {
            
           
            nameLbl.text = name
           
            makeGradientViewForUsername(username: username)
            nickname = username
            
        
            ChallengeView.username.text = username
            
            let DateFormatter = DateFormatter()
            DateFormatter.dateStyle = .medium
            DateFormatter.timeStyle = .none
            ChallengeView.startTime.text = DateFormatter.string(from: create_time.dateValue())
            
            
            
            imageStorage.async.object(forKey: avatarUrl) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        
                        self.avatarImg.image = image
                        self.ChallengeView.userImgView.image = image
                       
                        
                    }
                    
                } else {
                    
                    
                 AF.request(avatarUrl).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):
                            
                            
                            self.avatarImg.image = value
                            self.ChallengeView.userImgView.image = value
                            try? imageStorage.setObject(value, forKey: avatarUrl)
                        case let .failure(error):
                            print(error)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
        
        }
        
        
        if let challenge_info = item["challenge_info"] as? String {
            
            if challenge_info != "nil" {
                
                ChallengeView.infoLbl.text = challenge_info
                
            } else {
                
                ChallengeView.infoLbl.text = "Dual's challenger"
            }
            
        } else {
            
            ChallengeView.infoLbl.text = "Dual's challenger"
            
        }
        
        
        if let DiscordStatus = item["DiscordStatus"] as? Bool {
            
            if DiscordStatus == true {
                
                if let discord_link = item["discord_link"] as? String, discord_link != "nil", discord_link != "" {
                    
                    discordBtn.isHidden = false
                    discord_url = discord_link
                    
                } else {
                    
                    discordBtn.isHidden = true
                    
                }
                
            } else {
                
                
                discordBtn.isHidden = true
                
            }
            
       
        } else {
            
            discordBtn.isHidden = true
            
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
       
        return final_most_playList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCell.cellReuseIdentifier(), for: indexPath)) as! ChallengeCell
        let item = final_most_playList[indexPath.row]
        
        
        cell.cornerRadius = (collectionView.layer.frame.height - 5) / 2
        cell.configureCell(item)
        
        return cell
    
  
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = final_most_playList[indexPath.row]
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MostPlayVideoVC") as? MostPlayVideoVC {
            
            controller.modalPresentationStyle = .fullScreen
            controller.selected_category = item
            controller.selected_userUID = uid
            
            self.present(controller, animated: true, completion: nil)
            
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.layer.frame.height - 5, height: collectionView.layer.frame.height - 5)
          
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
                                                                                                                    
        
    }

    
    // prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToUserHighlightVC"{
            if let destination = segue.destination as? UserHighlightFeedVC
            {
            
                destination.item_id_list = self.keyList
                              
            }
        } else if segue.identifier == "moveToViewAllChallenge3"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.viewUID = uid
                
            }
        } else if segue.identifier == "moveToFollowVC2" {
            
            if let destination = segue.destination as? FollowerVC {
                
                destination.uid = uid
                destination.nickname = nickname
                destination.followerCount = followCnt
                destination.followingCount = followingCnt
                
            }
            
        }
        
    }
    
  

    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func followAction(_ sender: Any) {
        
        if FollowerBtn.titleLabel?.text != "" {
            
            self.FollowerBtn.isEnabled = false
            
            delayItem1.perform(after: 0.25) {
                
                self.attemptCount += 1
                
                if self.attemptCount <= 3 {
                    
                    if self.FollowerBtn.titleLabel?.text == "Follow" {
                        
                        self.performCheckAndAdFollow()
                
                    } else if self.FollowerBtn.titleLabel?.text == "Follow back" {
                        
                        self.performCheckAndAdFollow()
                        
                    } else if self.FollowerBtn.titleLabel?.text == "Following" {
                     
                        self.unfollow()
                        
                    }
                    
                    
                } else {
                    
                    
                    self.showErrorAlert("Oops!", msg: "The system detects some unusual actions, the follow function is temporarily disabled. Please contact our support for more information.")
                    
                    
                }
                
                
                
            }
            
            
            
        }
        
    }
    
    
    func performCheckAndAdFollow() {
        
        if global_block_list.contains(uid) == false {
            
            let db = DataService.instance.mainFireStoreRef
            
            db.collection("Users").document(uid!).getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let is_suspend = item["is_suspend"] as? Bool {
                            
                            if is_suspend == false {
                                
                                
                                if let username = item["username"] as? String, let name = item["name"] as? String {
                                    
                                    
                                    self.addFollow(Follower_username: username, Follower_name: name)
                                    
                                }
                              
                                
                            } else {
                                
                                self.showErrorAlert("Oops!", msg: "You can't perform this action now!")
                                
                            }
                            
                        } else {
                            
                            self.showErrorAlert("Oops!", msg: "You can't perform this action now!")
                           
                        }
                        
                    }
                    
                }
                
                
                
                
                
            }
            
            
            
        }
        
        
        
        
    }
 
    @IBAction func messageBtnPressed(_ sender: Any) {
        
        let channelParams = SBDGroupChannelParams()
        channelParams.isDistinct = true
        channelParams.addUserId(uid)
        channelParams.addUserId(Auth.auth().currentUser!.uid)
        
        
        
        SBDGroupChannel.createChannel(with: channelParams) { (groupChannel, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            let channelUrl = groupChannel?.channelUrl
            
            let channelVC = ChannelViewController(
                                channelUrl: groupChannel!.channelUrl,
                                messageListParams: nil
                            )
                                        
            let navigationController = UINavigationController(rootViewController: channelVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            addToAvailableChatList(uid: [self.uid])
            
            if let channel = groupChannel {
                
                for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                              
                    if item.userId != Auth.auth().currentUser?.uid {
                       
                        if item.state != .joined {
                            
                            self.acceptInviation(channelUrl: channelUrl!, user_id: self.uid)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
    }
    
    func acceptInviation(channelUrl: String, user_id: String) {
        
        // perform admin post
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_accept_invitation")
        
        AF.request(urlss!, method: .post, parameters: [
            
            "channel_url": channelUrl,
            "user_id": user_id
            
        
            ])
            
            .validate(statusCode: 200..<500)
            
        
        
    }
    
   

    
    @IBAction func highlightBtnPressed(_ sender: Any) {
        
        challengeBorder.removeFromSuperlayer()
        aboutBorder.removeFromSuperlayer()
        highlightsBtn.layer.addSublayer(highlightBorder)
        highlightsBtn.setTitleColor(UIColor.white, for: .normal)
        
        //
        challengeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        aboutBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        //
        
        videoVC.view.isHidden = false
        infoVC.view.isHidden = true
        ViewAllChallengeVC.view.isHidden = true
        
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        
        highlightBorder.removeFromSuperlayer()
        aboutBorder.removeFromSuperlayer()
        challengeBtn.layer.addSublayer(challengeBorder)
        challengeBtn.setTitleColor(UIColor.white, for: .normal)
        
        //
        highlightsBtn.setTitleColor(UIColor.lightGray, for: .normal)
        aboutBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        //
        
        videoVC.view.isHidden = true
        infoVC.view.isHidden = true
        ViewAllChallengeVC.view.isHidden = false
        
    }
    
    @IBAction func aboutBtnPressed(_ sender: Any) {
        
        highlightBorder.removeFromSuperlayer()
        challengeBorder.removeFromSuperlayer()
        aboutBtn.layer.addSublayer(highlightBorder)
        aboutBtn.setTitleColor(UIColor.white, for: .normal)
        
        //
        highlightsBtn.setTitleColor(UIColor.lightGray, for: .normal)
        challengeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        //
        
        videoVC.view.isHidden = true
        infoVC.view.isHidden = false
        ViewAllChallengeVC.view.isHidden = true
        
    }
    
    
    @IBAction func discordBtnPressed(_ sender: Any) {
        
        openLink(link: discord_url)
        
    }
    
 
    
    func openLink(link: String) {
        
        if link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't open this link")
            
        }

    }
    
    
    func NoticeBlockAndDismiss() {
        
        let sheet = UIAlertController(title: "Oops!", message: "This user isn't available now.", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Got it", style: .default) { (alert) in
            
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
        sheet.addAction(ok)

        
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func initBlock(uid: String) {
        
        
        SBDMain.blockUserId(uid) { blockedUser, error in
            
            if error != nil {
                
                self.showErrorAlert("Oops!", msg: "User can't be blocked now due to internal error from our SB system, please try again")
                
            } else {
                
                self.removeFollowFromCurrentUser()
                self.removeFollowFromUID()
                self.addToBlockList()
             
            }
            
        }
        

        
    }
    
}


