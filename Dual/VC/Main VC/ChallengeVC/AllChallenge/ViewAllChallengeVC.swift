//
//  ViewAllChallengeVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/24/20.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire
import SendBirdUIKit
import SendBirdCalls
import SCLAlertView
import AsyncDisplayKit

class ViewAllChallengeVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var dismissBtn2: UIButton!
    @IBOutlet weak var dismissBtn1: UIButton!
    var challengeList = [ChallengeModel]()
    var type: String!
    var userid: String!
    var challengeid: String!
    var rate_index = 0
    var viewUID: String!
    var enabledSetting = false
    var istrack = false

    //var collectionNode: ASCollectionNode!
    var tableNode: ASTableNode!
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    
    private var pullControl = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.addSubview(tableNode.view)
       
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()

       
        if viewUID != nil {
            
            if type == "Pending" {
                loadPendingChallenges(uid: viewUID)
            } else if type == "Active" {
                loadActiveChallenge(uid: viewUID)
            } else{
                
                
                if istrack == true {
                    
                    if allChallengevcListen != nil {
                        allChallengevcListen.remove()
                    }
                    
                    loadExpireChallengeWithTrack(uid: viewUID)
                    
                } else {
                    
                    loadExpireChallenge(uid: viewUID)
                    
                }
 
                
            }
            
            
            pullControl.tintColor = UIColor.systemOrange
            pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
            
       
            
            if #available(iOS 10.0, *) {
                tableNode.view.refreshControl = pullControl
            } else {
                tableNode.view.addSubview(pullControl)
            }
            
            
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == "Pending" {
            
            let userDefaults = UserDefaults.standard
            
            delay(1) {
                
                if !self.challengeList.isEmpty {
                    
                    
                    if userDefaults.bool(forKey: "hasGuideChallengefore") == false {
                       
                        
                        //self.tryLandscape()
                        self.challengeAlert()
                       
                        // Update the flag indicator
                        userDefaults.set(true, forKey: "hasGuideChallengefore")
                        userDefaults.synchronize() // This forces the app to update userDefaults
                       
                        
                    }
                    
                }
                
                
                
                
                
            }
            
            
            
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
        
        
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "Awesome, you have received a pending challenge from other players. Now just swipe left, you can either decline or accept the challenge. Thank you and have fun playing with other players!", color: UIColor.black, icon: icon!)
       
    }
    
    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        

        reloadData()
        
    
        
        
    }
    
    func reloadData() {
        
        if viewUID != nil {
            
            self.challengeList.removeAll()
            //self.tableNode.reloadData()
            
            if type == "Pending" {
                loadPendingChallenges(uid: viewUID)
            } else if type == "Active" {
                loadActiveChallenge(uid: viewUID)
            } else{
                
                
                if istrack == true {
                    
                    loadExpireChallengeWithTrack(uid: viewUID)
                    
                } else {
                    
                    loadExpireChallenge(uid: viewUID)
                    
                }

                
            }
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if enabledSetting {
            
            let index = indexPath.row
            let item = self.challengeList[index]
            let size = CGFloat(70)
            let iconSize: CGFloat = 40.0
            
            
            let declineImg = UIImage(named: "decline")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
            let acceptImg = UIImage(named: "accept")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
            let viewImg = UIImage(named: "view")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
            
           
            if item.challenge_status == "Pending" {
                
                
                
                let acceptAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.AcceptAtIndexPath(IndexPath(item: indexPath.row, section: 0))
                    
                    actionHandler(true)
                }
                
                let acceptTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                
                acceptTypeView.layer.cornerRadius = iconSize/2
                acceptTypeView.backgroundColor = UIColor.clear
                acceptTypeView.image = acceptImg
                acceptTypeView.contentMode = .center
                
                acceptAction.image = acceptTypeView.asImage()
                acceptAction.backgroundColor = self.view.backgroundColor
                
                //
                
                let declineAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.RejectAtIndexPath(IndexPath(item: indexPath.row, section: 0))
                    
                    actionHandler(true)
                }
                
                let declineTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                declineTypeView.layer.cornerRadius = iconSize/2
                declineTypeView.backgroundColor = UIColor.clear
                declineTypeView.image = declineImg
                declineTypeView.contentMode = .center
                
                declineAction.image = declineTypeView.asImage()
                declineAction.backgroundColor = self.view.backgroundColor
                
                
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
                    
                
                return UISwipeActionsConfiguration(actions: [acceptAction, declineAction, viewAction])
                
                
            } else if item.challenge_status == "Active" {
                
                let callImg = UIImage(named: "call")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
                let messImg = UIImage(named: "mess")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
                let closeImg = UIImage(named: "decline")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
                
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
                
            } else if item.challenge_status == "Expired" {
                
                let starImg = UIImage(named: "star")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
                let reportImg = UIImage(named: "reports")!.resize(targetSize: CGSize(width: 25.0, height: 25.0))
                
                let starAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { [self] action, view, actionHandler in
                
                    
                    let rateViewController = CWRateKitViewController()
                    rateViewController.delegate = self
                    rateViewController.modalPresentationStyle = .formSheet
                    rateViewController.overlayOpacity = 0.8
                    rateViewController.animationDuration = 0.1
                                           
                    rateViewController.confirmRateEnabled = true
                    rateViewController.showCloseButton = true
                                           
                    rateViewController.showHeaderImage = true
                    rateViewController.headerImage = UIImage(named: "initial_smile")
                    rateViewController.headerImageSize = CGSize(width: 52.0, height: 52.0)
                    rateViewController.headerImageIsStatic = false
                                           
                    rateViewController.cornerRadius = 16.0
                    rateViewController.showShadow = true
                    rateViewController.animationType = .bounce
                                           
                    rateViewController.selectedMarkImage = UIImage(named: "star_selected.png")
                    rateViewController.unselectedMarkImage = UIImage(named: "star_unselected.png")
                    rateViewController.sizeMarkImage = CGSize(width: 30.0, height: 30.0)
                                           
                                           
                    rateViewController.hapticMoments = [.willChange, .willSubmit]
                                           
                    rateViewController.headerImages = [
                          UIImage(named: "smile_1"),
                          UIImage(named: "smile_2"),
                          UIImage(named: "smile_3"),
                          UIImage(named: "smile_4"),
                          UIImage(named: "smile_5")
                   ]
                                           
                   rateViewController.submitTextColor = .orange
                   rateViewController.submitText = "Send rate"
                                           
                                           
                   let uid_lis = self.challengeList[indexPath.row].uid_list
                   self.rate_index = indexPath.row
                                       
                   for item in uid_lis! {
                                               
                       if item != Auth.auth().currentUser?.uid {
                                                   
                                                   
                           self.userid = item
                           self.challengeid = self.challengeList[indexPath.row]._challenge_id
                           self.present(rateViewController, animated: true, completion: nil)
                                                   
                        }
                                               
                   }

                    
                    actionHandler(true)
                }
                
                let starTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                starTypeView.layer.cornerRadius = iconSize/2
                starTypeView.backgroundColor = UIColor.clear
                starTypeView.image = starImg
                starTypeView.contentMode = .center
                
                starAction.image = starTypeView.asImage()
                starAction.backgroundColor = self.view.backgroundColor
                
                //
                
                let reportAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                
                    let slideVC =  reportView()
                                                
                    slideVC.challenge_report = true
                    slideVC.challenge_id = self.challengeList[indexPath.row]._challenge_id
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = self
                                
                    self.present(slideVC, animated: true, completion: nil)

                    actionHandler(true)
                }
                
                let reportTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                reportTypeView.layer.cornerRadius = iconSize/2
                reportTypeView.backgroundColor = UIColor.clear
                reportTypeView.image = reportImg
                reportTypeView.contentMode = .center
                
                reportAction.image = reportTypeView.asImage()
                reportAction.backgroundColor = self.view.backgroundColor
                
                
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
                
                
                if self.challengeList[indexPath.row]._shouldShowRate == nil {
                                        
                   return nil
                                        
                } else {
                                        
                                        
                    if self.challengeList[indexPath.row]._shouldShowRate ==  true {
                                            
                    
                    return UISwipeActionsConfiguration(actions: [reportAction, starAction, viewAction])
                                            
                } else {
                  
                    return UISwipeActionsConfiguration(actions: [reportAction, viewAction])
                                            
                    }
                                        
                }

                
            } else {
                return nil
            }
             
        } else {
            return nil
        }
        
        
        
    }
    
    
    func ViewAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        
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

    
    
    
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }

    func applyStyle() {
        
   
        
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.view.allowsSelection = true
        self.tableNode.view.contentInsetAdjustmentBehavior = .never
        self.tableNode.needsDisplayOnBoundsChange = true
        
        
    }

    
    func loadPendingChallenges(uid: String) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
  
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("receiver_ID", isEqualTo: uid).whereField("challenge_status", isEqualTo: "Pending").whereField("current_status", isEqualTo: "Valid").whereField("created_timeStamp", isGreaterThan: myNSDate).limit(to: 20).getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                
                
                return
            }
            
                if snap?.isEmpty == true {
                    
                    return
                    
                } else {
                      
                    for item in snap!.documents {
                        
                        var updateDict = item.data()
                        updateDict.updateValue(self.viewUID!, forKey: "current_ID")
                        
                        
                        let dict = ChallengeModel(postKey: item.documentID, Challenge_model: updateDict)
                        self.challengeList.append(dict)
           
                    }
                    
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }
      
                    self.tableNode.reloadData()
       
                }
      
        }
     
    }
    
    func loadActiveChallenge(uid: String) {
        
        let current = getCurrentMillis()
        let comparedDate = current - (5 * 60 * 60 * 1000)
        let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Active").whereField("current_status", isEqualTo: "Valid").whereField("started_timeStamp", isGreaterThan: myNSDate).limit(to: 20).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
               
                return
            }
            
            if snap?.isEmpty == true {
                
                return
                
            } else {
                    
                for item in snap!.documents {
                    
                    
                    var updateDict = item.data()
                    updateDict.updateValue(self.viewUID!, forKey: "current_ID")
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: updateDict)
                    self.challengeList.append(dict)
                                
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                self.tableNode.reloadData()
                
            }
            
        
        }
        
        
    }
    
    
    func loadExpireChallenge(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Expired").whereField("current_status", isEqualTo: "Valid").whereField("isAccepted", isEqualTo: true).order(by: "updated_timeStamp", descending: true).limit(to: 20).getDocuments { (snap, err) in
       
            if err != nil {
                
                print(err!.localizedDescription)
               
                return
            }
            
            if snap?.isEmpty == true {
                
                return
                
            } else {
            
        
                for item in snap!.documents {
                    
                    
                    var updateDict = item.data()
                    updateDict.updateValue(self.viewUID!, forKey: "current_ID")
                    
                    
                    let dict = ChallengeModel(postKey: item.documentID, Challenge_model: updateDict)
                    
                    
                    var isContinue = true
                    
                    for item in dict.uid_list {
                        
                        
                        if global_block_list.contains(item) {
                            isContinue = false
                        }
                        
                    }
                    
                    
                    if isContinue == true {
                        self.challengeList.append(dict)
                    }
                    
                                
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                self.tableNode.reloadData()
                
            }
            
        
        }
        
    }
    
    
    func loadExpireChallengeWithTrack(uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        allChallengevcListen = db.whereField("uid_list", arrayContains: uid).whereField("challenge_status", isEqualTo: "Expired").whereField("current_status", isEqualTo: "Valid").whereField("isAccepted", isEqualTo: true).order(by: "updated_timeStamp", descending: true).limit(to: 20).addSnapshotListener { (snap, err) in
       
            
            guard let snapshot = snap else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                

                if  (diff.type == .added) {
                    
                    var updateDict = diff.document.data()
                    updateDict.updateValue(self.viewUID!, forKey: "current_ID")
                    
                    
                    let dict = ChallengeModel(postKey: diff.document.documentID, Challenge_model: updateDict)
                    
                    var isContinue = true
                    for item in dict.uid_list {
                        
                        if global_block_list.contains(item) {
                            
                            isContinue = false
                            
                        }
                        
                    }
                    
                    
                    if isContinue == true {
                        
                        
                        if self.challengeList.count == 20 {
                            self.challengeList.removeLast()
                        }
                        
                        
                        self.challengeList.append(dict)
                        
                        
                    }
                    
                    
                }
                
                if self.pullControl.isRefreshing == true {
                    self.pullControl.endRefreshing()
                }
                
                self.challengeList = self.challengeList.sorted(by: { $0.updated_timeStamp.compare($1.updated_timeStamp) == .orderedDescending })
                self.tableNode.reloadData()
                           
           }
            
        }
        
    }
    
    
    func OpenChallengeInformationAtIndexPath(_ path: IndexPath) {
        
        let item = challengeList[(path as NSIndexPath).row]
        
        if let id = item.highlight_Id, id != "" {
            
            
            
            let db = DataService.instance.mainFireStoreRef
            
            
            db.collection("Highlights").document(id).getDocument { [self] (snap, err) in
                
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
                                        presentViewController(id: id, items: [i])
                                        
                                    }
                                    
                                } else if mode == "Public" {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    presentViewController(id: id, items: [i])
                                    
                                }
                                
                            } else{
                                
                                if owner_uid == Auth.auth().currentUser?.uid {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    presentViewController(id: id, items: [i])
                                    
                                    
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
    
    
    func AcceptAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Active", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp(), "isPending": false, "isAccepted": true]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                
                self.challengeList.remove(at: path.row)
                self.tableNode.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                //self.tableNode.deleteItems(at: [IndexPath(row: path.row, section: 0)])
                
                for uid in item.uid_list {
                                  
                    self.update_most_play_list(category: item.category, uid: uid)
                    
                    if uid != Auth.auth().currentUser!.uid {
                        
                        InteractionLogService.instance.UpdateLastedInteractUID(id: uid)
                        ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Accept", toUserUID: uid, category: item.category, challengeid: item._challenge_id, Highlight_Id: item.highlight_Id)
                        ActivityLogService.instance.updateChallengeNotificationLog(mode: "Accept", category: item.category, userUID: uid, challengeid: item._challenge_id, Highlight_Id: item.highlight_Id)
                        break
                        
                    }
                    
                }
                
                self.CreateChallengeChatList(item: item)
                
            }
         
        }
  
    }
    
    func update_most_play_list(category: String, uid: String) {
        
        let mostPlayed_hist = ["userUID": uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": category, "type": "Challenge", "ChallengeID": "nil"]
        
        DataService.instance.mainFireStoreRef.collection("MostPlayed_history").addDocument(data: mostPlayed_hist)
        
    }
    
    
    func RejectAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Rejected", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                self.challengeList.remove(at: path.row)
                self.tableNode.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                //self.tableNode.deleteItems(at: [IndexPath(row: path.row, section: 0)])
                
                
                for uid in item.uid_list {
                    
                    if uid != Auth.auth().currentUser!.uid {
                        
                        ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Reject", toUserUID: uid, category: item.category, challengeid: item._challenge_id, Highlight_Id: item.highlight_Id)
                        break
                        
                    }
                    
                }
                
            }
            
        }
         
    }
    
   
    func CloseAtIndexPath(_ path: IndexPath) {
           
        let item = challengeList[(path as NSIndexPath).row]
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        if let item_id = item._challenge_id {
            
            
            db.document(item_id).updateData(["challenge_status": "Expired", "updated_timeStamp": FieldValue.serverTimestamp(), "is_processed": false]) { (err) in
                
                
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    return
                }
                
                self.challengeList.remove(at: path.row)
               
                self.tableNode.deleteRows(at: [IndexPath(row: path.row, section: 0)], with: .automatic)
                self.deleteChannel(channel_url: item._challenge_id)
                
            }
            
        }
        
 
    }
    
    
    func deleteChannel(channel_url: String) {
        
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_channel_delete")
        
        AF.request(urlss!, method: .post, parameters: [
            
            "channel_url": channel_url
        
            ])
            
            .validate(statusCode: 200..<500)
            
        
    }
    
    func CreateChallengeChatList(item: ChallengeModel) {
        
  
        getLogo(category: item.category, item: item)
        
        
           
    }
    
    func getLogo(category: String, item: ChallengeModel) {
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("short_name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for itemsed in snap!.documents {
                
                if let url = itemsed.data()["url"] as? String {
                                  
                  
                    // Create chat
                    
                    let title = "Challenge chat"
                    
                    let channelParams = SBDGroupChannelParams()
                    channelParams.isDistinct = false
                    channelParams.addUserId(item.uid_list[0])
                    channelParams.addUserId(item.uid_list[1])
                    if let id = item._challenge_id {
                        channelParams.channelUrl = "challenge-\(id)"
                    }
                    channelParams.coverUrl = url
                    channelParams.name = title
                    
                    for add_uid in item.uid_list {
                        
                        if add_uid != Auth.auth().currentUser?.uid {
                            
                            addToAvailableChatList(uid: [add_uid])
                            
                        } else {
                            
                            addToUserAvailableChatList(uid: add_uid)
                            
                        }
                        
                    }
                    
                    SBDGroupChannel.createChannel(with: channelParams) { (groupChannel, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                              
                        let channelVC = ChannelViewController(
                            channelUrl: groupChannel!.channelUrl,
                            messageListParams: nil
                        )
                        
                        
                        let navigationController = UINavigationController(rootViewController: channelVC)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true, completion: nil)
                        
                        // perform admin post
                        let urls = MainAPIClient.shared.baseURLString
                        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_admin_post")
                        
                        for user in item.uid_list {
                            if user != Auth.auth().currentUser?.uid {
                                self.acceptInviation(channelUrl: groupChannel!.channelUrl, user_id: user)
                                break
                            }
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            print("Admin message posts")
                            
                            AF.request(urlss!, method: .post, parameters: [
                                
                                "channel_url": groupChannel?.channelUrl
                            
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
            .responseJSON {  responseJSON in
                
                switch responseJSON.result {
                    
                case .success(_):
                    
                   print("")
                    
                case .failure(_):
                    
                    
                    print("")
                    
                }
                
            }
            
        
        
    }
    
    func makeCall(_ path: IndexPath) {
        
        
        var callee = ""
        let item = challengeList[(path as NSIndexPath).row]
           
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
                self.performSegue(withIdentifier: "moveToCallVC3", sender: call)
                
              
            }
        }
        
    }
    
    func MoveToChat(_ path: IndexPath) {
      
        let item = challengeList[(path as NSIndexPath).row]
        
       
        
        let channelVC = ChannelViewController(
            channelUrl: "challenge-\(item._challenge_id!)",
            messageListParams: nil
        )
        
        
        let navigationController = UINavigationController(rootViewController: channelVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfileVC2"
        {
            if let destination = segue.destination as? UserProfileVC
            {
                
               
                destination.uid = self.userid
                  
            }
        } else {
            
            if var dataSource = segue.destination as? DirectCallDataSource, let call = sender as? DirectCall {
                dataSource.call = call
                dataSource.isDialing = true
            }
            
            
        }
        
    }
  

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}


extension ViewAllChallengeVC: CWRateKitViewControllerDelegate {

    func didChange(rate: Int) {
        print("Current rate is \(rate)")
    }
    
   
    func didSubmit(rate: Int) {
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                self.showErrorAlert("Oops!", msg: "Can't verify your information to send challenge, please try again.")
                
            } else if let string = string {
                
                DispatchQueue.main.async() { [self] in
                    
                    let device = UIDevice().type.rawValue
                    
                    var data = [String:Any]()
                    
                    
                    data = ["from_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "rate_status": "valid", "challenge_id": challengeid!, "to_uid": userid!, "rate_value": rate, "query": string] as [String : Any]
                        
                        
                   let db = DataService.instance.mainFireStoreRef.collection("Challenge_rate")
                    
                    db.addDocument(data: data) { [self] (errors) in
                        
                        if errors != nil {
                                                        
                            print(errors!.localizedDescription)
                            return
                            
                        }
                        
                       
                        let item = challengeList[rate_index]
                        item._shouldShowRate = false
                        
                        self.tableNode.reloadData()
                        //self.tableNode.reloadItems(at: [IndexPath(row: rate_index, section: 0)])
                        
                    }
                    
                
                    
                    
                }
                
            }
            
        }
    }
    
    func didDismiss() {
        print("Dismiss the rate view")
    }
    
   
    
}


extension ViewAllChallengeVC: ASTableDelegate {
    
   
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    

}


extension ViewAllChallengeVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return self.challengeList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let user = self.challengeList[indexPath.row]
       
        return {
            
            let node = ChallengeNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            
            return node
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        for item_uid in challengeList[indexPath.row].uid_list {
                    
                    if item_uid != viewUID {
                 
                        userid = item_uid
                        
                    }
            
                }
               
        self.performSegue(withIdentifier: "moveToUserProfileVC2", sender: nil)
    }
    
        
}
