//
//  FollowingViewController.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/3/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit


enum FollowingtableNodeControl  {
    
    case NormalList
    case SearchList
   
}

class FollowingViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tableNode: ASTableNode!
    var userList = [UserModel]()
    
   

    var uid: String?
    var index = 0

    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var selectedUID: String?
    
    //
    
    lazy var delayItem = workItem()
    
    var tableControl = FollowertableNodeControl.NormalList
    var shouldEnd = false
    var tapGesture: UITapGestureRecognizer!
    var tableSearchNode: ASTableNode!
    var searchUserList = [UserModel]()
    
    var followingList = [FollowingModelFromAlgolia]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableNode = ASTableNode(style: .plain)
        self.tableSearchNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
        
        tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.closeKeyboard(_:)))
        tapGesture.delegate = self
        
        //
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        
        //
        
        self.tableSearchNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableSearchNode.automaticallyAdjustsContentOffset = true
        //
          
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
       
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
        tableControl = .SearchList
        tableNode.isHidden = true
        //self.contentView.addSubnode(tableSearchNode)
        
        contentView.addSubview(tableSearchNode.view)
        
        self.tableSearchNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableSearchNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableSearchNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableSearchNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableSearchNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 200).isActive = true
        
        
        self.contentView.addGestureRecognizer(tapGesture)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
        if shouldEnd == true {
            
            tableNode.isHidden = false
            tableControl = .NormalList
            tableSearchNode.removeFromSupernode()
            
        }
        
        
             
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        delayItem.perform(after: 0.5) {
            
            if searchText != "" {
                
//                self.searchUsers(searchText: searchText)
                self.tableNode.isHidden = true
                self.tableSearchNode.isHidden = false
                self.searchFollowings(searchText: searchText);
            } else {
                self.tableNode.isHidden = false
                self.tableSearchNode.isHidden = true
            }

        }
        
    }
    
    func searchFollowings(searchText: String) {
        AlgoliaSearch.instance.searchFollowings(targetUserUID: self.uid!, searchText: searchText) { res in
            print("Found \(res.count) followings with searchText \(searchText)")
            if !res.isEmpty  {
                
                self.searchUserList.removeAll()
                
                for each in res {
                    
                    var data = ["Following_uid": each.Following_uid as Any, "Follower_uid": each.Follower_uid as Any, "follow_time": each.follow_time, "status": "Valid", "Follower_username": each.Follower_username, "Following_username": each.Following_username]
                    
                    data.updateValue("Following", forKey: "action")
                    
                    let item = UserModel(postKey: "Follower_search", user_model: data)
                    self.searchUserList.append(item)
                }
                
                
                DispatchQueue.main.async {
                    self.tableSearchNode.reloadData()
                }
                
               
            }
        }
    }
    
    func searchUsers(searchText: String)  {
        
        DataService.init().mainFireStoreRef.collection("Users").whereField("username", isEqualTo: searchText).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            
            if snapshot.isEmpty != true {
                
                for item in snapshot.documents {
                
                    if let searchUserUID = item.data()["userUID"] as? String {
                        
                        
                        self.checkIfValidUser(searchUID: searchUserUID)
                        
                        }
                
                }
                
                
                
            }
                 
        }
        
    }
    
    func checkIfValidUser(searchUID: String) {
       
        DataService.init().mainFireStoreRef.collection("Follow").whereField("Following_uid", isEqualTo: uid!).whereField("Follower_uid", isEqualTo: searchUID).whereField("status", isEqualTo: "Valid").getDocuments {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                let section = 0
                var items = [UserModel]()
                var indexPaths: [IndexPath] = []
              
                
                let path = IndexPath(row: 0, section: section)
                indexPaths.append(path)
                
                for i in snapshot.documents {
                    
                    
                    var x = i.data()
                    x.updateValue("Following", forKey: "action")
                    
                    let item = UserModel(postKey: i.documentID, user_model: x)
                    items.append(item)
                  
                }
                
                
                if self.searchUserList.isEmpty == true {
                    
                    self.searchUserList.append(contentsOf: items)
                    self.tableSearchNode.insertRows(at: indexPaths, with: .none)
                    
                } else {
                    
                    
                    self.searchUserList[0] = items[0]
                    self.tableSearchNode.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
                    
                }
                
                
                
            
            }
            
        }
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: tableSearchNode.view)
            shouldEnd = tableSearchNode.indexPathForRow(at: location) == nil
            return (tableSearchNode.indexPathForRow(at: location) == nil)
        }
       
        shouldEnd = true
        return true
    }
    
    
    @objc func closeKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        
        self.contentView.removeGestureRecognizer(tapGesture)
        self.view.endEditing(true)
        
        
        if tableControl == .SearchList {
            
            
            tableControl = .NormalList
            tableSearchNode.view.removeFromSuperview()
            
        }
        
    
        self.searchBar.text = ""
   
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
       // self.tableNode.frame = view.bounds
       // self.tableSearchNode.frame = view.bounds
    }
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
       
        
        //
        
        self.tableSearchNode.view.separatorStyle = .none
        self.tableSearchNode.view.separatorColor = UIColor.lightGray
        self.tableSearchNode.view.isPagingEnabled = false
        self.tableSearchNode.view.backgroundColor = UIColor.clear
        self.tableSearchNode.view.showsVerticalScrollIndicator = false
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
        
        self.tableSearchNode.delegate = self
        self.tableSearchNode.dataSource = self
    }

    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
        if tableNode == self.tableNode {
            
            
            selectedUID = userList[indexPath.row].Follower_uid
           
            
        } else {
            
            
            selectedUID = searchUserList[indexPath.row].Follower_uid
        }
        
        
        self.performSegue(withIdentifier: "moveToUserProfile5", sender: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfile5"{
            if let destination = segue.destination as? UserProfileVC
            {
                
                
                destination.uid = selectedUID
                  
            }
        }
        
    }
 

}

extension FollowingViewController: ASTableDelegate {

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
            
            var check_newUsers = [DocumentSnapshot]()
            
            for user in newUsers {
                
                let user_check =  UserModel(postKey: user.documentID, user_model: user.data()!)
                if !global_block_list.contains(user_check.Follower_uid) {
                    
                    check_newUsers.append(user)
                    
                }
                        
            }
            
            self.insertNewRowsInTableNode(newUsers: check_newUsers)
                
            context.completeBatchFetching(true)
            
        }
        
    }
       
    
}


extension FollowingViewController {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        let db = DataService.instance.mainFireStoreRef
            
            if lastDocumentSnapshot == nil {
                
                query = db.collection("Follow").whereField("Following_uid", isEqualTo: uid!).whereField("status", isEqualTo: "Valid").order(by: "follow_time", descending: true).limit(to: 10)
                
                
            } else {
                
                query = db.collection("Follow").whereField("Following_uid", isEqualTo: uid!).whereField("status", isEqualTo: "Valid").order(by: "follow_time", descending: true).limit(to: 10).start(afterDocument: lastDocumentSnapshot)
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
        let total = self.userList.count + newUsers.count
        
        for row in self.userList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newUsers {
            
            var x = i.data()!
            x.updateValue("Following", forKey: "action")
            
            let item = UserModel(postKey: i.documentID, user_model: x)
            items.append(item)
          
        }
        
    
        self.userList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }
    
    
}

extension FollowingViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        switch tableControl {
        
        case .NormalList:
            if tableNode == self.tableNode {
                
                if self.userList.count == 0 {
                    
                    tableNode.view.setEmptyMessage("No following user")
                    
                } else {
                    tableNode.view.restore()
                }
                
                return self.userList.count
                
            }else {
                return 0
            }
            
        case .SearchList:
            if tableNode == self.tableSearchNode {

                return self.searchUserList.count
                
            } else {
                
                return 0
            }
            
     
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        var user: UserModel!
       
        switch tableControl {
        
        case .NormalList:
            if tableNode == self.tableNode {
                

                user = self.userList[indexPath.row]
                
            }
            
        case .SearchList:
            if tableNode == self.tableSearchNode {
                
                user = self.searchUserList[indexPath.row]
                
                
            }
            
        }
       
        return {
            var node: UserNode!
            
            switch self.tableControl {
            case .NormalList:
                node = UserNode(with: user)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
            case .SearchList:
                node = UserNode(with: user)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
            }
            
//            let node = UserNode(with: user)
//            node.neverShowPlaceholders = true
//            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    

        
}

