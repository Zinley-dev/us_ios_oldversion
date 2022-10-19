//
//  AutocompeteViewController.swift
//  Dual
//
//  Created by Rui Sun on 8/18/21.
//

import UIKit
import AlgoliaSearchClient

class AutocompeteViewController: UIViewController, UITableViewDelegate {
    
    enum Mode {
        case user, hashtag, highlight, keyword
    }
    
    var userSearchcompletionHandler: ((String, String) -> Void)?
    var hashtagSearchcompletionHandler: ((String) -> Void)?
    var highlightSearchcompletionHandler: ((String) -> Void)?
    var keywordSearchcompletionHandler: ((String) -> Void)?

    
    var searchMode = Mode.user
    
    var searchUserList = [UserModelFromAlgolia]()
    var searchHashtagList = [HashtagsModelFromAlgolia]()
    var searchHighlightList = [HighlightsModel]()
    var searchKeywordList = [KeywordModelFromAlgolia]()
    
    let tableView: UITableView = {
        let uitableView = UITableView()
        uitableView.separatorStyle = .none
        uitableView.register(customSearchCell.nib(), forCellReuseIdentifier: customSearchCell.cellReuseIdentifier())
        uitableView.backgroundColor = .clear
        uitableView.borderColors = .clear
        return uitableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        view.addSubview(tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func searchUsers(searchText: String) {
        print("searching: \(searchText)")
        
        AlgoliaSearch.instance.searchUsers(searchText: searchText) { userSearchResult in
            print("finish search")
            print(userSearchResult.count)
            if userSearchResult != self.searchUserList {
                self.searchUserList = userSearchResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("***RUI***: Got result and reload table")
                }
                
            }
            
        }
        
    }
    
    
    func searchHashtags(searchText: String) {
        AlgoliaSearch.instance.searchHashtags(searchText: searchText) { hashtagSearchResult in
            print("Finished hashtag search, got \(hashtagSearchResult.count) results")
            if hashtagSearchResult != self.searchHashtagList {
                self.searchHashtagList = hashtagSearchResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("***RUI***: Got result and reload table")
                }
            }
        }
        
    }
    
    func searchHighlights(searchText: String) {
        AlgoliaSearch.instance.searchHighlights(searchText: searchText, pageNumber: 0, withHashtagOnly: false) { highlightSearchResult in
            print("Finished highlight search, got \(highlightSearchResult.count) results")
            if highlightSearchResult != self.searchHighlightList {
                self.searchHighlightList = highlightSearchResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("***RUI***: Got result and reload table")
                }
            }
        }
    }
    
    func searchKeywords(searchText: String) {
        AlgoliaSearch.instance.searchKeywords(searchText: searchText, pageNumber: 0) { keywordSearchResult in
            print("Finished keyword search, got \(keywordSearchResult.count) results")
            if keywordSearchResult != self.searchKeywordList {
                self.searchKeywordList = keywordSearchResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("***RUI***: Got result and reload table")
                }
            }
        }
    }
    
    func search(text: String, with mode: Mode) {
        switch mode {
        case .user:
            searchUsers(searchText: text)
            self.searchMode = .user
        case .hashtag:
            searchHashtags(searchText: text)
            self.searchMode = .hashtag
        case .highlight:
            searchHighlights(searchText: text)
            self.searchMode = .highlight
        case .keyword:
            searchKeywords(searchText: text)
            self.searchMode = .keyword
        }
    }
    
    
    func clearTable() {
        self.searchUserList = [UserModelFromAlgolia]()
        self.searchHashtagList = [HashtagsModelFromAlgolia]()
        self.searchHighlightList = [HighlightsModel]()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("***RUI***: Got result from Algolia")
        }
        //        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearTable()
    }
    
}

extension AutocompeteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.searchMode {
        case .user:
            return self.searchUserList.count
        case .hashtag:
            return self.searchHashtagList.count
        case .highlight:
            return self.searchHighlightList.count
        case .keyword:
            return self.searchKeywordList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: customSearchCell.cellReuseIdentifier(), for: indexPath) as? customSearchCell {
            
            cell.backgroundColor = .clear
            
            
            switch self.searchMode {
            case .user:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].username, url: self.searchUserList[indexPath.row].avatarUrl)
                
            case .hashtag:
                cell.configureCell(type: "hashtag", text: String(self.searchHashtagList[indexPath.row].keyword.dropFirst()), url: "")
                
            case .highlight:
                cell.configureCell(type: "highlight", text: String(self.searchHighlightList[indexPath.row].highlight_title ?? "No Title"), url: "")
            case .keyword:
                cell.configureCell(type: "keyword", text: String(self.searchKeywordList[indexPath.row].keyword), url: "")
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("autocompletevc: did select row")
        switch self.searchMode {
        case .user:
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].username), (self.searchUserList[indexPath.row].userUID))
        case .hashtag:
            (hashtagSearchcompletionHandler)?(self.searchHashtagList[indexPath.row].keyword)
        case .highlight: //todo: what to display/search?
            (highlightSearchcompletionHandler)?(self.searchHighlightList[indexPath.row].highlight_title)
        case .keyword:
            (keywordSearchcompletionHandler)?(self.searchKeywordList[indexPath.row].keyword)
        }
    }
}

