//
//  VideoSearchDetailViewController.swift
//  The Dual
//
//  Created by Rui Sun on 6/26/21.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire
import FLAnimatedImage
import AsyncDisplayKit

class VideoListWithHashtagVC: UIViewController {
    
    var searchHashtag: String?
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var hashtagViewsLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    
    
    //====================================
    
    
    private var pullControl = UIRefreshControl()
    var collectionNode: ASCollectionNode!
    var lastDocumentSnapshot: DocumentSnapshot!
    var lastPublicDocumentSnapshot: DocumentSnapshot!
    var publicQuery: Query!
    var query: Query!
    var Highlight_list = [HighlightsModel]()
    var currentIndex = 0
    var key_list = [String]()
    var newSnap = [DocumentSnapshot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("show video detail...")
        //view.backgroundColor = .clear
        
        if let hashtag = searchHashtag {
            
            
            label.text = hashtag
            
            //todo: customized search to search only in hashtag_list
            
            getHashtagViews(hashtag: hashtag)
            getHastag_unique_id(hashtag: hashtag)
            
            let flowLayout = UICollectionViewFlowLayout()
            self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
            
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
            
            
            
            //
            
            self.applyStyle()
            self.collectionNode.leadingScreensForBatching = 5
            self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
            contentView.addSubview(collectionNode.view)
            
            //
            
            pullControl.tintColor = UIColor.systemOrange
            pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
            
            if #available(iOS 10.0, *) {
                collectionNode.view.refreshControl = pullControl
            } else {
                collectionNode.view.addSubview(pullControl)
            }
            
            self.wireDelegates()
            
            
        }
        
        
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
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        refreshRequest()
          
    }
    
    func refreshRequest() {
        
        self.Highlight_list.removeAll()
        self.newSnap.removeAll()
        self.key_list.removeAll()
        lastDocumentSnapshot = nil
        query = nil
        lastPublicDocumentSnapshot = nil
        publicQuery = nil
        
        self.collectionNode.reloadData()
        
    }
    
    func applyStyle() {
        
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
          
    }
    
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.collectionNode.frame = contentView.bounds
    }
    
    func findDataInList(item: HighlightsModel) -> Bool {
        
        for i in Highlight_list {
            
            if i.Mux_playbackID == item.Mux_playbackID, i.Mux_assetID == item.Mux_assetID, i.url == item.url {
                
                return true
                
            }
                      
        }
        
        return false
        
    }

    
    func findDataIndex(item: HighlightsModel) -> Int {
        
        var count = 0
        
        for i in Highlight_list {
            
            if i.Mux_playbackID == item.Mux_playbackID, i.Mux_assetID == item.Mux_assetID, i.url == item.url {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
    
    func getHashtagViews(hashtag: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Hashtags_Views").whereField("hashtag", isEqualTo: hashtag).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.hashtagViewsLbl.text = "0 views"
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
                    //LikerID
                    
                    self.hashtagViewsLbl.text = "\(formatPoints(num: Double(cnt))) views"
                    
                }
                
            }
                
            
        }
        
        
    }
    
    
    func getHastag_unique_id(hashtag: String) {
        
        DataService.instance.mainFireStoreRef.collection("Unique_hashtags").whereField("hashtag", isEqualTo: hashtag).getDocuments { querySnapshot, error in
                     
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                return
                
            } else {
                
                for item in snapshot.documents {
                    
                    let key = item.documentID
                    self.updateHashtagViews(hashtag: hashtag, key: key)
                    
                }
                
            }
                
            
        }
        
    }
    

    func updateHashtagViews(hashtag: String, key: String) {
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let string = string {
                                          
                let device = UIDevice().type.rawValue
        
                let data = ["hashtag": hashtag as Any, "ViewBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "key": key as Any, "is_processed": false, "query": string]
                let db = DataService.instance.mainFireStoreRef.collection("Hashtags_Views")
                db.addDocument(data: data)
          
                                         
            }
            
        }

        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        //back
    }
        
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        //back
        
    }
    
    
    
}

extension VideoListWithHashtagVC: ASCollectionDelegate {
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            self.insertNewRowsInTableNode(newPosts: newPosts)
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let min = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        let max = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        return ASSizeRangeMake(min, max);
        
        
    }
    
}

extension VideoListWithHashtagVC: ASCollectionDataSource {
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return Highlight_list.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        
        let post = self.Highlight_list[indexPath.row]
        
        let node = VideoNode(with: post)
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        
        return node
        
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        currentIndex = indexPath.row
       
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            controller.video_list = Highlight_list
            controller.userid = Auth.auth().currentUser?.uid
            controller.startIndex = currentIndex
            
            self.present(controller, animated: true, completion: nil)
            
        }
        
    }
        
}

extension VideoListWithHashtagVC {
    
    func loadVideoFrompublic(completed: @escaping DownloadComplete) {
        
        if let hashtag = searchHashtag {
            
            let db = DataService.instance.mainFireStoreRef
            
            if lastPublicDocumentSnapshot == nil {
                
                publicQuery = db.collection("Highlights").whereField("hashtag_list", arrayContains: hashtag).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5)
                
                //mode
                
            } else {
                
                publicQuery = db.collection("Highlights").whereField("hashtag_list", arrayContains: hashtag).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastPublicDocumentSnapshot)
            
               
            }
                
            publicQuery.getDocuments {  (snap, err) in
                    
                    if err != nil {
                        completed()
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        print("Successfully retrieved \(snap!.count) users.")
                        let items = snap?.documents
                        self.lastPublicDocumentSnapshot = snap!.documents.last
                                              
                        
                            for item in items! {
                                
                                if let userUID = item.data()["userUID"] as? String {
                                    
                                    // check for block
                                    
                                    if !global_block_list.contains(userUID) {
                                        
                                        // check mode
                                        
                                        if !self.key_list.contains(item.documentID) {
                                            
                                            self.newSnap.append(item)
                                            self.key_list.append(item.documentID)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        
                      
                        
                        completed()
                        
                    } else {
                        
                        completed()
                      
                }
                    
            }
            
        }
        
    }
    
    func loadVideoInNormalLoad(completed: @escaping DownloadComplete) {
        
        if let hashtag = searchHashtag {
            
            let db = DataService.instance.mainFireStoreRef
            
            if lastDocumentSnapshot == nil {
                
                query = db.collection("Highlights").whereField("hashtag_list", arrayContains: hashtag).whereField("h_status", isEqualTo: "Ready").whereField("mode", isNotEqualTo: "Only me").order(by: "mode").order(by: "post_time", descending: true).limit(to: 5)
                
                //mode
                
            } else {
                
                query = db.collection("Highlights").whereField("hashtag_list", arrayContains: hashtag).whereField("h_status", isEqualTo: "Ready").whereField("mode", isNotEqualTo: "Only me").order(by: "mode").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
            
               
            }
                
                query.getDocuments {  (snap, err) in
                    
                    if err != nil {
                        completed()
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        print("Successfully retrieved \(snap!.count) users.")
                        let items = snap?.documents
                        self.lastDocumentSnapshot = snap!.documents.last
                                              
                        
                            for item in items! {
                                
                                if let userUID = item.data()["userUID"] as? String {
                                    
                                    // check for block
                                    
                                    if !global_block_list.contains(userUID) {
                                        
                                        // check mode
                                        
                                        if let mode = item.data()["mode"] as? String {
                                            
                                            if mode != "Only me" {
                                                
                                                if mode != "Followers" {
                                                    
                                                    if !self.key_list.contains(item.documentID) {
                                                        
                                                        self.newSnap.append(item)
                                                        self.key_list.append(item.documentID)
                                                        
                                                    }
                                                    
                                                    
                                                } else {
                                                    
                                                    
                                                    if global_following_list.contains(userUID) {
                                            
                                                        if !self.key_list.contains(item.documentID) {
                                                            
                                                            self.newSnap.append(item)
                                                            self.key_list.append(item.documentID)
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                    } else if userUID == Auth.auth().currentUser?.uid {
                                                        
                                                        if !self.key_list.contains(item.documentID) {
                                                            
                                                            self.newSnap.append(item)
                                                            self.key_list.append(item.documentID)
                                                            
                                                        }
                                                        
                                                        
                                                    } 
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        
                
                        completed()
                        
                    } else {
                        
                        completed()
                      
                }
                    
            }
            
        }
        
    }
    
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        newSnap.removeAll()
        self.loadVideoInNormalLoad {
                     
            self.loadVideoFrompublic {
                
                DispatchQueue.main.async {
                    block(self.newSnap)
                }
                
            }
            
        }
        
        
                
    }
    
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        var checkPost = [DocumentSnapshot]()
        
        for item in newPosts {
            let test = HighlightsModel(postKey: item.documentID, Highlight_model: item.data()!)

            if test.mode != "Only me", findDataInList(item: test) == false {
                
                checkPost.append(item)
                
            }
            
        }
        
        guard checkPost.count > 0 else {
            return
        }
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.Highlight_list.count + checkPost.count
        
        for row in self.Highlight_list.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in checkPost {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            items.append(item)
          
        }
        
    
        self.Highlight_list.append(contentsOf: items)
        self.collectionNode.insertItems(at: indexPaths)
        
    }
    
    
}
