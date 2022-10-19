//
//  AddVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import UIKit
import Cache
import Alamofire
import AlamofireImage
import Firebase
import AsyncDisplayKit


class AddVC: UIViewController, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
     
    
    var itemList = [AddModel]()
    var selectedItem: AddModel!
    var SelectedIndex: IndexPath!
    var collectionNode: ASCollectionNode!
    
    var firstLoad = true
    var caseLoad = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil{
                
            return
               
        }
       
        
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        loadAddGame()
        
  
    
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.switchvc), name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
         
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        
        contentView.addSubview(collectionNode.view)
      
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
        applyStyle()
         
       
        
    }
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }

    @objc func switchvc() {
    
        print("switch request")
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![0]
        
    }
    
    @objc func updateProgressBar() {
        
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
           
            global_percentComplete = 0.00
            
        }
        
        
        
    }
  
    
    @objc func SignUpBtnPressed() {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Maintenance_control").whereField("status", isEqualTo: true).getDocuments{ querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
            
            if snapshot.isEmpty == true {
                
                self.performSegue(withIdentifier: "moveToLoginVC1", sender: nil)
                
            } else {
                
                self.showErrorAlert("Notice", msg: "We're down for scheduled maintenance right now!")
                
            }
            
        }
        
        
        
    }
    

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
        
    }
    


    func loadAddGame() {
        
        let db = DataService.instance.mainFireStoreRef
        
        addGameAddVC = db.collection("Support_game").order(by: "name", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if self.firstLoad == true {
                    
                    for item in snapshot.documents {
                        
                        let i = item.data()
                        let item = AddModel(postKey: item.documentID, Game_model: i)
                        
                        if i["name"] as? String != "General", i["name"] as? String != "Search" {
                            
                            if i["name"] as? String != "Others" {
                             
                                
                                self.itemList.insert(item, at: 0)
                                
                            } else {
                                
                                self.itemList.append(item)
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    global_add_list = self.itemList
                    
                    self.collectionNode.reloadData()
                    
                    self.firstLoad =  false
                    
                }
                
          
                snapshot.documentChanges.forEach { diff in
                    
                    
                    let item = AddModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                    
                    if diff.document.data()["name"] as? String != "General", diff.document.data()["name"] as? String != "Search" {
                        
                        if (diff.type == .modified) {
            
                            let isIn = self.findDataInList(item: item)
                            
                            if isIn == false {
                                
                                self.itemList.insert(item, at: 0)
                                
                            } else {
                                
                                let index = self.findDataIndex(item: item)
                                self.itemList.remove(at: index)
                                self.itemList.insert(item, at: index)
                                    
                            }
                            
                            global_add_list = self.itemList
                            
                            self.collectionNode.reloadData()
                            
                        } else if (diff.type == .removed) {
                            
                            let index = self.findDataIndex(item: item)
                            self.itemList.remove(at: index)
                            
                            
                            global_add_list = self.itemList
                            self.collectionNode.reloadData()
                            
                            // delete processing goes here
                            
                        } else if (diff.type == .added) {
                            
                          
                            let isIn = self.findDataInList(item: item)
                            
                            if isIn == false {
                                
                                self.itemList.insert(item, at: 0)
                                
                                global_add_list = self.itemList
                                self.collectionNode.reloadData()
                                
                        }
        
                    }
                        
                }
          
            }
        }
    }
    
    func findDataInList(item: AddModel) -> Bool {
        
        for i in itemList {
            
            if i.name == item.name {
                
                return true
                
            }
            
        }
        
        return false
        
    }
    
    func findDataIndex(item: AddModel) -> Int {
        
        var count = 0
        
        for i in itemList {
            
            if i.name == item.name {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func ContinueBtnPressed(_ sender: Any) {
        
        
        if global_percentComplete == 0.00 || global_percentComplete == 100.0 {
            self.performSegue(withIdentifier: "moveToCreateHighlightVC", sender: nil)
        } else {
            self.showErrorAlert("Oops!", msg: "Your current video is being uploaded.")
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "moveToCreateHighlightVC"{
            if let destination = segue.destination as? HighlightVC
            {
                
                destination.item = self.selectedItem
                destination.itemList = self.itemList
               
                
            }
        }
        
        
    }
    

}


extension AddVC: ASCollectionDelegate {
   
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let min = CGSize(width: view.frame.width/2 - 25, height: 57);
        let max = CGSize(width: view.frame.width/2 - 25, height: 57);
        return ASSizeRangeMake(min, max);
       
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        return false
    }
    

}

extension AddVC: ASCollectionDataSource {
    
   
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        
        return 1
        
        

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
      
    }
 
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let category = self.itemList[indexPath.row]
       
        return {
            
            let node = AddNode(with: category)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
           
            return node
        }
        
    }
    

   
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        
        if let cell = collectionNode.nodeForItem(at: indexPath) as? AddNode {
            
            
            if itemList.isEmpty != true {
                
                let item = itemList[indexPath.row]
                
                if item.status != true {
                    
                    self.showErrorAlert("Oops!", msg: "This category is temporarily disabled, please try again later.")
                    
                    return
                    
                }
                
                if selectedItem != nil {
                    
                    if item.name == selectedItem.name, item.url == selectedItem.url {
                        
                       
                        cell.AddViews.name.textColor = UIColor.white
                        selectedItem = nil
                        
                    } else {
                        
                       
                        let DeselectedCell = collectionNode.nodeForItem(at: SelectedIndex as IndexPath) as? AddNode
                        
                       
                        DeselectedCell?.AddViews.name.textColor = UIColor.white
                        
                        let item = itemList[indexPath.row]
                     
     
                        if cell.isSelected == true {
                            
                            cell.AddViews.name.textColor = selectedColor
                            selectedItem = item
                            SelectedIndex = indexPath
                            
                                
                        }

                        
                        
                    }
                    
                } else {
                    
                    if cell.isSelected == true {
                        
                        cell.AddViews.name.textColor = selectedColor
                        selectedItem = item
                        SelectedIndex = indexPath
                            
                    }
                    
                }
                
                
                // check whether disable continue button
                if selectedItem == nil {
                    
                    continueBtn.isHidden = true
                    
                } else {
                    
                    continueBtn.isHidden = false
                }
              
                
            }
            
            
        }
        
        
        
    }
   


}

