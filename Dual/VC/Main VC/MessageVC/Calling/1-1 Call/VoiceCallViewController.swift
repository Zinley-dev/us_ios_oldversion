//
//  VoiceCallViewController.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import AVKit
import CallKit
import MediaPlayer
import SendBirdCalls
import AsyncDisplayKit
import Firebase

class VoiceCallViewController: UIViewController, DirectCallDataSource {
    
    var newcall: Bool?
    @IBOutlet weak var speakerButton: UIButton! {
        
        didSet {
    
            guard let output = AVAudioSession().currentRoute.outputs.first else { return }
            
            
            if output.portType.rawValue == "BluetoothHFP" {
                
                self.speakerButton.setBackgroundImage(UIImage(named: "airpod"), for: .normal)
                
            } else {
                
                self.speakerButton.setBackgroundImage(.audio(output: output.portType),
                                                         for: .normal)
            }
            
        
            
        }
        
    }
    
    @IBOutlet weak var muteAudioButton: UIButton! {
        
        didSet {
            self.muteAudioButton.isSelected = !self.call.isLocalAudioEnabled
            self.muteAudioButton.setBackgroundImage(.audio(isOn: !(self.call.isLocalAudioEnabled)), for: .normal)
        }
    }
    
    @IBOutlet weak var endButton: UIButton!
    
    
    @IBOutlet weak var callTimerLabel: UILabel!
    
    
    // Notify muted state
    
    @IBOutlet weak var mutedStateImageView: UIImageView!
    
    @IBOutlet weak var mutedStateLabel: UILabel! {
        
        didSet {
            guard let remoteUser = self.call.remoteUser else { return }
            let name = remoteUser.nickname?.isEmptyOrWhitespace == true ? remoteUser.userId : remoteUser.nickname!
            
            self.mutedStateLabel.text = CallStatus.muted(user: name).message
        }
        
    }
   
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var CalleeName: UILabel!
    
    var call: DirectCall!
    var isDialing: Bool?
    var callTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }

        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        
        self.call.delegate = appDelegate
        
        self.setupAudioOutputButton()
        self.updateRemoteAudio(isEnabled: true)
        
        if newcall == true {
            
            general_call = self.call
            
        } else {
            
            
            if self.call.duration.durationText() != "0:00" {
                
                self.activeTimer()
                
            }
            
            
            
        }
        
        if self.call.callee?.userId != Auth.auth().currentUser!.uid {
            
            if let Callee = self.call.callee?.nickname  {
                
                CalleeName.text = Callee
                
            }
            
            if let url = self.call.callee?.profileURL {
                
                
             
                let imageNode = ASNetworkImageNode()
                imageNode.contentMode = .scaleAspectFit
                imageNode.shouldRenderProgressImages = true
                imageNode.url = URL.init(string: url)
                imageNode.frame = self.profileImg.layer.bounds
                self.profileImg.image = nil
                
                
                self.profileImg.addSubnode(imageNode)
                
            }
            
            
        } else {
            
            if let Callee = self.call.caller?.nickname  {
                
                CalleeName.text = Callee
                
            }
            
            if let url = self.call.caller?.profileURL {
                
                
            
                
                let imageNode = ASNetworkImageNode()
                imageNode.contentMode = .scaleAspectFit
                imageNode.shouldRenderProgressImages = true
                imageNode.url = URL.init(string: url)
                imageNode.frame = self.profileImg.layer.bounds
                self.profileImg.image = nil
                
                
                self.profileImg.addSubnode(imageNode)
                
            }
            
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.isDialing == true else { return }
        
        
        if newcall == true {
            
            CXCallManager.shared.startCXCall(self.call) { [weak self] isSucceed in
                guard let self = self else { return }
                if !isSucceed {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
        
        
        
    }
    
    // MARK: - IBActions
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        
        guard let call = SendBirdCall.getCall(forCallId: self.call.callId) else { return }
        call.end()
        CXCallManager.shared.endCXCall(call)
        
        
    }
    
    // MARK: - Basic UI
    func setupEndedCallUI() {
        self.callTimer?.invalidate()    // Main thread
        self.callTimer = nil
        self.callTimerLabel.text = CallStatus.ended(result: call.endResult.rawValue).message
        
        self.endButton.isHidden = true
        self.speakerButton.isHidden = true
        self.muteAudioButton.isHidden = true
        
        self.mutedStateImageView.isHidden = true
        self.mutedStateLabel.isHidden = true
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

// MARK: - SendBirdCalls: Audio Features
extension VoiceCallViewController {
    func updateLocalAudio(isEnabled: Bool) {
        self.muteAudioButton.setBackgroundImage(.audio(isOn: isEnabled), for: .normal)
        if isEnabled {
            call?.muteMicrophone()
        } else {
            call?.unmuteMicrophone()
        }
    }
    
    func updateRemoteAudio(isEnabled: Bool) {
        self.mutedStateImageView.isHidden = isEnabled
        self.mutedStateLabel.isHidden = isEnabled
    }
}

// MARK: - SendBirdCalls: Audio Output
extension VoiceCallViewController {
    func setupAudioOutputButton() {
        
        let width = self.speakerButton.frame.width
        let height = self.speakerButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
    
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        self.customize(routePickerView)
        self.speakerButton.addSubview(routePickerView)
    }
    
    func customize(_ routePickerView: UIView) {
        if #available(iOS 11.0, *) {
            guard let routePickerView = routePickerView as? AVRoutePickerView else { return }
            routePickerView.activeTintColor = .clear
            routePickerView.tintColor = .clear
        } else {
            guard let volumeView = routePickerView as? MPVolumeView else { return }
            
            volumeView.showsVolumeSlider = false
            volumeView.setRouteButtonImage(nil, for: .normal)
            volumeView.routeButtonRect(forBounds: volumeView.frame)
        }
    }
}

// MARK: - SendBirdCalls: DirectCall duration
extension VoiceCallViewController {
    func activeTimer() {
        self.callTimerLabel.text = "00:00"
        
        // Main thread
        self.callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            // update UI
            self.callTimerLabel.text = self.call.duration.durationText()

            // Timer Invalidate
            if self.call.endedAt != 0, timer.isValid {
                timer.invalidate()
                self.callTimer = nil
            }
        }
    }
}

