//
//  SearchVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 4/5/21.
//

import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import AlgoliaSearchClient

class SearchVC: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var videosBtn: UIButton!
    @IBOutlet weak var hashTagBtn: UIButton!
    @IBOutlet weak var widthconstant: NSLayoutConstraint!
    
    enum SearchMode {
        case users
        case videos
        case hashTags
    }
    
    var selectedSearchMode = SearchMode.users
    var searchText = ""
    
    var prevSelectedSearchMode = SearchMode.users
    var prevSearchText = ""
    
    lazy var delayItem = workItem()
       
    var uid: String?
    var index = 0
    
    var selectedUID: String?
    
    var tapGesture: UITapGestureRecognizer!
    
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    var userBorder = CALayer()
    var videoBorder = CALayer()
    var hashTagBorder = CALayer()
    
    
    lazy var userSearchViewController: UserSearchViewController = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserSearchViewController") as? UserSearchViewController {
            controller.uid = uid
            self.addVCAsChildVC(childViewController: controller)
            return controller
        } else {
            return UIViewController() as! UserSearchViewController
        }
    }()
    
    lazy var hashtagSearchViewController: HashtagSearchViewController = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HashtagSearchViewController") as? HashtagSearchViewController {
            controller.uid = uid
            self.addVCAsChildVC(childViewController: controller)
            return controller
        } else {
            return UIViewController() as! HashtagSearchViewController
        }
    }()
    
    lazy var videoSearchViewController: VideoSearchViewController = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoSearchViewController") as? VideoSearchViewController {
            controller.uid = uid
            self.addVCAsChildVC(childViewController: controller)
            return controller
        } else {
            return UIViewController() as! VideoSearchViewController
        }
    }()
    
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        //childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //
        childViewController.didMove(toParent: self)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch self.selectedSearchMode {
        case SearchMode.users:
            print("search users...")
           
            
        case SearchMode.videos:
            print("search video.. ")
            
            if let word = textField.text, word != "" {
                
                update_unique_video_searchWords_collection(keyword: word)
                upload_video_searchWords_collection(keyword: word)
                self.videoSearchViewController.view.isHidden = false
                //self.videoSearchViewController.searchHighlights(searchText: word)
                
                if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoFromSearchViewController") as? VideoFromSearchViewController {
                    
                    controller.modalPresentationStyle = .fullScreen
                    controller.current_searchText = word
                    self.present(controller, animated: true, completion: nil)
                    
                }
                     

            }
            
        case SearchMode.hashTags:
            print("search hashtag...")
            
        }
        
        self.view.endEditing(true)
        
        return true
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(self.view.frame.width)

        tapGesture = UITapGestureRecognizer(target: self, action:#selector(self.closeKeyboard(_:)))
        //do not cancel touch gesture
        tapGesture.cancelsTouchesInView = false
        
        tapGesture.delegate = self

        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white

        self.contentView.addGestureRecognizer(tapGesture)
        
        
        userSearchViewController.view.isHidden = false
        hashtagSearchViewController.view.isHidden = true
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.delegate = self
        } else {
            if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.delegate = self
            }
        }
        
        userBorder = userBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        videoBorder = videosBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        hashTagBorder = hashTagBtn.addBottomBorderWithColor(color: selectedColor, height: 2.0, width: self.view.frame.width * (120/414))
        userBtn.layer.addSublayer(userBorder)
        
        widthconstant.constant = self.view.frame.width * (120/414)
        searchBar.becomeFirstResponder()
        
    }
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchTextIn: String) {
        
        //print("prev text: \(self.searchText), cur: \(searchTextIn)")
        
        delayItem.perform(after: 0.25) {
            
            self.searchText = searchTextIn
            self.sendSearchRequestToTargetVC()
            //finish search, update previous search text
            self.prevSearchText = self.searchText
            
        }
        
    }
    
    func sendSearchRequestToTargetVC(){
        //print("Searching... \(searchText), previous search: \(self.prevSearchText)")
        if searchText.isEmpty {
            self.hideTableOnEmptySearchText()

        } else if selectedSearchMode == prevSelectedSearchMode && searchText == prevSearchText {
            //print("no change...")
            return
        } else {
            switch self.selectedSearchMode {
            case SearchMode.users:
                //print("search users...")
                userSearchViewController.view.isHidden = false
                self.userSearchViewController.searchUsers(searchText: searchText)
                
            case SearchMode.videos:
                //print("search video.. ")
                
                // introduce autocomplete vc to show keywords
                videoSearchViewController.view.isHidden = false
                self.videoSearchViewController.searchKeywords(searchText: searchText)
               
                
                
            case SearchMode.hashTags:
                //print("search hashtag...")
                hashtagSearchViewController.view.isHidden = false
                self.hashtagSearchViewController.searchHashtags(searchText: searchText)
            }
        }
        
    }
    
    
    @objc func closeKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToUserProfile6"{
            if let destination = segue.destination as? UserProfileVC
            {
                
               
                destination.uid = selectedUID
                  
            }
        }
        
    }
    
  
    
    
    @IBAction func userBtnPressed(_ sender: Any) {
        setCurrentBorderAndShowView(currentSelected: SearchMode.users)
        userBtn.setTitleColor(UIColor.white, for: .normal)
        videosBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashTagBtn.setTitleColor(UIColor.lightGray, for: .normal)
              
    }
    
    @IBAction func videoBtnPressed(_ sender: Any) {
        
        setCurrentBorderAndShowView(currentSelected: SearchMode.videos)
        videosBtn.setTitleColor(UIColor.white, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
        hashTagBtn.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    @IBAction func hashTagBtnPressed(_ sender: Any) {
        setCurrentBorderAndShowView(currentSelected: SearchMode.hashTags)
        hashTagBtn.setTitleColor(UIColor.white, for: .normal)
        videosBtn.setTitleColor(UIColor.lightGray, for: .normal)
        userBtn.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    private func setCurrentBorderAndShowView(currentSelected: SearchMode){
//        clearPreviousBorderAndHideView()
        prevSelectedSearchMode = selectedSearchMode
        selectedSearchMode = currentSelected
        switch selectedSearchMode {
        case SearchMode.users:
            userBtn.layer.addSublayer(userBorder)
            videoBorder.removeFromSuperlayer()
            videoSearchViewController.view.isHidden = true
            hashTagBorder.removeFromSuperlayer()
            hashtagSearchViewController.view.isHidden = true
        case SearchMode.videos:
            videosBtn.layer.addSublayer(videoBorder)
            userBorder.removeFromSuperlayer()
            userSearchViewController.view.isHidden = true
            hashTagBorder.removeFromSuperlayer()
            hashtagSearchViewController.view.isHidden = true
            
        case SearchMode.hashTags:
            hashTagBtn.layer.addSublayer(hashTagBorder)
            userBorder.removeFromSuperlayer()
            userSearchViewController.view.isHidden = true
            videoBorder.removeFromSuperlayer()
            videoSearchViewController.view.isHidden = true
        }
        sendSearchRequestToTargetVC()
    }
    
    func hideTableOnEmptySearchText(){
        switch selectedSearchMode {
        case SearchMode.users:
            userSearchViewController.view.isHidden = true
            userSearchViewController.searchUserList.removeAll()
            userSearchViewController.tableNode.reloadData(completion: nil)
        case SearchMode.videos:
            videoSearchViewController.view.isHidden = true
            videoSearchViewController.searchKeywordList.removeAll()
            videoSearchViewController.tableNode.reloadData(completion: nil)
        case SearchMode.hashTags:
            hashtagSearchViewController.view.isHidden = true
            hashtagSearchViewController.searchHashtagList.removeAll()
            hashtagSearchViewController.tableNode.reloadData(completion: nil)
        }
    }
    
}
