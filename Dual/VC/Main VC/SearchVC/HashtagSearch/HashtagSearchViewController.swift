//
//  HashtagSearchViewController.swift
//  The Dual
//
//  Created by Rui Sun on 6/17/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import AlgoliaSearchClient

class HashtagSearchViewController: UIViewController, UIGestureRecognizerDelegate {

    
    
    var tableNode: ASTableNode!
    var searchHashtagList = [HashtagsModelFromAlgolia]()
   
    var uid: String?
    var index = 0
    
    var selectedUID: String?
    
    var selectedHashtag = ""
    
    //var tableControl = FollowertableNodeControl.NormalList
    
//    var tapGesture: UITapGestureRecognizer!
    
    //
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Do any additional setup after loading the view.
        
        view.addSubview(tableNode.view)
        self.applyStyle()

        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true

        
//        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
  
    
    func searchHashtags(searchText: String) {
        AlgoliaSearch.instance.searchHashtags(searchText: searchText) { hashtagSearchResult in
            print("Finished hashtag search, got \(hashtagSearchResult.count) results")
            if hashtagSearchResult != self.searchHashtagList {
                self.searchHashtagList = hashtagSearchResult
                DispatchQueue.main.async {
                    self.tableNode.reloadData(completion: nil)
                    print("***RUI***: Got result and reload table")
                }
            }
        }
    }
    
    
//    @objc func closeKeyboard(_ recognizer: UITapGestureRecognizer) {
//
//        self.view.endEditing(true)
//
//
//    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 300)
       
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
        
        
        selectedHashtag = searchHashtagList[indexPath.row].keyword

        self.performSegue(withIdentifier: "moveFromHashtagSearchToVideoListWithHashtagVC", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveFromHashtagSearchToVideoListWithHashtagVC"{
            if let destination = segue.destination as? VideoListWithHashtagVC
            {
                
                destination.searchHashtag = selectedHashtag
            }
        }
        
    }
    
}
extension HashtagSearchViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
   
}

extension HashtagSearchViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchHashtagList.count

    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let hashtag = self.searchHashtagList[indexPath.row]
       
        return {
            
            let node = HashTagSearchNode(with: hashtag)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
        
}



