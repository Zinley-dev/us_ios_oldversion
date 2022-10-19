import UIKit
import SwiftPublicIP
import Firebase
import Alamofire
import AsyncDisplayKit
import AlgoliaSearchClient
import FLAnimatedImage

class UserSearchViewController: UIViewController{

   
    @IBOutlet weak var loadingImg: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var tableNode: ASTableNode!
    var searchUserList = [UserModelFromAlgolia]()
   
    @IBOutlet weak var contentView: UIView!
    var uid: String?
    var index = 0
    
    var selectedUID: String?
    
    var selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        contentView.addSubview(tableNode.view)
        self.applyStyle()

        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImg.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
    }

    
    func searchUsers(searchText: String) {
        AlgoliaSearch.instance.searchUsers(searchText: searchText) { userSearchResult in
           
            if userSearchResult != self.searchUserList {
                self.searchUserList = userSearchResult
                
                if userSearchResult.count == 1 {
                    
                    if userSearchResult[0].userUID == "" {
                        
                        UIView.animate(withDuration: 0.5) {
                            
                            DispatchQueue.main.async {
                                
                                if self.loadingView.isHidden == false {
                                    
                                    if self.loadingView.alpha != 0 {
                                        self.loadingView.alpha = 0
                                    }
                                    
                                }
                               
                            }
                           
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            
                            if self.loadingView.alpha == 0 {
                                
                                self.loadingView.isHidden = true
                                
                            }
                            
                        }
                        
                        
                        
                    } else {
                        
                        DispatchQueue.main.async {
                            self.loadingView.alpha = 1.0
                            self.loadingView.isHidden = false
                            
                        }
                        
                        
                        delay(0.75) {
                            
                            UIView.animate(withDuration: 0.5) {
                                
                                self.loadingView.alpha = 0
                                
                            }
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                
                                if self.loadingView.alpha == 0 {
                                    
                                    self.loadingView.isHidden = true
                                    
                                }
                                
                            }
                            
                        }
                        
                    
                        
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        
                        self.loadingView.alpha = 1.0
                        self.loadingView.isHidden = false
                        
                    }
                    
                    delay(0.75) {
                        
                        UIView.animate(withDuration: 0.5) {
                            
                            self.loadingView.alpha = 0
                            
                        }
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            
                            if self.loadingView.alpha == 0 {
                                
                                self.loadingView.isHidden = true
                                
                            }
                            
                        }
                        
                    }
                    
            
                    
                }
                
               
                DispatchQueue.main.async {
                    self.tableNode.reloadData(completion: nil)
                    print("***RUI***: Got result and reload table")
                }
                
            }
            
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentView.bounds
       
    }
    
  
    
    
    func applyStyle() {
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
    }
    
    func wireDelegates() {
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveFromUserSearchToProfile"{
            if let destination = segue.destination as? UserProfileVC
            {
                
                destination.uid = selectedUID
            }
        }
        
    }
    
}

extension UserSearchViewController: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        selectedUID = searchUserList[indexPath.row].userUID
        print("selected: \(searchUserList[indexPath.row].name)")
        self.performSegue(withIdentifier: "moveFromUserSearchToProfile", sender: nil)
    }
}

extension UserSearchViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.searchUserList.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard self.searchUserList.count > indexPath.row else { return { ASCellNode() } }
        let user = self.searchUserList[indexPath.row]
        
        let cellNodeBlock = { () -> ASCellNode in
            let cellNode = UserSearchNode(with: user)
            return cellNode
        }
        
        return cellNodeBlock
    }
    
        
}

