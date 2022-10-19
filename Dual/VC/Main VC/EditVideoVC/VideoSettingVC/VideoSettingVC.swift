//
//  VideoSettingVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/18/20.
//

import UIKit
import Photos
import Alamofire
import Firebase

class VideoSettingVC: UIViewController {
    
    var selectedItem: HighlightsModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func vidInformationBtnPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "moveToVidInformationVC", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToVidInformationVC"{
            if let destination = segue.destination as? VideoInformationVC
            {
                
                destination.selectedItem = self.selectedItem
               
                
            }
        }
        
    }
    
    @IBAction func downloadVideoBtnPressed(_ sender: Any) {
        
        if let id = selectedItem.Mux_playbackID {
            
            let url = "https://stream.mux.com/\(id)/high.mp4"
           
            downloadVideo(url: url, id: id)
            
        }
        
        
    }
    
    @IBAction func copyLinkBtnPressed(_ sender: Any) {
        
        
        if let id = selectedItem.highlight_id {
           
            let link = "https://dualteam.page.link/dual?p=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
            
        }
        
        
    }
    
    
    
    @IBAction func shareVideoLinkBtnPressed(_ sender: Any) {
        
        if let id = selectedItem.highlight_id {
            
            
            let items: [Any] = ["Hi I am \(global_name) from Dual, let's check out this highlight!", URL(string: "https://dualteam.page.link/dual?p=\(id)")!]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
            
        }
        
        
        
    }
    
    @IBAction func DeleteVideoBtnPressed(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Are you sure to delete this video ?", message: "If you confirm to delete, this video will be removed permanently and this action can't be undo.", preferredStyle: UIAlertController.Style.actionSheet)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { action in

            
            if let id = self.selectedItem.highlight_id {
                
                DispatchQueue.main.async {
                    self.swiftLoader(progress: "Deleting")
                }
              
                let db = DataService.instance.mainFireStoreRef.collection("Highlights")
                
                
                //h_status
                
                db.document(id).updateData(["h_status": "Deleted", "Deleted_by": Auth.auth().currentUser!.uid, "Reason": "self remove"]) { (err) in
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    
                    if let err = err {
                            print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
       
                        self.deleteRemoveHistory(item: self.selectedItem)
                        self.checkIfRemoveMostPlayList(item: self.selectedItem)
                        ActivityLogService.instance.UpdateHighlightActivityLog(mode: "Delete", Highlight_Id: id, category: self.selectedItem.category)
                        
                        DispatchQueue.main.async {
                           
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                            
                        }
                        
                       
                            
                    }
                }
                    
             
                
            }
            
                
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func checkIfRemoveMostPlayList(item: HighlightsModel) {
        
        DataService.instance.mainFireStoreRef.collection("MostPlayed_history").whereField("HighlightID", isEqualTo: item.highlight_id!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty != true {
                
                for item in querySnapshot!.documents {
                    
                    DataService.instance.mainFireStoreRef.collection("MostPlayed_history").document(item.documentID).delete()
                    
                    
                }
                
            }
            
            
        }
        
    }
    
    func deleteRemoveHistory(item: HighlightsModel) {
        
        DataService.instance.mainFireStoreRef.collection("Report_history").whereField("id", isEqualTo: item.highlight_id!).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty != true {
                
                for item in querySnapshot!.documents {
                    
                    DataService.instance.mainFireStoreRef.collection("Report_history").document(item.documentID).delete()
                    
                    
                }
                
            }
            
            
        }
        
        
    }
    
    func downloadVideo(url: String, id: String){

        AF.request(url).downloadProgress(closure : { (progress) in
       
            self.swiftLoader(progress: "\(String(format:"%.2f", Float(progress.fractionCompleted) * 100))%")
            
        }).responseData{ (response) in
            
            switch response.result {
            
            case let .success(value):
                
                
                let data = value
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
          
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
                }) { saved, error in
                    
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    
                    if (error != nil) {
                        
                        
                        DispatchQueue.main.async {
                            print("Error: \(error!.localizedDescription)")
                            self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                        }
                        
                    } else {
                        
                        
                        DispatchQueue.main.async {
                        
                            let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
     
                        
                    }
                }
                
            case let .failure(error):
                print(error)
                
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
