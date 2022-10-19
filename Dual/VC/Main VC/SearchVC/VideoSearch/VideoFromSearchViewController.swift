//
//  VideoFromSearchViewController.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/20/21.
//

import UIKit
import Firebase
import SwiftPublicIP
import Alamofire
import FLAnimatedImage
import AsyncDisplayKit

class VideoFromSearchViewController: UIViewController {
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var searchViewsLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    
    var highlightList = [HighlightsModel]()
    var selectedItem: HighlightsModel!
    var collectionNode: ASCollectionNode!
    var current_searchText: String!
        //
    var currentIndex = 0
    var uid: String?
    var newSearch = true
        
    var count = 0
        
    let algoliaHighlightsIndex = algoliaSearchClient.index(withName: "Highlights")
        
    var currentAlgoliaPageNum = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
                
       
        searchViewsLbl.text = current_searchText
        getKeywordViews(keyword: current_searchText)
                
        self.applyStyle()
        self.collectionNode.leadingScreensForBatching = 2
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        contentView.addSubview(collectionNode.view)
            
       
        self.wireDelegates()
        
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
    
    func findDataInList(item: HighlightsModel) -> Bool {
        
        for i in highlightList {
            
            if i.Mux_playbackID == item.Mux_playbackID, i.Mux_assetID == item.Mux_assetID, i.url == item.url {
                
                return true
                
            }
                      
        }
        
        return false
        
    }
    
    func getKeywordViews(keyword: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Video_searchWords").whereField("searchWord", isEqualTo: keyword).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                //self.DetailViews.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                self.label.text = "0 searches"
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
                    self.label.text = "\(formatPoints(num: Double(cnt))) searches"
                    
                }
                
            }
                
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        if segue.identifier == "moveFromVideoSearchToUserHighlightFeed"{
            if let destination = segue.destination as? UserHighlightFeedVC
            {
                    //todo: how to deal with highlightsModel vs HighlightsModelFromAlgolia???
                    
                destination.userid = Auth.auth().currentUser!.uid
                destination.startIndex = currentIndex
                destination.video_list = self.highlightList
                   
            }
        }
            
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
    
    func prepareModel(hits: [HighlightsModelFromAlgolia]) -> [HighlightsModel]{
        var res = [HighlightsModel]()
        for hit in hits {
            let highlight = HighlightsModel(from: hit)
            print("mode: \(String(describing: highlight.mode))")
                
            let currentUserUID = Auth.auth().currentUser?.uid
                
                // user own videos are visible to their own no matter in which mode
            if highlight.userUID == currentUserUID {
                res.append(highlight)
            } else {
                switch highlight.mode {
                case "Public":
                        //not from a blocked user
                    if !global_block_list.contains(highlight.userUID) {
                        res.append(highlight)
                    }
                    break
                case "Only me":
                    break
                case "Followers":
                    if global_following_list.contains(highlight.userUID), !global_block_list.contains(highlight.userUID) {
                        res.append(highlight)
                    }
                    break
                case .none:
                    break
                case .some(_):
                    break
                }
                    
            }
        }
        return res
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension VideoFromSearchViewController: ASCollectionDelegate {
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        print("start batch fetch...\n\n\n")
        
        AlgoliaSearch.instance.searchHighlights(searchText: current_searchText, pageNumber: self.currentAlgoliaPageNum, withHashtagOnly: false) { highlightSearchResult in
            
            self.insertNewRowsInTableNode(newPosts: highlightSearchResult)
            self.currentAlgoliaPageNum += 1
            context.completeBatchFetching(true)
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let min = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        let max = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        return ASSizeRangeMake(min, max);
        
        
    }
    
 
}

extension VideoFromSearchViewController: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return highlightList.count
    }
    
    func collectionView(_ collectionView: ASCollectionView, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let post = self.highlightList[indexPath.row]
        
        let node = VideoNode(with: post)
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        
        return node
    }

    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        currentIndex = indexPath.row
       
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            controller.video_list = highlightList
            controller.userid = Auth.auth().currentUser?.uid
            controller.startIndex = currentIndex
            
            self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    
    func insertNewRowsInTableNode(newPosts: [HighlightsModel]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        var checkPost = [HighlightsModel]()
        
        
        for item in newPosts {
            
            
            if item.userUID == Auth.auth().currentUser?.uid, findDataInList(item: item) == false {
                
                checkPost.append(item)
                
            } else if item.mode != "Only me", findDataInList(item: item) == false {
                
                checkPost.append(item)
                
            }
                 
            
        }
        
        guard checkPost.count > 0 else {
            return
        }
        
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.highlightList.count + checkPost.count
        
        for row in self.highlightList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in checkPost {
            
            
            items.append(i)
          
        }
        
    
        DispatchQueue.main.async {
            
            self.highlightList.append(contentsOf: items)
            self.collectionNode.insertItems(at: indexPaths)
            
        }
        
        
    }
    
}
