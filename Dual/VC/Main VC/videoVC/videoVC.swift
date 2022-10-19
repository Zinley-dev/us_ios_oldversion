//
//  videoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/29/21.
//

import UIKit
import Firebase
import AsyncDisplayKit

class videoVC: UIViewController {
    
    var userUID: String?
    var isTrack: Bool?
    lazy var delayItem = workItem()
    var collectionNode: ASCollectionNode!
    
    private var pullControl = UIRefreshControl()
    
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var hasRestrict = false
    
    var Highlight_list = [HighlightsModel]()
    
    
    var isFollow = false
    var isFeed = false
    var isBack = false
    var isfollow = false
    var ismain = false
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       
        if userUID != nil {
            
            let flowLayout = UICollectionViewFlowLayout()
            self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
            
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
            
            //
            
            self.applyStyle()
            self.collectionNode.leadingScreensForBatching = 5
           
            view.addSubview(collectionNode.view)
            
            //
            
            pullControl.tintColor = UIColor.systemOrange
            pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
            
            if #available(iOS 10.0, *) {
                collectionNode.view.refreshControl = pullControl
            } else {
                collectionNode.view.addSubview(pullControl)
            }
            
            if isTrack == true {
                
                
                self.delayItem.perform(after: 1.0) {

                    self.trackingVideo()
                  
                }
                
                
            }
            
        } 
        
        
        
    }
    
    
    func startLoading() {
        
        self.wireDelegates()
        
    }
    
    @objc private func refreshListData(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        refreshRequest()
          
    }
    
    func refreshRequest() {
        
        self.Highlight_list.removeAll()
        lastDocumentSnapshot = nil
        query = nil
        
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
        self.collectionNode.frame = view.bounds
    }
    
    
    func trackingVideo() {
        
        
        if Auth.auth().currentUser?.uid != nil {
            
            
            let db = DataService.instance.mainFireStoreRef
            let uid = Auth.auth().currentUser?.uid
            
            videoListen = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).order(by: "post_time", descending: true)
                .addSnapshotListener { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }


                    snapshot.documentChanges.forEach { diff in
                        
                        let item = HighlightsModel(postKey: diff.document.documentID, Highlight_model: diff.document.data())

                        if (diff.type == .modified) {
                           
                            if let status = diff.document.data()["h_status"] as? String, status == "Ready" {
                                   
                                let isIn = self.findDataInList(item: item)
                                
                                if isIn == false {
                                    
                                    delay(1.5) {
                                        self.Highlight_list.insert(item, at: 0)
                                        self.collectionNode.insertItems(at: [IndexPath(row: 0, section: 0)])
                                    }
                                   
                                    
                                } else {
                                    
                                    let index = self.findDataIndex(item: item)
                                    self.Highlight_list[index] = item
                                    self.collectionNode.reloadItems(at: [IndexPath(row: index, section: 0)])
                                    
                                    
                                }
                                
                            // add new item processing goes here
                            } else if let status = diff.document.data()["h_status"] as? String, status == "Deleted" {
                                
                                let isIn = self.findDataInList(item: item)
                                
                                if isIn == true {
                                    
                                    let index = self.findDataIndex(item: item)
                                    if !self.Highlight_list.isEmpty {
                                        self.Highlight_list.remove(at: index)
                                        self.collectionNode.deleteItems(at: [IndexPath(row: index, section: 0)])
                                    }
                                    
                                }
                                
                            }
                            
                        }
                      
                    }
                }
            
            
        }
        
        
   
    }
    
    func findDataInList(item: HighlightsModel) -> Bool {
        
        if Highlight_list.contains(item) {
            return true
        } else {
            return false
        }
        
        
    }

    
    func findDataIndex(item: HighlightsModel) -> Int {
        
        var count = 0
        
        for i in Highlight_list {
            
            if i.Mux_playbackID == item.Mux_playbackID {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "moveToUserHighlightVC1"{
            if let destination = segue.destination as? UserHighlightFeedVC
            {
               
                destination.userid = self.userUID!
                destination.startIndex = currentIndex
                destination.video_list = Highlight_list
               
            }
        }
        
    }

}


extension videoVC: ASCollectionDelegate {
    
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
        
        let min = CGSize(width: view.frame.width/2 - 3, height: view.frame.width/2);
        let max = CGSize(width: view.frame.width/2 - 3, height: view.frame.width/2);
        return ASSizeRangeMake(min, max);
        
        
    }
    
}

extension videoVC: ASCollectionDataSource {
    
    
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

        self.performSegue(withIdentifier: "moveToUserHighlightVC1", sender: nil)

    }
        
}

extension videoVC {
    
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        if userUID != nil {
            
            let db = DataService.instance.mainFireStoreRef
            let uid = userUID
            
            if lastDocumentSnapshot == nil {
                
                if ismain == true {
                    
                    query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").order(by: "post_time", descending: true).limit(to: 5)
                    
                } else {
                    
                    if isFollow == true {
                        
                        query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").order(by: "post_time", descending: true).limit(to: 5)
                        
                    } else {
                        
                        query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5)
                        
                    }
                    
                }
                
                //mode
                
            } else {
                
                if ismain == true {
                    
                    query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
                    
                } else {
                    
                    if isFollow == true {
                        
                        query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
                        
                    } else {
                        
                        query = db.collection("Highlights").whereField("userUID", isEqualTo: uid!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
                        
                    }
                    
                }
            
               
            }
                
                query.getDocuments { (snap, err) in
                    
                    if err != nil {
                        
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        print("Successfully retrieved \(snap!.count) users.")
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
                
    }
    
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        var checkPost = [DocumentSnapshot]()
        
        if ismain == true {
                
            for item in newPosts {
                let test = HighlightsModel(postKey: item.documentID, Highlight_model: item.data()!)

                if findDataInList(item: test) == false {
                    
                    checkPost.append(item)
                    
                }
                
            }
            
        } else {
            
            for item in newPosts {
                let test = HighlightsModel(postKey: item.documentID, Highlight_model: item.data()!)

                if test.mode != "Only me", findDataInList(item: test) == false {
                    
                    checkPost.append(item)
                    
                }
                
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
            
            if !indexPaths.contains(path) {
                indexPaths.append(path)
            }
            
        }
        
        for i in checkPost {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            
            if !items.contains(item) {
                items.append(item)
            }
           
        }
        
    
        self.Highlight_list.append(contentsOf: items)
        self.collectionNode.insertItems(at: indexPaths)
        
    }
    
    
}
