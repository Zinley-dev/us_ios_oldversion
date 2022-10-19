//
//  TutorialVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/15/21.
//

import UIKit
import AsyncDisplayKit

class TutorialVC: UIViewController {

    @IBOutlet weak var descLbl: UITextView!
    @IBOutlet weak var tutorialImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var circleView1: circleView!
    @IBOutlet weak var circleView2: circleView!
    @IBOutlet weak var circleView3: circleView!
    @IBOutlet weak var circleView4: circleView!
    @IBOutlet weak var circleView5: circleView!
    
    @IBOutlet weak var finalBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var stackViewBtn: UIStackView!
    
    var tutorial_list = [tutorialModel]()
    var current_rank = 0
    var imageNode = ASNetworkImageNode()
    let videoNode = ASVideoNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadTutorialList()
        
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = false
        videoNode.muted = true
        videoNode.gravity =  AVLayerVideoGravity.resizeAspect.rawValue
        
    }
    
    func loadTutorialList() {
        
        let db = DataService.instance.mainFireStoreRef
      
        
        db.collection("Tutorial").order(by: "rank", descending: false).getDocuments {  querySnapshot, error in
         
             guard let snapshot = querySnapshot else {
                 print("Error fetching snapshots: \(error!)")
                 return
             }
         
         if !snapshot.isEmpty {
             
             for item in snapshot.documents {
                
                let tutorial = tutorialModel(postKey: item.documentID, tutorialModel: item.data())
                self.tutorial_list.append(tutorial)
                
             }
            
            
            self.loadFirstTutorial()
            
            //
            
            
            
            
         }
        
       }
        
        
        
    }
    
    func loadFirstTutorial() {
        
        videoNode.pause()
        videoNode.removeFromSupernode()
        imageNode.isHidden = false
       
        circleView1.backgroundColor = UIColor.lightGray
        circleView2.backgroundColor = UIColor.white
        circleView3.backgroundColor = UIColor.white
        circleView4.backgroundColor = UIColor.white
        circleView5.backgroundColor = UIColor.white
        //
        
        titleLbl.text = tutorial_list[0].title
        descLbl.text = tutorial_list[0].description
        
        //
        
        stackViewBtn.isHidden = true
        finalBtn.isHidden = false
        finalBtn.setTitle("Let's start", for: .normal)
        
        //
        
        if let url = tutorial_list[0].url, url != "" {
            
            
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: url)
            imageNode.frame = tutorialImg.layer.bounds
            tutorialImg.image = nil
            
            imageNode.removeFromSupernode()
            tutorialImg.addSubnode(imageNode)
            
        }
        
        
      
        current_rank = 1
    }
    
    func loadsecondTutorial() {
        
        imageNode.isHidden = true
        imageNode.removeFromSupernode()
        
        circleView1.backgroundColor = UIColor.white
        circleView2.backgroundColor = UIColor.lightGray
        circleView3.backgroundColor = UIColor.white
        circleView4.backgroundColor = UIColor.white
        circleView5.backgroundColor = UIColor.white
        //
        
        titleLbl.text = tutorial_list[1].title
        descLbl.text = tutorial_list[1].description
        
        //
        
        stackViewBtn.isHidden = false
        finalBtn.isHidden = true
        finalBtn.setTitle("Let's start", for: .normal)
        
        //
            
        if let url = tutorial_list[1].url, url != "" {
            
            
            
            videoNode.frame = tutorialImg.layer.bounds
            tutorialImg.image = nil
            
            DispatchQueue.main.async {
                self.videoNode.asset = nil
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(link: url)!)
            }
            
            videoNode.removeFromSupernode()
            tutorialImg.addSubnode(videoNode)
            videoNode.play()
          
            
        }
        
        current_rank = 2
      
        
    }
    
    func loadThirdTutorial() {
        
        videoNode.pause()
        imageNode.isHidden = true
        
        circleView1.backgroundColor = UIColor.white
        circleView2.backgroundColor = UIColor.white
        circleView3.backgroundColor = UIColor.lightGray
        circleView4.backgroundColor = UIColor.white
        circleView5.backgroundColor = UIColor.white
        //
        
        titleLbl.text = tutorial_list[2].title
        descLbl.text = tutorial_list[2].description
        
        //
        
        stackViewBtn.isHidden = false
        finalBtn.isHidden = true
        finalBtn.setTitle("Let's start", for: .normal)
        
        //
        
        if let url = tutorial_list[2].url, url != "" {
            
            videoNode.frame = tutorialImg.layer.bounds
            tutorialImg.image = nil
            
            DispatchQueue.main.async {
                self.videoNode.asset = nil
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(link: url)!)
            }
            
            videoNode.removeFromSupernode()
            tutorialImg.addSubnode(videoNode)
            videoNode.play()
            
        }
        
        current_rank = 3
      
        
    }
    
    func loadFourthTutorial() {
        
        videoNode.pause()
        imageNode.isHidden = true
       
        
        circleView1.backgroundColor = UIColor.white
        circleView2.backgroundColor = UIColor.white
        circleView3.backgroundColor = UIColor.white
        circleView4.backgroundColor = UIColor.lightGray
        circleView5.backgroundColor = UIColor.white
        //
        
        titleLbl.text = tutorial_list[3].title
        descLbl.text = tutorial_list[3].description
        
        //
        
        stackViewBtn.isHidden = false
        finalBtn.isHidden = true
        finalBtn.setTitle("Let's start", for: .normal)
      
        //
        
        if let url = tutorial_list[3].url, url != "" {
            
            videoNode.frame = tutorialImg.layer.bounds
            tutorialImg.image = nil
            
            DispatchQueue.main.async {
                self.videoNode.asset = nil
                self.videoNode.asset = AVAsset(url: self.getVideoURLForRedundant_stream(link: url)!)
            }
            
            videoNode.removeFromSupernode()
            tutorialImg.addSubnode(videoNode)
            videoNode.play()
           
            
        }
        
        current_rank = 4
        
    }
    
    func loadLastTutorial() {
        
        videoNode.pause()
        videoNode.removeFromSupernode()
        imageNode.isHidden = false
        
        circleView1.backgroundColor = UIColor.white
        circleView2.backgroundColor = UIColor.white
        circleView3.backgroundColor = UIColor.white
        circleView4.backgroundColor = UIColor.white
        circleView5.backgroundColor = UIColor.lightGray
        //
        
        titleLbl.text = tutorial_list[4].title
        descLbl.text = tutorial_list[4].description
        
        //
        
        stackViewBtn.isHidden = true
        finalBtn.isHidden = false
        finalBtn.setTitle("Let's get in", for: .normal)
      
        //
        
        if let url = tutorial_list[4].url, url != "" {
            
            
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: url)
            imageNode.frame = tutorialImg.layer.bounds
            tutorialImg.image = nil
            
            imageNode.removeFromSupernode()
            tutorialImg.addSubnode(imageNode)
            
        }
        
        current_rank = 5
        
    }
    
    
    func getVideoURLForRedundant_stream(link: String) -> URL? {
        
        return URL(string: link)
        
    }
    
    
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if current_rank == 2 {
            
            loadThirdTutorial()
            
        } else if current_rank == 3 {
            
            loadFourthTutorial()
            
        } else if current_rank == 4 {
            
            loadLastTutorial()
            
        }
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        if current_rank == 2 {
            
            loadFirstTutorial()
            
        } else if current_rank == 3 {
            
            loadsecondTutorial()
            
        } else if current_rank == 4 {
            
            loadThirdTutorial()
            
        }
        
    }
    
    @IBAction func finalBtnPressed(_ sender: Any) {
        
        
        if finalBtn.titleLabel?.text == "Let's get in" {
            
            self.performSegue(withIdentifier: "moveToMainVC2", sender: nil)
            
        } else {
            
            loadsecondTutorial()
            
        }
        
    }
    
    
}
