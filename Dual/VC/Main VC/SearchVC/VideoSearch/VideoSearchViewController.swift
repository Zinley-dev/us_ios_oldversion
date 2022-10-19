//
//  VideoSearchViewController.swift
//  The Dual
//
//  Created by Rui Sun on 6/17/21.
//

import UIKit
import AlgoliaSearchClient
import FirebaseAuth
import AsyncDisplayKit

class VideoSearchViewController: UIViewController {
    
    
    @IBOutlet weak var contentView: UIView!
   
    var tableNode: ASTableNode!
    var searchKeywordList = [KeywordModelFromAlgolia]()
   
    var uid: String?
    var index = 0
    
    var selectedUID: String?
    
    var selectedKeyword = ""
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func searchKeywords(searchText: String) {
        AlgoliaSearch.instance.searchKeywords(searchText: searchText, pageNumber: 0) { keywordSearchResult in
            print("Finished keyword search, got \(keywordSearchResult.count) results")
            if keywordSearchResult != self.searchKeywordList {
                self.searchKeywordList = keywordSearchResult
                DispatchQueue.main.async {
                    self.tableNode.reloadData(completion: nil)
                    print("***RUI***: Got result and reload table")
                }
            }
        }
    }
    

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
        
        selectedKeyword = searchKeywordList[indexPath.row].keyword
        upload_video_searchWords_collection(keyword: selectedKeyword)
        self.performSegue(withIdentifier: "moveToVideoFromSearchViewController1", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVideoFromSearchViewController1"{
            if let destination = segue.destination as? VideoFromSearchViewController
            {
                
                destination.current_searchText = selectedKeyword
            }
        }
        
    }
    
    
    
}

extension VideoSearchViewController: ASTableDelegate {

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

extension VideoSearchViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchKeywordList.count

    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let  keyword = self.searchKeywordList[indexPath.row]
       
        return {
            
            let node = KeywordSearchNode(with: keyword)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
        
}
