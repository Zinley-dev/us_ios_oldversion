//
//  MostPlayVideoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/2/21.
//

import UIKit
import Alamofire
import Cache
import Firebase
import FLAnimatedImage
import AsyncDisplayKit

class MostPlayVideoVC: UIViewController {

    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var selectecGameLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    var selected_userUID: String!
    var selected_category: String!
    
    //
    
    private var pullControl = UIRefreshControl()
    var collectionNode: ASCollectionNode!
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var Highlight_list = [HighlightsModel]()
    var currentIndex = 0
    var key_list = [String]()
    var newSnap = [DocumentSnapshot]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !global_block_list.contains(selected_userUID) {
            
            //categoryLbl.text = selected_category
            
            loadUserInfo()
            loadCategoryLogo()
            
            selectecGameLbl.font = UIFont(name:"URIALFONT-Bold",size: 23)!
            categoryLbl.font = UIFont(name:"URIALFONT-Bold",size: 16)!
            selectecGameLbl.text = selected_category
            let flowLayout = UICollectionViewFlowLayout()
            self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
            
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
            
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
    
    func loadUserInfo() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(selected_userUID!).getDocument { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let is_suspend = item["is_suspend"] as? Bool {
                        
                        if is_suspend == false {
                            
                            if let username = item["username"] as? String  {
                                
                                self.usernameLbl.text = "@\(username)"
                                 
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            
            
        }
        
       
    }
    
    func loadCategoryLogo() {
        
        self.categoryImg.image = UIImage(named: selected_category!)
        
        DataService.instance.mainFireStoreRef.collection("Support_game").whereField("short_name", isEqualTo: selected_category!).getDocuments { (snap, err) in
              
              
              if err != nil {
                  
                  print(err!.localizedDescription)
                  return
              }
              
              for item in snap!.documents {
                  
                  if let name = item.data()["name"] as? String {
                      
                      self.categoryLbl.text = name
                      
                  } else {
                      
                      self.categoryLbl.text = self.selected_category
                      
                  }
                  
                  
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

extension MostPlayVideoVC: ASCollectionDelegate {
    
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

extension MostPlayVideoVC: ASCollectionDataSource {
    
    
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

extension MostPlayVideoVC {
    
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
        
        if lastDocumentSnapshot == nil {
            
            
            if global_following_list.contains(selected_userUID!) || selected_userUID == Auth.auth().currentUser?.uid {
                
                query = db.collection("Highlights").whereField("category", isEqualTo: selected_category!).whereField("userUID", isEqualTo: selected_userUID!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isNotEqualTo: "Only me").order(by: "mode").order(by: "post_time", descending: true).limit(to: 5)
                
            } else {
                
                query = db.collection("Highlights").whereField("category", isEqualTo: selected_category!).whereField("userUID", isEqualTo: selected_userUID!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5)
                
                
            }
            
            
            
            //
            
        } else {
            
            
            if global_following_list.contains(selected_userUID!) || selected_userUID == Auth.auth().currentUser?.uid {
                
                query = db.collection("Highlights").whereField("category", isEqualTo: selected_category!).whereField("userUID", isEqualTo: selected_userUID!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isNotEqualTo: "Only me").order(by: "mode").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
                
                
            } else {
                
                query = db.collection("Highlights").whereField("category", isEqualTo: selected_category!).whereField("userUID", isEqualTo: selected_userUID!).whereField("h_status", isEqualTo: "Ready").whereField("mode", isEqualTo: "Public").order(by: "post_time", descending: true).limit(to: 5).start(afterDocument: lastDocumentSnapshot)
                
            }
            
        
           
        }
            
            query.getDocuments {  (snap, err) in
                
                if err != nil {
                    
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
                                            
                                        } else {
                                            if userUID == Auth.auth().currentUser?.uid {
                                                
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
                    
                  
                    DispatchQueue.main.async {
                        block(self.newSnap)
                    }
                    
                } else {
                    
                    let items = snap?.documents
                    DispatchQueue.main.async {
                        block(items!)
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
            
            
            if test.userUID == Auth.auth().currentUser?.uid, findDataInList(item: test) == false {
                
                checkPost.append(item)
                
            } else if test.mode != "Only me", findDataInList(item: test) == false {
                
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
