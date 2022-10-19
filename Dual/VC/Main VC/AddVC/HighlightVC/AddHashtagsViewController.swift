//
//  AddHashtagsViewController.swift
//  Dual
//
//  Created by Rui Sun on 7/30/21.
//

import UIKit
import AlgoliaSearchClient
import AsyncDisplayKit

class AddHashtagsViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textField: UITextField!
    var text: String?
    
    var completionHandler: ((String) -> Void)?
//    var needTriggerSearch = true
    
    var tableNode: ASTableNode!
    var searchHashtagList = [HashtagsModelFromAlgolia]()
    let algoliaHighlightsIndex = algoliaSearchClient.index(withName: "Hashtags")
    
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [HashtagsModelFromAlgolia]
    }
    
    //Store search history
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()
    
    func applyStyle() {
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
    }

    func checkLocalRecords(searchText: String) -> Bool {
        print("***RUI***: check local search records...")
        for (i, record) in searchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    let retrievedSearchHashtagList = record.items
                    
                    if self.searchHashtagList != retrievedSearchHashtagList {
                        self.searchHashtagList = retrievedSearchHashtagList
                        DispatchQueue.main.async {
                            self.tableNode.reloadData(completion: nil)
                        }
                    }
                    return true
                } else {
                    print("***RUI***: delete expired record")
                    searchHist.remove(at: i)
                }
            }
        }
        print("***RUI***: no available local record found")
        return false
    }
    
    
    func searchHashTags(searchText: String) {
        if searchText.isEmpty {
            return
        }
        //check local result first
        if checkLocalRecords(searchText: searchText){
            return
        }
        print("***RUI***: search in Algolia...")
        algoliaHighlightsIndex.search(query: AlgoliaSearchClient.Query(searchText)) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    let newSearchHashtagList:[HashtagsModelFromAlgolia] = try response.extractHits()
                    
                    //store search result locally
                    let newSearchRecord = SearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchHashtagList)
                    self.searchHist.append(newSearchRecord)
                    
                    if self.searchHashtagList != newSearchHashtagList {
                        self.searchHashtagList = newSearchHashtagList
                        DispatchQueue.main.async {
                            self.tableNode.reloadData(completion: nil)
                            print("***RUI***: Got result from Algolia")
                        }
                    }
            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if text != nil {
            
            if let currentText = text {
                textField.text = "\(currentText)#"
            }
            
        } else {
            textField.text = "#"
        }
        
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(tableNode.view)
        self.applyStyle()
        //self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
                
        //improve later
        
        self.contentView.addSubview(tableNode.view)
      
       
        
        
        textField.delegate = self
        
        textField.becomeFirstResponder()
        
        

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentView.bounds
       
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
    }
    
    func getCurrentSearchHashTag(text: String) -> String {
        let mentionText = text.findMHashtagText()
        print("***RUi***: getCurrentSearchHashTag\nMentionText: \(mentionText)")
        
        
        if !text.findMHashtagText().isEmpty {
            
            let res = text.findMHashtagText()[text.findMHashtagText().count - 1]
            
            print("***RUi***: findMentionText: \(res)")
            
            return res
            
        } else {
            return ""
        }
        
        
    }
    
    func backBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        backBtnTapped()
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        backBtnTapped()
        
    }
    @IBAction func DoneBtnPressed(_ sender: Any) {
        
        var updateText = ""
        if let text = self.textField.text {
            updateText = self.textField.text!
            if text.last == "#" {
                updateText.removeLast()
            }
            
            completionHandler?(updateText)
        }
        
        backBtnTapped()
        
    }
}

extension AddHashtagsViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            
            if text.last != " " && text.last != "#" {
                let searchText = String(getCurrentSearchHashTag(text: text).dropFirst(1))
                
                self.searchHashTags(searchText: searchText)
            } else {
                self.searchHashtagList = [HashtagsModelFromAlgolia]()
                self.tableNode.reloadData(completion: nil)
            }
        }
    }
}


extension AddHashtagsViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = tableNode.view.bounds.size.width;

        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
    
    
}

extension AddHashtagsViewController: ASTableDataSource {
    
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
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        let hashtagsStr = self.textField.text!
        let endOfSentence = hashtagsStr.lastIndex(of: "#")!
        
        let newhashtagsText = hashtagsStr[..<endOfSentence] + (self.searchHashtagList[indexPath.row].keyword) + "#"
        
        self.textField.text = newhashtagsText
        
        self.searchHashtagList = [HashtagsModelFromAlgolia]()
        self.tableNode.reloadData(completion: nil)
    }
    
        
}

 


