//
//  AppDelegate+SendBirdCallsDelegates.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved..
//

import UIKit
import CallKit
import PushKit
import SendBirdCalls
import AsyncDisplayKit


// MARK: - Sendbird Calls Delegates
extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    // MARK: SendBirdCallDelegate
    // Handles incoming call. Please refer to `AppDelegate+VoIP.swift` file
    func didStartRinging(_ call: DirectCall) {
        call.delegate = self // To receive call event through `DirectCallDelegate`
        
        guard let uuid = call.callUUID else { return }
        guard CXCallManager.shared.shouldProcessCall(for: uuid) else { return }  // Should be cross-checked with state to prevent weird event processings
        
        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.nickname ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = false
        update.localizedCallerName = call.caller?.nickname ?? "Unknown"
        
        if SendBirdCall.getOngoingCallCount() > 1 {
            // Allow only one ongoing call.
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update) { _ in
                CXCallManager.shared.endCall(for: uuid, endedAt: Date(), reason: .declined)
            }
            call.end()
        } else {
            // Report the incoming call to the system
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update)
        }
    }
    
    // MARK: DirectCallDelegate
    func didConnect(_ call: DirectCall) {
        
        if let vc = UIViewController.currentViewController() {
                    
            if vc is VoiceCallViewController {
                
                if let update1 = vc as? VoiceCallViewController {
                    
                    update1.activeTimer()      // call.duration
                    update1.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
                    
                    if update1.newcall == true {
                        
                        CXCallManager.shared.connectedCall(call)
                        
                    }
                    
                }
                
                
                
            }
            
            
        }
        
    }
    
    func didEnd(_ call: DirectCall) {
             
        //guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        CXCallManager.shared.endCXCall(call)
        
        
        general_call = nil
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
        
        if let vc = UIViewController.currentViewController() {
                    
            if vc is VoiceCallViewController {
                
                if let update1 = vc as? VoiceCallViewController {
                    
                    update1.setupEndedCallUI()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard self != nil else { return }
                        
                        update1.dismiss(animated: true, completion: nil)
                       
                    }
                    
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    func didEstablish(_ call: DirectCall) {
        
        if let vc = UIViewController.currentViewController() {
                    
            if vc is VoiceCallViewController {
                
                if let update1 = vc as? VoiceCallViewController {
                    
                    if update1.newcall == true {
                        
                        update1.callTimerLabel.text = CallStatus.connecting.message
                        
                    }
                    
                }
            }
        }
        
        
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        
        if let vc = UIViewController.currentViewController() {
                    
            if vc is VoiceCallViewController {
                
                if let update1 = vc as? VoiceCallViewController {
                    
                    update1.updateRemoteAudio(isEnabled: call.isRemoteAudioEnabled)
                    
                }
            }
        }
        
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        
        
        
        if let vc = UIViewController.currentViewController() {
                    
            if vc is VoiceCallViewController {
                
                if let update1 = vc as? VoiceCallViewController {
                    
                    guard !call.isEnded else { return }
                    guard let output = session.currentRoute.outputs.first else { return }
                    
                  
                    if output.portType.rawValue == "BluetoothHFP" {
                        
                        update1.speakerButton.setBackgroundImage(UIImage(named: "airpod"), for: .normal)
                        
                    } else {
                        update1.speakerButton.setBackgroundImage(.audio(output: output.portType),
                                                                 for: .normal)
                    }
                    
                    
                 
                }
            }
            
        }
        
    }
}
