//
//  AccountActivityVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/7/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import SendBirdCalls
import SendBirdSDK
import FLAnimatedImage

class AccountActivityVC: UIViewController {

    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    var tableNode: ASTableNode!
    var UserActivityList = [UserActivityModel]()
    var item: UserActivityModel!
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        contentView.addSubview(tableNode.view)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        
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
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        //
     
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
          
        
        let activity = UserActivityList[indexPath.row]
        
        if activity.Field == "Highlight" {
            
            if activity.Action != "Delete" {
                
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
                    
                    let db = DataService.instance.mainFireStoreRef
                    
                    
                    db.collection("Highlights").document(activity.Highlight_Id).getDocument {  (snap, err) in
                        
                        if err != nil {
                            
                            print(err!.localizedDescription)
                            return
                        }
                        
                        if snap?.exists != false {
                            
                            if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String {
                                
                                if status == "Ready", !global_block_list.contains(owner_uid) {
                                    
                        
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    
                                    
                                    controller.modalPresentationStyle = .fullScreen
                                    controller.video_list = [i]
                                    controller.startIndex = 0
                                    
                                    controller.userid = i.userUID

                                    self.present(controller, animated: true, completion: nil)
                                                                              
                                    
                                }
                                
                            }
                            
                        }

                        
                    }
                    
                    
                }
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "This video was deleted")
                
            }
            
            
            
        } else if activity.Field == "Follow" {
            
            if let uid = activity.toUserUID {
                
                
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                    
                   
                    if !global_block_list.contains(uid) {
                        
                        controller.uid = uid
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    
                }
                
            
                
                
            }
            
            
            
        } else if activity.Field == "Comment" {
            
            if activity.type == "Reply" {
                
                
                if let CId = activity.CId, let reply_to_cid = activity.reply_to_cid, let Mux_playbackID = activity.Mux_playbackID, let root_id = activity.root_id, let Highlight_Id = activity.Highlight_Id, let category = activity.category, let owner_uid = activity.owner_uid {
                    
            
                    processComment(Mux_playbackID: Mux_playbackID, CId: CId, reply_to_cid: reply_to_cid, type: "Reply", root_id: root_id, Highlight_Id: Highlight_Id, category: category, owner_uid: owner_uid)
                    
                } else {
                    
                    print("Not enough data - reply")
                    
                }
                
                
                
            } else if activity.type == "Comment" {
                
                if let CId = activity.CId, let Mux_playbackID = activity.Mux_playbackID, let Highlight_Id = activity.Highlight_Id, let category = activity.category, let owner_uid = activity.owner_uid {
                    
                    
                    processComment(Mux_playbackID: Mux_playbackID, CId: CId, reply_to_cid: "", type: "Comment", root_id: "", Highlight_Id: Highlight_Id, category: category, owner_uid: owner_uid)
                    
                } else {
                    
                    
                    print("Not enough data - comment")
                }
                
                
            }
            
            
        } else if activity.Field == "Account" {
            
            item = UserActivityList[indexPath.row]
            self.performSegue(withIdentifier: "moveToLogInfomationVC", sender: nil)
            
        } else if activity.Field == "Challenge" {
        
            if let challengeid = activity.challengeid {
                
                DataService.instance.mainFireStoreRef.collection("Challenges").document(challengeid).getDocument { snapshot, err in
                    
                    if err != nil {
                        
                        print(err!.localizedDescription)
                        return
                    }
                    
                    if snapshot?.exists == true {
                        
                        
                        if let challenge_status = snapshot?.data()!["challenge_status"] as? String {
                            
                           if challenge_status == "Active" {
                                
                                self.activeFunctionForChallenge(item: activity)
                                
                           } else if challenge_status == "Expired" || challenge_status == "Rejected" {
                            
                            if let uid = activity.toUserUID {
                                            
                                            
                                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                                                
                                               
                                            if !global_block_list.contains(uid) {
                                                    
                                                controller.uid = uid
                                                controller.modalPresentationStyle = .fullScreen
                                                self.present(controller, animated: true, completion: nil)
                                                    
                                            }
                                                
                                                
                                    }
                                            
                                        
                                            
                                            
                                }

                            
                           }
                            
                            
                        } else {
                            print("No challenge_status")
                        }
                        
                    } else {
                        
                        print("Document no exist")
                        
                    }
                                
                    
                    
                }
                
                
                
            } else {
                
                print("No challengeid")
                
            }
            
            
            
        }
        
        
    }
    
    func activeFunctionForChallenge(item: UserActivityModel) {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let message = UIAlertAction(title: "Message", style: .default) { (alert) in
            
            self.MoveToChat(item: item)
                            
        }
        
        let call = UIAlertAction(title: "Call", style: .default) { (alert) in
            
            self.makeCall(item: item)
            
        }
        
        let close = UIAlertAction(title: "Close challenge", style: .destructive) { (alert) in
            
            self.CloseAtIndexPath(item: item)
            
            
        }
        
        let info = UIAlertAction(title: "View video", style: .default) { (alert) in
            
            self.OpenChallengeInformationAtIndexPath(item: item)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        sheet.addAction(message)
        sheet.addAction(call)
        sheet.addAction(info)
        sheet.addAction(close)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    func OpenChallengeInformationAtIndexPath(item: UserActivityModel) {
        
        if let id = item.Highlight_Id, id != "" {
            
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
  
    
    func AcceptAtIndexPath(item: UserActivityModel) {
           
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        
        db.document(item.challengeid).updateData(["challenge_status": "Active", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp(), "isPending": false, "isAccepted": true]) { (err) in
            
            
            if err != nil {
                
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                return
            }
            
            
            ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Accept", toUserUID: item.toUserUID, category: item.category, challengeid: item.challengeid, Highlight_Id: item.Highlight_Id)
            ActivityLogService.instance.updateChallengeNotificationLog(mode: "Accept", category: item.category, userUID: item.toUserUID, challengeid: item.challengeid, Highlight_Id: item.Highlight_Id)
            
            
            
            // update chat id for challenges
            self.CreateChallengeChatList(item: item)
                            
        }
        
        
    }
    
    func RejectAtIndexPath(item: UserActivityModel) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.document(item.challengeid).updateData(["challenge_status": "Rejected", "started_timeStamp": FieldValue.serverTimestamp(), "updated_timeStamp": FieldValue.serverTimestamp()]) { (err) in
            
            
            if err != nil {
                
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                
            }
            
            ActivityLogService.instance.UpdateChallengeActivityLog(mode: "Reject", toUserUID: item.toUserUID, category: item.category, challengeid: item.challengeid, Highlight_Id: item.Highlight_Id)
            
        }
        
        
    }
    
    func makeCall(item: UserActivityModel) {
        
        
        let callee = item.toUserUID
        
        
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: callee!, isVideoCall: false, callOptions: callOptions, customItems: [:])

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
                self.performSegue(withIdentifier: "moveToCallVC6", sender: call)
                
              
            }
        }
        
    }
    
    func CloseAtIndexPath(item: UserActivityModel) {
              
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.document(item.challengeid).updateData(["challenge_status": "Expired", "updated_timeStamp": FieldValue.serverTimestamp(), "is_processed": false]) { (err) in
            
            
            if err != nil {
                
                self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                
            }
            
            self.deleteChannel(channel_url: item.challengeid)
            
        }
   
    }
    
    func MoveToChat(item: UserActivityModel) {
        
        //moveToChannelVC2
        if let id = item.challengeid, id != "" {
            
            let channelVC = ChannelViewController(
                channelUrl: item.challengeid,
                messageListParams: nil
            )
            
            
            let navigationController = UINavigationController(rootViewController: channelVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            
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
    
    func CreateChallengeChatList(item: UserActivityModel) {
        
  
        self.getLogo(category: item.category, item: item)
        
        
           
    }
    
    
    func getLogo(category: String, item: UserActivityModel) {
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("name", isEqualTo: category).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
            
            for itemsed in snap!.documents {
                
                if let url = itemsed.data()["url2"] as? String {
                    
                            
                  
                    // Create chat
                    
                    let title = "Challenge chat"
                    
                    let channelParams = SBDGroupChannelParams()
                    channelParams.isDistinct = false
                    channelParams.addUserId(Auth.auth().currentUser!.uid)
                    channelParams.addUserId(item.toUserUID)
                    channelParams.channelUrl = item.challengeid
                    channelParams.coverUrl = url
                    channelParams.name = title
                    
                    
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
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            
                            print("Admin message posts")
                            
                            AF.request(urlss!, method: .post, parameters: [
                                
                                "channel_url": groupChannel?.channelUrl
                            
                                ])
                                
                                .validate(statusCode: 200..<500)
                                
                            
                        }
                        
                        
                    }
                    
                   
                    
                    
                  
                    
                }
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToLogInfomationVC"{
            if let destination = segue.destination as? LogInfomationVC
            {
                
                destination.item = self.item
                
            }
        
        }
    }
    
    func processComment(Mux_playbackID: String, CId: String, reply_to_cid: String, type: String, root_id: String, Highlight_Id: String, category: String, owner_uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_playbackID", isEqualTo: Mux_playbackID).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
            
            
            if err != nil {
                
                
                return
            }
            
            if snap?.isEmpty == true {
                
                
                return
                
            }
            
            self.checkCommentReady(Mux_playbackID: Mux_playbackID, CId: CId, reply_to_cid: reply_to_cid, type: type, root_id: root_id, Highlight_Id: Highlight_Id, category: category, owner_uid: owner_uid)
            
            
        }
        
        
        
    }
    
    func checkCommentReady(Mux_playbackID: String, CId: String, reply_to_cid: String, type: String, root_id: String, Highlight_Id: String, category: String, owner_uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Comments").document(CId).getDocument { (snap, err) in
            
            
            if err != nil {
                
                
                return
            }
            
            if let data = snap?.data() {
                
                
                if let status = data["cmt_status"] as? String, status == "valid" {
                    
                    
                    let slideVC = CommentNotificationVC()
                    slideVC.CId = CId
                    slideVC.get_reply_to_cid = reply_to_cid
                    slideVC.type = type
                    slideVC.root_id = root_id
                    slideVC.Highlight_Id = Highlight_Id
                    slideVC.Mux_playbackID = Mux_playbackID
                    slideVC.category = category
                    slideVC.owner_uid = owner_uid
                    
                    //
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = self
                    
                    
                    self.present(slideVC, animated: true, completion: nil)
                    
                    
                }
                
                
            }
             
            
        }
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentView.bounds
       
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
extension AccountActivityVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newUsers) in
            
            self.insertNewRowsInTableNode(newUsers: newUsers)
            
            context.completeBatchFetching(true)
            
        }
        
    }
       
    
}

extension AccountActivityVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
            
            if lastDocumentSnapshot == nil {
                
                query = db.collection("Account_activity").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).order(by: "timeStamp", descending: true).limit(to: 20)
                
                
            } else {
                
                query = db.collection("Account_activity").whereField("userUID", isEqualTo: Auth.auth().currentUser!.uid).order(by: "timeStamp", descending: true).limit(to: 20).start(afterDocument: lastDocumentSnapshot)
            }
            
            query.getDocuments {  (snap, err) in
                
                if err != nil {
                    
                    print(err!.localizedDescription)
                    return
                }
                    
                if snap?.isEmpty != true {
                    
                    print("Successfully retrieved \(snap!.count) activities.")
                    let items = snap?.documents
                    self.lastDocumentSnapshot = snap!.documents.last
                    DispatchQueue.main.async {
                        block(items!)
                    }
                    
                } else {
                    
                    let items = snap?.documents
                    DispatchQueue.main.async {
                        block(items!)
                    }
                  
                    
                }
                
                
            }
                
    }
    
    
    
    func insertNewRowsInTableNode(newUsers: [DocumentSnapshot]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        let section = 0
        var items = [UserActivityModel]()
        var indexPaths: [IndexPath] = []
        let total = self.UserActivityList.count + newUsers.count
        
        for row in self.UserActivityList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newUsers {

            let item = UserActivityModel(postKey: i.documentID, UserActivityModel: i.data()!)
            items.append(item)
          
        }
        
    
        self.UserActivityList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }
    
    
}

extension AccountActivityVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.UserActivityList.count == 0 {
            
            tableNode.view.setEmptyMessage("No activity")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.UserActivityList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let activity = self.UserActivityList[indexPath.row]
       
        return {
            
            let node = AccountActivityNode(with: activity)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    

        
}
