//
//  AlgoliaSearch.swift
//  Dual
//
//  Created by Rui Sun on 9/10/21.
//

import Foundation
import AlgoliaSearchClient
import FirebaseAuth


class AlgoliaSearch {
    
    enum SearchType {
        case User
        case Highlight
        case Hashtag
        case Keyword
        case ReportHistory
    }
    
    fileprivate static var _instance = AlgoliaSearch()
    
    static var instance: AlgoliaSearch {
        return _instance
    }
    
    let HASHTAG_RESULTS_PER_PAGE = 5
    let KEYWORD_RESULTS_PER_PAGE = 10
    
    let USER_RESULTS_NUM = 10
    let FOLLOW_RESULTS_NUM = 5
    
    struct UserSearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [UserModelFromAlgolia]
    }
    
    struct HashtagSearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [HashtagsModelFromAlgolia]
    }
    
    struct HighlightSearchRecordPerPage {
            let keyWord: String
            let timeStamp: Double
            let pageNum: Int
            // page number, hits
    //        let items: [HighlightsModelFromAlgolia]
            let items: [HighlightsModel]
        }
    
    struct ReportHistorySearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [ReportHistoryModelFromAlgolia]
    }
    
    //Store search history
    let EXPIRE_TIME = 5.0 //s
    var userSearchHist = [UserSearchRecord]()
    var hashtagSearchHist = [HashtagSearchRecord]()
    var highlightSearchHist = [String: [Int: HighlightSearchRecordPerPage]]()
    var reportHistorySearchHist = [ReportHistorySearchRecord]()
    
    
    private func retrieveApiKeyInfoAndRegisterServices() {
        DataService.instance.mainFireStoreRef.collection("Api_keys").whereField("service_name", isEqualTo: "Algolia").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting apikey documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // update api key info in constant then register services
                    let apiKeyDetail = ApiKeyDetail(apiKeyModel: document.data())
                    api_key_dict[apiKeyDetail.key] = apiKeyDetail
                    
                    // register algolia
                    if apiKeyDetail.serviceName == "Algolia" {
                        print("Algolia api key -> \(String(describing: apiKeyDetail.key)): \(String(describing: apiKeyDetail.appId))")
                        
                        // register algolia service
                        algoliaSearchClient = SearchClient(appID: ApplicationID(rawValue: apiKeyDetail.appId), apiKey: APIKey(rawValue: apiKeyDetail.key))
                    }
                    
                }
            }
        }
    }
    
    private func checkAlgoliaSearchClient() {
        if algoliaSearchClient == nil {
            retrieveApiKeyInfoAndRegisterServices()
        }
    }
    
    func pingServer() {
        checkAlgoliaSearchClient()
        print("Start pinging Algolia server...")
        let algoliaPingIndex = algoliaSearchClient.index(withName: "Ping")
        var newQuery = AlgoliaSearchClient.Query("NotExist")
        newQuery.hitsPerPage = 1
        newQuery.page = 0
        
        algoliaPingIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Ping Algolia Server Error: \(error)")
            case .success(_):
                print("ping sucessful")
            }
        }
    }

    func checkUsersLocalRecords(searchText: String) -> [UserModelFromAlgolia] {
        
        var retrievedSearchUserList = [UserModelFromAlgolia]()
        print("***RUI***: check local search records...")
        for (i, record) in userSearchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    
                    retrievedSearchUserList = record.items
                    return retrievedSearchUserList
                    
                } else {
                    print("***RUI***: delete expired record \(record) at index \(i)")
                    
                    //todo: out of index?
                    self.userSearchHist.remove(at: i)
                    
                }
            }
        }
        print("***RUI***: no available local record found")
        return retrievedSearchUserList
        
    }
    
    func checkHashtagLocalRecords(searchText: String) -> [HashtagsModelFromAlgolia] {
        
        var retrievedHashtagSearchList = [HashtagsModelFromAlgolia]()
        print("***RUI***: check local search records...")
        for (i, record) in hashtagSearchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    
                    retrievedHashtagSearchList = record.items
                    return retrievedHashtagSearchList
                    
                } else {
                    print("***RUI***: delete expired record")
                    hashtagSearchHist.remove(at: i)
                }
            }
        }
        print("***RUI***: no available local record found")
        return retrievedHashtagSearchList
        
    }
    
    func checkHighlightLocalRecords(searchText: String, pageNumber: Int) -> [HighlightsModel] {
        
        var retrievedHighlightSearchList = [HighlightsModel]()
        print("***RUI***: check local search records...")
        if var highlightSearchRecords = highlightSearchHist[searchText], let record = highlightSearchRecords[pageNumber] {
            if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                
                retrievedHighlightSearchList = record.items
                return retrievedHighlightSearchList
                
            } else {
                print("***RUI***: delete expired record")
                highlightSearchRecords.removeValue(forKey: pageNumber)
            }
        }
        print("***RUI***: no available local record found")
        return retrievedHighlightSearchList
        
    }
    
    func checkReportHistoryLocalRecords(searchText: String) -> [ReportHistoryModelFromAlgolia] {
        
        var retrievedSearchReportHistList = [ReportHistoryModelFromAlgolia]()
        print("***RUI***: check local search records...")
        for (i, record) in reportHistorySearchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    
                    retrievedSearchReportHistList = record.items
                    return retrievedSearchReportHistList
                    
                } else {
                    print("***RUI***: delete expired record \(record) at index \(i)")
                    
                    //todo: out of index?
                    self.reportHistorySearchHist.remove(at: i)
                    
                }
            }
        }
        print("***RUI***: no available local record found")
        return retrievedSearchReportHistList
    }

    
    // search a given text in users index on Algolia and return a list of UserModel
    // also filers out suspended user
    func searchUsers(searchText: String, completionHandler: @escaping ([UserModelFromAlgolia]) -> Void) {
        checkAlgoliaSearchClient()
        let algoliaUserIndex = algoliaSearchClient.index(withName: "Users")
        //check local result first
        let res = checkUsersLocalRecords(searchText: searchText)
        if !res.isEmpty {
            print("Retrieve local result: \(res.count)")
            completionHandler(res)
            return
        }
        
        print("***RUI***: search in Algolia...")
        
        
        var newQuery = AlgoliaSearchClient.Query(searchText)
        newQuery.hitsPerPage = USER_RESULTS_NUM
        newQuery.page = 0
        
        
//        let newQuery = AlgoliaSearchClient.Query(searchText)
        algoliaUserIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    let hits: [UserModelFromAlgolia] = try response.extractHits()
                    
                    //filter result
                    var newSearchUserList = self.filterSearchResult(hits: hits)
                    
                    //store search result locally
                    let newSearchRecord = UserSearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchUserList)
                    self.userSearchHist.append(newSearchRecord)
                    
                    //show no results
                    if newSearchUserList.isEmpty {
                        newSearchUserList = [UserModelFromAlgolia()]
                    }
                            
                    print("Retrieve algolia result: \(res.count)")
                    newSearchUserList.forEach{ user in
                        print(user.username)
                    }
                    completionHandler(newSearchUserList)
                    
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    //filter blocked user or suspended user
    func filterSearchResult(hits: [UserModelFromAlgolia]) -> [UserModelFromAlgolia]{
        var res = [UserModelFromAlgolia]()
        for hit in hits {
            if !global_block_list.contains(hit.userUID) && !(hit.is_suspend ?? false){
                res.append(hit)
            }
        }
        return res
    }
    
    //search who is following you
    func searchFollowers(targetUserUID: String, searchText: String, completionHandler: @escaping ([FollowModelFromAlgolia]) -> Void) {
        
        if searchText.isEmpty {
            completionHandler([FollowModelFromAlgolia]())
        }
        
        checkAlgoliaSearchClient()
        //check local result first
        let algoliaFollowIndex = algoliaSearchClient.index(withName: "Follow")
        
                
//        let res = checkHashtagLocalRecords(searchText: searchText)
//        if !res.isEmpty {
//            print("Retrieve hashtag local result: \(res.count)")
//            completionHandler(res)
//            return
//        }
        
        var newQuery = AlgoliaSearchClient.Query(searchText).set(\.restrictSearchableAttributes, to: [
            "Following_username"
        ])
        newQuery.filters = "Follower_uid:\(targetUserUID)"
        newQuery.hitsPerPage = FOLLOW_RESULTS_NUM
        newQuery.page = 0
        
//        print("***RUI***: search in Algolia...")
        algoliaFollowIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
//                print("Response: \(response)")
                do {
                    let newSearchFollowList:[FollowModelFromAlgolia] = try response.extractHits()
                    
                    //store search result locally
//                    let newSearchRecord = HashtagSearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchHashtagList)
//                    self.hashtagSearchHist.append(newSearchRecord)
                    
                    completionHandler(newSearchFollowList)
            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    
    //search who you are following
    // note: following is followee
    func searchFollowings(targetUserUID: String, searchText: String, completionHandler: @escaping ([FollowModelFromAlgolia]) -> Void) {
        if searchText.isEmpty {
            completionHandler([FollowModelFromAlgolia]())
        }
        
        checkAlgoliaSearchClient()
        //check local result first
        let algoliaFollowIndex = algoliaSearchClient.index(withName: "Follow")
        
                
//        let res = checkHashtagLocalRecords(searchText: searchText)
//        if !res.isEmpty {
//            print("Retrieve hashtag local result: \(res.count)")
//            completionHandler(res)
//            return
//        }
        
        var newQuery = AlgoliaSearchClient.Query(searchText).set(\.restrictSearchableAttributes, to: [
            "Follower_username"
        ])
        newQuery.filters = "Following_uid:\(targetUserUID)"
        newQuery.hitsPerPage = FOLLOW_RESULTS_NUM
        newQuery.page = 0
        
//        print("***RUI***: search in Algolia...")
        algoliaFollowIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
//                print("Response: \(response)")
                do {
                    let newSearchFollowList:[FollowModelFromAlgolia] = try response.extractHits()
                    
                    //store search result locally
//                    let newSearchRecord = HashtagSearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchHashtagList)
//                    self.hashtagSearchHist.append(newSearchRecord)
                    
                    completionHandler(newSearchFollowList)
            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    func searchHashtags(searchText: String, completionHandler: @escaping ([HashtagsModelFromAlgolia]) -> Void) {
        checkAlgoliaSearchClient()
        //check local result first
        let algoliaHashtagIndex = algoliaSearchClient.index(withName: "Hashtags")
        let res = checkHashtagLocalRecords(searchText: searchText)
        if !res.isEmpty {
            print("Retrieve hashtag local result: \(res.count)")
            completionHandler(res)
            return
        }
        
        let newQuery = AlgoliaSearchClient.Query(searchText)
        
        print("***RUI***: search in Algolia...")
        algoliaHashtagIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    let newSearchHashtagList:[HashtagsModelFromAlgolia] = try response.extractHits()
                    
                    //store search result locally
                    let newSearchRecord = HashtagSearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchHashtagList)
                    self.hashtagSearchHist.append(newSearchRecord)
                    
                    completionHandler(newSearchHashtagList)
            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    //get result by page number, default results per page is set to 5
    func searchHighlights(searchText: String, pageNumber: Int, withHashtagOnly: Bool, completionHandler: @escaping ([HighlightsModel]) -> Void) {
        checkAlgoliaSearchClient()
        //check local result first
        let algoliaHighlightIndex = algoliaSearchClient.index(withName: "Highlights")
        let res = checkHighlightLocalRecords(searchText: searchText, pageNumber: pageNumber)
        if !res.isEmpty {
            print("Retrieve hashtag local result: \(res.count)")
            completionHandler(res)
            return
        }
        
        var newQuery = AlgoliaSearchClient.Query(searchText)
        newQuery.hitsPerPage = HASHTAG_RESULTS_PER_PAGE
        newQuery.page = pageNumber
        
        //only search hashtags
        if withHashtagOnly {
            newQuery.restrictSearchableAttributes = ["hashtag_list"]
        }
        
        print("***RUI***: search in Algolia...")
        algoliaHighlightIndex.search(query: newQuery) { [self] result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    print("hits per page: \(String(describing: response.hitsPerPage)), number of pages: \(String(describing: response.nbPages))")
                    let newSearchHighlightList:[HighlightsModelFromAlgolia] = try response.extractHits()
                    
                    let newSearchHighlightListConverted = self.prepareModel(hits: newSearchHighlightList)
                    
                    //store search result locally
                    let newSearchRecord = HighlightSearchRecordPerPage(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, pageNum: pageNumber, items: newSearchHighlightListConverted)
                    if var highlightSearchRecords = self.highlightSearchHist[searchText] {
                        highlightSearchRecords[pageNumber] = newSearchRecord
                    } else {
                        self.highlightSearchHist[searchText] = [pageNumber: newSearchRecord]
                    }
                    
                    completionHandler(newSearchHighlightListConverted)

            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    //convert model and filter results: blocked, modes: only me, public, followers
        func prepareModel(hits: [HighlightsModelFromAlgolia]) -> [HighlightsModel]{
            var res = [HighlightsModel]()
            for hit in hits {
                let highlight = HighlightsModel(from: hit)
                print("mode: \(String(describing: highlight.mode))")
                
                let currentUserUID = Auth.auth().currentUser?.uid
                
                // user own videos are visible to their own no matter in which mode
                if highlight.userUID == currentUserUID {
                    res.append(highlight)
                } else {
                    switch highlight.mode {
                    case "Public":
                        //not from a blocked user
                        if !global_block_list.contains(highlight.userUID) {
                            res.append(highlight)
                        }
                        break
                    case "Only me":
                        break
                    case "Followers":
                        if global_following_list.contains(highlight.userUID), !global_block_list.contains(highlight.userUID) {
                            res.append(highlight)
                        }
                        break
                    case .none:
                        break
                    case .some(_):
                        break
                    }
                    
                }
            }
            return res
        }
    
    
    
    
    func searchKeywords(searchText: String, pageNumber: Int, completionHandler: @escaping ([KeywordModelFromAlgolia]) -> Void) {
        checkAlgoliaSearchClient()
        //check local result first
        let algoliaKeywordIndex = algoliaSearchClient.index(withName: "Keywords")
//        let res = checkHashtagLocalRecords(searchText: searchText)
//        if !res.isEmpty {
//            print("Retrieve hashtag local result: \(res.count)")
//            completionHandler(res)
//            return
//        }
        
        var newQuery = AlgoliaSearchClient.Query(searchText)
        newQuery.hitsPerPage = KEYWORD_RESULTS_PER_PAGE
        newQuery.page = pageNumber
        newQuery.filters = "count > 0"
        
        print("***RUI***: search in Algolia...")
        algoliaKeywordIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    let newSearchKeywordList:[KeywordModelFromAlgolia] = try response.extractHits()
                    
                    //store search result locally
//                    let newSearchRecord = HashtagSearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchHashtagList)
//                    self.hashtagSearchHist.append(newSearchRecord)
                    
                    completionHandler(newSearchKeywordList)
            
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }
    
    
    
    func searchReportHistory(searchText: String, completionHandler: @escaping ([ReportHistoryModelFromAlgolia]) -> Void) {
        checkAlgoliaSearchClient()
        let algoliaUserIndex = algoliaSearchClient.index(withName: "Report_history")
        //check local result first
        let res = checkReportHistoryLocalRecords(searchText: searchText)
        if !res.isEmpty {
            print("Retrieve local result: \(res.count)")
            completionHandler(res)
            return
        }
        
        print("***RUI***: search in Algolia...")
        
        
        let newQuery = AlgoliaSearchClient.Query(searchText)
//        newQuery.hitsPerPage = USER_RESULTS_NUM
//        newQuery.page = 0
        
        
//        let newQuery = AlgoliaSearchClient.Query(searchText)
        algoliaUserIndex.search(query: newQuery) { result in
            switch result {
            case .failure(let error):
                print("Error: \(error)")
            case .success(let response):
                //print("Response: \(response)")
                do {
                    let hits: [ReportHistoryModelFromAlgolia] = try response.extractHits()
                    
                    //filter result
//                    var newSearchUserList = self.filterSearchResult(hits: hits)
                    
                    //store search result locally
                    let newSearchRecord = ReportHistorySearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: hits)
                    self.reportHistorySearchHist.append(newSearchRecord)
                    
                    //show no results
//                    if newSearchUserList.isEmpty {
//                        newSearchUserList = [UserModelFromAlgolia()]
//                    }
                            
                    print("Retrieve algolia result: \(res.count)")
                    hits.forEach{ user in
                        print(user.nickname)
                    }
                    completionHandler(hits)
                    
                } catch let error {
                    print("Contact parsing error: \(error)")
                }
            }
        }
        
    }

    
    
}

