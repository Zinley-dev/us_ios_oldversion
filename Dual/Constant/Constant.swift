//
//  Constant.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/4/20.
//

import Foundation
import Cache
import UIKit
import CoreLocation
import SwiftEntryKit
import Alamofire
import SendBirdCalls
import Firebase
import SendBirdSDK
import SendBirdUIKit
import AlgoliaSearchClient
import SendBirdSDK
import CoreMedia
import AsyncDisplayKit
import StoreKit


var background = false
var global_isLandScape = false
var ifhasNotch = false
var selected_channelUrl: String?
var hideChannelToadd: SBDGroupChannel?
var streaming_domain = [streamingDomainModel]()
var shouldMute = true
var streamingListen: ListenerRegistration!
var notiListen2: ListenerRegistration!
var messageListen: ListenerRegistration!
var maintanenceListen: ListenerRegistration!
var profileDelegateListen: ListenerRegistration!
//
var starListen: ListenerRegistration!
var followListen: ListenerRegistration!
var followingListen: ListenerRegistration!
var notiListen: ListenerRegistration!
var challengeListen: ListenerRegistration!
var challengeListen2: ListenerRegistration!
var MostPlayed_history: ListenerRegistration!


var profileListen: ListenerRegistration!
var profileListen2: ListenerRegistration!

//
var challengevcListen: ListenerRegistration!
var allChallengevcListen: ListenerRegistration!
//
var infoListen: ListenerRegistration!
var videoListen: ListenerRegistration!
var notiChallengeListen: ListenerRegistration!
var availableChatList: ListenerRegistration!
//

var block1: ListenerRegistration!
var block2: ListenerRegistration!
var following: ListenerRegistration!
var addGamefeedvc: ListenerRegistration!
var addGameAddVC: ListenerRegistration!

var pendingChallengeCount: ListenerRegistration!
var activeChallengeCount: ListenerRegistration!
var expireChallengeCount: ListenerRegistration!

var apiKeyInfoListener: ListenerRegistration!

var discord_domain = ["discordapp.com", "discord.com", "discord.co", "discord.gg", "watchanimeattheoffice.com", "dis.gd", "discord.media", "discordapp.net", "discordstatus.com" ]

let unmuteImg = UIImage(named: "3xunmute")?.resize(targetSize: CGSize(width: 32, height: 32))
let muteImg = UIImage(named: "3xmute")?.resize(targetSize: CGSize(width: 32, height: 32))

let pauseImg = UIImage(named: "Pause")?.resize(targetSize: CGSize(width: 32, height: 32))
let playImg = UIImage(named: "Play")?.resize(targetSize: CGSize(width: 32, height: 32))
let xBtn = UIImage(named: "1024x")?.resize(targetSize: CGSize(width: 12, height: 12))

var boundHeight = 0.00
var boundWidth = 0.00

func blurImage(image:UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: image)
        let originalOrientation = image.imageOrientation
        let originalScale = image.scale

        let filter = CIFilter(name: "CIBokehBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(30.0, forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage

        var cgImage:CGImage?

        if let asd = outputImage
        {
            cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
        }

        if let cgImageA = cgImage
        {
            return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
        }

        return nil
    }


func removeAllListen() {
    
    if MostPlayed_history != nil {
        MostPlayed_history.remove()
    }
    
    if messageListen != nil {
        messageListen.remove()
    }
    
    if maintanenceListen != nil {
        maintanenceListen.remove()
    }
    
    if profileDelegateListen != nil {
        profileDelegateListen.remove()
    }
    
    if starListen != nil {
        starListen.remove()
    }
    
    if followListen != nil {
        followListen.remove()
    }
    
    if followingListen != nil {
        followingListen.remove()
    }
    
    if challengeListen != nil {
        challengeListen.remove()
    }
    
    if challengeListen2 != nil {
        challengeListen2.remove()
    }
    
    if profileListen != nil {
        profileListen.remove()
    }
    if profileListen2 != nil {
        profileListen2.remove()
    }
    
    if challengevcListen != nil {
        challengevcListen.remove()
    }
    
    if allChallengevcListen != nil {
        allChallengevcListen.remove()
    }
    
    if infoListen != nil {
        infoListen.remove()
    }
    
    if videoListen != nil {
        videoListen.remove()
    }
    
    if block1 != nil {
        block1.remove()
    }
    
    if block2 != nil {
        block2.remove()
    }
    
    if following != nil {
        following.remove()
    }
    
    if addGamefeedvc != nil {
        addGamefeedvc.remove()
    }
    
    if addGameAddVC != nil {
        
        addGameAddVC.remove()
        
    }
    
    if notiListen != nil {
        notiListen.remove()
    }
    
    if notiChallengeListen != nil {
        notiChallengeListen.remove()
    }
    
    if notiListen2 != nil {
        notiListen2.remove()
    }
    
    if streamingListen != nil {
        streamingListen.remove()
    }

    if availableChatList != nil {
        availableChatList.remove()
    }
    
    if pendingChallengeCount != nil {
        pendingChallengeCount.remove()
    }
    
    if activeChallengeCount != nil {
        activeChallengeCount.remove()
    }
    if expireChallengeCount != nil {
        expireChallengeCount.remove()
    }
    
    if apiKeyInfoListener != nil {
        apiKeyInfoListener.remove()
    }
}

var isHighlightNoti = false
var isChallengeNoti = false
var isCommentNoti = false
var isFollowNoti = false
var isMessageNoti = false
var isCallNoti = false
var isMentionNoti = false
var isSound: Bool?
var isMinimize = false
var isPending_deletion = false
var isSocial = false
var isChallenge = false
var isDiscord = false
//var refId = ""
var sessionId = ""
var isFeedVC = false


var general_call: DirectCall!
var general_room: Room!
var gereral_group_chanel_url: String!

var recommendationId = ""
var impression = [String]()
var global_block_list = [String]()
var global_following_list = [String]()

var global_availableChatList = [String]()


// store all api key info
var api_key_dict = [String: ApiKeyDetail]()
var key_dict = [String: Any]()
var algoliaSearchClient: SearchClient!
var global_avatar_url = ""
var global_username = ""
var global_name = ""
var sendbird_applicationID = "B3325F9F-FB59-4A96-823B-95D176E949C8"

var global_add_list = [AddModel]()


var global_percentComplete:Double = 0.000

typealias DownloadComplete = () -> ()
let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
let movedColor = UIColor(red: 247/255, green: 88/255, blue: 28/255, alpha: 1.0)

extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

}


let diskConfig = DiskConfig(
  // The name of disk storage, this will be used as folder name within directory
  name: "Floppy",
  // Expiry date that will be applied by default for every added object
  // if it's not overridden in the `setObject(forKey:expiry:)` method
  expiry: .date(Date().addingTimeInterval(2*3600)),
  // Maximum size of the disk cache storage (in bytes)
  maxSize: 1000,
  // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
  directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
    appropriateFor: nil, create: true).appendingPathComponent("MyPreferences"),
  // Data protection is used to store files in an encrypted format on disk and to decrypt them on demand
  protectionType: .complete
)

let memoryConfig = MemoryConfig(
  // Expiry date that will be applied by default for every added object
  // if it's not overridden in the `setObject(forKey:expiry:)` method
  expiry: .date(Date().addingTimeInterval(2*60)),
  /// The maximum number of objects in memory the cache should hold
  countLimit: 50,
  /// The maximum total cost that the cache can hold before it starts evicting objects
  totalCostLimit: 0
)


let disksConfig = DiskConfig(name: "Mix")

let dataStorage = try! Storage(
  diskConfig: disksConfig,
  memoryConfig: MemoryConfig(),
  transformer: TransformerFactory.forData()
)
let imageStorage = dataStorage.transformImage()


func timeAgoSinceDate(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(String(describing: components.year)) years"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour"
        } else {
            return "An hour"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) mins"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 min"
        } else {
            return "A min"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "Just now"
    }
    
}


func timeForReloadScheduler(_ date:Date, numericDates:Bool) -> Int {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return 0
    } else if (components.year! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.month! >= 2) {
        return 0
    } else if (components.month! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.weekOfYear! >= 2) {
        return 0
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return 0
        } else {
            return 0
        }
    } else if (components.day! >= 2) {
        return 8640
    } else if (components.day! >= 1){
        if (numericDates){
            return 8640
        } else {
            return 8640
        }
    } else if (components.hour! >= 2) {
        return 360
    } else if (components.hour! >= 1){
        if (numericDates){
            return 360
        } else {
            return 360
        }
    } else if (components.minute! >= 2) {
        return 60
    } else if (components.minute! >= 1){
        if (numericDates){
            return 60
        } else {
            return 60
        }
    } else if (components.second! >= 3) {
        return 1
    } else {
        return 1
    }
    
}

func timeForChat(_ date:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = Date()
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    let lastMessageDateFormatter = DateFormatter()
    lastMessageDateFormatter.dateStyle = .short
    lastMessageDateFormatter.timeStyle = .none
    
    if (components.year! >= 2) {
        return "\(String(describing: components.year)) years"
    } else if (components.year! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months"
    } else if (components.month! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return lastMessageDateFormatter.string(from: date)
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour"
        } else {
            return "An hour"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) mins"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 min"
        } else {
            return "A min"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!)s"
    } else {
        return "Just now"
    }
    
}

func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}


extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


func applyShadowOnView(_ view:UIView) {

    view.layer.cornerRadius = 8
    view.layer.shadowColor = UIColor.lightGray.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize.zero
    view.layer.shadowRadius = 3

}

private var kAssociationKeyMaxLength: Int = 0


extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)
        
        selectedTextRange = selection
    }
}



var pixel_key = "ZFZ7ImsiOiJve3NvYDZKJFY7SjlON01dMWJBIiwidiI6ImY4RkRqIiwiaSI6IjUzIn1yTWZ1"
var env_key = "v9s48ds44jmrgnqgmp666jcpe"
var applicationKey = "2c3ccae1-c080-467b-b989-d1d70aaf159c"
var twApiKey = "4ob6dNOQJPIjz9DQtCiLcD8VY"
var twSecretKey = "mGTOy20I2fhrvvkGsNIRJwKKY7TCywJbrjuaEJexzVrfKeJyqQ"
var should_Play = false
var login_type = ""

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension UIView {

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue

            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }


    func addShadow(shadowColor: CGColor = UIColor.orange.cgColor,
               shadowOffset: CGSize = CGSize(width: 3.0, height: 4.0),
               shadowOpacity: Float = 0.7,
               shadowRadius: CGFloat = 4.5) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

extension UIView {
    func addBottomBorderWithColor(color: UIColor, height: CGFloat, width: CGFloat) -> CALayer {
        
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - height,
                              width: width, height: height)
        
        
        return border
        
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}


public enum Model : String {

    case simulator     = "simulator",

    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",

    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPadAir3           = "iPad Air 3",
    iPad5              = "iPad 5",
    iPad6              = "iPad 6",
    iPad7              = "iPad 7",

    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    iPadMini5          = "iPad Mini 5",

    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro11          = "iPad Pro 11\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    iPadPro3_12_9      = "iPad Pro 3 12.9\"",

    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6Plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6SPlus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7Plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8Plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    iPhone11           = "iPhone 11",
    iPhone11Pro        = "iPhone 11 Pro",
    iPhone11ProMax     = "iPhone 11 Pro Max",
    iPhoneSE2          = "iPhone SE 2nd gen",
    iPhone12Mini       = "iPhone 12 Mini",
    iPhone12           = "iPhone 12",
    iPhone12Pro        = "iPhone 12 Pro",
    iPhone12ProMax     = "iPhone 12 Pro Max",

    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

public extension UIDevice {

    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }

        let modelMap : [String: Model] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,

            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,

            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad6,11"  : .iPad5,
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6,
            "iPad7,6"   : .iPad6,
            "iPad7,11"  : .iPad7,
            "iPad7,12"  : .iPad7,

            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            "iPad11,1"  : .iPadMini5,
            "iPad11,2"  : .iPadMini5,

            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            "iPad8,1"   : .iPadPro11,
            "iPad8,2"   : .iPadPro11,
            "iPad8,3"   : .iPadPro11,
            "iPad8,4"   : .iPadPro11,
            "iPad8,5"   : .iPadPro3_12_9,
            "iPad8,6"   : .iPadPro3_12_9,
            "iPad8,7"   : .iPadPro3_12_9,
            "iPad8,8"   : .iPadPro3_12_9,

            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad11,3"  : .iPadAir3,
            "iPad11,4"  : .iPadAir3,

            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6Plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax,

            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
            
        ]

        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        
        return Model.unrecognized
        
    }
}

extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970) / 10)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
}

func formatPoints(num: Double) ->String{
    var thousandNum = num/1000
    var millionNum = num/1000000
    if num >= 1000 && num < 1000000{
        if(floor(thousandNum) == thousandNum){
            return("\(Int(thousandNum))K")
        }
        return("\(thousandNum.roundToPlaces(places: 1))k")
    }
    if num > 1000000{
        if(floor(millionNum) == millionNum){
            return("\(Int(thousandNum))K")
        }
        return ("\(millionNum.roundToPlaces(places: 1))M")
    }
    if num > 1000000000{
        if(floor(millionNum) == millionNum){
            return("\(Int(thousandNum))M")
        }
        return ("\(millionNum.roundToPlaces(places: 1))B")
    }
    else{
        if(floor(num) == num){
            return ("\(Int(num))")
        }
        return ("\(num)")
    }

}

func showNote(text: String) {
    
    var attributes = EKAttributes.topNote
    attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.1), scale: .init(from: 1, to: 0.7, duration: 0.2)))
    attributes.entryBackground = .color(color: .musicBackground)
    attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
    attributes.statusBar = .dark
    attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
    attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
    
    
    let style = EKProperty.LabelStyle(
        font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
        color: .white,
        alignment: .center
    )
    let labelContent = EKProperty.LabelContent(
        text: text,
        style: style
    )
    let contentView = EKNoteMessageView(with: labelContent)
    SwiftEntryKit.display(entry: contentView, using: attributes)
    
}

func getCurrentMillis()->Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 120, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"Roboto-Regular",size: 15)!
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 120, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 3
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"Roboto-Regular",size: 15)!
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
       
    }

    func restore() {
        self.backgroundView = nil
    }
    
    
    
}



func calculateMedian(array: [Int]) -> Double {
    // Array should be sorted
    let sorted = array.sorted()
    let length = array.count
    
    // handle when count of items is even
    if (length % 2 == 0) {
        return (Double(sorted[length / 2 - 1]) + Double(sorted[length / 2])) / 2.0
    }
    
    // handle when count of items is odd
    return Double(sorted[length / 2])
}


extension UINavigationBar {

    @IBInspectable var bottomBorderColor: UIColor {
        get {
            return self.bottomBorderColor;
        }
        set {
            let bottomBorderRect = CGRect.zero;
            let bottomBorderView = UIView(frame: bottomBorderRect);
            bottomBorderView.backgroundColor = newValue;
            addSubview(bottomBorderView);

            bottomBorderView.translatesAutoresizingMaskIntoConstraints = false;

            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0));
            self.addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 1));
        }

    }

}

extension Array where Element : Equatable  {
    public mutating func removeObject(_ item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /*
    subscript (exists index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
     */
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}


extension UINavigationController {

    func popBack(_ nb: Int) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < nb else {
            self.popToViewController(viewControllers[viewControllers.count - nb], animated: true)
            return
        }
    }

    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        var viewControllers: [UIViewController] = self.viewControllers
        viewControllers = viewControllers.reversed()
        for currentViewController in viewControllers {
            if currentViewController .isKind(of: toControllerType) {
                self.popToViewController(currentViewController, animated: true)
                break
            }
        }
    }

 }

extension UIViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension UIButton {
    
    func beat() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        layer.add(pulse, forKey: nil)
    
    
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.9
        animation.values = [-5.0, 5.0, -5.0, 5.0, -5.0, 2.0, -1.0, 1.0, 0.0 ]
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shake")
    }
    
    
    
    
    func removeAnimation() {
        
        layer.removeAllAnimations()
        
    }

}

@IBDesignable extension UIView {
    @IBInspectable var borderColors: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidths: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
}


@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable override var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

@IBDesignable
class UISwitchCustom: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}

extension String {
    func findMHashtagText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{L}\\p{N}]*)", options: [.useUnicodeWordBoundaries, .caseInsensitive])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
    
    func findMentiontagText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(@[a-zA-Z0-9_\\p{L}\\p{N}]*)", options: [.useUnicodeWordBoundaries, .caseInsensitive])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}



func findUserIndexFromArray(userUID: String, arr: [String]) -> Int {
    
    var count = 0
    for item in arr {
        
        
        if item == userUID {
            return count
        }
        
        count+=1
        
    }
    
    return count
    
}

extension String{

    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)

        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

}

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    
    return false
}

extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        let custom: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 13)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let subtitleString = NSMutableAttributedString(string: subtitle!, attributes: custom)
        
        
        alert.setValue(subtitleString, forKey: "attributedMessage")
        
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showCodeDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        
        let custom: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 13)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let subtitleString = NSMutableAttributedString(string: subtitle!, attributes: custom)
        
        
        alert.setValue(subtitleString, forKey: "attributedMessage")
        
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action:UIAlertAction) in
            
            
            actionHandler?("Skip Code")
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

func getReadableDate(timeStamp: TimeInterval) -> String? {
    let date = Date(timeIntervalSince1970: timeStamp)
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .long
    dateFormatter.dateStyle = .short
    return dateFormatter.string(from: date)
}

func dateFallsInCurrentWeek(date: Date) -> Bool {
    let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
    let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
    return (currentWeek == datesWeek)
}


extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
    
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension UIImage {

    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

func check_Url(host: String) -> Bool {
    
    
    for item in streaming_domain {
        
        if item.domain.contains(host) {
            
            return true
            
        }
        
    }
    
    return false
    
}


func discord_verify(host: String) -> Bool  {
    
    if discord_domain.contains(host) {
        return true
    }
    
    return false
}


func activeSpeaker() {
    
    do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
    
}



func addToAvailableChatList(uid: [String]) {
    
    if Auth.auth().currentUser?.uid != nil {
        
        let db = DataService.instance.mainFireStoreRef
        db.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    if let Available_Chat_List = item["Available_Chat_List"] as? [String] {
                        
                        var list = Available_Chat_List
                        
                        for user in uid {
                            
                            if !list.contains(user) {
                                list.append(user)
                            }
                            
                        }
                        
                     
                       db.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["Available_Chat_List": list])
                        
                        
                    } else {
                        
                        
                        if !uid.isEmpty {
                            db.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["Available_Chat_List": uid])
                        }
                       
                    
                            
                        }
                    
                }
                
            }
            
        
                
            }
        
        
    }
    

}
//Auth.auth().currentUser!.uid
func addToUserAvailableChatList(uid: String) {
    
    let db = DataService.instance.mainFireStoreRef
    
    db.collection("Users").document(uid).getDocument {  querySnapshot, error in
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            return
        }
        
        if snapshot.exists {
            
            if let item = snapshot.data() {
                
                if let Available_Chat_List = item["Available_Chat_List"] as? [String] {
                    
                    var list = Available_Chat_List
                    
                    if !list.contains(Auth.auth().currentUser!.uid) {
                        list.append(Auth.auth().currentUser!.uid)
                    }
                    
                 
                   db.collection("Users").document(uid).updateData(["Available_Chat_List": list])
                    
                    
                } else {
                    
                    
                    if !uid.isEmpty {
                        db.collection("Users").document(uid).updateData(["Available_Chat_List": [Auth.auth().currentUser!.uid]])
                    }
                   
                
                    
                }
                
                
            }
            
            
        }
        
        
        
        
        
    }
    
    
}

extension UITableViewRowAction {

  func setIcon(iconImage: UIImage, backColor: UIColor, cellHeight: CGFloat, iconSizePercentage: CGFloat)
  {
    let iconHeight = cellHeight * iconSizePercentage
    let margin = (cellHeight - iconHeight) / 2 as CGFloat

    UIGraphicsBeginImageContextWithOptions(CGSize(width: cellHeight, height: cellHeight), false, 0)
    let context = UIGraphicsGetCurrentContext()

    backColor.setFill()
    context!.fill(CGRect(x:0, y:0, width:cellHeight, height:cellHeight))

    iconImage.draw(in: CGRect(x: margin, y: margin, width: iconHeight, height: iconHeight))

    let actionImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundColor = UIColor.init(patternImage: actionImage!)
  }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UITableView {
    func reloadData(with animation: UITableView.RowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}

func update_unique_video_searchWords_collection(keyword: String) {
    
    DataService.instance.mainFireStoreRef.collection("Unique_video_searchWords").whereField("searchWord", isEqualTo: keyword).getDocuments { querySnapshot, error in
                 
        guard querySnapshot != nil else {
            print("Error fetching snapshots: \(error!)")
            return
        }
        
        if querySnapshot?.isEmpty == true {
            
            
            let searchWords_dict = ["searchWord": keyword as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp(), "update_timeStamp": FieldValue.serverTimestamp()]
            
            DataService.instance.mainFireStoreRef.collection("Unique_video_searchWords").addDocument(data: searchWords_dict)
            
        } else {
            
            for item in querySnapshot!.documents {
                
                
                DataService.instance.mainFireStoreRef.collection("Unique_video_searchWords").document(item.documentID).updateData(["update_timeStamp": FieldValue.serverTimestamp()])
                
            }
            
            
        }
    }
    
    
}

func upload_video_searchWords_collection(keyword: String) {
    
    let searchWords_dict = ["searchWord": keyword as Any, "createBy_userUID": Auth.auth().currentUser!.uid as Any, "timeStamp": FieldValue.serverTimestamp()]
    
    DataService.instance.mainFireStoreRef.collection("Video_searchWords").addDocument(data: searchWords_dict)
    
    
}

func recoverAllPost(userUID: String) {
    
    let db = DataService.instance.mainFireStoreRef
    
    db.collection("Highlights").whereField("userUID", isEqualTo: userUID).whereField("h_status", isEqualTo: "Terminated").getDocuments{ querySnapshot, error in
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            return
        }
    
        if snapshot.isEmpty != true {
            
            for item in snapshot.documents {
                
                let highlightItem = HighlightsModel(postKey: item.documentID, Highlight_model: item.data())
                     
                if highlightItem.status != "Deleted" {
                    
                    
                    db.collection("Highlights").document(highlightItem.highlight_id).updateData(["h_status": "Ready"])
                    
                }
                
                
            }
           
            
        }
    
    }
    
}

func recoverAllFollower(userUID: String) {
    
    let db = DataService.instance.mainFireStoreRef
    
    db.collection("Follow").whereField("Follower_uid", isEqualTo: userUID).whereField("status", isEqualTo: "Terminated").getDocuments{ querySnapshot, error in
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            return
        }
    
        if snapshot.isEmpty != true {
            
            for item in snapshot.documents {
                
                db.collection("Follow").document(item.documentID).updateData(["status": "Valid"])
                
                
            }
           
            
        }
    
    }
    
}


func recoverAllFollowing(userUID: String) {
    
    let db = DataService.instance.mainFireStoreRef
    
    db.collection("Highlights").whereField("Following_uid", isEqualTo: userUID).whereField("status", isEqualTo: "Terminated").getDocuments{ querySnapshot, error in
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            return
        }
    
        if snapshot.isEmpty != true {
            
            for item in snapshot.documents {
                
                db.collection("Follow").document(item.documentID).updateData(["status": "Valid"])
                
            }
            
        }
     
    }
    
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    
    
   
    
    
}


extension CGFloat {
    func toInt() -> Int? {
        if self > CGFloat(Int.min) && self < CGFloat(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}



func resumeVideoIfNeed() {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
            
                
                if update1.currentIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.currentIndex, section: 0)) as? PostNode {
                        
                        
                        if cell.currentTimeStamp != nil {
                                                    
                                                    cell.videoNode.currentItem?.seek(to: CMTimeMakeWithSeconds(cell.currentTimeStamp, preferredTimescale: Int32(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) {
                                                         finished in
                                                        
                                                        cell.videoNode.play()
                                                        
                                                    }
                                                   
                                                } else {
                                                    cell.videoNode.play()
                                                }

                        cell.animatedLabel.restartLabel()
                       
                        
                        
                        
                        if cell.is_challenge == true {
                            
                            cell.ButtonView.challengeBtn.beat()
                            
                        }
                     
                        
                    }
                   
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if update2.currentIndex != nil {
                    
                    if update2.currentIndex != nil {
                        
                        if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: update2.currentIndex, section: 0)) as? PostNode {
                            
                            if cell.currentTimeStamp != nil {
                                                        
                                                        cell.videoNode.currentItem?.seek(to: CMTimeMakeWithSeconds(cell.currentTimeStamp, preferredTimescale: Int32(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) {
                                                             finished in
                                                            
                                                            cell.videoNode.play()
                                                            
                                                        }
                                                       
                                                    } else {
                                                        cell.videoNode.play()
                                                    }
                            cell.animatedLabel.restartLabel()

                            if cell.is_challenge == true {
                                
                                cell.ButtonView.challengeBtn.beat()
                                
                            }
                            
                           
                            if cell.is_challenge == true {
                                cell.ButtonView.challengeBtn.beat()
                            }
                          
                            
                        }
                       
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
    
}



func unmuteVideoIfNeed() {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
                if update1.currentIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.currentIndex, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            if cell.videoNode.muted == true {
                                cell.videoNode.muted = false
                            
                                cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                                cell.ButtonView.soundLbl.text = "Sound on"
                                
                                shouldMute = false
                                
                                let imgView = UIImageView()
                                imgView.image = UIImage(named: "3xunmute")
                                imgView.frame.size = CGSize(width: 50, height: 50)
                                imgView.center = cell.view.center
                                cell.view.addSubview(imgView)
                                
                                
                                imgView.transform = CGAffineTransform.identity
                                
                                UIView.animate(withDuration: 1) {
                                    
                                    imgView.alpha = 0
                                    
                                }
                                
                            }
                        }
                        
                    }
                   
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if update2.currentIndex != nil {
                    
                    if update2.currentIndex != nil {
                        
                        if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: update2.currentIndex, section: 0)) as? PostNode {
                            
                            if cell.videoNode.isPlaying() {
                                if cell.videoNode.muted == true {
                                    cell.videoNode.muted = false
                                
                                    cell.ButtonView.soundBtn.setImage(unmuteImg, for: .normal)
                                    cell.ButtonView.soundLbl.text = "Sound on"
                                    shouldMute = false
                                    
                                    let imgView = UIImageView()
                                    imgView.image = UIImage(named: "3xunmute")
                                    imgView.frame.size = CGSize(width: 50, height: 50)
                                    imgView.center = cell.view.center
                                    cell.view.addSubview(imgView)
                                    
                                    
                                    imgView.transform = CGAffineTransform.identity
                                    
                                    UIView.animate(withDuration: 1) {
                                        
                                        imgView.alpha = 0
                                        
                                    }
                                }
                            }
                            
                        }
                       
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
    
}

func recordStreamLinkTap(category: String, link: String, ownerUID: String) {
    
    if category != "", link != "", ownerUID != "" {
        
        
        if let url = URL(string: link) {
            
            if let domain = url.host {
                
           
                let data = ["category": category, "link": link, "timeStamp": FieldValue.serverTimestamp(), "domain": domain, "ownerUID": ownerUID, "userUID": Auth.auth().currentUser!.uid, "Device": UIDevice().type.rawValue] as [String : Any]
                
             
                DataService.instance.mainFireStoreRef.collection("Stream_link_record").addDocument(data: data) { err in
                    
                    if err != nil {
                        
                        print(err!.localizedDescription)
                        
                    }
                }
                
                
            }
            
            
        }
        
 
    }
    

}


func pausePreviousVideoIfNeed(pauseIndex: Int) {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.videoNode.isPlaying() {
                        
                        //cell.videoNode.player?.seek(to: CMTime.zero)
                        cell.videoNode.pause()
                        //cell.videoNode.player?.seek(to: CMTime.zero)
                    
                    }
                    
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.videoNode.isPlaying() {
                        
                        //cell.videoNode.player?.seek(to: CMTime.zero)
                        cell.videoNode.pause()
                        //cell.videoNode.player?.seek(to: CMTime.zero)
                       
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
}

func playPreviousVideoIfNeed(playIndex: Int) {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        cell.videoNode.play()
                      
                    }
                    
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        cell.videoNode.play()
                        
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
}

func muteVideoIfNeed() {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
                if update1.currentIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.currentIndex, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            if cell.videoNode.muted == false {
                                cell.videoNode.muted = true
                            
                                cell.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                                cell.ButtonView.soundLbl.text = "Sound off"
                                shouldMute = true
                                
                                let imgView = UIImageView()
                                imgView.image = UIImage(named: "3xmute")
                                imgView.frame.size = CGSize(width: 50, height: 50)
                                imgView.center = cell.view.center
                                cell.view.addSubview(imgView)
                                
                                
                                imgView.transform = CGAffineTransform.identity
                                
                                UIView.animate(withDuration: 1) {
                                    
                                    imgView.alpha = 0
                                    
                                }
                                
                            }
                        }
                        
                    }
                   
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if update2.currentIndex != nil {
                    
                    if update2.currentIndex != nil {
                        
                        if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: update2.currentIndex, section: 0)) as? PostNode {
                            
                            if cell.videoNode.isPlaying() {
                                if cell.videoNode.muted == false {
                                    cell.videoNode.muted = true
                                    shouldMute = true
                                    cell.ButtonView.soundBtn.setImage(muteImg, for: .normal)
                                    cell.ButtonView.soundLbl.text = "Sound off"
                                    
                                    let imgView = UIImageView()
                                    imgView.image = UIImage(named: "3xmute")
                                    imgView.frame.size = CGSize(width: 50, height: 50)
                                    imgView.center = cell.view.center
                                    cell.view.addSubview(imgView)
                                    
                                    
                                    imgView.transform = CGAffineTransform.identity
                                    
                                    UIView.animate(withDuration: 1) {
                                        
                                        imgView.alpha = 0
                                        
                                    }
                                }
                            }
                            
                        }
                       
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
    
}

func pauseVideoIfNeed() {
    
    
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedVC {
            
            if let update1 = vc as? FeedVC {
                
            
                
                if update1.currentIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.currentIndex, section: 0)) as? PostNode {
                        
                        
                        cell.videoNode.pause()
                       
                    }
                   
                }
                
            }
            
        } else if vc is UserHighlightFeedVC {
            
            if let update2 = vc as? UserHighlightFeedVC {
                
                if update2.currentIndex != nil {
                    
                    if update2.currentIndex != nil {
                        
                        if let cell = update2.collectionNode.nodeForItem(at: IndexPath(row: update2.currentIndex, section: 0)) as? PostNode {
                            
                            cell.videoNode.pause()
                           
                        }
                       
                    }
                    
                }
                
            }
            
            
        }
             
        
    }
    
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }

    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}

func getThumbnailString(post: HighlightsModel) -> String? {
    
    if let id = post.Mux_playbackID, id != "nil" {
        
        let urlString = "https://image.mux.com/\(id)/thumbnail.png?smart_crop=true&time=1"
        
        return urlString
        
    } else {
        
        return nil
        
    }
    
}


func getThumbnailStringFromMux_playbackID(Mux_playbackID: String) -> String? {
    
    let urlString = "https://image.mux.com/\(Mux_playbackID)/thumbnail.png?smart_crop=true&time=1"
    
    return urlString
    
}

func getVideoURL(post: HighlightsModel) -> URL? {
    
    if let id = post.Mux_playbackID, id != "nil" {
        
        let urlString = "https://stream.mux.com/\(id).m3u8"
        
        return URL(string: urlString)
        
    } else {
        
        return nil
        
    }
    
   
}



func removeFCMToken(userUID: String, completed: @escaping DownloadComplete) {
    
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
          completed()
      } else if let token = token {
        print("FCM registration token: \(token)")
          
          if Auth.auth().currentUser?.uid != nil {
              
              DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { querySnapshot, error in
                  guard let snapshot = querySnapshot else {
                      print("Error fetching snapshots: \(error!)")
                      return
                  }
                  
                  if snapshot.exists {
                      
                      if let item = snapshot.data() {
                          
                          if let fcm_tokenList = item["FCM_Token_List"] as? [String] {

                              if fcm_tokenList.contains(token) {
                                  
                                  let index = findIndex(target: token, list: fcm_tokenList)
                                  var new_token_list = fcm_tokenList
                                  new_token_list.remove(at: index)
                                  
                                  
                                  DataService.instance.mainFireStoreRef.collection("Users").document(Auth.auth().currentUser!.uid).updateData(["FCM_Token_List": new_token_list]) { (err) in
                                      if err != nil {
                                          print(err!.localizedDescription)
                                          completed()
                                          return
                                      }
                                      
                                      completed()
                                      print("Update fcm token to server with userUID: \(userUID)  token: \(token)")
                                  }
                                  
                                  
                              } else {
                                  completed()
                              }
                          } else {
                              completed()
                          }
                          
                      }
                      
                  } else {
                      completed()
                  }
                  
              }
              
              
          } else {
              completed()
          }
                
        
            }

        }
      
}


func checkregistrationTokenAndPerformUpload(token: String) {
     
    print("Attempt to register token: \(token)")
    if Auth.auth().currentUser != nil {
        
        if !Auth.auth().currentUser!.isAnonymous  {
            
            
            if let userUID = Auth.auth().currentUser?.uid {
                
                
                DataService.instance.mainFireStoreRef.collection("Users").document(userUID).getDocument { querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshot.exists {
                        
                        if let item = snapshot.data() {
                            
                            if let fcm_tokenList = item["FCM_Token_List"] as? [String] {
                                
                                if !fcm_tokenList.contains(token) {
                                    
                                   
                                    var new_fcm_tokenList = fcm_tokenList
                                    new_fcm_tokenList.append(token)
                                   
                                    
                                    DataService.instance.mainFireStoreRef.collection("Users").document(userUID).updateData(["FCM_Token_List": new_fcm_tokenList]) { (err) in
                                        if err != nil {
                                            print(err!.localizedDescription)
                                            return
                                        }
                                        
                                        print("Update fcm token to server with userUID: \(userUID)  token: \(token)")
                                    }
                                    
                                    
                                }
                                
                                
                            } else {
                                
                                let FCM_Token_List = [token]
                                
                                DataService.instance.mainFireStoreRef.collection("Users").document(userUID).updateData(["FCM_Token_List": FCM_Token_List]) { (err) in
                                    if err != nil {
                                        print(err!.localizedDescription)
                                        return
                                    }
                                    
                                    print("First push fcm token to server with userUID: \(userUID)  token: \(token)")
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                
                    
                }
                
                
            }
            
            
        }
        
        
    }
    
}


func checkAndRegisterForFCMDict(token: String) {
    

   if Auth.auth().currentUser != nil {
       
       if !Auth.auth().currentUser!.isAnonymous  {
           
           
           if let userUID = Auth.auth().currentUser?.uid {
               
               
               DataService.instance.mainFireStoreRef.collection("FCM_Dict").whereField("Token", isEqualTo: token).whereField("userUID", isEqualTo: userUID).getDocuments { (snap, err) in
                   
                   if err != nil {
                       print("Can't find user with \(userUID)")
                       return
                   }
                   
                   if snap?.isEmpty != true {
                       
                       for item in snap!.documents {
                           

                           DataService.instance.mainFireStoreRef.collection("FCM_Dict").document(item.documentID).updateData(["timeStamp": FieldValue.serverTimestamp()])
                           
                           
                           
                       }
                       
                   } else {
                       
                       
                       let FCM_Token_Dict = ["Token": token, "timeStamp": FieldValue.serverTimestamp(), "userUID": userUID] as [String : Any]
                       DataService.instance.mainFireStoreRef.collection("FCM_Dict").addDocument(data: FCM_Token_Dict) { err in
                           if err != nil {
                               print(err!.localizedDescription)
                               return
                           }
                       }
                        
                   }
                   
                   
                   
                   
               }
               
               
               
           }
           
           
       }
       
       
   }
    
    
}


func loadInActiveFCMToken() {
    
    if Auth.auth().currentUser != nil {
        
        if !Auth.auth().currentUser!.isAnonymous  {
            
            if let userUID = Auth.auth().currentUser?.uid {
                
                let current = getCurrentMillis()
                let comparedDate = current - (100 * 60 * 60 * 1000)
                let myNSDate = Date(timeIntervalSince1970: TimeInterval(Int(comparedDate/1000)))
                
                var tokens = [String]()
                
                DataService.instance.mainFireStoreRef.collection("FCM_Dict").whereField("userUID", isEqualTo: userUID).whereField("timeStamp", isGreaterThan: myNSDate).getDocuments { (snap, err) in
                    
                    if err != nil {
                        print("Can't find user with \(userUID)")
                        return
                    }
                    
                    if snap?.isEmpty != true {
                        
                        for item in snap!.documents {
                            

                            if let token = item.data()["Token"] as? String {
                                
                                tokens.append(token)
                                
                            }
                            
                            
                            
                        }
                        
                        if !tokens.isEmpty {
                            removeInActiveFCMToken(tokens: tokens) {
                                print("Done removing")
                            }
                        }
                    
                        
                    }
                    
                }
                
                
                
            }
            
            
        }
        
        
    }
    
    
}

func removeInActiveFCMToken(tokens: [String], completed: @escaping DownloadComplete) {
    
   if Auth.auth().currentUser != nil {
       
       if !Auth.auth().currentUser!.isAnonymous  {
           
           
           if let userUID = Auth.auth().currentUser?.uid {
               
               
               DataService.instance.mainFireStoreRef.collection("Users").document(userUID).getDocument { querySnapshot, error in
                   
                   guard let snapshot = querySnapshot else {
                       print("Error fetching snapshots: \(error!)")
                       return
                   }
                   
                   if snapshot.exists {
                       
                       if let item = snapshot.data() {
                           
                           if let fcm_tokenList = item["FCM_Token_List"] as? [String] {
                               
                               var updated_fcm_tokenList = fcm_tokenList
                               
                               for token in updated_fcm_tokenList {
                                   
                                   if !tokens.contains(token) {
                                       updated_fcm_tokenList.removeObject(token)
                                   }
                                   
                               }
                               
                               
                               DataService.instance.mainFireStoreRef.collection("Users").document(userUID).updateData(["FCM_Token_List": updated_fcm_tokenList]) { (err) in
                                   if err != nil {
                                       print(err!.localizedDescription)
                                       completed()
                                       return
                                   }
                                      
                               }
                                 
                           }
                           
                       } else {
                           completed()
                       }
                       
                   } else {
                       completed()
                   }
                    
               }
               
           }
           
           
       }
       
       
   }
    
    
}
 

func removetargetFCMToken(completed: @escaping DownloadComplete) {
    
    if Auth.auth().currentUser != nil {
        
        if !Auth.auth().currentUser!.isAnonymous  {
            
            
            if let userUID = Auth.auth().currentUser?.uid {
                
                Messaging.messaging().token { token, error in
                  if let error = error {
                    completed()
                    print("Error fetching FCM registration token: \(error)")
                  } else if let token = token {
                    print("FCM removing token: \(token)")
                      
                      DataService.instance.mainFireStoreRef.collection("FCM_Dict").whereField("Token", isEqualTo: token).whereField("userUID", isEqualTo: userUID).getDocuments { (snap, err) in
                          
                          if err != nil {
                              completed()
                              print("Can't find user with \(userUID)")
                              return
                          }
                          
                          if snap?.isEmpty != true {
                              
                              for item in snap!.documents {
                                  

                                  DataService.instance.mainFireStoreRef.collection("FCM_Dict").document(item.documentID).delete()
                                  completed()
                                  
                                  
                              }
                              
                          } else {
                              completed()
                          }
                          
                      }
                      
                      
                  }
                    
                }
                
                
                
                
                
            } else {
                completed()
            }
            
            
        } else {
            completed()
        }
        
        
    } else {
        completed()
    }
    
    
}

func findIndex(target: String, list: [String]) -> Int{
    
    var count = 0
    
    for item in list {
        
        if item == target {
            
            break
            
        }
        
        count+=1
    }
    
    return count
    
}

/*
func addFollowPostIntoFollowee(targetUID: String) {
    
    var list  = [[String: Any]]()
    
    DataService.instance.mainFireStoreRef.collection("Highlights").whereField("userUID", isEqualTo: targetUID).getDocuments { (snap, err) in
        
        if err != nil {
            
            print(err!.localizedDescription)
            return
        }
        
        if snap?.isEmpty != true {
            
            for item in snap!.documents {
                
                let dict = ["postDocId": item.documentID,
                            "postUID": item.data()["userUID"],
                                "createdTimeStamp": item.data()["post_time"],
                                "updatedTimeStamp": item.data()["updatedTimeStamp"],
                                "category": item.data()["category"]]
                list.append(dict as [String : Any])
                
                
            }
            
            if !list.isEmpty {
                addPost(list: list)
            }
            
        } else {
           
            print("No items")
            
        }
        
    }
    
    
}
 */

func addPost(list: [[String: Any]]) {
  
    for item in list {
        
        
        if let userUID = Auth.auth().currentUser?.uid {
            
            DataService.instance.mainFireStoreRef.collection("Users").document(userUID).collection("FolloweePost").addDocument(data: ["createdTimeStamp": item["createdTimeStamp"]!, "category": item["category"]!, "postUID": item["postUID"]!, "postDocId": item["postDocId"]!]) { err in
               
               if err != nil {
                   
                   print(err!.localizedDescription)
                   return
               }
               
              
             
               print("Writting successfull")
           }
            
        }
        
       
    }
    
   
}

/*
func removeFollowPostIntoFollowee(targetUID: String) {
    
    if let userUID = Auth.auth().currentUser?.uid {
        
        DataService.instance.mainFireStoreRef.collection("Users").document(userUID).collection("FolloweePost").whereField("postUID", isEqualTo: targetUID).getDocuments { (snap, err) in
            
            if err != nil {
              
                return
            }
            
            
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    DataService.instance.mainFireStoreRef.collection("Users").document(userUID).collection("FolloweePost").document(item.documentID).delete { err in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        
                        if let vc = UIViewController.currentViewController() {
                            
                            
                            if vc is FollowerVC {
                                
                                if let update1 = vc as? FollowerVC {
                                    update1.updateFollowingCount()
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            
            
        }
        
    }
    
    
    
    
}*/

func removeUnFollowUserDaily() {
    
    if let userUID = Auth.auth().currentUser?.uid {
        
        DataService.instance.mainFireStoreRef.collection("Users").document(userUID).collection("FolloweePost").getDocuments { (snap, err) in
            
            if err != nil {
                
               
                return
            }
            
            
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
     
                    if let ownerUID = item.data()["postUID"] as? String {
                        
                        if ownerUID != Auth.auth().currentUser?.uid {
                            
                            if !global_following_list.contains(ownerUID) {
                                
                                
                                DataService.instance.mainFireStoreRef.collection("Users").document(userUID).collection("FolloweePost").document(item.documentID).delete { err in
                                    if err != nil {
                                        print(err!.localizedDescription)
                                    }
                                    
                                    
                                }
                                
                                
                            }
                                 
                        }
                            
                    }
                      
                }
                
                
            }
            
            
            
        }
        
        
    }
        
  

}


protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 0.5) {
        // create effect
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)

        // set boundry and alpha
        //effectView.frame = self.bounds
        //effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = alpha

        self.addSubview(effectView)
        
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
    }
}

enum AppStoreReviewManager {
  static func requestReviewIfAppropriate() {
      SKStoreReviewController.requestReview()
  }
}

// Conformance
extension UIView: Bluring {}


func checkUserCreateTimeAndPerformRateRequest() {
    
    
    if let cuid = Auth.auth().currentUser?.uid {
        
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Users").document(cuid).getDocument {  querySnapshot, error in
             guard let snapshot = querySnapshot else {
                 print("Error fetching snapshots: \(error!)")
                 return
             }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    
                    if let is_suspend = item["is_suspend"] as? Bool {
                        
                        if is_suspend == true {
                         
                        
                         
                        } else {
                         
                            
                            if let create_time = item["create_time"] as? Timestamp {
                                
                                if (NSDate().timeIntervalSince1970 - create_time.dateValue().timeIntervalSince1970) >= (60 * 60 * 24 * 14) {
                                    
                                    
                                    if let rateTime = item["rateTime"] as? Timestamp {
                                        
                                        
                                        if (NSDate().timeIntervalSince1970 - rateTime.dateValue().timeIntervalSince1970) >= (60 * 60 * 24 * 70) {
                                            
                                            AppStoreReviewManager.requestReviewIfAppropriate()
                                            db.collection("Users").document(cuid).updateData(["rateTime": FieldValue.serverTimestamp()])
                                            
                                        }
                                        
                                        
                                    } else {
                                        
                                        AppStoreReviewManager.requestReviewIfAppropriate()
                                        db.collection("Users").document(cuid).updateData(["rateTime": FieldValue.serverTimestamp()])
                                        
                                        
                                    }
                                  
                                    
                                }
                                        
                            }
                           
                         
                        }
                     
                    }
                    
                    
                }
               
                
            }
         
    
        }
        
        
    }
    
    
}

