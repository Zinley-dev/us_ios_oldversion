//
//  UserHighlightFeedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 12/26/20.
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


class UserHighlightFeedVC: UIViewController, UIAdaptivePresentationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var playTimeBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playTimeBar: UIProgressView!
    @IBOutlet weak var copyBackGroundImage: UIImageView!
    @IBOutlet weak var back1: UIButton!
    var isFirstLoad = true
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var userImgView: UIImageView!
    var copyImage =  UIImageView()
    
    @IBOutlet weak var bViewBottomConstraint: NSLayoutConstraint!
    var isAppear = false
    var isAnimating = false
    var most_playDict = [String:Int]()
    var final_most_playDict = [Dictionary<String, Int>.Element]()
    var final_most_playList = [String]()
    var most_played_collectionView: UICollectionView!
    //
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backgroundView3: UIView!
    // challenge
    @IBOutlet weak var challengeView: UIView!
    @IBOutlet weak var challengeTextView: UITextView!
    @IBOutlet weak var challengeConstant: NSLayoutConstraint!
    var selected_item: HighlightsModel!
    @IBOutlet weak var backgroundView2: UIView!
    var firstLoad = false
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var placeholderLabel : UILabel!
  
    lazy var delayItem = workItem()
    lazy var delayItem2 = workItem()
    lazy var delayItem3 = workItem()
    lazy var delayItem4 = workItem()
    //
    
    @IBOutlet weak var bView: UIView!
    
    var willIndex: Int!
    var endIndex: Int!
    var startIndex: Int!
    var currentIndex: Int!
    var challengeItem: HighlightsModel!
    var challengeName = ""
    var userid: String?
  
    var previousIndex = 0
    var collectionNode: ASCollectionNode!
    var posts = [HighlightsModel]()
    var item_id_list = [String]()
    var video_list = [HighlightsModel]()
    var index = 0
    
    var backgroundView = UIView()
    
    var myCategoryOrdersTuple: [(key: String, value: Float)]? = nil
    var viewsCategoryOrdersTuple: [(key: String, value: Float)]? = nil
 
    var isFeed = false
   
    var currentItem: HighlightsModel!
    
    var selectedItem: HighlightsModel!
    
    var ispause = false
    
    @IBOutlet weak var setting1: UIButton!
    
    @IBOutlet weak var setting2: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        if userid == nil {
            
            
            return
        }
        
        isFeedVC = false
      
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
         
        
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        
        
        challengeBtn.setTitle("", for: .normal)
        bView.backgroundColor = UIColor.clear
        bView.addSubview(collectionNode.view)
        
    
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.bView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.bView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.bView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.bView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()
        
        self.loadHighlight()
        
        //
        
        challengeTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = ""
        placeholderLabel.font = UIFont.systemFont(ofSize: (challengeTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        challengeTextView.addSubview(placeholderLabel)
        
        placeholderLabel.frame = CGRect(x: 5, y: (challengeTextView.font?.pointSize)! / 2 - 5, width: 200, height: 30)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !challengeTextView.text.isEmpty
        
        
        //
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        copyBackGroundImage.addSubview(effectView)
        
        
        
        self.copyBackGroundImage.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: self.copyBackGroundImage.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.copyBackGroundImage.bottomAnchor, constant: 0).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.copyBackGroundImage.leadingAnchor, constant: 0).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.copyBackGroundImage.trailingAnchor, constant: 0).isActive = true
        
    
 
   
    }
    

    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        self.challengeTextView.text = ""
        
        
        if cardView.isHidden == false {
            
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
                    
                
                self.performSegue(withIdentifier: "moveToUserProfileVC5", sender: nil)
                  
            }
                
        }
    }
    
    func loadHighlight() {

        guard video_list.count > 0 else {
            return
        }
        
        if video_list.count > 150 {
            
            let count = video_list.count
          
            if currentIndex - 0 <= 75 {
                
                video_list.removeSubrange(150...count-1)
                
            } else {
                
                if (0...video_list.count - 151).contains(currentIndex) == false {
                    video_list.removeSubrange(0...video_list.count - 151)
                }
              
            }
            
            
            
        }
        
        
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + video_list.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for item in video_list {
            
            items.append(item)
          
        }
        
        self.posts.append(contentsOf: items)
        self.collectionNode.reloadData()
         
        guard startIndex != nil else {
            return
        }
        
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100000)) {
            
            
            self.currentIndex = self.startIndex
            
            self.collectionNode.scrollToItem(at: IndexPath(row: self.startIndex, section: 0), at: .centeredVertically, animated: false)
            
            if self.currentIndex != 0 {
                
                self.delayItem3.perform(after: 0.25) {
                    if self.currentIndex != 0, self.currentIndex != nil {
                        
                        
                        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? PostNode {
                            
                            self.openCell(cell: cell)
                            self.isFirstLoad = false
                            
                        }
                    }
                    
                }
            
            
            }
            
            
        }
        
        
    }
    
   
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return self.textLimit(existingText: textView.text,
                                  newText: text,
                                  limit: 50)
        
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        
        
        if self.challengeTextView.text != "" {
            
            
            ChallengeSend(text: self.challengeTextView.text)
            
            placeholderLabel.isHidden = self.challengeTextView.text.isEmpty
            self.challengeTextView.resignFirstResponder()
            
        }
        
        
        
    }
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                challengeView.isHidden = false
                backgroundView2.isHidden = false
            let keyboardHeight = keyboardSize.height
            
                bottomConstraint.constant = keyboardHeight - 35
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
        
        
        //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
        isAppear = true
       
        
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.delayItem.perform(after: 2.0) {
            self.isAppear = false
        }
        
        if currentIndex != nil {
            
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {
                
                
                cell.videoNode.pause()
               
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.posts.isEmpty != true {
            
            if currentIndex != nil {
                
                if self.posts[currentIndex].userUID != Auth.auth().currentUser?.uid {
                    
                    
                    setting1.isHidden = true
                    setting2.isHidden = true
                    
                }
                
            }
            
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
            
        }
        
        if ifhasNotch {
            playTimeBarBottomConstraint.constant = 20.0
        } else {
            playTimeBarBottomConstraint.constant = 0.0
        }
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
       
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
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
                
               // NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                
            }
           
           present(ac, animated: true, completion: nil)
           //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        
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
                
                
                
                _ = alert.showCustom("Hello \(global_username),", subTitle: "Awesome, but this user may turn off the challenge status, you can keep watching other highlight and challenge them to play together. Thank you from Stichbox Team.", color: UIColor.black, icon: icon!)
                
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
            
            
            
            _ = alert.showCustom("Hello \(global_username),", subTitle: "Awesome, but you can't challenge yourself. Let's challenge other users to get a some new gaming partners. Thank you so much from Stichbox Team.", color: UIColor.black, icon: icon!)
            
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
    
    @objc func ChallengeSend(text: String) {
        
       if challengeItem != nil, text != "" {
            
            checkPendingChallengeFromMe(receiver_ID: challengeItem.userUID) {
                
                self.checkPendingChallengeFromUser(receiver_ID: self.challengeItem.userUID) {
                    
                    
                    self.checkActiveChallengeFromMe(receiver_ID: self.challengeItem.userUID) {
                        
                        
                        self.checkActiveChallengeFromUser(receiver_ID: self.challengeItem.userUID) {
                            
                            self.checkIfExceedPendingChallenge(receiver_ID: self.challengeItem.userUID) {
                                
                                if self.challengeTextView.text != "", self.challengeTextView.text.count > 5 {
                                    
                                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                                        if let error = error {
                                            
                                            print(error.localizedDescription)
                                            self.showErrorAlert("Oops!", msg: "Can't verify your information to send challenge, please try again.")
                                            
                                        } else if let string = string {
                                            
                                            let device = UIDevice().type.rawValue
                                            
                                            var data = ["receiver_ID": self.challengeItem.userUID!, "sender_ID": Auth.auth().currentUser!.uid, "category": self.challengeItem.category!, "created_timeStamp": FieldValue.serverTimestamp(), "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp(), "Device": device, "challenge_status": "Pending", "uid_list": [self.challengeItem.userUID, Auth.auth().currentUser!.uid], "isPending": true, "isAccepted": false, "query": string, "current_status": "Valid", "highlight_Id": self.challengeItem.highlight_id!, "messages": text] as [String : Any]
                                            
                                            
                                            
                                            let db = DataService.instance.mainFireStoreRef.collection("Challenges")
                                            
                                            data.updateValue(string, forKey: "query")
                                            
                                            var ref: DocumentReference!
                                            
                                            ref = db.addDocument(data: data) {  (errors) in
                                                
                                                if errors != nil {
                                                    
                                                    self.showErrorAlert("Oops!", msg: errors!.localizedDescription)
                                                    return
                                                    
                                                }
                                                
                                              
                                                ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Send", toUserUID: self.challengeItem.userUID!, category: self.challengeItem.category, challengeid: ref.documentID, Highlight_Id: self.challengeItem.highlight_id)
                                                ActivityLogService.instance.updateChallengeNotificationLog(mode: "Send", category: self.challengeItem.category, userUID: self.challengeItem.userUID!, challengeid: ref.documentID, Highlight_Id: self.challengeItem.highlight_id)
                                                
                                                
                                                self.challengeTextView.text = ""
                                                self.view.endEditing(true)
                                                
                                                showNote(text: "Cool! You have succesfully sent a challenge to @\(self.challengeName)")
                                                
                                                
                                            }
                                            
                         
                                        }
                                    }
                                              
                                    
                                    
                                } else {
                                    
                                    self.showErrorAlert("Oops!", msg: "Please enter your challenge messages.")
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                    }
                }
            }
                  
        } else {
            
           
            //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
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
                                                                
                                                                
                                                                let index = self.findIndexFromPost(item: item)
                                                                self.posts[index] = item
                                                                self.collectionNode.reloadItems(at: [IndexPath(row: index, section: 0)])
                                                               
                                                                                                                               
                                                                
                                                                showNote(text: "Stream link updated!")
                                                                
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
    
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        isFeedVC = true
        self.setPortrait()
        self.dismiss(animated: true) {
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is CommentNotificationVC {
                    
                    if let update1 = vc as? CommentNotificationVC {
                        update1.resumeNotification()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
       
        //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeAllobserve")), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        self.setPortrait()
        isFeedVC = true
        self.dismiss(animated: true) {
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is CommentNotificationVC {
                    
                    if let update1 = vc as? CommentNotificationVC {
                        update1.resumeNotification()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func setting2BtnPressed(_ sender: Any) {
        
       
        if self.posts[currentIndex].userUID != Auth.auth().currentUser?.uid {
            
            self.setPortrait()
            setting()
            
        } else {
            
            self.setPortrait()
            self.performSegue(withIdentifier: "moveToVideoSetting", sender: nil)
            
        }
        
    }
    
    
    @IBAction func setting1BtnPressed(_ sender: Any) {
        
        
        if self.posts[currentIndex].userUID != Auth.auth().currentUser?.uid {
            
            self.setPortrait()
            setting()
            
        } else {
            
            self.setPortrait()
            self.performSegue(withIdentifier: "moveToVideoSetting", sender: nil)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "moveToVideoSetting"{
                if let destination = segue.destination as? VideoSettingVC
                {
                    
                    destination.selectedItem = self.posts[currentIndex]
                   
                    
                }
            } else if segue.identifier == "moveToUserProfileVC5"{
                if let destination = segue.destination as? UserProfileVC
                {
                    
                    destination.uid = self.userid
                      
                }
            } else if segue.identifier == "moveToViewVC1"{
                if let destination = segue.destination as? ViewVC
                {
                    
                    destination.selected_item = self.selected_item
                      
                }
            }
            
            
    }
    
    func setting() {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        let report = UIAlertAction(title: "Report", style: .destructive) { (alert) in
            
            /*
            let slideVC =  reportView()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self

            self.present(slideVC, animated: true, completion: nil)
            
            */
            
            let slideVC = reportView()
            
            slideVC.video_report = true
            slideVC.highlight_id = self.video_list[self.currentIndex].highlight_id//self.post.highlight_id
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self

            self.present(slideVC, animated: true, completion: nil)
            
            
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        sheet.addAction(report)
        sheet.addAction(cancel)

        
        self.present(sheet, animated: true, completion: nil)
        
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
        most_played_collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
        most_played_collectionView.delegate = self
        most_played_collectionView.dataSource = self
        loadMostPlayedList(uid: item.userUID)
        loadGeneralCardInfo(uid: item.userUID, cView: ChallengeView)
        loadChallengeCardInfo(uid: item.userUID, cView: ChallengeView)
        
        //
        self.cardView.addSubview(ChallengeView)
        ChallengeView.frame = self.cardView.layer.bounds
        ChallengeView.badgeWidth.constant = self.view.bounds.width * (150/428)
        ChallengeView.infoHeight.constant = self.view.bounds.height * (24/759)
        ChallengeView.userImgWidth.constant = self.view.bounds.width * (85/428)
        ChallengeView.userImgHeight.constant = self.view.bounds.width * (85/428)
        
        
    }
    
    func setupChallengeView(item: HighlightsModel){
    
        self.backgroundView3.isHidden = false
        self.cardView.alpha = 1.0
        
        UIView.transition(with: cardView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.cardView.isHidden = false
            
        })
    
    }
    
    
    func loadMostPlayedList(uid: String) {
        
        
        most_playDict.removeAll()
        final_most_playList.removeAll()
        //MostPlayed_history
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
                                        
                                        DispatchQueue.main.async { // Make sure you're on the main thread here
                                            
                                          
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
                            
                            
                            if let challenge_info = snapshot.data()!["challenge_info"] as? String {
                                
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
                image1Attachment.image = UIImage(named: "challenge")?.resize(targetSize: CGSize(width: 10, height: 10))
                image1Attachment.bounds = CGRect(x: 0, y: -2, width: 10, height: 10)
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
    
}

extension UserHighlightFeedVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let min = CGSize(width: self.bView.layer.frame.width, height: self.bView.layer.frame.height);
        let max = CGSize(width: self.bView.layer.frame.width, height: self.bView.layer.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return false
    }
    
}

extension UserHighlightFeedVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
           
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
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
            
            node.commentBtn = { (node) in
                
                self.setPortrait()
                self.openComment(item: post)
                
            }
            
            node.profileBtn = { (node) in
                
                self.setPortrait()
                self.openProfile(item: post)
                
            }
                
            node.viewBtn = { (node) in
                
                self.setPortrait()
                self.openView(item: post)
                
            }
            
            node.cardBtn = { (node) in
            
                self.setPortrait()
                self.opencard(item: post)
                  
            }
            
            
            delay(1.0) {
                if node.DetailViews != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                }
            }
            
            //
            return node
        }
    }
    
 
    func openProfile(item: HighlightsModel) {
        
        userid = item.userUID
        
        self.performSegue(withIdentifier: "moveToUserProfileVC5", sender: nil)

    }
    
    func openView(item: HighlightsModel) {
        
        selected_item = item
       
        self.performSegue(withIdentifier: "moveToViewVC1", sender: nil)

    }
    
    func openComment(item: HighlightsModel) {
        
        
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_assetID", isEqualTo: item.Mux_assetID!).whereField("Mux_playbackID", isEqualTo: item.Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                return
            }
            
            if snap?.isEmpty == true {
                
                self.showErrorAlert("Oops!", msg: "The comment for this highlight is disabled")
                return
                
            } else {
                
                //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
                self.isFeed = true
                self.currentItem = item
                
                let slideVC = CommentVC()
                
                slideVC.modalPresentationStyle = .custom
                slideVC.transitioningDelegate = self
                slideVC.currentItem = self.currentItem
                should_Play = false
                self.present(slideVC, animated: true, completion: nil)
                          
                
            }
            
        }
    
        
        
    }
    
    func hideAllSettings() {
        
        back1.isHidden = true
        setting2.isHidden = true
    }
    
    func showAllSettings() {
        
        back1.isHidden = false
        setting2.isHidden = false
        
    }
    

    @objc func updateSound() {
        
        if currentIndex != nil {
            
            if let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PostNode {
                
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
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if isAppear == true, currentIndex != nil {
            
            
            if UIDevice.current.orientation.isLandscape {
                
                   // bViewBottomConstraint.constant = 0
                
                   
                    hideAllSettings()
                    global_isLandScape = true
                
                } else {
                    
                   
                    
                    //bViewBottomConstraint.constant = 50
                    showAllSettings()
                    self.playTimeBar.isHidden = false
                    global_isLandScape = false
    
                }
            
            
            isAnimating = true
            
            if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: self.currentIndex, section: 0)) as? PostNode {
                
                cell.backgroundImageNode.isHidden = true
                
                coordinator.animate(alongsideTransition: { [unowned self] _ in
                    
                    cell.rotatingCell = true
                    
                    copyImage.backgroundColor = UIColor.clear
                    copyImage.contentMode = .scaleAspectFit
                    copyImage.image = cell.backgroundImageNode.image
                    
                    
                    view.addSubview(copyImage)
                    
                    self.copyImage.translatesAutoresizingMaskIntoConstraints = false
                    self.copyImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
                    self.copyImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
                    self.copyImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
                    self.copyImage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
                    
                    
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
                        cell.ButtonView.animationView.isHidden = true
                        cell.ButtonView.soundLbl.isHidden = false
                        cell.ButtonView.soundBtn.isHidden = false
                        
                        
                        //bViewBottomConstraint.constant = 0

                        
                    } else {
                        
                        
                        //bViewBottomConstraint.constant = 50
                        
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
      
                        delayItem.perform(after: 0.05) {
                           
                           
                            self.isAnimating = false
                            cell.rotatingCell = false
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
        
        _ = alert.showCustom("Hello, ", subTitle: "It seems like you'll have a better viewing experience in landscape mode. You can also continue to scroll infinitely as if you were in portrait mode.", color: UIColor.black, icon: icon!)
        
    }
    
    func checkIfGuideLandScape() {
    
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasGuideLandScapeBefore") == false {
           
            tryLandscape()
          
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasGuideLandScapeBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
            
            // Run code here for the first launch
            
        }
    
    }
    
    func openCell(cell: PostNode) {
        
       
        if currentIndex != nil {
            
            cell.shouldCountView = true
            self.playTimeBar.setProgress(0, animated: false)
            
           
            if !cell.videoNode.isPlaying() {
                cell.videoNode.play()
            }
           
            
            if !isFirstLoad {
                
                if let playerItem = cell.videoNode.currentItem {
                   
                    if !playerItem.isPlaybackLikelyToKeepUp  {
                        
                        print("checking1: checking back after 3s")
                        
                        delayItem4.perform(after: 3) {
                            
                            if cell.isVisible {
                                
                                if !playerItem.isPlaybackLikelyToKeepUp  {
                                    
                                    print("checking2: perform reset")
                                    cell.videoNode.asset = nil
                                    cell.videoNode.asset = AVAsset(url: cell.getVideoURLForRedundant_stream(post: cell.post)!)
                                   
                                    
                                }
                                
                            }
                            
                        }
                       
                    }

                    
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
            
            
            
            if UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height {
                
                showAllSettings()
                
            }
            
            

                delayItem2.perform(after: 0.05) {
                    
                    if cell.DetailViews != nil {
                        
                        if cell.animatedLabel != nil, cell.ButtonView != nil {
                            
                            
                            
                            cell.infoView.alpha = 1.0
                            cell.ButtonView.alpha = 1.0
                            
                            UIView.transition(with: cell.infoView.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                
                                cell.infoView.isHidden = false
                                cell.ButtonView.isHidden = false
                                
                                
                               
                            })
                            
                            
                        }
                        
                    }
                    
               
                    
                    if cell.is_challenge == true {
                        //cell.ButtonView.challengeBtn.beat()
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
        
        guard let cell = node as? PostNode else { return }
        
        
        if isAnimating == false {
            
          
            if cell.DetailViews != nil {
                
                cell.gradientNode.isHidden = false
                cell.DetailViews.isHidden = false
                cell.ButtonView.isHidden = false
                cell.backgroundImageNode.isHidden = false
                self.playTimeBar.isHidden = false
                
                if cell.animatedLabel != nil, cell.ButtonView != nil {
                    
                    cell.animatedLabel.restartLabel()
                  
                }
                
                if isSound == true {
                    
                    
                    cell.videoNode.muted = false
                    cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                    
        
                    
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
                    cell.ButtonView.animationView.isHidden = true
                    cell.ButtonView.soundLbl.isHidden = false
                    cell.ButtonView.soundBtn.isHidden = false
                    
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
            
            if willIndex != nil {
                if willIndex > currentIndex {
                    pausePreviousVideoIfNeed(pauseIndex: willIndex - 1)
                } else {
                    pausePreviousVideoIfNeed(pauseIndex: currentIndex)
                }
               
            }
        
            
        }
       
        
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        guard let cell = node as? PostNode else { return }
        
        endIndex = cell.indexPath?.row
        
        cell.videoNode.player?.seek(to: CMTime.zero)
        
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
    
    func setPortrait() {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

    }

    func checkVideoReady(row: Int, item: HighlightsModel) {
        
        let db = DataService.instance.mainFireStoreRef
        db.collection("Highlights").document(item.highlight_id).getDocument { (snap, err) in
            
            if err != nil {
                
                self.posts.remove(at: row)
                self.collectionNode.deleteItems(at: [IndexPath(row: row, section: 0)])
                print(err!.localizedDescription)
                return
            }
            
            
            if snap?.exists != false {
                
                if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String {
                    
                    if status == "Ready", !global_block_list.contains(owner_uid) {
                        
                        if item.origin_width/item.origin_height > 0.5, item.origin_width/item.origin_height < 0.6 {
                                
                            self.checkIfGuideLandScape()
                            
                        } else {
                            
                            let userDefaults = UserDefaults.standard
                            
                            if userDefaults.bool(forKey: "hasGuideSwipePlaySpeed") == false {
                                   
                                self.trySwipe()
                                
                                userDefaults.set(true, forKey: "hasGuideSwipePlaySpeed")
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
    
    
    //
    
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
    
    
    //
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.most_played_collectionView {
            return final_most_playList.count
        } else {
            return posts[collectionView.tag].hashtag_list.count
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
            
            //cell.backgroundColor = UIColor.red
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
            
            
        } else {
            
            let selectedHashtag = posts[collectionView.tag].hashtag_list[indexPath.row]
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoListWithHashtagVC") as? VideoListWithHashtagVC {
                
                vc.searchHashtag = selectedHashtag
                vc.modalPresentationStyle = .fullScreen
                      
                present(vc, animated: true)
                
                
            }
            
        }

        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == self.collectionNode.view {
            return 0.0
        } else if collectionView == self.most_played_collectionView {
           
            return 10.0
            
        } else {
            return 10.0
            
        }
      
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == self.collectionNode.view {
            return 0.0
        } else if collectionView == self.most_played_collectionView {
            
            return 10.0
            
        } else {
            return 10.0
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == self.most_played_collectionView {
            
            return CGSize(width: collectionView.layer.frame.height - 5, height: collectionView.layer.frame.height - 5)
            
        } else {
                
            return CGSize(width: 99, height: 30)
            
        }
        
        
        
    }

    
    func NoticeBlockAndDismiss() {
        
        let sheet = UIAlertController(title: "Oops!", message: "This user isn't available now.", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Got it", style: .default) { (alert) in
            
            self.setPortrait()
            self.dismiss(animated: true, completion: nil)
            
        }
        
        sheet.addAction(ok)

        
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
}

extension UserHighlightFeedVC {
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + newPosts.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newPosts {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            items.append(item)
          
        }
        
    
        self.posts.append(contentsOf: items)
        self.collectionNode.insertItems(at: indexPaths)
        
        
    }
    
   
    
    
}
