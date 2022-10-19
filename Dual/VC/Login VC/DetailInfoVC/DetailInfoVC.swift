//
//  DetailInfoVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/28/20.
//

import UIKit
import AsyncDisplayKit

class DetailInfoVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    var finalPhone: String?
    var finalCode: String?
    var finalName: String?
    var finalBirthday: String?
    var Create_mode: String?
    var dView = DetailInfo()
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        preLoadTutorial()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupView()
    }
    
    func setupView() {
        
        dView.frame = CGRect(x: self.contentView.layer.bounds.minX + 16, y: self.contentView.layer.bounds.minY, width: self.contentView.layer.bounds.width - 32, height: self.contentView.layer.bounds.height)
        
        dView.NameLbl.attributedPlaceholder = NSAttributedString(string: "Name",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        dView.BirthdayLbl.attributedPlaceholder = NSAttributedString(string: "Birthday",
                                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        
        dView.BirthdayLbl.addTarget(self, action: #selector(DetailInfoVC.getBirthday), for: .editingDidBegin)
        dView.NextBtn.addTarget(self, action: #selector(DetailInfoVC.nextBtnPressed), for: .touchUpInside)
        self.contentView.addSubview(dView)
        
        dView.NameLbl.delegate = self
        dView.NameLbl.keyboardType = .default
        dView.NameLbl.becomeFirstResponder()
        
        
        
    }
    
    @objc func nextBtnPressed() {
        
        if let name = dView.NameLbl.text, name != "", let birthday = dView.BirthdayLbl.text, birthday != "" {
            
            finalName = name
            finalBirthday = birthday
            Create_mode = "Original"
            self.performSegue(withIdentifier: "MoveToFinalAccount", sender: nil)
            
        } else {
            
            showErrorAlert("Oops!", msg: "Please fill up all required fields to continue.")
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MoveToFinalAccount"{
            if let destination = segue.destination as? FinalInfoVC
            {
                
                destination.finalPhone = self.finalPhone
                destination.finalCode = self.finalCode
                destination.finalName = self.finalName
                destination.finalBirthday = self.finalBirthday
                destination.Create_mode = self.Create_mode
                
            }
        }
        
    }
    
    @objc func getBirthday() {
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -8, to: Date())
        dView.BirthdayLbl.inputView = datePicker
        datePicker.addTarget(self, action: #selector(DetailInfoVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dView.BirthdayLbl.text = dateFormatter.string(from: sender.date)

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
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
         
        
    }
    
    func preLoadTutorial() {
        
        let db = DataService.instance.mainFireStoreRef
      
        
        db.collection("Tutorial").order(by: "rank", descending: false).getDocuments {  querySnapshot, error in
         
             guard let snapshot = querySnapshot else {
                 print("Error fetching snapshots: \(error!)")
                 return
             }
         
         if !snapshot.isEmpty {
             
             for item in snapshot.documents {
                
                let tutorial = tutorialModel(postKey: item.documentID, tutorialModel: item.data())
                 
                 if let url = tutorial.url, url != "" {
                     
                     let imageNode = ASNetworkImageNode()
                     imageNode.contentMode = .scaleAspectFit
                     imageNode.shouldRenderProgressImages = true
                     imageNode.url = URL.init(string: url)
                     
                
                 }
                
                
             }
             
            
         }
        
       }
        
        
    }
    
}
