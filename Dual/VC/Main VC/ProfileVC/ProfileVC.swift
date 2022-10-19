//
//  ProfileVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/14/20.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import Alamofire
import SendBirdUIKit
import SendBirdCalls
import PixelSDK
import Photos

class ProfileVC: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var widthconstant: NSLayoutConstraint!
    @IBOutlet weak var rewardBtn: SSBadgeButton!
    @IBOutlet weak var bigProfileImg: UIImageView!
    
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    var followCnt = 0
    var followingCnt = 0
    //
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var rateLbl: UILabel!
    
    @IBOutlet weak var challengeCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followView: UIStackView!
    @IBOutlet weak var challengeView: UIStackView!
   
    
    var highlightBorder = CALayer()
    var challengeBorder = CALayer()
    var aboutBorder = CALayer()
    
    @IBOutlet weak var aboutBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var highlightsBtn: UIButton!
    
    @IBOutlet weak var settingBtn2: UIButton!
    @IBOutlet weak var SettingBtn1: UIButton!
   
    var nickname = ""
    var discord_url = ""
    var firstReload = false
    
    // challenge history
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    var SelectedUserName = ""
    var SelectedAvatarUrl = ""
    var username = ""
    var selectedItem: HighlightsModel!
    
    
    @IBOutlet weak var avatarImg: borderAvatarView!
    @IBOutlet weak var profileImgBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    var Highlight_list = [HighlightsModel]()
    var challenge_list = [ChallengeModel]()
    

    lazy var videoVC: videoVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "videoVC") as? videoVC {
            
           
            controller.isTrack = true
            controller.ismain = true
            controller.userUID = Auth.auth().currentUser?.uid
            
            self.addVCAsChildVC(childViewController: controller)
            
            
            controller.startLoading()
            
            return controller
            
        } else {
            return UIViewController() as! videoVC
        }
       
        
    }()
    
    lazy var infoVC: infoVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "infoVC") as? infoVC {
            
            
            controller.istrack = true
            controller.uid = Auth.auth().currentUser?.uid
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! infoVC
        }
                
        
    }()
    
    lazy var ViewAllChallengeVC: ViewAllChallengeVC = {
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewAllChallengeVC") as? ViewAllChallengeVC {
            controller.viewUID = Auth.auth().currentUser?.uid
            controller.type = "Expired"
            controller.istrack = true
            controller.enabledSetting = true
            self.addVCAsChildVC(childViewController: controller)
            
            controller.dismissBtn1.isHidden = true
            controller.dismissBtn2.isHidden = true
            controller.challengeTitle.isHidden = true
            controller.topConstraint.constant = -70.0
            
            return controller
            
        } else {
            return UIViewController() as! ViewAllChallengeVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
        if let uid = Auth.auth().currentUser?.uid {
            
            loadProfile()
            countChallenge(uid: uid)
            countFollow(uid: uid)
            countFollowing(uid: uid)
            getstar(uid: uid)
          
        }
        
        avatarImg.contentMode = .scaleAspectFill
        
        videoVC.view.isHidden = false
        infoVC.view.isHidden = true
        ViewAllChallengeVC.view.isHidden = true
        
        
        let followGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollow(_:)))

        // Configure Tap Gesture Recognizer
        followGestureRecognizer.numberOfTapsRequired = 1

        // Add Tap Gesture Recognizer
        followView.addGestureRecognizer(followGestureRecognizer)
        
        //
        
        let challengeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChallenge(_:)))

        // Configure Tap Gesture Recognizer
        challengeGestureRecognizer.numberOfTapsRequired = 1

        // Add Tap Gesture Recognizer
        challengeView.addGestureRecognizer(challengeGestureRecognizer)
        
        
        //notificationBtn.badge = "10"
        
        
        widthconstant.constant = self.view.frame.width * (120/414)
        setupView(width: self.view.frame.width * (120/414))
        stackview.spacing = self.view.bounds.width * (35/414)
        
        //
        
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        ViewAllChallengeVC.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstReload == false {
            firstReload = true
            ViewAllChallengeVC.reloadData()
        }
        
        
    }
    

    @objc func didTapFollow(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "moveToFollowListVC", sender: nil)
    }
    
    @objc func didTapChallenge(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "moveToViewAllChallenge2", sender: nil)
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
    
    func setupView(width: CGFloat) {
        
        highlightBorder = highlightsBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: width)
        challengeBorder = challengeBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: width)
        aboutBorder = aboutBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: width)
        
        //
        
        highlightsBtn.layer.addSublayer(highlightBorder)
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
        
        imageHeight.constant = self.view.frame.height * (250/707)
       
        
    }
 

    func countFollow(uid: String) {
        
        followListen = DataService.init().mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("status", isEqualTo: "Valid").addSnapshotListener {  querySnapshot, error in
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
        
        followingListen = DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("status", isEqualTo: "Valid").addSnapshotListener {  querySnapshot, error in
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
        
        
        challengeListen = db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("current_status", isEqualTo: "Valid").whereField("isAccepted", isEqualTo: true).whereField("uid_list", arrayContains: uid)
            
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty == true {
                    
                    self.challengeCount.text = "0"
                    
                } else {
                    self.challengeCount.text = "\(formatPoints(num: Double(snapshot.count)))"
                }
                
            }
    }
 
     
    func loadProfile() {
        
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
        
        profileListen = db.collection("Users").document(uid!).addSnapshotListener {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    self.assignProfile (item: item)
                    
                }
                
            }

        }
    }
    
    func getAvatarImage(url: String) {
        
        imageStorage.async.object(forKey: url) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    self.avatarImg.image = image
                    
                }
                
            } else {
                
                
             AF.request(url).responseImage { response in
                    
                    switch response.result {
                    case let .success(value):
                        
                        self.avatarImg.image = value
                        try? imageStorage.setObject(value, forKey: url, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                        
                    case let .failure(error):
                        print(error)
                    }
                    

                }
                
            }
            
        }
        
        
        
    }
    
    
    func assignProfile(item: [String: Any]) {
        
        if let username = item["username"] as? String, let name = item["name"] as? String, let avatarUrl = item["avatarUrl"] as? String  {
            
            
            global_avatar_url = avatarUrl
            global_username = username
            global_name = name
            self.SelectedUserName = username
            self.SelectedAvatarUrl = avatarUrl
            nameLbl.text = name.uppercased()
            //usernameLbl.text = "@\(username)"
            makeGradientViewForUsername(username: username)
            nickname = username
                      
            getAvatarImage(url: avatarUrl)

        }
 
        
        if let DiscordStatus = item["DiscordStatus"] as? Bool {
            
            if DiscordStatus == true {
                              
                isDiscord =  true
                
                if let discord_link = item["discord_link"] as? String, discord_link != "nil", discord_link != "" {
                    
                    discordBtn.isHidden = false
                    discord_url = discord_link
                    
                   
                } else {
                    
                    discordBtn.isHidden = true
                   
                }
                
            } else {
                
                
                discordBtn.isHidden = true
                isDiscord =  false
                
            }
            
            
            
        } else {
            
            discordBtn.isHidden = true
            isDiscord = false
            
        }
            
        if let ChallengeStatus = item["ChallengeStatus"] as? Bool {
            
            if ChallengeStatus == true {
                
                isChallenge = true
               
            } else {
                
                
                isChallenge = false
                
            }
            
        } else {
            
            isChallenge = false
            
        }
        
        
        if let HighlightNotiStatus = item["HighlightNotiStatus"] as? Bool {
            
            if HighlightNotiStatus == true {
                
                isHighlightNoti = true
               
            } else {
                
                
                isHighlightNoti = false
                
            }
            
        } else {
            
            isHighlightNoti = false
            
        }
        
        
        if let ChallengeNotiStatus = item["ChallengeNotiStatus"] as? Bool {
            
            if ChallengeNotiStatus == true {
                
                isChallengeNoti = true
               
            } else {
                
                
                isChallengeNoti = false
                
            }
            
        } else {
            
            isChallengeNoti = false
            
        }
        
        if let CommentNotiStatus = item["CommentNotiStatus"] as? Bool {
            
            if CommentNotiStatus == true {
                
                isCommentNoti = true
               
            } else {
                
                
                isCommentNoti = false
                
            }
            
        } else {
            
            isCommentNoti = false
            
        }
        
        
        if let FollowNotiStatus = item["FollowNotiStatus"] as? Bool {
            
            if FollowNotiStatus == true {
                
                isFollowNoti = true
               
            } else {
                
                
                isFollowNoti = false
                
            }
            
        } else {
            
            isFollowNoti = false
            
        }
        
        if let MessageNotiStatus = item["MessageNotiStatus"] as? Bool {
            
            if MessageNotiStatus == true {
                
                isMessageNoti = true
               
            } else {
                
                
                isMessageNoti = false
                
            }
            
        } else {
            
            isMessageNoti = false
            
        }
        
        if let CallNotiStatus = item["CallNotiStatus"] as? Bool {
            
            if CallNotiStatus == true {
                
                isCallNoti = true
               
            } else {
                
                
                isCallNoti = false
                
            }
            
        } else {
            
            isCallNoti = false
            
        }
        
        if let MentionNotiStatus = item["MentionNotiStatus"] as? Bool {
            
            if MentionNotiStatus == true {
                
                isMentionNoti = true
               
            } else {
                
                
                isMentionNoti = false
                
            }
            
        } else {
            
            isMentionNoti = false
            
        }
        
        
        if let isSoundGET = item["isSound"] as? Bool {
            
            if isSound == nil {
                
            
                if isSoundGET == true {
                    
                    isSound = true
                    shouldMute = false
                   
                } else {
                    
                    isSound = false
                    shouldMute = true
                    
                }
                
            } else {
                
                if isSoundGET == true {
                    
                    if isSound != true {
                        isSound = true
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateSound1")), object: nil)
                    }
                    
                   
                } else {
                    
                    if isSound != false {
                        isSound = false
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateSound1")), object: nil)
                    }
                
                    
                }
                
            }
            
            
            
            
        } else {
            
            isSound = false
            
        }
        
        
        if let isMinimizeGET = item["isMinimize"] as? Bool {
            
            if isMinimizeGET == true {
                
                isMinimize = true
               
            } else {
                
                isMinimize = false
                
            }
            
            //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateSound1")), object: nil)
           
            
        } else {
            
            isMinimize = false
            
            
        }
        
        if let isPending_deletionGET = item["isPending_deletion"] as? Bool {
            
            if isPending_deletionGET == true {
                
                isPending_deletion = true
               
            } else {
                
                isPending_deletion = false
                
            }
            
          
        } else {
            
            isPending_deletion = false
            
            
        }
     
        
    }
    
    func getstar(uid: String) {
        
        starListen = DataService.instance.mainFireStoreRef.collection("Challenge_rate").whereField("to_uid", isEqualTo: uid).limit(to: 200).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.rateLbl.isHidden = true
                
                
            } else {
                
                
                snapshot.documentChanges.forEach { diff in
                    

                    if (diff.type == .added) {
                       
                        var rate_lis = [Int]()
                        
                        for item in snapshot.documents {
                            
                            if let current_rate = item.data()["rate_value"] as? Int {
                                
                                
                                rate_lis.append(current_rate)
                                
                            }
                            
                        }
                       
                        
                        let average = calculateMedian(array: rate_lis)
                        self.rateLbl.isHidden = false
                        self.rateLbl.text = " \(String(format:"%.1f", average))"
                        
                        
                    }
                  
                }
                
            }
        
        }
        
        
    }
    
    func makeGradientViewForUsername(username: String) {
        
        usernameLbl.text = "@\(username)"
        usernameLbl.sizeToFit()
        self.view.layoutIfNeeded()
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
        gradient.setNeedsLayout()
        
         
        // Create a label and add it as a subview
        let label = UILabel(frame: usernameLbl.bounds)
        label.text = "@\(username)".lowercased()
        label.font = .robotoRegular(size: 20)
        label.textAlignment = .center
        usernameLbl.addSubview(label)

        // Tha magic! Set the label as the views mask
        usernameLbl.mask = label
        
    }
    
    
    
    
    @IBAction func ImgBtnPressed(_ sender: Any) {
        
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let view = UIAlertAction(title: "View profile image", style: .default) { (alert) in
            
            self.blurView.isHidden = false
            self.bigProfileImg.alpha = 1.0
            self.bigProfileImg.image = self.avatarImg.image
            self.bigProfileImg.borderColors = selectedColor
            
            UIView.transition(with: self.bigProfileImg, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
                self.bigProfileImg.isHidden = false
                
            })
           
            
            
        }
        
        let change = UIAlertAction(title: "Change profile image", style: .default) { (alert) in
           
            let container = ContainerController(modes: [.library, .photo])
            container.editControllerDelegate = self
            
            // Include only videos from the users photo library
            container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            // Include only videos from the users drafts
            container.libraryController.draftMediaTypes = [.image]
            
            
            let nav = UINavigationController(rootViewController: container)
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true, completion: nil)
            
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        sheet.addAction(view)
        sheet.addAction(change)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
        
        
    }

    
    func getImage(image: UIImage) {
        
        DispatchQueue.main.async {
            
            self.profileImgBtn.setTitle("", for: .normal)
            self.avatarImg.image = image
           
            
        }
        
        uploadImg(image: image)

    }
    
    func uploadImg(image: UIImage) {

        let metaData = StorageMetadata()
        let imageUID = UUID().uuidString
        metaData.contentType = "image/png"
        var imgData = Data()
        imgData = image.jpegData(compressionQuality: 0.7)!
         
        DataService.instance.AvatarStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
            
            if err != nil {
                
                //SwiftLoader.hide()
                if err?.localizedDescription == "User is not authenticated, please authenticate using Firebase Authentication and try again." {
                    
                    self.showErrorAlert("Oops!", msg: "Can't authenticate your user, please logout and login again.")
                    
                } else {
                    
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    
                }
                

            } else {
                
                DataService.instance.AvatarStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
               
                    guard let Url = url?.absoluteString else { return }
                    
                    let downUrl = Url as String
                    let downloadUrl = downUrl as NSString
                    let downloadedUrl = downloadUrl as String
                    
                    
                    self.getAvatarImage(url: downloadedUrl)
                    DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["avatarUrl": downloadedUrl])
                    
                    SBUMain.updateUserInfo(nickname: SBDMain.getCurrentUser()!.nickname, profileUrl: downloadedUrl) { (err) in
                        
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        
                        
                    }
                    
                })
                      
                
            }
            
            
        }
        
              
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
        
        if segue.identifier == "moveToViewAllChallenge2"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.viewUID = Auth.auth().currentUser?.uid
                destination.enabledSetting = true
                
            }
        } else if segue.identifier == "moveToFollowListVC" {
            
            if let destination = segue.destination as? FollowerVC {
                
                destination.uid = Auth.auth().currentUser!.uid
                destination.nickname = nickname
                destination.followerCount = followCnt
                destination.followingCount = followingCnt
                destination.isMain = true
                
            }
            
        }
        
    }
  
    
    @IBAction func setting1BtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToSettingVC", sender: nil)
        
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
    
    
    
    @IBAction func rewardBtnPressed(_ sender: Any) {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leaderboardContainerVC") as? leaderboardContainerVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            self.present(controller, animated: true, completion: nil)
                 
        }
        
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
    
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         super.touchesBegan(touches, with: event)
         
    
         
         if blurView.isHidden == false {
             
             let touch = touches.first
             guard let location = touch?.location(in: self.view) else { return }
             if !bigProfileImg.frame.contains(location) {
                 
                 
                 UIView.animate(withDuration: 0.3, animations: {
                     self.bigProfileImg.alpha = 0
                 }) { (finished) in
                     self.bigProfileImg.isHidden = finished
                     self.blurView.isHidden = true
                 }
               
             }
                 
         }
         
     }
    
    
    
    
    
}


extension ProfileVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        if let image = session.image {
            
            ImageExporter.shared.export(image: image, completion: { (error, uiImage) in
                    if let error = error {
                        self.showErrorAlert("Oops!", msg: "Unable to export image: \(error)")
                        return
                    }

                self.getImage(image: uiImage!)
            })
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
}
