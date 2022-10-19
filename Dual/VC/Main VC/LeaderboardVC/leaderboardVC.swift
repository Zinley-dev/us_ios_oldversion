//
//  leaderboardVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/23/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit

class leaderboardVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var timeFrameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var contentView: UIView!
    var collectionNode: ASCollectionNode!
    
    @IBOutlet weak var bannerImgView: UIView!
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    
    @IBOutlet weak var newsHeight: NSLayoutConstraint!
    var leaderboard_list = [leaderboardModel]()
    
    
    var selectedItem = [String: Any]()
    lazy var delayItem = workItem()
    
    var rank = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        newsHeight.constant = 0
        // Do any additional setup after loading the view.
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        contentView.addSubview(collectionNode.view)
       
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        self.applyStyle()
         
        //
        checkCompetition()
        
    }
    
    
    func checkCompetition() {
        let db = DataService.instance.mainFireStoreRef
        db.collection("reward_competition").whereField("status", isEqualTo: true).whereField("end date", isGreaterThan: NSDate()).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            
            if !snapshot.isEmpty {
                
                self.newsHeight.constant = 200
                self.newsView.isHidden = false
                self.collectionNode.leadingScreensForBatching = 5
                self.wireDelegates()
                
                for item in snapshot.documents {
                    
                    
                    self.selectedItem = item.data()
                    
                    if let title = item.data()["Title"] as? String {
                        
                        //self.titleLbl.text = title
                        
                        
                    }
                    
                    if let start_date = item.data()["start date"] as? Timestamp {
                        
                        if let end_date = item.data()["end date"] as? Timestamp {
                            
                            
                            self.timeFrameLbl.text = "From \(getReadableDate(timeStamp: start_date.dateValue().timeIntervalSince1970)!) to \(getReadableDate(timeStamp: end_date.dateValue().timeIntervalSince1970)!)"
                       
                            
                        }
                        
                    }
                    
                    if let desc = item.data()["description"] as? String {
                        
                        //self.descriptionLbl.text = desc
                        
                    }
                    
                    if let url = item.data()["url"] as? String {
                        
                        let imageNode = ASNetworkImageNode()
                        imageNode.contentMode = .scaleAspectFill
                        imageNode.shouldRenderProgressImages = true
                        imageNode.url = URL.init(string: url)
                        
                        
                        self.bannerImgView.backgroundColor = UIColor.clear
                        self.bannerImgView.addSubnode(imageNode)
                        
                        
                        imageNode.view.translatesAutoresizingMaskIntoConstraints = false
                        imageNode.view.topAnchor.constraint(equalTo: self.bannerImgView.topAnchor, constant: 0).isActive = true
                        imageNode.view.leadingAnchor.constraint(equalTo: self.bannerImgView.leadingAnchor, constant: 0).isActive = true
                        imageNode.view.trailingAnchor.constraint(equalTo: self.bannerImgView.trailingAnchor, constant: 0).isActive = true
                        imageNode.view.bottomAnchor.constraint(equalTo: self.bannerImgView.bottomAnchor, constant: 0).isActive = true
                        
                    }
                    
                    
                    
        
                }
                
            } else {
                
                
                self.newsHeight.constant = 0
                self.newsView.isHidden = true
                self.collectionNode.view.setEmptyMessage("Wait, the event is coming soon.")
              
                
            }
            
            
        }
        
        
    }
    
    @IBAction func moveToCompetitionVC(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToCompetitionVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToCompetitionVC"{
            if let destination = segue.destination as? competitionVC
            {
                
                destination.selectedItem = self.selectedItem
                  
            }
        }
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }

    func applyStyle() {
        
   
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
         
        let uid = leaderboard_list[indexPath.row].userUID
        
        if !global_block_list.contains(uid!) {
            
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                
                controller.modalPresentationStyle = .fullScreen
                
                
                if let vc = UIViewController.currentViewController() {
                    
                    controller.uid = uid
                    
                    vc.present(controller, animated: true, completion: nil)
                     
                }
                 
            }
                 
        } else {
            self.showErrorAlert("Oops!", msg: "Can't open this user profile this time.")
        }
        
        
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }


}

extension leaderboardVC: ASCollectionDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 35, height: 35)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == collectionNode.view {
            
            return 30.0
            
        } else {
            
            return 5.0
        }
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if collectionView == collectionNode.view {
            
            return 30.0
            
        } else {
            
            return 5.0
        }
        
    }

    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.retrieveNextPageWithCompletion { (newUsers) in
            
            if !newUsers.isEmpty {
                self.insertNewRowsInCollectionNode(newUsers: newUsers)
            }
            
           
            context.completeBatchFetching(true)
            
        }
    }
 
}


extension leaderboardVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
        
        if leaderboard_list.count < 100 {
            
            let db = DataService.instance.mainFireStoreRef
                
                if lastDocumentSnapshot == nil {
                    
                    query = db.collection("Users_leaderboard").whereField("status", isEqualTo: true).order(by: "timeStamp", descending: true).limit(to: 10)
                    
                    
                } else {
                    
                    query = db.collection("Users_leaderboard").whereField("status", isEqualTo: true).order(by: "timeStamp", descending: true).limit(to: 10).start(afterDocument: lastDocumentSnapshot)
                }
                
                query.getDocuments { (snap, err) in
                    
                    if err != nil {
                        
                        print(err!.localizedDescription)
                        return
                    }
                        
                    if snap?.isEmpty != true {
                        
                        print("Successfully retrieved \(snap!.count) users from leaderboard.")
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
            
        } else {
            
            DispatchQueue.main.async {
                let items = [QueryDocumentSnapshot]()
                block(items)
            }
            
        }
            
        
        
                
    }
    
    
    
    func insertNewRowsInCollectionNode(newUsers: [DocumentSnapshot]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        let section = 0
        var items = [leaderboardModel]()
        var indexPaths: [IndexPath] = []
        let total = self.leaderboard_list.count + newUsers.count
        
        for row in self.leaderboard_list.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newUsers {
            
            rank += 1
            var updatedItem = i.data()
            
            updatedItem?.updateValue(rank, forKey: "rank")
            
            let item = leaderboardModel(postKey: i.documentID, leaderboardModel: updatedItem!)
            items.append(item)
          
        }
        
    
        self.leaderboard_list.append(contentsOf: items)
        self.collectionNode.insertItems(at: indexPaths)
        
    }
    
    
}

extension leaderboardVC: ASCollectionDataSource {
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        
        return 1
        
        

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.leaderboard_list.count
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = self.leaderboard_list[indexPath.row]
       
        return {
            
            let node = leaderboadNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            delay(0.75) {
                if node.LeaderboardViews != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                }
            }
            
            return node
        }
        
    }
    
    /*
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        
        guard let cell = node as? leaderboadNode else { return }
        
        
        delay(0.75) {
            
            if cell.LeaderboardViews != nil {
                
                print("Loading...")
                  
                if cell.indexPath != nil {
                    cell.setCollectionViewDataSourceDelegate(self, forRow: cell.indexPath!.row)
                }
                

            } else {
                print("Unsafe to load")
            }
            
        }
        
        
        
    }*/
    
    
        
}

extension leaderboardVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return leaderboard_list[collectionView.tag].final_most_playList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: ChallengeCell.cellReuseIdentifier(), for: indexPath)) as! ChallengeCell
        let item = leaderboard_list[collectionView.tag].final_most_playList[indexPath.row]

        //cell.cornerRadius = cell.frame.size.width / 2
        cell.configureCell(item)
        
        return cell
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        let user = leaderboard_list[indexPath.row]
        
        
        if !global_block_list.contains(user.userUID) {
            
            
            
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                
                if let vc = UIViewController.currentViewController() {
                
                    controller.uid = user.userUID
                    controller.modalPresentationStyle = .fullScreen
                    
                    
                    
                    vc.present(controller, animated: true, completion: nil)
                     
                }
                
                
            }
            
        }
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if collectionView != self.collectionNode.view {
            
            let item = leaderboard_list[collectionView.tag].final_most_playList[indexPath.row]
            
            
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MostPlayVideoVC") as? MostPlayVideoVC {
                
                controller.modalPresentationStyle = .fullScreen
                controller.selected_category = item
                controller.selected_userUID = leaderboard_list[collectionView.tag].userUID
                
                self.present(controller, animated: true, completion: nil)
                
                
            }
            
            
        }
    
    }
    
}
