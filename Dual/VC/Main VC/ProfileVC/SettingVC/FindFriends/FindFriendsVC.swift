//
//  FindFriendsVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/20/22.
//

import UIKit
import Contacts
import ContactsUI
import FLAnimatedImage
import AsyncDisplayKit
import MessageUI

class FindFriendsVC: UIViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var contactLists = [FindFriendsModel]()
    
    var tableNode: ASTableNode!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true

        // Do any additional setup after loading the view.
        
        self.applyStyle()
       
        fetchContacts()
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        switch result {
            case .cancelled:
                showNote(text: "Invitation cancelled.")
                break
            case .sent:
                showNote(text: "Thank you, your invitation has been sent.")
                break
            case .failed:
                showNote(text: "Thank you, but your invitation is failed to send.")
                break
            default:
                break
        }
        
        controller.dismiss(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
        
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
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if contactLists[indexPath.row]._userUID != nil {
            
            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                
                controller.modalPresentationStyle = .fullScreen
                
                controller.uid = contactLists[indexPath.row]._userUID
                
                self.present(controller, animated: true, completion: nil)
                
                
            }
            
            
        } else {
            
            if let phoneNumber = contactLists[indexPath.row].phoneNumber  {
                
                
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self

                // Configure the fields of the interface.
                composeVC.recipients = [phoneNumber]
                composeVC.body = "[Dual] I am \(global_name) on Stitchbox. To download the app and watch more gaming videos. tap:https://apps.apple.com/us/app/dual/id1576592262"

                // Present the view controller modally.
                if MFMessageComposeViewController.canSendText() {
                    self.present(composeVC, animated: true, completion: nil)
                } else {
                    print("Can't send messages.")
                
                }
                
            }
            
        }
    }
    
    
    func fetchContacts() {
        
        let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, error) in
                if let error = error {
                    print("failed to request access", error)
                    return
                }
                if granted {
                    // 2.
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactImageDataAvailableKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        // 3.
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            
                            if contact.phoneNumbers.first?.value.stringValue != nil {
                                
                                
                                
                                var dict = ["firstName": contact.givenName, "familyName": contact.familyName, "phoneNumber": contact.phoneNumbers.first?.value.stringValue.stringByRemovingWhitespaces.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "")] as? [String: Any]
                                
                                if contact.imageDataAvailable {
                                   
                                    dict!.updateValue(contact.imageData!, forKey: "imageData")
                                    
                                }
                                
                                
                                let contactList = FindFriendsModel(FindFriendsModel: dict! as Dictionary<String, Any>)
                                
                               
                                self.contactLists.append(contactList)
                            }
                            
                          
                        })
                    } catch let error {
                        print("Failed to enumerate contact", error)
                    }
                    
                    self.checkContacts()
                } else {
                    print("access denied")
                }
            }
        
        
    }
    
    func checkContacts() {
        
        let max = contactLists.count
        var count = 0
        
        for user in contactLists {
           
            
            let db = DataService.instance.mainFireStoreRef
           
            db.collection("Users").whereField("phone", isEqualTo: user.phoneNumber!).getDocuments {  querySnapshot, error in
                 guard let snapshot = querySnapshot else {
                     print("Error fetching snapshots: \(error!)")
                     return
                 }
             
                if snapshot.isEmpty != true {
                    
                    for item in snapshot.documents {
                        
                        user._isIn = true
                        user._avatarURL = item.data()["avatarUrl"] as? String
                        user._userUID = item.data()["userUID"] as? String
                        user._username = item.data()["username"] as? String
                    }
                    
                } else {
                    
                    user._isIn = false
                    
                }
                
                count += 1
                
                if count == max {
                    
                    print("Done - \(max) - \(count)")
                    self.contactLists.sort { $0._isIn && !$1._isIn }
                    self.tableNode.reloadData()
                    
                    delay(1.25) {
                        
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
                
  
                
            }
        }
 
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
}

extension FindFriendsVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
    
       
}


extension FindFriendsVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.contactLists.count == 0 {
            
            tableNode.view.setEmptyMessage("No user")
            
        } else {
            tableNode.view.restore()
        }
        
        
        return self.contactLists.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
     
        let user = self.contactLists[indexPath.row]
       
        return {
            var node: FindFriendsNode!
            
            node = FindFriendsNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    

        
}
