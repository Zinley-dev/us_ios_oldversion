//
//  RequestChannelVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/22/21.
//

import UIKit
import Firebase
import SendBirdUIKit
import SendBirdCalls

class RequestChannelVC: SBUChannelViewController {
    
    var isUnHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nil
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = .zero
    }
   
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        
        if (parent != nil) {
            self.tabBarController?.tabBar.frame = .zero
            self.tabBarController?.tabBar.isHidden = true
        }
            
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                 
        
        let button = UIButton()
        button.frame = CGRect(x: 50, y: 6, width: 170, height: 40)
        button.setTitle("", for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(ChannelViewController.profileBtnPressed), for: .touchUpInside)
        self.navigationController?.navigationBar.addSubview(button)
        
        if (channel?.members!.count) == 2 {
            
            
            if let selected_channel = channel {
                
                if selected_channel.joinedMemberCount == 2 {
                    
                    
                    for user in ((selected_channel.members)! as NSArray as! [SBDMember]) {
                        
                        if user.userId != Auth.auth().currentUser!.uid {
                            if global_block_list.contains(user.userId) {
                                
                                self.navigationItem.rightBarButtonItems = nil
                                self.messageInputView.isHidden = true
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                }
            
                
            }
            
            
            
            
        }
        
    }
    
    func checkIFUnhidden() {
    
        var uid_list = [String]()
        for user in ((channel?.members)! as NSArray as! [SBDMember]) {
            
            if user.userId != Auth.auth().currentUser!.uid {
                
                if !global_availableChatList.contains(user.userId) {
                    
                    uid_list.append(user.userId)
                    global_availableChatList.append(user.userId)
                    
                }
                           
            }
            
        }
             
        if !uid_list.isEmpty {
            addToAvailableChatList(uid: uid_list)
        }
        
        
        
    }
    
    func updateChannel() {
        
        if let channel = self.channel, self.channel?.creator?.userId != Auth.auth().currentUser?.uid {
            
            if isUnHidden == false {
                
                checkIFUnhidden()
                
                hideChannelToadd = channel
                
                
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeHideChannel")), object: nil)
                
                
                channel.setMyPushTriggerOption(.all) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                }
                
                isUnHidden = true
                
            }
            
            
            
            
            //
            
            
            
        } else if let channel = self.channel, self.channel?.joinedAt != nil {
            
            if isUnHidden == false {
                
                checkIFUnhidden()
                
                hideChannelToadd = channel
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeHideChannel")), object: nil)
                
                
                channel.setMyPushTriggerOption(.all) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                }
                
                isUnHidden = true
            
            }
            
            
        }
        
        
    }
    
    
    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        
        
        if let channel = self.channel, self.channel?.creator?.userId != Auth.auth().currentUser?.uid {
            
            if global_availableChatList.contains(self.channel!.creator!.userId) {
                
                sendText(messageParams: messageParams)
                
            } else {
                
                channel.acceptInvitation { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    
                    self.sendText(messageParams: messageParams)
                }
                
            }
            
            
            
            
        } else {
            
            sendText(messageParams: messageParams)
            
            
        }
        
    }

    
    func sendText(messageParams: SBDUserMessageParams) {
        
        var uid_list = [String]()
        for user in ((channel?.members)! as NSArray as! [SBDMember]) {
            
            if user.userId != Auth.auth().currentUser!.uid {
                
                if !global_availableChatList.contains(user.userId) {
                    
                    uid_list.append(user.userId)
                    global_availableChatList.append(user.userId)
                    
                   
                    
                }
                           
            }
            
        }
             
       
        if uid_list.count > 0 {
            
            addToAvailableChatList(uid: uid_list)
            
        }
        
        if self.channel?.isHidden == true {
            
            if self.channel?.creator?.userId == Auth.auth().currentUser?.uid {
                
                messageParams.pushNotificationDeliveryOption = .suppress
                
            }
            
        }
          
        
        let preSendMessage = self.channel?.sendUserMessage(with: messageParams)
        { [weak self] userMessage, error in
            if (error != nil) {
                
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: userMessage?.channelUrl,
                    message: userMessage
                )
                
             
            } else {
                
                SBUPendingMessageManager.shared.removePendingMessage(
                    channelUrl: userMessage?.channelUrl,
                    requestId: userMessage?.requestId
                )
                
            }
            
            guard let self = self else { return }
            
            if error != nil {
                self.sortAllMessageList(needReload: true)
                
                return
            }
            
            guard let message = userMessage else { return }
         
              
            self.upsertMessagesInList(messages: [message], needReload: true)
            if let channel = self.channel {
                channel.markAsRead { err in
                    if err != nil {
                        print(err!.localizedDescription)
                    }
                }
            }
        }
               
        if let preSendMessage = preSendMessage,
           self.messageListParams.belongs(to: preSendMessage)
        {
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: preSendMessage
            )
        }
        
        self.sortAllMessageList(needReload: true)
        self.messageInputView.endTypingMode()
        self.scrollToBottom(animated: false)
        if let channel = self.channel {
            channel.endTyping()
        }
        
        updateChannel()
        
    }
    
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        
        if let channel = self.channel, self.channel?.creator?.userId != Auth.auth().currentUser?.uid {
            
            
            if global_availableChatList.contains(self.channel!.creator!.userId) {
                
                channel.acceptInvitation { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    
                    self.sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
                }
                
                
            } else {
                
                self.sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
                
            }
            
            
            
            
            
        } else {
            
            sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
            
        }
        
        
        
        
        
    }
    
    func sendMedia(fileData: Data?, fileName: String, mimeType: String) {
        
        guard let fileData = fileData else { return }
        
        var uid_list = [String]()
        for user in ((channel?.members)! as NSArray as! [SBDMember]) {
            
            if user.userId != Auth.auth().currentUser!.uid {
                
                if !global_availableChatList.contains(user.userId) {
                    
                    uid_list.append(user.userId)
                    global_availableChatList.append(user.userId)
                    
                    
                    
                    
                }
                           
            }
            
        }
             
       
        if uid_list.count > 0 {
            
            addToAvailableChatList(uid: uid_list)
            
        }
        
        let messageParams = SBDFileMessageParams(file: fileData)!
        messageParams.fileName = fileName
        messageParams.mimeType = mimeType
        messageParams.fileSize = UInt(fileData.count)
        
        if let image = UIImage(data: fileData) {
            let thumbnailSize = SBDThumbnailSize.make(withMaxCGSize: image.size)
            messageParams.thumbnailSizes = [thumbnailSize]
        }
        
        SBUGlobalCustomParams.fileMessageParamsSendBuilder?(messageParams)
        
        guard let channel = self.channel else { return }
        
        
        var preSendMessage: SBDFileMessage?
        preSendMessage = channel.sendFileMessage(
            with: messageParams,
            progressHandler: { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                //// If need reload cell for progress, call reload action in here.
                guard (preSendMessage?.requestId) != nil else { return }
                _ = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
               
            },
            completionHandler: { [weak self] fileMessage, error in
                if (error != nil) {
                    if let fileMessage = fileMessage,
                       self?.messageListParams.belongs(to: fileMessage) == true
                    {
                        SBUPendingMessageManager.shared.upsertPendingMessage(
                            channelUrl: fileMessage.channelUrl,
                            message: fileMessage
                        )
                    }
                } else {
                    SBUPendingMessageManager.shared.removePendingMessage(
                        channelUrl: fileMessage?.channelUrl,
                        requestId: fileMessage?.requestId
                    )
                }
                
                guard let self = self else { return }
                if error != nil {
                    self.sortAllMessageList(needReload: true)
                    
                    return
                }
                
                guard let message = fileMessage else { return }
                
                
                
                self.upsertMessagesInList(messages: [message], needReload: true)
                
                if let channel = self.channel {
                    channel.markAsRead { err in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                    }
                }
            })
        
        if let preSendMessage = preSendMessage,
           self.messageListParams.belongs(to: preSendMessage)
        {
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: preSendMessage
            )
            
            SBUPendingMessageManager.shared.addFileInfo(
                requestId: preSendMessage.requestId,
                params: messageParams
            )
        } else {
           // SBULog.info("A filtered file message has been sent.")
        }
        
        self.sortAllMessageList(needReload: true)
       
        updateChannel()
        
    }
    
    
    

    
    @objc func profileBtnPressed() {
        
        if self.navigationController?.visibleViewController is ChannelViewController {
            
            if let selected_channel = channel {
                
                if let members = selected_channel.members {
                    
                    if members.count == 2 {
                        
                        for user in ((members) as NSArray as! [SBDMember]) {
                                                      
                            if user.userId != Auth.auth().currentUser?.uid {
                                
                                presentUsers(uid: user.userId)
                                return
                                
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
                      
        } else {
            
            print("Wrong")
            
        }
        
    }
    
    
    func presentUsers(uid: String) {
        
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            if let vc = UIViewController.currentViewController() {
                
                controller.uid = uid
                
                vc.present(controller, animated: true, completion: nil)
                 
            }
            
            
        }
        
    }
 


    

}






