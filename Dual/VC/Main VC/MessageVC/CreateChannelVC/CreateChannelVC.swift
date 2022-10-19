//
//  CreateChannelVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 3/28/21.
//

import UIKit
import SendBirdUIKit
import Firebase
import SendBirdSDK
import Alamofire
import AlgoliaSearchClient


class CreateChannelVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    

    var userListQuery: SBDApplicationUserListQuery?
    
    var inSearchMode = false

    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    //
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var searchUserListAgo  = [UserModelFromAlgolia]()
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    //
    
    var createButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    private lazy var titleView: UIView? = _titleView
    private lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
   
    private lazy var _titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = "New Message"
        titleView.textAlignment = .center
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            
            image: SBUIconSet.iconBack.resize(targetSize: CGSize(width: 25.0, height: 25.0)),
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: "Chat",
                style: .plain,
                target: self,
                action: #selector(createChannel)
            )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.placeholder = "Search"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        
        self.searchController?.searchBar.searchBarStyle = .minimal
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor.white
       
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)
        
       
        self.setupScrollView()
        
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
     
        // Styles
        self.setupStyles()
        
        var first20 = global_following_list.prefix(20)
        
        if first20.count < 20 {
            
            let already = 20 - first20.count
            let second20 = global_availableChatList.prefix(already)
            for uid in second20 {
                if first20.contains(uid) == false {
                    first20.append(uid)
                }
            }
                    
    
        }
        
        print(first20)
        loadInfoPreUser(list: Array(first20))
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tabBarController?.tabBar.frame = .zero
        
    }
    
    func loadInfoPreUser(list: [String]) {
        
        
        var count = 0
        let max = list.count
        var pre_dict = [String: [String: Any]]()
        
        
        for key in list {
            
            DataService.instance.mainFireStoreRef.collection("Users").document(key).getDocument {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                
                if snapshot.exists {
                                
                    if let item = snapshot.data() {
                        
                        if let username = item["username"] as? String, let avatarUrl = item["avatarUrl"] as? String  {
                            
                            let data = ["username": username, "profileUrl": avatarUrl, "userUID": key]
                            pre_dict[key]  = data
                            
                            count += 1
                            
                        } else {
                            count += 1
                        }
                                    
                    }
                    
                } else {
                    
                    count += 1
                    
                }
                
                
                
                
                print(count, max)
                
                if count == max - 1 {
                 
                    self.finishPreloadUser(dict: pre_dict)
                }
                
            }
            
          
            
        }
        
       
        
    }
    
    func finishPreloadUser(dict: [String: [String: Any]]) {
        
        for (_, val) in dict {
            
            if let userUID = val["userUID"] as? String, let avatarUrl = val["profileUrl"] as? String, let username = val["username"] as? String{
                
                if userUID != Auth.auth().currentUser?.uid {
                    
                    let user = SBUUser(userId: userUID, nickname: username, profileUrl: avatarUrl)
                    
                    self.userList.append(user)
                    
                }
                
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func setupStyles() {

        self.leftBarButton?.tintColor = SBUTheme.userListTheme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUsers.isEmpty
            ? SBUTheme.userListTheme.rightBarButtonTintColor
            : SBUTheme.userListTheme.rightBarButtonSelectedTintColor

    }
    

    func setupScrollView() {
        self.selectedUserListView.contentInset = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
        self.selectedUserListView.delegate = self
        self.selectedUserListView.dataSource = self
        self.selectedUserListView.register(SelectedUserCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier())
        self.selectedUserListHeight.constant = 0
        self.selectedUserListView.isHidden = true
        
        self.selectedUserListView.showsHorizontalScrollIndicator = false
        self.selectedUserListView.showsVerticalScrollIndicator = false
        
        if let layout = self.selectedUserListView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 120, height: 30)
        }
    }
        
    @objc func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

  
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedUserCollectionViewCell
        
        
        cell.nicknameLabel.text = selectedUsers[indexPath.row].nickname
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedUsers.remove(at: indexPath.row)
        
        
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
        setupStyles()
        
        DispatchQueue.main.async {
            if self.selectedUsers.count == 0 {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            collectionView.reloadData()
            self.tableView.reloadData()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            
            return self.searchUserList.count
           
        } else {
            
            return self.userList.count
                   
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var user: SBUUser?
        
        if inSearchMode {
            
            if indexPath.row < searchUserList.count {
                
                user = searchUserList[indexPath.row]
                
            }
          
            
        } else {
            
            user = userList[indexPath.row]
                   
        }
        
        
        var cell: UITableViewCell? = nil
        cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)

        cell?.selectionStyle = .none

        if let defaultCell = cell as? SBUUserCell {
            defaultCell.configure(
                type: .createChannel,
                user: user!,
                isChecked: self.selectedUsers.contains(user!)
            )
        }
        
        return cell ?? UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        var user: SBUUser?
        
        if inSearchMode {
            
            user = searchUserList[indexPath.row]
            searchController?.searchBar.text = ""
            
        } else {
            
            user = userList[indexPath.row]
            
        }
        
        if inSearchMode {
            
            if let user = self.searchUserList[exists: indexPath.row] {
                if self.selectedUsers.contains(user) {
                    self.selectedUsers.removeObject(user)
                } else {
                    if !self.userList.contains(user) {
                        self.userList.insert(user, at: 0)
                    }
                    self.selectedUsers.append(user)
                }
            }
            
        } else {
            
            if let user = self.userList[exists: indexPath.row] {
                if self.selectedUsers.contains(user) {
                    self.selectedUsers.removeObject(user)
                } else {
                    self.selectedUsers.append(user)
                }
            }
            
        }
        
        
        
       
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
        DispatchQueue.main.async {
            if self.selectedUsers.count > 0 {
                self.selectedUserListHeight.constant = 40
                self.selectedUserListView.isHidden = false
            }
            else {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            
            if let defaultCell = self.tableView.cellForRow(at: indexPath) as? SBUUserCell {
                defaultCell.selectUser(self.selectedUsers.contains(user!))
            }
            
            self.setupStyles()
            
            self.selectedUserListView.reloadData()
        }
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchUserList.removeAll()
        inSearchMode = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchUserList = userList
        inSearchMode = true
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
           
            let filteredUsers = userList.filter { ($0.nickname?.contains(searchText))!}
            
            if filteredUsers.count != 0 {
                
                searchUserList = filteredUsers
                self.tableView.reloadData()
                
            } else {
                
                if searchText != "" {
                    
                    self.searchUsers(searchText: searchText)
                    
                }
            }
        }
    }
    
    func searchUsers(searchText: String) {
        AlgoliaSearch.instance.searchUsers(searchText: searchText) { userSearchResult in
            print("finish search")
            print(userSearchResult.count)
            if userSearchResult != self.searchUserListAgo {
                self.searchUserListAgo = userSearchResult
                
                if !self.searchUserListAgo.isEmpty {
                    self.searchUserList.removeAll()
                    for user in self.searchUserListAgo {
                        
                        if user.userUID != Auth.auth().currentUser?.uid, !global_block_list.contains(user.userUID) {
                            
                            let user = SBUUser(userId: user.userUID, nickname: user.username, profileUrl: user.avatarUrl)
                            
                            self.searchUserList.append(user)
                            
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                  
                }
                
            }
            
        }
    }
    
   @objc func createChannel() {

        if selectedUsers.count != 0 {
            
            let channelParams = SBDGroupChannelParams()
            channelParams.isDistinct = true
            for item in selectedUsers {
                channelParams.addUserId(item.userId)
            }
            
            if selectedUsers.count > 1 {
                channelParams.operatorUserIds = [Auth.auth().currentUser!.uid]
            }
            
            channelParams.addUserId(Auth.auth().currentUser!.uid)
            
            
            
            SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
                guard error == nil else {
                    // Handle error.
                    self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                    return
                }
                
                let channelUrl = groupChannel?.channelUrl
                
                if self.selectedUsers.count == 1 {
                    let user = self.selectedUsers[0]
                    addToAvailableChatList(uid: [user.userId])
                    
                    self.checkIfHidden(uid: user.userId, channelUrl: channelUrl!, channel: groupChannel!)
                    
                    
                } else {
                    
                    
                    var user_list = [String]()
                   
                    
                    for user in self.selectedUsers {
                        
                        if !user_list.contains(user.userId) {
                            user_list.append(user.userId)
                        }
                        
                    }
                    
                    addToAvailableChatList(uid: user_list)
                    self.hideForSelectedUser(channelUrl: channelUrl!, user_list: user_list, channel: groupChannel!)
                    
                    let channelVC = ChannelViewController(
                        channelUrl: channelUrl!,
                        messageListParams: nil
                    )
                    
                   
                    self.navigationController?.pushViewController(channelVC, animated: true)
                    self.navigationController?.viewControllers.remove(at: 1)
                    
                    
                    if self.selectedUsers.count > 1 {
                        
                        
                        self.sendAdminMessage(channelUrl: channelUrl!, message: "Let's chat")
                        
                        
                    }
                    
                }

                
    
                
                
            }
   
            
            
        }
   
    }
    
    func hideForSelectedUser(channelUrl: String, user_list: [String], channel: SBDGroupChannel) {
        
        
        let db = DataService.instance.mainFireStoreRef
        
        for user in user_list {
            
            db.collection("Users").document(user).getDocument {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                                
                    if snapshot.data() != nil {
                        
                        for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                                      
                            if item.userId != Auth.auth().currentUser?.uid {
                                
                                if item.state != .joined {
                                    
                                    self.acceptInviation(channelUrl: channelUrl, user_id: item.userId)
                                    
                                }
                                
                            }
                            
                        }
                        
                        /*
                        
                        if let Available_Chat_List = item["Available_Chat_List"] as? [String] {
                            
                            if !Available_Chat_List.contains(Auth.auth().currentUser!.uid) {
                                
                                self.hideChannel2(channelUrl: channelUrl, user_id: user)
                                
                            } else {
                                
                                //
                                
                                
                                for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                                              
                                    if item.userId != Auth.auth().currentUser?.uid {
                                        
                                        if item.state != .joined {
                                            
                                            self.acceptInviation(channelUrl: channelUrl, user_id: item.userId)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                                
                            }
                            
                            
                            
                        } else {
                            
                           
                            self.hideChannel2(channelUrl: channelUrl, user_id: user)
                            
                        } */
                                    
                    }
                    
                }
                
   
            }
            
         
            
        }
        
        
    }
    
    
    
    func checkIfHidden(uid: String, channelUrl: String, channel: SBDGroupChannel) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(uid).getDocument{  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                            
               if let item = snapshot.data() {
                   
                   if let Available_Chat_List = item["Available_Chat_List"] as? [String] {
                       
                       if Available_Chat_List.contains(Auth.auth().currentUser!.uid) {
                           
                           
                           for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                                         
                               if item.userId != Auth.auth().currentUser?.uid {
                                   
                                   if item.state != .joined {
                                       
                                       self.acceptInviation(channelUrl: channelUrl, user_id: uid)
                                       
                                   }
                                   
                               }
                               
                           }
                           
                           
                           let channelVC = ChannelViewController(
                               channelUrl: channelUrl,
                               messageListParams: nil
                           )
                           
                           
                           self.navigationController?.pushViewController(channelVC, animated: true)
                           self.navigationController?.viewControllers.remove(at: 1)
                           
                           
                           
                       } else {
                           
                           
                           //self.hideChannel2(channelUrl: channelUrl, user_id: uid)
                           
                           for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                                         
                               if item.userId != Auth.auth().currentUser?.uid {
                                   
                                   if item.state != .joined {
                                       
                                       self.acceptInviation(channelUrl: channelUrl, user_id: uid)
                                       
                                   }
                                   
                               }
                               
                           }
                           
                           let RequestChannelVC = RequestChannelVC(
                               channelUrl: channelUrl,
                               messageListParams: nil
                           )
                           
                           self.navigationController?.pushViewController(RequestChannelVC, animated: true)
                           self.navigationController?.viewControllers.remove(at: 1)
                           
                       
                       }
                       
                       
                       
                       
                   } else {
                       
                       //self.hideChannel2(channelUrl: channelUrl, user_id: uid)
                       
                       for item in ((channel.members!) as NSArray as! [SBDMember]) {
                                                     
                           if item.userId != Auth.auth().currentUser?.uid {
                               
                               if item.state != .joined {
                                   
                                   self.acceptInviation(channelUrl: channelUrl, user_id: uid)
                                   
                               }
                               
                           }
                           
                       }
                       
                       let RequestChannelVC = RequestChannelVC(
                           channelUrl: channelUrl,
                           messageListParams: nil
                       )
                       
                       self.navigationController?.pushViewController(RequestChannelVC, animated: true)
                       self.navigationController?.viewControllers.remove(at: 1)
                       
               
                   }
                                
                }
            }
            
            
            
            
        }
        
       
    }
    
    
    func acceptInviation(channelUrl: String, user_id: String) {
        
        // perform admin post
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_accept_invitation")
        
        AF.request(urlss!, method: .post, parameters: [
            
            "channel_url": channelUrl,
            "user_id": user_id
            
        
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON {  responseJSON in
                
                switch responseJSON.result {
                    
                case .success(_):
                    
                   print("")
                    
                case .failure(_):
                    
                    
                    print("")
                    
                }
                
            }
            
        
        
    }
    
    /*
    func hideChannel2(channelUrl: String, user_id: String) {
        
        // perform admin post
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_channel_hide2")
        
        AF.request(urlss!, method: .post, parameters: [
            
            "channel_url": channelUrl,
            "user_id": user_id
            
        
            ])
            
            .validate(statusCode: 200..<500)
            .responseJSON {  responseJSON in
                
                switch responseJSON.result {
                    
                case .success(_):
                    
                   print("")
                    
                case .failure(_):
                    
                    
                    print("")
                    
                }
                
            }
            
        
    
    }
  */
    
    func sendAdminMessage(channelUrl: String, message: String) {
        
        // perform admin post
        let urls = MainAPIClient.shared.baseURLString
        let urlss = URL(string: urls!)?.appendingPathComponent("sendbird_admin_post2")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            

            
            AF.request(urlss!, method: .post, parameters: [
                
                "channel_url": channelUrl,
                "message": message
            
                ])
                
                .validate(statusCode: 200..<500)
                .responseJSON {  responseJSON in
                    
                    switch responseJSON.result {
                        
                    case .success(_):
                        
                       print("")
                        
                    case .failure(_):
                        
                        
                        print("")
                        
                    }
                    
                }
                
            
        }
        
        
    }
    
    func shouldShowLoadingIndicator(){
        SBULoading.start()
        
    }
    
    func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }

}

