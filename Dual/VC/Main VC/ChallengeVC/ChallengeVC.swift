//
//  ChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/27/20.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire
import SendBirdUIKit
import SendBirdCalls
import AVFAudio
import SCLAlertView


class ChallengeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var allAActiveBtn: UIButton!
    @IBOutlet weak var allPastBtn: UIButton!
    @IBOutlet weak var allPendingBtn: UIButton!
    @IBOutlet weak var backgroundView2: UIView!
    @IBOutlet weak var editChallengeCardTxtField: UITextField!
    @IBOutlet weak var cardView2: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    var type: String!
    var userid: String!
    var challengeid: String!
    var shouldProcess = true
    var rate_index = 0
    var ChallengeView = ChallengeCard()
    var ChallengeView2 = ChallengeCard()
    var currentInfo = ""
    var most_playDict = [String:Int]()
    var final_most_playDict = [Dictionary<String, Int>.Element]()
    var final_most_playList = [String]()
    @IBOutlet weak var cardViewHeight: NSLayoutConstraint!
   
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var height2Constant: NSLayoutConstraint!
   

    @IBOutlet weak var ActiveTableView: UITableView!
    
    @IBOutlet weak var cardHeigh2: NSLayoutConstraint!
    @IBOutlet weak var cardHeigh1: NSLayoutConstraint!
    var maxItem = 3
    var didSetup = false
    
    var activeList = [ChallengeModel]()
    
    lazy var delayItem = workItem()
    var firstLoad = false
    
    private var pullControl = UIRefreshControl()
    
    @IBOutlet weak var viewAllPendingBtn: SSBadgeButton!
    @IBOutlet weak var viewAllActiveBtn: SSBadgeButton!
    @IBOutlet weak var viewAllPassBtn: SSBadgeButton!
    @IBOutlet weak var passChallengeCount: UILabel!
    //Challenges that expired
    var tap: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
        self.height2Constant.constant = 60
       
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ChallengeVC.closeKeyboard))
        tap.delegate = self
        
       
        
        ActiveTableView.delegate = self
        ActiveTableView.dataSource = self
        

        editChallengeCardTxtField.delegate = self
        editChallengeCardTxtField.returnKeyType = .done
        editChallengeCardTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        countChallenge(uid: Auth.auth().currentUser!.uid)
        
        loadProfile()
        
        loadActiveChallenge()
        
        
       
        
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        
        self.setupChallengeView()
       
        self.view.isUserInteractionEnabled = true
        
        loadMostPlayedList(uid: Auth.auth().currentUser!.uid)
        
        countPendingChallenge(uid: Auth.auth().currentUser!.uid)
        countActiveChallenge(uid: Auth.auth().currentUser!.uid)
        countExpiredChallenge(uid: Auth.auth().currentUser!.uid)
        
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
   
        
        if #available(iOS 10.0, *) {
            ActiveTableView.refreshControl = pullControl
        } else {
            ActiveTableView.addSubview(pullControl)
        }
        
        
        allPendingBtn.setTitle("", for: .normal)
        allPastBtn.setTitle("", for: .normal)
        allAActiveBtn.setTitle("", for: .normal)
        
        
    }
    
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        activeList.removeAll()
        ActiveTableView.reloadData()
        
        if challengevcListen != nil {
            challengevcListen.remove()
        }
        
        loadActiveChallenge()
        
    }
    
    
    
    func countPendingChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
       
        
        pendingChallengeCount = db.whereField("receiver_ID", isEqualTo: uid).whereField("challenge_status", isEqualTo: "Pending").whereField("current_status", isEqualTo: "Valid")
            
            .addSnapshotListener {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                if snapshot.isEmpty == true {
                    
                    self.viewAllPendingBtn.badge = nil
                
                } else {
                    

                    if snapshot.count == 0 {
                        
                        self.viewAllPendingBtn.badge = nil
                        
                    } else {
                        
                                             
                        if snapshot.count >= 100 {
                            self.viewAllPendingBtn.badge = "\(99)+"
                        } else {
                            self.viewAllPendingBtn.badge = "\(snapshot.count)"
                        }
                        
                    }
                  
                }
                
            }
        
    }
    
    func countActiveChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
       
        
        activeChallengeCount = db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Active").whereField("current_status", isEqualTo: "Valid")
            
            .addSnapshotListener {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                if snapshot.isEmpty == true {
                    
                    self.viewAllActiveBtn.badge = nil
                
                } else {
                    

                    if snapshot.count == 0 {
                        
                        self.viewAllActiveBtn.badge = nil
                        
                    } else {
                        
                                             
                        if snapshot.count >= 100 {
                            self.viewAllActiveBtn.badge = "\(99)+"
                        } else {
                            if snapshot.count > 3 {
                                self.viewAllActiveBtn.badge = "\(snapshot.count - 3)"
                            }
                            
                        }
                        
                    }
                  
                }
                
            }
        
    }
    
    
    func countExpiredChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
       
        
        expireChallengeCount = db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Expired").whereField("current_status", isEqualTo: "Valid")
            
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                if snapshot.isEmpty == true {
                    
                    self.viewAllPassBtn.badge = nil
                    self.passChallengeCount.text = "Challenges that expired"
                
                } else {
                    
                    
                    snapshot.documentChanges.forEach { diff in
                        
                        let item = ChallengeModel(postKey: diff.document.documentID, Challenge_model: diff.document.data())
                        
                        if self.findExistChallenge(challengeItem: item) == true {
                            
                            if let index = self.findIndexChallenge(challengeItem: item) {
                                
                                self.activeList.remove(at: index)
                                self.ActiveTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                                self.adjustHeight()
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    

                    if snapshot.count == 0 {
                        
                        self.viewAllPassBtn.badge = nil
                        self.passChallengeCount.text = "Challenges that expired"
                        
                    } else {
                        
                                             
                        if snapshot.count >= 100 {
                            self.passChallengeCount.text = "Challenges that expired - 99+"
                        } else {
                            self.passChallengeCount.text = "Challenges that expired - \(formatPoints(num: Double(snapshot.count)))"
                        }
                        
                    }
                  
                }
                
            }
        
    }
    
    
    
    
    
    
    @objc func closeKeyboard(sender: AnyObject!) {
        
        self.view.endEditing(true)
        ChallengeView.infoLbl.text = currentInfo
        backgroundView2.isHidden = true
    }
    
    
    func resetNotification(userUID: String) {
        
        DataService.init().mainFireStoreRef.collection("Challenge_notification_center").whereField("userUID", isEqualTo: userUID).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                let data = ["userUID": userUID, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue, "count": 0] as [String : Any]
                
                DataService.init().mainFireStoreRef.collection("Challenge_notification_center").addDocument(data: data)
                
            } else {
                
                for item in snapshot.documents {
                    
                    DataService.init().mainFireStoreRef.collection("Challenge_notification_center").document(item.documentID).updateData(["count": 0])
                }
                
            }
            
        }
        
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
        
        
        resetNotification(userUID: Auth.auth().currentUser!.uid)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasGuideEditChallengefore") == false {
           
            
            //self.tryLandscape()
            self.challengeAlert()
           
            // Update the flag indicator
            userDefaults.set(true, forKey: "hasGuideEditChallengefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
           
            
        }
     
    }
    
    func challengeAlert() {
        
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
        
        
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "You can hold a Stitchbox card for a second to edit the message on the card, all other gamers will see it. Let's change to something fun.", color: UIColor.black, icon: icon!)
       
    }
    
    func setupChallengeView(){
       
        if boundHeight == 0.00 {
            boundHeight = self.view.bounds.height
        }
        
        if boundWidth == 0.00 {
            boundWidth = self.view.bounds.width - 32
        }
       
        var newHeight = boundHeight * (230/759)
        
    
        if newHeight > 235 {
            newHeight = 240
        } else if newHeight < 235, newHeight > 179 {
            newHeight = 230
        } else {
            newHeight = 220
        }

        
        cardHeigh2.constant = newHeight
        cardHeigh1.constant = newHeight
        
        self.cardView.frame = CGRect(x: 0, y: 0, width: boundWidth, height: newHeight)
        self.cardView2.frame = CGRect(x: 0, y: 0, width: boundWidth, height: newHeight)
        
        ChallengeView.collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
        ChallengeView2.collectionView.register(ChallengeCell.nib(), forCellWithReuseIdentifier: ChallengeCell.cellReuseIdentifier())
        
        ChallengeView.collectionView.delegate = self
        ChallengeView.collectionView.dataSource = self
        ChallengeView2.collectionView.delegate = self
        ChallengeView2.collectionView.dataSource = self
        
        //
        self.cardView.addSubview(ChallengeView)
        self.cardView2.addSubview(ChallengeView2)
        
        //cardView.backgroundColor = UIColor.red
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: self.cardView.frame.width, height: self.cardView.frame.height - 45)
        button.backgroundColor = UIColor.clear
        self.cardView.addSubview(button)
        button.addTarget(self, action: #selector(ChallengeVC.openCard), for: .touchUpInside)
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ChallengeVC.settingBtnPressed(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        self.cardView.addGestureRecognizer(longPressGesture)
        
        
        ChallengeView.frame = self.cardView.frame
        ChallengeView2.frame = self.cardView.frame
        
      
        ChallengeView.badgeWidth.constant = self.view.bounds.width * (150/428)
        ChallengeView.infoHeight.constant = self.view.bounds.height * (24/759)
        ChallengeView.userImgWidth.constant = self.view.bounds.width * (85/428)
        ChallengeView.userImgHeight.constant = self.view.bounds.width * (85/428)
        
        //
        
        ChallengeView2.frame = self.cardView.layer.bounds
        ChallengeView2.badgeWidth.constant = self.view.bounds.width * (150/428)
        ChallengeView2.infoHeight.constant = self.view.bounds.height * (24/759)
        ChallengeView2.userImgWidth.constant = self.view.bounds.width * (85/428)
        ChallengeView2.userImgHeight.constant = self.view.bounds.width * (85/428)
         
        
    }
    
    
    @objc func settingBtnPressed(sender: AnyObject!) {
        
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editInfo = UIAlertAction(title: "Edit card information", style: .default) { (alert) in
            
            
            self.editChallengeCardTxtField.becomeFirstResponder()
            self.backgroundView2.isHidden = false
            
            
        }
        
        let viewCard = UIAlertAction(title: "View card", style: .default) { (alert) in
            
            self.openCard()
            
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
          
        
        sheet.addAction(editInfo)
        sheet.addAction(viewCard)
        sheet.addAction(cancel)
        
        
        self.present(sheet, animated: true, completion: nil)
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.addGestureRecognizer(tap)
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.removeGestureRecognizer(tap)
        textField.text = ""
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text != "" {
            
            ChallengeView.infoLbl.text = textField.text
            
        } else {
            
            ChallengeView.infoLbl.text = currentInfo
            
        }
       
        
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            
            if let text = self.editChallengeCardTxtField.text, text != "" {
                
                let db = DataService.instance.mainFireStoreRef
                db.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["challenge_info": text]) { error in
                    if error != nil {
                        
                        showNote(text: error!.localizedDescription)
                    } else {
                        showNote(text: "Stitchbox card infomation is updated")
                    }
                }
                
            }
            
            editChallengeCardTxtField.text = ""
            editChallengeCardTxtField.resignFirstResponder()
            backgroundView2.isHidden = true
            
            return false
            
        } else {
            
            
            return self.textLimit(existingText: self.editChallengeCardTxtField.text,
                                      newText: string,
                                      limit: 30)
            
        }
        
    }
    
    private func textLimit(existingText: String?,
                           newText: String,
                           limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if cardView2.isHidden == false {
            
            let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !cardView2.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.cardView2.alpha = 0
                }) { (finished) in
                    self.cardView2.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
            }
            
        }
        
        self.view.endEditing(true)
        backgroundView2.isHidden = true
        ChallengeView.infoLbl.text = currentInfo
        
    }
    
    func loadMostPlayedList(uid: String) {
        
        
        //MostPlayed_history
        let db = DataService.instance.mainFireStoreRef
    
        
        MostPlayed_history = db.collection("MostPlayed_history").whereField("userUID", isEqualTo: uid).limit(to: 100)
            
            .addSnapshotListener {  querySnapshot, error in
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
    
    
    
    
    
    
    func countChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef
    
        
        challengeListen2 = db.collection("Challenges").whereField("isPending", isEqualTo: false).whereField("current_status", isEqualTo: "Valid").whereField("isAccepted", isEqualTo: true).whereField("uid_list", arrayContains: uid)
            
            .addSnapshotListener {  querySnapshot, error in
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
                    
                    self.ChallengeView.challengeCount.attributedText = fullString
                    self.ChallengeView2.challengeCount.attributedText = fullString
                    
                } else {
                    
                    fullString.append(NSAttributedString(string: " \(formatPoints(num: Double(snapshot.count)))"))
                    self.ChallengeView.challengeCount.attributedText = fullString
                    self.ChallengeView2.challengeCount.attributedText = fullString
                }
                
            }
    }
    
    
    func loadProfile() {
        
        
        let db = DataService.instance.mainFireStoreRef
        let uid = Auth.auth().currentUser?.uid
        
        profileListen2 = db.collection("Users").document(uid!).addSnapshotListener { querySnapshot, error in
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
    
    
    func assignProfile(item: [String: Any]) {
        
        if let username = item["username"] as? String, let avatarUrl = item["avatarUrl"] as? String, let create_time = item["create_time"] as? Timestamp  {
            
            

            ChallengeView.username.text = username
            ChallengeView2.username.text = username
            
            let DateFormatter = DateFormatter()
            DateFormatter.dateStyle = .medium
            DateFormatter.timeStyle = .none
            ChallengeView.startTime.text = DateFormatter.string(from: create_time.dateValue())
            ChallengeView2.startTime.text = DateFormatter.string(from: create_time.dateValue())
            
            
            imageStorage.async.object(forKey: avatarUrl) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        
                        self.ChallengeView.userImgView.image = image
                        self.ChallengeView2.userImgView.image = image
                        
                        
                        //try? imageStorage.setObject(image, forKey: url)
                        
                    }
                    
                } else {
                    
                    
                 AF.request(avatarUrl).responseImage { response in
                        
                        
                        switch response.result {
                        case let .success(value):

                            self.ChallengeView.userImgView.image = value
                            self.ChallengeView2.userImgView.image = value
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
                ChallengeView2.infoLbl.text = challenge_info
                currentInfo = challenge_info
                
            } else {
                
                ChallengeView.infoLbl.text = "Stitchbox's challenger"
                ChallengeView2.infoLbl.text = "Stitchbox's challenger"
                currentInfo = "Stitchbox's challenger"
            }
            
        } else {
            
            ChallengeView.infoLbl.text = "Stitchbox's challenger"
            ChallengeView2.infoLbl.text = "Stitchbox's challenger"
            currentInfo = "Stitchbox's challenger"
            
        }
        
        
    }
    
    @objc func openCard() {
        
        
        self.backgroundView.isHidden = false
        self.cardView2.alpha = 1.0
        
        UIView.transition(with: cardView2, duration: 0.5, options: .transitionCrossDissolve, animations: {
            
            self.cardView2.isHidden = false
            self.ChallengeView2.collectionView.reloadData()
            
        })
        
        
                
    }
 

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
       
        return final_most_playList.count
        
    }
    
   
    
    @IBAction func allPastBtnPressed(_ sender: Any) {
        
        type = "Expired"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    
    @IBAction func allActiveBtnPressed(_ sender: Any) {
        
        type = "Active"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    
    @IBAction func allPendingBtnPressed(_ sender: Any) {
        
        type = "Pending"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
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
            controller.selected_userUID = Auth.auth().currentUser?.uid
            
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
    
    
    func loadActiveChallenge() {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        let uid = Auth.auth().currentUser?.uid
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        
        challengevcListen = db.whereField("uid_list", arrayContains: uid!).whereField("challenge_status", isEqualTo: "Active").whereField("current_status", isEqualTo: "Valid").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: maxItem).addSnapshotListener {  (snap, err) in
        
       
            snap!.documentChanges.forEach { diff in
                
                let item = ChallengeModel(postKey: diff.document.documentID, Challenge_model: diff.document.data())
                
                if (diff.type == .added) {
                    
                    
                    if item.challenge_status == "Active" {
                        
                        if self.findExistChallenge(challengeItem: item) == false {
                            if self.activeList.count == self.maxItem {
                                self.activeList.remove(at: 2)
                                self.ActiveTableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .none)
                                
                                self.activeList.insert(item, at: 0)
                                self.ActiveTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                            } else {
                                
                                self.activeList.insert(item, at: 0)
                                self.ActiveTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                                
                                
                            }
                        }
                        
                        self.adjustHeight()
                        
                    }
                            
                    
                    
                } else if (diff.type == .modified) {
                    
                    if item.challenge_status != "Active" {
                        
                        if self.findExistChallenge(challengeItem: item) == true {
                            
                            if let index = self.findIndexChallenge(challengeItem: item) {
                                
                                self.activeList.remove(at: index)
                                self.ActiveTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
        }
        
        
    }
    
    func findExistChallenge(challengeItem: ChallengeModel) -> Bool {
        
        for challenge in activeList {
            
            if challenge._challenge_id == challengeItem._challenge_id {
                return true
            }
            
            
        }
        
        return false
        
        
    }
    
    func findIndexChallenge(challengeItem: ChallengeModel) -> Int? {
        
        var count = 0
        for challenge in activeList {
             
            if challenge._challenge_id == challengeItem._challenge_id {
                return count
            }
            
            count += 1
            
            
        }
        
        return nil
        
    }
    
    func adjustHeight() {
        
        if self.activeList.count == 1 {
            self.height2Constant.constant = self.view.frame.height * (120/759)
        } else if self.activeList.count == 2 {
            self.height2Constant.constant = self.view.frame.height * (180/759)
        } else if self.activeList.count == 3 {
            self.height2Constant.constant = self.view.frame.height * (220/759)
        } else {
            self.height2Constant.constant = 60
        }
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return activeList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 25    //if you want round edges
        maskLayer.backgroundColor = UIColor.red.cgColor
        
        if tableView == self.ActiveTableView {
           
         
            let item = activeList[indexPath.row]
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveTableViewCell") as? ActiveTableViewCell {
                
                
                cell.configureCell(item)
                
                
                maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: tableView.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
                cell.layer.mask = maskLayer
                
                return cell
                
            } else {
                
                return ActiveTableViewCell()
            }
            
        } else {
            
            return ActiveTableViewCell()
            
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        for item_uid in self.activeList[indexPath.row].uid_list {
            
            if item_uid != Auth.auth().currentUser?.uid {
                
                self.userid = item_uid
           
            }
   
        }
        
        self.performSegue(withIdentifier: "moveToUserProfileVC1", sender: nil)
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75.0
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
       
        let size = CGFloat(70)
        let iconSize: CGFloat = 40.0
       
        
        let callImg = UIImage(named: "call")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
        let messImg = UIImage(named: "mess")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
        let closeImg = UIImage(named: "decline")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
        let viewImg = UIImage(named: "view")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
       
        let callAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
            
            self.makeCall(IndexPath(item: indexPath.row, section: 0))
            actionHandler(true)
            
        }
        
        let callTypeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
        ))
        callTypeView.layer.cornerRadius = iconSize/2
        callTypeView.backgroundColor = UIColor.clear
        callTypeView.image = callImg
        callTypeView.contentMode = .center
        
        callAction.image = callTypeView.asImage()
        callAction.backgroundColor = self.view.backgroundColor
        
        //
        
        let messAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
            
            self.MoveToChat(IndexPath(item: indexPath.row, section: 0))
            
            actionHandler(true)
        }
        
        let messTypeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
        ))
        messTypeView.layer.cornerRadius = iconSize/2
        messTypeView.backgroundColor = UIColor.clear
        messTypeView.image = messImg
        messTypeView.contentMode = .center
        
        messAction.image = messTypeView.asImage()
        messAction.backgroundColor = self.view.backgroundColor
        
        //
        
        let closeAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
        
            self.CloseAtIndexPath(IndexPath(item: indexPath.row, section: 0))
            
            actionHandler(true)
        }
        
        let closeTypeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
        ))
        closeTypeView.layer.cornerRadius = iconSize/2
        closeTypeView.backgroundColor = UIColor.clear
        closeTypeView.image = closeImg
        closeTypeView.contentMode = .center
        
        closeAction.image = closeTypeView.asImage()
        closeAction.backgroundColor = self.view.backgroundColor
        
        
        let viewAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
            
            self.ViewAtIndexPath(IndexPath(item: indexPath.row, section: 0))
            
            actionHandler(true)
        }
        
        let viewTypeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
        ))
        viewTypeView.layer.cornerRadius = iconSize/2
        viewTypeView.backgroundColor = UIColor.clear
        viewTypeView.image = viewImg
        viewTypeView.contentMode = .center
        
        viewAction.image = viewTypeView.asImage()
        viewAction.backgroundColor = self.view.backgroundColor
        
        return UISwipeActionsConfiguration(actions: [messAction, callAction, viewAction, closeAction])
        
    }
    
    func ViewAtIndexPath(_ path: IndexPath) {
           
        let item = activeList[(path as NSIndexPath).row]
        
        if let highlight_Id = item.highlight_Id {
            
            let db = DataService.instance.mainFireStoreRef
            
            
            db.collection("Highlights").document(highlight_Id).getDocument { (snap, err) in
                
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
                                        self.presentViewController(items: [i])
                                        
                                    }
                                    
                                } else if mode == "Public" {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    self.presentViewController(items: [i])
                                    
                                }
                                
                            } else{
                                
                                if owner_uid == Auth.auth().currentUser?.uid {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    self.presentViewController(items: [i])
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }

                
            }
            
        }
        
         
    }
    
    
    func presentViewController(items: [HighlightsModel]) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            
            controller.video_list = items
            controller.userid = items[0].userUID
            controller.startIndex = 0
            
            self.present(controller, animated: true, completion: nil)
            
        }
        
        
        
        
    }
    
    func deleteChannel(channel_url: String) {
        
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_channel_delete")
        
        AF.request(urlss!, method: .post, parameters: [
            
            "channel_url": channel_url
        
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON {  responseJSON in
                
                switch responseJSON.result {
                    
                case .success(_):
                    
                   print("")
                    
                case .failure(_):
                    
                    
                    print("")
                    
                }
                
            }
            
        
    }
    
    
    func OpenChallengeInformationAtIndexPath(_ path: IndexPath) {
        
        let item = activeList[(path as NSIndexPath).row]
        
        if let id = item.highlight_Id, id != "" {
            
            let db = DataService.instance.mainFireStoreRef
            
            db.collection("Highlights").document(id).getDocument { (snap, err) in
                
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
                                        
                                    }
                                    
                                } else if mode == "Public" {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    self.presentViewController(id: id, items: [i])
                                    
                                }
                                
                            } else{
                                
                                if owner_uid == Auth.auth().currentUser?.uid {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    self.presentViewController(id: id, items: [i])
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                           
                            
                        }
                        
                    }
                    
                }

                
            }
            
            
        }
        
        
    }
    
    
    func presentViewController(id: String, items: [HighlightsModel]) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            controller.video_list = items
            controller.userid = items[0].userUID
            controller.startIndex = 0
            
       
            
            self.present(controller, animated: true, completion: nil)
            
            
        }
 
        
    }
 
    
    func makeCall(_ path: IndexPath) {
        
        
        var callee = ""
        let item = activeList[(path as NSIndexPath).row]
        
        
        
        for i in item.uid_list {
            
            if i != Auth.auth().currentUser!.uid {
                
                callee = i
                break
                
            }
            
            
        }
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: callee, isVideoCall: false, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.presentErrorAlert(message: DialErrors.voiceCallFailed(error: error).localizedDescription)
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "moveToCallVC2", sender: call)
                
              
            }
        }
        
    }
    
    func MoveToChat(_ path: IndexPath) {
        
        //moveToChannelVC2
        
        let item = activeList[(path as NSIndexPath).row]

        
        let channelVC = ChannelViewController(
            channelUrl: "challenge-\(item._challenge_id!)",
            messageListParams: nil
        )
        
        
        let navigationController = UINavigationController(rootViewController: channelVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
        
        
               
    }

    
    func CloseAtIndexPath(_ path: IndexPath) {
              
        let item = activeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Expired", "updated_timeStamp": FieldValue.serverTimestamp(), "is_processed": false]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                }
                
                self.deleteChannel(channel_url: item._challenge_id)
                
            }
            
        }
   
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func viewAllPendingBtnPressed(_ sender: Any) {
        
        type = "Pending"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    
    @IBAction func viewAllActiveBtnPressed(_ sender: Any) {
        
        type = "Active"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    @IBAction func ViewAllExpireBtnPressed(_ sender: Any) {
        
        type = "Expired"
        performSegue(withIdentifier: "MoveToViewAllVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToViewAllVC"{
            if let destination = segue.destination as? ViewAllChallengeVC
            {
                
                destination.type = self.type
                destination.enabledSetting = true
                destination.viewUID = Auth.auth().currentUser?.uid
                
            }
        } else if segue.identifier == "moveToUserProfileVC1"
        {
            if let destination = segue.destination as? UserProfileVC
            {
                  
                destination.uid = self.userid
                  
            }
        } else if segue.identifier == "moveToCallVC2" {
            
            if var dataSource = segue.destination as? DirectCallDataSource, let call = sender as? DirectCall {
                dataSource.call = call
                dataSource.isDialing = true
            }
            
        }
        
    }
    
   
}
