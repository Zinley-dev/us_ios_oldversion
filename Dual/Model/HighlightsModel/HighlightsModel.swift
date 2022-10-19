//
//  HighlightsModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/15/20.
//

import Foundation
import Firebase
import AlamofireImage
import Alamofire


class HighlightsModel {
    
  
    fileprivate var _origin_height: CGFloat!
    fileprivate var _origin_width: CGFloat!
    fileprivate var _reporting_nickname: String!
    fileprivate var _category: String!
    fileprivate var _url: String!
    fileprivate var _status: String!
    fileprivate var _mode: String!
    fileprivate var _music: String!
    fileprivate var _Mux_processed: Bool!
    fileprivate var _isReportingPlayer: Bool!
    fileprivate var _Mux_playbackID: String!
    fileprivate var _Mux_assetID: String!
    fileprivate var _Allow_comment: Bool!
    fileprivate var _userUID: String!
    fileprivate var _highlight_title: String!
    fileprivate var _highlight_id: String!
    fileprivate var _post_time: Timestamp!
    fileprivate var _ratio: CGFloat!
    fileprivate var _hashtag_list: [String]!
    fileprivate var _backgroundBlurrImage: UIImage!
    
    var _stream_link: String!
    
    
    var backgroundBlurrImage: UIImage! {
        get {
            if _backgroundBlurrImage == nil {
                _backgroundBlurrImage = nil
            }
            return _backgroundBlurrImage
        }
        
    }
    
    var origin_height: CGFloat! {
        get {
            if _origin_height == nil {
                _origin_height = 0
            }
            return _origin_height
        }
        
    }
    
    var origin_width: CGFloat! {
        get {
            if _origin_width == nil {
                _origin_width = 0
            }
            return _origin_width
        }
        
    }
    
    var reporting_nickname: String! {
        get {
            if _reporting_nickname == nil {
                _reporting_nickname = ""
            }
            return _reporting_nickname
        }
        
    }

    var hashtag_list: [String]! {
        get {
            
            if _hashtag_list == nil {
                return []
            }
 
            return _hashtag_list
        }
        
    }
    
    var ratio: CGFloat! {
        get {
            if _ratio == nil {
                _ratio = 0.0
            }
            return _ratio
        }
        
    }
    
    
    var Mux_assetID: String! {
        get {
            if _Mux_assetID == nil {
                _Mux_assetID = ""
            }
            return _Mux_assetID
        }
        
    }
    
    
    var highlight_id: String! {
        get {
            if _highlight_id == nil {
                _highlight_id = ""
            }
            return _highlight_id
        }
        
    }

    var category: String! {
        get {
            if _category == nil {
                _category = ""
            }
            return _category
        }
        
    }
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    var status: String! {
        get {
            if _status == nil {
                _status = ""
            }
            return _status
        }
        
    }
    
    var mode: String! {
        get {
            if _mode == nil {
                _mode = ""
            }
            return _mode
        }
        
    }
    
    var music: String! {
        get {
            if _music == nil {
                _music = ""
            }
            return _music
        }
        
    }
    
    var Mux_playbackID: String! {
        get {
            if _Mux_playbackID == nil {
                _Mux_playbackID = ""
            }
            return _Mux_playbackID
        }
        
    }
    
    var userUID: String! {
        get {
            if _userUID == nil {
                _userUID = ""
            }
            return _userUID
        }
        
    }
    
    var highlight_title: String! {
        get {
            if _highlight_title == nil {
                _highlight_title = ""
            }
            return _highlight_title
        }
        
    }
    
    var stream_link: String! {
        get {
            if _stream_link == nil {
                _stream_link = ""
            }
            return _stream_link
        }
        
    }
    
    var Mux_processed: Bool! {
        get {
            if _Mux_processed == nil {
                _Mux_processed = false
            }
            return _Mux_processed
        }
        
    }
    
    var Allow_comment: Bool! {
        get {
            if _Allow_comment == nil {
                _Allow_comment = false
            }
            return _Allow_comment
        }
        
    }
    
    var isReportingPlayer: Bool! {
        get {
            if _isReportingPlayer == nil {
                _isReportingPlayer = false
            }
            return _isReportingPlayer
        }
        
    }
    
    var post_time: Timestamp! {
        get {
            if _post_time == nil {
                _post_time = Timestamp.init(date: NSDate() as Date)
            }
            return _post_time
        }
    }



    //convert algolia model to highlights model
    convenience init(from highlightModelFromAlgolia: HighlightsModelFromAlgolia) {
        self.init(postKey: highlightModelFromAlgolia.objectID, Highlight_model: highlightModelFromAlgolia.dictionary ?? Dictionary())
        let postTime = highlightModelFromAlgolia.post_time
        if let second = postTime["_seconds"], let nanosec = postTime["_nanoseconds"]{
            self._post_time = Timestamp(seconds: Int64(second), nanoseconds: Int32(nanosec))
        }
    }
    
    init(postKey: String, Highlight_model: Dictionary<String, Any>) {
        
        
        self._highlight_id = postKey
        
        
        
       

        if let ratio = Highlight_model["ratio"] as? CGFloat {
            self._ratio = ratio
        }
        
        if let Mux_assetID = Highlight_model["Mux_assetID"] as? String {
            self._Mux_assetID = Mux_assetID
        }
        
        
        if let url = Highlight_model["url"] as? String {
            self._url = url
        }
        
        if let category = Highlight_model["category"] as? String {
            self._category = category
        }
        
        if let status = Highlight_model["h_status"] as? String {
            self._status = status
        }
        
        if let mode = Highlight_model["mode"] as? String {
            self._mode = mode
        }
        
        if let music = Highlight_model["music"] as? String {
            self._music = music
        }
        
        
        if let reporting_nickname = Highlight_model["reporting_nickname"] as? String {
            self._reporting_nickname = reporting_nickname
        }
        
        if let Mux_playbackID = Highlight_model["Mux_playbackID"] as? String {
            self._Mux_playbackID = Mux_playbackID
        }
        
        if let userUID = Highlight_model["userUID"] as? String {
            self._userUID = userUID
        }
        
        if let highlight_title = Highlight_model["highlight_title"] as? String {
            self._highlight_title = highlight_title
        }
        
        if let stream_link = Highlight_model["stream_link"] as? String {
            self._stream_link = stream_link
        }
        
        if let Mux_processed = Highlight_model["Mux_processed"] as? Bool {
            self._Mux_processed = Mux_processed
        }
        
        if let Allow_comment = Highlight_model["Allow_comment"] as? Bool {
            self._Allow_comment = Allow_comment
        }
        
        if let isReportingPlayer = Highlight_model["isReportingPlayer"] as? Bool {
            self._isReportingPlayer = isReportingPlayer
        }
        
        
        if let post_time = Highlight_model["post_time"] as? Timestamp {
            self._post_time = post_time
            
        }
         
        if let hashtag_list = Highlight_model["hashtag_list"] as? [String] {
            
            self._hashtag_list = hashtag_list
   
        }
        
        
        if let origin_height = Highlight_model["origin_height"] as? CGFloat {
            
            self._origin_height = origin_height
            
        }
        
        if let origin_width = Highlight_model["origin_width"] as? CGFloat {
            
            self._origin_width = origin_width
            
        }
    
        
    }
    
    func getBlurrImage(url: String) {
        
        let cachedKey = "\(url)BlurredImage"
        
        imageStorage.async.object(forKey: cachedKey) { result in
                    if case .value(let image) = result {
                        
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                             
                            self._backgroundBlurrImage = image

                        }
                        
                    } else {
                        
                        
                        AF.request(url).responseImage { response in
                            
                            
                            switch response.result {
                            case let .success(value):
                                
                               
                                let finalImg = blurImage(image: value)
                                self._backgroundBlurrImage = finalImg

                                
                                try? imageStorage.setObject(finalImg!, forKey: cachedKey, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                
                            case let .failure(error):
                                print(error)
                            }
                            
                            
                            
                        }
                         
                    }
                    
                }
        
        
        
    }
    
    
    
    
    func getUserName(userUID: String) {
        
        DataService.instance.mainFireStoreRef.collection("Users").whereField("userUID", isEqualTo: userUID).getDocuments { (snap, err) in
            
            if err != nil {
                print("Can't find user with \(userUID)")
                return
            }
            
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    if let username = item.data()["username"] as? String {
                        
                        self._hashtag_list.insert(username, at: self._hashtag_list.count)
                    }
                    
                }
                
            }
            
        }
        
        
        
    }
    
}

extension HighlightsModel: Equatable {
    static func == (lhs: HighlightsModel, rhs: HighlightsModel) -> Bool {
        return lhs._highlight_id == rhs._highlight_id
    }
}
