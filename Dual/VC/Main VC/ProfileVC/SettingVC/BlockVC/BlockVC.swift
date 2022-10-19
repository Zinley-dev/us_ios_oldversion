//
//  BlockVC.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/11/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class BlockVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var tableNode: ASTableNode!
    var BlockList = [UserModel]()
    
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

extension BlockVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
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

extension BlockVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
            
            if lastDocumentSnapshot == nil {
                
                query = db.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).order(by: "block_time", descending: true).limit(to: 10)
                
                
            } else {
                
                query = db.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).order(by: "block_time", descending: true).limit(to: 10).start(afterDocument: lastDocumentSnapshot)
            }
            
            query.getDocuments {  (snap, err) in
                
                if err != nil {
                    
                    print(err!.localizedDescription)
                    return
                }
                    
                if snap?.isEmpty != true {
                    
                    print("Successfully retrieved \(snap!.count) Block.")
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
        var items = [UserModel]()
        var indexPaths: [IndexPath] = []
        let total = self.BlockList.count + newUsers.count
        
        for row in self.BlockList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newUsers {

            let item = UserModel(postKey: i.documentID, user_model: i.data()!)
            items.append(item)
          
        }
        
    
        self.BlockList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }
    
    
}

extension BlockVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.BlockList.count == 0 {
            
            tableNode.view.setEmptyMessage("No blocked user!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.BlockList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = self.BlockList[indexPath.row]
       
        return {
            
            let node = BlockNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    

        
}

