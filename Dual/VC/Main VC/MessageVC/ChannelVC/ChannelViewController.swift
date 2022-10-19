//
//  ChannelViewController.swift
//  Dual
//
//  Created by Khoi Nguyen on 3/28/21.
//

import UIKit
import Firebase
import SendBirdUIKit
import SendBirdCalls

class ChannelViewController: SBUChannelViewController {
    
    var getRoom: Room!
    
    var settingButton: UIButton = UIButton(type: .custom)
    var voiceCallButton: UIButton = UIButton(type: .custom)

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
        
        if channel?.channelUrl.contains("challenge") == true {
            
            let timeNow = UInt.init(Date().timeIntervalSince1970)
            
            if timeNow - (channel?.createdAt)! > 5 * 60 * 60 {
                
                self.navigationItem.rightBarButtonItems = nil
                self.messageInputView.isHidden = true
                self.tableView.isUserInteractionEnabled = false
                
            } else {
                
                
                if let selected_channel = channel {
                    
                    if selected_channel.joinedMemberCount == 2 {
                        
                        for user in ((selected_channel.members)! as NSArray as! [SBDMember]) {
                            
                            if user.userId != Auth.auth().currentUser!.uid {
                                if !global_block_list.contains(user.userId) {
                                    
                                    setupWithCall()
                                    
                                } else {
                                    
                                    
                                    self.navigationItem.rightBarButtonItems = nil
                                    self.messageInputView.isHidden = true
                                 
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                        
            }
            
            
        } else {
            
            if channel?.isHidden == false {
                
                if (channel?.members!.count)! > 2 {
                    
                    setupWithCall()
                    
                } else {
                    
                    if (channel?.members!.count) == 2 {
                        
                        
                        if let selected_channel = channel {
                            
                            if selected_channel.joinedMemberCount == 2 {
                                
                                
                                for user in ((selected_channel.members)! as NSArray as! [SBDMember]) {
                                    
                                    if user.userId != Auth.auth().currentUser!.uid {
                                        if !global_block_list.contains(user.userId) {
                                            
                                            setupWithCall()
                                            
                                        } else {
                                            
                                            
                                            self.navigationItem.rightBarButtonItems = nil
                                            self.messageInputView.isHidden = true
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                                
                            }
                        
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
                
            }
            
            
        }
        
       
            
        
        let button = UIButton()
        button.frame = CGRect(x: 50, y: 6, width: 170, height: 40)
        button.setTitle("", for: .normal)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(ChannelViewController.profileBtnPressed), for: .touchUpInside)
        self.navigationController?.navigationBar.addSubview(button)
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        
        if channel?.channelUrl.contains("challenge") == true {
            
            let timeNow = UInt.init(Date().timeIntervalSince1970)
            
            //UInt.init(Date().timeIntervalSince1970)
            
            if timeNow - (channel?.createdAt)! > 5 * 60 * 60 {
                
                self.showErrorAlert("Oops!", msg: "This challenge expired")
                
            } else {
                
                sendTextMessage(messageParams: messageParams)
                
            }
            
            
        } else {
            
            sendTextMessage(messageParams: messageParams)
            
            
        }
        
    }
  
    
    func sendTextMessage(messageParams: SBDUserMessageParams) {
        
        
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
        
    }
    
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        
        if channel?.channelUrl.contains("challenge") == true {
            
            let timeNow = UInt.init(Date().timeIntervalSince1970)
            
            if timeNow - (channel?.createdAt)! > 5 * 60 * 60 {
                
                self.showErrorAlert("Oops!", msg: "This challenge expired")
                
            } else {
                
                sendMediaMess(fileData: fileData, fileName: fileName, mimeType: mimeType)
               
                
            }
            
            
        } else {
            
            sendMediaMess(fileData: fileData, fileName: fileName, mimeType: mimeType)
            
            
        }
      
        
    }
    
    func sendMediaMess(fileData: Data?, fileName: String, mimeType: String) {
        
        guard let fileData = fileData else { return }
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
    
    func setupWithCall() {
        
        // Do any additional setup after loading the view.
        
        settingButton.setImage(UIImage(named: "img_btn_channel_settings"), for: [])
        settingButton.addTarget(self, action: #selector(showChannelSetting(_:)), for: .touchUpInside)
        settingButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let settingBarButton = UIBarButtonItem(customView: settingButton)
    

        
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
      
        self.navigationItem.rightBarButtonItems = [settingBarButton, voiceCallBarButton]
        
        
        // call animation
        if general_call != nil {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                
                
                if  voiceCallButton.currentImage == nil {
                    
                    voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                    
                } else {
                    
                    if voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                        
                        voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                        
                    }
                    
                    
                }
                
                         
                return
                
            }
            
            if call.isEnded == true {
                
                if  voiceCallButton.currentImage == nil {
                    
                    voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                    
                } else {
                    
                    if voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                        
                        voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                        
                    }
                    
                    
                }
                
            } else {
                
                
                let arr = [call.callee?.userId, call.caller?.userId]
                
                
                for user in ((channel?.members)! as NSArray as! [SBDMember]) {
                    if user.userId != Auth.auth().currentUser!.uid {
                        
                        
                        if arr.contains(user.userId) {
                            
                            
                            if voiceCallButton.currentImage == nil {
                                
                                voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                                
                            } else {
                                
                                if voiceCallButton.currentImage?.isEqual(UIImage(named: "icCallFilled")) == false  {
                                    
                                    voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                                    
                                }
                                
                                
                            }
                        
                            
                            voiceCallButton.setTitle("", for: .normal)
                            voiceCallButton.sizeToFit()
                            voiceCallButton.shake()
                        
                            
                        } else{
                            
                            
                            if voiceCallButton.currentImage == nil {
                                
                                voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                
                            } else {
                                
                                if voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                                    
                                    voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                    
                                }
                                
                            }
                            
                            
                            
                            //voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                            voiceCallButton.setTitle("", for: .normal)
                            voiceCallButton.sizeToFit()
                            voiceCallButton.removeAnimation()
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            
            
        } else {
            
            if let url = channelUrl {
                
                let db = DataService.instance.mainFireStoreRef.collection("Group_call")
                
                db.whereField("ChanelUrl", isEqualTo: url).getDocuments {  querySnapshot, error in
                        guard let snapshot = querySnapshot else {
                            
                            self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                            self.presentErrorAlert(message: error!.localizedDescription)
                            print("Error fetching snapshots: \(error!)")
                            return
                        
                        }
                    
                    if snapshot.isEmpty != true {
                        
                        print("Get room Id")
                        
                        for item in snapshot.documents {
                            
                            if let roomId = item.data()["roomId"] as? String {
                                
                                SendBirdCall.fetchRoom(by: roomId) {  room, error in
                                    guard let room = room, error == nil else {
                                        
                                        
                                        if error?.errorCode.rawValue == 1800303 {
                                            
                                            self.reauthenticateUser(shouldAnimated: false)
                                            
                                        } else if error?.errorCode.rawValue == 1800700 || error?.errorCode.rawValue == 1800701 || error?.errorCode.rawValue == 1400122 {
                                            
                                            do {
                                                try self.getRoom!.exit()
                                                general_room = nil
                                                gereral_group_chanel_url = nil
                                                
                                                // participant has exited the room successfully.
                                            } catch {
                                                
                                                //self.presentErrorAlert(message: "Can't leave the room now!")
                                                // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                                            }
                                            
                                        } else {
                                            
                                            self.presentErrorAlert(message: "Error code: \(error!.errorCode.rawValue), \(error!.localizedDescription)")
                                            
                                            
                                        }
                                        
                                        return
                                        
                                        
                                    }
                                    
                                    self.getRoom = room
                        
                                    
                                    if self.getRoom.participants.count > 0 {
                                    
                                        
                                        self.voiceCallButton.setTitle("+", for: .normal)
                                        
                                        
                                        if self.voiceCallButton.currentImage == nil {
                                            
                                            self.voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                                            
                                        } else {
                                            
                                            if self.voiceCallButton.currentImage?.isEqual(UIImage(named: "icCallFilled")) == false  {
                                                
                                                self.voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                                                
                                            }
                                            
                                        }
                                        
                                        //voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                                        
                                        self.voiceCallButton.sizeToFit()
                                        self.voiceCallButton.shake()
                                        
                                    } else {
                                        
                                        
                                        if self.voiceCallButton.currentImage == nil {
                                            
                                            self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                            
                                        } else {
                                            
                                            if self.voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                                                
                                                self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                                
                                            }
                                            
                                        }
                                        
                                        //voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                        self.voiceCallButton.setTitle("", for: .normal)
                                        self.voiceCallButton.sizeToFit()
                                        self.voiceCallButton.removeAnimation()
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                    } else {
                        
                        
                        if self.voiceCallButton.currentImage == nil {
                            
                            self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                            
                        } else {
                            
                            if self.voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                                
                                self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    
                }
                
                
            } else {
                
                if voiceCallButton.currentImage == nil {
                    
                    voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                    
                } else {
                    
                    if voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                        
                        voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                        
                    }
                    
                }
                
               // voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                
            }
            
            
            
            
        }
        
        
    }
    
    func showChannelSetting(_ sender: AnyObject) {
       
        if let selected_channel = channel {
            
            let CSV = ChannelSettingsVC(channelUrl: selected_channel.channelUrl)
            navigationController?.pushViewController(CSV, animated: true)
            
        }
        
        
    }
    
    func clickVoiceCallBarButton(_ sender: AnyObject) {
        
        
        if (channel?.members!.count)! > 2 {
            
            

            preProcessGroupCall()
            
            
            
        } else if channel?.members?.count == 2 {
            
            
            makeDirectCall()
            
        } else {
            
            print("Can't perform action")
            
        }
        
           
    }
    
    func preProcessGroupCall() {
        
        // cancel any current direct call
        
        if general_call != nil {
            
            // cancel current call
            if let call = SendBirdCall.getCall(forCallId: general_call.callId) {
                call.end()
                CXCallManager.shared.endCXCall(call)
                general_call = nil
            }
            
            
        }
        
        if let url = channel?.channelUrl {
            
            if general_room == nil {
                checkIfRoomForChanelUrl(ChanelUrl: url)
            } else {
                
                if gereral_group_chanel_url != url {
                    
                    do {
                        try general_room!.exit()
                        general_room?.removeAllDelegates()
                        general_room = nil
                        gereral_group_chanel_url = nil
                        
                        // participant has exited the room successfully.
                        
                        checkIfRoomForChanelUrl(ChanelUrl: url)
                        
                    } catch {
                        
                        self.presentErrorAlert(message: "Multiple call at once error!")
                        // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                    }
                               
                    
                } else {
                    
                    
                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
        
                        controller.currentRoom = general_room
                        controller.newroom = false
                        controller.currentChanelUrl = url
                        
                        controller.modalPresentationStyle = .fullScreen
                        SwiftLoader.hide()
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                    
                    
                }
                
            }
            
            
            
        } else {
            
            self.presentErrorAlert(message: "Can't join call")
            
        }
        
    }
    
    func makeDirectCall() {
        
        // remove any group call
        
        if general_room != nil {
            
            do {
                try general_room!.exit()
                general_room?.removeAllDelegates()
                general_room = nil
                gereral_group_chanel_url = nil
                
                // participant has exited the room successfully.
            } catch {
                
                //self.presentErrorAlert(message: "Can't leave the room now!")
                // SBCError.participantNotInRoom is thrown because participant has not entered the room.
            }
            
        }
        
        if general_call == nil {
            
            makeCall()
            
        } else {
            
            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else {
                
                self.presentErrorAlert(message: "Can't make call now!")
                return
                
            }
            
            if call.isEnded == true {
                
                general_call = nil
                makeCall()
                
            } else {
                
                
                let arr = [call.callee?.userId, call.caller?.userId]
                
                for user in ((channel?.members)! as NSArray as! [SBDMember]) {
                    if user.userId != Auth.auth().currentUser!.uid {
                        
                        
                        if arr.contains(user.userId) {
                            
                            
                            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoiceCallViewController") as? VoiceCallViewController {
                
                                controller.call = general_call
                                controller.isDialing = true
                                controller.newcall = false
                            
                                controller.modalPresentationStyle = .fullScreen
                                
                                SwiftLoader.hide()
                                self.present(controller, animated: true, completion: nil)
                                
                            }
                            
                            
                        } else {
                            
                            // cancel current call
                            guard let call = SendBirdCall.getCall(forCallId: general_call.callId) else { return }
                            call.end()
                            CXCallManager.shared.endCXCall(call)
                            general_call = nil
                            
                            
                            //establish a new call
                            makeCall()
                            
                            
                        }
                        
                        
                    }
                }
          
            }
            
            
        }
        
    }
    
    
    
    func makeCall() {
        
        var callee = ""
        
        for user in ((channel?.members)! as NSArray as! [SBDMember]) {
            if user.userId != Auth.auth().currentUser!.uid {
                callee = user.userId
                break
            }
        }
       
        // MARK: SendBirdCall.dial()
        let callOptions = CallOptions(isAudioEnabled: true)
        let dialParams = DialParams(calleeId: callee, isVideoCall: false, callOptions: callOptions, customItems: [:])

        SendBirdCall.dial(with: dialParams) { call, error in
            DispatchQueue.main.async { [weak self] in
                guard self != nil else { return }
            }
            
            guard error == nil, let call = call else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if error!.errorCode.rawValue == 1800303 {
                        
                        self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                        
                    } else {
                        
                        self.presentErrorAlert(message: "Error code: \(error!.errorCode.rawValue), \(DialErrors.voiceCallFailed(error: error).localizedDescription)")
                        
                    }
                    
                    
                   
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
               
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoiceCallViewController") as? VoiceCallViewController {
    
                    controller.call = call
                    controller.isDialing = true
                    controller.newcall = true
                    
                    controller.modalPresentationStyle = .fullScreen
                    SwiftLoader.hide()
                    self.present(controller, animated: true, completion: nil)
                    
                }
                
            }
        }
                
    }
    
    
    func checkIfRoomForChanelUrl(ChanelUrl: String) {
        
        swiftLoader(text: "")
        
        if getRoom == nil {
            
            let db = DataService.instance.mainFireStoreRef.collection("Group_call")
            
            db.whereField("ChanelUrl", isEqualTo: ChanelUrl).getDocuments {  querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        
                        SwiftLoader.hide()
                        self.presentErrorAlert(message: error!.localizedDescription)
                        print("Error fetching snapshots: \(error!)")
                        return
                    
                    }
                
                if snapshot.isEmpty != true {
                    
                    print("Get room Id")
                    
                    for item in snapshot.documents {
                        
                        if let roomId = item.data()["roomId"] as? String {
                            
                            self.startGroupCall(id: roomId, url: ChanelUrl)
                        }
                        
                    }
                    
                } else {
                    
                    let roomType = RoomType.largeRoomForAudioOnly
                    let params = RoomParams(roomType: roomType)
                    SendBirdCall.createRoom(with: params) { room, error in
                        guard let room = room, error == nil else { return } // Handle error.
                        // `room` is created with a unique identifier `room.roomId`.
                        
                        let data = ["roomId": room.roomId, "ChanelUrl": ChanelUrl, "timeStamp": FieldValue.serverTimestamp()] as [String : Any]
                        
                        db.addDocument(data: data) { err in
                            if err != nil {
                                
                                SwiftLoader.hide()
                                self.presentErrorAlert(message: err!.localizedDescription)
                                return
                            }
                            
                            
                            self.startGroupCall(id: room.roomId, url: ChanelUrl)
                            
                        }
                            
                    }
                    
                    
                }
                
            }
            
            
        } else {
            
            let params = Room.EnterParams(isVideoEnabled: false, isAudioEnabled: true)
            
            getRoom.enter(with: params, completionHandler: {  err in
                if err != nil {
                    
                    
                    if err?.errorCode.rawValue == 1800303 {
                        
                        self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                        
                    } else if err?.errorCode.rawValue == 1800700 || err?.errorCode.rawValue == 1800701 {
                        
                        do {
                            try self.getRoom!.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            SwiftLoader.hide()
                            self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                    } else {
                        
                        
                        SwiftLoader.hide()
                        self.presentErrorAlert(message: "Error code: \(err!.errorCode.rawValue), \(err!.localizedDescription)")
                        
                        
                    }
                              
                    
                } else {
                    
                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
        
                        controller.currentRoom = self.getRoom
                        controller.newroom = true
                        controller.currentChanelUrl = ChanelUrl
                        
                        controller.modalPresentationStyle = .fullScreen
                        SwiftLoader.hide()
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                    
                    
                }
                
            })
            
            
        }
        
        
    }
    
    func startGroupCall(id: String, url: String) {
        
        SendBirdCall.fetchRoom(by: id) { room, error in
            guard let room = room, error == nil else {
                
                if error?.errorCode.rawValue == 1800303 {
                    
                    self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                    
                } else if error?.errorCode.rawValue == 1800700 || error?.errorCode.rawValue == 1800701 || error?.errorCode.rawValue == 1400122 {
                    
                    do {
                        try self.getRoom!.exit()
                        general_room = nil
                        gereral_group_chanel_url = nil
                        
                        // participant has exited the room successfully.
                    } catch {
                        
                        //self.presentErrorAlert(message: "Can't leave the room now!")
                        // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                    }
                    
                } else {
                    
                    
                    SwiftLoader.hide()
                    self.presentErrorAlert(message: "Error code: \(error!.errorCode.rawValue), \(error!.localizedDescription)")
                    
                    
                }
                
                return
                
                
            } // Handle error.
            // `room` with the identifier `ROOM_ID` is fetched from Sendbird Server.
            

            let params = Room.EnterParams(isVideoEnabled: false, isAudioEnabled: true)
            
            room.enter(with: params, completionHandler: { err in
                if err != nil {
                    
                    
                    if err?.errorCode.rawValue == 1800303 {
                        
                        self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                        
                    } else if err?.errorCode.rawValue == 1800700 || err?.errorCode.rawValue == 1800701 {
                        
                        do {
                            try self.getRoom!.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            SwiftLoader.hide()
                            self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                    } else {
                        
                        do {
                            try room.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            SwiftLoader.hide()
                            self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                        self.presentErrorAlert(message: "Error code: \(err!.errorCode.rawValue), \(err!.localizedDescription)")
                        
                        
                    }
                    
                    
                    
                    
                } else {
                    
                    if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
        
                        
                        
                        controller.currentRoom = room
                        controller.newroom = true
                        controller.currentChanelUrl = url
                        
                        controller.modalPresentationStyle = .fullScreen
                        SwiftLoader.hide()
                        
                        self.present(controller, animated: true, completion: nil)
                        
                    }
                    
                }
                
                
                
                
            })
            
        }
        
    }
    
    
    func ShowNotAuthenticatedProperlyAndReAuthenticate() {
        
        SwiftLoader.hide()
        
        let sheet = UIAlertController(title: "Your account isn't authenticated properly!", message: "You will have to re-authenticate to perform any calling function!", preferredStyle: .actionSheet)
        
        
        let Authenticate = UIAlertAction(title: "Re-authenticate", style: .default) { (alert) in
            
            
            self.reauthenticateUser(shouldAnimated: true)
            
        }

        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        sheet.addAction(Authenticate)
        sheet.addAction(cancel)

        
        self.present(sheet, animated: true, completion: nil)
        
        
        
    }
    
    
    
    func reauthenticateUser(shouldAnimated: Bool) {
        
        SwiftLoader.hide()
        
        if Auth.auth().currentUser?.isAnonymous != true, Auth.auth().currentUser?.uid != nil {
            
            if shouldAnimated == true {
                
                swiftLoader(text: "Authenticating...")
                
            }
        
            
            SBUGlobals.CurrentUser = SBUUser(userId: Auth.auth().currentUser!.uid)
            
            SBUMain.connect { usr, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                if let user = usr {
                
                    let params = AuthenticateParams(userId: user.userId)
                    
                        
                        SendBirdCall.authenticate(with: params) { (users, err) in
                            if err != nil {
                                
                                print(err!.localizedDescription)
                                return
                            }
                            // The user has been authenticated successfully and is connected to Sendbird server.
                            
                            
                            
                            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                            
                           
                            appDelegate?.voipRegistration()
                            appDelegate?.addDirectCallSounds()
                            
                            
                            if shouldAnimated == true {
                                
                                SwiftLoader.hide()
                                showNote(text: "Authenticated successfully!")
                            }
                            
                            
                            
                            // re-updateUI
                            
                            self.setupWithCall()
                            
                            //
                            
                           
                            
                        }
                }
                
            }
            
            
        } else {
            
            
            self.presentErrorAlert(message: "Can't authenticate your account right now, please try to logout and login again.")
            
        }
        
        
        
    }
    
    
    
    func swiftLoader(text: String) {
        
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
    

}





