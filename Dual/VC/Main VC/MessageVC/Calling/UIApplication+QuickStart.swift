//
//  UIApplication+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIApplication {
    
    func showCallController(with call: DirectCall) {
        
        // cancel any current direct call
        if general_call != nil {
            
            // cancel current call
            if let call = SendBirdCall.getCall(forCallId: general_call.callId) {
                call.end()
                CXCallManager.shared.endCXCall(call)
                general_call = nil
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
            }
            
            
        }
        
        // cancel any current room call
        
        if general_room != nil {
            
            do {
                try general_room!.exit()
                general_room?.removeAllDelegates()
                general_room = nil
                gereral_group_chanel_url = nil
                
                // participant has exited the room successfully.
                
               // checkIfRoomForChanelUrl(ChanelUrl: url)
                
            } catch {
                
                //self.presentErrorAlert(message: "Multiple call at once error!")
                // SBCError.participantNotInRoom is thrown because participant has not entered the room.
            }
            
        }
        
        
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "VoiceCallViewController")
            
            if var dataSource = viewController as? DirectCallDataSource {
                dataSource.call = call
                dataSource.isDialing = false
                dataSource.newcall = true
            }
            
            if let topViewController = UIViewController.topViewController {
                viewController.modalPresentationStyle = .fullScreen
                topViewController.present(viewController, animated: true, completion: nil)
            } else {
                self.keyWindow?.rootViewController = viewController
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
    
    func showError(with errorDescription: String?) {
        let message = errorDescription ?? "Something went wrong. Please retry."
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let topViewController = UIViewController.topViewController {
                topViewController.presentErrorAlert(message: message)
            } else {
                self.keyWindow?.rootViewController?.presentErrorAlert(message: message)
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
}
