//
//  MessageVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 2/4/21.
//

import UIKit
import Firebase
import SendBirdUIKit
import SendBirdSDK
import SendBirdCalls
import SwiftEntryKit

var oldTabbarFr: CGRect = .zero

class MessageVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, GroupChannelsUpdateListDelegate, UINavigationBarDelegate, SBDUserEventDelegate, UINavigationControllerDelegate  {
    
    
    
    @IBOutlet weak var groupChannelsTableView: UITableView!

    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    var lastUpdatedToken: String? = nil
    var limit: UInt = 20
    var refreshControl: UIRefreshControl?
    var trypingIndicatorTimer: [String : Timer] = [:]
    
    var channelListQuery: SBDGroupChannelListQuery?
    var Hide_channelListQuery: SBDGroupChannelListQuery?
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true
    var lastUpdatedTimestamp: Int64 = 0
    
    var deletedChannel: SBDGroupChannel!
    //
    let createButton: UIButton = UIButton(type: .custom)
    let requestBtn: SSBadgeButton = SSBadgeButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if Auth.auth().currentUser?.isAnonymous == true || Auth.auth().currentUser?.uid == nil {
            
            return
             
        }
        
    
 
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        self.groupChannelsTableView.delegate = self
        self.groupChannelsTableView.dataSource = self
     
        

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MessageVC.longPressChannel(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.groupChannelsTableView.addGestureRecognizer(longPressGesture)
        
     
        
        self.updateTotalUnreadMessageCountBadge()
        
        
        delay(2) {
            self.loadChannelListNextPage(true)
        }
        
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Messages")
  
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        //reauthenticate()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessageVC.checkCallForLayout), name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessageVC.addHideChannel), name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
             
        
        self.navigationController?.navigationBar.delegate = self
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MessageVC.refreshChannelList), for: .valueChanged)
      
   
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
        
    }
    
    
    deinit {
        
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.groupChannelsTableView.layoutIfNeeded()
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
        
        
        loadHideChannelList()
        checkCallForLayout()
        autoRemoveExpireChallengeChat()
        
    }
    
    func autoRemoveExpireChallengeChat() {
        
        if channels.isEmpty != true {
            
            var remove_list = [Int]()
            var count = 0
            
            for channel in channels {
                
                if channel.channelUrl.contains("challenge") {
                    
                    let timeNow = UInt.init(Date().timeIntervalSince1970)
                    
                    if timeNow - (channel.createdAt) > 5 * 60 * 60 {
                        
                        remove_list.append(count)
                        
                    }
                    
                    
                }
                
                count += 1
                
            }
            
            if remove_list.isEmpty != true {
                
                remove_list.reverse()
                
                for index in remove_list {
                    
                    self.channels.remove(at: index)
                    groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    
                    
                }
                
            }
            
            
            
        }
        
        
    }

    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.groupChannelsTableView)
        guard let indexPath = self.groupChannelsTableView.indexPathForRow(at: point) else { return }
        if recognizer.state == .began {
            let channel = self.channels[indexPath.row]
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionLeave = UIAlertAction(title: "Leave message", style: .destructive) { (action) in
                channel.leave(completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                })
            }
            
            let actionHide = UIAlertAction(title: "Hide message", style: .default) { (action) in
                if channel.hiddenState == .unhidden {
                    
                    channel.hide(withHidePreviousMessages: false, allowAutoUnhide: false) { error in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            return
                        }
                    }
                    
                    
                                      
                }
            }
            
            
            
            let actionNotificationOn = UIAlertAction(title: "Turn notification on", style: .default) { (action) in
               channel.setMyPushTriggerOption(.all) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                }
            }
            
            let actionNotificationOff = UIAlertAction(title: "Turn notification off", style: .default) { (action) in
                channel.setMyPushTriggerOption(.off) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.modalPresentationStyle = .popover
            
            
            if channel.myPushTriggerOption == .off {
                
                
                alert.addAction(actionNotificationOn)
                alert.addAction(actionHide)
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
            } else if channel.myPushTriggerOption == .all {
                
                
                alert.addAction(actionNotificationOff)
                alert.addAction(actionHide)
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
            } else {
                
                alert.addAction(actionHide)
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
                
            }
        
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func updateTotalUnreadMessageCountBadge() {
        SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
            guard let navigationController = self.navigationController else { return }
            if error != nil {
                navigationController.tabBarItem.badgeValue = nil
                
                return
            }
            
            if unreadCount > 0 {
                navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
            }
            else {
                navigationController.tabBarItem.badgeValue = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
                guard let navigationController = self.navigationController else { return }
                if error != nil {
                    navigationController.tabBarItem.badgeValue = nil
                    return
                }
                
                if unreadCount > 0 {
                    navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
                }
                else {
                    navigationController.tabBarItem.badgeValue = nil
                }
            }
        }
    }
    
    func buildTypingIndicatorLabel(channel: SBDGroupChannel) -> String {
        let typingMembers = channel.getTypingUsers()
        if typingMembers == nil || typingMembers?.count == 0 {
            return ""
        }
        else {
            return "Typing"
        }
    }
    
    @objc func typingIndicatorTimeout(_ timer: Timer) {
        if let channelUrl = timer.userInfo as? [Any] {
            self.trypingIndicatorTimer[channelUrl[0] as! String]?.invalidate()
            self.trypingIndicatorTimer.removeValue(forKey: channelUrl[0] as! String)
            DispatchQueue.main.async {
                
                if let index = self.channels.firstIndex(of: channelUrl[1] as! SBDGroupChannel) {
                    self.groupChannelsTableView.reloadRows(at:  [IndexPath(row: index, section: 0)], with: .automatic)
                }
                
                
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelTableViewCell
        let channel = self.channels[indexPath.row]
        
        cell.setTimeStamp(channel: channel)
        
        
        let typingIndicatorText = self.buildTypingIndicatorLabel(channel: channel)
        let timer = self.trypingIndicatorTimer[channel.channelUrl]
        var showTypingIndicator = false
        if timer != nil && typingIndicatorText.count > 0 {
            showTypingIndicator = true
        }
        
        if showTypingIndicator {
            cell.lastMessageLabel.isHidden = true
            cell.typingIndicatorContainerView.isHidden = false
            cell.typingIndicatorLabel.text = typingIndicatorText
        }
        else {
            cell.lastMessageLabel.isHidden = false
            cell.typingIndicatorContainerView.isHidden = true
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
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an image"
                            }
                            
                            
                            
                        }
                        
                       
                    }
                    else if lastMessage.type.hasPrefix("video") {
                        
                        if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                            
                            cell.lastMessageLabel.text = "You just sent a video"
                            
                        } else {
                            
                            if let nickname = channel.lastMessage?.sender?.nickname {
                                
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent a video"
                               
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    else if lastMessage.type.hasPrefix("audio") {
                        
                        if channel.lastMessage?.sender?.userId == Auth.auth().currentUser?.uid {
                            

                            cell.lastMessageLabel.text = "You just sent an audio"
                            
                        } else {
                            
                            if let nickname = channel.lastMessage?.sender?.nickname {
                                
                                
                                cell.lastMessageLabel.text = "\(nickname): just sent an audio"
                               
                                
                            }
                            
                            
                            
                        }
                        
                    }
                   
                }
                else if  channel.lastMessage is SBDAdminMessage{
                    let lastMessage = channel.lastMessage as! SBDAdminMessage
                    cell.lastMessageLabel.text = lastMessage.message
                }
            }
            else {
                cell.lastMessageLabel.text = "System: message is created"
            }
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
        
        let pushOption = channel.myPushTriggerOption
        
        switch pushOption {
        case .all, .default, .mentionOnly:
            cell.notiOffIconImageView.isHidden = true
            break
        case .off:
            cell.notiOffIconImageView.isHidden = false
            break
        @unknown default:
            cell.notiOffIconImageView.isHidden = true
            break
        }

        
        if channel.isFrozen == true {
            
            cell.frozenImageView.isHidden = false
            
        } else {
            
            cell.frozenImageView.isHidden = true
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
        
        let channelVC = ChannelViewController(
            channelUrl: channelUrl,
            messageListParams: nil
        
        )
        
        
        self.navigationController?.pushViewController(channelVC, animated: true)
        
        
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
    
    
    func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                
                let index = indexPath.row
                let channel = self.channels[index]
                let size = tableView.visibleCells[0].frame.height
                let iconSize: CGFloat = 40.0
                
                let leaveAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.channels[indexPath.row].leave(completionHandler: { (error) in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            print(error.localizedDescription, error.code)
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
                
                
                
                let pushOption = channel.myPushTriggerOption
                let alarmAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    if self.channels[indexPath.row].myPushTriggerOption == .off {
                        
                        self.channels[indexPath.row].setMyPushTriggerOption(.all) { error in
                            if let error = error {
                                Utils.showAlertController(error: error, viewController: self)
                                return
                            }
                        }
                        
                    } else {
                        
                        
                        self.channels[indexPath.row].setMyPushTriggerOption(.off) { error in
                            if let error = error {
                                Utils.showAlertController(error: error, viewController: self)
                                return
                            }
                        }
                        
                        
                    }
                            
                    actionHandler(true)
                }
                
                let alarmTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                let alarmIcon: UIImage
                
                if pushOption == .off {
                    alarmTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOnBackgroundColor
                    alarmIcon = UIImage(named: "Noti3x")!
                } else {
                    alarmTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOffBackgroundColor
                    alarmIcon  = UIImage(named: "muted")!
                }
                alarmTypeView.image = alarmIcon
                alarmTypeView.contentMode = .center
                alarmTypeView.layer.cornerRadius = iconSize/2
                
                alarmAction.image = alarmTypeView.asImage()
                alarmAction.backgroundColor = self.view.backgroundColor
                
                
                let hideAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    if self.channels[indexPath.row].hiddenState == .unhidden {
                        
                        self.channels[indexPath.row].hide(withHidePreviousMessages: false, allowAutoUnhide: false) { error in
                            if let error = error {
                                Utils.showAlertController(error: error, viewController: self)
                                return
                            }
                        }
                        
                        
                                          
                    }
                    
                    actionHandler(true)
                }
                
                let hideTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                hideTypeView.layer.cornerRadius = iconSize/2
                hideTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOffBackgroundColor
                hideTypeView.image = UIImage(named: "hide3x")
                hideTypeView.contentMode = .center
                
                hideAction.image = hideTypeView.asImage()
                hideAction.backgroundColor = self.view.backgroundColor
                
                return UISwipeActionsConfiguration(actions: [leaveAction, hideAction, alarmAction])
                
        }
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.loadChannelListNextPage(true)
    }
    
    
    func loadHideChannelList() {
        self.Hide_channelListQuery = nil
        self.Hide_channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.Hide_channelListQuery?.channelHiddenStateFilter = .hiddenOnly
        self.Hide_channelListQuery?.limit = 100
        self.Hide_channelListQuery?.includeFrozenChannel = true
        self.Hide_channelListQuery?.includeEmptyChannel = true
        
        self.Hide_channelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.requestBtn.badge = nil
                return
            }
            
            DispatchQueue.main.async {
                if channels?.isEmpty != true {
                    
                    if let cnt = channels?.count {
                        
                        
                        if cnt == 0 {
                            self.requestBtn.badge = nil
                            
                        } else {
                            
                                                 
                            if cnt >= 100 {
                                self.requestBtn.badge = "\(99)+"
                            } else {
                                self.requestBtn.badge = "\(cnt)"
                            }
                            
                        }
                      
                    }
                    
                } else {
                    
                    self.requestBtn.badge = nil
                    
                }
            }
        })
        
    }
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            self.channelListQuery = nil
            self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            self.channels = []
            self.lastUpdatedToken = nil
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.channelHiddenStateFilter = .unhiddenOnly
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.includeFrozenChannel = true
            self.channelListQuery?.includeEmptyChannel = true
            
           
            
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (newChannels, error) in
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
                           
                self.channels += newChannels!
                
                for channel in self.channels {
                    
                    if channel.channelUrl.contains("challenge") {
                        
                        let timeNow = UInt.init(Date().timeIntervalSince1970)
                        
                        if timeNow - (channel.createdAt) > 5 * 60 * 60 {
                        
                            self.channels.removeObject(channel)
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                self.sortChannelList(needReload: true)
                self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
                self.refreshControl?.endRefreshing()
            }
        })
    }
 
    
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

    
    func sortChannelList(needReload: Bool) {
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
            
           
            //self.groupChannelsTableView.reloadData()
            self.groupChannelsTableView.reloadSections([0], with: .automatic)
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
   
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return SBUChannelTheme.dark.statusBarStyle
    }
    
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        DispatchQueue.main.async {
            
            if sender is SBDGroupChannel {
                var hasChannelInList = false
                var index = 0
                
                for ch in self.channels {
                    
                    if ch.channelUrl == sender.channelUrl {
                        self.channels.removeObject(ch)
                        self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                       
                        self.channels.insert(sender as! SBDGroupChannel, at: 0)
                        self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        
                       
                        self.updateTotalUnreadMessageCountBadge()
                        
                        hasChannelInList = true
                        break
                    }
                    
                    index += 1
                }
                
                if hasChannelInList == false {
                    if self.shouldAddToList(channel: sender as! SBDGroupChannel) == true {
                        
                        self.channels.insert(sender as! SBDGroupChannel, at: 0)
                        self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        
                        self.updateTotalUnreadMessageCountBadge()
                        
                    }
                }
            }
            
        }
        
        
    }
    

    
    func shouldAddToList(channel: SBDGroupChannel) -> Bool {
        
        if channel.creator?.userId == Auth.auth().currentUser?.uid {
            
            return true
          
            
        } else {
            
            if global_availableChatList.contains(channel.creator!.userId) {
                
                return true
               
                
            } else {
                
                
                if let inviter = channel.getInviter() {
                    
                    if global_availableChatList.contains(inviter.userId) {
                        
                        return true
                        
                    } else {
                        
                        return false
                        
                        
                    }
                    
                    
                } else {
                    
                    return false
                    
                }
                
                
                
            }
            
            
        }
        
        
        
        
       
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        if sender.isTyping() == true {
            
            if sender.getTypingUsers()?.firstIndex(of: SBDMain.getCurrentUser()!) == nil {
                
                if let timer = self.trypingIndicatorTimer[sender.channelUrl] {
                    timer.invalidate()
                }
                
                let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(MessageVC.typingIndicatorTimeout(_ :)), userInfo: [sender.channelUrl, sender], repeats: false)
                self.trypingIndicatorTimer[sender.channelUrl] = timer
                
                DispatchQueue.main.async {
                    
                    if let index = self.channels.firstIndex(of: sender as SBDGroupChannel) {
                        self.groupChannelsTableView.reloadRows(at:  [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    
                }
                
            }
 
        
        }
        
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
    
    func loadChannelChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore else {
            self.sortChannelList(needReload: true)
            return
        }
        
        var channelLogsParams = SBDGroupChannelChangeLogsParams()
        if let channelListQuery = self.channelListQuery {
            channelLogsParams = SBDGroupChannelChangeLogsParams.create(with: channelListQuery)
        }
        
        
        if let token = token {
            
            SBDMain.getMyGroupChannelChangeLogs(
                byToken: token,
                params: channelLogsParams
            ){ [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                guard let self = self else { return }
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.lastUpdatedToken = token
                
                self.upsertChannels(updatedChannels, needReload: false)
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
        else {

            SBDMain.getMyGroupChannelChangeLogs(
                byTimestamp: self.lastUpdatedTimestamp,
                params: channelLogsParams
            ) { [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                guard let self = self else { return }
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.lastUpdatedToken = token
                
                
                
                self.upsertChannels(updatedChannels, needReload: false)
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
    }
    
    
    func didSucceedReconnection() {
        self.loadChannelChangeLogs(hasMore: true, token: self.lastUpdatedToken)
    }
    
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
        if findDeletedChannel(channelUrl: channelUrl) == true, deletedChannel != nil {
            if self.channels.contains(deletedChannel) {
                self.deleteChannel(channel: deletedChannel)
            }
        }
        
    }
    
    func findDeletedChannel(channelUrl: String) -> Bool {
        
        if self.channels.isEmpty != true {
            
            for subChannel in self.channels {
                if subChannel.channelUrl == channelUrl {
                    deletedChannel = subChannel
                    return true
                }
            }
            
            return false
            
        } else {
            return false
        }
        
     
        
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            if self.channels.firstIndex(of: sender) == nil {
                
                if self.shouldAddToList(channel: sender) == true {
                    
                    if self.channels.firstIndex(of: sender) == nil {
                        
                        self.channels.insert(sender, at: 0)
                        self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            
                    }
                    
                }
                
                
            } else {
                
                
                if let index = self.channels.firstIndex(of: sender as SBDGroupChannel) {
                    self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                
            }
            
        }
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
        if user.userId == Auth.auth().currentUser?.uid {
            
            self.deleteChannel(channel: sender)
            
        } else {
            
            if let index = self.channels.firstIndex(of: sender as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            
            
        }
        
        
        
    }
    
    func channelWasHidden(_ sender: SBDGroupChannel) {
        
        self.deleteChannel(channel: sender)
        sender.setMyPushTriggerOption(.off) { error in
            if let error = error {
                Utils.showAlertController(error: error, viewController: self)
                return
            }
        }
        
        self.loadHideChannelList()
        
    }
   
    func channelWasChanged(_ sender: SBDBaseChannel) {
       
        //guard let channel = sender as? SBDGroupChannel else { return }
        self.sortChannelList(needReload: true)
       
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if user.userId == SBUGlobals.CurrentUser?.userId {
            guard let channel = sender as? SBDGroupChannel else { return }
            self.deleteChannel(channel: channel)
        }
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
    
    func reauthenticate() {
    
        SBUMain.connect { user, error in
            if error != nil {
                print(error!.localizedDescription)
                self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                return
            }
            
            if let user = user {
            
                print("SBUMain.connect: \(user)")
      
                let params = AuthenticateParams(userId: Auth.auth().currentUser!.uid)
                
                SendBirdCall.authenticate(with: params) { (cuser, err) in
                    
                    guard cuser != nil else {
                        // Failed
                        showNote(text: err!.localizedDescription)
                        return
                    }
                                                      
                }
                
            }
            
        
        }
    }
    
    
    
    func setupWithCall(isGroup: Bool) {
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "img_icon_add_operator"), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        //request
    
        
        
        requestBtn.setImage(UIImage(named: "request"), for: [])
        requestBtn.addTarget(self, action: #selector(showHideChannelListVC(_:)), for: .touchUpInside)
        requestBtn.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let requestBtnButton = UIBarButtonItem(customView: requestBtn)

        
        let voiceCallButton: UIButton = UIButton(type: .custom)
        voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
        
        if isGroup == true {
            
            voiceCallButton.setTitle("+", for: .normal)
            voiceCallButton.sizeToFit()
            
        } else {
            
            voiceCallButton.setTitle("", for: .normal)
            voiceCallButton.sizeToFit()
            
        }
        
        
      
        self.navigationItem.rightBarButtonItems = [createBarButton, requestBtnButton, voiceCallBarButton]
        
        voiceCallButton.shake()
    
        
    }
    
    func setupWithoutCall() {
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "img_icon_add_operator"), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        
        requestBtn.setImage(UIImage(named: "request"), for: [])
        requestBtn.addTarget(self, action: #selector(showHideChannelListVC(_:)), for: .touchUpInside)
        requestBtn.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let requestBtnButton = UIBarButtonItem(customView: requestBtn)
    
        
        self.navigationItem.rightBarButtonItems = [createBarButton, requestBtnButton]
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.tabBarController?.tabBar.isHidden = true
        
      
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }


    @objc func checkCallForLayout() {
        
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                return
                
            }
            
            if call.isEnded == true {
                
                general_call = nil
                call.end()
                CXCallManager.shared.endCXCall(call)
                setupWithoutCall()
                
            } else {
                
                
                setupWithCall(isGroup: false)
                
            }
            
        } else {
             
            if general_room != nil {
                
                
                setupWithCall(isGroup: true)
                
                
            } else {
                
                setupWithoutCall()
                
            }
            
            
            
            
        }
        
    }
    
    @objc func showCreateChannel(_ sender: AnyObject) {
        //CreateChannelVC
        
        if let CCV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateChannelVC") as? CreateChannelVC {
             
            self.navigationController?.pushViewController(CCV, animated: true)
            
        }
        
       
    }
    
    
    @objc func showHideChannelListVC(_ sender: AnyObject) {
        
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HideChannelListVC") as? HideChannelListVC {
            
            //viewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
        
    }
    
    
    @objc func clickVoiceCallBarButton(_ sender: AnyObject) {
        
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                return
                
            }
            
            if call.isEnded == true {
                
                general_call = nil
                call.end()
                CXCallManager.shared.endCXCall(call)
                setupWithoutCall()
                
            } else {
                
                
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoiceCallViewController") as? VoiceCallViewController {

                    controller.call = general_call
                    controller.isDialing = true
                    controller.newcall = false
                
                    self.present(controller, animated: true, completion: nil)
                    
                }
                
            }
            
            
        } else {
            
            if general_room != nil {
                
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
    
                    controller.currentRoom = general_room
                    controller.newroom = false
                    controller.currentChanelUrl = gereral_group_chanel_url
                    
                    self.present(controller, animated: true, completion: nil)
                    
                }
                
                
                
            } else {
                
                setupWithoutCall()
                
                
            }
            
            
        }
        
          
        
    }
    
    @objc func addHideChannel() {
        
        if hideChannelToadd != nil {
            
            DispatchQueue.main.async {
                if self.channels.firstIndex(of: hideChannelToadd!) == nil {
                    
                    self.channels.insert(hideChannelToadd!, at: 0)
                    self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                   
                    
                    
                    
                }
                
            }
            
            
        }
        

        
    }
    

}


