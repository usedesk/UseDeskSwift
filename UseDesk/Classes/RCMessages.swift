//
//  RCMessages.swift

import Foundation
import AVFoundation
import CoreLocation
import MapKit
import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let RC_TYPE_STATUS = 1
let RC_TYPE_TEXT = 2
let RC_TYPE_EMOJI = 3
let RC_TYPE_PICTURE = 4
let RC_TYPE_VIDEO = 5
let RC_TYPE_AUDIO = 6
let RC_TYPE_LOCATION = 7
let RC_TYPE_File = 8
let RC_TYPE_Feedback = 9

let RC_STATUS_LOADING = 1
let RC_STATUS_SUCCEED = 2
let RC_STATUS_MANUAL = 3
let RC_STATUS_OPENIMAGE = 3

let RC_AUDIOSTATUS_STOPPED = 1
let RC_AUDIOSTATUS_PLAYING = 2

public class RCMessages: NSObject {
    // Section
    public var sectionHeaderMargin: CGFloat = 0.0
    public var sectionHeaderHeight: CGFloat = 0.0
    public var sectionHeaderLeft: CGFloat = 0.0
    public var sectionHeaderRight: CGFloat = 0.0
    public var sectionHeaderColor: UIColor?
    public var sectionHeaderFont: UIFont?
    public var sectionFooterHeight: CGFloat = 0.0
    public var sectionFooterLeft: CGFloat = 0.0
    public var sectionFooterRight: CGFloat = 0.0
    public var sectionFooterColor: UIColor?
    public var sectionFooterFont: UIFont?
    public var sectionFooterMargin: CGFloat = 0.0
    // Bubble
    public var bubbleHeaderHeight: CGFloat = 0.0
    public var bubbleHeaderLeft: CGFloat = 0.0
    public var bubbleHeaderRight: CGFloat = 0.0
    public var bubbleHeaderColor: UIColor?
    public var bubbleHeaderFont: UIFont?
    public var bubbleMarginLeft: CGFloat = 0.0
    public var bubbleMarginRight: CGFloat = 0.0
    public var bubbleRadius: CGFloat = 0.0
    public var bubbleFooterHeight: CGFloat = 0.0
    public var bubbleFooterLeft: CGFloat = 0.0
    public var bubbleFooterRight: CGFloat = 0.0
    public var bubbleFooterColor: UIColor?
    public var bubbleFooterFont: UIFont?
    // Avatar
    
    public var avatarDiameter: CGFloat = 0.0
    public var avatarIncomingHidden: Bool = false
    public var avatarMarginLeft: CGFloat = 0.0
    public var avatarOutgoingHidden: Bool = false
    public var avatarMarginRight: CGFloat = 0.0
    public var avatarBackColor: UIColor?
    public var avatarTextColor: UIColor?
    public var avatarFont: UIFont?
    // Status cell
    public var statusBubbleRadius: CGFloat = 0.0
    public var statusBubbleColor: UIColor?
    public var statusTextColor: UIColor?
    public var statusFont: UIFont?
    public var statusInsetLeft: CGFloat = 0.0
    public var statusInsetRight: CGFloat = 0.0
    public var statusInsetTop: CGFloat = 0.0
    public var statusInsetBottom: CGFloat = 0.0
    public var statusInset: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: statusInsetTop, left: statusInsetLeft, bottom: statusInsetBottom, right: statusInsetRight)
        }
        set {
            statusInsetLeft = newValue.left
            statusInsetRight = newValue.right
            statusInsetTop = newValue.top
            statusInsetBottom = newValue.bottom
        }
    }
    // Text cell
    public var textBubbleWidthMin: CGFloat = 0.0
    public var textBubbleHeightMin: CGFloat = 0.0
    public var textBubbleColorOutgoing: UIColor?
    public var textBubbleColorIncoming: UIColor?
    public var textTextColorOutgoing: UIColor?
    public var textTextColorIncoming: UIColor?
    public var textFont: UIFont!
    public var textInsetLeft: CGFloat = 0.0
    public var textInsetRight: CGFloat = 0.0
    public var textInsetTop: CGFloat = 0.0
    public var textInsetBottom: CGFloat = 0.0
    public var textInset: UIEdgeInsets {
       get {
           return UIEdgeInsets(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)
       }
       set {
           textInsetLeft = newValue.left
           textInsetRight = newValue.right
           textInsetTop = newValue.top
           textInsetBottom = newValue.bottom
       }
   }
    // Emoji cell
    public var emojiBubbleWidthMin: CGFloat = 0.0
    public var emojiBubbleHeightMin: CGFloat = 0.0
    public var emojiBubbleColorOutgoing: UIColor?
    public var emojiBubbleColorIncoming: UIColor?
    public var emojiFont: UIFont?
    public var emojiInsetLeft: CGFloat = 0.0
    public var emojiInsetRight: CGFloat = 0.0
    public var emojiInsetTop: CGFloat = 0.0
    public var emojiInsetBottom: CGFloat = 0.0
    public var emojiInset: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: emojiInsetTop, left: emojiInsetLeft, bottom: emojiInsetBottom, right: emojiInsetRight)
        }
        set {
            emojiInsetLeft = newValue.left
            emojiInsetRight = newValue.right
            emojiInsetTop = newValue.top
            emojiInsetBottom = newValue.bottom
        }
    }
    // Picture cell
    public var pictureBubbleWidth: CGFloat = 0.0
    public var pictureBubbleColorOutgoing: UIColor?
    public var pictureBubbleColorIncoming: UIColor?
    public var pictureImageManual: UIImage?
    // Video cell
    public var videoBubbleWidth: CGFloat = 0.0
    public var videoBubbleHeight: CGFloat = 0.0
    public var videoBubbleColorOutgoing: UIColor?
    public var videoBubbleColorIncoming: UIColor?
    public var videoImagePlay: UIImage?
    public var videoImageManual: UIImage?
    // Audio cell
    public var audioBubbleWidht: CGFloat = 0.0
    public var audioBubbleHeight: CGFloat = 0.0
    public var audioBubbleColorOutgoing: UIColor?
    public var audioBubbleColorIncoming: UIColor?
    public var audioTextColorOutgoing: UIColor?
    public var audioTextColorIncoming: UIColor?
    public var audioImagePlay: UIImage?
    public var audioImagePause: UIImage?
    public var audioImageManual: UIImage?
    public var audioFont: UIFont?
    // Location cell
    public var locationBubbleWidth: CGFloat = 0.0
    public var locationBubbleHeight: CGFloat = 0.0
    public var locationBubbleColorOutgoing: UIColor?
    public var locationBubbleColorIncoming: UIColor?
    // Input view
    public var inputViewBackColor: UIColor?
    public var inputTextBackColor: UIColor?
    public var inputTextTextColor: UIColor?
    public var inputFont: UIFont?
    public var inputViewHeightMin: CGFloat = 0.0
    public var inputTextHeightMin: CGFloat = 0.0
    public var inputTextHeightMax: CGFloat = 0.0
    public var inputBorderWidth: CGFloat = 0.0
    public var inputBorderColor: CGColor?
    public var inputRadius: CGFloat = 0.0
    public var inputInsetLeft: CGFloat = 0.0
    public var inputInsetRight: CGFloat = 0.0
    public var inputInsetTop: CGFloat = 0.0
    public var inputInsetBottom: CGFloat = 0.0
    public var inputInset: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)
        }
        set {
            inputInsetLeft = newValue.left
            inputInsetRight = newValue.right
            inputInsetTop = newValue.top
            inputInsetBottom = newValue.bottom
        }
    }
    
    public static var shared = RCMessages()
    
    override public init() {
        super.init()
        
        // Section
        
        sectionHeaderMargin = 8.0
        
        sectionHeaderHeight = 20.0
        sectionHeaderLeft = 10.0
        sectionHeaderRight = 10.0
        sectionHeaderColor = UIColor.lightGray
        sectionHeaderFont = UIFont.systemFont(ofSize: 12)
        
        sectionFooterHeight = 15.0
        sectionFooterLeft = 10.0
        sectionFooterRight = 10.0
        sectionFooterColor = UIColor.lightGray
        sectionFooterFont = UIFont.systemFont(ofSize: 12)
        
        sectionFooterMargin = 8.0
        
        // Bubble
        bubbleHeaderHeight = 15.0
        bubbleHeaderLeft = 50.0
        bubbleHeaderRight = 50.0
        bubbleHeaderColor = UIColor.lightGray
        bubbleHeaderFont = UIFont.systemFont(ofSize: 12)
        
        bubbleMarginLeft = 40.0
        bubbleMarginRight = 40.0
        bubbleRadius = 15.0
        
        bubbleFooterHeight = 15.0
        bubbleFooterLeft = 50.0
        bubbleFooterRight = 50.0
        bubbleFooterColor = UIColor.lightGray
        bubbleFooterFont = UIFont.systemFont(ofSize: 12)
        
        // Avatar
        avatarDiameter = 30.0
        avatarMarginLeft = 5.0
        avatarIncomingHidden = false
        avatarMarginRight = 5.0
        avatarOutgoingHidden = false
        
        avatarBackColor = UIColor(hexString: "d6d6d6ff")
        avatarTextColor = UIColor.white
        
        avatarFont = UIFont.systemFont(ofSize: 12)
        // Status cell
        
        statusBubbleRadius = 10.0
        
        statusBubbleColor = UIColor(hexString: "00000030")
        statusTextColor = UIColor.white

        statusFont = UIFont.systemFont(ofSize: 12)
        
        statusInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        // Text cell
        
        textBubbleWidthMin = 45.0
        textBubbleHeightMin = 35.0
        
        textBubbleColorOutgoing = UIColor(hexString: "9999ff")
        textBubbleColorIncoming = UIColor(hexString: "e6e5eaff")
        textTextColorOutgoing = UIColor.white
        textTextColorIncoming = UIColor.black
        
        textFont = UIFont.systemFont(ofSize: 16)
        textInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        // Emoji cell
        emojiBubbleWidthMin = 45.0
        emojiBubbleHeightMin = 35.0
        
        emojiBubbleColorOutgoing = UIColor(hexString: "007affff")
        emojiBubbleColorIncoming = UIColor(hexString: "e6e5eaff")
        
        emojiFont = UIFont.systemFont(ofSize: 46)
        
        emojiInset = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
        // Picture cell
        
        pictureBubbleWidth = 200.0
        
        pictureBubbleColorOutgoing = UIColor.lightGray
        pictureBubbleColorIncoming = UIColor.lightGray
        
        pictureImageManual = UIImage.named("rcmessages_manual")
        
        // Video cell
        
        videoBubbleWidth = 200.0
        videoBubbleHeight = 145.0
        
        videoBubbleColorOutgoing = UIColor.lightGray
        videoBubbleColorIncoming = UIColor.lightGray
        
        videoImagePlay = UIImage.named("rcmessages_videoplay")
        videoImageManual = UIImage.named("rcmessages_manual")
        
        // Audio cell
        
        audioBubbleWidht = 150.0
        audioBubbleHeight = 40.0
        
        audioBubbleColorOutgoing = UIColor(hexString: "007affff")
        audioBubbleColorIncoming = UIColor(hexString: "e6e5eaff")
        audioTextColorOutgoing = UIColor.white
        audioTextColorIncoming = UIColor.black
        
        audioImagePlay = UIImage.named("rcmessages_audioplay")
        audioImagePause = UIImage.named("rcmessages_audiopause")
        audioImageManual = UIImage.named("rcmessages_manual")
        
        audioFont = UIFont.systemFont(ofSize: 16)
        
        // Location cell
        
        locationBubbleWidth = 200.0
        locationBubbleHeight = 145.0
        
        locationBubbleColorOutgoing = UIColor.lightGray
        locationBubbleColorIncoming = UIColor.lightGray
        
        // Input view
        
        inputViewBackColor = UIColor.groupTableViewBackground
        inputTextBackColor = UIColor.white
        inputTextTextColor = UIColor.black
        
        inputFont = UIFont.systemFont(ofSize: 17)
        
        inputViewHeightMin = 44.0
        inputTextHeightMin = 30.0
        inputTextHeightMax = 110.0
        
        inputBorderWidth = 1.0
        inputBorderColor = UIColor.lightGray.cgColor
        
        inputRadius = 5.0
        
        inputInset = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 7)
        
    }
    
    // Section
    
    class func sectionHeaderMargin() -> CGFloat {
        return self.shared.sectionHeaderMargin
    }
    
    class var sectionHeaderHeight: CGFloat {
        return shared.sectionHeaderHeight
    }
    
    class func sectionHeaderLeft() -> CGFloat {
        return self.shared.sectionHeaderLeft
    }
    
    class func sectionHeaderRight() -> CGFloat {
        return self.shared.sectionHeaderRight
    }
    
    class func sectionHeaderColor() -> UIColor? {
        return self.shared.sectionHeaderColor
    }
    
    class func sectionHeaderFont() -> UIFont? {
        return self.shared.sectionHeaderFont
    }
    
    class var sectionFooterHeight: CGFloat {
        return self.shared.sectionFooterHeight
    }
    
    class func sectionFooterLeft() -> CGFloat {
        return self.shared.sectionFooterLeft
    }
    
    class func sectionFooterRight() -> CGFloat {
        return self.shared.sectionFooterRight
    }
    
    class func sectionFooterColor() -> UIColor? {
        return self.shared.sectionFooterColor
    }
    
    class func sectionFooterFont() -> UIFont? {
        return self.shared.sectionFooterFont
    }
    
    class func sectionFooterMargin() -> CGFloat {
        return self.shared.sectionFooterMargin
    }
    // Bubble
    
    class func bubbleHeaderHeight() -> CGFloat {
        return self.shared.bubbleHeaderHeight
    }
    
    class func bubbleHeaderLeft() -> CGFloat {
        return self.shared.bubbleHeaderLeft
    }
    
    class func bubbleHeaderRight() -> CGFloat {
        return self.shared.bubbleHeaderRight
    }
    
    class func bubbleHeaderColor() -> UIColor? {
        return self.shared.bubbleHeaderColor
    }
    
    class func bubbleHeaderFont() -> UIFont? {
        return self.shared.bubbleHeaderFont
    }
    
    class func bubbleMarginLeft() -> CGFloat {
        return self.shared.bubbleMarginLeft
    }
    
    class func bubbleMarginRight() -> CGFloat {
        return self.shared.bubbleMarginRight
    }
    
    class func bubbleRadius() -> CGFloat {
        return self.shared.bubbleRadius
    }
    
    class func bubbleFooterHeight() -> CGFloat {
        return self.shared.bubbleFooterHeight
    }
    
    class func bubbleFooterLeft() -> CGFloat {
        return self.shared.bubbleFooterLeft
    }
    
    class func bubbleFooterRight() -> CGFloat {
        return self.shared.bubbleFooterRight
    }
    
    class func bubbleFooterColor() -> UIColor? {
        return self.shared.bubbleFooterColor
    }
    
    class func bubbleFooterFont() -> UIFont? {
        return self.shared.bubbleFooterFont
    }
    // Avatar
    
    class func avatarDiameter() -> CGFloat {
        return self.shared.avatarDiameter
    }

    class func avatarIncomingHidden() -> Bool {
        return self.shared.avatarIncomingHidden
    }

    class func avatarMarginLeft() -> CGFloat {
        return self.shared.avatarMarginLeft
    }
    
    class func avatarOutgoingHidden() -> Bool {
        return self.shared.avatarOutgoingHidden
    }
    
    class func avatarMarginRight() -> CGFloat {
        return self.shared.avatarMarginRight
    }
    
    class func avatarBackColor() -> UIColor? {
        return self.shared.avatarBackColor
    }
    
    class func avatarTextColor() -> UIColor? {
        return self.shared.avatarTextColor
    }
    
    class func avatarFont() -> UIFont? {
        return self.shared.avatarFont
    }
    
    // Status cell
    class func statusBubbleRadius() -> CGFloat {
        return self.shared.statusBubbleRadius
    }
    
    class func statusBubbleColor() -> UIColor? {
        return self.shared.statusBubbleColor
    }
    
    class func statusTextColor() -> UIColor? {
        return self.shared.statusTextColor
    }
    
    class func statusFont() -> UIFont? {
        return self.shared.statusFont
    }
    
    class func statusInsetLeft() -> CGFloat {
        return self.shared.statusInsetLeft
    }
    
    class func statusInsetRight() -> CGFloat {
        return self.shared.statusInsetRight
    }
    
    class func statusInsetTop() -> CGFloat {
        return self.shared.statusInsetTop
    }
    
    class func statusInsetBottom() -> CGFloat {
        return self.shared.statusInsetBottom
    }
    
    class func statusInset() -> UIEdgeInsets {
        return self.shared.statusInset
    }
    
    // Text cell
    
    class func textBubbleWidthMin() -> CGFloat {
        return self.shared.textBubbleWidthMin
    }
    
    class func textBubbleHeightMin() -> CGFloat {
        return self.shared.textBubbleHeightMin
    }
    
    class func textBubbleColorOutgoing() -> UIColor? {
        return self.shared.textBubbleColorOutgoing
    }
    
    class func textBubbleColorIncoming() -> UIColor? {
        return self.shared.textBubbleColorIncoming
    }
    
    class func textTextColorOutgoing() -> UIColor? {
        return self.shared.textTextColorOutgoing
    }
    
    class func textTextColorIncoming() -> UIColor? {
        return self.shared.textTextColorIncoming
    }
    
    class func textFont() -> UIFont {
        return self.shared.textFont
    }
    
    class func textInsetLeft() -> CGFloat {
        return self.shared.textInsetLeft
    }
    
    class func textInsetRight() -> CGFloat {
        return self.shared.textInsetRight
    }
    
    class func textInsetTop() -> CGFloat {
        return self.shared.textInsetTop
    }
    
    class func textInsetBottom() -> CGFloat {
        return self.shared.textInsetBottom
    }
    
    class func textInset() -> UIEdgeInsets {
        return self.shared.textInset
    }
    
    // Emoji cell
    class func emojiBubbleWidthMin() -> CGFloat {
        return self.shared.emojiBubbleWidthMin
    }
    
    class func emojiBubbleHeightMin() -> CGFloat {
        return self.shared.emojiBubbleHeightMin
    }
    
    class func emojiBubbleColorOutgoing() -> UIColor? {
        return self.shared.emojiBubbleColorOutgoing
    }
    
    class func emojiBubbleColorIncoming() -> UIColor? {
        return self.shared.emojiBubbleColorIncoming
    }
    
    class func emojiFont() -> UIFont? {
        return self.shared.emojiFont
    }
    
    class func emojiInsetLeft() -> CGFloat {
        return self.shared.emojiInsetLeft
    }
    
    class func emojiInsetRight() -> CGFloat {
        return self.shared.emojiInsetRight
    }
    
    class func emojiInsetTop() -> CGFloat {
        return self.shared.emojiInsetTop
    }
    
    class func emojiInsetBottom() -> CGFloat {
        return self.shared.emojiInsetBottom
    }
    
    class func emojiInset() -> UIEdgeInsets {
        return self.shared.emojiInset
    }
    // Picture cell
    
    class func pictureBubbleWidth() -> CGFloat {
        return self.shared.pictureBubbleWidth
    }
    
    class func pictureBubbleColorOutgoing() -> UIColor? {
        return self.shared.pictureBubbleColorOutgoing
    }
    
    class func pictureBubbleColorIncoming() -> UIColor? {
        return self.shared.pictureBubbleColorIncoming
    }
    
    class func pictureImageManual() -> UIImage? {
        return self.shared.pictureImageManual
    }
    
    // Video cell
    class func videoBubbleWidth() -> CGFloat {
        return self.shared.videoBubbleWidth
    }
    
    class func videoBubbleHeight() -> CGFloat {
        return self.shared.videoBubbleHeight
    }
    
    class func videoBubbleColorOutgoing() -> UIColor? {
        return self.shared.videoBubbleColorOutgoing
    }
    
    class func videoBubbleColorIncoming() -> UIColor? {
        return self.shared.videoBubbleColorIncoming
    }
    
    class func videoImagePlay() -> UIImage? {
        return self.shared.videoImagePlay
    }
    
    class func videoImageManual() -> UIImage? {
        return self.shared.videoImageManual
    }
    
    // Audio cell
    class func audioBubbleWidht() -> CGFloat {
        return self.shared.audioBubbleWidht
    }
    
    class func audioBubbleHeight() -> CGFloat {
        return self.shared.audioBubbleHeight
    }
    
    class func audioBubbleColorOutgoing() -> UIColor? {
        return self.shared.audioBubbleColorOutgoing
    }
    
    class func audioBubbleColorIncoming() -> UIColor? {
        return self.shared.audioBubbleColorIncoming
    }
    
    class func audioTextColorOutgoing() -> UIColor? {
        return self.shared.audioTextColorOutgoing
    }
    
    class func audioTextColorIncoming() -> UIColor? {
        return self.shared.audioTextColorIncoming
    }
    
    class func audioImagePlay() -> UIImage? {
        return self.shared.audioImagePlay
    }
    
    class func audioImagePause() -> UIImage? {
        return self.shared.audioImagePause
    }
    
    class func audioImageManual() -> UIImage? {
        return self.shared.audioImageManual
    }
    
    class func audioFont() -> UIFont? {
        return self.shared.audioFont
    }

    // Location cell
    
    class func locationBubbleWidth() -> CGFloat {
        return self.shared.locationBubbleWidth
    }
    
    class func locationBubbleHeight() -> CGFloat {
        return self.shared.locationBubbleHeight
    }
    
    class func locationBubbleColorOutgoing() -> UIColor? {
        return self.shared.locationBubbleColorOutgoing
    }
    
    class func locationBubbleColorIncoming() -> UIColor? {
        return self.shared.locationBubbleColorIncoming
    }
    
    // Input view
    class func inputViewBackColor() -> UIColor? {
        return self.shared.inputViewBackColor
    }
    
    class func inputTextBackColor() -> UIColor? {
        return self.shared.inputTextBackColor
    }
    
    class func inputTextTextColor() -> UIColor? {
        return self.shared.inputTextTextColor
    }
    
    class func inputFont() -> UIFont? {
        return self.shared.inputFont
    }
    
    class func inputViewHeightMin() -> CGFloat {
        return self.shared.inputViewHeightMin
    }
    
    class func inputTextHeightMin() -> CGFloat {
        return self.shared.inputTextHeightMin
    }
    
    class func inputTextHeightMax() -> CGFloat {
        return self.shared.inputTextHeightMax
    }
    
    class func inputBorderWidth() -> CGFloat {
        return self.shared.inputBorderWidth
    }
    
    class func inputBorderColor() -> CGColor? {
        return self.shared.inputBorderColor
    }
    
    class func inputRadius() -> CGFloat {
        return self.shared.inputRadius
    }
    
    class func inputInsetLeft() -> CGFloat {
        return self.shared.inputInsetLeft
    }
    
    class func inputInsetRight() -> CGFloat {
        return self.shared.inputInsetRight
    }
    
    class func inputInsetTop() -> CGFloat {
        return self.shared.inputInsetTop
    }
    
    class func inputInsetBottom() -> CGFloat {
        return self.shared.inputInsetBottom
    }
    
    class func inputInset() -> UIEdgeInsets {
        return self.shared.inputInset
    }

}
