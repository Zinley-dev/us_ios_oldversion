//
//  PostNode.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/23/20.
//

import UIKit
import AsyncDisplayKit
import MarqueeLabel
import SwiftPublicIP
import Alamofire
import Firebase
import ActiveLabel
import SendBirdSDK
import AVFoundation
import AVKit


class PostNode: ASCellNode, ASVideoNodeDelegate {
    
    var longpressing = false
    var rotatingCell = false
    var is_challenge = false
    var already_chatList = false
    var animatedLabel: MarqueeLabel!
    var time = 0
    var isCellHidden = false
    var last_view_timestamp =  NSDate().timeIntervalSince1970
    var isViewed = false
    var buttonHidden = true
    var currentAspect = "AspectFit"
    var shouldCountView = true
    var currentTimeStamp: TimeInterval!
    //
    var gradientNode: GradienView
    var isAnimating = false
    weak var post: HighlightsModel!
   
    var backgroundImageNode: ASNetworkImageNode
    var copyImageNode: ASNetworkImageNode
    var videoNode: ASVideoNode
    var region: String!
    var DetailViews: DetailView!
    var ButtonView: ButtonViews!
   
    var infoView: ASDisplayNode!
    var buttonListView: ASDisplayNode!
   
    // btn
    
    var shareBtn : ((ASCellNode) -> Void)?
    var challengeBtn : ((ASCellNode) -> Void)?
    var linkBtn : ((ASCellNode) -> Void)?
    var profileBtn : ((ASCellNode) -> Void)?
    var viewBtn : ((ASCellNode) -> Void)?
    var commentBtn : ((ASCellNode) -> Void)?
    var cardBtn: ((ASCellNode) -> Void)?
    var gameTimer: Timer?
    //
    
    var isFilled = false
    var isAlreadyFilled = false
    
    var viewCount = 0
    var cmtCount = 0
    var likeCount = 0
    
    var animatingList = ["Like", "View", "Comment"]
    var currentAnimating = ""
    
    init(with post: HighlightsModel) {
        
        self.post = post
       
        self.videoNode = ASVideoNode()
       
        self.infoView = ASDisplayNode()
        self.buttonListView = ASDisplayNode()
        self.backgroundImageNode = ASNetworkImageNode()
        self.copyImageNode = ASNetworkImageNode()
        self.gradientNode = GradienView()
       
        super.init()
        
        
       
        
        DispatchQueue.main.async {
            
            self.DetailViews = DetailView()
            self.ButtonView = ButtonViews()
            
            
        }
        
        
        automaticallyManagesSubnodes = true
       
        self.videoNode.backgroundColor =  UIColor.clear
        self.backgroundImageNode.contentMode = .scaleAspectFill
        self.backgroundImageNode.backgroundColor = UIColor.clear
        self.videoNode.url = self.getThumbnailVideoNodeURL(post: post)
        self.videoNode.player?.automaticallyWaitsToMinimizeStalling = true
        
        
        self.videoNode.shouldAutoplay = false
        self.videoNode.shouldAutorepeat = true
        self.videoNode.delegate = self
        
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
        
        
        backgroundImageNode.isOpaque = false
   
        
        
        if global_isLandScape == false {
            
            if post.origin_width/post.origin_height > 0.5, post.origin_width/post.origin_height < 0.6 {
                    
                self.videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                self.videoNode.contentMode = .scaleAspectFill
                isAlreadyFilled = true
               
               
            } else {
                
                
                self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
                self.videoNode.contentMode = .scaleAspectFit
                isAlreadyFilled = false
                
                
            }
            
        } else {
            
            self.videoNode.gravity = AVLayerVideoGravity.resizeAspect.rawValue
            self.videoNode.contentMode = .scaleAspectFit
            isAlreadyFilled = false
            
            
        }
        
        if post.origin_width/post.origin_height > 0.5, post.origin_width/post.origin_height < 0.6 {
                
            isFilled = true
           
        } else {
            
            
            isFilled = false
            
            
        }

        
      
        self.backgroundColor = UIColor.clear
        self.infoView.backgroundColor = UIColor.clear
        
        backgroundImageNode.url = getThumbnailURL(post: post)
        
        DispatchQueue.main.async {
            self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(post: post)!)
            

            self.DetailViews.backgroundColor = UIColor.clear
            self.view.backgroundColor = UIColor.clear
            

            self.infoView.view.addSubview(self.DetailViews)
            self.buttonListView.view.addSubview(self.ButtonView)
            
            
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            
            self.backgroundImageNode.view.addSubview(effectView)
            
            effectView.translatesAutoresizingMaskIntoConstraints = false
            effectView.topAnchor.constraint(equalTo: self.backgroundImageNode.view.topAnchor, constant: 0).isActive = true
            effectView.bottomAnchor.constraint(equalTo: self.backgroundImageNode.view.bottomAnchor, constant: 1000).isActive = true
            effectView.leadingAnchor.constraint(equalTo: self.backgroundImageNode.view.leadingAnchor, constant: -1000).isActive = true
            effectView.trailingAnchor.constraint(equalTo: self.backgroundImageNode.view.trailingAnchor, constant: 1000).isActive = true
            
             
            self.DetailViews.translatesAutoresizingMaskIntoConstraints = false
            self.DetailViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.DetailViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.DetailViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.DetailViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true
            
          
            
            
            self.ButtonView.translatesAutoresizingMaskIntoConstraints = false
            self.ButtonView.topAnchor.constraint(equalTo: self.buttonListView.view.topAnchor, constant: 0).isActive = true
            self.ButtonView.bottomAnchor.constraint(equalTo: self.buttonListView.view.bottomAnchor, constant: 0).isActive = true
            self.ButtonView.leadingAnchor.constraint(equalTo: self.buttonListView.view.leadingAnchor, constant: 0).isActive = true
            self.ButtonView.trailingAnchor.constraint(equalTo: self.buttonListView.view.trailingAnchor, constant: 0).isActive = true
            
            

            
            self.ButtonView.commentBtn.setImage(UIImage(named: "comment")?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
            self.ButtonView.shareBtn.setImage(UIImage(named: "newShare")?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
            self.ButtonView.viewBtn.setImage(UIImage(named: "view")?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
            
            //self!.ButtonView.challengeBtn.imageView?.contentMode = .scaleAspectFill
            
            
            self.DetailViews.challengeCardBtn.setTitle("", for: .normal)
            self.DetailViews.challengeCardBtn.setImage(UIImage(named: "card_4x")?.resize(targetSize: CGSize(width: 37, height: 27)), for: .normal)
            
            self.DetailViews.collectionView.backgroundColor = UIColor.clear
            // construct hashTagCollectionHeight depends on hashtag list
            
                
            
            self.ButtonView.controlAction.setTitle("", for: .normal)
            self.ButtonView.likeBtn.setTitle("", for: .normal)
            self.ButtonView.soundBtn.setTitle("", for: .normal)
            self.ButtonView.commentBtn.setTitle("", for: .normal)
            self.ButtonView.shareBtn.setTitle("", for: .normal)
            self.ButtonView.challengeBtn.setTitle("", for: .normal)
            self.ButtonView.viewBtn.setTitle("", for: .normal)
            self.ButtonView.controlHeight.constant = 10
            self.DetailViews.openCommentBtn.setTitle("", for: .normal)
           
            self.ButtonView.soundLbl.isHidden = true
            
            
            self.gameInfoSetting(post: post, Dview: self.DetailViews)
            
            // attribute
            
            if isSound == true {
                
                
                if shouldMute == false {
                    self.videoNode.muted = false
                    self.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                    self.ButtonView.soundLbl.text = "Sound on"
                } else {
                    self.videoNode.muted = true
                    self.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                    self.ButtonView.soundLbl.text = "Sound off"
                }
                
    
                
            } else {
                
                
                if shouldMute == false {
                    self.videoNode.muted = false
                    self.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                    self.ButtonView.soundLbl.text = "Sound on"
                } else {
                    self.videoNode.muted = true
                    self.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                    self.ButtonView.soundLbl.text = "Sound off"
                }
                               
            }
            
            if isMinimize == true {
                
                if global_isLandScape == false {
                    self.hideButtons(shouldAnimate: true)
                } else {
                    self.hideButtons(shouldAnimate: false)
                }
              
                
            } else {
                
                self.showButtons()
                
            }
            
            
            let linkTap = UITapGestureRecognizer(target: self, action: #selector(PostNode.streamLinkBtnPressed))
            self.DetailViews.streamLinkLbl.isUserInteractionEnabled = true
            self.DetailViews.streamLinkLbl.addGestureRecognizer(linkTap)
            
            
            
            let profileTap = UITapGestureRecognizer(target: self, action: #selector(PostNode.userProfileBtnPressed))
            self.DetailViews.avatarImg.isUserInteractionEnabled = true
            self.DetailViews.avatarImg.addGestureRecognizer(profileTap)
            
            //
            
            let profileTa2 = UITapGestureRecognizer(target: self, action: #selector(PostNode.userProfileBtnPressed))
            self.DetailViews.usernameLbl.isUserInteractionEnabled = true
            self.DetailViews.usernameLbl.addGestureRecognizer(profileTa2)
            
            
            
            let cmtTa2 = UITapGestureRecognizer(target: self, action: #selector(PostNode.cmtTapped))
            self.DetailViews.titleLbl.isUserInteractionEnabled = true
            self.DetailViews.titleLbl.addGestureRecognizer(cmtTa2)
        
            self.likeCount(Dview: self.ButtonView)
            self.cmtCount(Dview: self.ButtonView)
            self.viewCount(Dview: self.ButtonView)
            
            
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostNode.handleSwipes(_:)))
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PostNode.handleSwipes(_:)))
            
            leftSwipe.direction = .left
            rightSwipe.direction = .right
            
            
            self.view.addGestureRecognizer(leftSwipe)
            self.view.addGestureRecognizer(rightSwipe)
            
            
            let likeTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.likeTapped))
            likeTap.numberOfTapsRequired = 1
            self.ButtonView.likeBtn.addGestureRecognizer(likeTap)
            

            
            let challengeCardTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.cardBtnPressed))
            challengeCardTap.numberOfTapsRequired = 1
            self.DetailViews.challengeCardBtn.addGestureRecognizer(challengeCardTap)

            let controlTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.controlButton))
            controlTap.numberOfTapsRequired = 1
            self.ButtonView.controlAction.addGestureRecognizer(controlTap)
            
            let commentTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.cmtTapped))
            commentTap.numberOfTapsRequired = 1
            
            let commentTap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.cmtTapped))
            commentTap2.numberOfTapsRequired = 1
            
            self.ButtonView.commentBtn.addGestureRecognizer(commentTap)
            self.DetailViews.openCommentBtn.addGestureRecognizer(commentTap2)
        
            
            let shareTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.shareBtnPressed))
            shareTap.numberOfTapsRequired = 1
            self.ButtonView.shareBtn.addGestureRecognizer(shareTap)
            
            let soundTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.updateSound))
            soundTap.numberOfTapsRequired = 1
            self.ButtonView.soundBtn.addGestureRecognizer(soundTap)
            
            let viewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.viewBtnPressed))
            viewTap.numberOfTapsRequired = 1
            self.ButtonView.viewBtn.addGestureRecognizer(viewTap)
            
            
            
            
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostNode.likeHandle))
            doubleTap.numberOfTapsRequired = 2
            self.view.addGestureRecognizer(doubleTap)
            
            doubleTap.delaysTouchesBegan = true
            
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(PostNode.settingBtnPressed(sender:)))
            longPressGesture.minimumPressDuration = 0.5
            self.view.addGestureRecognizer(longPressGesture)
            
            
        }
        
      
     
    }
    

    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .right) {
            
            if videoNode.isPlaying() {
                
                if let speedRate = videoNode.player?.rate {
                    
                    var updatedSpeedRate = speedRate
                     
                    if updatedSpeedRate == 1.0 {
                             
                        updatedSpeedRate = 0.7
                        
                        if updatedSpeedRate == 1.0 {
                           
                            animateSpeedRate(rate: "Normal")
                        } else {
                            
                            animateSpeedRate(rate: "\(updatedSpeedRate)x")
                        }
                      
                        videoNode.player?.rate = Float(updatedSpeedRate)
                        
                    } else if updatedSpeedRate == 1.5 {
                       
                        updatedSpeedRate = 1.0
                        
                        if updatedSpeedRate == 1.0 {
                            
                            animateSpeedRate(rate: "Normal")
                        } else {
                            
                            animateSpeedRate(rate: "\(updatedSpeedRate)x")
                        }
                      
                        videoNode.player?.rate = Float(updatedSpeedRate)
                        
                    } else {
                        
                        
                        animateSpeedRate(rate: "\(speedRate)x")
                        
                      
                    }
                    
                }
                
            }
            
        }
            
        if (sender.direction == .left) {
            
            if videoNode.isPlaying() {
                
                if let speedRate = videoNode.player?.rate {
                    
                    var updatedSpeedRate = speedRate
                    
                    if updatedSpeedRate == 1.0 {
                        
                        updatedSpeedRate = 1.5
                        
                        if updatedSpeedRate == 1.0 {
                           
                            animateSpeedRate(rate: "Normal")
                        } else {
                           
                            animateSpeedRate(rate: "\(updatedSpeedRate)x")
                        }
                      
                        videoNode.player?.rate = Float(updatedSpeedRate)
                        
                    } else if updatedSpeedRate == 0.7 {
                        
                        updatedSpeedRate = 1.0
                        
                        if updatedSpeedRate == 1.0 {
                            
                            animateSpeedRate(rate: "Normal")
                        } else {
                           
                            animateSpeedRate(rate: "\(updatedSpeedRate)x")
                        }
                      
                        videoNode.player?.rate = Float(updatedSpeedRate)
                        
                    } else {
                        
                        
                        animateSpeedRate(rate: "\(updatedSpeedRate)x")
                        
                      
                    }
                    
                    
                }
       
            }
            
        }
        
    }
    
    func animateSpeedRate(rate: String) {
        
        let rateView = UILabel()
        rateView.textAlignment = .center
        rateView.font = UIFont(name:"Roboto-Regular",size: 20)!
        rateView.textColor = UIColor.white
        rateView.backgroundColor = UIColor.clear
        rateView.text = rate
        rateView.frame.size = CGSize(width: 100, height: 30)
        rateView.center = self.videoNode.view.center
        self.videoNode.view.addSubview(rateView)
        rateView.textDropShadow()
        
        
        rateView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 1) {
            
            rateView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if rateView.alpha == 0 {
                
                rateView.removeFromSuperview()
                
            }
            
        }
        
    }
    

    
    @objc func likeHandle() {
        
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "likes pop up")
        imgView.frame.size = CGSize(width: 70, height: 70)
        imgView.center = self.videoNode.view.center
        self.videoNode.view.addSubview(imgView)
        
        
        imgView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 1) {
            
            imgView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if imgView.alpha == 0 {
                
                imgView.removeFromSuperview()
                
            }
            
        }
    
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            DataService.instance.mainFireStoreRef.collection("Likes").document(post.highlight_id + uid).getDocument { querySnapshot, error in
                
                guard querySnapshot != nil else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if querySnapshot?.exists == false {
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.ButtonView.likeBtn.transform = self.ButtonView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
                        self.ButtonView.likeBtn.setImage(UIImage(named: "liked")?.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                        }, completion: { _ in
                          // Step 2
                          UIView.animate(withDuration: 0.1, animations: {
                              self.ButtonView.likeBtn.transform = CGAffineTransform.identity
                          })
                        })
                             
                    
                    self.likeCount += 1
                    
                    self.ButtonView.likeLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
                    
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                          
                            ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Like-post", Highlight_Id: self.post.highlight_id, category: self.post.category)
                        
                            self.getIpInfoAndUpdateToServer(IP: string, islike: true)
                           
                        }
                        
                    }
                    
                }
                
                
                
            }
            
        }
    
    }
    
    func showButtons() {
        
        
        ButtonView.shareStackView.isHidden = false
        ButtonView.controlHeight.constant = 40
        ButtonView.soundLbl.isHidden = false
        ButtonView.soundBtn.isHidden = false
        ButtonView.commentStackView.isHidden = false
        ButtonView.likeStackView.isHidden = false
        ButtonView.animationView.isHidden = true
        ButtonView.challengeBtn.isHidden = false
        ButtonView.moveStackView.isHidden = false
        buttonHidden = false
        
       
        if global_isLandScape == false {
            startAnimating()
        }
        
        isAnimating = false
        
        if post.userUID == Auth.auth().currentUser?.uid {
            
            ButtonView.viewStackView.isHidden = false
            ButtonView.shadowHeight.constant = 465
            
        } else {
            ButtonView.shadowHeight.constant = 400
        }
        
        ButtonView.botConstraint.constant = 0
        ButtonView.challengeHeight.constant = 80
        ButtonView.shadowBottomConstraint.constant = -60
        
        self.ButtonView.controlAction.setImage(UIImage(named: "down")!.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        
        
    }
    
    
    @objc func controlButton() {
        
        if buttonHidden == true {
            
            showButtons()
            
            
        } else {
            
            if global_isLandScape == false {
                hideButtons(shouldAnimate: true)
               
            } else {
                hideButtons(shouldAnimate: false)
            }
            
        
        }
        
        
    }
    

    
    @objc func updateSound() {
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
      
        if videoNode.muted == true {
            
            videoNode.muted = false
            shouldMute = false
           
            
            UIView.animate(withDuration: 0.1, animations: {
                self.ButtonView.soundBtn.transform = self.ButtonView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                self.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                self.ButtonView.soundLbl.text = "Sound on"
                }, completion: { _ in
                  // Step 2
                  UIView.animate(withDuration: 0.1, animations: {
                      self.ButtonView.soundBtn.transform = CGAffineTransform.identity
                  })
                })
            
            
            let imgView = UIImageView()
            imgView.image = UIImage(named: "3xunmute")
            imgView.frame.size = CGSize(width: 50, height: 50)
            imgView.center = self.view.center
            self.view.addSubview(imgView)
            
            
            imgView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 1) {
                
                imgView.alpha = 0
                
            }
        
           
            
        } else {
            
            videoNode.muted = true
            shouldMute = true
         
            UIView.animate(withDuration: 0.1, animations: {
                self.ButtonView.soundBtn.transform = self.ButtonView.soundBtn.transform.scaledBy(x: 0.9, y: 0.9)
                self.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                self.ButtonView.soundLbl.text = "Sound off"
                }, completion: { _ in
                  // Step 2
                  UIView.animate(withDuration: 0.1, animations: {
                      self.ButtonView.soundBtn.transform = CGAffineTransform.identity
                  })
                })
            
            
            let imgView = UIImageView()
            imgView.image = UIImage(named: "3xmute")
            imgView.frame.size = CGSize(width: 50, height: 50)
            imgView.center = self.view.center
            self.view.addSubview(imgView)
            
            
            imgView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 1) {
                
                imgView.alpha = 0
                
            }
                 
        }
        
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        

        
        if constrainedSize.max.width < constrainedSize.max.height {
            
            
            infoView.style.preferredSize = CGSize(width: constrainedSize.max.width - 75 , height: 138)
            
        } else {
            
            infoView.style.preferredSize = CGSize(width: constrainedSize.max.height - 75 , height: 138)
            
        }
     

        var insets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: CGFloat.infinity)
        let insets2 = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0)
        
        
        if constrainedSize.max.width < constrainedSize.max.height {
                    
            addbuttonFrame(width: Float(constrainedSize.max.width), height: Float(constrainedSize.max.height))
           
        } else {
            
            addbuttonFrame(width: Float(constrainedSize.max.width - 20), height: Float(constrainedSize.max.height))
                        
        }
        
        if isFeedVC {
            
            insets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: CGFloat.infinity)
            
        } else {
            
            insets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 25, right: CGFloat.infinity)
            
        }
        
        let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: infoView)
                let textInsetSpec2 = ASInsetLayoutSpec(insets: insets2, child: videoNode)
                let textInsetSpec3 = ASInsetLayoutSpec(insets: insets2, child: gradientNode)
                
                
                let firsOverlay = ASOverlayLayoutSpec(child: backgroundImageNode, overlay: textInsetSpec2)
                let secondOverlay = ASOverlayLayoutSpec(child: firsOverlay, overlay: textInsetSpec3)
                let thirdOverlay = ASOverlayLayoutSpec(child: secondOverlay, overlay: textInsetSpec)

        

        
        return thirdOverlay
           
       
    }
    

 
    
    func hideButtons(shouldAnimate: Bool) {
        
        
        ButtonView.moveStackView.isHidden = false
        ButtonView.controlAction.isHidden = false
        ButtonView.challengeBtn.isHidden = false
        ButtonView.shareStackView.isHidden = true
       
        ButtonView.viewStackView.isHidden = true
        ButtonView.soundLbl.isHidden = true
        ButtonView.soundBtn.isHidden = true
        ButtonView.commentStackView.isHidden = true
        ButtonView.likeStackView.isHidden = true
        
        ButtonView.controlHeight.constant = 10
        ButtonView.animationView.isHidden = false
        buttonHidden = true
        
        
        
       
        if shouldAnimate == true {

            animateBanner()
            
        }
        
        if global_isLandScape == true {
            ButtonView.shadowHeight.constant = 250
            ButtonView.challengeHeight.constant = 0
            ButtonView.botConstraint.constant = -22.5
            ButtonView.shadowBottomConstraint.constant = 0
            
            ButtonView.challengeBtn.isHidden = true
            ButtonView.moveStackView.isHidden = true
            ButtonView.commentStackView.isHidden = true
            ButtonView.viewStackView.isHidden = true
            ButtonView.shareStackView.isHidden = false
            ButtonView.likeStackView.isHidden = false
            ButtonView.soundLbl.isHidden = false
            ButtonView.soundBtn.isHidden = false
            ButtonView.animationView.isHidden = true
            
        } else {
            ButtonView.shadowHeight.constant = 100
            ButtonView.challengeHeight.constant = 80
            ButtonView.botConstraint.constant = 0
            ButtonView.shadowBottomConstraint.constant = -60
        }
        
        
        self.ButtonView.controlAction.setImage(UIImage(named: "up")?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)

    }
    
    
    
    
    func addbuttonFrame(width: Float, height: Float) {
        
        if isFeedVC == true {
            buttonListView.frame = CGRect(x: CGFloat(width) - 70, y: CGFloat(height) - 615, width: 70, height: 600)
        } else {
            buttonListView.frame = CGRect(x: CGFloat(width) - 70, y: CGFloat(height) - 635, width: 70, height: 600)
        }
        
       
        
        buttonListView.backgroundColor = UIColor.clear
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            
            self.view.addSubnode(self.buttonListView)
           // self.view.addSubview(self.buttonListView)
        }
        
        
        
    }

    // function
    
    func getThumbnailURL(post: HighlightsModel) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
           
            let urlString = "https://image.mux.com/\(id)/thumbnail.png?smartcrop&time=1"
            
            return URL(string: urlString)
            
        } else {
            
            return nil
           
        }
        
    }
    
    
    func getThumbnailAtTimeStampURL(time: TimeInterval) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
           
            let urlString = "https://image.mux.com/\(id)/thumbnail.png?time=\(time)"
            print(urlString)
            return URL(string: urlString)
            
        } else {
            
            return nil
           
        }
        
    }
    
    
    func getThumbnailVideoNodeURL(post: HighlightsModel) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
           
            let urlString = "https://image.mux.com/\(id)/thumbnail.png?time=0.025"
            
            return URL(string: urlString)
            
        } else {
            
            return nil
           
        }
        
    }

    
    func getVideoURLForRedundant_stream(post: HighlightsModel) -> URL? {
        
        if let id = post.Mux_playbackID, id != "nil" {
            
            let urlString = "https://stream.mux.com/\(id).m3u8?redundant_streams=true"
            return URL(string: urlString)
            
        } else {
            
            return nil
            
        }
        
       
    }
    
    //
    
    func setVideoProgress(rate: Float) {
        
        
        if let vc = UIViewController.currentViewController() {
            
            
            if vc is FeedVC {
                
                if let update1 = vc as? FeedVC {
                    
                    update1.playTimeBar.setProgress(rate, animated: true)
                    
                }
                
            } else if vc is UserHighlightFeedVC {
                
                if let update2 = vc as? UserHighlightFeedVC {
                    
                    update2.playTimeBar.setProgress(rate, animated: true)
                    
                }
                
                
            }
                 
            
        }
        
        
        
    }
    
    
    
    @objc func cmtTapped() {
        
        if global_isLandScape == false {
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            if post.userUID == Auth.auth().currentUser?.uid {
                
                
                
                DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_assetID", isEqualTo: post
                                                                                            .Mux_assetID!).whereField("Mux_playbackID", isEqualTo: post.Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").getDocuments {  (snap, err) in
                    
                    
                    if err != nil {
                        
                          if let vc = UIViewController.currentViewController() {
                              
                              
                              if vc is FeedVC {
                                  
                                  if let update1 = vc as? FeedVC {
                                      
                                    update1.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                      
                                  }
                                  
                              } else if vc is UserHighlightFeedVC {
                                  
                                  if let update2 = vc as? UserHighlightFeedVC {
                                      
                                    update2.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                      
                                  }
                                  
                                  
                              }
                                   
                              
                          }
                        
                        
                        return
                    }
                    
                    if snap?.isEmpty == true {
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            
                            if vc is FeedVC {
                                
                                if let update1 = vc as? FeedVC {
                                    
                                  update1.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                    
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update2 = vc as? UserHighlightFeedVC {
                                    
                                  update2.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                    
                                }
                                
                                
                            }
                                 
                            
                        }
                      
                      
                      return
                        
                    } else {
                        
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            self.videoNode.pause()
                            if vc is FeedVC {
                                
                                if let update1 = vc as? FeedVC {
                                
                                  update1.setPortrait()
                                    update1.currentItem = self.post
                                  let slideVC = CommentVC()
                                    
                                  slideVC.modalPresentationStyle = .custom
                                  slideVC.transitioningDelegate = update1.self
                                  slideVC.currentItem = self.post
                                  update1.present(slideVC, animated: true, completion: nil)
                                    
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update2 = vc as? UserHighlightFeedVC {
                                    
                                    
                                    
                                    update2.setPortrait()
                                    update2.currentItem = self.post
                                    let slideVC = CommentVC()
                                      
                                    slideVC.modalPresentationStyle = .custom
                                    slideVC.transitioningDelegate = update2.self
                                    slideVC.currentItem = self.post
                                    update2.present(slideVC, animated: true, completion: nil)
                                    
                                }
                                
                                
                            }
                                 
                            
                        }
                        
                    }
                    
                }
                
                
                
            } else {
                
                
                DataService.instance.mainFireStoreRef.collection("Highlights").whereField("Mux_assetID", isEqualTo: post
                                                                                            .Mux_assetID!).whereField("Mux_playbackID", isEqualTo: post.Mux_playbackID!).whereField("h_status", isEqualTo: "Ready").whereField("Allow_comment", isEqualTo: true).getDocuments {  (snap, err) in
                    
                    
                    if err != nil {
                        
                          if let vc = UIViewController.currentViewController() {
                              
                              
                              if vc is FeedVC {
                                  
                                  if let update1 = vc as? FeedVC {
                                      
                                    update1.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                      
                                  }
                                  
                              } else if vc is UserHighlightFeedVC {
                                  
                                  if let update2 = vc as? UserHighlightFeedVC {
                                      
                                    update2.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                      
                                  }
                                  
                                  
                              }
                                   
                              
                          }
                        
                        
                        return
                    }
                    
                    if snap?.isEmpty == true {
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            
                            if vc is FeedVC {
                                
                                if let update1 = vc as? FeedVC {
                                    
                                  update1.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                    
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update2 = vc as? UserHighlightFeedVC {
                                    
                                  update2.showErrorAlert("Oops!", msg: "Can't open the comment for this highlight right now.")
                                    
                                }
                                
                                
                            }
                                 
                            
                        }
                      
                      
                      return
                        
                    } else {
                        
                        self.videoNode.pause()
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            
                            if vc is FeedVC {
                                
                                if let update1 = vc as? FeedVC {
                                    
                                  update1.setPortrait()
                                    update1.currentItem = self.post
                                  let slideVC = CommentVC()
                                    
                                  slideVC.modalPresentationStyle = .custom
                                  slideVC.transitioningDelegate = update1.self
                                    slideVC.currentItem = self.post
                                  update1.present(slideVC, animated: true, completion: nil)
                                    
                                }
                                
                            } else if vc is UserHighlightFeedVC {
                                
                                if let update2 = vc as? UserHighlightFeedVC {
                                    
                                    update2.setPortrait()
                                    update2.currentItem = self.post
                                    let slideVC = CommentVC()
                                      
                                    slideVC.modalPresentationStyle = .custom
                                    slideVC.transitioningDelegate = update2.self
                                    slideVC.currentItem = self.post
                                    update2.present(slideVC, animated: true, completion: nil)
                                    
                                }
                                
                                
                            }
                                 
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
        }
        
        
    }
    
    // handle gesture tap
    
    @objc func likeTapped() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            DataService.instance.mainFireStoreRef.collection("Likes").document(post.highlight_id + uid).getDocument { querySnapshot, error in
                
                guard querySnapshot != nil else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if querySnapshot?.exists == false {
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.ButtonView.likeBtn.transform = self.ButtonView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
                        self.ButtonView.likeBtn.setImage(UIImage(named: "liked")!.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                        }, completion: { _ in
                          // Step 2
                          UIView.animate(withDuration: 0.1, animations: {
                              self.ButtonView.likeBtn.transform = CGAffineTransform.identity
                          })
                        })
                    
                    
                    let imgView = UIImageView()
                    imgView.image = UIImage(named: "likes pop up")
                    imgView.frame.size = CGSize(width: 70, height: 70)
                    imgView.center = self.view.center
                    self.view.addSubview(imgView)
                    
                    
                    imgView.transform = CGAffineTransform.identity
                    
                    UIView.animate(withDuration: 1) {
                        
                        imgView.alpha = 0
                        
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        if imgView.alpha == 0 {
                            
                            imgView.removeFromSuperview()
                            
                        }
                        
                    }
                    
                    self.likeCount += 1
                    
                    self.ButtonView.likeLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
                    
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                            
                          
                            ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Like-post", Highlight_Id: self.post.highlight_id, category: self.post.category)
                        
                            self.getIpInfoAndUpdateToServer(IP: string, islike: true)
                           
                        }
                        
                    }
                    
                } else {
                    
                    let id = self.post.highlight_id + uid
                    DataService.instance.mainFireStoreRef.collection("Likes").document(id).delete()
                    self.likeCount -= 1
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.ButtonView.likeBtn.transform = self.ButtonView.likeBtn.transform.scaledBy(x: 0.9, y: 0.9)
                        self.ButtonView.likeBtn.setImage(UIImage(named: "like")!.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                        }, completion: { _ in
                          // Step 2
                          UIView.animate(withDuration: 0.1, animations: {
                              self.ButtonView.likeBtn.transform = CGAffineTransform.identity
                          })
                        })
                    
                    
                    
                    self.ButtonView.likeLbl.text = "\(formatPoints(num: Double(self.likeCount)))"
                    print("Like delete")
                    
                    SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if let string = string {
                                                      
                            self.getIpInfoAndUpdateToServer(IP: string, islike: false)
                            // AWS Event
                                                     
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    
    func performHeartBeat(sender: UIButton) {
        let imageView = UIImageView(frame: self.ButtonView.likeBtn.frame)
        imageView.image = UIImage(named: "liked")
        self.ButtonView.likeBtn.addSubview(imageView)
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            imageView.transform = CGAffineTransform(scaleX: 3,y: 3)
            imageView.alpha = 0
            }) { (completed) -> Void in
                imageView.removeFromSuperview()
        }
    }
    
    
    func getIpInfoAndUpdateToServer(IP: String, islike: Bool) {
        
        let device = UIDevice().type.rawValue
        
        let data = ["Mux_playbackID": post.Mux_playbackID!, "LikerID": Auth.auth().currentUser!.uid, "ownerUID": post.userUID!, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "category": post.category!, "query": IP] as [String : Any]
        let db = DataService.instance.mainFireStoreRef.collection("Likes").document(post.highlight_id + Auth.auth().currentUser!.uid)
        
        
        
        if islike == true {
            
           
            db.setData(data)
            
          
            
        }
        
    }
    
    
    // get count IP address and update
    
    func getCountIpInformationAndUpdate(IP: String) {
        
        if Auth.auth().currentUser != nil {
            
            let device = UIDevice().type.rawValue
           
            let data = ["Mux_playbackID": post.Mux_playbackID!, "ViewerID": Auth.auth().currentUser!.uid, "ownerUID": post.userUID!, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "category": post.category!, "Item_id": post.highlight_id!, "is_processed": false, "query": IP] as [String : Any]
            
            let db = DataService.instance.mainFireStoreRef.collection("H_Views").document(post.highlight_id + Auth.auth().currentUser!.uid)
            let dbs = DataService.instance.mainFireStoreRef.collection("Views")
            
            db.getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if !snapshot.exists {
                    
                    db.setData(data) { err in
                        if err != nil {
                            print(err!.localizedDescription)
                            return
                        }
                    }
                    
                }
            }
            
            
            
            dbs.addDocument(data: data) { err in
                
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                
                self.viewCount += 1
                
            }
            
         
        } else {
            print("Nil user or same user")
        }
         
        
    }
    // load info
    
    func gameInfoSetting(post: HighlightsModel, Dview: DetailView) {
        
        Dview.avatarImg.contentMode = .scaleAspectFill
        
        if self.post.userUID == Auth.auth().currentUser?.uid {
            
            if global_avatar_url != "", global_username != "" {
                
                
                Dview.usernameLbl.text = "\(global_username.lowercased())"
                
                
                asyncImage(Dview: Dview, url: global_avatar_url)
                
               
                
                loadStreamLink(Dview: Dview)
                
                
                
            } else {
                
                self.loadInfo(uid: post.userUID, Dview: Dview)
                
            }
            
        } else {
            
            
            self.loadInfo(uid: post.userUID, Dview: Dview)
            
        }
        
      
        self.getLogo(category: post.category, Dview: Dview)
        

        // date
        let date = post.post_time.dateValue()
        let time = timeAgoSinceDate(date, numericDates: true)
        


        let finalTime = NSMutableAttributedString()
        
        //
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = UIImage(named: "time")!
        image1Attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
        let image1String = NSAttributedString(attachment: image1Attachment)
        
        finalTime.append(image1String)
        finalTime.append(NSAttributedString(string: " \(time)"))
        
       
      
        
        if post.highlight_title != "nil" {
            Dview.titleLbl.text = post.highlight_title
        } else {
            Dview.titleLbl.text = "Add comment ..."
        }
        
        
    }
    
    func asyncImage(Dview: DetailView, url: String) {
        
        
        imageStorage.async.object(forKey: url) { result in
            if case .value(let image) = result {
                                
            DispatchQueue.main.async { // Make sure you're on the main thread here
                                    
                                    
                Dview.avatarImg.image = image
                
                                    
            }
                                
            } else {
                                
                                
              AF.request(url).responseImage { response in
                                    
                                    
                 switch response.result {
                        case let .success(value):
                            Dview.avatarImg.image = value
                            try? imageStorage.setObject(value, forKey: url, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                        
                         case let .failure(error):
                             print(error)
                        }
                                    
                                    
                                    
                }
                                
           }

        }
        
    }
    
    @objc func updateTimeStamp() {
        
        if DetailViews != nil {
            
            let date = post.post_time.dateValue()
            let time = timeAgoSinceDate(date, numericDates: true)
            


            let finalTime = NSMutableAttributedString()
            
            //
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(named: "time")!
            image1Attachment.bounds = CGRect(x: 0, y: -1, width: 12, height: 12)
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            finalTime.append(image1String)
            finalTime.append(NSAttributedString(string: " \(time)"))
            
            //DetailViews.dateLbl.attributedText = finalTime
            
        }
        
        
        
        
    }
    
    func loadInfo(uid: String, Dview: DetailView) {
        
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let username = item["username"] as? String {
                        
                        //
                        
                        Dview.usernameLbl.text = "\(username.lowercased())"
                        
                        if let avatarUrl = item["avatarUrl"] as? String {
                            
                            self.asyncImage(Dview: Dview, url: avatarUrl)
                            
                          
                            
                        }
                        

                    }
                    
                    self.loadStreamLink(Dview: Dview)
                    
                    
                }
                
                
            } else {
                
                self.animatedLabel = MarqueeLabel.init(frame: Dview.streamLinkLbl.layer.bounds, rate: 30.0, fadeLength: 10.0)
                //Dview.streamLinkLbl.text = "Current stream link will go here"
                
                
                self.animatedLabel.backgroundColor = UIColor.clear
                self.animatedLabel.type = .continuous
                self.animatedLabel.leadingBuffer = 20.0
                self.animatedLabel.trailingBuffer = 10.0
                self.animatedLabel.animationDelay = 0.0
                self.animatedLabel.textAlignment = .center
                self.animatedLabel.font = UIFont(name:"Roboto-Regular",size: 11)!
                self.animatedLabel.textColor = UIColor.white
                
                self.animatedLabel.text = "https://dual.live/                                                    "
                
                Dview.streamLinkLbl.addSubview(self.animatedLabel)
                
            }
            
            
        }
       
      
    }
    
    func loadStreamLink(Dview: DetailView) {
        
       
        
        animatedLabel = MarqueeLabel.init(frame: Dview.streamLinkLbl.layer.bounds, rate: 30.0, fadeLength: 10.0)
        Dview.streamLinkLbl.addSubview(animatedLabel)
        //Dview.streamLinkLbl.text = "Current stream link will go here"
        
        
        animatedLabel.backgroundColor = UIColor.clear
        animatedLabel.type = .continuous
        animatedLabel.leadingBuffer = 20.0
        animatedLabel.trailingBuffer = 10.0
        animatedLabel.animationDelay = 0.0
        animatedLabel.textAlignment = .center
        animatedLabel.font = UIFont(name:"Roboto-Regular",size: 11)!
        animatedLabel.textColor = UIColor.white
        
    

        if post.stream_link != "nil", post.stream_link != "" {

            if let text = post.stream_link {
                
                guard let requestUrl = URL(string: text) else {
                    return
                }
                
                if let domain = requestUrl.host {
                
                    if domain == "dualteam.page.link" {
                        
                        animatedLabel.text = "Tap to see the next video                                              "
                        
                    } else {
                        
                        animatedLabel.text = "\(text)                                              "
                        
                    }
                    
                } else {
                    
                    animatedLabel.text = "\(text)                                              "
                    
                }
                
                
            } else {
                
                if post.userUID == Auth.auth().currentUser?.uid {
                    
                    animatedLabel.text = "Share your channel link here                                    "
                    
                } else {
                                                        
                    animatedLabel.text = "https://dual.live/                                                "
                    
                }
                
            }

        } else  {
            
            if post.userUID == Auth.auth().currentUser?.uid {
                
                animatedLabel.text = "Share your channel link here                                        "
                
            } else {
                                                    
                animatedLabel.text = "https://dual.live/                                                    "
                
            }
        }
                     
    }
    
    
    func getLogo(category: String, Dview: DetailView) {
        
        if Dview.gameLbl != nil {
          
            
            Dview.gameLbl.text = category
            
        }
        
    }
    
    
    // like count
    
    
    func likeCount(Dview: ButtonViews) {
        
        DataService.instance.mainFireStoreRef.collection("Likes").whereField("Mux_playbackID", isEqualTo: post.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                
                Dview.likeLbl.text = "0"
                self.ButtonView.likeBtn.setImage(UIImage(named: "like")!.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
                    self.likeCount = querySnapshot!.count
                   
                    Dview.likeLbl.text = "\(formatPoints(num: Double(cnt)))"
                    self.checkifUserLike(Dview: Dview)
                    
                }
                
            }
                
            
        }
        
    
    }
    
    func viewCount(Dview: ButtonViews) {
        
        DataService.instance.mainFireStoreRef.collection("Views").whereField("Mux_playbackID", isEqualTo: post.Mux_playbackID!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
               
                Dview.viewLbl.text = "0"
                
                
            } else {
                
                if let cnt = querySnapshot?.count {
                    
        
                    self.viewCount = cnt
                    Dview.viewLbl.text = "\(formatPoints(num: Double(cnt)))"
                   
                    
                }
                
            }
                
            
        }
        
    }
    
    func checkifUserLike(Dview: ButtonViews) {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.instance.mainFireStoreRef.collection("Likes").document(post.highlight_id + uid).getDocument { querySnapshot, error in
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    self.ButtonView.likeBtn.setImage(UIImage(named: "liked")!.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                    
                } else {
                    
                    
                    self.ButtonView.likeBtn.setImage(UIImage(named: "like")!.resize(targetSize: CGSize(width: 40, height: 40)), for: .normal)
                    
                }

                
                
            }
            
        }
        
    
    }
    
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        
        currentTimeStamp = timeInterval
        
        setVideoProgress(rate: Float(timeInterval/(videoNode.currentItem?.asset.duration.seconds)!))
    
        if (videoNode.currentItem?.asset.duration.seconds)! <= 15 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.8 {
                
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
               
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 15, (videoNode.currentItem?.asset.duration.seconds)! <= 30 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.7 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 30, (videoNode.currentItem?.asset.duration.seconds)! <= 60 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.6 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 60 , (videoNode.currentItem?.asset.duration.seconds)! <= 90 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 90, (videoNode.currentItem?.asset.duration.seconds)! <= 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.4 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        } else if (videoNode.currentItem?.asset.duration.seconds)! > 120 {
            
            if timeInterval/(videoNode.currentItem?.asset.duration.seconds)! >= 0.5 {
                if shouldCountView {
                    shouldCountView = false
                    endVideo()
                }
            }
            
        }
        
        
    }
    
    // view count
    
    func cmtCount(Dview: ButtonViews) {
        
        DataService.instance.mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: post.Mux_playbackID!).whereField("cmt_status", isEqualTo: "valid").getDocuments{ querySnapshot, error in
                    
   
                    guard querySnapshot != nil else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if querySnapshot?.isEmpty == true {
                        
                      
                        Dview.commentLbl.text = "0"
                        
                    } else {
                        
                        if let count = querySnapshot?.count {
                            
                            self.cmtCount = count
                            Dview.commentLbl.text = "\(formatPoints(num: Double(count)))"
                            
                        }
                        
                    }
                    
                }
        
        
        
    }
    
    func animateBanner() {
        
        
        if self.gameTimer != nil {
            self.gameTimer?.invalidate()
            isAnimating = false
        }
    
        startAnimating()
        
        
    }
    
    @objc func startAnimating() {
        
        if isAnimating == false {
            
            self.gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(PostNode.startAnimating), userInfo: nil, repeats: true)
            
            isAnimating = true
        }
        
        if global_isLandScape == true {
            self.gameTimer?.invalidate()
            isAnimating = false
        } else {
            if currentAnimating == "" {
                currentAnimating = "Like"
                ButtonView.animationTxt.text = "\(formatPoints(num: Double(likeCount)))"
                ButtonView.animationImg.image = ButtonView.likeBtn.imageView?.image
            } else if currentAnimating == "Like" {
                currentAnimating = "View"
                ButtonView.animationTxt.text = "\(formatPoints(num: Double(viewCount)))"
                ButtonView.animationImg.image = ButtonView.viewBtn.imageView?.image
            } else if currentAnimating == "View" {
                currentAnimating = "Comment"
                ButtonView.animationTxt.text = "\(formatPoints(num: Double(cmtCount)))"
                ButtonView.animationImg.image = ButtonView.commentBtn.imageView?.image
            } else if currentAnimating == "Comment" {
                currentAnimating = "Like"
                ButtonView.animationTxt.text = "\(formatPoints(num: Double(likeCount)))"
                ButtonView.animationImg.image = ButtonView.likeBtn.imageView?.image
            }
        }
      
    }
     
    
    //check challenge enable
    
    func checkChallenge(Dview: ButtonViews) {
        
        Dview.challengeBtn.addTarget(self, action: #selector(PostNode.challengeBtnPressed), for: .touchUpInside)
        
        if Auth.auth().currentUser?.uid == post.userUID {
        
            is_challenge = false
            
            
        } else {
            
            checkIfChalleneEnable(Dview: Dview)
            
        }
        
    }
    
    func checkIfChalleneEnable(Dview: ButtonViews) {
        
        
        DataService.init().mainFireStoreRef.collection("Users").document(post.userUID!).getDocument {  querySnapshot, error in
            guard let snapshot = querySnapshot else {
                
                print("Error fetching snapshots: \(error!)")
                self.is_challenge = false
                

                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let challengeStatus = item["ChallengeStatus"] as? Bool {
                        
                        if challengeStatus == true {
                            
                            Dview.challengeBtn.beat()
                            
                            self.is_challenge = true
                            
                        } else {
                            
                            self.is_challenge = false
                            
                        }
                        
                    } else {
                        
                        self.is_challenge = false
                        
                    }
                    
                    
                }
                
                
            } else {
                
                self.is_challenge = false
                
            }
            
            
        }
        
    }
    
    func didTap(_ videoNode: ASVideoNode) {
        
    
        
        
        if videoNode.isPlaying() {
            
           
            videoNode.pause()
            
            
            
            let imgView = UIImageView()
            imgView.image = UIImage(named: "Pause")
            imgView.frame.size = CGSize(width: 100, height: 100)
            imgView.center = self.view.center
            self.view.addSubview(imgView)
            
            
            imgView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 1) {
                
                imgView.alpha = 0
                
            }
            
        } else {
         
            
            videoNode.play()
            
            let imgView = UIImageView()
            imgView.image = UIImage(named: "Play-1")
            imgView.frame.size = CGSize(width: 100, height: 100)
            imgView.center = self.view.center
            self.view.addSubview(imgView)
            
            
            imgView.transform = CGAffineTransform.identity
            
            UIView.animate(withDuration: 1) {
                
                imgView.alpha = 0
                
            }
            
         
        }
      
    }
    
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
    
        shouldCountView = true
        key_dict[post.highlight_id] = NSDate().timeIntervalSince1970
        
    }
     
    @objc func endVideo() {
        
        if Auth.auth().currentUser?.uid != nil {
            
            time += 1
            
            if time < 2 {
                
                last_view_timestamp = NSDate().timeIntervalSince1970
                isViewed = true
                
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let string = string {
                        
                        self.getCountIpInformationAndUpdate(IP: string)
                       
                    }
                }
                
            }
            
            if time > 5, already_chatList == false {
                already_chatList = true
                addToAvailableChatList(uid: [self.post.userUID])
            }
            
            
        }
        
        
    }
    
    // button list
    
    @objc func settingBtnPressed(sender: AnyObject!) {
        
        if global_isLandScape == false {
            
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let profile = UIAlertAction(title: "Copy profile", style: .default) { (alert) in
                
                
                if let id = self.post.userUID {
                    
                    let link = "https://dualteam.page.link/dual?up=\(id)"
                    
                    UIPasteboard.general.string = link
                    showNote(text: "User profile link is copied")
                    
                }
                
                
            }
            
            let post = UIAlertAction(title: "Copy post", style: .default) { (alert) in
                
                if let id = self.post.highlight_id {
                   
                    let link = "https://dualteam.page.link/dual?p=\(id)"
                    
                    UIPasteboard.general.string = link
                    showNote(text: "Post link is copied")
                    
                }
                
            }
            
          
            let report = UIAlertAction(title: "Report this post", style: .destructive) { (alert) in
                
                self.reportPressed()
                
                
            }
            
            let block = UIAlertAction(title: "Block", style: .destructive) { (alert) in
                
                self.confirmBlock()
                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                
            }
            
              
            
            if self.post.userUID != Auth.auth().currentUser?.uid {
                
                //sheet.addAction(reload)
                sheet.addAction(profile)
                sheet.addAction(post)
                sheet.addAction(report)
                sheet.addAction(block)
                sheet.addAction(cancel)
                
                
            } else {
                
                //sheet.addAction(reload)
                sheet.addAction(profile)
                sheet.addAction(post)
                sheet.addAction(cancel)
                
            }
            
            
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is FeedVC {
                    
                    if let update1 = vc as? FeedVC {
                        
                        update1.present(sheet, animated: true, completion: nil)
                        
                    }
                    
                } else if vc is UserHighlightFeedVC {
                    
                    if let update2 = vc as? UserHighlightFeedVC {
                        
                        update2.present(sheet, animated: true, completion: nil)
                        
                    }
                }
                
            }
            
        } else {
            
            if longpressing == false {
                
                longpressing = true
                
                delay(1) {
                    self.longpressing = false
                }
                
                if DetailViews.isHidden == true {
                    DetailViews.isHidden = false
                    ButtonView.isHidden = false
                    gradientNode.isHidden = false
                    
                    
                    if let vc = UIViewController.currentViewController() {
                        
                        
                        if vc is FeedVC {
                            
                            if let update1 = vc as? FeedVC {
                                
                                update1.playTimeBar.isHidden = false
                                
                            }
                            
                        } else if vc is UserHighlightFeedVC {
                            
                            if let update2 = vc as? UserHighlightFeedVC {
                                
                                update2.playTimeBar.isHidden = false
                                
                            }
                            
                            
                        }
                             
                        
                    }
                    
                    
                    
                } else {
                    DetailViews.isHidden = true
                    ButtonView.isHidden = true
                    gradientNode.isHidden = true
                    
                    
                    if let vc = UIViewController.currentViewController() {
                        
                        
                        if vc is FeedVC {
                            
                            if let update1 = vc as? FeedVC {
                                
                                update1.playTimeBar.isHidden = true
                                
                            }
                            
                        } else if vc is UserHighlightFeedVC {
                            
                            if let update2 = vc as? UserHighlightFeedVC {
                                
                                update2.playTimeBar.isHidden = true
                                
                            }
                            
                            
                        }
                             
                        
                    }
                    
                    
                }
                
            }
            
        }
        
           
    }
    
    func reportPressed() {
        
        if let vc = UIViewController.currentViewController() {
            
            
            if vc is FeedVC {
                
                if let update1 = vc as? FeedVC {
                    
                    let slideVC = reportView()
                    
                    slideVC.video_report = true
                    slideVC.highlight_id = self.post.highlight_id
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self

                    update1.present(slideVC, animated: true, completion: nil)
                    
                }
                
            } else if vc is UserHighlightFeedVC {
                
                if let update2 = vc as? UserHighlightFeedVC {
                    
                    let slideVC = reportView()
                    
                    slideVC.video_report = true
                    slideVC.highlight_id = self.post.highlight_id
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update2.self

                    update2.present(slideVC, animated: true, completion: nil)
                    
                }
                
                
            }
                 
            
        }
        
    }
    
    func confirmBlock() {
        
        if let getUsername = DetailViews.usernameLbl.text {
            
            let alert = UIAlertController(title: "Are you sure to block \(getUsername)!", message: "If you confirm to block, you can always unblock \(getUsername) from your block list any time.", preferredStyle: UIAlertController.Style.actionSheet)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Block", style: UIAlertAction.Style.destructive, handler: { action in
                
                self.initBlock(uid: self.post.userUID)
        
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

            // show the alert
            
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is FeedVC {
                    
                    if let update1 = vc as? FeedVC {
                        
                        update1.present(alert, animated: true, completion: nil)
                        
                    }
                    
                } else if vc is UserHighlightFeedVC {
                    
                    if let update2 = vc as? UserHighlightFeedVC {
                        
                        

                        update2.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    
                }
                     
                
            }
            
            
        }
        
        
        
    }
    
    func initBlock(uid: String) {
        
        
        SBDMain.blockUserId(uid) { blockedUser, error in
            
            if error != nil {
                
                
                if let vc = UIViewController.currentViewController() {
                    
                    
                    if vc is FeedVC {
                        
                        if let update1 = vc as? FeedVC {
                            
                            update1.showErrorAlert("Oops!", msg: "User can't be blocked now due to internal error from our SB system, please try again")
                            
                        }
                        
                    } else if vc is UserHighlightFeedVC {
                        
                        if let update2 = vc as? UserHighlightFeedVC {
                            
                            

                            update2.showErrorAlert("Oops!", msg: "User can't be blocked now due to internal error from our SB system, please try again")
                            
                        }
                        
                        
                    }
                         
                    
                }
                //self.showErrorAlert("Oops!", msg: "User can't be blocked now due to internal error from our SB system, please try again")
                
            } else {
                
                self.removeFollowFromCurrentUser(uid: self.post.userUID)
                self.removeFollowFromUID(uid: self.post.userUID)
                self.addToBlockList(uid: self.post.userUID)
             
            }
            
        }
        

        
    }
    
    func removeFollowFromCurrentUser(uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Following_uid", isEqualTo: uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Follow").document(id).delete()
                    
                    
                }
                
            }
            
        }
        
        
    }
    
    
    func removeFollowFromUID(uid: String) {
        
        
        DataService.instance.mainFireStoreRef.collection("Follow").whereField("Follower_uid", isEqualTo: uid).whereField("Following_uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snap, err) in
            
            if err != nil {
                
                print(err!.localizedDescription)
                return
            }
                
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    let id = item.documentID
                    DataService.instance.mainFireStoreRef.collection("Follow").document(id).delete()
                    
                    
                }
                
                
            }
            
        }
        
    }
    
    func addToBlockList(uid: String) {
        
        
        DataService.init().mainFireStoreRef.collection("Block").whereField("User_uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("Block_uid", isEqualTo: uid).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty == true {
                
                self.addToList(uid: self.post.userUID)
                
            }
                
            
        }
             
   
    }
    
    func addToList(uid: String) {
        
        
        let db = DataService.init().mainFireStoreRef.collection("Block")
        
        let data = ["User_uid": Auth.auth().currentUser!.uid as Any, "Block_uid": uid as Any, "block_time": FieldValue.serverTimestamp()]
        
        db.addDocument(data: data) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
        }
        
    }
    

    
    @objc func cardBtnPressed(sender: AnyObject!) {
  
        cardBtn?(self)
  
        
    }
    
    @objc func shareBtnPressed(sender: AnyObject!) {
  
        shareBtn?(self)
  
        
    }
    
    @objc func challengeBtnPressed(sender: AnyObject!) {
  
        challengeBtn?(self)
  
        
    }

    @objc func streamLinkBtnPressed(sender: AnyObject!) {
  
        linkBtn?(self)
  
    
    }
    
    @objc func userProfileBtnPressed(sender: AnyObject!) {
  
        profileBtn?(self)
  
    }
    
    @objc func viewBtnPressed(sender: AnyObject!) {
  
        viewBtn?(self)
  
    }
    
   

    
}

extension PostNode {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
    
    
        DetailViews.collectionView.delegate = dataSourceDelegate
        DetailViews.collectionView.dataSource = dataSourceDelegate
        DetailViews.collectionView.tag = row
        DetailViews.collectionView.setContentOffset(DetailViews.collectionView.contentOffset, animated:true) // Stops collection view if it was scrolling.
        DetailViews.collectionView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
        DetailViews.collectionView.reloadData()
        
    }

}
