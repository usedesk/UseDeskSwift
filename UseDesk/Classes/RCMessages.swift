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

class RCMessages: NSObject {
    // Section
    var sectionHeaderMargin: CGFloat = 0.0
    var sectionHeaderHeight: CGFloat = 0.0
    var sectionHeaderLeft: CGFloat = 0.0
    var sectionHeaderRight: CGFloat = 0.0
    var sectionHeaderColor: UIColor?
    var sectionHeaderFont: UIFont?
    var sectionFooterHeight: CGFloat = 0.0
    var sectionFooterLeft: CGFloat = 0.0
    var sectionFooterRight: CGFloat = 0.0
    var sectionFooterColor: UIColor?
    var sectionFooterFont: UIFont?
    var sectionFooterMargin: CGFloat = 0.0
    // Bubble
    var bubbleHeaderHeight: CGFloat = 0.0
    var bubbleHeaderLeft: CGFloat = 0.0
    var bubbleHeaderRight: CGFloat = 0.0
    var bubbleHeaderColor: UIColor?
    var bubbleHeaderFont: UIFont?
    var bubbleMarginLeft: CGFloat = 0.0
    var bubbleMarginRight: CGFloat = 0.0
    var bubbleRadius: CGFloat = 0.0
    var bubbleFooterHeight: CGFloat = 0.0
    var bubbleFooterLeft: CGFloat = 0.0
    var bubbleFooterRight: CGFloat = 0.0
    var bubbleFooterColor: UIColor?
    var bubbleFooterFont: UIFont?
    // Avatar
    
    var avatarDiameter: CGFloat = 0.0
    var avatarMarginLeft: CGFloat = 0.0
    var avatarMarginRight: CGFloat = 0.0
    var avatarBackColor: UIColor?
    var avatarTextColor: UIColor?
    var avatarFont: UIFont?
    // Status cell
    var statusBubbleRadius: CGFloat = 0.0
    var statusBubbleColor: UIColor?
    var statusTextColor: UIColor?
    var statusFont: UIFont?
    var statusInsetLeft: CGFloat = 0.0
    var statusInsetRight: CGFloat = 0.0
    var statusInsetTop: CGFloat = 0.0
    var statusInsetBottom: CGFloat = 0.0
    var statusInset: UIEdgeInsets?
    // Text cell
    var textBubbleWidthMin: CGFloat = 0.0
    var textBubbleHeightMin: CGFloat = 0.0
    var textBubbleColorOutgoing: UIColor?
    var textBubbleColorIncoming: UIColor?
    var textTextColorOutgoing: UIColor?
    var textTextColorIncoming: UIColor?
    var textFont: UIFont?
    var textInsetLeft: CGFloat = 0.0
    var textInsetRight: CGFloat = 0.0
    var textInsetTop: CGFloat = 0.0
    var textInsetBottom: CGFloat = 0.0
    var textInset: UIEdgeInsets?
    // Emoji cell
    
    var emojiBubbleWidthMin: CGFloat = 0.0
    var emojiBubbleHeightMin: CGFloat = 0.0
    var emojiBubbleColorOutgoing: UIColor?
    var emojiBubbleColorIncoming: UIColor?
    var emojiFont: UIFont?
    var emojiInsetLeft: CGFloat = 0.0
    var emojiInsetRight: CGFloat = 0.0
    var emojiInsetTop: CGFloat = 0.0
    var emojiInsetBottom: CGFloat = 0.0
    var emojiInset: UIEdgeInsets?
    // Picture cell
    var pictureBubbleWidth: CGFloat = 0.0
    var pictureBubbleColorOutgoing: UIColor?
    var pictureBubbleColorIncoming: UIColor?
    var pictureImageManual: UIImage?
    // Video cell
    var videoBubbleWidth: CGFloat = 0.0
    var videoBubbleHeight: CGFloat = 0.0
    var videoBubbleColorOutgoing: UIColor?
    var videoBubbleColorIncoming: UIColor?
    var videoImagePlay: UIImage?
    var videoImageManual: UIImage?
    // Audio cell
    
    var audioBubbleWidht: CGFloat = 0.0
    var audioBubbleHeight: CGFloat = 0.0
    var audioBubbleColorOutgoing: UIColor?
    var audioBubbleColorIncoming: UIColor?
    var audioTextColorOutgoing: UIColor?
    var audioTextColorIncoming: UIColor?
    var audioImagePlay: UIImage?
    var audioImagePause: UIImage?
    var audioImageManual: UIImage?
    var audioFont: UIFont?
    // Location cell
    var locationBubbleWidth: CGFloat = 0.0
    var locationBubbleHeight: CGFloat = 0.0
    var locationBubbleColorOutgoing: UIColor?
    var locationBubbleColorIncoming: UIColor?
    // Input view
    var inputViewBackColor: UIColor?
    var inputTextBackColor: UIColor?
    var inputTextTextColor: UIColor?
    var inputFont: UIFont?
    var inputViewHeightMin: CGFloat = 0.0
    var inputTextHeightMin: CGFloat = 0.0
    var inputTextHeightMax: CGFloat = 0.0
    var inputBorderWidth: CGFloat = 0.0
    var inputBorderColor: CGColor?
    var inputRadius: CGFloat = 0.0
    var inputInsetLeft: CGFloat = 0.0
    var inputInsetRight: CGFloat = 0.0
    var inputInsetTop: CGFloat = 0.0
    var inputInsetBottom: CGFloat = 0.0
    var inputInset: UIEdgeInsets?
    
    static let shared = RCMessages()
    
//    class func shared() -> RCMessages? {
//
//        var once: Int = 0
//        var rcmessages: RCMessages?
//
//        if (once == 0) {
//            rcmessages = RCMessages()
//        }
//        once = 1
//
//        return rcmessages
//    }
    
    override init() {
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
        avatarMarginRight = 5.0
        
        avatarBackColor = UIColor(hexString: "d6d6d6ff")
        avatarTextColor = UIColor.white
        
        avatarFont = UIFont.systemFont(ofSize: 12)
        // Status cell
        
        statusBubbleRadius = 10.0
        
        statusBubbleColor = UIColor(hexString: "00000030")
        statusTextColor = UIColor.white

        statusFont = UIFont.systemFont(ofSize: 12)
        
        statusInsetLeft = 10.0
        statusInsetRight = 10.0
        statusInsetTop = 5.0
        statusInsetBottom = 5.0
        statusInset = UIEdgeInsets(top: statusInsetTop, left: statusInsetLeft, bottom: statusInsetBottom, right: statusInsetRight)
        
        // Text cell
        
        textBubbleWidthMin = 45.0
        textBubbleHeightMin = 35.0
        
        textBubbleColorOutgoing = UIColor(hexString: "9999ff")
        textBubbleColorIncoming = UIColor(hexString: "e6e5eaff")
        textTextColorOutgoing = UIColor.white
        textTextColorIncoming = UIColor.black
        
        textFont = UIFont.systemFont(ofSize: 16)
        textInsetLeft = 10.0
        textInsetRight = 10.0
        textInsetTop = 10.0
        textInsetBottom = 10.0
        textInset = UIEdgeInsets(top: textInsetTop, left: textInsetLeft, bottom: textInsetBottom, right: textInsetRight)
        
        // Emoji cell
        emojiBubbleWidthMin = 45.0
        emojiBubbleHeightMin = 35.0
        
        emojiBubbleColorOutgoing = UIColor(hexString: "007affff")
        emojiBubbleColorIncoming = UIColor(hexString: "e6e5eaff")
        
        emojiFont = UIFont.systemFont(ofSize: 46)
        
        emojiInsetLeft = 30.0
        emojiInsetRight = 30.0
        emojiInsetTop = 5.0
        emojiInsetBottom = 5.0
        emojiInset = UIEdgeInsets(top: emojiInsetTop, left: emojiInsetLeft, bottom: emojiInsetBottom, right: emojiInsetRight)
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
        
        inputInsetLeft = 7.0
        inputInsetRight = 7.0
        inputInsetTop = 5.0
        inputInsetBottom = 5.0
        inputInset = UIEdgeInsets(top: inputInsetTop, left: inputInsetLeft, bottom: inputInsetBottom, right: inputInsetRight)
        
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
    
    class func avatarMarginLeft() -> CGFloat {
        return self.shared.avatarMarginLeft
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
        return self.shared.statusInset!
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
    
    class func textFont() -> UIFont? {
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
        return self.shared.textInset!
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
        return self.shared.emojiInset!
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
        return self.shared.inputInset!
    }

}
