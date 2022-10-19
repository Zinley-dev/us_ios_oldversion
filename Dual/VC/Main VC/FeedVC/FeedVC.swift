//
//  FeedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/20/20.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Firebase
import SwiftPublicIP
import Alamofire
import SwiftyJSON
import SCLAlertView
import SendBirdCalls
import CoreMedia
import FLAnimatedImage

enum categoryControl {
    case Universal
    case category
  
}

class FeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate, UITextViewDelegate {
    
   
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var playTimeBar: UIProgressView!
    @IBOutlet weak var copyBackGroundImage: UIImageView!
    @IBOutlet weak var selectedGameLbl: UILabel!
    @IBOutlet weak var selectedGameImg: UIImageView!
    @IBOutlet weak var selectedGameView: UIView!
    @IBOutlet weak var landscapeBtn: UIButton!
    @IBOutlet weak var rewardBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var cardHeigh1: NSLayoutConstraint!
    var firstLoadCategory = false
    var currentFollowingLoadList = [String]()
    
    @IBOutlet weak var categoryView: UIView!
    
   
   
    var isAppear = false
    var isAnimating = false
    var copyImage =  UIImageView()
    var most_playDict = [String:Int]()
    var final_most_playDict = [Dictionary<String, Int>.Element]()
    var final_most_playList = [String]()
    var most_played_collectionView: UICollectionView!
    //
    
    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backgroundView3: UIView!
    var storedOffsets = [Int: CGFloat]()
    //
    var reload_time: Int!
    var refresh_request = false
  
    @IBOutlet weak var gameSwitchBtn: UIButton!
    
    @IBOutlet weak var notificationBtn: SSBadgeButton!
    @IBOutlet weak var settingViews: UIView!
  
    var isChallengeEnable = false
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    lazy var delayItem4 = workItem()

    @IBOutlet weak var backgroundView2: UIView!
   
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var category = categoryControl.Universal
    var key_list = [String]()
    var selected_item: HighlightsModel!
    //
    
    var willIndex: Int!
    var endIndex: Int!
    var currentIndex: Int!
    var challengeItem: HighlightsModel!
    var challengeName = ""
    var userid = ""
    var currentItem: HighlightsModel!
   
    @IBOutlet weak var progressBar: ProgressBar!
    
    
    @IBOutlet weak var bView: UIView!
    
    
    
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    var firstLoad = true
    var previousIndex = 0
    var itemList = [AddModel]()
    var collectionNode: ASCollectionNode!
    var categoryCollectionNode: ASCollectionNode!
    var posts = [HighlightsModel]()
    var newAddedItemList = [SubcollectionModel]()
    var newSnap = [DocumentSnapshot]()
    var viewedSnap = [DocumentSnapshot]()
    var index = 0
    var type = "For you"
    var type_detail = "For you"
    
    // challenge
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var challengeTextView: UITextView!
    @IBOutlet weak var challengeConstant: NSLayoutConstraint!
    
    var backgroundView = UIView()

    
    private var pullControl = UIRefreshControl()
  
    var lastPublicDocumentSnapshot: DocumentSnapshot!
    var lastOwnSubCollectionDocumentSnapshot: DocumentSnapshot!
    
    var query: Query!
    var subCollectionQuery: Query!
    
    
    var firstLoadBlock1 = true
    var firstLoadBlock2 = true
    var firstFollowing = true
    var firstInitLoad = true
    //
    
 
    var block_list = [String]()
    var following_list = [String]()
    var care_list = [String]()
    
    //
    
    var IBlock_list = [String]()
    var BlockMe_list = [String]()
    
    var content_list = [QueryDocumentSnapshot]()
   
    
    var placeholderLabel : UILabel!
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
        let flowLayout = UICollectionViewFlowLayout()
        let flowLayout2 = UICollectionViewFlowLayout()
        
      
        flowLayout2.scrollDirection = .horizontal
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.categoryCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout2)
        
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        self.collectionNode.leadingScreensForBatching = 2
        
        bView.backgroundColor = UIColor.clear
        bView.addSubview(collectionNode.view)
        categoryView.addSubview(categoryCollectionNode.view)
        
        challengeBtn.setTitle("", for: .normal)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.bView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.bView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.bView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.bView.bottomAnchor, constant: 0).isActive = true
        
        
        //
        
        self.categoryCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.categoryCollectionNode.view.topAnchor.constraint(equalTo: self.categoryView.topAnchor, constant: 0).isActive = true
        self.categoryCollectionNode.view.leadingAnchor.constraint(equalTo: self.categoryView.leadingAnchor, constant: 0).isActive = true
        self.categoryCollectionNode.view.trailingAnchor.constraint(equalTo: self.categoryView.trailingAnchor, constant: 0).isActive = true
        self.categoryCollectionNode.view.bottomAnchor.constraint(equalTo: self.categoryView.bottomAnchor, constant: 0).isActive = true
        
        challengeTextView.returnKeyType = .default
        self.applyStyle()
        
  
        // don't remove this function
        loadAddGame()
        
        
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            collectionNode.view.refreshControl = pullControl
        } else {
            collectionNode.view.addSubview(pullControl)
        }
        
        
        
        self.collectionHeight.constant = 0
        
        //updateTimeStamp()
        
        initWithoutCategoryRun()
        loadAvailableChatList()
        countNotification()
        //
        
        challengeTextView.delegate = self
        placeholderLabel = UILabel()
        
        placeholderLabel.font = UIFont.systemFont(ofSize: (challengeTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        
        challengeTextView.addSubview(placeholderLabel)
        
        placeholderLabel.frame = CGRect(x: 5, y: (challengeTextView.font?.pointSize)! / 2 - 5, width: 200, height: 30)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !challengeTextView.text.isEmpty
        
        //
        
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        
        searchBtn.setTitle("", for: .normal)
        notificationBtn.setTitle("", for: .normal)
        gameSwitchBtn.setTitle("", for: .normal)
        rewardBtn.setTitle("", for: .normal)
        landscapeBtn.setTitle("", for: .normal)
        
        
        delayItem.perform(after: 0.5) {
            boundHeight = self.view.bounds.height
            boundWidth = self.view.bounds.width - 32
            
          
            for viewController in self.tabBarController?.viewControllers ?? [] {
                
                
                if let navigationVC = viewController as? UINavigationController, let rootVC = navigationVC.viewControllers.first {
                    
                    
                    let _ = navigationVC.view
                    let _ = rootVC.view
                   
                    
                } else {
                    if viewController is FeedVC  {
                       
                    }else {
                        
                        let _ = viewController.view
                      
                    }
                   
                }
                
                
            }
    
        }

        
        Timer.scheduledTimer(timeInterval: 360, target: self, selector: #selector(FeedVC.removeOutDatePost), userInfo: nil, repeats: true)
        
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        copyBackGroundImage.addSubview(effectView)
        
        
        
        self.copyBackGroundImage.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: self.copyBackGroundImage.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.copyBackGroundImage.bottomAnchor, constant: 0).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.copyBackGroundImage.leadingAnchor, constant: 0).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.copyBackGroundImage.trailingAnchor, constant: 0).isActive = true
    
        
    }
    

   
    
    @objc func removeOutDatePost() {
        
        if !key_dict.isEmpty {
            
            for (key, value) in key_dict {
                
                if let dataVal = value as? Double {
                    
                  
                    if NSDate().timeIntervalSince1970 - dataVal >= 3600 {
                        
                        key_dict[key] = nil
                        
                        
                    }
                    
                }
                
               
                
            }
            
        }
        
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
        if UIDevice.current.orientation.isLandscape {
                
                self.tabBarController!.tabBar.isHidden = true
                self.settingViews.isHidden = true
                self.tabBarController?.tabBar.frame = .zero
                
                global_isLandScape = true
                    
            } else {
                self.tabBarController!.tabBar.isHidden = false
                self.tabBarController?.tabBar.frame = oldTabbarFr
                self.playTimeBar.isHidden = false
                global_isLandScape = false
          
            }
        
       
        if isAppear == true, currentIndex != nil {
            
            
            isAnimating = true
            
            if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? PostNode {
                
              
            
                cell.backgroundImageNode.isHidden = true
                
                
                
                
                
                coordinator.animate(alongsideTransition: { [unowned self] _ in
                    
                    
                    view.addSubview(copyImage)
                    
                    self.copyImage.translatesAutoresizingMaskIntoConstraints = false
                    self.copyImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
                    self.copyImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
                    self.copyImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
                    self.copyImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
                    
                    cell.rotatingCell = true
                
                    //cell.transitionLayout(with: ASSizeRange(min: size, max: size), animated: false, shouldMeasureAsync: false)
                    let indexPath = IndexPath(item: self.currentIndex, section: 0)
                    self.collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                    
                    
                    if UIDevice.current.orientation.isLandscape == false {
                       
                        if cell.post.origin_width/cell.post.origin_height > 0.5, cell.post.origin_width/cell.post.origin_height < 0.6 {
                                
                            cell.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                            cell.videoNode.contentMode = .scaleAspectFill
                            cell.isAlreadyFilled = true
                           
                        }
                        
                        
                        
                    } else {
                        
                        if cell.isFilled == true {
                            cell.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                            cell.videoNode.contentMode = .scaleAspectFit
                        }
                       
                       
                        cell.isAlreadyFilled = false
                        cell.videoNode.url = nil
                        
                        
                    }
                    
                    
                    rotatingAllVideos()
                    
                    
                    
    
                      if global_isLandScape {
                          
                          
                          cell.hideButtons(shouldAnimate: false)
                          
                          cell.ButtonView.challengeBtn.isHidden = true
                          cell.ButtonView.moveStackView.isHidden = true
                          cell.ButtonView.commentStackView.isHidden = true
                          cell.ButtonView.viewStackView.isHidden = true
                          cell.ButtonView.shareStackView.isHidden = false
                          cell.ButtonView.likeStackView.isHidden = false
                          cell.ButtonView.soundLbl.isHidden = false
                          cell.ButtonView.soundBtn.isHidden = false
                          cell.ButtonView.animationView.isHidden = true

                          
                      } else {
                          
                          if cell.isCellHidden == true {
                              
                              self.settingViews.isHidden = true
                              
                          } else {
                              
                              self.settingViews.isHidden = false
                              
                          }
                          
                          cell.gradientNode.isHidden = false
                          cell.DetailViews.isHidden = false
                          cell.ButtonView.isHidden = false
                         
                          if isMinimize == true {
                              cell.hideButtons(shouldAnimate: true)
                          } else {
                              cell.showButtons()
                          }
                          
                          
                      }
                     
       
                    }) { [unowned self] _ in
                        
                       
                        self.copyImage.removeFromSuperview()
                     
                        
                        delayItem.perform(after: 0.5) {
                            
                           
                            self.isAnimating = false
                            cell.rotatingCell = false
                            
                        }
                        
                       
                    }
                
                
            }
            

            
            
            
        }
       
        
         
    }

    @IBAction func landscapeBtnPressed(_ sender: Any) {
        
        landscapeBtn.isHidden = true
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
    }
    
    func setupChallengeView(item: HighlightsModel){
 
        self.backgroundView3.isHidden = false
        self.cardView.alpha = 1.0
        
        UIView.transition(with: cardView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.cardView.isHidden = false
            
        })
           
    
    }
    
    
    func showAddVC() {
    
        
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![2]
        
    }
    
    func loadMostPlayedList(uid: String) {
        
        most_playDict.removeAll()
        final_most_playList.removeAll()
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("MostPlayed_history").whereField("userUID", isEqualTo: uid).limit(to: 500)
            
            .getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                
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
                
                
                
                var count = 0
                
                for (key, _) in self.final_most_playDict {
                    
                    if count < 4 {
                        self.final_most_playList.append(key)
                        count += 1
                    } else {
                        break
                    }
                    
                    
                }
            
                self.most_played_collectionView.reloadData()

            }
        
   
        
    }
    
    func loadGeneralCardInfo(uid: String, cView: ChallengeCard) {
        
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
                            
                            if let username = item["username"] as? String, let avatarUrl = item["avatarUrl"] as? String, let create_time = item["create_time"] as? Timestamp  {
                                
                                
                                
                                cView.username.text = username
                                
                                let DateFormatter = DateFormatter()
                                DateFormatter.dateStyle = .medium
                                DateFormatter.timeStyle = .none
                                cView.startTime.text = DateFormatter.string(from: create_time.dateValue())
                                
                                
                                imageStorage.async.object(forKey: avatarUrl) { result in
                                    if case .value(let image) = result {
                                        
                                        DispatchQueue.main.async {
                                            cView.userImgView.image = image
                                        }
                                       
                                    } else {
                                        
                                        
                                     AF.request(avatarUrl).responseImage { response in
                                            
                                            
                                            switch response.result {
                                            case let .success(value):
                                             
                                                cView.userImgView.image = value
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
                                    
                                    cView.infoLbl.text = challenge_info
                                    
                                } else {
                                    
                                    cView.infoLbl.text = "Stitchbox's challenger"
                                }
                                
                            } else {
                                
                                cView.infoLbl.text = "Stitchbox's challenger"
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
     
            
        }
        
    
    }
    
    func loadChallengeCardInfo(uid: String, cView: ChallengeCard) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("isAccepted", isEqualTo: true).whereField("current_status", isEqualTo: "Valid").whereField("uid_list", arrayContains: uid)
            
            .getDocuments { querySnapshot, error in
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
                  
                    cView.challengeCount.attributedText = fullString
                    
                } else {
                  
                    fullString.append(NSAttributedString(string: " \(formatPoints(num: Double(snapshot.count)))"))
                    
                    cView.challengeCount.attributedText = fullString
                    
                }
                
            }
        
    }
    
    func updateData() {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
                
            if newPosts.count > 0 {
                        
                self.insertNewRowsInTableNode(newPosts: newPosts)
                
                                 
            } else {
              
                
                self.refresh_request = false
                self.posts.removeAll()
                self.collectionNode.reloadData()
                
                if self.posts.isEmpty == true {
                    
                    if self.type_detail == "For you" {
                        
                        self.collectionNode.view.setEmptyMessage("We can't find any available highlight for you right now, can you post some videos?")
                        
                    } else {
                        
                        self.collectionNode.view.setEmptyMessage("We can't find any available \(self.type_detail) highlight for you right now, can you post some videos?")
                    }
                    
                 
                } else {
                    
                    self.collectionNode.view.restore()
                    
                }
                
            }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            self.delayItem.perform(after: 0.75) {
                
                
                self.collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                
             
                    
            }
              
          
        }
        
        
    }
    
        
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       
        
      
        return self.textLimit(existingText: textView.text,
                                  newText: text,
                                  limit: 50)
        
        
    }
    
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        
        if self.challengeTextView.text != "" {
            
            ChallengeSend(text: self.challengeTextView.text)
            
            placeholderLabel.isHidden = self.challengeTextView.text.isEmpty
            self.challengeTextView.resignFirstResponder()
            
        }
        
        
    }
    
    
    
    
    
    
    // care list
    
    /*
     
     */
    
    func loadAvailableChatList() {
        
        
        if Auth.auth().currentUser?.uid != nil {
            
            let db = DataService.instance.mainFireStoreRef
            
            availableChatList = db.collection("Users").document(Auth.auth().currentUser!.uid).addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                      
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let Available_Chat_List = item["Available_Chat_List"] as? [String] {
                            
                            global_availableChatList = Available_Chat_List
                            
                            
                        } else {
                            
                            
                            global_availableChatList.removeAll()
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
        }
    
    
    }
    
    
    func getUsersIBlock(completed: @escaping DownloadComplete) {
        
        if Auth.auth().currentUser?.uid != nil {
            
            let db = DataService.instance.mainFireStoreRef
            
            block1 = db.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                
                
                if snapshot.isEmpty == true {
                    
                    if self.firstLoadBlock1 == true {
                        
                        self.firstLoadBlock1 = false
                        completed()
                    
                    }
           
                } else {
                    
                    if self.firstLoadBlock1 == true {
                        
                        
                        for item in snapshot.documents {
                            
                            if let Block_uid = item.data()["Block_uid"] as? String {
                                
                                if !self.block_list.contains(Block_uid) && !self.IBlock_list.contains(Block_uid)  {
                                    
                                    self.block_list.append(Block_uid)
                                    self.IBlock_list.append(Block_uid)
                                    
                                    //
                                    
                                }
                                
                            }
                            
                        }
                        
                        global_block_list = self.block_list
                        
                        self.firstLoadBlock1 =  false
                        completed()
                        
                    }
                    
                    
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    if self.firstInitLoad == false {
                        
                        if (diff.type == .added) {
                           
                            if let Block_uid = diff.document.data()["Block_uid"] as? String {
                                
                                if !self.block_list.contains(Block_uid) && !self.IBlock_list.contains(Block_uid) {
                                    
                                    self.block_list.append(Block_uid)
                                    self.IBlock_list.append(Block_uid)
                                                         
                                    
                                }
                                
                                //
                                global_block_list = self.block_list
                                
                                self.getCurrentVCAndPerformUpdate(uid: Block_uid)
                                
                                
                            }
                            
                        } else if (diff.type == .removed) {
                            
                            if let Block_uid = diff.document.data()["Block_uid"] as? String {
                                
                                if self.IBlock_list.contains(Block_uid) && self.block_list.contains(Block_uid) {
                                    
                                    if !self.BlockMe_list.contains(Block_uid) {
                                        
                                        self.block_list.removeObject(Block_uid)
                                                                
                                        
                                    }
                                    
                                    //
                                    global_block_list = self.block_list
                                    self.IBlock_list.removeObject(Block_uid)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                   
                    
                  
                }
                
                
            }
            
        }
        
        
        
    }

    func getUsersblockMe(completed: @escaping DownloadComplete){
        
        if Auth.auth().currentUser?.uid != nil {
            
            let db = DataService.instance.mainFireStoreRef
            
            block2 = db.collection("Block").whereField("Block_uid", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                
                
                if snapshot.isEmpty == true {
                    
                    if self.firstLoadBlock2 == true {
                        
                        self.firstLoadBlock2 = false
                        
                        completed()
                    
                    }
                    
                } else {
                    
                    if self.firstLoadBlock2 == true {
                        
                        
                        for item in snapshot.documents {
                            
                            if let User_uid = item.data()["User_uid"] as? String {
                                
                                if !self.block_list.contains(User_uid) && !self.BlockMe_list.contains(User_uid) {
                                    
                                    self.block_list.append(User_uid)
                                    self.BlockMe_list.append(User_uid)
                                    
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                        
                        
                        //
                        global_block_list = self.block_list
                        
                        self.firstLoadBlock2 =  false
                        completed()
                        
                    }
                    
                    
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    if self.firstInitLoad == false {
                        
                        if (diff.type == .added) {
                           
                            if let User_uid = diff.document.data()["User_uid"] as? String {
                                
                                if !self.block_list.contains(User_uid) && !self.BlockMe_list.contains(User_uid) {
                                    
                                    self.block_list.append(User_uid)
                                    self.BlockMe_list.append(User_uid)
                                    
                                    
                                }
                                
                                //
                                global_block_list = self.block_list
                                
                                self.getCurrentVCAndPerformUpdate(uid: User_uid)
                          
                            }
                             
                        } else if (diff.type == .removed) {
                            
                            if let User_uid = diff.document.data()["User_uid"] as? String {
                                
                                if self.BlockMe_list.contains(User_uid) && self.block_list.contains(User_uid) {
                                    
                                    if !self.IBlock_list.contains(User_uid) {
                                        
                                        self.block_list.removeObject(User_uid)
                                        //
                                        global_block_list = self.block_list
                                        
                                    }
                                    
                                    //
                                    global_block_list = self.block_list
                                    
                                    self.BlockMe_list.removeObject(User_uid)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }

                    
                  
                }
                
                
            }
            
        }
   
    }
    
    func getCurrentVCAndPerformUpdate(uid: String) {
        
        
        if let vc = UIViewController.currentViewController() {
            
            reloadFeed(uid: uid)
            
            if vc is UserProfileVC {
                
                if let update1 = vc as? UserProfileVC {
                    
                    update1.NoticeBlockAndDismiss()
                    
                }
                
            } else if vc is UserHighlightFeedVC {
                
                if let update2 = vc as? UserHighlightFeedVC {
                    
                    update2.NoticeBlockAndDismiss()
                    
                }
                
                
            }
                 
            
        }
        
        
    }
    
    func reloadFeed(uid: String) {
        
        var indexArr = [Int]()
        var index = 0
        
        for item in posts {
            
            if item.userUID == uid {
                
                indexArr.append(index)
                
            }
            
            index += 1
        }
        
        
        indexArr.reverse()
        //
        
        if indexArr.isEmpty != true {
            
            for i in indexArr {
                                
                posts.remove(at: i)
                collectionNode.deleteItems(at: [IndexPath(row: i, section: 0)])
                        
            }
            
            
        }
        
    }
    
    func initWithoutCategoryRun() {
        
        
        self.getUsersIBlock {
                                                   
            self.getUsersblockMe {
                
                
                self.getFollowing {
                                                           
                    self.firstInitLoad = false
                    
                    self.wireDelegates()
                                    
                }
                                                        
            }
                                                   
        }
        
        
             
    }
   
    func loadFromPublic(completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef
            
        if lastPublicDocumentSnapshot == nil {
            
            switch self.category {
                                                  
                case .Universal:
                query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").limit(to: 5)
                case .category:
                    if type != "" {
                        query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").whereField("category", isEqualTo: type).limit(to: 5)
                    } else {
                        query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").limit(to: 5)
                    }
            }
       
                
        } else {
            
            
            switch self.category {
                                                  
                case .Universal:
                    query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").limit(to: 5).start(afterDocument: lastPublicDocumentSnapshot)
                case .category:
                    if type != "" {
                        query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").whereField("category", isEqualTo: type).limit(to: 5).start(afterDocument: lastPublicDocumentSnapshot)
                    } else {
                        query = db.collection("Highlights").whereField("mode", isEqualTo: "Public").order(by: "updatedTimeStamp", descending: true).whereField("h_status", isEqualTo: "Ready").limit(to: 5).start(afterDocument: lastPublicDocumentSnapshot)
                    }
              
             }
          
           }
            
            query.getDocuments {  (snap, err) in
                
                if err != nil {
                    
                    completed()
                    
                    print(err!.localizedDescription)
                    return
                }
                    
                if snap?.isEmpty != true {
                    
                    // get item
                   
                    let items = snap?.documents
                    self.lastPublicDocumentSnapshot = snap!.documents.last
                    
                   
                    for item in items! {
                        
                        if let userUID = item.data()["userUID"] as? String {
                            
                            // check for block
                            
                            if !self.block_list.contains(userUID) {
                                
                                // check mode
                                
                                if !self.key_list.contains(item.documentID) {
                                    
                                    
                                    if key_dict[item.documentID] == nil {
                                        
                                    
                                        self.newSnap.append(item)
                                        self.key_list.append(item.documentID)
                                        
                                    }
                                   
                                }
                                
                            }
                       
                        }
                    }
                    
                  
                    completed()
                    
                    
                } else {
                
                    
                    self.lastPublicDocumentSnapshot = nil
                    key_dict.removeAll()
                    completed()
        
                }
                
        }
        
    }
    
    func loadFromOwnSubCollection(completed: @escaping DownloadComplete) {
        
        if let userUID = Auth.auth().currentUser?.uid {
        
            let db = DataService.instance.mainFireStoreRef
          
            if lastOwnSubCollectionDocumentSnapshot == nil {
                
                switch self.category {
                                                      
                    case .Universal:
                    subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).limit(to: 3)
                    case .category:
                        if type != "" {
                            subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).whereField("category", isEqualTo: type).limit(to: 3)
                        } else {
                            subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).limit(to: 3)
                        }
                }
           
                    
            } else {
                
                
                switch self.category {
                                                      
                    case .Universal:
                    subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).limit(to: 3).start(afterDocument: lastOwnSubCollectionDocumentSnapshot)
                    case .category:
                        if type != "" {
                            subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).whereField("category", isEqualTo: type).limit(to: 3).start(afterDocument: lastOwnSubCollectionDocumentSnapshot)
                        } else {
                            subCollectionQuery = db.collection("Users").document(userUID).collection("FolloweePost").order(by: "createdTimeStamp", descending: true).limit(to: 3).start(afterDocument: lastOwnSubCollectionDocumentSnapshot)
                        }
                  
                 }
              
               }
                
            subCollectionQuery.getDocuments {  (snap, err) in
                    
                    if err != nil {
                        
                        completed()
                        
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        let items = snap?.documents
                        self.lastOwnSubCollectionDocumentSnapshot = snap!.documents.last
                        
                        self.newAddedItemList.removeAll()
                        
                        for item in items! {
                            
                            if let postUID = item.data()["postUID"] as? String {
                                
                                // check for block
                                
                                if !self.block_list.contains(postUID) {
                                    
                                    let addItem = SubcollectionModel(postKey: item.documentID, Highlight_model: item.data())
                                    // check mode
                                    
                                    if !self.key_list.contains(item.documentID) {
                                        
                                        
                                        self.newAddedItemList.append(addItem)
                                        
                                    }
                                   
                                }
                           
                            }
                        }
                        
                         completed()
                      
                       
                        
                    } else {
                    
                        self.lastOwnSubCollectionDocumentSnapshot = nil
                        completed()
            
                    }
                    
            }
            
            
        } else {
            completed()
        }
        
    }
    
    func performCheckAndRemoveItemFromSubCollectionIfNeeds(docId: String) {
        
        DataService.instance.mainFireStoreRef.collection("Highlights").document(docId).getDocument { (snap, err) in
            
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            
            if snap?.exists != false {
                
                if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String {
                    
                    if status == "Ready", !global_block_list.contains(owner_uid) {
                        
                        
         
                    } else {
                        self.removeItem(docID: docId)
                    }
                    
                } else {
                    self.removeItem(docID: docId)
                }
                
            } else {
                self.removeItem(docID: docId)
            }
            
        }
        
    }
    
    func removeItem(docID: String) {
        
        DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).collection("FolloweePost").document(docID).delete()
        
    }
    
    func performMainCollectionCheckAndGatherInformation(completed: @escaping DownloadComplete) {
        
        if newAddedItemList.isEmpty {
            completed()
        } else {
            
            
            var nextItemCounts = 0

            for nextItem in newAddedItemList {
                
                DataService.instance.mainFireStoreRef.collection("Highlights").document(nextItem.mainDocID).getDocument { (snap, err) in
                    
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    
                    
                    if snap?.exists != false {
                        
                        if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String {
                            
                            if status == "Ready", !global_block_list.contains(owner_uid) {
                                
                                
                                if !self.key_list.contains(nextItem.mainDocID) {
                                    
                                    
                                    if key_dict[nextItem.mainDocID] == nil {
                                        
                                        self.newSnap.append(snap!)
                                        self.key_list.append(nextItem.mainDocID)
                                        
                                    }
                                   
                                }
                            
                            } else {
                                self.removeItem(docID: nextItem.mainDocID)
                            }
                            
                        } else {
                            self.removeItem(docID: nextItem.mainDocID)
                        }
                        
                     
                        
                    } else {
                        self.removeItem(docID: nextItem.mainDocID)
                    }
                    
                    nextItemCounts += 1
                    
                    if nextItemCounts == self.newAddedItemList.count {
                        completed()
                    }
                    
                }
                   
            }
     
        }
        
    }
    
    func checkForIfViewed(completed: @escaping DownloadComplete) {
        
        
        if newSnap.isEmpty {
            
            completed()
            
        } else {
            
            var count = 0
            let max = newSnap.count
            
            
            
            for item in newSnap {
                
                DataService.instance.mainFireStoreRef.collection("H_Views").document(item.documentID + Auth.auth().currentUser!.uid).getDocument { querySnapshot, error in
                    
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        self.showErrorAlert("Oops!", msg: "\(error!.localizedDescription)")
                        return
                    }
                    
                    
                    if snapshot.exists {
                        
                        if !self.viewedSnap.contains(item) {
                            
                            self.viewedSnap.append(item)
                            self.newSnap.removeObject(item)
                            
                        }
                        
                    }
                    
                    count += 1
                    if max == count {
                        completed()
                    }
                
                
                }
                
               
                
                
            }
            
            
        }
       
        
        
        
        
    }
    
    
    
    func getFollowing(completed: @escaping DownloadComplete) {
    
        let db = DataService.instance.mainFireStoreRef
            
        following = db.collection("Follow").whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("status", isEqualTo: "Valid").order(by: "follow_time", descending: true).addSnapshotListener {  querySnapshot, error in
                
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
             }
        
                if snapshot.isEmpty == true {
                    
                    if self.firstFollowing == true {
                        
                        self.firstFollowing = false
                        completed()
                    
                    }
                    
                } else {
                    
                    if self.firstFollowing == true {
                        
                        
                        for item in snapshot.documents {
                            
                            if let User_uid = item.data()["Follower_uid"] as? String {
                                                
                                if !self.following_list.contains(User_uid) {
                                    
                                   
                                    self.following_list.insert(User_uid, at: 0)
                                }
                               
                                if !self.currentFollowingLoadList.contains(self.userid) {
                                    self.currentFollowingLoadList.append(self.userid)
                                }
                                
                                global_following_list = self.following_list
                            }
                            
                        }
                        
                        self.firstFollowing =  false
                        completed()
                        
                    }
                    
                    
                }
                
            snapshot.documentChanges.forEach { diff in
                

                if (diff.type == .added) {
                   
                    if let User_uid = diff.document.data()["Follower_uid"] as? String, let status = diff.document.data()["status"] as? String, status == "Valid"  {
                        
                        if !self.following_list.contains(User_uid) {
                            
                            self.following_list.insert(User_uid, at: 0)
                            
                            
                            if !self.currentFollowingLoadList.contains(User_uid) {
                                self.currentFollowingLoadList.append(User_uid)
                            }
                           
                        }
              
                    } else {
                        
                        if let User_uid = diff.document.data()["Follower_uid"] as? String {
                            
                            if self.following_list.contains(User_uid) {
                                
                                self.following_list.removeObject(User_uid)
                                
                                if !self.currentFollowingLoadList.contains(User_uid) {
                                    self.currentFollowingLoadList.append(User_uid)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                
                    global_following_list = self.following_list
                    
                } else if (diff.type == .modified) {
                    
                    if let User_uid = diff.document.data()["Follower_uid"] as? String, let status = diff.document.data()["status"] as? String, status == "Valid"  {
                        
                        if !self.following_list.contains(User_uid) {
                            
                            self.following_list.insert(User_uid, at: 0)
                            
                            if !self.currentFollowingLoadList.contains(User_uid) {
                                self.currentFollowingLoadList.append(User_uid)
                            }
                           
                        }
                        
                        
                        
                    } else {
                        
                        if let User_uid = diff.document.data()["Follower_uid"] as? String {
                            
                            if self.following_list.contains(User_uid) {
                                
                                self.following_list.removeObject(User_uid)
                                
                                if self.currentFollowingLoadList.contains(User_uid) {
                                    self.currentFollowingLoadList.removeObject(User_uid)
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                   
                    global_following_list = self.following_list
                    
                    
                } else if (diff.type == .removed) {
                    
                    if let User_uid = diff.document.data()["Follower_uid"] as? String {
                        
                        if self.following_list.contains(User_uid) {
                            
                            self.following_list.removeObject(User_uid)
                            
                            if self.currentFollowingLoadList.contains(User_uid) {
                                self.currentFollowingLoadList.removeObject(User_uid)
                            }
                            
                        }
                        
                       
                        global_following_list = self.following_list
                        
                    }
                    
                    
                }
              
            }
                
        }
        
    }
    
   
    @objc func SignUpBtnPressed() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            if snapshot.isEmpty == true {
                
                self.performSegue(withIdentifier: "moveToLoginVC7", sender: nil)
                
            } else {
                
                self.showErrorAlert("Notice", msg: "We're down for scheduled maintenance right now!")
                
            }
            
        }
        
        
      
    }
    
    
    @objc private func refreshListCategory(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.itemList.removeAll()
        
        self.firstLoad = true
        loadAddGame()
              
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
    
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                challengeView.isHidden = false
                backgroundView2.isHidden = false
            
             let keyboardHeight = keyboardSize.height - (tabBarController?.tabBar.frame.height)!
            
                bottomConstraint.constant = keyboardHeight
                challengeConstant.constant = 50
               
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
        
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 0
        challengeConstant.constant = 0
        //textConstraint.constant = 30
       
        
        challengeView.isHidden = true
        backgroundView2.isHidden = true
        
          
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
    
    @IBAction func rewardBtnPressed(_ sender: Any) {
        
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "leaderboardContainerVC") as? leaderboardContainerVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            self.present(controller, animated: true, completion: nil)
                 
        }
        
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToIndex")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.delayItem.perform(after: 0.5) {
            self.isAppear = false
        }
        
        
        //pauseVideoIfNeed()
        if currentIndex != nil {
            
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {

                cell.videoNode.pause()
                
            }
        }
    
    }
    
 

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
        
        self.isAppear = true
        isFeedVC = true

        self.settingViews.isHidden = false
        
        if currentIndex != nil {
            
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {
                
                
                if cell.videoNode.isPlaying() == false {
                    delay(0.025) {
                        cell.videoNode.play()
                    }
                }
                
                if cell.is_challenge == true {
                    cell.ButtonView.challengeBtn.beat()
                }
               
            }
        }
        
        if self.landscapeBtn.isHidden == false {
            self.landscapeBtn.isHidden = true
        }
        
    
    }
    
  
    
    func setPortrait() {
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.shouldScrollToTop), name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.updateSound), name: (NSNotification.Name(rawValue: "updateSound1")), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
        
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                return
                
            }
            
            if call.isEnded == true {
                
                activeSpeaker()
                
            }
            
        } else {
             
            if general_room != nil {
                
                
               
                
                
            } else {
                
                activeSpeaker()
                
            }
            
            
            
            
        }
        
        
        if global_percentComplete == 0.00 || global_percentComplete == 100.0 {
            progressBar.isHidden = true
        }
        
       
      
    }
    
    
    @objc func updateProgressBar() {
        
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
            progressBar.isHidden = true
            global_percentComplete = 0.00
            
        } else {
            progressBar.isHidden = false
            progressBar.progress = (CGFloat(global_percentComplete)/100)
            
        }
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        self.challengeTextView.text = ""
        
        if self.categoryView.isHidden == false {
            
            UIView.transition(with: categoryView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.categoryView.isHidden = true
                                self.collectionHeight.constant = 0
                          })
            
        } else if cardView.isHidden == false {
            
            let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !cardView.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.cardView.alpha = 0
                }) { (finished) in
                    self.cardView.isHidden = finished
                    self.backgroundView3.isHidden = true
                }
              
            } else {
                    
                self.performSegue(withIdentifier: "moveToUserProfileVC3", sender: nil)
                  
            }
                
        }
        
        
        
        
    }
    
    func findCategoryIndex(list: [AddModel], name: String) -> Int {
        
        var count = 0
        for i in list {
            
            if i.name == name {
                break
            }
            
            count+=1
            
        }
        
        return count
        
    }
    
    
    func findIndex(item: String, list: [String]) -> Int {
        
        var count = 0
        
        for i in list {
            
            if item == i {
            
               return count
                
            }
            
            count += 1
        }
        
        return -1
        
    }
    
    
    func findIndexFromPost(item: HighlightsModel) -> Int {
        
        var count = 0
        
        for i in posts {
            
            if item.Mux_playbackID == i.Mux_playbackID, item.highlight_id == i.highlight_id, item.userUID == i.userUID {
            
               return count
                
            }
            
            count += 1
        }
        
        return -1
        
    }
    
    func isDataInPosts(item: HighlightsModel) -> Bool {
        
        for i in posts {
            
            if item.Mux_playbackID == i.Mux_playbackID, item.highlight_id == i.highlight_id, item.userUID == i.userUID {
            
               return true
                
            }
            
        }
        
        return false
        
    }
    
    
    
    
    @objc func shouldScrollToTop() {
        
        
        if currentIndex != nil {
            
            if cardView.isHidden == false {
                
                self.cardView.alpha = 0
                self.cardView.isHidden = true
                self.backgroundView3.isHidden = true
            
            }
            
        }
        
        
        if currentIndex != 0, currentIndex != nil {
            
            if collectionNode.numberOfItems(inSection: 0) != 0 {
                
                
                if currentIndex == 1 {
                    collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                } else {
                    
                    collectionNode.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredVertically, animated: false)
                    collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                    
                    if let cell = collectionNode.nodeForItem(at: IndexPath(row: 0, section: 0)) as? PostNode {
                        
                        openCell(cell: cell)
                        
                    }
                
                }
                
            
                
            }
            
            
        } else {
            
            delayItem3.perform(after: 0.25) {
                self.clearAllData()
            }

            
        }
            
            
            
        
        
    }
    
    

    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        
        clearAllData()
    
        
        
    }
    
    @objc func clearAllData() {
        
        //self.posts.removeAll()
        refresh_request = true
        self.key_list.removeAll()
        self.index = 0
        self.newSnap.removeAll()
        self.viewedSnap.removeAll()
        self.currentFollowingLoadList = self.following_list
        
        //
        lastOwnSubCollectionDocumentSnapshot = nil
        lastPublicDocumentSnapshot = nil
        
        query = nil
       
        endIndex = nil
        willIndex = nil
        currentIndex = nil
       
        updateData()
               
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
        
        self.categoryCollectionNode.delegate = self
        self.categoryCollectionNode.dataSource = self
        
    }

    func applyStyle() {
        
   
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
       
        //
        
        self.categoryCollectionNode.view.isPagingEnabled = false
        self.categoryCollectionNode.view.backgroundColor = UIColor.clear
        self.categoryCollectionNode.view.showsHorizontalScrollIndicator = false
        self.categoryCollectionNode.view.allowsSelection = true
        self.categoryCollectionNode.view.contentInsetAdjustmentBehavior = .never
       
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        if collectionView == self.most_played_collectionView {
            return final_most_playList.count
        } else {
            
            if collectionView.tag < posts.count {
                
                return posts[collectionView.tag].hashtag_list.count
            } else {
                
              
                return 0
                
            }
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.most_played_collectionView {
            
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCell.cellReuseIdentifier(), for: indexPath)) as! ChallengeCell
            let item = final_most_playList[indexPath.row]
            
            
            cell.cornerRadius = (collectionView.layer.frame.height - 5) / 2
            cell.configureCell(item)
            
            return cell
            
            
        } else {
            
            let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath)) as! HashtagCell
            let item = posts[collectionView.tag]
            
         
            cell.hashTagLabel.text = item.hashtag_list[indexPath.row]
            
            return cell
            
        }
    
         
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView == self.most_played_collectionView {
            
            let item = final_most_playList[indexPath.row]
            
            
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MostPlayVideoVC") as? MostPlayVideoVC {
                
                controller.modalPresentationStyle = .fullScreen
                controller.selected_category = item
                controller.selected_userUID = userid
                
                self.present(controller, animated: true, completion: nil)
                
                
            }
            
            
        }
        else {
            

            let selectedHashtag = posts[collectionView.tag].hashtag_list[indexPath.row]
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoListWithHashtagVC") as? VideoListWithHashtagVC {
                
                self.setPortrait()
                
                vc.searchHashtag = selectedHashtag
                vc.modalPresentationStyle = .fullScreen
                      
                present(vc, animated: true)
                
                
            }
            
            
        }
        
                 
    
    }
    
    func setImageForGameSwitch(info: AddModel) {
        
        if info.name == "General" {
            
            selectedGameView.isHidden = true
            self.gameSwitchBtn.backgroundColor = selectedColor
            
    
            if let url = info.url, url != "", url != "nil" {
                
                
                self.gameSwitchBtn.setImage(UIImage(named: info.short_name)!.resize(targetSize: CGSize(width: 20, height: 20)), for: .normal)
                     
             
            }
            
        } else {
            selectedGameView.isHidden = false
    
            self.gameSwitchBtn.setImage(nil, for: .normal)
            self.gameSwitchBtn.backgroundColor = UIColor.clear
            
            if info.short_name == "Others" {
                self.selectedGameLbl.backgroundColor = selectedColor
                self.selectedGameLbl.text = "Others"
                self.selectedGameLbl.textColor = UIColor.darkGray
            } else {
                self.selectedGameLbl.backgroundColor = UIColor.clear
                self.selectedGameLbl.text = info.short_name
                self.selectedGameLbl.textColor = selectedColor
            }

            
            if let url = info.url, url != "", url != "nil" {
            
                imageStorage.async.object(forKey: url) { result in
                    if case .value(let image) = result {
                        
                        DispatchQueue.main.async {
                            //self.gameSwitchBtn.setImage(image.resize(targetSize: CGSize(width: 20, height: 20)), for: .normal)
                            self.selectedGameImg.image = image
                            
                        }
                        
                        
                    } else {
                        
                     AF.request(info.url).responseImage { response in
                            
                            
                            switch response.result {
                            case let .success(value):
                                self.selectedGameImg.image = value
                                try? imageStorage.setObject(value, forKey: url)
                                
                            case let .failure(error):
                                print(error)
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
             
            }
        }
        
        
        
    }
    
    
    func recordCategorySelection(category: String, uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Category_record")
        
        let data = ["category": category, "userUID": uid, "timeStamp": FieldValue.serverTimestamp()] as [String : Any]
        
        
        db.addDocument(data: data) { (err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                
                
            }
            
        }
        
        
        
    }
    
    func loadAddGame() {
        
        let db = DataService.instance.mainFireStoreRef
        
        addGamefeedvc = db.collection("Support_game").order(by: "name", descending: true)
            .addSnapshotListener {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                     return
                }
                
                if self.firstLoad == true {
                    
                    var generalItem: AddModel?
                    var otherItem: AddModel?
                   
                    
                    for item in snapshot.documents {
                       
                        if item.data()["status"] as! Bool == true {
                            
                            var i = item.data()
                           
 
                            if i["short_name"] as? String == "Others" {
                             
                                i.updateValue(false, forKey: "isSelected")
                                let updatedItem = AddModel(postKey: item.documentID, Game_model: i)
                                otherItem = updatedItem
                                
                    
                            } else if i["short_name"] as? String == "General" {
                                
                                i.updateValue(true, forKey: "isSelected")
                                let updatedItem = AddModel(postKey: item.documentID, Game_model: i)
                                generalItem = updatedItem
                                
                                                  
                            } else {
                                
                                i.updateValue(false, forKey: "isSelected")
                                let updatedItem = AddModel(postKey: item.documentID, Game_model: i)
                                self.itemList.append(updatedItem)
                                
                            }
                            
                        }
                        
                    }
                    
                    if generalItem != nil {
                    
                       
                        self.itemList.insert(generalItem!, at: 0)
                        self.previousIndex = 0
                    }
                    
                    if otherItem != nil {
                        
                        self.itemList.append(otherItem!)
                    }
                      
                    
                    self.setImageForGameSwitch(info: self.itemList[0])
                    self.firstLoad =  false
                    
                  
                       
                }
                
                snapshot.documentChanges.forEach { diff in
                    

                    if (diff.type == .modified) {
                        
                        if diff.document["status"] as! Bool == true {
                            
                            let checkItem = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            let isIn = self.findDataInList(item: checkItem)
                            
                            if isIn == false {
                                
                                var data = diff.document.data()
                                
                                data.updateValue(false, forKey: "isSelected")
                                let updatedItem = AddModel(postKey: diff.document.documentID, Game_model: data)
                                
                                if diff.document["short_name"] as? String != "Others" {
                                    
                                    self.itemList.insert(updatedItem, at: 1)
                                    
                                } else if diff.document["short_name"] as? String != "General" {
                                    
                                    self.itemList.insert(updatedItem, at: 0)
                                    
                                } else if diff.document["short_name"] as? String != "Search" {
                                    
                                    self.itemList.insert(updatedItem, at: 0)
                                    
                                }
                                
                                else {
                                    
                                    self.itemList.append(updatedItem)
                                        
                                }
                                
                                
                            } else {
                                
                                let updatedItem = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                                let index = self.findDataIndex(item: updatedItem)
                                
                                let selected = self.itemList[index].isSelected
                                
                                var data = diff.document.data()
                                data.updateValue(selected!, forKey: "isSelected")
                                
                                let Fitem = AddModel(postKey: diff.document.documentID, Game_model: data)
                                
                                self.itemList.remove(at: index)
                                self.itemList.insert(Fitem, at: index)
                                
                            
                            }
                            
                           // self.categoryCollectionNode.reloadData()
                            
                            
                        } else {
                            
                            
                            let updatedItem = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            
                            let index = self.findDataIndex(item: updatedItem)
                            self.itemList.remove(at: index)
                            
                            
                            // delete processing goes here
                            
                            self.itemList[0]._isSelected = true
                
                            self.previousIndex = 0
                            //self.categoryCollectionNode.reloadData()
                            
                            
                        }
                        
              
                    } else if (diff.type == .removed) {
                        
                        let updatedItem = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                        
                        let index = self.findDataIndex(item: updatedItem)
                        self.itemList.remove(at: index)
                        
                        
                        // delete processing goes here
                        
                        self.itemList[0]._isSelected = true
                        self.previousIndex = 0
                        //self.categoryCollectionNode.reloadData()
                        
                        
                    } else if (diff.type == .added) {
                        
                        
                        if diff.document["status"] as! Bool == true {
                            
                            var data = diff.document.data()
                            data.updateValue(false, forKey: "isSelected")
                            
                            let updatedItem = AddModel(postKey: diff.document.documentID, Game_model: data)
                          
                            let isIn = self.findDataInList(item: updatedItem)
                            
                            if isIn == false {
                                
                                if diff.document["short_name"] as? String != "Others" {
                                    
                                    self.itemList.insert(updatedItem, at: 1)
                                    
                                } else if diff.document["short_name"] as? String != "General" {
                                    
                                    self.itemList.insert(updatedItem, at: 0)
                                    
                                } else if diff.document["short_name"] as? String != "Search" {
                                    
                                    self.itemList.insert(updatedItem, at: 0)
                                    
                                } else {
                                    
                                    self.itemList.append(updatedItem)
                                    
                                }
 
                                                      
                            }
                            
                            //self.categoryCollectionNode.reloadData()
                            
                            
                        }
                        
                    }
                }
            }
        
    }
    
    func findDataInList(item: AddModel) -> Bool {
        
        for i in itemList {
            
            if i.name == item.name {
                
                return true
                
            }
          
        }
        
        return false
        
    }
    
    func findDataIndex(item: AddModel) -> Int {
        
        var count = 0
        
        for i in itemList {
            
            if i.name == item.name {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
 
    // layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == self.most_played_collectionView {
           
            return 10.0
            
        } else if collectionView == self.collectionNode.view {
            return 0.0
            
        } else if collectionView == self.categoryCollectionNode.view {
            return 30.0
        } else {
            return 10.0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.most_played_collectionView {
            
            return 10.0
            
        } else if collectionView == self.collectionNode.view {
            return 0.0
            
        } else if collectionView == self.categoryCollectionNode.view {
            return 30.0
        } else {
            return 10.0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
      if collectionView == self.most_played_collectionView {
            
            return CGSize(width: collectionView.layer.frame.height - 5, height: collectionView.layer.frame.height - 5)
            
        } else {
                
            return CGSize(width: 99, height: 20)
            
        }
        
        
        
    }

    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Dismiss")
    }

    // functions
    func shareVideo(item: HighlightsModel) {
        
        if let id = item.highlight_id, id != "" {
            
            let items: [Any] = ["Hi I am \(global_name) from Stitchbox, let's check out this highlight!", URL(string: "https://dualteam.page.link/dual?p=\(id)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                           
                
            }
           
           present(ac, animated: true, completion: nil)
        
        }
    
        
    }
    
    func challenge(item: HighlightsModel, node: PostNode) {
        
     
            if let uid = Auth.auth().currentUser?.uid, Auth.auth().currentUser?.isAnonymous != true, uid != item.userUID {
                
                
                if node.is_challenge {
                    
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    
                    DataService.init().mainFireStoreRef.collection("Users").document(item.userUID!).getDocument { querySnapshot, error in
                        
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(error!)")
                            self.showErrorAlert("Oops!", msg: "\(error!.localizedDescription)")
                            return
                        }
                        
                        if snapshot.exists {
                            
                            if let items = snapshot.data() {
                                
                                if let username = items["username"] as? String {
                                        
                                    self.challengeName = username
                                        
                                        
                                } else {
                                    
                                    self.challengeName = "Undefined"
                                    
                                }
                                
                                
                                
                                self.userid = item.userUID
                                
                              
                                self.challengeItem = item
                                
                                self.placeholderLabel.text = "Challenge @\(self.challengeName)"
                                self.loadUserAvatar()
                                self.challengeTextView.becomeFirstResponder()
                                
                            }
                                 
                            
                        } else {
                            self.showErrorAlert("Oops!", msg: "You can't send challenge to this user.")
                            return
                        }
                        
                    }
                    
                } else {
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
                        kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                        kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
                        showCloseButton: true,
                        dynamicAnimatorActive: true,
                        buttonsLayout: .horizontal
                    )
                  
                    let alert = SCLAlertView(appearance: appearance)
                    
                    
                 
                    

                    let icon = UIImage(named:"logo123")
                    
                    
                    
                    _ = alert.showCustom("Hello \(global_username),", subTitle: "Awesome, but this user may turn off the challenge status, you can keep watching other highlight and challenge them to play together. Thank you so much from Stichbox Team.", color: UIColor.black, icon: icon!)
                    
                    
                }
                
                
                
                
            } else {
                
                
                //self.showErrorAlert("Oops!", msg: "You should be a signed user to challenge or you can't challenge yourself.")
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
                    kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
                    kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
                    showCloseButton: true,
                    dynamicAnimatorActive: true,
                    buttonsLayout: .horizontal
                )
              
                let alert = SCLAlertView(appearance: appearance)
                
                
             
                

                let icon = UIImage(named:"logo123")
                
                
                
                _ = alert.showCustom("Hello \(global_username),", subTitle: "Awesome, but you can't challenge yourself. Let's challenge other users to get a some new gaming partners. Thank you from Stichbox Team.", color: UIColor.black, icon: icon!)
                
                
            }
            
    

    }
    
    func loadUserAvatar() {
        
        if global_avatar_url != "" {
            
            asyncAvatar(avatarUrl: global_avatar_url)
            
        } else {
            
            let db = DataService.instance.mainFireStoreRef
            let uid = Auth.auth().currentUser?.uid
            
            
            
            db.collection("Users").document(uid!).getDocument { querySnapshot, error in
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let is_suspend = item["is_suspend"] as? Bool {
                            
                            if is_suspend == true {
                             

                            } else {
                             
                                if let avatarUrl = item["avatarUrl"] as? String {
                                     
                                     global_avatar_url = avatarUrl
                                     self.asyncAvatar(avatarUrl: global_avatar_url)
                                     
                                 }
                             
                            }
                         
                        }
                        
                        
                    }
                    
                    
                }
                
                
                
                
            }
            
           
        }
        
        
    }
    
    
    func asyncAvatar(avatarUrl: String) {
        
        imageStorage.async.object(forKey: avatarUrl) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async {
                    self.userImgView.image = image
                }
                
            } else {
                
                
             AF.request(avatarUrl).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                        self.userImgView.image = value
                        try? imageStorage.setObject(value, forKey: avatarUrl)
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
                }
                
            }
            
        }
        
    }
    
    func checkPendingChallengeFromMe(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
       
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Pending").whereField("created_timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "You have sent to @\(self.challengeName) a challenge before, please wait for the user's acceptance or until the expiration time.")
                return
                
            }
            
        
        }
        

        
    }
    
    func checkPendingChallengeFromUser(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
       
        
        db.whereField("sender_ID", isEqualTo: receiver_ID).whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Pending").whereField("created_timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "@\(self.challengeName) has sent you a challenge, please check your challenge list to accept.")
                return
                
            }
            
        
        }
        

        
    }
    
    func checkActiveChallengeFromMe(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                completed()
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "Your and @\(self.challengeName)'s challenge is active, you can't send another the expiration time.")
                return
                
            }
            
            
            
        }
        
    }
    
    
    func checkIfExceedPendingChallenge(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
  
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Pending").whereField("current_status", isEqualTo: "Valid").whereField("created_timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                
                
                return
            }
            
                if snap?.isEmpty == true {
                    
                    completed()
                    
                } else {
                    
       
                    if snap!.count >= 20 {
                        
                        self.showErrorAlert("Oops!", msg: "@\(self.challengeName) has reached maximum pending challenges.")
                        return
                        
                    } else {
                        completed()
                    }
                }
      
        }
        
        
        
    }
    
    func checkActiveChallengeFromUser(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        db.whereField("sender_ID", isEqualTo: receiver_ID).whereField("receiver_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("challenge_status", isEqualTo: "Active").whereField("started_timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                completed()
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "Your and @\(self.challengeName)'s challenge is active, you can't send another the expiration time.")
                return
                
            }
              
        }
        
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        AlgoliaSearch.instance.pingServer()
        self.performSegue(withIdentifier: "moveToSearchVC", sender: nil)
       
    }
    
    @IBAction func gameSwitchBtnPressed(_ sender: Any) {
        
        
        if self.categoryView.isHidden == false {
            
            UIView.transition(with: categoryView, duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.categoryView.isHidden = true
                                self.collectionHeight.constant = 0
                
                          })
            
        } else {
            
            if firstLoadCategory == false {
                categoryCollectionNode.reloadData()
                firstLoadCategory = true
            }
            
            UIView.transition(with: categoryView, duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.collectionHeight.constant = 47
                                self.categoryView.isHidden = false
                
                          })
        }
        
        
    }
    
    func countNotification() {
        
        notiListen = DataService.init().mainFireStoreRef.collection("Notification_center").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).addSnapshotListener {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.notificationBtn.badge = nil
            
            } else {
                
                for item in snapshot.documents {
                    
                    if let cnt = item.data()["count"] as? Int {
                        
                        
                        if cnt == 0 {
                            self.notificationBtn.badge = nil
                            
                        } else {
                            
                                                 
                            if cnt >= 100 {
                                self.notificationBtn.badge = "\(99)+"
                            } else {
                                self.notificationBtn.badge = "\(cnt)"
                            }
                            
                        }
                      
                    }
                    
                }
                
              
                
                
              
            }
            
            
        }
        
    }
    
    
  
    
    @IBAction func notificationBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToNotiVC", sender: nil)
        
    }
    
    func ChallengeSend(text: String) {
        
        if challengeItem != nil, text != "" {
            
            checkPendingChallengeFromMe(receiver_ID: challengeItem.userUID) {
                
                self.checkPendingChallengeFromUser(receiver_ID: self.challengeItem.userUID) {
                    
                    
                    self.checkActiveChallengeFromMe(receiver_ID: self.challengeItem.userUID) {
                        
                        
                        self.checkActiveChallengeFromUser(receiver_ID: self.challengeItem.userUID) {
                            
                            self.checkIfExceedPendingChallenge(receiver_ID: self.challengeItem.userUID) {
                                
                                if self.challengeTextView.text != "", self.challengeTextView.text.count > 5  {
                                    
                                    self.swiftLoader()
                                    
                                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                                        if let error = error {
                                            
                                            print(error.localizedDescription)
                                            SwiftLoader.hide()
                                            self.showErrorAlert("Oops!", msg: "Can't verify your information to send challenge, please try again.")
                                            
                                        } else if let string = string {
                                            
                                            let device = UIDevice().type.rawValue
                                            
                                            let data = ["receiver_ID": self.challengeItem.userUID!, "sender_ID": Auth.auth().currentUser!.uid, "category": self.challengeItem.category!, "created_timeStamp": FieldValue.serverTimestamp(), "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp(), "Device": device, "challenge_status": "Pending", "uid_list": [self.challengeItem.userUID, Auth.auth().currentUser!.uid], "isPending": true, "isAccepted": false, "query": string, "current_status": "Valid", "highlight_Id": self.challengeItem.highlight_id!, "messages": text] as [String : Any]
                                            
                                            
                                            
                                            
                                            let db = DataService.instance.mainFireStoreRef.collection("Challenges")
                                            var ref: DocumentReference!
                                            
                                            ref = db.addDocument(data: data) {  (errors) in
                                                
                                                if errors != nil {
                                                    
                                                    
                                                    SwiftLoader.hide()
                                                    self.showErrorAlert("Oops!", msg: errors!.localizedDescription)
                                                    return
                                                    
                                                }
                                                
                                                
                                                SwiftLoader.hide()
                                                
                                                
                                                ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Send", toUserUID: self.challengeItem.userUID!, category: self.challengeItem.category, challengeid: ref.documentID, Highlight_Id: self.challengeItem.highlight_id)
                                                ActivityLogService.instance.updateChallengeNotificationLog(mode: "Send", category: self.challengeItem.category, userUID: self.challengeItem.userUID!, challengeid: ref.documentID, Highlight_Id: self.challengeItem.highlight_id)
                                                
                                                self.challengeTextView.text = ""
                                               
                                                self.view.endEditing(true)
                                                
                                                
                                                showNote(text: "Cool! Challenge sent to @\(self.challengeName)")
                                                
                                                
                                            }
                                            
                         
                                        }
                                    }
                                              
                                    
                                    
                                } else {
                                    
                                    
                                   
                                    self.showErrorAlert("Oops!", msg: "Please enter your challenge messages, the message should contain more than 5 characters.")
                                    
                                }
                                
                            }
                        
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                }
                
                
            }
            
            
            
      
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Can't send challeng now, please try again")
            
            
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
    
    func openLink(item: HighlightsModel) {
        

        if let link = item.stream_link, link != "nil", link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            recordStreamLinkTap(category: item.category, link: link, ownerUID: item.userUID)
            
            if let domain = requestUrl.host {
            
                if domain == "dualteam.page.link" {
                    
                    guard let components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: false),let queryItems = components.queryItems else {
                        
                        return
                        
                    }
                    
                    
                    for queryItem in queryItems {
                        
                        if queryItem.name == "p" {
                            
                            if let id = queryItem.value {
                                
                                let db = DataService.instance.mainFireStoreRef
                                
                                
                                db.collection("Highlights").document(id).getDocument {  (snap, err) in
                                    
                                    if err != nil {
                                        
                                        print(err!.localizedDescription)
                                        return
                                    }
                                    
                                    
                                    if snap?.exists != false {
                                        
                                        if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String, let mode = snap!.data()!["mode"] as? String {
                                            
                                            if status == "Ready", !global_block_list.contains(owner_uid) {
                                                
                                                if mode != "Only me" {
                                                    
                                                    if mode == "Followers"  {
                                                        
                                                        if global_following_list.contains(owner_uid) ||  owner_uid == Auth.auth().currentUser?.uid {
                                                            
                                                            let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                            
                                                            self.presentViewController(id: id, items: [i])
                                                            
                                                        } else {
                                                            
                                                            if let vc = UIViewController.currentViewController() {
                                                                
                                                                if vc is notificationVC {
                                                                    
                                                                    if let update = vc as? notificationVC {
                                                                        update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                    }
                                                                    
                                                                } else if vc is CommentNotificationVC {
                                                                    
                                                                    if let update = vc as? CommentNotificationVC {
                                                                        update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                    }
                                                                    
                                                                }
                                                                                                          
                                                                 
                                                            }
                                                            
                                                        }
                                                        
                                                    } else if mode == "Public" {
                                                        
                                                        let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                        self.presentViewController(id: id, items: [i])
                                                        
                                                    }
                                                    
                                                } else{
                                                    
                                                    if owner_uid == Auth.auth().currentUser?.uid {
                                                        
                                                        let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                        self.presentViewController(id: id, items: [i])
                                                        
                                                        
                                                    } else {
                                                        
                                                        if let vc = UIViewController.currentViewController() {
                                                            
                                                            if vc is notificationVC {
                                                                
                                                                if let update = vc as? notificationVC {
                                                                    update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                }
                                                                
                                                            } else if vc is CommentNotificationVC {
                                                                
                                                                if let update = vc as? CommentNotificationVC {
                                                                    update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                }
                                                                
                                                            }
                                                                                                      
                                                             
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }

                                    
                                }
                               
                                
                            }
            
                        } else if queryItem.name == "up" {
                            
                            if let id = queryItem.value {
                                
                                if !global_block_list.contains(id) {
                                    
                                    self.MoveToUserProfileVC(uid: id)
                                }
                                
                            }
                            
                         
                        }
                        
                        
                    }
                    
                    
                    
                    
                    
                } else {
                    
                    if UIApplication.shared.canOpenURL(requestUrl) {
                         UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                    }
                    
                }
                
                
            } else {
                
                if UIApplication.shared.canOpenURL(requestUrl) {
                     UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                }
            }
            
        } else {
            
            
            if item.userUID == Auth.auth().currentUser?.uid {
                
                
                showInputDialog(subtitle: "You can add your current channel link directly from here",
                                actionTitle: "Add",
                                cancelTitle: "Cancel",
                                inputPlaceholder: "Stream link",
                                inputKeyboardType: .default, actionHandler:
                                        { (input:String?) in
                                            
                                            
                                            if verifyUrl(urlString: input) != true {
                                                                                       
                                                self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct it.")
                                                return
                                                
                                            } else {
                                                
                                                if let urlString = input {
                                                    
                                                    if let url = URL(string: urlString) {
                                                        
                                                        if let domain = url.host {
                                                            
                                                            if check_Url(host: domain) == true {
                                                                
                                                                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                                                                db.document(item.highlight_id).updateData(["stream_link": input!])
                                                                
                                                                
                                                                item._stream_link = input
                                                                
                                                                if self.isDataInPosts(item: item) {
                                                                    
                                                                    let index = self.findIndexFromPost(item: item)
                                                                    self.posts[index] = item
                                                                
                                                                    self.collectionNode.reloadItems(at: [IndexPath(row: index, section: 0)])
                                                                    
                                                                    showNote(text: "Stream link updated!")
                                                                    
                                                                }
                                                                
                                                            } else {
                                                                
                                                                
                                                                self.streamError()
                                                                return
                                                                
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                                
    
                                    }
                                            
                            })
                
                
            } else {
                
                let url = "https://dual.live/"
                
                guard let requestUrl = URL(string: url) else {
                    return
                }

                if UIApplication.shared.canOpenURL(requestUrl) {
                     UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                }
                
            }
            
            
            
            
        }

    }
    
    
    func MoveToUserProfileVC(uid: String) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            if let vc = UIViewController.currentViewController() {
                
                controller.uid = uid
                
                
                vc.present(controller, animated: true, completion: nil)
                 
            }
            
            
        }
        
    }
    
    func presentViewController(id: String, items: [HighlightsModel]) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            
            controller.video_list = items
            controller.userid = items[0].userUID
            controller.startIndex = 0
            
            if let vc = UIViewController.currentViewController() {
                 
               
                vc.present(controller, animated: true, completion: nil)
                 
            }
            
        }
        
        
        
        
    }
    
    func opencard(item: HighlightsModel) {
        
        preloadChallengeInfo(item: item)
        setupChallengeView(item: item)
        
    }
    
    
    func preloadChallengeInfo(item: HighlightsModel) {
        
        for v in cardView.subviews {
            v.removeFromSuperview()
        }
        
        let ChallengeView = ChallengeCard()
        most_played_collectionView = ChallengeView.collectionView
        most_played_collectionView.invalidateIntrinsicContentSize()
        most_played_collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
        most_played_collectionView.delegate = self
        most_played_collectionView.dataSource = self
        loadMostPlayedList(uid: item.userUID)
        loadGeneralCardInfo(uid: item.userUID, cView: ChallengeView)
        loadChallengeCardInfo(uid: item.userUID, cView: ChallengeView)
        
        //
        
        var newHeight = self.view.bounds.height * (230/759)
        
        if newHeight > 235 {
            newHeight = 240
        } else if newHeight < 235, newHeight > 179 {
            newHeight = 230
        } else {
            newHeight = 220
        }
        
        
        
        self.cardHeigh1.constant = newHeight
        self.cardView.frame = CGRect(x: 0, y: 0, width: self.cardView.frame.width, height: newHeight)
        
        //
        self.cardView.addSubview(ChallengeView)
        ChallengeView.frame = self.cardView.frame
        ChallengeView.badgeWidth.constant = self.view.bounds.width * (150/428)
        ChallengeView.infoHeight.constant = self.view.bounds.height * (24/759)
        ChallengeView.userImgWidth.constant = self.view.bounds.width * (85/428)
        ChallengeView.userImgHeight.constant = self.view.bounds.width * (85/428)
        
        
    }
    
    
    
    
    func streamError() {
        
        let alert = UIAlertController(title: "Oops!", message: "Your current streaming link isn't supported now, do you want to view available streaming link list ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            let slideVC =  steamingListVC()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            
            
            self.present(slideVC, animated: true, completion: nil)
            
            
        }))

        self.present(alert, animated: true)
        
    }
    

    func openProfile(item: HighlightsModel) {
        
      
        userid = item.userUID
        self.performSegue(withIdentifier: "moveToUserProfileVC3", sender: nil)
        
    }
    
    func openView(item: HighlightsModel) {
        
        selected_item = item
        self.performSegue(withIdentifier: "moveToViewVC", sender: nil)

    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfileVC3"{
            if let destination = segue.destination as? UserProfileVC
            {
                
                destination.uid = self.userid
                  
            }
        } else if segue.identifier == "moveToViewVC"{
            if let destination = segue.destination as? ViewVC
            {
                
                destination.selected_item = self.selected_item
                  
            }
        }
        
    }

    
        
}

extension FeedVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        if collectionNode != self.categoryCollectionNode {
            
            let min = CGSize(width: self.bView.layer.frame.width, height: self.bView.layer.frame.height);
            let max = CGSize(width: self.bView.layer.frame.width, height: self.bView.layer.frame.height);
            
            return ASSizeRangeMake(min, max);
            
        } else {
            
            let min = CGSize(width: 47, height: 47);
            let max = CGSize(width: 47, height: 47);
            
            return ASSizeRangeMake(min, max);
            
        }
       
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        if collectionNode != self.categoryCollectionNode {
            return true
        }
        
        return false
    }
    
   
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if collectionNode != self.categoryCollectionNode {
            
            if isAnimating != true, refresh_request != true {
                
                if self.posts.count <= 150 {
                    
                    self.retrieveNextPageWithCompletion { (newPosts) in
                            
                        if newPosts.count > 0 {
                                    
                            self.insertNewRowsInTableNode(newPosts: newPosts)
                                             
                        }
                        
                        if self.pullControl.isRefreshing == true {
                            self.pullControl.endRefreshing()
                        }
                        
                        
                        if newPosts.isEmpty == true , self.posts.isEmpty == true {
                            
                            if self.type_detail == "For you" {
                                
                                self.collectionNode.view.setEmptyMessage("We can't find any available highlight for you right now, can you post some videos?")
                                
                            } else {
                                
                                self.collectionNode.view.setEmptyMessage("We can't find any available \(self.type_detail) highlight for you right now, can you post some videos?")
                            }
                           
                        } else {
                            
                            collectionNode.view.restore()
                            
                           
                        }
                          
                        context.completeBatchFetching(true)
                                
                    }
                    
                } else {
                    
                    context.completeBatchFetching(true)
                    
                }
                

                
            } else {
                
                context.completeBatchFetching(true)
                
                
            }
            
            
            
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
        
        
    }


   
}

extension FeedVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        
        return 1
        
        

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        if collectionNode != self.categoryCollectionNode {
            return posts.count
        } else {
            return itemList.count
        }
      
    }
 
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        if collectionNode != self.categoryCollectionNode {
            
            let post = self.posts[indexPath.row]
               
            return {
                let node = PostNode(with: post)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                node.cardBtn = { (node) in
                
                    self.setPortrait()
                    self.opencard(item: post)
                      
                }
                
                node.shareBtn = { (node) in
                
                    self.shareVideo(item: post)
                      
                }
                
                node.challengeBtn = { (node) in
                    
                    self.setPortrait()
                    self.challenge(item: post, node: node as! PostNode)
                    
                    
                }
                
                
                node.linkBtn = { (node) in
                    
                    self.openLink(item: post)
                    
                }
                
                
                node.profileBtn = { (node) in
                    
                    self.setPortrait()
                    self.openProfile(item: post)
                    
                }
                
                node.viewBtn = { (node) in
                    
                    self.setPortrait()
                    self.openView(item: post)
                    
                }
                
                delay(0.3) {
                    if node.DetailViews != nil {
                        node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                    }
                }
        
                    
                return node
            }
            
        } else {
            
            let category = self.itemList[indexPath.row]
           
            return {
                
                let node = categoryFeed(with: category)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                
               
                return node
            }
            
        }
        
    }
    

    
    @objc func updateSound() {
        
        if currentIndex != nil {
            
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode, cell.ButtonView != nil {
                
                if isSound == true {
                    
                    cell.videoNode.muted = false
                    shouldMute = false
                    cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                    cell.ButtonView.soundLbl.text = "Sound on"
                    
                   
                } else {
                    
                    cell.videoNode.muted = true
                    shouldMute = true
                    cell.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                    cell.ButtonView.soundLbl.text = "Sound off"
                    
                }
                
            }
            
        }
        
        
        
        
    }
    
   
    func openCell(cell: PostNode) {

            if currentIndex != nil {
                
                cell.shouldCountView = true
               
                //cell.videoNode.player?.seek(to: CMTime.zero)
                self.playTimeBar.setProgress(0, animated: false)
                
                if !cell.videoNode.isPlaying() {
                    cell.videoNode.play()
                }
                
                if let playerItem = cell.videoNode.currentItem {
                   
                    if !playerItem.isPlaybackLikelyToKeepUp  {
                        
                        print("checking1: checking back after 3s")

                        //self.loadingImage.isHidden = false
                        
                        delayItem4.perform(after: 3) {
                            
                            if cell.isVisible {
                                
                                if !playerItem.isPlaybackLikelyToKeepUp  {
                                    
                                    print("checking2: perform reset")
                                    cell.videoNode.asset = nil
                                    cell.videoNode.asset = AVAsset(url: cell.getVideoURLForRedundant_stream(post: cell.post)!)
                                    
                                   
                                    
                                }
                                
                            }
                            
                            
                           
                            //self.loadingImage.isHidden = false
                            
                        }
                       
                    } else {
                        
                        
                        //self.loadingImage.isHidden = true
                        
                    }

                    
                }
               
               
                if cell.backgroundImageNode.image != nil {
                    
                    copyBackGroundImage.isHidden = false
                    copyBackGroundImage.image = cell.backgroundImageNode.image
                    copyBackGroundImage.contentMode = .scaleAspectFill
                    
                } else{
                    
                    delay(0.5) {
                        self.copyBackGroundImage.isHidden = false
                        self.copyBackGroundImage.image = cell.backgroundImageNode.image
                        self.copyBackGroundImage.contentMode = .scaleAspectFill
                    }
                    
                }
                
                
                
                
                let item = posts[currentIndex]
                
                userid = item.userUID
                
                if global_block_list.contains(item.userUID) {
                    
                    posts.remove(at: currentIndex)
                    collectionNode.deleteItems(at:  [IndexPath(row: currentIndex, section: 0)])
                   
                    return
                }
                
                checkVideoReady(row: currentIndex, item: item)
                
        
                cell.isCellHidden = false
                
                
               
                if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
                    
                    self.settingViews.isHidden = false
                    
                }
                
                var timePerform = 0.00
                
                if currentIndex == 0 {
                    timePerform = 0.25
                } else {
                    timePerform =  0.025
                }
                
                
                
                
                delayItem2.perform(after: timePerform) {
                    
                    if cell.DetailViews != nil {
                        
                        if cell.animatedLabel != nil, cell.ButtonView != nil {
                            

                            cell.infoView.isHidden = false
                            cell.ButtonView.isHidden = false
                            
                            
                        }
                        
                    }
                
                    
                  
                }
                
                
                if cell.isViewed == true {
                    
                    let currentTime = NSDate().timeIntervalSince1970
                    
                    let change = currentTime - cell.last_view_timestamp
                    
                    if change > 30.0 {
                        
                        cell.isViewed = false
                        cell.time = 0
                    
                    }
                    
                }
                
                if cell.ButtonView != nil {
                    cell.checkChallenge(Dview: cell.ButtonView)
                   
                }  else {
                    
                    delay(0.3) {
                        if cell.ButtonView != nil {
                            cell.checkChallenge(Dview: cell.ButtonView)
                            
                        }
                    }
                }
                

            }
                
                
            
    }
               
                
            
 
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
       
        if collectionNode != self.categoryCollectionNode {
            
            guard let cell = node as? PostNode else { return }
            
            if isAnimating == false {
                

                if cell.DetailViews != nil, cell.ButtonView != nil {
                        
                    cell.backgroundImageNode.isHidden = false
                    
                    cell.gradientNode.isHidden = false
                    cell.DetailViews.isHidden = false
                    cell.ButtonView.isHidden = false
                    self.playTimeBar.isHidden = false
                    
                    if cell.animatedLabel != nil, cell.ButtonView != nil {
                        
                        cell.animatedLabel.restartLabel()
                    }
                    
                
                    if isSound == true {
                        
                        
                        if shouldMute == false {
                            cell.videoNode.muted = false
                            cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                            cell.ButtonView.soundLbl.text = "Sound on"
                        } else {
                            cell.videoNode.muted = true
                            cell.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                            cell.ButtonView.soundLbl.text = "Sound off"
                        }
                        
            
                        
                    } else {
                        
                        
                        if shouldMute == false {
                            cell.videoNode.muted = false
                            cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                            cell.ButtonView.soundLbl.text = "Sound on"
                        } else {
                            cell.videoNode.muted = true
                            cell.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                            cell.ButtonView.soundLbl.text = "Sound off"
                        }
                                        
                       
                                       
                    }

                    
                   
                    
                    if global_isLandScape == true {
                        
                       
                        cell.hideButtons(shouldAnimate: false)
                        
                        cell.ButtonView.challengeBtn.isHidden = true
                        cell.ButtonView.moveStackView.isHidden = true
                        cell.ButtonView.commentStackView.isHidden = true
                        cell.ButtonView.viewStackView.isHidden = true
                        cell.ButtonView.shareStackView.isHidden = false
                        cell.ButtonView.likeStackView.isHidden = false
                        cell.ButtonView.soundLbl.isHidden = false
                        cell.ButtonView.soundBtn.isHidden = false
                        cell.ButtonView.animationView.isHidden = true
                       
                        
                        
                    } else {
                       
                       
                        
                        if isMinimize == true {
                            
                            cell.hideButtons(shouldAnimate: true)
                            
                        } else {
                            
                            cell.showButtons()
                            
                        }
                      
                        
                    }
                    
                    
                    if cell.is_challenge == true {
                        cell.ButtonView.challengeBtn.beat()
                    }
            

                }
               
              
                if currentIndex == nil {
                    
                    currentIndex = cell.indexPath?.row
                    openCell(cell: cell)
                    
                    
                } else {
                         
                    if isAnimating == false {
                        willIndex = cell.indexPath?.row
                    }
                    
                    
                }
                
                
                if self.categoryView.isHidden != true
                {
                    self.categoryView.isHidden = true
                    self.collectionHeight.constant = 0
                }
                
                
                if willIndex != nil {
                    if willIndex > currentIndex {
                        pausePreviousVideoIfNeed(pauseIndex: willIndex - 1)
                    } else {
                        pausePreviousVideoIfNeed(pauseIndex: currentIndex)
                    }
                   
                }

            }
            
            
        }
       

    }
    
    
    
    func rotatingAllVideos() {
        
        
        if posts.isEmpty != true {
            
            let total = posts.count
            var start = 0
            
            while start < total {
                
                if start != self.currentIndex {
                    
                    if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: start, section: 0)) as? PostNode {
                        
                        
                        
                        if cell.rotatingCell == false {
                            cell.videoNode.shouldAutoplay = false
                        }
                        
                        if self.view.frame.width < self.view.frame.height {
                           
                            if cell.post.origin_width/cell.post.origin_height > 0.5, cell.post.origin_width/cell.post.origin_height < 0.6, cell.isAlreadyFilled == false {
                                    
                                cell.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                                cell.videoNode.contentMode = .scaleAspectFill
                                cell.isAlreadyFilled = true
                               
                            }
                            
                        } else {
                            
                            if cell.isFilled == true {
                                cell.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                                cell.videoNode.contentMode = .scaleAspectFit
                                cell.isAlreadyFilled = false
                            }
                            
                            
                            //cell.videoNode.url = nil
                            
                        }
                               
                    }
                    
                    
                    
                    
                    
                }
                
                
                start += 1
                
                
            }
            
            
            
            
        }
        
        
        
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
     
        if collectionNode == self.categoryCollectionNode {
            
            UIView.transition(with: categoryView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.categoryView.isHidden = true
                                self.collectionHeight.constant = 0
                          })
            
            
            if previousIndex != indexPath.row {
                
                self.itemList[indexPath.row]._isSelected = true
                self.itemList[previousIndex]._isSelected = false
                
              
                if let cell = self.categoryCollectionNode.nodeForItem(at: IndexPath(row: indexPath.row, section: 0)) as? categoryFeed {
                    cell.configureCell(info: cell.category)
                }
                
                if let cell = self.categoryCollectionNode.nodeForItem(at: IndexPath(row: previousIndex, section: 0)) as? categoryFeed {
                    cell.configureCell(info: cell.category)
                }
                
                previousIndex = indexPath.row
                
                let scrollToPath = IndexPath(row: indexPath.row - 1, section: 0)
                
                
                self.categoryCollectionNode.scrollToItem(at: scrollToPath, at: .left, animated: true)
                
            }
            
            let item = self.itemList[indexPath.row]
            
    
            setImageForGameSwitch(info: item)
           
            // apply to item
            if item.name != type {
                
                type_detail = item.name
                type = item.short_name
                
                if item.name == "General" {
                    
                    category = categoryControl.Universal
                    
                } else {

                    category = categoryControl.category
                   
                }
                
                
                clearAllData()
                
                
            } else {
                //
                
                if currentIndex == 0 {
                    
                    clearAllData()
                    
                    
                } else {
                    
                    
                    if collectionNode.numberOfItems(inSection: 0) != 0 {
                        collectionNode.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        
                    }
                
                }
                
                
            }
            
            
            
        }
        
    }
    
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        
        if collectionNode != self.categoryCollectionNode {
            
            guard let cell = node as? PostNode else { return }

            if isAnimating == false {
                
                cell.videoNode.player?.seek(to: CMTime.zero)
                
                endIndex = cell.indexPath?.row
                
                if cell.gameTimer != nil {
                    cell.gameTimer?.invalidate()
                }
               
                cell.isAnimating = false
                
                if endIndex == willIndex {
                    
                    
                    if endIndex != nil {
                     
                        if endIndex > currentIndex {
                           playPreviousVideoIfNeed(playIndex: endIndex - 1)
                        } else {
                           playPreviousVideoIfNeed(playIndex: currentIndex)
                        }
                        
                       
                    }
                  
                } else {
                    
                    if isAnimating == false {
                      
                       
                        cell.videoNode.pause()
                       
                        if willIndex != nil {
                            
                            currentIndex = willIndex
                            
                            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {
                                
                               
                                
                                openCell(cell: cell)
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }
            
        }
        
    }
    

    
    func checkVideoReady(row: Int, item: HighlightsModel) {
        
        let db = DataService.instance.mainFireStoreRef
        db.collection("Highlights").document(item.highlight_id).getDocument { (snap, err) in
            
            if err != nil {
                
                self.posts.remove(at: row)
                self.collectionNode.deleteItems(at: [IndexPath(row: row, section: 0)])
                
                return
            }
            
            
            if snap?.exists != false {
                
                if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String {
                    
                    if status == "Ready", !global_block_list.contains(owner_uid) {
                        
                        if global_isLandScape == false {
                            
                            if item.origin_width/item.origin_height >= 1.5 {
                                    
                                if global_isLandScape == false {
                                    
                                    
                                    self.checkIfGuideLandScape()
                                   
                                }
                               
                                
                            } else {
                                
                                if self.landscapeBtn.isHidden == true {
                                    
                                    let userDefaults = UserDefaults.standard
                                    
                                    if userDefaults.bool(forKey: "hasGuideSwipePlaySpeed") == false {
                                           
                                        self.trySwipe()
                                       
                                        userDefaults.set(true, forKey: "hasGuideSwipePlaySpeed")
                                        userDefaults.synchronize()
                                        
                                        
                                    }
                                    
                                }

                                
                            }
                            
                        } else {
                            
                            let userDefaults = UserDefaults.standard
                            
                            if userDefaults.bool(forKey: "hasGuideHideInformation") == false {
                                   
                                
                                self.tryHide()
                              
                                userDefaults.set(true, forKey: "hasGuideHideInformation")
                                userDefaults.synchronize()
                                
                                
                            }
                            
                        }
                       
                        
                                                       
                        
                    } else {
                        
                        self.posts.remove(at: row)
                       
                        self.collectionNode.deleteItems(at: [IndexPath(row: row, section: 0)])
                        // remove
                    }
                    
                } else {
                    
                    self.posts.remove(at: row)
                    self.collectionNode.deleteItems(at: [IndexPath(row: row, section: 0)])
                    // remove
                }
                
            } else {
                
                self.posts.remove(at: row)
                self.collectionNode.deleteItems(at: [IndexPath(row: row, section: 0)])
                // remove
                
            }
            
        }
        
        
    }

    func checkIfGuideLandScape() {
    
        let userDefaults = UserDefaults.standard
        
        
        if userDefaults.bool(forKey: "hasGuideLandScapeBefore") == false {
           
            
            delayItem.perform(after: 2) {
                self.tryLandscape()
            }
           
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasGuideLandScapeBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
           
            // Run code here for the first launch
            
        } else {
            
            if userDefaults.bool(forKey: "hasGuideLandscapeAnimation") == false {
                   
                delay(0.25) {
                    self.animatedLandScapeBtn()
                }
               
                userDefaults.set(true, forKey: "hasGuideLandscapeAnimation")
                userDefaults.synchronize()
                
                
            } else {
                
                if self.landscapeBtn.isHidden == true {
                    
                    let userDefaults = UserDefaults.standard
                    
                    if userDefaults.bool(forKey: "hasGuideSwipePlaySpeed") == false {
                           
                        self.trySwipe()
                        
                        userDefaults.set(true, forKey: "hasGuideSwipePlaySpeed")
                        userDefaults.synchronize()
                        
                        
                    }
                    
                    
                }
                
                
                
            }
            
            
            
            
        }
                
    
    }
    
    func animatedLandScapeBtn() {
        
        landscapeBtn.isHidden = false
        
        UIView.animate(withDuration: 3.25) {
            self.landscapeBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        } completion: { finished in
            if finished == true {
                self.landscapeBtn.isHidden = true
            }
            
        }

        
    }
    
    
 
}

extension FeedVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        if Auth.auth().currentUser?.uid != nil {
            
            newSnap.removeAll()
            newAddedItemList.removeAll()
         
            self.loadFromPublic {
                
                
                self.loadFromOwnSubCollection {
                    
                    self.performMainCollectionCheckAndGatherInformation {
                        
                        
                        self.checkForIfViewed {
                            
                            //print("retrieveNextPageWithCompletion1 \(self.newSnap.count) - \(self.viewedSnap.count)")
                            
                            if self.newSnap.count < 2 || self.newSnap.isEmpty  {
                                //print("retrieveNextPageWithCompletion2 \(self.newSnap.count) - \(self.viewedSnap.count)")
                                if !self.viewedSnap.isEmpty {
                                    
                                    if self.viewedSnap.count < 2 {
                                        
                                        for item in self.viewedSnap {
                                            if !self.newSnap.contains(item) {
                                                self.newSnap.append(item)
                                            }
                                        }
                                        
                                      
                                        self.viewedSnap.removeAll()
                                        
                                    } else {
                                        
                                        let first = self.viewedSnap.first
                                        self.viewedSnap.removeFirst()
                                        let second = self.viewedSnap.first
                                        self.viewedSnap.removeFirst()
                                        
                                        if !self.newSnap.contains(first!) {
                                            
                                            self.newSnap.append(first!)
                                            
                                        }
                                        
                                        if !self.newSnap.contains(second!) {
                                            
                                            self.newSnap.append(second!)
                                            
                                        }
                                        
                            
                                        
                                    }
                                    
                            
                                }
                                
                                
                            } else {
                                
                                if self.viewedSnap.count > 5 {
                                    
                                    for item in self.viewedSnap[5...self.viewedSnap.count - 1] {
                                        
                                        if !self.newSnap.contains(item) {
                                            self.newSnap.append(item)
                                        }
                                        
                                        
                                    }
                                    
                                    self.viewedSnap.removeSubrange(5...self.viewedSnap.count - 1)
                                    
                               
                                    
                                }
                                
                                
                            }
                            
                          
                            
                            block(self.newSnap.shuffled())
                            
                        }
                        
                    }
                    
                }
                
               
            }
            
        }
     
        
    }
    
    func trySwipe() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
            kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
            showCloseButton: true,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
      
        let alert = SCLAlertView(appearance: appearance)
        
        let icon = UIImage(named:"logo123")
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "We just want to let you know that you are able to change the playspeed by swiping left or right.", color: UIColor.black, icon: icon!)
        
    }
    
    func tryHide() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
            kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
            showCloseButton: true,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
      
        let alert = SCLAlertView(appearance: appearance)
        
        let icon = UIImage(named:"logo123")
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "You can hide all information by holding screen for 1 second.", color: UIColor.black, icon: icon!)
        
    }
    
    
    func tryLandscape() {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
            kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
            showCloseButton: true,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
      
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton("Let's try") {
            
            self.isAppear = true
            let value = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            
        }
        
       
        
        let icon = UIImage(named:"logo123")
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "For this video, you'll have a better viewing experience in landscape mode. You can also continue to scroll infinitely as if you were in portrait mode.", color: UIColor.black, icon: icon!)
        
    }
    
    
    
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        // checking empty
        guard newPosts.count > 0 else {
            return
        }
        
        if refresh_request == true {
            
            refresh_request = false
            

            if self.posts.isEmpty != true {
                
               
                var delete_indexPaths: [IndexPath] = []
                
                for row in 0...self.posts.count - 1 {
                    let path = IndexPath(row: row, section: 0) // single indexpath
                    delete_indexPaths.append(path) // app
                }
            
                self.posts.removeAll()
                self.collectionNode.deleteItems(at: delete_indexPaths)
                   
            }
            
        }
        
        // basic contruction
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        //
        
        // current array = posts
        
        let total = self.posts.count + newPosts.count
        
        
        // 0 - 2 2-4 4-6
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section) // single indexpath
            indexPaths.append(path) // app
        }
        
        //
        
        for i in newPosts {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            items.append(item)
          
        }
        
        //
        
    
        // array
        
        
        
        self.posts.append(contentsOf: items) // append new items to current items
        //
        self.collectionNode.insertItems(at: indexPaths)
        
      
        
    }
    
    
}

