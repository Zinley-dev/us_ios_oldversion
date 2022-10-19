//
//  HighlightVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/7/20.
//

import UIKit
import Alamofire
import AlamofireImage
import MarqueeLabel
import PixelSDK
import PhotosUI
import Firebase
import SwiftPublicIP
import SCLAlertView

class HighlightVC: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var dismiss1: UIButton!
    @IBOutlet weak var dismiss2: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var postBtn: UIButton!
    
    @IBOutlet weak var categoryInput: UITextField!
    
    var itemList = [AddModel]()
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var hashTagTxtField: UITextField!
    @IBOutlet weak var isComment: UISwitch!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    @IBOutlet weak var soundText: UILabel!
    @IBOutlet weak var highlightTitle: UITextField!
    @IBOutlet weak var checkImg: UIImageView!
    @IBOutlet weak var HighlightName: UILabel!
    @IBOutlet weak var HighlightImg: UIImageView!
   
    @IBOutlet weak var creatorLink: UITextField!
    
   
    var isUpdateLayout = false
    var isNickNameTxtField = false
    var new_category = ""
    var new_category_fullname = ""
    var duration: Double!
    //
    var selectedVideo: SessionVideo!
    var exportedURL: URL!
    var mode: String!
    var music: String!
    var isAllowComment: Bool!
    var isReportingPlayer: Bool!
    var Htitle: String!
    var StreamLink: String!
    
    var item: AddModel!
    var animatedLabel: MarqueeLabel!
    var region: String!
    var length: Double!
    var origin_width: CGFloat!
    var origin_height: CGFloat!
    @IBOutlet weak var categoryBtn: UIButton!
    
    var dayPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        HighlightName.text = item.short_name
        
        if item.short_name == "Others" {
            
            self.HighlightImg.image = UIImage(named: "more")
            
        } else {
            
            if item.url != "" {
                
                
                
                imageStorage.async.object(forKey: item.url) {  result in
                    if case .value(let image) = result {
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here

                            self.HighlightImg.image = image

                        }
                        
                    } else {
            
                        AF.request(self.item.url).responseImage {  response in
                                   
                            switch response.result {
                            case let .success(value):
                                self.HighlightImg.image = value
                                try? imageStorage.setObject(value, forKey: self.item.url)
                            case let .failure(error):
                                print(error)
                            }
                             
                        }
                        
                    }
                    
                }
                
                
            } else {
                
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
       
        
        highlightTitle.delegate = self
        highlightTitle.borderStyle = .none
        creatorLink.borderStyle = .none
        hashTagTxtField.borderStyle = .none
        
        // default setting
        music = "Original sound"
        isAllowComment = true
        isComment.setOn(true, animated: false)
        
        //
      
        hashTagTxtField.delegate = self
        creatorLink.delegate = self
       
        
        loadProfile()
        loadLastMode()
        loadLastLink()
        new_category = self.item.short_name
        new_category_fullname = self.item.name
        //
        
        self.hideKeyboardWhenTappedAround()
        categoryBtn.setTitle("", for: .normal)
        
        self.dayPicker.delegate = self
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasAlertContentBefore") == false {
            
            categoryAlert()
            
        }
        
    
    }
    
    func categoryAlert() {
        
        let userDefaults = UserDefaults.standard
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont.systemFont(ofSize: 17, weight: .medium),
            kTextFont: UIFont.systemFont(ofSize: 15, weight: .regular),
            kButtonFont: UIFont.systemFont(ofSize: 15, weight: .medium),
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
      
        let alert = SCLAlertView(appearance: appearance)
        
        
        _ = alert.addButton("Agree") {
            
            userDefaults.set(true, forKey: "hasAlertContentBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults
          
            showNote(text: "Thank you and enjoy Dual!")
            
        }
        
        _ = alert.addButton("Disagree") {
            
            showNote(text: "Thank you and feel feel free to enjoy other videos at Dual!")
            self.dismiss(animated: true)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
            
            
        }
        

        let icon = UIImage(named:"logo123")
        
        
        
        _ = alert.showCustom("Hello \(global_username),", subTitle: "Dual is a gaming social network, we require all users to post only related gaming content. In order to protect our community, you will get a permanent ban even for a first-time violation. You have to pick the right category of gaming content because you can't modify it later. If you choose to disagree, you can't post content but feel free to enjoy other videos at Dual.", color: UIColor.black, icon: icon!)
       
    }
    
    func createDayPicker() {

        categoryInput.inputView = dayPicker

    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField == hashTagTxtField {
            
            if let text = textField.text, text != "" {
                
                print(getCurrentSearchHashTag(text: text))
                
            }
            
        }
        
    }
    
    func getCurrentSearchHashTag(text: String) -> String {
        let mentionText = text.findMHashtagText()
        print("***RUi***: getCurrentSearchHashTag\nMentionText: \(mentionText)")
        
        
        if !text.findMHashtagText().isEmpty {
            
            let res = text.findMHashtagText()[text.findMHashtagText().count - 1]
            
            print("***RUi***: findMentionText: \(res)")
            
            return res
            
        } else {
            return ""
        }
        
        
    }
        

    func loadProfile() {
        
        if let uid = Auth.auth().currentUser?.uid {
            
            DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                if snapshot.exists {
                    
                    if let item = snapshot.data() {
                        
                        if let username = item["username"] as? String {
                        
                            self.soundText.text = ""
                            self.animatedLabel = MarqueeLabel.init(frame: CGRect(x: self.soundText.layer.bounds.minX, y: self.soundText.layer.bounds.minY + 10, width: self.soundText.layer.bounds.width, height: 16.0), rate: 60.0, fadeLength: 10.0)
                            self.animatedLabel.type = .continuous
                            self.animatedLabel.leadingBuffer = 20.0
                            self.animatedLabel.trailingBuffer = 10.0
                            self.animatedLabel.animationDelay = 0.0
                            self.animatedLabel.textAlignment = .center
                            self.animatedLabel.font = UIFont.systemFont(ofSize: 13)
                            self.animatedLabel.text = "Original sound - \(username)                                            "
                            self.animatedLabel.textColor = UIColor.white
                           
                            self.soundText.addSubview(self.animatedLabel)
                            
                           

                        }
                        
                    }
                    
                    
                }
                
                
                
            }
           
            
        }
        
  
    }
    
    
    
    func loadLastLink() {

        DataService.instance.mainRealTimeDataBaseRef.child("Last_link").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {  (snapData) in
                     
            if snapData.exists() {
                
                if let dict = snapData.value as? Dictionary<String, Any> {
                    
                    if let SavedLink = dict["stream_link"] as? String {
                        
                        if SavedLink != "nil" {
                            
                            self.creatorLink.text = SavedLink
                            
                        }
                    }
                }
     
            }
            
        })
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == hashTagTxtField {
            
            isUpdateLayout = true
            
            
        }  else {
            
            isUpdateLayout = false
            
        }
        
    }
    
    
    func loadLastMode() {
        
        
        DataService.instance.mainRealTimeDataBaseRef.child("Last_mode").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: {  (snapData) in
            
            
            if snapData.exists() {
                
                if let dict = snapData.value as? Dictionary<String, Any> {
                    
                    if let SavedMode = dict["mode"] as? String {
     
                        if SavedMode == "Public" {
                            
                            self.mode = SavedMode
                            
                            self.publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                            self.FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            self.OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        } else if SavedMode == "Followers" {
                            
                            self.mode = SavedMode
                            
                            self.FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
                            self.publicBtn.setImage(UIImage(named: "public"), for: .normal)
                            self.OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        } else if SavedMode == "Only me" {
                            
                            self.mode = SavedMode
                            
                            self.OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
                            self.FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            self.publicBtn.setImage(UIImage(named: "public"), for: .normal)
                            
                        } else {
                            
                            self.mode = "Public"
                            
                            // defaults mode
                            
                            self.publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                            self.FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                            self.OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                            
                        }
                        
                    }
                    
                }
                
            } else {
         
                self.mode = "Public"
                
                // defaults mode
                
                self.publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
                self.FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
                self.OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
                
            }
            
        })
        
    }
    

 
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func isCommentBtnPressed(_ sender: Any) {
        
        if isAllowComment == true {
                  
            isAllowComment =  false
            isComment.setOn(false, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
            
        } else {
            
            isAllowComment = true
            isComment.setOn(true, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
        }
        
        
    }
    // mode choose
    
    @IBAction func PublicBtnPressed(_ sender: Any) {
        
        publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Public"
    }
    
    
    @IBAction func FriendsBtnPressed(_ sender: Any) {
        
        FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
        
        
        mode = "Followers"
        
    }
    
    @IBAction func OnlyMeBtnPressed(_ sender: Any) {
        
        OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
        FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
        publicBtn.setImage(UIImage(named: "public"), for: .normal)
        
        mode = "Only me"
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        view.endEditing(true)
        return false
    }
    
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
            
       
        
        
        let container = ContainerController(modes: [.library, .video])
        
       
        
        container.editControllerDelegate = self
        container.libraryController.previewCropController.maxRatioForPortraitMedia = CGSize(width: 1, height: .max)
        container.libraryController.previewCropController.maxRatioForLandscapeMedia = CGSize(width: .max, height: 1)
        container.libraryController.previewCropController.defaultsToAspectFillForPortraitMedia = false
        container.libraryController.previewCropController.defaultsToAspectFillForLandscapeMedia = false
      
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        // Include only videos from the users drafts
        container.libraryController.draftMediaTypes = [.video]
        
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
       

    }
 
    
    func exportVideo(video: SessionVideo, completed: @escaping DownloadComplete) {
        
        VideoExporter.shared.export(video: video, progress: { progress in
            DispatchQueue.main.async {
                self.swiftLoader(progress: "Exporting: \(String(format:"%.2f", Float(progress) * 100))%")
            }
        }, completion: {  error in
            if let error = error {
                
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                }
                
                print("Unable to export video: \(error)")
                self.showErrorAlert("Ops!", msg: "Unable to export video: \(error)")
                    return
            }
                    
            self.exportedURL = video.exportedVideoURL
            
            self.origin_width = video.renderSize.width
            self.origin_height = video.renderSize.height
            self.length = video.duration.seconds
        
                   
                   
            completed()
         
        })
        
       
        
        
    }
    
    
    // upload video to firebase
    
    func uploadVideo(url: URL) {
           
        let data = try! Data(contentsOf: url)
        let metaData = StorageMetadata()
        let vidUID = UUID().uuidString
        metaData.contentType = "video/mp4"
        let uploadUrl = DataService.instance.mainStorageRef.child(item.name).child(vidUID)
        
        //
        self.dismiss(animated: true, completion: nil)
        
        let uploadTask = uploadUrl.putData(data , metadata: metaData) { (metaData, err) in
            
            if err != nil {
                
                global_percentComplete = 0.00
                self.showErrorAlert("Oops!", msg: "We're having trouble veriying your authentication to upload videos, please try to logout and login again to fix the issue.")
                return
            }
                
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print("Uploading progress: \(percentComplete)")
            
            global_percentComplete = percentComplete
            
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateProgressBar")), object: nil)
            
        }
        
        uploadTask.observe(.failure) { snapshot in
            
            uploadTask.cancel()
            
        }
        
         
        uploadTask.observe(.success) { snapshot in
          // Upload completed successfully
            
            uploadUrl.downloadURL(completion: {  (url, err) in
    
                 guard let Url = url?.absoluteString else { return }
                 
                 let downUrl = Url as String
                 let downloadUrl = downUrl as NSString
                 let downloadedUrl = downloadUrl as String
                 let device = UIDevice().type.rawValue
                 
                 // put in firestore here
                      
                var higlightVideo = [String: Any]()
                
                var update_hashtaglist = [String]()
                
                if self.hashTagTxtField.text?.findMHashtagText().isEmpty == true {
                    higlightVideo = ["category": self.new_category as Any, "url": downloadedUrl as Any, "h_status": "Pending" as Any, "userUID": Auth.auth().currentUser!.uid as Any, "post_time": FieldValue.serverTimestamp() , "mode": self.mode as Any, "music": self.music as Any, "Mux_processed": false, "Mux_playbackID": "nil", "Allow_comment": self.isAllowComment!, "highlight_title": self.Htitle!, "stream_link": self.StreamLink!,"length": self.length!, "Device": device, "AWS": false, "updatedTimeStamp": FieldValue.serverTimestamp(), "current_view": 0, "is_hashtaged": false, "origin_width": self.origin_width!, "origin_height": self.origin_height!, "isTitleCmt": false, "username": global_username, "owner_documentID": Auth.auth().currentUser!.uid, "languageCode": Locale.current.languageCode!]
                    
                    update_hashtaglist = ["#\(global_username)", "#\(self.new_category)"]
                    
                    if self.new_category_fullname != "Others", self.new_category_fullname != "General" {
                        self.new_category_fullname = self.new_category_fullname.components(separatedBy: .whitespacesAndNewlines).joined()
                        update_hashtaglist.append("#\(self.new_category_fullname)")
                    }
                    
                    
                    
                    higlightVideo.updateValue(update_hashtaglist, forKey: "hashtag_list")
                    
                } else {
                    
                    update_hashtaglist = self.hashTagTxtField.text!.findMHashtagText()
                    
                    if !update_hashtaglist.contains("#\(global_username)") {
                        update_hashtaglist.insert("#\(global_username)", at: 0)
                    }
                    
                    if !update_hashtaglist.contains("#\(self.new_category)") {
                        update_hashtaglist.insert("#\(self.new_category)", at: 0)
                    }
                    
                    
                    if self.new_category_fullname != "Others", self.new_category_fullname != "General" {
                        self.new_category_fullname = self.new_category_fullname.components(separatedBy: .whitespacesAndNewlines).joined()
                        if !update_hashtaglist.contains("#\(self.new_category_fullname)") {
                            update_hashtaglist.insert("#\(self.new_category_fullname)", at: 0)
                        }
                        
                    }
                    
                    higlightVideo = ["category": self.new_category as Any, "url": downloadedUrl as Any, "h_status": "Pending" as Any, "userUID": Auth.auth().currentUser!.uid as Any, "post_time": FieldValue.serverTimestamp() , "mode": self.mode as Any, "music": self.music as Any, "Mux_processed": false, "Mux_playbackID": "nil", "Allow_comment": self.isAllowComment!, "highlight_title": self.Htitle!, "stream_link": self.StreamLink!,"length": self.length!, "Device": device, "AWS": false, "updatedTimeStamp": FieldValue.serverTimestamp(), "hashtag_list": update_hashtaglist, "current_view": 0, "is_hashtaged": true, "origin_width": self.origin_width!, "origin_height": self.origin_height!, "isTitleCmt": false, "owner_documentID": Auth.auth().currentUser!.uid, "languageCode": Locale.current.languageCode!]
                }
                
                
                
                if global_username != "" {
                    higlightVideo.updateValue(global_username, forKey: "username")
                }
                
              
                
                if self.origin_width!/self.origin_height! >= 1.5 {
                    higlightVideo.updateValue("Landscape", forKey: "content_mode")
                } else if self.origin_height! == self.origin_width!  {
                    higlightVideo.updateValue("Square", forKey: "content_mode")
                } else {
                    higlightVideo.updateValue("Portrait", forKey: "content_mode")
                }
                
                
                SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let string = string {
                          
                        higlightVideo.updateValue((string), forKey: "query")
                        self.writeToDb(higlightVideo: higlightVideo, downloadedUrl: downloadedUrl)
                        
                        // update last mode
                        
                        DispatchQueue.main.async {
                            self.upload_hashtag_collection(update_hashtaglist: update_hashtaglist)
                            self.update_unique_hashtag_collection(update_hashtaglist: update_hashtaglist)
                        }
                        

                    }
                }
                            
             })
            
        }
        
    }
    
    func writeToDb(higlightVideo: [String: Any], downloadedUrl: String) {
        
        // update last mode
        DataService.instance.mainRealTimeDataBaseRef.child("Last_mode").child(Auth.auth().currentUser!.uid).setValue(["mode": self.mode as Any])
        DataService.instance.mainRealTimeDataBaseRef.child("Last_link").child(Auth.auth().currentUser!.uid).setValue(["stream_link": self.StreamLink as Any])
        
        let db = DataService.instance.mainFireStoreRef.collection("Highlights")
         
        var id: DocumentReference!
        
        id = db.addDocument(data: higlightVideo) { error in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                
    
                ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Create", Highlight_Id: id.documentID, category: higlightVideo["category"] as! String)
               
                self.update_most_play_list(id: id.documentID)
                print("Finished writting")
                
            }
        }

       
    }
    
    
    
    
    func update_most_play_list(id: String) {
        
        let mostPlayed_hist = ["userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": new_category, "type": "Highlight", "HighlightID": id]
        
        DataService.instance.mainFireStoreRef.collection("MostPlayed_history").addDocument(data: mostPlayed_hist)
        
    }
    
  
    
    func upload_hashtag_collection(update_hashtaglist: [String]) {
        
        if !update_hashtaglist.isEmpty {
            
            
            for hashtag in update_hashtaglist {
                
                if hashtag != "#" {
                    
                    let hashtag_dict = ["hashtag": hashtag as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": self.item.name as Any]
                    
                    DataService.instance.mainFireStoreRef.collection("Hashtags").addDocument(data: hashtag_dict)
                    
                }
                
                
            }
            
            
        }
        
        
    }
    
    
    func update_unique_hashtag_collection(update_hashtaglist: [String]) {
        
        if !update_hashtaglist.isEmpty {
                    
            for hashtag in update_hashtaglist {
                
                DataService.instance.mainFireStoreRef.collection("Unique_hashtags").whereField("hashtag", isEqualTo: hashtag).getDocuments { querySnapshot, error in
                             
                    guard querySnapshot != nil else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if querySnapshot?.isEmpty == true {
                        
                        
                        if hashtag != "#" {
                            
                            let hashtag_dict = ["hashtag": hashtag as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": self.item.name as Any]
                            
                            DataService.instance.mainFireStoreRef.collection("Unique_hashtags").addDocument(data: hashtag_dict)
                            
                        }
                        
                    }
                }
                        
            }
            
            
        }
        
        
    }
    
    
    @IBAction func hashTagTap(_ sender: Any) {
        
        isUpdateLayout.toggle()
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddHashtagsViewController") as? AddHashtagsViewController {
            
            vc.text = self.hashTagTxtField.text
            vc.modalPresentationStyle = .fullScreen
            
            vc.completionHandler = { text in
                           
                self.hashTagTxtField.text = text
            }
            
            present(vc, animated: true)
            
            
        }
        
        
    }
    
    @IBAction func changeGameBtnPressed(_ sender: Any) {
        
        createDayPicker()
        categoryInput.becomeFirstResponder()
        
    }
    
    
  
    
    @IBAction func postBtnPressed(_ sender: Any) {
        

        if selectedVideo != nil {
            
            self.postBtn.isEnabled = false
            
            if creatorLink.text != "" {
                
                
                if verifyUrl(urlString: creatorLink.text) != true {
                    
                    creatorLink.text = ""
                    self.postBtn.isEnabled = true
                    self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct it.")
                    return
                    
                } else {
                    
                    
                    
                    if let urlString = creatorLink.text {
                        
                        if let url = URL(string: urlString) {
                            
                            if let domain = url.host {
                                
                                if check_Url(host: domain) == true {
                                    
                                    
                                    if self.selectedVideo.duration.seconds > 3.0 {
                                        
                                        postVideo()
                                        
                                    } else {
                                        
                                        self.postBtn.isEnabled = true
                                        self.showErrorAlert("Oops!", msg: "Please upload a video with a duration is longer than 3 seconds.")
                                        
                                    }
                                    
                                    
                                } else {
                                    
                                    creatorLink.text = ""
                                    self.postBtn.isEnabled = true
                                    streamError()
                                    return
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                    
                    
                }
             
            } else {
                
                
                if self.selectedVideo.duration.seconds > 5.0 {
                    
                    postVideo()
                    
                } else {
                    
                    self.postBtn.isEnabled = true
                    self.showErrorAlert("Oops!", msg: "Please upload a video with a duration is longer than 5 seconds.")
                }
                    
             
                
            }

            
        } else {
            
            
            self.showErrorAlert("Oops!", msg: "Please upload or record your highlight")
            
        }

    }
    
    func streamError() {
        
        let alert = UIAlertController(title: "Oops!", message: "Your current streaming link isn't supported now, do you want to view available streaming link list ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            let slideVC =  steamingListVC()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            
            
            self.present(slideVC, animated: true, completion: nil)
            
            
        }))

        self.present(alert, animated: true)
        
        
    }
    
    func postVideo() {
        
        if let title = highlightTitle.text, title != "" {
            
            Htitle = title
        } else {
            
            Htitle = "nil"
            
        }
        
        if let link = creatorLink.text, link != "" {
            
            StreamLink = link
            
        } else {
            
            StreamLink = "nil"
        }
 
        Dispatch.background {

            print("Start exporting")
            self.exportVideo(video: self.selectedVideo){
                            
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "Thank you, your video is being uploaded!")
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
                   
                }

                    
                print("Start uploading")
                self.uploadVideo(url: self.exportedURL)
                                               
            }
                        
        }
    
        
    }
    
    
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                    
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
 
    }
  
    
}

extension HighlightVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        if let video = session.video {
            
            selectedVideo = video
            let img = UIImage(named: "wtick")
            checkImg.image = img
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
}

extension HighlightVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return itemList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if let name = itemList[row].name {
            pickerLabel?.text = name
        } else {
            pickerLabel?.text = "Error loading"
        }
        
        
        
     
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if itemList[row].name != nil {
                  
            HighlightName.text = itemList[row].short_name
           
            new_category = itemList[row].short_name
            new_category_fullname = itemList[row].name
            
            
            if itemList[row].short_name == "Others" {
                self.HighlightImg.image = UIImage(named: "more")
            } else {
                
                self.HighlightImg.image = UIImage(named: itemList[row].short_name)
                
             
            }
            
            //
            
            
        }
    
        
    }
    
    
}

