//
//  VideoInformationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit
import AlamofireImage
import Alamofire
import Firebase
import SCLAlertView

class VideoInformationVC: UIViewController, UITextFieldDelegate {
    
    var current_hashtag = [String]()

    @IBOutlet weak var titleLbl: UITextField!
    @IBOutlet weak var creatorLinkLbl: UITextField!
    @IBOutlet weak var isComment: UISwitch!
    
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var hashtagTxtField: UITextField!
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var FriendsBtn: UIButton!
    @IBOutlet weak var OnlyMeBtn: UIButton!
    
    var add_list = [AddModel]()
    var isUpdateLayout = false
    
    @IBOutlet weak var removeCurrentHashtagBtn: UIButton!
    
    var mode: String!
    var comment_allow: Bool!
    var selectedItem: HighlightsModel!
    
    
    var dayPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleLbl.delegate = self
        creatorLinkLbl.delegate = self
        titleLbl.borderStyle = .none
        creatorLinkLbl.borderStyle = .none
        hashtagTxtField.borderStyle = .none
        
        
        if selectedItem.highlight_title != "nil" {
            
            titleLbl.text = selectedItem.highlight_title
            
        }
        
        
        if selectedItem.stream_link != "nil" {
            
            creatorLinkLbl.text = selectedItem.stream_link
            
        }
        
        
        if selectedItem.Allow_comment == true {
            
            isComment.setOn(true, animated: true)
            
        } else{
            
            isComment.setOn(false, animated: true)
            
        }
        
        
        if selectedItem.mode == "Public" {
            
            publicBtn.setImage(UIImage(named: "SelectedPublic"), for: .normal)
            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
            
            
        } else if selectedItem.mode == "Followers" {
            
            FriendsBtn.setImage(UIImage(named: "selectedFriends"), for: .normal)
            publicBtn.setImage(UIImage(named: "public"), for: .normal)
            OnlyMeBtn.setImage(UIImage(named: "profile"), for: .normal)
            
            
        } else if selectedItem.mode == "Only me" {
            
            OnlyMeBtn.setImage(UIImage(named: "SelectedOnlyMe"), for: .normal)
            FriendsBtn.setImage(UIImage(named: "friends"), for: .normal)
            publicBtn.setImage(UIImage(named: "public"), for: .normal)
                   
        }
        
        
        if !selectedItem.hashtag_list.isEmpty {
            
            removeCurrentHashtagBtn.isHidden = false
            
        }
        
        
        if let category = selectedItem.category {
            
            
            categoryLbl.text = category
            
            
            if category == "Others" {
                
                self.categoryImg.image = UIImage(named: "more")
                
            } else {
                
                self.categoryImg.image = UIImage(named: category)
                
                
            }
            
            //loadImg(category: category)
           
            
        }
       
        
        if !selectedItem.hashtag_list.isEmpty {
            
            current_hashtag = selectedItem.hashtag_list
            let string = selectedItem.hashtag_list.joined(separator: "")
            hashtagTxtField.text = string
             
        }
        
       
        
     
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return false
    }
    
  
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == hashtagTxtField {
            
            isUpdateLayout = true
                   
            
        } else {
            
            isUpdateLayout = false
            
        }
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func isReportingPlayerBtnPressed(_ sender: Any) {
        
      
        
    }
    //
    
    func loadImg(category: String) {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Support_game").whereField("short_name", isEqualTo: category)
            .getDocuments{  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                for item in snapshot.documents {
                    
                    let i = item.data()
                    let item = AddModel(postKey: item.documentID, Game_model: i)
                    
                    if let url = item.url, url != "" {
                    
                        imageStorage.async.object(forKey: url) { result in
                            if case .value(let image) = result {
                                
                                DispatchQueue.main.async { // Make sure you're on the main thread here
                                    
                                    self.categoryImg.image = image
                                  
                                }
                                
                            } else {
                                
                             AF.request(item.url).responseImage { response in
                                    
                                    
                                    switch response.result {
                                    case let .success(value):
                                        self.categoryImg.image = value
                                        try? imageStorage.setObject(value, forKey: url)
                                    case let .failure(error):
                                        print(error)
                                    }
                                    
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                     
                    }
                    
                    
            }
            
        }
        
    }
    
    
    
    func addImgFromList(category: String) {
        
        
        
        let item = global_add_list[findIndex(category: category)]
        
        imageStorage.async.object(forKey: item.url) {  result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async { // Make sure you're on the main thread here

                    self.categoryImg.image = image

                }
                
            } else {
    
                AF.request(item.url).responseImage { response in
                           
                    switch response.result {
                    case let .success(value):
                        self.categoryImg.image = value
                        try? imageStorage.setObject(value, forKey: item.url)
                    case let .failure(error):
                        print(error)
                    }
                     
                }
                
            }
            
        }
        
        
    }
    
    
    func findIndex(category: String) -> Int {
        var count = 0
        
        for item in global_add_list {
            
            if item.name == category {
                
                return count
            }
            
            count+=1
            
        }
        
        return count
        
    }
    
    
    @IBAction func isCommentBtnPressed(_ sender: Any) {
        
        if comment_allow == true {
            
            
            comment_allow =  false
            isComment.setOn(false, animated: true)
            
            
            
            
        } else if comment_allow == false {
            
            comment_allow = true
            isComment.setOn(true, animated: true)
            
           
            
        } else {
            
            
            if selectedItem.Allow_comment == true {
                
                comment_allow =  false
                isComment.setOn(false, animated: true)
                
                
            } else {
                
                
                comment_allow = true
                isComment.setOn(true, animated: true)
                
                
            }
            
            
        }
        
        
    }
    

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func updateCommenTitle(highlight_title: String) {
        
        
        DataService.init().mainFireStoreRef.collection("Comments").whereField("Mux_playbackID", isEqualTo: selectedItem.Mux_playbackID!).whereField("Comment_uid", isEqualTo: selectedItem.userUID!).whereField("is_title", isEqualTo: true).getDocuments {   querySnapshot, error in
            
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                
                for items in querySnapshot!.documents {
                    
                    
                    DataService.init().mainFireStoreRef.collection("Comments").document(items.documentID).updateData(["text": highlight_title, "last_modified": FieldValue.serverTimestamp()])
                    
                }
                
                
            } else {
                
                let db = DataService.instance.mainFireStoreRef.collection("Comments")
                let device = UIDevice().type.rawValue
               
                
                let data = ["Comment_uid": self.selectedItem.userUID!, "timeStamp": FieldValue.serverTimestamp(), "text": highlight_title, "cmt_status": "valid", "isReply": false, "Mux_playbackID": self.selectedItem.Mux_playbackID!, "root_id": "nil", "has_reply": false, "update_timestamp": FieldValue.serverTimestamp(), "is_title": true, "Device": device, "last_modified": FieldValue.serverTimestamp(), "owner_uid": self.selectedItem.userUID!] as [String : Any]
                
                       
                db.addDocument(data: data) { (errors) in
                    
                    if errors != nil {
                        
                       
                        print(errors!.localizedDescription)
                        return
                        
                    }
                    
                  
                    
                }
                
                
            }
            
        }
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        
        if titleLbl.text != "" || creatorLinkLbl.text != "" || mode != nil || comment_allow != nil || hashtagTxtField.text != "" {
            
            print("Updating")
            
            var updateData = [String: Any]()
            
            if creatorLinkLbl.text != "" {
                

                if verifyUrl(urlString: creatorLinkLbl.text) != true {
                    
                    creatorLinkLbl.text = ""
                    self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct it.")
                    return
                    
                } else {
                    
                    
                    
                    if let urlString = creatorLinkLbl.text {
                        
                        if let url = URL(string: urlString) {
                            
                            if let domain = url.host {
                                
                                if check_Url(host: domain) == true {
                                    
                                    if titleLbl.text != "" {
                                                    
                                                    updateData.updateValue(titleLbl.text!, forKey: "highlight_title")
                                                    
                                                    // update comment title if have
                                                    updateCommenTitle(highlight_title: titleLbl.text!)
                                                    
                                                } else {
                                                    
                                                    // delete cmt lbl
                                                    
                                                    
                                                }
                                                
                                                if creatorLinkLbl.text != "" {
                                                    
                                                    
                                                    if verifyUrl(urlString: creatorLinkLbl.text) != true {
                                                        
                                                        creatorLinkLbl.text = ""
                                                        self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct it.")
                                                        return
                                                        
                                                    } else {
                                                        
                                                        
                                                        
                                                        if let urlString = creatorLinkLbl.text {
                                                            
                                                            if let url = URL(string: urlString) {
                                                                
                                                                if let domain = url.host {
                                                                    
                                                                    if check_Url(host: domain) == true {
                                                                        
                                                                        updateData.updateValue(creatorLinkLbl.text!, forKey: "stream_link")
                                                                        
                                                                    } else {
                                                                        
                                                                        creatorLinkLbl.text = ""
                                                                        streamError()
                                                                        return
                                                                        
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                        
                                                    }
                                                    
                                               
                                                    
                                                }
                                                
                                                if self.mode != nil {
                                                    
                                                    updateData.updateValue(self.mode!, forKey: "mode")
                                                    
                                                }
                                                
                                                if self.comment_allow != nil {

                                                    updateData.updateValue(self.comment_allow!, forKey: "Allow_comment")
                                                    
                                                }
                                                   
                                                
                                                if let hashtag_text = hashtagTxtField.text, hashtag_text != "" {
                                                    
                                                    if !hashtag_text.findMHashtagText().isEmpty {
                                                        
                                                        var update_hashtaglist = hashtag_text.findMHashtagText()
                                                        
                                                        if let category = selectedItem.category {
                                                            
                                                            if !update_hashtaglist.contains("#\(category)") {
                                                                update_hashtaglist.insert("#\(category)", at: 0)
                                                            }
                                                            
                                                        }
                                                       
                                                        
                                                        if !update_hashtaglist.contains("#\(global_username)") {
                                                            update_hashtaglist.insert("#\(global_username)", at: 0)
                                                        }
                                                        
                                                        
                                                        updateData.updateValue(update_hashtaglist, forKey: "hashtag_list")
                                                        updateData.updateValue(true, forKey: "is_hashtaged")
                                                        
                                                        let arr = update_hashtaglist.difference(from: current_hashtag)
                                                        
                                                        if !arr.isEmpty {
                                                            
                                                            self.upload_hashtag_collection(hashtag_arr: arr)
                                                            self.update_unique_hashtag_collection(hashtag_arr: arr)
                                                            
                                                        }
                                                        
                                                   
                                                    }

                                                }
                                                
                                                
                                                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                                                db.document(selectedItem.highlight_id).updateData(updateData)
                                                ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Update", Highlight_Id: selectedItem.highlight_id, category: selectedItem.category)
                                                
                                                
                                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                    
                                    
                                    
                                } else {
                                    
                                    creatorLinkLbl.text = ""
                                    streamError()
                                    return
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                    
                    
                }

                    
                
                
            } else {
                
                if titleLbl.text != "" {
                    
                    updateData.updateValue(titleLbl.text!, forKey: "highlight_title")
                    
                    // update comment title if have
                    updateCommenTitle(highlight_title: titleLbl.text!)
                    
                } else {
                    
                    // delete cmt lbl
                    
                    
                }
                
                if creatorLinkLbl.text != "" {
                    
                    
                    if verifyUrl(urlString: creatorLinkLbl.text) != true {
                        
                        creatorLinkLbl.text = ""
                        self.showErrorAlert("Oops!", msg: "Seem like it's not a valid url, please correct it.")
                        return
                        
                    } else {
                        
                        
                        
                        if let urlString = creatorLinkLbl.text {
                            
                            if let url = URL(string: urlString) {
                                
                                if let domain = url.host {
                                    
                                    if check_Url(host: domain) == true {
                                        
                                        updateData.updateValue(creatorLinkLbl.text!, forKey: "stream_link")
                                        
                                    } else {
                                        
                                        creatorLinkLbl.text = ""
                                        streamError()
                                        return
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
               
                    
                }
                
                if self.mode != nil {
                    
                    updateData.updateValue(self.mode!, forKey: "mode")
                    
                }
                
                if self.comment_allow != nil {

                    updateData.updateValue(self.comment_allow!, forKey: "Allow_comment")
                    
                }
                   
                
                if let hashtag_text = hashtagTxtField.text, hashtag_text != "" {
                    
                    if !hashtag_text.findMHashtagText().isEmpty {
                        
                        var update_hashtaglist = hashtag_text.findMHashtagText()
                        
                        if let category = selectedItem.category {
                            
                            if !update_hashtaglist.contains("#\(category)") {
                                update_hashtaglist.insert("#\(category)", at: 0)
                            }
                            
                        }
                       
                        
                        if !update_hashtaglist.contains("#\(global_username)") {
                            update_hashtaglist.insert("#\(global_username)", at: 0)
                        }
                        
                        
                        updateData.updateValue(update_hashtaglist, forKey: "hashtag_list")
                        updateData.updateValue(true, forKey: "is_hashtaged")
                        
                        let arr = update_hashtaglist.difference(from: current_hashtag)
                        
                        if !arr.isEmpty {
                            
                            self.upload_hashtag_collection(hashtag_arr: arr)
                            self.update_unique_hashtag_collection(hashtag_arr: arr)
                            
                        }
                        
                   
                    }

                }
                
                
                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                db.document(selectedItem.highlight_id).updateData(updateData)
                ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Update", Highlight_Id: selectedItem.highlight_id, category: selectedItem.category)
                
                
                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                
                
                
            }
            
            
        } else {
            
            print("Nothing changes")
            
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
    
    
    func upload_hashtag_collection(hashtag_arr: [String]) {
        
        if !hashtag_arr.isEmpty {
            
            
            for hashtag in hashtag_arr {
                
                let hashtag_dict = ["hashtag": hashtag as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": self.selectedItem.category as Any]
                
               
                
           
                
                DataService.instance.mainFireStoreRef.collection("Hashtags").addDocument(data: hashtag_dict)
                
            }
            
            
        }
        
        
    }
    
    func update_unique_hashtag_collection(hashtag_arr: [String]) {
        
        if !hashtag_arr.isEmpty {
                    
            for hashtag in hashtag_arr {
                
                
                DataService.instance.mainFireStoreRef.collection("Unique_hashtags").whereField("hashtag", isEqualTo: hashtag).getDocuments { querySnapshot, error in
                             
                    guard querySnapshot != nil else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if querySnapshot?.isEmpty == true {
                        
                        
                        let hashtag_dict = ["hashtag": hashtag as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "category": self.selectedItem.category as Any]
                
                        
                        DataService.instance.mainFireStoreRef.collection("Unique_hashtags").addDocument(data: hashtag_dict)
                        
                    }
                }
                        
            }
            
            
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        isUpdateLayout.toggle()
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddHashtagsViewController") as? AddHashtagsViewController {
            
            vc.text = self.hashtagTxtField.text
            vc.modalPresentationStyle = .fullScreen
            
            vc.completionHandler = { text in
                self.hashtagTxtField.text = text
            }
            
            present(vc, animated: true)
            
            
        }
        
        
        
    }
    

    @IBAction func removeCurrentHashtagBtnPressed(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Are you sure to delete all hashtags for this video !", message: "If you confirm to remove, all hashtags will be removed immediately and this action can't be undo. Your category and your username will still be default hashtags.", preferredStyle: UIAlertController.Style.actionSheet)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in

            if let id = self.selectedItem.highlight_id, let category = self.selectedItem.category {
                
                DataService.instance.mainFireStoreRef.collection("Highlights").document(id).updateData(["hashtag_list": FieldValue.delete()])
                DataService.instance.mainFireStoreRef.collection("Highlights").document(id).updateData(["hashtag_list": ["#\(category)", "#\(global_username)"]])
                self.removeCurrentHashtagBtn.isHidden = true
                self.hashtagTxtField.text = "#\(category)#\(global_username)"
                
            }
           
            
                
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    

    
    
    
}

