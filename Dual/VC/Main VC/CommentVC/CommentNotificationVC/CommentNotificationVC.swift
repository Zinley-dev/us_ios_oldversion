//
//  CommentNotificationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/18/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import FLAnimatedImage

class CommentNotificationVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var commentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBtn: UIButton!
    var isSending = false
    @IBOutlet weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var bView: UIView!
    var reply_to_uid: String!
    var get_reply_to_cid: String!
    var root_id: String!
    var index: Int!
    var CId: String!
    var type: String?
    var Mux_playbackID: String?
    var reply_to_cid: String?
    var Highlight_Id: String?
    var category: String?
    var owner_uid: String?

 
    
    //
    var CommentList = [CommentModel]()
    var tableNode: ASTableNode!
    
    //
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    //
    @IBOutlet weak var tView: UIView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    @IBOutlet weak var cmtTxtView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var placeholderLabel : UILabel!
    
    //
    var LoadPath: [IndexPath] = []
    
    
    //
    
    var hashtag_arr = [String]()
    var mention_arr = [String]()
    
    var previousTxtLen = 0
    var previousTxt = ""
    var isInAutocomplete = false
    
    
    var uid_dict = [String: String]()
    var mention_list = [String]()
    
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
//            self.updatePrevCmtTxt()
            
            self.searchResultContainerView.isHidden = true
            vc.clearTable()
            self.isInAutocomplete = false
        }
        
        
        return vc
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchResultContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultContainerView)
        NSLayoutConstraint.activate([
            searchResultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchResultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            searchResultContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            searchResultContainerView.bottomAnchor.constraint(equalTo: cmtTxtView.topAnchor, constant: 0),
        ])
        searchResultContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        searchResultContainerView.isHidden = true
        
        //
        
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
        
        //
        
        tView.addSubview(tableNode.view)
        
        
        self.wireDelegates()
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 20
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        setupLongPressGesture()
        loadAvatar()
        
        if owner_uid != nil, !global_block_list.contains(owner_uid!) {
            
            if type != nil, CId != nil {
                
                if type == "Comment" {
                    
                    loadComment(comment_id: CId) {
                        
                        self.checkIfUserHasReplyIntoComment(root_id: self.CId)
                        
                    }
                    
                    
                } else if type == "Reply" {
                    
                    if root_id != "" {
                           
                        if get_reply_to_cid == root_id {
                            
                            loadRootCmt(comment_id: root_id) {
                                
                                self.loadrepliedCmt()
                                
                            }
                                             
                            
                        } else {
                            
                            if get_reply_to_cid != nil {
                                
                                loadRootCmt(comment_id: root_id) {
                      
                                    self.loadBeforeCmt(comment_id: self.get_reply_to_cid) {
                                        
                                        self.loadrepliedCmt()
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                } else {
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
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
                
                if let is_suspend = snapshot.data()!["is_suspend"] as? Bool {
                    
                    if is_suspend == true {
                     
                    
                     
                    } else {
                     
                         if let avatarUrl = snapshot.data()!["avatarUrl"] as? String {
                             
                             global_avatar_url = avatarUrl
                             self.asyncAvatar(avatarUrl: global_avatar_url)
                             
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
    
    
    func resumeNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func loadRootCmt(comment_id: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").document(comment_id).getDocument { (snapshot, err) in
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if ((snapshot?.exists) != false) {
        
                if let cmt_status = snapshot!.data()!["cmt_status"] as? String {
                    
                    if cmt_status == "valid" {
                        
                        var newDict = snapshot!.data()
                        newDict?.updateValue(true, forKey: "IsNoti")
                      
                        
                        let cmt = CommentModel(postKey: snapshot!.documentID, Comment_model: newDict!)
                        self.CommentList.append(cmt)
                        completed()
                        
                    } else {
                        
                        self.tableNode.view.setEmptyMessage("Comment was removed!")
                        
                    }
                    
                    
                }
                      
            }
        }
        
    }
    
    func loadBeforeCmt(comment_id: String, completed: @escaping DownloadComplete) {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").document(comment_id).getDocument { (snapshot, err) in
            
            if err != nil {
                
                
                completed()
                return
            }
            
        
            if ((snapshot?.exists) != false) {
                
                if let cmt_status = snapshot!.data()!["cmt_status"] as? String {
                    
                    if cmt_status == "valid" {
                        
                        
                        var newDict = snapshot!.data()
                        newDict?.updateValue(true, forKey: "IsNoti")
                      
                        let cmt = CommentModel(postKey: snapshot!.documentID, Comment_model: newDict!)
                        self.CommentList.append(cmt)
                        
                        
                    }
                    
                    completed()
                    
                } else {
                    
                    completed()
                    
                }
                             
                
            } else {
                completed()
            }
        }
        
        
    }
    
    func loadrepliedCmt() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").document(CId).getDocument { (snapshot, err) in
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if ((snapshot?.exists) != false) {
              
                var updateCmt: CommentModel!
               
                if let cmt_status = snapshot!.data()!["cmt_status"] as? String {
                    
                    if cmt_status == "valid" {
                        
                        var newDict = snapshot!.data()
                        newDict?.updateValue(true, forKey: "IsNoti")
                       
                        let cmt = CommentModel(postKey: snapshot!.documentID, Comment_model: newDict!)
                        updateCmt = cmt
                        self.CommentList.append(cmt)
                        
                        //
                        
                        self.checkifAnyReplyToMyReply2()
                        
                        
                        //
                        
                        if updateCmt.isReply != false {
                            
                            self.root_id = updateCmt.root_id
                            self.index = self.findIndexForRootCmt(post: updateCmt)
                            
                        }
                        
                        
                        self.reply_to_uid =  updateCmt.Comment_uid
                        self.reply_to_cid =  updateCmt.Comment_id
                       
                        
                    } else {
                        
                        self.tableNode.view.setEmptyMessage("Comment was removed!")
                        
                    }
                }
                
                
                          
            }
        }
        
    }
    
    func checkifAnyReplyToMyReply2() {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").whereField("reply_to_cid", isEqualTo: CId!).whereField("cmt_status", isEqualTo: "valid").order(by: "timeStamp", descending: true).limit(to: 1).getDocuments { (snapshot, err) in
            
            if err != nil {
                
                
                let section = 0
           
                print(err!.localizedDescription)
                for row in 0...self.CommentList.count-1 {
                    let path = IndexPath(row: row, section: section)
                    self.LoadPath.append(path)
                }
                
               
                self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                
                return
            } else {
                
                if snapshot?.isEmpty != true {
                    
                    for item in snapshot!.documents {
                        
                        var newDict = item.data()
                        newDict.updateValue(true, forKey: "IsNoti")
                      
                        let cmt = CommentModel(postKey: item.documentID, Comment_model: newDict)
                        self.CommentList.append(cmt)
                        
                        
                        let section = 0
                        
                        print(self.CommentList.count)
                
                        for row in 0...self.CommentList.count-1 {
                            let path = IndexPath(row: row, section: section)
                            self.LoadPath.append(path)
                        }
                        
                       
                        self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                        
                        
                    }
                    
                    
                } else {
                    
                    let section = 0
                    
            
                    for row in 0...self.CommentList.count-1 {
                        let path = IndexPath(row: row, section: section)
                        self.LoadPath.append(path)
                    }
                    
                   
                    self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                    
                }
                
                
                
            }
            
            
        }
        

    }
    
    
    
    
    func loadComment(comment_id: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").document(comment_id).getDocument { (snapshot, err) in
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if ((snapshot?.exists) != false) {
                
                
                if let cmt_status = snapshot!.data()!["cmt_status"] as? String {
                    
                    if cmt_status == "valid" {
                        
                        var newDict = snapshot!.data()
                        newDict?.updateValue(true, forKey: "IsNoti")
                      
                        let cmt = CommentModel(postKey: snapshot!.documentID, Comment_model: newDict!)
                        
                        let section = 0
                        var indexPaths: [IndexPath] = []
                      

                        let path = IndexPath(row: 0, section: section)
                        indexPaths.append(path)
                        
                        
                        if cmt.isReply == false {
                            self.root_id = cmt.Comment_id
                            self.index = 0
                        }
                        
                        self.reply_to_uid =  cmt.Comment_uid
                        self.reply_to_cid =  cmt.Comment_id
                        
                        self.CommentList.append(cmt)
                        completed()
                        
                    } else {
                        
                        self.tableNode.view.setEmptyMessage("Comment was removed!")
                       
                        
                    }
                    
                }
                
                
                
                //self.tableNode.insertRows(at: indexPaths, with: .none)
                
                
            }
                     
            
        }
        
        
    }
    
    func checkIfUserHasReplyIntoComment(root_id: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").whereField("root_id", isEqualTo: root_id).whereField("Comment_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("cmt_status", isEqualTo: "valid").order(by: "timeStamp", descending: true).limit(to: 1).getDocuments { (snapshot, err) in
            
            
            if err != nil {
                
                let section = 0
                var indexPaths: [IndexPath] = []
                
                let path = IndexPath(row: 0, section: section)
                indexPaths.append(path)
                self.tableNode.insertRows(at: indexPaths, with: .none)
                
                print(err!.localizedDescription)
                return
            }
                
            if snapshot?.isEmpty != true {
                
                
                for item in snapshot!.documents {
                    
                    
                    var newDict = item.data()
                    newDict.updateValue(true, forKey: "IsNoti")
                  
                    let cmt = CommentModel(postKey: item.documentID, Comment_model: newDict)
                    self.CommentList.append(cmt)
                    
                    if let reply_to1 = item.data()["reply_to"] as? String, reply_to1 != "" {
                        
                        
                        if reply_to1 == Auth.auth().currentUser?.uid {
                            
                            let section = 0
                            
                    
                            for row in 0...self.CommentList.count-1 {
                                let path = IndexPath(row: row, section: section)
                                self.LoadPath.append(path)
                            }
                            
                           
                            self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                            
                            
                        } else {
                            
                            // load replied cmt
                            if let reply_to_cid1 = item.data()["reply_to_cid"] as? String, reply_to_cid1 != "" {
                                
                                if reply_to_cid1 != root_id {
                                    self.loadReplyCmtToCurrentCmt(reply_to_cid: reply_to_cid1)
                                } else {
                                    
                                    // load reply cmt to current cmt if have
                                    self.checkifAnyReplyToMyReply(reply_to_cid: item.documentID)
                                    
                                }
                                
                               
                                
                                
                            } else {
                                
                                let section = 0
                                
                        
                                for row in 0...self.CommentList.count-1 {
                                    let path = IndexPath(row: row, section: section)
                                    self.LoadPath.append(path)
                                }
                                
                               
                                self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                                
                                
                            }
                            
                            
                        }
                        
                        
                        
                        
                    } else {
                        
                        
                        let section = 0
                        
                
                        for row in 0...self.CommentList.count-1 {
                            let path = IndexPath(row: row, section: section)
                            self.LoadPath.append(path)
                        }
                        
                       
                        self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                        
                        
                    }
                    
                    
                    
                }
                
                
                
                
            } else {
                
                
                let section = 0
                var indexPaths: [IndexPath] = []
                
                let path = IndexPath(row: 0, section: section)
                indexPaths.append(path)
                self.tableNode.insertRows(at: indexPaths, with: .none)
                
                
            }
            
            
        }
        
    }
    
    func checkifAnyReplyToMyReply(reply_to_cid: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").whereField("reply_to_cid", isEqualTo: reply_to_cid).whereField("cmt_status", isEqualTo: "valid").order(by: "timeStamp", descending: true).limit(to: 1).getDocuments { (snapshot, err) in
            
            
            if err != nil {
                
                let section = 0
                
        
                for row in 0...self.CommentList.count-1 {
                    let path = IndexPath(row: row, section: section)
                    self.LoadPath.append(path)
                }
                
               
                self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                
                print(err!.localizedDescription)
                return
            }
                
            if snapshot?.isEmpty != true {
                
                for item in snapshot!.documents {
                    
                    
                    var newDict = item.data()
                    newDict.updateValue(true, forKey: "IsNoti")
                  
                    let cmt = CommentModel(postKey: item.documentID, Comment_model: newDict)
                    self.CommentList.append(cmt)
                    
                    
                    let section = 0
                    
            
                    for row in 0...self.CommentList.count-1 {
                        let path = IndexPath(row: row, section: section)
                        self.LoadPath.append(path)
                    }
                    
                   
                    self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                    
                    
                }
                
                
            } else {
                
                let section = 0
                
        
                for row in 0...self.CommentList.count-1 {
                    let path = IndexPath(row: row, section: section)
                    self.LoadPath.append(path)
                }
                
               
                self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                
                
            }
            
        }
        
    }
    
    func loadReplyCmtToCurrentCmt(reply_to_cid: String) {
        
      
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments").document(reply_to_cid).getDocument { (snapshot, err) in
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                return
            }
            
            if ((snapshot?.exists) != false) {
              
              
               
                if let cmt_status = snapshot!.data()!["cmt_status"] as? String {
                    
                    if cmt_status == "valid" {
                        
                        var newDict = snapshot!.data()
                        newDict?.updateValue(true, forKey: "IsNoti")
                       
                        let cmt = CommentModel(postKey: snapshot!.documentID, Comment_model: newDict!)
                        
                        self.CommentList.insert(cmt, at: 1)
                        
                        //
                        
                        
                       
                        
                    }
                }
                
                let section = 0
                
        
                for row in 0...self.CommentList.count-1 {
                    let path = IndexPath(row: row, section: section)
                    self.LoadPath.append(path)
                }
                
               
                self.tableNode.insertRows(at: self.LoadPath, with: .automatic)
                                 
            } else {
                print("Empty")
            }
        }
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        resumeVideoIfNeed()

        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
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
    
    func updatePrevCmtTxt() {
        self.previousTxtLen = self.cmtTxtView.text.count
        self.previousTxt = self.cmtTxtView.text
    }
    
    func handleDeletion() {
        print("handle deletion")
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
        
        print("Mentionarr: \(mention_arr)")
        
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
//                    self.autocompleteVC.searchUsers(searchText: userToSearchTrimmed)
                }
                
            }
        } else {
             
            print("Just normal text")
            self.searchResultContainerView.isHidden = true
            
        }
        self.updatePrevCmtTxt()
        
        print("Done")
        
    }
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        
        if let text = self.cmtTxtView.text, text != "", isSending == false {
            isSending = true
            DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_playbackID", isEqualTo: Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments { (snap, err) in
                
                
                if err != nil {
                    
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                if snap?.isEmpty == true {
                    
                    
                    if self.owner_uid == Auth.auth().currentUser?.uid {
                        
                        self.isSending = false
                        self.showDisableAndEnable()
                        
                    } else {
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                    
                    return
                    
                } else {
                    
                    if !global_block_list.contains(self.owner_uid!) {
                        
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
            
            
            DataService.instance.mainFireStoreRef.collection("Highlights").document(self.Highlight_Id!).updateData(["Allow_comment": true]) { err in
                
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
        
        if Auth.auth().currentUser?.isAnonymous != true, Auth.auth().currentUser?.uid != nil, !global_block_list.contains(owner_uid!), reply_to_uid != nil {
            
            if let text = cmtTxtView.text, text != "" {
                
                for (_, value) in uid_dict {
                    
                    if !mention_list.contains(value) {
                        mention_list.append(value)
                    }
                    
                }
                
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                    if let error = error {
                        
                        self.isSending = false
                        print(error.localizedDescription)
                        self.showErrorAlert("Oops!", msg: "Can't verify your information to send challenge, please try again.")
                        
                    } else if let string = string {
                        
                        DispatchQueue.main.async {
                            
                            let device = UIDevice().type.rawValue
                            
                            var data = [String:Any]()
                            
                            if self.root_id != nil {
                                
                                data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": true, "Mux_playbackID": self.Mux_playbackID!, "root_id": self.root_id!, "has_reply": false, "Update_timestamp": FieldValue.serverTimestamp(), "reply_to": self.reply_to_uid!, "is_title": false, "owner_uid": self.owner_uid!, "Highlight_Id": self.Highlight_Id!, "category": self.category!] as [String : Any]
                                
                                if self.reply_to_cid != nil {
                                    
                                    data.updateValue(self.reply_to_cid!, forKey: "reply_to_cid")
                                    
                                }
                                             
                                
                            } else {
                                
                                data = ["Comment_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "text": text, "cmt_status": "valid", "isReply": false, "Mux_playbackID": self.Mux_playbackID!, "root_id": "nil", "has_reply": false, "Update_timestamp": FieldValue.serverTimestamp(), "is_title": false, "owner_uid": self.owner_uid!, "Highlight_Id": self.Highlight_Id!, "category": self.category!] as [String : Any]
                                
                            }
                            
                            
                            let db = DataService.instance.mainFireStoreRef.collection("Comments")
                            var ref: DocumentReference!
                            data.updateValue(string, forKey: "query")
                            
                            
                            ref = db.addDocument(data: data) {  (errors) in
                         
                         if errors != nil {
                             
                             self.isSending = false
                             self.showErrorAlert("Oops!", msg: errors!.localizedDescription)
                             return
                             
                         }
                         
                                if !self.mention_list.isEmpty {
                             
                             
                                    for user in self.mention_list {
                                 
                                 data.updateValue(user, forKey: "mentioned_userUID")
                                 data.updateValue(ref.documentID, forKey: "CID")
                                 DataService.instance.mainFireStoreRef.collection("Comments_mentions").addDocument(data: data)
                                 
                             }
                             
                                                                                  
                         }
                         
                         
                                if self.root_id != nil {
                             
                                    DataService.instance.mainFireStoreRef.collection("Comments").document(self.root_id).updateData(["has_reply": true, "Update_timestamp": FieldValue.serverTimestamp()])
                             
                                    ActivityLogService.instance.updateCommentActivytyLog(mode: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: self.reply_to_cid!, type: "Reply", root_id: self.root_id, owner_uid: self.owner_uid!, isActive: true, Cmt_user_uid: Auth.auth().currentUser!.uid, userUID: Auth.auth().currentUser!.uid)
                             
                             
                                    if self.reply_to_uid != Auth.auth().currentUser?.uid, self.reply_to_uid != nil {
                                 
                                        ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: self.reply_to_cid!, type: "Reply", root_id: self.root_id, owner_uid: self.owner_uid!, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: self.reply_to_uid, Action: "Reply")
                                 
                             }
                             
                                    if !self.mention_list.isEmpty {
                                 
                                        for user in self.mention_list {
                                     
                                     if user != Auth.auth().currentUser?.uid {
                                         
                                         
                                         ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: self.reply_to_cid!, type: "Mention", root_id: self.root_id, owner_uid: self.owner_uid!, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: user, Action: "Reply")
                                         
                                     }
                                                                                                  
                                 }
                             }
                             
                             
                         } else {
                             
                             ActivityLogService.instance.updateCommentActivytyLog(mode: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: "", type: "Comment", root_id: "", owner_uid: self.owner_uid!, isActive: true, Cmt_user_uid: Auth.auth().currentUser!.uid, userUID: Auth.auth().currentUser!.uid)
                             
                             
                             if Auth.auth().currentUser?.uid != self.owner_uid {
                                 
                                 ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: "", type: "Comment", root_id: "", owner_uid: self.owner_uid!, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: self.owner_uid!, Action: "Comment")
            
                             }
                             
                             if !self.mention_list.isEmpty {
                                 
                                 for user in self.mention_list {
                                     
                                     if user != Auth.auth().currentUser?.uid {
                                         
                                         
                                         ActivityLogService.instance.updateCommentNotificationLog(Field: "Comment", Highlight_Id: self.Highlight_Id!, category: self.category!, Mux_playbackID: self.Mux_playbackID!, CId: ref.documentID, reply_to_cid: "", type: "Mention", root_id: "", owner_uid: self.owner_uid!, isActive: false, fromUserUID: Auth.auth().currentUser!.uid, userUID: user, Action: "Comment")
                                         
                                     }
                                                                                                             
                                 }
                             }
                             
                         }
                    
                         var start = 0
                         let item = CommentModel(postKey: ref.documentID, Comment_model: data)
  
                         
                         
                                if self.index != nil {
                                    start = self.index + 1
                                    self.CommentList.insert(item, at: self.index + 1)
                                    self.tableNode.insertRows(at: [IndexPath(row: self.index + 1, section: 0)], with: .none)
                                    self.tableNode.scrollToRow(at: IndexPath(row: self.index, section: 0), at: .top, animated: true)
                             
                         } else {
                             
                             start = 0
                             self.CommentList.insert(item, at: 0)
                             self.tableNode.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                             self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                             
                         }
                         
                  
                         
                         var updatePath: [IndexPath] = []
                         
                                for row in start ... self.CommentList.count - 1 {
                             let path = IndexPath(row: row, section: 0)
                             updatePath.append(path)
                         }
                         
                         
                         self.tableNode.reloadRows(at: updatePath, with: .automatic)


                     
                         showNote(text: "Comment sent!")
                         
                         
                         
                         self.isSending = false
                         //
                         
                         // remove all
                                self.uid_dict.removeAll()
                                self.mention_list.removeAll()
                                self.hashtag_arr.removeAll()
                                self.mention_arr.removeAll()
                         
                         //
                         self.searchResultContainerView.isHidden = true
                         
                         
                                self.cmtTxtView.text = ""
                                self.placeholderLabel.isHidden = !self.cmtTxtView.text.isEmpty
                                self.cmtTxtView.resignFirstResponder()
                         
                     }
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
        } else {
            
            self.showErrorAlert("Ops!", msg: "You can't reply to this comment.")
            
        }
        
        
        
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                bottomConstraint.constant = keyboardHeight
                viewHeight.constant = cmtTxtView.layer.frame.height + 25
                avatarBottomConstraint.constant = 11
                commentBottomConstraint.constant = 11
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
        commentBottomConstraint.constant = 30
        bView.isHidden = true
        
        if cmtTxtView.text.isEmpty == true {
            placeholderLabel.text = "Add comment..."
            viewHeight.constant = 75
            
            
            
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
    @IBAction func vỉewPostBtnPressed(_ sender: Any) {
        
        
        if let id = Highlight_Id {
            
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
                                
                                if mode == "Followers" {
                                    
                                    if global_following_list.contains(owner_uid) ||  owner_uid == Auth.auth().currentUser?.uid {
                                        
                                        
                                        let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                        
                                        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
                                            
                                            controller.modalPresentationStyle = .fullScreen
                                            
                                            controller.video_list = [i]
                                            controller.userid = i.userUID
                                            controller.startIndex = 0
                                            
                                       
                                            
                                            self.present(controller, animated: true, completion: nil)
                                            
                                            
                                        }
                                        
                                    } else {
                                        
                                        self.showErrorAlert("Oops!", msg: "This video is not ready to watched!")
                                        
                                    }
                                    
                                    
                                    
                                } else if mode == "Public"{
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    
                                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
                                        
                                        controller.modalPresentationStyle = .fullScreen
                                        
                                        controller.video_list = [i]
                                        controller.userid = i.userUID
                                        controller.startIndex = 0
                                        
                                   
                                        
                                        self.present(controller, animated: true, completion: nil)
                                        
                                        
                                    }
                                    
                                }
                                
                                 
                            } else {
                                
                                if owner_uid == Auth.auth().currentUser?.uid {
                                    
                                    let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                    
                                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
                                        
                                        controller.modalPresentationStyle = .fullScreen
                                        
                                        controller.video_list = [i]
                                        controller.userid = i.userUID
                                        controller.startIndex = 0
                                        
                                   
                                        
                                        self.present(controller, animated: true, completion: nil)
                                        
                                        
                                    }
                                    
                                    
                                } else {
                                    
                                    self.showErrorAlert("Oops!", msg: "This video is not ready to watched!")
                                    
                                }
                            
                                
                                
                            }
                            
                                                   
                            
                            
                        } else {
                            
                            self.showErrorAlert("Oops!", msg: "This video is not ready to watched!")
                            
                        }
                        
                    }
                    
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

extension CommentNotificationVC: ASTableDelegate {


    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 50);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        
        return false
        
    }
    
}


extension CommentNotificationVC: ASTableDataSource {
    
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
    
    func getuserName(uid: String) {
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .left
        
            if let username = snapshot.data()!["username"] as? String {
                
            
                self.placeholderLabel.text = "Reply to @\(username)"
                
                
            }
        }
    
        
    }
 
        
}


extension CommentNotificationVC {
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
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
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) {  (alert) in
                    
                    let item = self.CommentList[indexPath.row]
                    self.removeComment(items: item, indexPath: indexPath.row)
                    
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                    
                }
                
                if uid == CommentList[indexPath.row].Comment_uid {
                    
                    sheet.addAction(copy)
                    sheet.addAction(delete)
                    sheet.addAction(cancel)
                    
                } else {
                    
                    sheet.addAction(copy)
                    sheet.addAction(report)
                    sheet.addAction(cancel)
                    
                    
                }

                
                self.present(sheet, animated: true, completion: nil)
                
            }
        }
    }
    
    
    func removeComment(items: CommentModel, indexPath: Int) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["cmt_status": "deleted", "Update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.CommentList.remove(at: indexPath)
                    self.tableNode.deleteRows(at: [IndexPath(item: indexPath, section: 0)], with: .automatic)
                    
                    if items.root_id == "nil" {
                        
                        self.RemoveIndexOfChildComment(from: items, start: indexPath)
                        
                    }
                    
                    
                    showNote(text: "Comment deleted!")
                    DataService.instance.mainRealTimeDataBaseRef.child("Cmt-Deleting").child(items.Comment_id).setValue(["id": items.Comment_id])
                    
                    
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
