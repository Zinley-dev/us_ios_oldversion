//
//  FeedVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/20/20.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Firebase
import SwiftPublicIP
import Alamofire
import SwiftyJSON


enum LoadControl {
    case NewLoad
    case NewLoadCategory
    case MoreLoad
    case MoreLoadCategory
}


class FeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate, UITextFieldDelegate {


    var ControlLoad = LoadControl.NewLoad
    var currentIndex = 0
    var challengeItem: HighlightsModel!
    var challengeName = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bView: UIView!
    
  
    var firstLoad = true
    var previousIndex = 0
    var itemList = [CategoryModel]()
    var tableNode: ASTableNode!
    var posts = [HighlightsModel]()
    var lastDocumentSnapshot: DocumentSnapshot!
    var query: Query!
    var item_id_list = [String]()
    var index = 0
    var type = "For you"
    
    var backgroundView = UIView()
    var CView = ChallengesView()
    var keyboard = false
    var myCategoryOrdersTuple: [(key: String, value: Float)]? = nil
    var viewsCategoryOrdersTuple: [(key: String, value: Float)]? = nil
    
    
    private var pullControl = UIRefreshControl()
    private var dragControl = UIRefreshControl()
    
    
    var RecommendLoad = false
    var max_category_record = 100
    var min_category_record = 10
    
    var isFeed = false
   
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
       
        bView.addSubview(tableNode.view)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 2
        
        
        loadAddGame()
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
       
        
        /*
        dragControl.tintColor = UIColor.systemOrange
        dragControl.addTarget(self, action: #selector(refreshListCategory(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = dragControl
        } else {
            collectionView.addSubview(dragControl)
        }
        
        self.collectionView.alwaysBounceVertical = true
        */
   
    }
    
    @objc private func refreshListCategory(_ sender: Any) {
      
        // stop after API Call
        // Call API
                
        self.itemList.removeAll()
        self.firstLoad = true
        loadAddGame()
              
    }
    
    
    func LoadCategorySelection(completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef
    
        if let uid = Auth.auth().currentUser?.uid {
            
        db.collection("Category_record").order(by: "timeStamp", descending: true).whereField("userUID", isEqualTo: uid).limit(to: max_category_record).getDocuments { (snap, err) in
       
                if err != nil {
                    print(err!.localizedDescription)
                    completed()
                    return
                }
                
                
                if snap!.count < self.min_category_record {
                    
                    completed()
                    print("Ignored")
                    
                } else {
                    
                    var lis = [String]()
                    
                    for item in snap!.documents {
                        
                        if let name = item.data()["category"] as? String {
                            
                            lis.append(name)
                            
                        }
                        
                        
                    }
                    
                    var dict = [String: Float]()
                    
                    for i in lis {
                        
                        if dict.keys.contains(i) {
                            dict[i]! += 1.0
                        } else {
                            dict[i] = 1.0
                        }
                        
                    }
                    
                    for (key,value) in dict {
                        let val = value * (70/100)
                        dict[key] = val
                    }
                    
                    self.myCategoryOrdersTuple = dict.sorted { (first, second) -> Bool in
                        return first.value > second.value
                    }
                    
                    completed()
                    
                    
                }
                
                
                
                
            }
            
        }
        
        
    }
    
    
    func LoadViewCategory(completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Views")
        
        if let uid = Auth.auth().currentUser?.uid {
        
        db.order(by: "timeStamp", descending: true).whereField("ViewerID", isEqualTo: uid).limit(to: max_category_record).getDocuments { (snap, err) in
       
                if err != nil {
                    print(err!.localizedDescription)
                    completed()
                    return
                }
            
            
            if snap!.count < self.min_category_record {
                
                completed()
                print("Ignored")
                
            } else {
                
                var lis = [String]()
                
                for item in snap!.documents {
                    
                    if let name = item.data()["category"] as? String {
                        
                        lis.append(name)
                        
                    }
                    
                    
                }
                
                var dict = [String: Float]()
                
                for i in lis {
                    
                    if dict.keys.contains(i) {
                        dict[i]! += 1.0
                    } else {
                        dict[i] = 1.0
                    }
                    
                }
                
                for (key,value) in dict {
                    let val = value * (30/100)
                    dict[key] = val
                }
                
                self.viewsCategoryOrdersTuple = dict.sorted { (first, second) -> Bool in
                    return first.value > second.value
                }
                
                completed()
            
            }
            
            
        }
    
    }
        
        
    }
    
    
    
    
    @objc func handleKeyboardShow(notification: Notification) {
        keyboard = true
    }
        
    @objc func handleKeyboardHide(notification: Notification) {
        
        keyboard = false
        
    }
    
    @objc func scrollToIndex() {
        
        if currentIndex + 1 < item_id_list.count {
            
            tableNode.scrollToRow(at: IndexPath(row: currentIndex + 1, section: 0), at: .bottom, animated: true)
            
        }
        
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        should_Play = false
        alreadyShow = false
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "scrollToIndex")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.shouldScrollToTop), name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.scrollToIndex), name: (NSNotification.Name(rawValue: "scrollToIndex")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "CheckIfPauseVideo")), object: nil)
        
        
        
        should_Play = true
        alreadyShow = true
        
        
    
    }
    
    func loadRecommendCategory() {
        
        
        LoadCategorySelection() {
            
            self.LoadViewCategory() {
      
                if self.myCategoryOrdersTuple != nil, self.viewsCategoryOrdersTuple != nil {
                    
                    
                    var copylist = self.itemList
                    var newList = [CategoryModel]()
                    var dict = [String: Float]()
                    var key = [String]()
                
                    for (key1, vals1) in self.myCategoryOrdersTuple! {
                        
                        for (key2, vals2) in self.viewsCategoryOrdersTuple! {
                                
                            if key1 == key2 {
                                
                                let val = vals1 + vals2
                                dict[key1] = val
                                key.append(key1)
                                
                            } else {
                                
                                if key.contains(key1) {
                                    
                                    dict[key2] = vals2
                                    key.append(key2)
                                    
                                } else {
                                    
                                    dict[key1] = vals1
                                    key.append(key1)
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                    let sorted = dict.sorted { (first, second) -> Bool in
                        return first.value > second.value
                    }
                    
                    var list = [String]()
                    
                    
                    for (key, _) in sorted {
                        
                        list.append(key)
                        
                    }
                    
                    var attempt = 0
                    var index = 0
                    var completed = false
                   
                    while (completed == false) {
                        
                        for i in self.itemList {
                            
                            if i.name != "For you", i.name != "Others", index < list.count {
         
                                if i.name == list[index] {
                                
                                    newList.append(i)
                                    
                                    let indexes = self.findIndex(list: copylist, name: i.name)
                                    copylist.remove(at: indexes)
                                }
                                
                            }
                            
                          
                        }
                        
                        index += 1
                        attempt += 1
                        
                        if attempt == list.count {
                            completed = true
                        }
                        
                    }
                    
                    
                    for i in copylist {
                        if i.name == "For you" {
                            
                            newList.insert(i, at: 0)
                       
                        } else {
                            newList.append(i)
                        }
                        
                    }
                    
                    self.itemList.removeAll()
                    self.itemList = newList
                    
                    self.collectionView.reloadData()
                   
                    
                } else {
                    
                     self.collectionView.reloadData()
                    
                }
                
            }
                    
                    
        }
 
    }
    
    func findIndex(list: [CategoryModel], name: String) -> Int {
        
        var count = 0
        for i in list {
            
            if i.name == name {
                break
            }
            
            count+=1
            
        }
        
        return count
        
    }
    
    
    func findIndex(item: String, list: [String]) -> Int {
        
        var count = 0
        
        for i in list {
            
            if item == i {
            
               return count
                
            }
            
            count += 1
        }
        
        return -1
        
    }
    
    
    
    
    @objc func shouldScrollToTop() {
        
        
        if currentIndex != 0, alreadyShow == true {
            
            if tableNode.numberOfRows(inSection: 0) != 0 {
                tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                
                print("scroll to top")
                
            }
            
            
        }
        
        
    }
    
    

    @objc private func refreshListData(_ sender: Any) {
       // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        self.posts.removeAll()
        self.item_id_list.removeAll()
        impressionList.removeAll()
        self.index = 0
        self.RecommendLoad = false
        
        self.tableNode.reloadData()
        
        
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = bView.bounds
        
    }
    
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = itemList[indexPath.row]

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCategoryCell", for: indexPath) as? FeedCategoryCell {
            
            
            let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
            
            if item.isSelected == true {
                
                cell.shadowView.isHidden = true
                cell.backView.backgroundColor = selectedColor
                cell.layer.cornerRadius = 15
                
                if item.name == "For you" {
                    cell.Fylbl.textColor = UIColor.white
                }
                
            } else {
                
                cell.shadowView.isHidden = false
                cell.backView.backgroundColor = UIColor.white
                cell.layer.cornerRadius = 17
                
                if item.name == "For you" {
                    cell.Fylbl.textColor = UIColor.black
                }
                
            }
                  
            cell.configureCell(item)
         
            return cell
            
        } else {
            
            return FeedCategoryCell()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if previousIndex != indexPath.row {
            
            self.itemList[indexPath.row]._isSelected = true
            self.itemList[previousIndex]._isSelected = false
            
            previousIndex = indexPath.row
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            
        }
        
        let item = self.itemList[indexPath.row]
        if item.name != "For you" {
            
            if let uid = Auth.auth().currentUser?.uid {
                
                
                recordCategorySelection(category: item.name, uid: uid)
                
            }
            
        }
        
        if item.name != type {
            
            if item.name == "For you" {
                
                type = item.name
                ControlLoad = LoadControl.NewLoad
                
                
            } else {
                
                type = item.name
                ControlLoad = LoadControl.NewLoadCategory
                
                
            }
            
            self.posts.removeAll()
            self.item_id_list.removeAll()
            impressionList.removeAll()
            self.index = 0
            self.RecommendLoad = false
            self.tableNode.reloadData()
            
            print("Type changes => load new")
            
        } else {
            //
            
            if currentIndex == 0 {
                
                self.posts.removeAll()
                self.item_id_list.removeAll()
                impressionList.removeAll()
                self.index = 0
                self.RecommendLoad = false
                self.tableNode.reloadData()
                
                print("scrolled to top => load new")
                
            } else {
                
                
                if tableNode.numberOfRows(inSection: 0) != 0 {
                    tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    
                    print("scroll to top")
                }
                
                
                
            }
            
            
        }
        
        
        
        
    
    }
    
    func recordCategorySelection(category: String, uid: String) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Category_record")
        
        let data = ["category": category, "userUID": uid, "timeStamp": FieldValue.serverTimestamp()] as [String : Any]
        
        
        db.addDocument(data: data) { (err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                
                
            }
            
        }
        
        
        
    }
    
    func loadAddGame() {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Support_game").order(by: "name", descending: true)
            .addSnapshotListener { [self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if firstLoad == true {
                    
                    for item in snapshot.documents {
                        
                        if item.data()["status"] as! Bool == true {
                            
                            var i = item.data()
                            i.updateValue(false, forKey: "isSelected")
                            let item = CategoryModel(postKey: item.documentID, Game_model: i)
                            
                            if i["name"] as? String != "Others" {
                             
                                self.itemList.insert(item, at: 0)
                                
                            } else {
                                
                                self.itemList.append(item)
                                                  
                            }
                            
                        }
                        
                    }
                    
                    if self.dragControl.isRefreshing == true {
                        self.dragControl.endRefreshing()
                    }
                    
                    firstLoad =  false
        
                    let updateData: [String: Any] = ["name": "For you", "url": "", "url2": "", "status": true, "isSelected": true]
                    let item = CategoryModel(postKey: "For you", Game_model: updateData)
                    self.itemList.insert(item, at: 0)
                    
                    
                    loadRecommendCategory()
                    
                    
                    
                    
    
                }
                
                snapshot.documentChanges.forEach { diff in
                    

                    if (diff.type == .modified) {
                        
                        if diff.document["status"] as! Bool == true {
                            
                            let checkItem = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            let isIn = findDataInList(item: checkItem)
                            
                            if isIn == false {
                                
                                var data = diff.document.data()
                                
                                data.updateValue(false, forKey: "isSelected")
                                let item = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                                
                                if diff.document["name"] as? String != "Others" {
                                    
                                    self.itemList.insert(item, at: 1)
                                    
                                } else {
                                    
                                    self.itemList.append(item)
                                        
                                }
                                
                                
                            } else {
                                
                                let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                                let index = findDataIndex(item: item)
                                
                                let selected = self.itemList[index].isSelected
                                
                                var data = diff.document.data()
                                data.updateValue(selected!, forKey: "isSelected")
                                
                                let Fitem = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                                
                                self.itemList.remove(at: index)
                                self.itemList.insert(Fitem, at: index)
                                
                            
                            }
                            
                            self.collectionView.reloadData()
                            
                            
                        } else {
                            
                            
                            let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                            
                            let index = findDataIndex(item: item)
                            self.itemList.remove(at: index)
                            
                            
                            // delete processing goes here
                            
                            self.itemList[0]._isSelected = true
                
                            previousIndex = 0
                            self.collectionView.reloadData()
                            
                            
                        }
                        
              
                    } else if (diff.type == .removed) {
                        
                        let item = CategoryModel(postKey: diff.document.documentID, Game_model: diff.document.data())
                        
                        let index = findDataIndex(item: item)
                        self.itemList.remove(at: index)
                        
                        
                        // delete processing goes here
                        
                        self.itemList[0]._isSelected = true
                        previousIndex = 0
                        self.collectionView.reloadData()
                        
                        
                    } else if (diff.type == .added) {
                        
                        
                        if diff.document["status"] as! Bool == true {
                            
                            var data = diff.document.data()
                            data.updateValue(false, forKey: "isSelected")
                            
                            let item = CategoryModel(postKey: diff.document.documentID, Game_model: data)
                          
                            let isIn = findDataInList(item: item)
                            
                            if isIn == false {
                                
                                if diff.document["name"] as? String != "Others" {
                                    
                                    self.itemList.insert(item, at: 1)
                                    
                                } else {
                                    
                                    self.itemList.append(item)
                                    
                                }
 
                                                      
                            }
                            
                            self.collectionView.reloadData()
                            
                            
                        }
                        
                    }
                }
            }
        
    }
    
    func findDataInList(item: CategoryModel) -> Bool {
        
        for i in itemList {
            
            if i.name == item.name {
                
                return true
                
            }
          
        }
        
        return false
        
    }
    
    func findDataIndex(item: CategoryModel) -> Int {
        
        var count = 0
        
        for i in itemList {
            
            if i.name == item.name {
                
                break
                
            }
            
            count += 1
            
        }
        
        return count
        
    }
 
    // layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = self.itemList[indexPath.row]
        
        if item.isSelected == true {
            
            return CGSize(width: 120, height: self.collectionView.frame.height)
            
        } else {
            
            return CGSize(width: 70, height: self.collectionView.frame.height)
            
        }
        
    }
    
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("Dismiss")
    }

    // functions
    
    
    func shareVideo(item: HighlightsModel) {
        
        if let id = item.highlight_id, id != "" {
            
            let items: [Any] = ["Check out this highlight", URL(string: "https://www.dual.so/\(id)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                
            }
           
           present(ac, animated: true, completion: nil)
           NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        
        }
    
        
    }
    
    func challenge(item: HighlightsModel) {
        
        
        if let uid = Auth.auth().currentUser?.uid, Auth.auth().currentUser?.isAnonymous != true, uid != item.userUID {
            
            
            self.backgroundView.frame = self.view.frame
            backgroundView.backgroundColor = UIColor.black
            backgroundView.alpha = 0.6
            self.view.addSubview(backgroundView)
            
            
            
            CView.frame = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height * (250/813), width: self.view.frame.size.width * (365/414), height: self.view.frame.size.height * (157/813))
            self.view.addSubview(CView)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
            CView.messages.becomeFirstResponder()
            CView.center.x = view.center.x
            challengeItem = item
            CView.messages.delegate = self
            
            CView.messages.attributedPlaceholder = NSAttributedString(string: "Send a message to @\(challengeName)",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
            CView.messages.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            CView.send.addTarget(self, action:  #selector(FeedVC.ChallengeBtnPressed), for: .touchUpInside)
           
            
        } else {
            
            
            self.showErrorAlert("Oops !", msg: "You should be a signed user to challenge")
            
            
        }
     
        

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        
        if textField == CView.messages, CView.messages.text != "" {
            
            CView.maxCharLbl.text = "Max 35 chars - \(CView.messages.text!.count)"
            
        } else {
            
            CView.maxCharLbl.text = "Max 35 chars"
            
        }
        
        
    }
    
    func checkPendingChallenge(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
       
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Pending").getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                
                completed()
                
            } else {
                
                self.showErrorAlert("Oops !", msg: "You have sent to @\(self.challengeName) a challenge before, please wait for the user's acceptance or until the expiration time.")
                return
                
            }
            
        
        }
        

        
    }
    
    func checkActiveChallenge(receiver_ID: String, completed: @escaping DownloadComplete) {
        
        let db = DataService.instance.mainFireStoreRef.collection("Challenges")
        
        db.whereField("sender_ID", isEqualTo: Auth.auth().currentUser!.uid).whereField("receiver_ID", isEqualTo: receiver_ID).whereField("challenge_status", isEqualTo: "Active").getDocuments { (snap, err) in
       
            if err != nil {
                self.showErrorAlert("Oops !", msg: err!.localizedDescription)
                return
            }
            
            if snap?.isEmpty == true {
                completed()
                
            } else {
                
                self.showErrorAlert("Oops !", msg: "Your and @\(self.challengeName)'s challenge is active, you can't send another the expiration time.")
                return
                
            }
            
            
            
        }
        
    }
    
    @objc func ChallengeBtnPressed() {
        
        if challengeItem != nil {
            
            checkPendingChallenge(receiver_ID: challengeItem.userUID) {
                
                self.checkActiveChallenge(receiver_ID: self.challengeItem.userUID) {
                    
                    if self.CView.messages.text != "" {
                        
                        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                            if let error = error {
                                
                                print(error.localizedDescription)
                                self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                                
                            } else if let string = string {
                                
                                DispatchQueue.main.async() { [self] in
                                    
                        
                                    let device = UIDevice().type.rawValue
                                    let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(string)
                                    var data = ["receiver_ID": challengeItem.userUID!, "sender_ID": Auth.auth().currentUser!.uid, "category": challengeItem.category!, "created_timeStamp": FieldValue.serverTimestamp(), "started_timeStamp": FieldValue.serverTimestamp(), "Device": device, "messages": self.CView.messages.text!, "challenge_status": "Pending"] as [String : Any]
                                    
                                    let db = DataService.instance.mainFireStoreRef.collection("Challenges")
                                    
                                    AF.request(urls, method: .get)
                                        .validate(statusCode: 200..<500)
                                        .responseJSON { responseJSON in
                                            
                                            switch responseJSON.result {
                                                
                                            case .success(let json):
                                                
                                                if let dict = json as? Dictionary<String, Any> {
                                                    
                              
                                                    if let status = dict["status"] as? String, status == "success" {
                                                        
                                                        data.merge(dict: dict)
                                                               
                                                        db.addDocument(data: data) { (errors) in
                                                            
                                                            if errors != nil {
                                                                
                                                                self.showErrorAlert("Oops !", msg: errors!.localizedDescription)
                                                                return
                                                                
                                                            }
                                                            
                                                            CView.messages.text = ""
                                                            backgroundView.removeFromSuperview()
                                                            CView.removeFromSuperview()
                                                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                                                            
                                                            showNote(text: "Cool! You have succesfully sent a challenge to @\(challengeName)")
                                                            
                                                            
                                                        }
                      
                                                    }
                                                    
                                                }
                                                
                                            case .failure(let err):
                                                
                                                print(err.localizedDescription)
                                                self.showErrorAlert("Oops !", msg: "Can't verify your information to send challenge, please try again.")
                                               
                                                
                                            }
                                            
                                        }
                                    
                                }
                                
             
                            }
                        }
                                  
                        
                        
                    } else {
                        
                        self.showErrorAlert("Oops !!!", msg: "Please enter your challenge messages.")
                        
                    }
                    
                }
                
            }
            
            
            
      
            
        } else {
            
            backgroundView.removeFromSuperview()
            CView.removeFromSuperview()
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
            
            self.showErrorAlert("Oops !!!", msg: "Can't send challeng now, please try again")
            
            
        }
        
       
       
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                                                                      
        
    }
    
    func openLink(item: HighlightsModel) {
        
        if let link = item.stream_link, link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }

            if UIApplication.shared.canOpenURL(requestUrl) {
                 UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            }
            
        } else {
            
            print("Empty link")
            
        }

    }
    
    
    func openProfile(item: HighlightsModel) {
        
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pauseVideo")), object: nil)
        isFeed = true
        self.performSegue(withIdentifier: "moveToUserProfileVC3", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfileVC3"{
            if let destination = segue.destination as? UserProfileVC
            {
                
                destination.isFeed = self.isFeed
                  
            }
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.CView)
            
            if CView.bounds.contains(currentPoint) {
              
            } else {
                
                if keyboard == true {
                    
                    self.view.endEditing(true)
                    
                    
                } else {
                    
                    backgroundView.removeFromSuperview()
                    CView.removeFromSuperview()
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "resumeVideo")), object: nil)
                    
                }
               
            }
            
        }
        
        
    }
    
        
}
extension FeedVC: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width;
        let min = CGSize(width: width, height: self.bView.layer.frame.height);
        let max = CGSize(width: width, height: self.bView.layer.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        
        return true
        
    }
    
    
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
       
   
        if RecommendLoad == true {
            
            if item_id_list.isEmpty != true, index < item_id_list.count {
      
                self.retrieveNextPageWithCompletion { (newPosts) in
                    
                    
                    self.insertNewRowsInTableNode(newPosts: newPosts)
                    if self.pullControl.isRefreshing == true {
                        self.pullControl.endRefreshing()
                    }
                    
                    context.completeBatchFetching(true)
                    
                    
                }
                
            } else {
                
                if type == "For you" {

                    ControlLoad = LoadControl.MoreLoad
      
                } else {
    
                    ControlLoad = LoadControl.MoreLoadCategory

                }
           
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let string = string {
                    
                        loadRecommendID(IP: string) {
                            if item_id_list.isEmpty != true {
                                
                                self.checkExistKey(list: item_id_list) {
                                
                                    if item_id_list.isEmpty != true, index < item_id_list.count {
                                        
                                        self.retrieveNextPageWithCompletion { (newPosts) in
                                            
                                            self.insertNewRowsInTableNode(newPosts: newPosts)
                                            if self.pullControl.isRefreshing == true {
                                                self.pullControl.endRefreshing()
                                            }
                                            
                                            context.completeBatchFetching(true)
                                           
                                        }
                                        
                                        
                                    } else {
                                        
                                        context.completeBatchFetching(true)
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
                            } else {
                                
                                context.completeBatchFetching(true)
                                
                            }
                    
                        }
                       
                    }
                }
                
            }
            
        } else {
            
            
            SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { [self] (string, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let string = string {
                
                    loadRecommendID(IP: string) {
                      
                        if item_id_list.isEmpty != true {
                            
                            self.checkExistKey(list: item_id_list) {
                            
                                if item_id_list.isEmpty != true, index < item_id_list.count {
                                    
                                    self.retrieveNextPageWithCompletion { (newPosts) in
                                        
                                        self.insertNewRowsInTableNode(newPosts: newPosts)
                                        if self.pullControl.isRefreshing == true {
                                            self.pullControl.endRefreshing()
                                        }
                                        
                                        context.completeBatchFetching(true)
                                       
                                    }
                                    
                                } else {
                                    
                                    context.completeBatchFetching(true)
                                    
                                }
                                
                                
                                
                                
                            }
                            
                            
 
                            
                        } else {
                            
                            context.completeBatchFetching(true)
                            
                            
                        }
                    
                        
                    }
                   
                }
            }
            
            
            
            
        }
        
 
    }
    
   
}

extension FeedVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        return self.posts.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let post = self.posts[indexPath.row]
           
        return {
            let node = PostNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.shareBtn = { (node) in
                
                self.shareVideo(item: post)
                  
            }
            
            node.challengeBtn = { (node) in
                
                self.challenge(item: post)
                
            }
            
            
            node.linkBtn = { (node) in
                
                self.openLink(item: post)
                
            }
            
            
            node.profileBtn = { (node) in
                
                self.openProfile(item: post)
                
            }
                
            return node
        }
        
   
            
    }
    

    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        
        guard let cell = node as? PostNode else { return }
        
        currentIndex = cell.indexPath!.row
        
        if cell.animatedLabel != nil {
            
            cell.animatedLabel.restartLabel()
            
        }
        
        challengeName = cell.challengeName
        
        cell.startObserve()
    
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didEndDisplayingRowWith node: ASCellNode) {
    
        
        guard let cell = node as? PostNode else { return }
        
        if cell.PlayViews != nil {
            cell.PlayViews.playImg.image = nil
        }
        
        
        cell.removeAllobserve()
        
    }
    
    func loadRecommendID(IP: String, completed: @escaping DownloadComplete) {
        
        let urlss = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(IP)
   
        AF.request(urlss, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                
                switch responseJSON.result {
                    
                case .success(let json):
                    
                    if let dict = json as? Dictionary<String, Any> {
                        
                        if let status = dict["status"] as? String, status == "success" {
                            
                            if let country = dict["country"] as? String {
                                
                                if let uid = Auth.auth().currentUser?.uid {
                                    
                                    let urls: URL!
                                    let url = MainAPIClient.shared.baseURLString
                                    
                                    
                                    switch self.ControlLoad {
                                        
                                    case .NewLoad:
                                        urls = URL(string: url!)?.appendingPathComponent("aws-personalize-get-recommendation")
                                    case .NewLoadCategory:
                                        urls = URL(string: url!)?.appendingPathComponent("aws-personalize-get-recommendation-category")
                                        
                                    case .MoreLoad:
                                        urls = URL(string: url!)?.appendingPathComponent("aws-personalize-get-recommendation-viewFilter")
                                    case .MoreLoadCategory:
                                        urls = URL(string: url!)?.appendingPathComponent("aws-personalize-get-recommendation-category-viewFilter")
                                    
                                    }
                                    
            
                                    
                                    AF.request(urls!, method: .post, parameters: [

                                        "USER_ID": uid,
                                        "REGION_ID": country,
                                        "TYPE_ID": self.type
                                        
                                        
                                    ])
                                    .validate(statusCode: 200..<500)
                                    .responseJSON { responseJSON in
                                        
                                        switch responseJSON.result {
                                            
                                        case .success(let json):
                                            
                                            if let dict = json as? Dictionary<String, AnyObject> {
                                                
                                                if let result = dict["itemList"] as? [Dictionary<String, AnyObject>] {
                                                    
                                                    for i in result {
                                                        
                                                        if let itemid = i["itemId"] as? String {
                                                            
                                                            if self.checkDuplicatedVal(id: itemid) == false {
                                                                self.item_id_list.append(itemid)
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    switch self.ControlLoad {
                                                        
                                                    case .NewLoad:
                                                        self.item_id_list.shuffle()
                                                    case .NewLoadCategory:
                                                        self.item_id_list.shuffle()
                                                        
                                                    case .MoreLoad:
                                                        print("Load more")
                                                    case .MoreLoadCategory:
                                                        print("Load more")
                                                    
                                                    }
                                                    
                                                    
                                                    self.RecommendLoad = true
                                                    completed()
                                                    
                                                }
                                                
                                            }
                                                
                                            
                                            
                                        case .failure(let error):
                                            
                                            self.RecommendLoad = false
                                            print(error.localizedDescription)
                                            completed()
                                            return
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                    }
                    
                case .failure( _):
                    
                    
                    
                    print("Failed")
                    return
                    
                }
                
            }
        
  
    }
    
    func checkExistKey(list: [String], completed: @escaping DownloadComplete) {
        
        var count = 0
        let total = list.count
        var tempList = [String]()
        let db = DataService.instance.mainFireStoreRef
        
        
        
        for key in list {
        
            db.collection("Highlights").document(key).getDocument { (snap, err) in

                if err != nil {
                    
                    print(err!.localizedDescription)
                    return
                }
                
                if snap?.data() != nil, snap!.data()!["status"] as! String == "Ready" {
                    
                    tempList.append(key)
                    
                } else {
                    
                    print("Key not exits \(key) at \(count + 1) out of \(total)")
                    
                }
                
                if count == total - 1 {
   
                    self.item_id_list = tempList
                    completed()
                    
                }
                
                count += 1
                
            }
            
            
        }
        
        
        
    }
    
    func checkDuplicatedVal(id: String) -> Bool {
        
        if item_id_list.isEmpty == true {
            
            return false
            
        } else {
            
            for i in item_id_list {
                
                if i == id {
                    return true
                }
                
            }
            
            return false
            
        }

        
    }

    
}

extension FeedVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([DocumentSnapshot]) -> Void) {
 
        let db = DataService.instance.mainFireStoreRef
        if item_id_list.isEmpty == true || item_id_list.count > index {
                 
        print("Load index: \(index), item: \(item_id_list[index]), itemCount: \(item_id_list.count)")
                 
        db.collection("Highlights").document(item_id_list[index]).getDocument { (snap, err) in
     
            if err != nil {
                         
                print(err!.localizedDescription)
                return
            }
                     
                self.index += 1
                     
                DispatchQueue.main.async {
                         block([snap!])
                }
                    
            
            }
             
             
        }
        
       
    
    }
    
    
    
    func insertNewRowsInTableNode(newPosts: [DocumentSnapshot]) {
        
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        var items = [HighlightsModel]()
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + newPosts.count
        
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newPosts {
            
            let item = HighlightsModel(postKey: i.documentID, Highlight_model: i.data()!)
            items.append(item)
          
        }
        
    
        self.posts.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
        
    }
    
    
}
