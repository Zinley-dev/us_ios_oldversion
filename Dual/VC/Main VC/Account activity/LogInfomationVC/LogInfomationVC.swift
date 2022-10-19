//
//  LogInfomationVC.swift
//  The Dual
//
//  Created by Khoi Nguyen on 5/27/21.
//

import UIKit
import GoogleMaps
import Alamofire

class LogInfomationVC: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var regionLbl: UILabel!
    @IBOutlet weak var IPLbl: UILabel!
    @IBOutlet weak var DeviceLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    var marker = GMSMarker()
    
    var item: UserActivityModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        styleMap()
        DeviceLbl.text = item.Device

        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(item.Query)
                                  
        AF.request(urls, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                                        
                switch responseJSON.result {
                                            
                    case .success(let json):
                                            
                        if let dict = json as? Dictionary<String, Any> {
                                                
                            if let status = dict["status"] as? String, status == "success" {
                                                    
                                if let regionName = dict["regionName"] as? String, let lat = dict["lat"] as? CLLocationDegrees, let lon = dict["lon"] as? CLLocationDegrees, let query = dict["query"] as? String {
                                    
                                    
                                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    self.centerMapOnUserLocation(location: location)
                                    self.regionLbl.text = regionName
                                    self.IPLbl.text = query
                                }
                                               

                            } else {
                                
                                self.IPLbl.text = self.item.Query
                                self.regionLbl.text = "Private range"
                                
                            }
                        }
                                            
                    case .failure(let error):
                      
                        print(error.localizedDescription)
                                           
                                            
              
                    }
                                        
        }
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timeLbl.text = dateFormatterGet.string(from: item.timeStamp.dateValue())
        
        
        
        
        
        
        
        if item.Action == "Create" {
            
            actionLbl.text = "Your account is created"
        
        } else if item.Action == "Update" {
               
            if let info = item.info {
                
                actionLbl.text = "Updated \(info.lowercased())"
                
            }
                         
        } else if item.Action == "Login" {
            
            actionLbl.text = "Login"
            
        } else if item.Action == "Logout" {
            
            actionLbl.text = "Logout"
            
            
        }
        
        
        
    }
    
    
    func centerMapOnUserLocation(location: CLLocationCoordinate2D) {
           

           // get MapView
           let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
           

           self.marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        
           marker.position = location
        
           marker.map = mapView
           mapView.camera = camera
           mapView.animate(to: camera)
           marker.appearAnimation = GMSMarkerAnimation.pop
           
           
           marker.isTappable = false
              
    }
    
    func styleMap() {
    
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "customizedMap", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    
    
    
    }
    
    @IBAction func back1BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    

}
