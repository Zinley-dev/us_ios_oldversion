//
//  CommentVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/1/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import AlamofireImage
import Cache
import FLAnimatedImage

class CommentVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var sendBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBtn: UIButton!
    var isSending = false
    @IBOutlet weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIImageView!
    var mention_list = [String]()
    var total = 0
    var isTitle = false
    @IBOutlet weak var totalCmtCount: UILabel!
    @IBOutlet weak var bView: UIView!
    var currentItem: HighlightsModel!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var reply_to_uid: String!
    var reply_to_cid: String!
    

    var CmtQuery: Query!
    var prev_id: String!
    
    var root_id: String!
    var index: Int!
    
    @IBOutlet weak var tView: UIView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    @IBOutlet weak var cmtTxtView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var placeholderLabel : UILabel!
    var CommentList = [CommentModel]()
    var tableNode: ASTableNode!
    
    
    //
    var hashtag_arr = [String]()
    var mention_arr = [String]()
    
    var previousTxtLen = 0
    var previousTxt = ""
    var isInAutocomplete = false
    
    
    var uid_dict = [String: String]()

    
    //private var pullControl = UIRefreshControl()
    
    //
    let searchResultContainerView = UIView()
    
    
    lazy var autocompleteVC: AutocompeteViewController = {
        let vc = AutocompeteViewController()
        searchResultContainerView.backgroundColor = UIColor.black
        
        
        self.searchResultContainerView.addSubview(vc.view)
        vc.view.frame = searchResultContainerView.bounds
    
        
        vc.userSearchcompletionHandler = { newMention, userUID in
            if newMention.isEmpty {
                return
            }
            
            let newMentionWithAt = "@" + newMention
            
            self.mention_arr[self.mention_arr.count - 1] = newMentionWithAt
            
            let curCmtTxt = self.cmtTxtView.text ?? ""
            let lastAt = curCmtTxt.lastIndex(of: "@")!
            let finalText = curCmtTxt[..<lastAt] + newMentionWithAt + " "
            
            
            self.cmtTxtView.text = String(finalText)
//            self.updatePrevCmtTxt()
            
            self.searchResultContainerView.isHidden = true
            vc.clearTable()
            self.isInAutocomplete = false
            
            self.uid_dict[newMention] = userUID
            
        }
        
        vc.hashtagSearchcompletionHandler = { newHashtag in
            
            if newHashtag.isEmpty {
                return
            }
            
            //already has pound sign
            let newHashtagWithPound = newHashtag
            
            self.hashtag_arr[self.hashtag_arr.count - 1] = newHashtagWithPound
            
            let curCmtTxt = self.cmtTxtView.text ?? ""
            let lastAt = curCmtTxt.lastIndex(of: "#")!
            let finalText = curCmtTxt[..<lastAt] + newHashtagWithPound + " "
            
            
            self.cmtTxtView.text = String(finalText)

            
            self.searchResultContainerView.isHidden = true
            vc.clearTable()
            self.isInAutocomplete = false
        }
        
        
        return vc
    }()
        
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

//        setup searchResultContainerView position
        searchResultContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultContainerView)
        NSLayoutConstraint.activate([
            searchResultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchResultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            searchResultContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            searchResultContainerView.bottomAnchor.constraint(equalTo: cmtTxtView.topAnchor, constant: -22),
        ])
        searchResultContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        searchResultContainerView.isHidden = true
        
        
        self.tableNode = ASTableNode(style: .plain)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        commentBtn.setTitle("", for: .normal)
        cmtTxtView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add comment..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (cmtTxtView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        cmtTxtView.addSubview(placeholderLabel)
        
        placeholderLabel.frame = CGRect(x: 5, y: (cmtTxtView.font?.pointSize)! / 2 - 5, width: 200, height: 30)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !cmtTxtView.text.isEmpty
        
        cmtTxtView.returnKeyType = .default
        
        checkIfHighlightTitleIsAComment()
        
        tView.addSubview(tableNode.view)
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 20
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        setupLongPressGesture()
        calculateToTalCmt()
        loadAvatar()
        
        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(CommentVC.calculateToTalCmt), userInfo: nil, repeats: true)
        
    }
    

    
    func loadAvatar() {
        
        if global_avatar_url != "" {
            
            asyncAvatar(avatarUrl: global_avatar_url)
            
        } else {
            
            let db = DataService.instance.mainFireStoreRef
            let uid = Auth.auth().currentUser?.uid
            
            db.collection("Users").document(uid!).getDocument {  querySnapshot, error in
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
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    self.avatarView.image = image
                    
                    //try? imageStorage.setObject(image, forKey: url)
                    
                }
                
            } else {
                
                
             AF.request(avatarUrl).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                        self.avatarView.image = value
                        try? imageStorage.setObject(value, forKey: avatarUrl)
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    func checkIfHighlightTitleIsAComment() {

        if currentItem.highlight_title != "nil" {
            
            isTitle = true
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("Comment_uid", isEqualTo: currentItem.userUID!).whereField("text", isEqualTo: currentItem.highlight_title!).whereField("is_title", isEqualTo: true).getDocuments { [self]  querySnapshot, error in
                
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.isEmpty != true {
                    
                    
                    for items in querySnapshot!.documents {
                        
                        let item = CommentModel(postKey: items.documentID, Comment_model: items.data())
                        self.CommentList.insert(item, at: 0)
                        isTitle = false
                        loadAllPinPost()
                        break
                        
                    }
                    
                    
                } else {
                    
                    isTitle = false
                    loadAllPinPost()
                    
                }
                
            }
            
          
            
            
        } else {
            
            isTitle = false
            loadAllPinPost()
            
            
        }
        
        
    }
    

    
    @objc func calculateToTalCmt() {
        
        if let Mux_playbackID = currentItem.Mux_playbackID {
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: Mux_playbackID).whereField("cmt_status", isEqualTo: "valid").getDocuments { [self]  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                if snapshot.isEmpty == true {
                    totalCmtCount.text = "No Comment"
                } else {
                    
                    
                    totalCmtCount.text = "\(snapshot.count) Comments"
                    
                    
                }
                
            }
              
        }
            
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        self.tableNode.reloadData()
        
        delay(1) {
            
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
    
    func loadAllPinPost() {
        
        let db = DataService.instance.mainFireStoreRef
        
     
        db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("is_title", isEqualTo: false).whereField("is_pinned", isEqualTo: true).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").order(by: "update_timestamp", descending: true).getDocuments { [self] (snap, err) in
            
            guard let snapshot = snap else {
                print("Error fetching snapshots: \(err!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                
                for items in snap!.documents {
                    
                    let item = CommentModel(postKey: items.documentID, Comment_model: items.data())
                    self.CommentList.append(item)
                    
                }
                
                wireDelegates()
                
                
            } else {
                
                wireDelegates()
                
            }
            
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        self.tableNode.frame = CGRect(x: 0, y: 0, width: self.tView.frame.width, height: self.tView.frame.height - 50)
        
    }
    
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
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
    
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewHeight.constant = textView.layer.frame.height + 25
        
        
        if let text = textView.text, text != "" {
            let curTxtLen = text.count
            print("pre: \(previousTxt), current: \(String(describing: textView.text))")
            if curTxtLen < previousTxtLen && !isInAutocomplete {
                handleDeletion()
            } else {
                checkCurrenText(text: text)
            }
        } else {
            
            uid_dict.removeAll()
            self.searchResultContainerView.isHidden = true
        }
       
    }
    
    func handleDeletion() {
        
        var txtBefore: String
        var targetTxt: String
            if let lastSpace = previousTxt.lastIndex(of: " ") {
                txtBefore = String(previousTxt[..<lastSpace])
                targetTxt = String(previousTxt[previousTxt.index(after: lastSpace)...])
                
            } else {
                txtBefore = ""
                targetTxt = previousTxt
            }
            print("target txt: " + targetTxt)
            if let firstOfTarget = targetTxt.first {
                print("first charactor: " + String(firstOfTarget))
                switch firstOfTarget {
                case "@":
                    print("delete @")
                    self.mention_arr.removeObject(targetTxt)
                    self.previousTxtLen = txtBefore.count
                    self.previousTxt = txtBefore
                    uid_dict[String(targetTxt.dropFirst())] = nil
                    self.cmtTxtView.text = txtBefore
                    print("target: " + targetTxt)
                case "#":
                    print("delete #")
                default:
                    print("normal delete")
                    updatePrevCmtTxt()
                    return
                }
            }
        updatePrevCmtTxt()
    }
        
    func checkCurrenText(text: String) {
        
       
        if hashtag_arr != text.findMHashtagText() {
            hashtag_arr = text.findMHashtagText()
            if !hashtag_arr.isEmpty {
                let hashtagToSearch = hashtag_arr[hashtag_arr.count - 1]
                print("User is looking for hashtag: \(hashtagToSearch)")
                let hashtagToSearchTrimmed = String(hashtagToSearch.dropFirst(1))
               
                if !hashtagToSearchTrimmed.isEmpty {
                    self.searchResultContainerView.isHidden = false
                    self.autocompleteVC.search(text: hashtagToSearchTrimmed, with: AutocompeteViewController.Mode.hashtag)
                    isInAutocomplete = true
                }
            }
            
        } else if mention_arr != text.findMentiontagText() {
            mention_arr = text.findMentiontagText()
            if !mention_arr.isEmpty {
                let userToSearch = mention_arr[mention_arr.count - 1]
                print("User is looking for user: \(userToSearch)")
                let userToSearchTrimmed = String(userToSearch.dropFirst(1))

                if !userToSearchTrimmed.isEmpty {
                    self.searchResultContainerView.isHidden = false
                    self.autocompleteVC.search(text: userToSearchTrimmed, with: AutocompeteViewController.Mode.user)
                    isInAutocomplete = true

                }
                
            }
        } else {
             
            print("Just normal text")
            self.searchResultContainerView.isHidden = true
            
        }
        self.updatePrevCmtTxt()
        
        print("Done")
        
    }
    
    func updatePrevCmtTxt() {
        self.previousTxtLen = self.cmtTxtView.text.count
        self.previousTxt = self.cmtTxtView.text
    }
    @IBAction func sendCommentBtnPressed(_ sender: Any) {
        
        if let text = self.cmtTxtView.text, text != "", isSending == false {
            
            isSending = true
            
            DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_assetID", isEqualTo: currentItem.Mux_assetID!).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
                
                
                if err != nil {
                    
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                if snap?.isEmpty == true {
                    
                    
                    if self.currentItem.userUID == Auth.auth().currentUser?.uid {
                        
                        self.isSending = false
                        self.showDisableAndEnable()
                        
                    } else {
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    return
                    
                } else {
                    
                    
                    if !global_block_list.contains(self.currentItem.userUID) {
                        
                        if self.reply_to_uid != nil {
                            
                            if !global_block_list.contains(self.reply_to_uid) {
                                
                                
                                if self.uid_dict.isEmpty != true {
                                    
                                    var check = false
                                    
                                    for (_, uid) in self.uid_dict {
                                        
                                        if global_block_list.contains(uid) {
                                            check = true
                                        }
                                        
                                    }
                                    
                                    if check == false {
                                        
                                        self.sendCommentBtn()
                                        
                                        
                                        
                                    } else {
                                        
                        
                                        self.isSending = false
                                        self.showErrorAlert("Oops!", msg: "You can't mention one or more users in your current comment.")
                                        
                                        
                                        
                                    }
                                    
                                    
                                } else {
                                    
                                    
                                    self.sendCommentBtn()
                                    
                                    
                                }
                                
                                
                                
                                
                            } else {
                                
                                self.isSending = false
                                self.showErrorAlert("Oops!", msg: "You can't reply to this user.")
                                
                            }
                            
                            
                            
                        } else {
                            
                            
                            if self.uid_dict.isEmpty != true {
                                
                                var check = false
                                
                                for (_, uid) in self.uid_dict {
                                    
                                    if global_block_list.contains(uid) {
                                        check = true
                                    }
                                    
                                }
                                
                                if check == false {
                                    
                                    self.sendCommentBtn()
                                    
                                    
                                    
                                } else {
                                    
                    
                                    self.isSending = false
                                    self.showErrorAlert("Oops!", msg: "You can't mention one or more users in your current comment.")
                                    
                                    
                                    
                                }
                                
                                
                            } else {
                                
                                
                                self.sendCommentBtn()
                               
                                
                            }
                            
                        }
                        
                        
                    } else {
                        
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    
                    
                    
                              
                    
                }
                
            }
            
        }
        
        
    }
    
  
    func showDisableAndEnable() {
        
        let sheet = UIAlertController(title: "Oops!", message: "The comment for this highlight is disabled.", preferredStyle: .actionSheet)
        
        
        let Enable = UIAlertAction(title: "Enable", style: .default) { (alert) in
            
            
            DataService.instance.mainFireStoreRef.collection("Highlights").document(self.currentItem.highlight_id).updateData(["Allow_comment": true]) { err in
                
                if err != nil {
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    return
                }
                
                showNote(text: "Comment is enabled!")
                
            }
            
            
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        
        sheet.addAction(Enable)
        sheet.addAction(cancel)
        
    
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    
    
    func sendCommentBtn() {
        // check condition
        
        //============================================
        
        if Auth.auth().currentUser?.isAnonymous != true, Auth.auth().currentUser?.uid != nil, !global_block_list.contains(currentItem.userUID) {
            
            
            if reply_to_uid != nil {
                
                if global_block_list.contains(reply_to_uid) {
                    
                    self.isSending = false
                    self.showErrorAlert("Oops!", msg: "You can't reply to this user now.")
                    return
                }
                
                
            }
            
            
            
            if let text = cmtTxtView.text, text != "" {
                
                
                for (_, value) in uid_dict {
                    
                    if !mention_list.contains(value) {
                        mention_list.append(value)
                    }
                    
                }
                
                
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                    if let error = error {
                        
                        print(error.localizedDescription)
                        self.isSending = false
                        self.showErrorAlert("Oops!", msg: "Can't verify your information to send comment, please try again.")
                        
                    } else if let string = string {
                        
                        DispatchQueue.main.async() { [self] in
                            
                            let device = UIDevice().type.rawValue
                            
                            var data = [String:Any]()
                          
                            if root_id != nil {
                                
                                data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": true, "Mux_playbackID": currentItem.Mux_playbackID!, "root_id": root_id!, "has_reply": false, "update_timestamp": FieldValue.serverTimestamp(), "reply_to": reply_to_uid!, "is_title": false, "owner_uid": currentItem.userUID!, "Highlight_Id": currentItem.highlight_id!, "category": currentItem.category!, "last_modified": FieldValue.serverTimestamp(), "is_pinned": false] as [String : Any]
                                
                                if reply_to_cid != nil {
                                    
                                    data.updateValue(reply_to_cid!, forKey: "reply_to_cid")
                                    
                                }
                                             
                                
                            } else {
                                
                                data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": false, "Mux_playbackID": currentItem.Mux_playbackID!, "root_id": "nil", "has_reply": false, "update_timestamp": FieldValue.serverTimestamp(), "is_title": false, "owner_uid": currentItem.userUID!, "Highlight_Id": currentItem.highlight_id!, "category": currentItem.category!, "last_modified": FieldValue.serverTimestamp(), "is_pinned": false] as [String : Any]
                                
                            }
                            
                            
                            let db = DataService.instance.mainFireStoreRef.collection("Comments")
                            data.updateValue(string, forKey: "query")
                            var ref: DocumentReference!
                            
                            ref = db.addDocument(data: data) {  [self] (errors) in
                                
                                if errors != nil {
                                    
                                    self.isSending = false
                                    self.showErrorAlert("Oops!", msg: errors!.localizedDescription)
                                    return
                                    
                                }
                                
                                
                                if !mention_list.isEmpty {
                                    
                                    
                                    for user in mention_list {
                                        
                                        data.updateValue(user, forKey: "mentioned_userUID")
                                        data.updateValue(ref.documentID, forKey: "CID")
                                        DataService.instance.mainFireStoreRef.collection("Comments_mentions").addDocument(data: data)
                                        
                                    }
                                    
                                 
                                    
                                }
                                
                                DataService.instance.mainFireStoreRef.collection("Highlights").document(currentItem.highlight_id).updateData(["updatedTimeStamp": FieldValue.serverTimestamp()])
                                
                                if root_id != nil {
                                    
                                    DataService.instance.mainFireStoreRef.collection("Comments").document(root_id).updateData(["has_reply": true, "update_timestamp": FieldValue.serverTimestamp()])
                                    
                                    
                                    ActivityLogService.instance.updateCommentActivytyLog(mode: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: reply_to_cid, type: "Reply", root_id: root_id, owner_uid: currentItem.userUID, isActive: true, Cmt_user_uid: Auth.auth().currentUser!.uid, userUID: Auth.auth().currentUser!.uid)
                                    
                                    //
                                    
                                    if reply_to_uid != Auth.auth().currentUser?.uid, reply_to_uid != nil {
                                        
                                        ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: reply_to_cid, type: "Reply", root_id: root_id, owner_uid: currentItem.userUID, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: reply_to_uid, Action: "Reply")
                                        
                                    }
                                    
                                    
                                    if !mention_list.isEmpty {
                                        
                                        for user in mention_list {
                                            
                                            if user != Auth.auth().currentUser?.uid {
                                                
                                                
                                                ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: reply_to_cid, type: "Mention", root_id: root_id, owner_uid: currentItem.userUID, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: user, Action: "Reply")
                                                
                                            }
                                            
                                            
                                            
                                            
                                        }
                                    }
                                    
                                                                                    
                                                                                          
                                } else {
                                    
                                    
                                    
                                    ActivityLogService.instance.updateCommentActivytyLog(mode: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: "", type: "Comment", root_id: "", owner_uid: currentItem.userUID, isActive: true, Cmt_user_uid: Auth.auth().currentUser!.uid, userUID: Auth.auth().currentUser!.uid)
                                    
                                                                    
                                    
                                    if Auth.auth().currentUser?.uid != currentItem.userUID {
                                        
                                        ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: "", type: "Comment", root_id: "", owner_uid: currentItem.userUID, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: currentItem.userUID, Action: "Comment")
                                        
                        
                                        
                                    }
                                    
                                    if !mention_list.isEmpty {
                                        
                                        for user in mention_list {
                                            
                                            if user != Auth.auth().currentUser?.uid {
                                                
                                                
                                                ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: currentItem.highlight_id, category: currentItem.category, Mux_playbackID: currentItem.Mux_playbackID, CId: ref.documentID, reply_to_cid: "", type: "Mention", root_id: "", owner_uid: currentItem.userUID, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: user, Action: "Comment")
                                                
                                            }
                                            
                                            
                                            
                                            
                                        }
                                    }
                                
                                    
                                }
                           
                                var start = 0
                                let item = CommentModel(postKey: ref.documentID, Comment_model: data)
         
                                
                                
                                if index != nil {
                                    
                                    start = index + 1
                                    self.CommentList.insert(item, at: index + 1)
                                    self.tableNode.insertRows(at: [IndexPath(row: index + 1, section: 0)], with: .none)
                                    tableNode.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                                    
                                } else {
                                    
                                    
                                    if currentItem.highlight_title != "nil" {
                                        
                                        if CommentList.isEmpty != true {
                                            
                                            if CommentList[0].is_title == true {
                                                
                                                start = 1
                                                self.CommentList.insert(item, at: 1)
                                                self.tableNode.insertRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                                                tableNode.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                                                
                                                
                                            } else {
                                                
                                                
                                                start = 0
                                                self.CommentList.insert(item, at: 0)
                                                self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                                                tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                                                
                                            }
                                            
                                            
                                        } else {
                                            
                                            start = 0
                                            self.CommentList.insert(item, at: 0)
                                            self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                                            tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                                            
                                        }
                                        
                                        
                                        
                                    } else {
                                        
                                        start = 0
                                        self.CommentList.insert(item, at: 0)
                                        self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                                        tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                                        
                                    }
                                     
                                }
                                
                                var updatePath: [IndexPath] = []
                                
                                for row in start ... CommentList.count - 1 {
                                    let path = IndexPath(row: row, section: 0)
                                    updatePath.append(path)
                                }
                                
                                
                                self.tableNode.reloadRows(at: updatePath, with: .automatic)


                                showNote(text: "Comment sent!")
                                calculateToTalCmt()
                                
                                root_id = nil
                                reply_to_uid = nil
                                reply_to_cid = nil
                                index = nil
                                self.isSending = false
                                
                                // remove all
                                uid_dict.removeAll()
                                mention_list.removeAll()
                                hashtag_arr.removeAll()
                                mention_arr.removeAll()
                                
                                //
                                self.searchResultContainerView.isHidden = true
                                
                                
                                cmtTxtView.text = ""
                                self.placeholderLabel.isHidden = !cmtTxtView.text.isEmpty
                                cmtTxtView.resignFirstResponder()
                                
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
        } else {
            
            self.showErrorAlert("Ops!", msg: "Please sign in to comment.")
            
        }
        
    }
     
    func checkduplicateLoading(post: CommentModel) -> Bool {
        
        
        for item in CommentList {
            
            if post.Comment_id == item.Comment_id {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        resumeVideoIfNeed()

        
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                bottomConstraint.constant = -keyboardHeight
              
                viewHeight.constant = cmtTxtView.layer.frame.height + 25
                avatarBottomConstraint.constant = 11
                sendBtnBottomConstraint.constant = 11
                textConstraint.constant = 8
                bView.isHidden = false
               
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
        
    }
    
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 0
       
        textConstraint.constant = 30
        avatarBottomConstraint.constant = 30
        sendBtnBottomConstraint.constant = 30
        bView.isHidden = true
        
        if cmtTxtView.text.isEmpty == true {
            placeholderLabel.text = "Add comment..."
            viewHeight.constant = 75
            
            
            root_id = nil
            reply_to_uid = nil
            reply_to_cid = nil
            index = nil
            
            // remove all
            uid_dict.removeAll()
            mention_list.removeAll()
            hashtag_arr.removeAll()
            mention_arr.removeAll()
            
            //
            self.searchResultContainerView.isHidden = true
                
 
        } else{
            viewHeight.constant = cmtTxtView.layer.frame.height + 41
        }
        
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    
}
extension CommentVC: ASTableDelegate {


    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 50);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            self.insertNewRowsInTableNode(newPosts: newPosts)
            
        
      
            context.completeBatchFetching(true)
            
            
        }
        
    }
    
    func loadReplied(item: CommentModel, indexex: Int, root_index: Int) {
        
        if let item_id = item.Comment_id {
            
            
            let db = DataService.instance.mainFireStoreRef
            
         
            if item.lastCmtSnapshot == nil {
                
              
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5)
                
                
            } else {
                
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5).start(afterDocument: item.lastCmtSnapshot)
            }
       
            CmtQuery.getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                guard snapshot.count > 0 else {
                    return
                }
                
                
                var actualPost = [QueryDocumentSnapshot]()
                
                for item in snapshot.documents {
                    
                    let check = CommentModel(postKey: item.documentID, Comment_model: item.data())
                    
                    
                    if self.checkduplicateLoading(post: check) == false {
                                        
                        actualPost.append(item)
                        
                    }
                    
                    
                }
                
                if actualPost.isEmpty != true {
                    
                    
                    let section = 0
                    var indexPaths: [IndexPath] = []

                    var last = 0
                    var start = indexex + 1
                    
                    
                    
                    for row in start...actualPost.count + start - 1 {
                        
                        let path = IndexPath(row: row, section: section)
                        indexPaths.append(path)
                        
                        last = row
                        
                    }
                    
                    
                    
                    for item in actualPost {
                        
                        var updatedItem = item.data()
                        
                        if item == actualPost.last {
                            
                            
                            updatedItem.updateValue(true, forKey: "has_reply")
                            
                        }
                        
                        
                        let items = CommentModel(postKey: item.documentID, Comment_model: updatedItem)
         
                        self.CommentList.insert(items, at: start)
                        
                        
                        if item == snapshot.documents.last {
                            
                            self.CommentList[start].lastCmtSnapshot = actualPost.last
                            
                        }
                        
                        start += 1
                        
                    }
                    
                    self.tableNode.insertRows(at: indexPaths,with: .none)
                    
                    self.CommentList[root_index].lastCmtSnapshot = actualPost.last
                    
                    
                    var updatePath: [IndexPath] = []
                    
                    for row in indexex + 1 ... self.CommentList.count - 1 {
                        let path = IndexPath(row: row, section: 0)
                        updatePath.append(path)
                    }
                    
                    
                    self.tableNode.reloadRows(at: updatePath, with: .automatic)
                    
                    
                    self.tableNode.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
                    
                        
                    
                }
            
                
            }
            
            
        }
        
        
    }
    
    func findCommentIndex(item: CommentModel) -> Int {
        
        var index = 0
        
        for comment in self.CommentList {
            
            if comment.Comment_uid == item.Comment_uid, comment.Comment_id == item.Comment_id {
                
                return index
            }
            
            index += 1
            
        }
        
        return -1
        
    }
    
    func ReplyBtn(item: CommentModel){
        
        
        if !global_block_list.contains(item.Comment_uid) {
            
            
            let cIndex = findCommentIndex(item: item)
            
            
            if cIndex != -1 {
                
                cmtTxtView.becomeFirstResponder()
                
                if let uid = CommentList[cIndex].Comment_uid {
                    getuserName(uid: uid)
                } else{
                    placeholderLabel.text = "Reply to @Undefined"
                }
                
                if CommentList[cIndex].isReply == false {
                    root_id = CommentList[cIndex].Comment_id
                    index = cIndex
                } else {
                    root_id = CommentList[cIndex].root_id
                    index = cIndex
                }
                
                
                reply_to_uid =  CommentList[cIndex].Comment_uid
                reply_to_cid =  CommentList[cIndex].Comment_id
                
                
                tableNode.scrollToRow(at: IndexPath(row: cIndex, section: 0), at: .top, animated: true)
                
            }
            
        }
        
    }
    
}


extension CommentVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        
        return self.CommentList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let post = self.CommentList[indexPath.row]
           
        return {
            let node = CommentNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.replyBtn = { (node) in
            
                self.ReplyBtn(item: post)
                  
            }
            
            node.reply = { (nodes) in
                
                if self.prev_id != nil {
                    
                    if self.prev_id != self.CommentList[indexPath.row].Comment_id {
                        
                        self.CmtQuery = nil
                        self.prev_id = self.CommentList[indexPath.row].Comment_id
                        
                    }
                    
                    
                } else {
                    
                    self.prev_id = self.CommentList[indexPath.row].Comment_id
                    
                }
                
  
                if post.root_id != "nil", post.has_reply == true {
                    
                    let newIndex = self.findIndexForRootCmt(post: post)
                    let newPost = self.CommentList[newIndex]
                               
                    
                    //post.update_timestamp!
                
                    var newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": true, "Mux_playbackID": post.Mux_playbackID!, "root_id": post.root_id!, "has_reply": false, "reply_to": post.reply_to!, "owner_uid": post.owner_uid!] as [String : Any]
                    
                    if post.update_timestamp != nil {
                        
                        newDict.updateValue(post.update_timestamp!, forKey: "update_timestamp")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "update_timestamp")
                        
                    }
                    
                    if post.last_modified != nil {
                        
                        newDict.updateValue(post.last_modified!, forKey: "last_modified")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "last_modified")
                        
                    }
                    
                    if post.is_title == true {
                        
                        newDict.updateValue(true, forKey: "is_title")
                        
                    } else {
                        
                        newDict.updateValue(false, forKey: "is_title")
                        
                    }
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: newPost, indexex: indexPath.row, root_index: newIndex)
                    
                    
                } else {
                    
                    
                    
                    var newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": false, "Mux_playbackID": post.Mux_playbackID!, "root_id": "nil", "has_reply": false, "reply_to": post.reply_to!, "is_title": false, "owner_uid": post.owner_uid!] as [String : Any]
                    
                    
                    if post.update_timestamp != nil {
                        
                        newDict.updateValue(post.update_timestamp!, forKey: "update_timestamp")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "update_timestamp")
                        
                    }
                    
                    if post.last_modified != nil {
                        
                        newDict.updateValue(post.last_modified!, forKey: "last_modified")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "last_modified")
                        
                    }
                    
                    if post.is_title == true {
                        
                        newDict.updateValue(true, forKey: "is_title")
                        
                    } else {
                        
                        newDict.updateValue(false, forKey: "is_title")
                        
                    }
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: post, indexex: indexPath.row, root_index: indexPath.row)
                    
                }
                
                
                
                
            }
            
            return node
        }
        
    }
    
    func findIndexForRootCmt(post: CommentModel) -> Int {
        
        index = 0
        
        
        for item in CommentList {
            
            
            if item.Comment_id == post.root_id
            {
                return index
                
            } else {
                
                index += 1
            }
            
        }
        
        return index
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
        //guard let cell = node as? PostNode else { return }
        
       
    
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
    
        
        // guard let cell = node as? PostNode else { return }
        
       
        
    }
    
    func getuserName(uid: String) {
        
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item["username"] as? String {
                        
                    
                        self.placeholderLabel.text = "Reply to @\(username)"
                        
                        
                    }
                    
                }
                
            }
            
            
            
            
        }
        
    }
 
        
}

extension CommentVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([QueryDocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
        //whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!)
     
        if lastDocumentSnapshot == nil {
            
          
            query = db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("is_title", isEqualTo: false).whereField("is_pinned", isEqualTo: false).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").order(by: "update_timestamp", descending: true).limit(to: 20)
            
            
        } else {
            
            query = db.collection("Comments").whereField("isReply", isEqualTo: false).whereField("is_title", isEqualTo: false).whereField("is_pinned", isEqualTo: false).whereField("Mux_playbackID", isEqualTo: currentItem.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").order(by: "update_timestamp", descending: true).start(afterDocument: lastDocumentSnapshot)
        }
        
        query.getDocuments { [self] (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                print("Successfully retrieved \(snap!.count) Comments.")
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
    
    func insertNewRowsInTableNode(newPosts: [QueryDocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        
        var actualPost = [QueryDocumentSnapshot]()
        
        
        for item in newPosts {
            
            let inputItem = CommentModel(postKey: item.documentID, Comment_model: item.data())
            
            if checkduplicateLoading(post: inputItem) != true {
                
                if !global_block_list.contains(inputItem.Comment_uid) {
                    
                    actualPost.append(item)
                    
                }
                
                
            }
            
        }
        
        guard actualPost.count > 0 else {
            return
        }
  
        var items = [CommentModel]()
        var indexPaths: [IndexPath] = []
        let total = self.CommentList.count + actualPost.count
        
        for row in self.CommentList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in actualPost {
            
            let item = CommentModel(postKey: i.documentID, Comment_model: i.data())
            items.append(item)
          
        }
        
    
        self.CommentList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        
    }
    

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        if !global_block_list.contains(CommentList[indexPath.row].Comment_uid) {
            
            cmtTxtView.becomeFirstResponder()
            
            if let uid = CommentList[indexPath.row].Comment_uid {
                getuserName(uid: uid)
            } else{
                placeholderLabel.text = "Reply to @Undefined"
            }
            
            if CommentList[indexPath.row].isReply == false {
                root_id = CommentList[indexPath.row].Comment_id
                index = indexPath.row
            } else {
                root_id = CommentList[indexPath.row].root_id
                index = indexPath.row
            }
            
            
            reply_to_uid =  CommentList[indexPath.row].Comment_uid
            reply_to_cid =  CommentList[indexPath.row].Comment_id
            
            
            tableNode.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
            
        }
        
       
       

    }
 


    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 0.5 second press
        longPressGesture.delegate = self
        self.tableNode.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableNode.view)
            if let indexPath = self.tableNode.indexPathForRow(at: touchPoint) {
                
                
                let uid = Auth.auth().currentUser?.uid
                tableNode.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
                
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                
                let report = UIAlertAction(title: "Report", style: .default) { (alert) in
                    
                    let slideVC =  reportView()
                    
                    
                    slideVC.comment_id = self.CommentList[indexPath.row].Comment_id
                    slideVC.comment_report = true
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = self
                    
                    
                    self.present(slideVC, animated: true, completion: nil)
                    
                    
                }
                
                let copy = UIAlertAction(title: "Copy", style: .default) { (alert) in
                    
                    UIPasteboard.general.string = self.CommentList[indexPath.row].text
                    showNote(text: "Copied")
                    
                    
                }
                
                let pin = UIAlertAction(title: "Pin", style: .default) {  [self] (alert) in
                    
                    let item = CommentList[indexPath.row]
                    pinCmt(items: item, indexPath: indexPath.row)
                    
                    
                }
                
                let unPin = UIAlertAction(title: "Unpin", style: .default) { [self] (alert) in
                    
                   
                    let item = CommentList[indexPath.row]
                    unPinCmt(items: item, indexPath: indexPath.row)
                    
                }
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { [self] (alert) in
                    
                    let item = CommentList[indexPath.row]
                    removeComment(items: item, indexPath: indexPath.row)
                    
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                    
                }
                
                
                if uid == self.currentItem.userUID {
                    
                    if CommentList[indexPath.row].is_title == false {
                        
                        if CommentList[indexPath.row].isReply == false {
                            
                            if CommentList[indexPath.row].is_pinned == true {
                                
                                sheet.addAction(unPin)
                                
                            } else {
                                
                                sheet.addAction(pin)
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    if uid == CommentList[indexPath.row].Comment_uid {
                              
                        if CommentList[indexPath.row].is_title == true {
                            
                            sheet.addAction(copy)
                            sheet.addAction(cancel)
                            
                        } else {
                            
                            sheet.addAction(copy)
                            sheet.addAction(delete)
                            sheet.addAction(cancel)
                            
                        }
                     
                        
                    } else {
                        
                        
                        sheet.addAction(copy)
                        sheet.addAction(report)
                        sheet.addAction(delete)
                        sheet.addAction(cancel)
                        
                    }
                    
                    
                } else {
                    
                    if uid == CommentList[indexPath.row].Comment_uid {
                        
                        sheet.addAction(copy)
                        sheet.addAction(delete)
                        sheet.addAction(cancel)
                        
                    } else {
                        
                        sheet.addAction(copy)
                        sheet.addAction(report)
                        sheet.addAction(cancel)
                        
                        
                    }
                    
                }
                
                
               
                self.present(sheet, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func pinCmt(items: CommentModel, indexPath: Int) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["is_pinned": true, "update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    
                    self.CommentList[indexPath]._is_pinned = true
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                    
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to pin this comment right now, please try again.")
            
            
        }
    }
    
    
    func unPinCmt(items: CommentModel, indexPath: Int) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["is_pinned": false, "update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.CommentList[indexPath]._is_pinned = false
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to unpin this comment right now, please try again.")
            
            
        }
        
    }
    
    
    func removeComment(items: CommentModel, indexPath: Int) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["cmt_status": "deleted", "update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.CommentList.remove(at: indexPath)
                    self.tableNode.deleteRows(at: [IndexPath(item: indexPath, section: 0)], with: .automatic)
                    
                    if items.root_id == "nil" {
                        
                        self.RemoveIndexOfChildComment(from: items, start: indexPath)
                        
                    }
                    
                    
                    showNote(text: "Comment deleted!")
                    self.calculateToTalCmt()
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to remove this comment right now, please try again.")
            
            
        }
        
 

    }
    
    
    func RemoveIndexOfChildComment(from: CommentModel, start: Int) {
        
        
        var indexPaths: [IndexPath] = []
    
        var indexex = 0
        //var count = 1
        if let root_id = from.Comment_id {
            
            
            for item in CommentList {
                
                if item.root_id == root_id {
                    
                    let indexPath = IndexPath(row: indexex, section: 0)
                    indexPaths.append(indexPath)
                    self.CommentList.remove(at: start)
 
                }
                
                
                indexex += 1
                
            }
         
        }
        
        self.tableNode.deleteRows(at: indexPaths, with: .automatic)
        
        
    }
    
    
}
