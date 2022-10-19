//
//  HideChannelListVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/21/21.
//

import UIKit
import Firebase
import SendBirdUIKit
import SendBirdSDK
import SendBirdCalls


class HideChannelListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, GroupChannelsUpdateListDelegate, UINavigationBarDelegate {
    
    
    @IBOutlet weak var groupChannelsTableView: UITableView!
    @IBOutlet weak var loadingIndicatorView: CustomActivityIndicatorView!
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    var limit: UInt = 20
    var refreshControl: UIRefreshControl?
   
    
    var channelListQuery: SBDGroupChannelListQuery?
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
       
        
        navigationItem.titleView = UIView()
        
        //
        
        let createButton: UIButton = UIButton(type: .custom)
        let image = UIImage(named: "iconBack")?.resize(targetSize: CGSize(width: 25, height: 25))
        createButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        createButton.tintColor = UIColor(named: "color_bar_item")
        createButton.addTarget(self, action: #selector(dismissVC(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        
        
        navigationItem.leftBarButtonItems = [createBarButton, self.createLeftTitleItem(text: "Request")]
  
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
   
        // Do any additional setup after loading the view.
      
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        self.groupChannelsTableView.delegate = self
        self.groupChannelsTableView.dataSource = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageVC.longPressChannel(_:)))
        longPressGesture.minimumPressDuration = 1.0
        self.groupChannelsTableView.addGestureRecognizer(longPressGesture)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MessageVC.refreshChannelList), for: .valueChanged)
        
        self.groupChannelsTableView.refreshControl = self.refreshControl
        
        
        
        self.loadChannelListNextPage(true)
        
        self.view.backgroundColor = UIColor(red: 2, green: 11, blue: 16)
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "HideChannelListVCDelegate")
        SBDMain.add(self as SBDConnectionDelegate, identifier: "HideChannelListVCConnectionDelegate")
        NotificationCenter.default.addObserver(self, selector: #selector(HideChannelListVC.removeHideChannel), name: (NSNotification.Name(rawValue: "removeHideChannel")), object: nil)
    }
    
    
    @objc func dismissVC(_ sender: AnyObject) {
        //CreateChannelVC
        
        
        SBDMain.removeChannelDelegate(forIdentifier: "HideChannelListVCDelegate")
        SBDMain.removeConnectionDelegate(forIdentifier: "HideChannelListVCConnectionDelegate")
        self.navigationController?.popViewController(animated: true)
        
       
    }
    
    @objc func removeHideChannel() {
        
        if hideChannelToadd != nil {
            
            DispatchQueue.main.async {
                if let index = self.channels.firstIndex(of: hideChannelToadd! as SBDGroupChannel) {
                    self.channels.remove(at: index)
                    self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
            
            
        }
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont(name:"Roboto-Bold",size: 18)!
        titleLabel.textColor = SBUTheme.componentTheme.titleColor
        
        
        
        return UIBarButtonItem.init(customView: titleLabel)
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func showToast(message: String, completion: (() -> Void)?) {
        self.toastCompleted = false
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.toastView.alpha = 0
        }) { (finished) in
            self.toastView.isHidden = true
            self.toastCompleted = true
            
            completion?()
        }
    }

    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.groupChannelsTableView)
        guard let indexPath = self.groupChannelsTableView.indexPathForRow(at: point) else { return }
        if recognizer.state == .began {
            let channel = self.channels[indexPath.row]
            let alert = UIAlertController(title: Utils.createGroupChannelName(channel: channel), message: nil, preferredStyle: .actionSheet)
            
            let actionLeave = UIAlertAction(title: "Leave message", style: .destructive) { (action) in
                channel.leave(completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.deleteChannels(channelUrls: [self.channels[indexPath.row].channelUrl], needReload: true)
                    }
                    
                })
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.modalPresentationStyle = .popover
            alert.addAction(actionLeave)
            alert.addAction(actionCancel)
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
  
  
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelTableViewCell
        let channel = self.channels[indexPath.row]
        
    
        let lastMessageDateFormatter = DateFormatter()
        var lastUpdatedAt: Date?
        
        /// Marking Date on the Group Channel List
        if channel.lastMessage != nil {
            lastUpdatedAt = Date(timeIntervalSince1970: Double((channel.lastMessage?.createdAt)! / 1000))
        } else {
            lastUpdatedAt = Date(timeIntervalSince1970: Double(channel.createdAt))
        }
        
        let currDate = Date()
        
        let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastUpdatedAt!)
        let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
        
        if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
            lastMessageDateFormatter.dateStyle = .short
            lastMessageDateFormatter.timeStyle = .none
            cell.lastUpdatedDateLabel.text = timeForChat(lastUpdatedAt!, numericDates: true)
        
        }
        else {
            lastMessageDateFormatter.dateStyle = .none
            lastMessageDateFormatter.timeStyle = .short
            cell.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastUpdatedAt!)
        }
        
        
        
        cell.lastMessageLabel.isHidden = false
        cell.typingIndicatorContainerView.isHidden = true
        
        cell.lastMessageLabel.isHidden = false
        cell.typingIndicatorContainerView.isHidden = true
        cell.notiOffIconImageView.isHidden = true
        
        if channel.lastMessage != nil {
            if channel.lastMessage is SBDUserMessage {
                let lastMessage = channel.lastMessage as! SBDUserMessage
                
                if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                    
                    cell.lastMessageLabel.text = "You: \(lastMessage.message)"
                    
                } else {
                    
                    if let nickname = channel.lastMessage?.sender?.nickname {
                        
                        cell.lastMessageLabel.text = "\(nickname): \(lastMessage.message)"
                        
                    }
                    
                    
                    
                }
                
                
            }
            else if channel.lastMessage is SBDFileMessage {
                let lastMessage = channel.lastMessage as! SBDFileMessage
                if lastMessage.type.hasPrefix("image") {
                    
                    if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                        
                        cell.lastMessageLabel.text = "You just sent an image"
                        
                    } else {
                        
                        if let nickname = channel.lastMessage?.sender?.nickname {
                            
                            if channel.memberCount == 2 {
                                
                                cell.lastMessageLabel.text = "just sent an image"
                                
                            } else if channel.memberCount > 2 {
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an image"
                                
                                
                            } else {
                                
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an image"
                                
                            }
                            
                            
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                   
                }
                else if lastMessage.type.hasPrefix("video") {
                    
                    if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                        
                        cell.lastMessageLabel.text = "You just sent a video"
                        
                    } else {
                        
                        if let nickname = channel.lastMessage?.sender?.nickname {
                            
                            
                            if channel.memberCount == 2 {
                                
                                cell.lastMessageLabel.text = "just sent a video"
                                
                            } else if channel.memberCount > 2 {
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent a video"
                                
                                
                            } else {
                                
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent a video"
                                
                            }
                           
                            
                        }
                        
                        
                        
                    }
                    
                }
                else if lastMessage.type.hasPrefix("audio") {
                    
                    if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                        

                        cell.lastMessageLabel.text = "You just sent an audio"
                        
                    } else {
                        
                        if let nickname = channel.lastMessage?.sender?.nickname {
                            
                            
                            if channel.memberCount == 2 {
                                
                                cell.lastMessageLabel.text = "just sent an audio"
                                
                            } else if channel.memberCount > 2 {
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an audio"
                                
                                
                            } else {
                                
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an audio"
                                
                            }
                           
                            
                        }
                        
                        
                        
                    }
                    
                }
               
            }
            else if  channel.lastMessage is SBDAdminMessage{
                let lastMessage = channel.lastMessage as! SBDAdminMessage
                cell.lastMessageLabel.text = lastMessage.message
            } else {
                cell.lastMessageLabel.text = "Message is hidden in request box"
            }
        }
        else {
            cell.lastMessageLabel.text = ""
        }
        
        cell.unreadMessageCountContainerView.isHidden = false
        if channel.unreadMessageCount > 99 {
            cell.unreadMessageCountLabel.text = "+99"
        }
        else if channel.unreadMessageCount > 0 {
            cell.unreadMessageCountLabel.text = String(channel.unreadMessageCount)
        }
        else {
            cell.unreadMessageCountContainerView.isHidden = true
        }
        
        if channel.memberCount <= 2 {
            cell.memberCountContainerView.isHidden = true
            cell.memberCountWidth.constant = 0.0
        }
        else {
            cell.memberCountContainerView.isHidden = false
            cell.memberCountWidth.constant = 18.0
            cell.memberCountLabel.text = String(channel.memberCount)
        }
        
        DispatchQueue.main.async {
            var members: [SBDUser] = []
            var count = 0
            if let channelMembers = channel.members as? [SBDMember], let currentUser = SBDMain.getCurrentUser() {
                for member in channelMembers {
                    if member.userId == currentUser.userId {
                        continue
                    }
                    members.append(member)
                    count += 1
                   
                }
            }
            
            if let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelTableViewCell {
                
                
                if channel.channelUrl.contains("challenge") {
                    
                    if let coverUrl = channel.coverUrl, coverUrl != "" {
                     
                        updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: true)
                       
                    }
                    
                    
                } else {
                    
                    if members.count == 0 {
                        
                        if let coverUrl = channel.coverUrl, coverUrl != "" {
                            
                            updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: false)
                            
                        }
                        
                    } else if members.count == 1 {
                        
                        updateCell.profileImagView.setImage(withCoverUrl: members[0].profileUrl!, shouldGetGame: false)
                        
                    } else if members.count > 1 && members.count < 5{
                        
                        updateCell.profileImagView.users = members
                        updateCell.profileImagView.makeCircularWithSpacing(spacing: 1)
                        
                    } else {
                        
                        if let coverUrl = channel.coverUrl, coverUrl != "" {
                            
                            updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: false)
                            
                        }
                        
                    }
                    
                }
                
                
                
                //
                
                // groupname
                
                if channel.name != "" && channel.name != "Group Channel" {
                    
                    updateCell.channelNameLabel.text = channel.name
                    
                } else {
                    
                    if members.count == 0 {
                        
                        updateCell.channelNameLabel.text = "No members"
                        
                    } else if members.count == 1 {
                        
                        updateCell.channelNameLabel.text = members[0].nickname
                        
                        
                    } else if members.count > 1 {
                        
                        var count = 0
                        var name = [String]()
                        for user in members {
                            name.append(user.nickname!)
                            count += 1
                            if count == 3 {
                                break
                            }
                        }
                        
                        
                        if members.count - name.count > 0 {
                            
                            let text = name.joined(separator: ",")
                            updateCell.channelNameLabel.text = "\(text) and \(members.count - name.count) users"
                            
                        } else {
                            
                            
                            let text = name.joined(separator: ",")
                            updateCell.channelNameLabel.text = text
                            
                        }
            
                    }
                    
                }
                
                    
            }
            
            
        }
        
        if self.channels.count > 0 && indexPath.row == self.channels.count - 1 {
            self.loadChannelListNextPage(false)
        }
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channels.count == 0 && self.toastCompleted {
            self.emptyLabel.isHidden = false
        }
        else {
            self.emptyLabel.isHidden = true
        }
        
        return self.channels.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "ShowGroupChat", sender: indexPath.row)
        
        let channel = self.channels[indexPath.row]
        let channelUrl = channel.channelUrl
        
        let channelVC = RequestChannelVC(
            channelUrl: channelUrl,
            messageListParams: nil
        
        )
        
        self.navigationController?.pushViewController(channelVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                
                //let index = indexPath.row
                let size = tableView.visibleCells[0].frame.height
                let iconSize: CGFloat = 40.0
                
                let leaveAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.channels[indexPath.row].leave(completionHandler: { (error) in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            return
                        }
                        
                        
                    })
                    
                    actionHandler(true)
                }
                
                let leaveTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                leaveTypeView.layer.cornerRadius = iconSize/2
                leaveTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOffBackgroundColor
                leaveTypeView.image = UIImage(named: "leave3x")
                leaveTypeView.contentMode = .center
                
                leaveAction.image = leaveTypeView.asImage()
                leaveAction.backgroundColor = self.view.backgroundColor
                
                
                
                
                
                return UISwipeActionsConfiguration(actions: [leaveAction])
                
                
                
                
                
        }
    
    func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        if self.channels.count > 0,
            self.channelListQuery?.hasNext == true,
            indexPath.row == (self.channels.count - Int(self.limit)/2),
            self.channelListQuery != nil {
            
            self.loadChannelListNextPage(false)
        }
    }
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.loadChannelListNextPage(true)
    }
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            self.channelListQuery = nil
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.channelHiddenStateFilter = .hiddenOnly
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.includeFrozenChannel = true
            self.channelListQuery?.includeEmptyChannel = true
           
           
            
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.channels.removeAll()
                }
                
                self.channels += channels!
                self.sortChannelList(needReload: true)
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    /// This function sorts the channel lists.
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func sortChannelList(needReload: Bool) {
        let sortedChannelList = self.channels
            .sorted(by: { (lhs: SBDGroupChannel, rhs: SBDGroupChannel) -> Bool in
                let createdAt1: Int64 = lhs.lastMessage?.createdAt ?? -1
                let createdAt2: Int64 = rhs.lastMessage?.createdAt ?? -1
                if (createdAt1 == -1 && createdAt2 == -1) {
                    return Int64(lhs.createdAt * 1000) > Int64(rhs.createdAt * 1000)
                } else {
                    return createdAt1 > createdAt2
                }
            })
        
        self.channels = sortedChannelList.sbu_unique()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard needReload else { return }
            
            self.groupChannelsTableView.reloadData()
        }
    }
    
    func updateChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard self.channelListQuery?.belongs(to: channel) == true else { continue }
            guard let index = self.channels.firstIndex(of: channel) else { continue }
            self.channels.append(self.channels.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
        
    }
    
    /// This function upserts the channels.
    ///
    /// If the channels are already in the list, it is updated, otherwise it is inserted.
    /// And, after upserting the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to upsert
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    func upsertChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard self.channelListQuery?.belongs(to: channel) == true else { continue }
            let includeEmptyChannel = self.channelListQuery?.includeEmptyChannel ?? false
            guard (channel.lastMessage != nil || includeEmptyChannel) else { continue }
            guard let index = self.channels.firstIndex(of: channel) else {
                self.channels.append(channel)
                
                continue
            }
            
            self.channels.append(self.channels.remove(at: index))
                 
        }
        self.sortChannelList(needReload: needReload)
    }
    
    
    func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        guard let channelUrls = channelUrls else { return }
        
        var toBeDeleteIndexes: [Int] = []
        
        for channelUrl in channelUrls {
            if let index = self.channels.firstIndex(where: { $0.channelUrl == channelUrl }) {
                toBeDeleteIndexes.append(index)
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for toBeDeleteIdx in sortedIndexes {
            self.channels.remove(at: toBeDeleteIdx)
        }
        
        self.sortChannelList(needReload: needReload)
    }
   
    
    // MARK: - GroupChannelsUpdateListDelegate
    func updateGroupChannelList() {
        DispatchQueue.main.async {
            self.groupChannelsTableView.reloadData()
        }
        
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return SBUChannelTheme.dark.statusBarStyle
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
        if user.userId == Auth.auth().currentUser?.uid {
            
            self.deleteChannel(channel: sender)
            
        }
        
        
    }
    
    func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser, inviter: SBDUser?) {
        
        if invitee.userId == Auth.auth().currentUser?.uid {
            
            self.deleteChannel(channel: sender)
            
        }
       
    }
    
    
    func deleteChannel(channel: SBDGroupChannel) {
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.channels.remove(at: index)
                self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    

}
