//
//  ContactUsVC.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/24/21.
//

import UIKit
import Firebase
import MobileCoreServices
import AVKit
import AVFoundation
import Alamofire
import SwiftPublicIP

class ContactUsVC: UIViewController, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var ContactTxtView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reportPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var characterCountLbl: UILabel!
    
    var reportImg = [UIImage]()
    var reportUrl = [String]()
    var selectedIndex: Int!
    var selectedImg: UIImage!
    var isObserved: Bool!
    
    var count = 0
    var total = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ContactTxtView.delegate = self
        ContactTxtView.text = "Tell us about your issues!"
        reportPhotoHeight.constant = 0
        
        // delegate
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
    
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              
            let keyboardHeight = keyboardSize.height
            
            bottomConstraint.constant = keyboardHeight
               
                
               
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
        
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 50

        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isObserved == false {
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
            
            
        }
        
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if ContactTxtView.text == "Tell us about your issues!" {
            
            ContactTxtView.text = ""
            
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if ContactTxtView.text == "" {
            
            ContactTxtView.text = "Tell us about your issues!"
            
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if ContactTxtView.text != "Tell us about your issues!", ContactTxtView.text != "" {
            
            sendBtn.isHidden = false
            characterCountLbl.text = "\(ContactTxtView.text.count) characters"
            
        } else {
            
            sendBtn.isHidden = true
            characterCountLbl.text = ""
            
            
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportImg.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactUsImageCell", for: indexPath) as? ContactUsImageCell {
            
            //cell.btn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            let img = reportImg[indexPath.row]
            cell.closeBtn.tag = indexPath.row
            cell.closeBtn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            cell.configureCell(img: img)
            return cell
            
        } else {
            
            
            return UICollectionViewCell()
            
        }
        
    }
    
    @objc func buttonSelected(sender: UIButton) {
        
        
        reportImg.remove(at: sender.tag)
        if reportImg.isEmpty {
            reportPhotoHeight.constant = 0
        } else {
            reportPhotoHeight.constant = 80
        }
        
        //
        self.collectionView.reloadData()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedImg = reportImg[indexPath.row]
        selectedIndex = indexPath.row
 
        isObserved = true
        
        self.performSegue(withIdentifier: "moveToPhotoVC", sender: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactUsVC.DeleteImg), name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        
    }
    
    
    @objc func DeleteImg() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        isObserved = false
        if let index = selectedIndex {
            
            
            reportImg.remove(at: index)
            if reportImg.isEmpty {
                reportPhotoHeight.constant = 0
            } else {
                reportPhotoHeight.constant = 80
            }
            self.collectionView.reloadData()
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToPhotoVC"{
            if let destination = segue.destination as? PhotoVC
            {
                
                destination.selectedImg = self.selectedImg
               
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 80, height: 80)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return 10.0
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }

    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    
    @IBAction func reportPhotoBtnPressed(_ sender: Any) {
        
        self.album()
        
        
    }
    
    
    func album() {
        
        self.getMediaFrom(kUTTypeImage as String)
       
    }
    
    func camera() {
        
        self.getMediaCamera(kUTTypeImage as String)
        
    }
    
    // get media
    
    func getMediaFrom(_ type: String) {
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaCamera(_ type: String) {
           
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String] //UIImagePickerController.availableMediaTypes(for: .camera)!
        mediaPicker.sourceType = .camera
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    func getImage(image: UIImage) {
        
        reportImg.append(image)
        reportPhotoHeight.constant = 80.0
        collectionView.reloadData()
        
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        if ContactTxtView.text != "Tell us about your issues!", ContactTxtView.text.count > 35 {
            
            //
            
            if reportImg.isEmpty {
                
                sendSupportWithoutImage(Message: ContactTxtView.text)
                
                
            } else {
                
                sendSupportWithImage(Message: ContactTxtView.text)
                
                
            }
            
            
        } else {
            
            showErrorAlert("Oops!", msg: "Please tell us your issues and provide us more than 35 characters description.")
            
        }
        
    }
    
    
    func sendSupportWithImage(Message: String) {
        
        
        total = reportImg.count
        
        swiftLoader(text: "Uploading image 1")
        
        
        for item in reportImg {
        
            uploadImg(img: item, Message: Message)
            
        }
        
        
    }
    
    
    func uploadImg(img: UIImage, Message: String) {
        
        let metaData = StorageMetadata()
        let imageUID = UUID().uuidString
        metaData.contentType = "image/jpeg"
        var imgData = Data()
        imgData = img.jpegData(compressionQuality: 1.0)!
        
        
         
        DataService.instance.supportStorageRef.child(imageUID).putData(imgData, metadata: metaData) { (meta, err) in
            
            if err != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: "Error while saving your image, please try again")
                print(err?.localizedDescription as Any)
                
            } else {
                
                DataService.instance.supportStorageRef.child(imageUID).downloadURL(completion: { (url, err) in
               
                    guard let Url = url?.absoluteString else { return }
                    
                    let downUrl = Url as String
                    let downloadUrl = downUrl as NSString
                    let downloadedUrl = downloadUrl as String
                    
                    self.reportUrl.append(downloadedUrl)
                    self.count += 1
                    
                    if self.count == self.total {
                        
                        let data = ["userUID": Auth.auth().currentUser!.uid, "Message": Message, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue, "photo_list": self.reportUrl] as [String : Any]
                        
                        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
                            if let error = error {
                                
                                print(error.localizedDescription)
                                DataService.instance.mainFireStoreRef.collection("Contact_us").addDocument(data: data)
                                
                            } else if let string = string {
                                
                                var updateData = data
                                updateData.updateValue(string, forKey: "query")
                                DataService.instance.mainFireStoreRef.collection("Contact_us").addDocument(data: updateData)
                                
                            }
                            
                            
                            DataService.init().mainFireStoreRef.collection("Contact_us").getDocuments {  querySnapshot, error in
                                    
                                    
                                if querySnapshot?.isEmpty == true {
                                    
                                    self.sendEmail2(text: Message, id: "0", photoUrl: self.reportUrl, Device: UIDevice().type.rawValue)
                                    
                                } else {
                                    
                                    self.sendEmail2(text: Message, id: String(querySnapshot!.count), photoUrl: self.reportUrl, Device: UIDevice().type.rawValue)
                                    
                                }
                                        
                            
                            }
                            
                            DispatchQueue.main.async {
                                
                                SwiftLoader.hide()
                                self.dismiss(animated: true, completion: nil)
                                showNote(text: "Message sent")
                            }
                            
                                
                        }
                        
                    } else {
                        
                        self.swiftLoader(text: "Uploading image \(self.count)")
                        
                    }
                    
                    
                })
                      
                
            }
            
            
        }
        
        
    }
    
    
    func sendSupportWithoutImage(Message: String) {
        
        
        let data = ["userUID": Auth.auth().currentUser!.uid, "Message": Message, "timeStamp": FieldValue.serverTimestamp(), "Device": UIDevice().type.rawValue] as [String : Any]
        
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) { (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                DataService.instance.mainFireStoreRef.collection("Contact_us").addDocument(data: data)
                
            } else if let string = string {
                
                var updateData = data
                updateData.updateValue(string, forKey: "query")
                DataService.instance.mainFireStoreRef.collection("Contact_us").addDocument(data: updateData)
                
            }
            
            
            DataService.init().mainFireStoreRef.collection("Contact_us").getDocuments { querySnapshot, error in
                    
                    
                if querySnapshot?.isEmpty == true {
                    
                    self.sendEmail1(text: Message, id: "0", Device: UIDevice().type.rawValue)
                    
                } else {
                    
                    self.sendEmail1(text: Message, id: String(querySnapshot!.count), Device: UIDevice().type.rawValue)
                    
                }
                        
            
            }
            
            DispatchQueue.main.async {
                
                
                self.dismiss(animated: true, completion: nil)
                showNote(text: "Message sent")
            }
            
                
        }
        
        
    }
    
    func sendEmail1(text: String, id: String, Device: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("email-send1")
        
        
        AF.request(urls!, method: .post, parameters: [
            
            "userUID": Auth.auth().currentUser!.uid,
            "text": text,
            "id": id,
            "Device": Device
            
        ])
        .validate(statusCode: 200..<500)
        
        
    }
    
    func sendEmail2(text: String, id: String, photoUrl: [String], Device: String) {
        
        let url = MainAPIClient.shared.baseURLString
        let urls = URL(string: url!)?.appendingPathComponent("email-send2")
        
        
        AF.request(urls!, method: .post, parameters: [
            
            
            "userUID": Auth.auth().currentUser!.uid,
            "text": text,
            "id": id,
            "photoUrl": photoUrl,
            "Device": Device
            
        ])
        .validate(statusCode: 200..<500)
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
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
        
        
        SwiftLoader.show(title: text, animated: true)
        
    }
    
}

extension ContactUsVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            getImage(image: editedImage)
        } else if let originalImage =
            info[.originalImage] as? UIImage {
            getImage(image: originalImage)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
