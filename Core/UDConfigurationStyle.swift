//
//  UDConfigurationStyle.swift

import Foundation
import AVFoundation
import CoreLocation
import MapKit
import UIKit

var safeAreaInsetsLeftOrRight: CGFloat = 0
var SCREEN_WIDTH: CGFloat {
    get {
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.width - safeAreaInsetsLeftOrRight
        }
    }
}
var MAX_WIDTH_MESSAGE: CGFloat {
    get {
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
}

// MARK: - Configuration desigen
public struct ConfigurationStyle {
    public var navigationBarStyle: NavigationBarStyle
    public var chatStyle: ChatStyle
    public var sectionHeaderStyle: SectionHeaderStyle
    public var bubbleStyle: BubbleStyle
    public var avatarStyle: AvatarStyle
    public var messageStyle: MessageStyle
    public var feedbackMessageStyle: FeedbackMessageStyle
    public var pictureStyle: PictureStyle
    public var videoStyle: VideoStyle
    public var fileStyle: FileStyle
    public var fileViewingStyle: FileViewingStyle
    public var noInternetStyle: NoInternetStyle
    public var inputViewStyle: InputViewStyle
    public var attachButtonStyle: AttachButtonStyle
    public var sendButtonStyle: SendButtonStyle
    public var messageButtonStyle: MessageButtonStyle
    public var feedbackFormStyle: FeedbackFormStyle
    public var selectTopicFeedbackFormStyle: SelectTopicFeedbackFormStyle
    public var baseStyle: BaseStyle
    public var baseSectionsStyle: BaseSectionsStyle
    public var baseCategoriesStyle: BaseCategoriesStyle
    public var baseArticlesListStyle: BaseArticlesListStyle
    public var baseSearchStyle: BaseSearchStyle
    public var baseArticleStyle: BaseArticleStyle
    
    public init(navigationBarStyle: NavigationBarStyle = NavigationBarStyle(),
                chatStyle: ChatStyle = ChatStyle(),
                sectionHeaderStyle: SectionHeaderStyle = SectionHeaderStyle(),
                bubbleStyle: BubbleStyle = BubbleStyle(),
                avatarStyle: AvatarStyle = AvatarStyle(),
                messageStyle: MessageStyle = MessageStyle(),
                feedbackMessageStyle: FeedbackMessageStyle = FeedbackMessageStyle(),
                pictureStyle: PictureStyle = PictureStyle(),
                videoStyle: VideoStyle = VideoStyle(),
                fileStyle: FileStyle = FileStyle(),
                fileViewingStyle: FileViewingStyle = FileViewingStyle(),
                noInternetStyle: NoInternetStyle = NoInternetStyle(),
                inputViewStyle: InputViewStyle = InputViewStyle(),
                attachButtonStyle: AttachButtonStyle = AttachButtonStyle(),
                sendButtonStyle: SendButtonStyle = SendButtonStyle(),
                messageButtonStyle: MessageButtonStyle = MessageButtonStyle(),
                feedbackFormStyle: FeedbackFormStyle = FeedbackFormStyle(),
                selectTopicFeedbackFormStyle: SelectTopicFeedbackFormStyle = SelectTopicFeedbackFormStyle(),
                baseStyle: BaseStyle = BaseStyle(),
                baseSectionsStyle: BaseSectionsStyle = BaseSectionsStyle(),
                baseCategoriesStyle: BaseCategoriesStyle = BaseCategoriesStyle(),
                articlesListStyle: BaseArticlesListStyle = BaseArticlesListStyle(),
                baseSearchStyle: BaseSearchStyle = BaseSearchStyle(),
                baseArticleStyle: BaseArticleStyle = BaseArticleStyle()) {
        
        self.navigationBarStyle = navigationBarStyle
        self.chatStyle = chatStyle
        self.sectionHeaderStyle = sectionHeaderStyle
        self.bubbleStyle = bubbleStyle
        self.avatarStyle = avatarStyle
        self.messageStyle = messageStyle
        self.feedbackMessageStyle = feedbackMessageStyle
        self.pictureStyle = pictureStyle
        self.videoStyle = videoStyle
        self.fileStyle = fileStyle
        self.fileViewingStyle = fileViewingStyle
        self.noInternetStyle = noInternetStyle
        self.inputViewStyle = inputViewStyle
        self.attachButtonStyle = attachButtonStyle
        self.sendButtonStyle = sendButtonStyle
        self.messageButtonStyle = messageButtonStyle
        self.navigationBarStyle = navigationBarStyle
        self.feedbackFormStyle = feedbackFormStyle
        self.selectTopicFeedbackFormStyle = selectTopicFeedbackFormStyle
        self.baseStyle = baseStyle
        self.baseSectionsStyle = baseSectionsStyle
        self.baseCategoriesStyle = baseCategoriesStyle
        self.baseArticlesListStyle = articlesListStyle
        self.baseSearchStyle = baseSearchStyle
        self.baseArticleStyle = baseArticleStyle
    }
}

// MARK: - NavigationBar
public struct NavigationBarStyle {
    public var backgroundColor: UIColor
    public var textColor: UIColor
    public var font: UIFont
    public var statusBarStyle: UIStatusBarStyle
    public var backButtonImage: UIImage?
    public var backButtonInFileImage: UIImage?
    public var searchButtonImage: UIImage?
    
    public init(backgroundColor: UIColor? = nil,
                textColor: UIColor? = nil,
                font: UIFont = UIFont.boldSystemFont(ofSize: 19),
                statusBarStyle: UIStatusBarStyle = .default,
                backButtonImage: UIImage? = nil,
                backButtonInFileImage: UIImage? = nil,
                searchButtonImage: UIImage? = nil) {
        self.backgroundColor = backgroundColor != nil ? backgroundColor! : UIColor(hexString: "F7F7F7")
        self.textColor = textColor != nil ? textColor! : UIColor(hexString: "333333")
        self.font = font
        self.statusBarStyle = statusBarStyle
        self.backButtonImage = backButtonImage != nil ? backButtonImage! : UIImage.named("udBackButton")
        self.backButtonInFileImage = backButtonInFileImage != nil ? backButtonInFileImage! : UIImage.named("udBackInFileButton")
        self.searchButtonImage = searchButtonImage != nil ? searchButtonImage! : UIImage.named("udSearch")
    }
}
// MARK: - ChatStyle
public struct ChatStyle {
    public var backgroundColor: UIColor
    public var backgroundColorLoaderView: UIColor
    public var alphaLoaderView: CGFloat
    public var scrollButtonImage: UIImage
    public var scrollButtonSize: CGSize
    public var scrollButtonMargin: UIEdgeInsets
    public var topMarginPortrait: CGFloat
    public var topMarginLandscape: CGFloat
    
    public init(backgroundColor: UIColor? = nil,
                backgroundColorLoaderView: UIColor? = nil,
                alphaLoaderView: CGFloat = 0.8,
                scrollButtonImage: UIImage? = nil,
                scrollButtonSize: CGSize = CGSize(width: 40, height: 40),
                scrollButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 12),
                topMarginPortrait: CGFloat = 0,
                topMarginLandscape: CGFloat = 0) {
        self.backgroundColor = backgroundColor != nil ? backgroundColor! : UIColor(hexString: "FFFFFF")
        self.backgroundColorLoaderView = backgroundColorLoaderView != nil ? backgroundColorLoaderView! : .lightGray
        self.alphaLoaderView = alphaLoaderView
        self.scrollButtonImage = scrollButtonImage != nil ? scrollButtonImage! : UIImage.named("udScrollButton")
        self.scrollButtonSize = scrollButtonSize
        self.scrollButtonMargin = scrollButtonMargin
        self.topMarginPortrait = topMarginPortrait
        self.topMarginLandscape = topMarginLandscape
    }
}
// MARK: - Date messages section
public struct SectionHeaderStyle {
    public var margin: UIEdgeInsets
    public var textColor: UIColor
    public var textHeight: CGFloat
    public var font: UIFont
    public var backViewPadding: UIEdgeInsets
    public var backViewColor: UIColor
    public var backViewCornerRadius: CGFloat
    public var backViewOpacity: CGFloat
    
    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10),
                textColor: UIColor? = nil,
                textHeight: CGFloat = 16,
                font: UIFont = UIFont.systemFont(ofSize: 13),
                backViewPadding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10),
                backViewColor: UIColor = .white,
                backViewCornerRadius: CGFloat = 12,
                backViewOpacity: CGFloat = 0.8) {
        
        self.margin = margin
        self.textColor = textColor == nil ? UIColor(hexString: "454D63") : textColor!
        self.textHeight = textHeight
        self.font = font
        self.backViewPadding = backViewPadding
        self.backViewColor = backViewColor
        self.backViewCornerRadius = backViewCornerRadius
        self.backViewOpacity = backViewOpacity
    }
    
    public var heightHeader: CGFloat {
        return textHeight + backViewPadding.top + backViewPadding.bottom + margin.top + margin.bottom
    }
}
// MARK: - Bubble
public struct BubbleStyle {
    public var backgroundImageOutgoing: UIImage
    public var backgroundImageIncoming: UIImage
    public var marginBefore: CGFloat
    public var marginAfter: CGFloat
    public var bubbleWidthMin: CGFloat
    public var bubbleHeightMin: CGFloat
    public var spacingOneSender: CGFloat
    public var spacingDifferentSender: CGFloat
    public var bubbleColorOutgoing: UIColor
    public var bubbleColorIncoming: UIColor
    
    public init(backgroundImageOutgoing: UIImage? = nil,
                backgroundImageIncoming: UIImage? = nil,
                marginBefore: CGFloat = 10.0,
                marginAfter: CGFloat = 50.0,
                bubbleWidthMin: CGFloat = 7.0,
                bubbleHeightMin: CGFloat = 30.0,
                spacingOneSender: CGFloat = 4,
                spacingDifferentSender: CGFloat = 16,
                bubbleColorOutgoing: UIColor? = nil,
                bubbleColorIncoming: UIColor? = nil) {
        self.backgroundImageOutgoing = backgroundImageOutgoing != nil ? backgroundImageOutgoing! : UIImage.named("udBubbleOutgoing")
        self.backgroundImageIncoming = backgroundImageIncoming != nil ? backgroundImageIncoming! : UIImage.named("udBubbleIncoming")
        self.marginBefore = marginBefore
        self.marginAfter = marginAfter
        self.bubbleWidthMin = bubbleWidthMin
        self.bubbleHeightMin = bubbleHeightMin
        self.spacingOneSender = spacingOneSender
        self.spacingDifferentSender = spacingDifferentSender
        self.bubbleColorOutgoing = bubbleColorOutgoing != nil ? bubbleColorOutgoing! : UIColor(hexString: "e0ecfc")
        self.bubbleColorIncoming = bubbleColorIncoming != nil ? bubbleColorIncoming! : UIColor(hexString: "F0F0F0")
    }
}
// MARK: - Avatar
public struct AvatarStyle {
    public var avatarDiameter: CGFloat
    public var margin: UIEdgeInsets
    public var avatarIncomingHidden: Bool
    public var avatarBackColor: UIColor
    public var avatarTextColor: UIColor
    public var avatarFont: UIFont
    
    public init(avatarDiameter: CGFloat = 30.0,
                margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
                avatarIncomingHidden: Bool = false,
                avatarBackColor: UIColor? = nil,
                avatarTextColor: UIColor = UIColor.white,
                avatarFont: UIFont = UIFont.systemFont(ofSize: 12)) {
        self.avatarDiameter = avatarDiameter
        self.margin = margin
        self.avatarIncomingHidden = avatarIncomingHidden
        self.avatarBackColor = avatarBackColor == nil ? UIColor(hexString: "d6d6d6ff") : avatarBackColor!
        self.avatarTextColor = avatarTextColor
        self.avatarFont = avatarFont
    }
}
// MARK: - Text cell
public struct MessageStyle {
    // Text Message
    public var textOutgoingColor: UIColor
    public var textIncomingColor: UIColor
    public var linkOutgoingColor: UIColor
    public var linkIncomingColor: UIColor
    public var font: UIFont
    public var textMargin: UIEdgeInsets
    // Time Text
    public var timeOutgoingColor: UIColor
    public var timeIncomingColor: UIColor
    public var timeFont: UIFont
    public var timeMargin: UIEdgeInsets
    public var timeOutgoingPictureColor: UIColor
    public var timeIncomingPictureColor: UIColor
    // Time Back View
    public var timeBackViewOutgoingColor: UIColor
    public var timeBackViewIncomingColor: UIColor
    public var timeBackViewOpacity: CGFloat
    public var timeBackViewCornerRadius: CGFloat
    public var timeBackViewPadding: UIEdgeInsets
    public var timeBackViewMargin: UIEdgeInsets
    // Sended Status
    public var sendStatusImage: UIImage
    public var sendedStatusImage: UIImage
    public var sendStatusImageForImageMessage: UIImage
    public var sendedStatusImageForImageMessage: UIImage
    public var sendedStatusSize: CGSize
    public var sendedStatusMargin: UIEdgeInsets
    // Not Sent Message
    public var notSentImage: UIImage
    public var notSentImageSize: CGSize
    public var notSentImageMarginToBubble: CGFloat
    // Sender Text
    public var senderTextColor: UIColor
    public var senderTextFont: UIFont
    public var senderTextMargin: UIEdgeInsets
    
    public init(textOutgoingColor: UIColor? = nil,
                textIncomingColor: UIColor? = nil,
                linkOutgoingColor: UIColor? = nil,
                linkIncomingColor: UIColor? = nil,
                font: UIFont = UIFont.systemFont(ofSize: 17),
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 5),
                timeOutgoingColor: UIColor? = nil,
                timeIncomingColor: UIColor? = nil,
                timeFont: UIFont = UIFont.systemFont(ofSize: 11),
                timeMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 6, right: 4),
                timeOutgoingPictureColor: UIColor? = nil,
                timeIncomingPictureColor: UIColor? = nil,
                timeBackViewOutgoingColor: UIColor? = nil,
                timeBackViewIncomingColor: UIColor? = nil,
                timeBackViewOpacity: CGFloat = 0.6,
                timeBackViewCornerRadius: CGFloat = 7,
                timeBackViewPadding: UIEdgeInsets = UIEdgeInsets(top: 1, left: 4, bottom: 0, right: 4),
                timeBackViewMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2),
                sendStatusImage: UIImage? = nil,
                sendedStatusImage: UIImage? = nil,
                sendStatusImageForImageMessage: UIImage? = nil,
                sendedStatusImageForImageMessage: UIImage? = nil,
                sendedStatusSize: CGSize = CGSize(width: 12, height: 12),
                sendedStatusMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 6.5, right: 4),
                notSentImage: UIImage? = nil,
                notSentImageSize: CGSize = CGSize(width: 24, height: 24),
                notSentImageMarginToBubble: CGFloat = 8,
                senderTextColor: UIColor? = nil,
                senderTextFont: UIFont = UIFont.systemFont(ofSize: 11),
                senderTextMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)) {
        self.textOutgoingColor = textOutgoingColor != nil ? textOutgoingColor! : UIColor(hexString: "333333")
        self.textIncomingColor = textIncomingColor != nil ? textIncomingColor! : UIColor(hexString: "333333")
        self.linkOutgoingColor = linkOutgoingColor != nil ? linkOutgoingColor! : UIColor(hexString: "007AFF")
        self.linkIncomingColor = linkIncomingColor != nil ? linkIncomingColor! : UIColor(hexString: "007AFF")
        self.font = font
        self.textMargin = textMargin
        self.timeOutgoingPictureColor = timeOutgoingPictureColor != nil ? timeOutgoingPictureColor! : UIColor(hexString: "FFFFFF")
        self.timeIncomingPictureColor = timeIncomingPictureColor != nil ? timeIncomingPictureColor! : UIColor(hexString: "FFFFFF")
        self.timeOutgoingColor = timeOutgoingColor != nil ? timeOutgoingColor! : UIColor(hexString: "989FB3")
        self.timeIncomingColor = timeIncomingColor != nil ? timeIncomingColor! : UIColor(hexString: "989FB3")
        self.timeFont = timeFont
        self.timeMargin = timeMargin
        self.timeBackViewOutgoingColor = timeBackViewOutgoingColor != nil ? timeBackViewOutgoingColor! : UIColor(hexString: "333333")
        self.timeBackViewIncomingColor = timeBackViewIncomingColor != nil ? timeBackViewIncomingColor! : UIColor(hexString: "333333")
        self.timeBackViewOpacity = timeBackViewOpacity
        self.timeBackViewCornerRadius = timeBackViewCornerRadius
        self.timeBackViewPadding = timeBackViewPadding
        self.timeBackViewMargin = timeBackViewMargin
        self.sendStatusImage = sendStatusImage != nil ? sendStatusImage! : UIImage.named("udSendStatusImage")
        self.sendedStatusImage = sendedStatusImage != nil ? sendedStatusImage! : UIImage.named("udSendedStatusImage")
        self.sendStatusImageForImageMessage = sendStatusImageForImageMessage != nil ? sendStatusImageForImageMessage! : UIImage.named("udSendStatusImageWhite")
        self.sendedStatusImageForImageMessage = sendedStatusImageForImageMessage != nil ? sendedStatusImageForImageMessage! : UIImage.named("udSendedStatusImageWhite")
        self.sendedStatusSize = sendedStatusSize
        self.sendedStatusMargin = sendedStatusMargin
        self.notSentImage = notSentImage != nil ? notSentImage! : UIImage.named("udNotSentImage")
        self.notSentImageSize = notSentImageSize
        self.notSentImageMarginToBubble = notSentImageMarginToBubble
        self.senderTextColor = senderTextColor != nil ? senderTextColor! : UIColor(hexString: "989FB3")
        self.senderTextFont = senderTextFont
        self.senderTextMargin = senderTextMargin
    }
}
// MARK: - Feedback Message cell
public struct FeedbackMessageStyle {
    public var buttonSize: CGSize
    public var buttonsMarginTop: CGFloat
    public var buttonsSpacing: CGFloat
    public var likeOnImage: UIImage
    public var likeOffImage: UIImage
    public var dislikeOnImage: UIImage
    public var dislikeOffImage: UIImage
    public var isFirstDislike: Bool
    public var textColor: UIColor
    public var font: UIFont
    public var textMargin: UIEdgeInsets
    
    public init(buttonSize: CGSize = CGSize(width: 56, height: 56),
                buttonsMarginTop: CGFloat = 25,
                buttonsSpacing: CGFloat = 12,
                likeOnImage: UIImage? = nil,
                likeOffImage: UIImage? = nil,
                dislikeOnImage: UIImage? = nil,
                dislikeOffImage: UIImage? = nil,
                isFirstDislike: Bool = true,
                textColor: UIColor? = nil,
                font: UIFont = UIFont.systemFont(ofSize: 17),
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 17, left: 28, bottom: 14, right: 28)) {
        self.buttonSize = buttonSize
        self.buttonsMarginTop = buttonsMarginTop
        self.buttonsSpacing = buttonsSpacing
        self.likeOnImage = likeOnImage != nil ? likeOnImage! : UIImage.named("udLikeOn")
        self.likeOffImage = likeOffImage != nil ? likeOffImage! : UIImage.named("udLikeOff")
        self.dislikeOnImage = dislikeOnImage != nil ? dislikeOnImage! : UIImage.named("udDislikeOn")
        self.dislikeOffImage = dislikeOffImage != nil ? dislikeOffImage! : UIImage.named("udDislikeOff")
        self.isFirstDislike = isFirstDislike
        self.textColor = textColor != nil ? textColor! : UIColor(hexString: "333333")
        self.font = font
        self.textMargin = textMargin
    }
}
// MARK: - Picture cell
public struct PictureStyle {
    public var margin: UIEdgeInsets
    public var cornerRadius: CGFloat
    public var imageDefault: UIImage
    public var sizeDefault: CGSize
    public var isNeedBubble: Bool
    
    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                cornerRadius: CGFloat = 8,
                imageDefault: UIImage? = nil,
                sizeDefault: CGSize = CGSize(width: 150, height: 150),
                isNeedBubble: Bool = true) {
        self.margin = margin
        self.cornerRadius = cornerRadius
        self.imageDefault = imageDefault != nil ? imageDefault! : UIImage.named("udPictureDefault")
        self.sizeDefault = sizeDefault
        self.isNeedBubble = isNeedBubble
    }
}
// MARK: - Video cell
public struct VideoStyle {
    public var margin: UIEdgeInsets
    public var cornerRadius: CGFloat
    public var imageDefault: UIImage
    public var sizeDefault: CGSize
    public var isNeedBubble: Bool

    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                cornerRadius: CGFloat = 8,
                imageDefault: UIImage? = nil,
                sizeDefault: CGSize = CGSize(width: 150, height: 170),
                isNeedBubble: Bool = true) {
        self.margin = margin
        self.cornerRadius = cornerRadius
        self.imageDefault = imageDefault != nil ? imageDefault! : UIImage.named("udVideoDefault")
        self.sizeDefault = sizeDefault
        self.isNeedBubble = isNeedBubble
    }
}
// MARK: - File cell
public struct FileStyle {
    public var iconMargin: UIEdgeInsets
    public var imageIcon: UIImage
    public var iconSize: CGSize
    public var fontName: UIFont
    public var nameMargin: UIEdgeInsets
    public var nameOutgoingColor: UIColor
    public var nameIncomingColor: UIColor
    public var fontSize: UIFont
    public var sizeMarginTop: CGFloat
    public var sizeOutgoingColor: UIColor
    public var sizeIncomingColor: UIColor

    public init(iconMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8),
                imageIcon: UIImage? = nil,
                iconSize: CGSize = CGSize(width: 40, height: 40),
                fontName: UIFont = UIFont.systemFont(ofSize: 17),
                nameMargin: UIEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 8),
                nameOutgoingColor: UIColor? = nil,
                nameIncomingColor: UIColor? = nil,
                fontSize: UIFont = UIFont.systemFont(ofSize: 12),
                sizeMarginTop: CGFloat = 2,
                sizeOutgoingColor: UIColor? = nil,
                sizeIncomingColor: UIColor? = nil) {
        self.iconMargin = iconMargin
        self.imageIcon = imageIcon != nil ? imageIcon! : UIImage.named("udFileIcon")
        self.iconSize = iconSize
        self.fontName = fontName
        self.nameMargin = nameMargin
        self.nameOutgoingColor = nameOutgoingColor != nil ? nameOutgoingColor! : UIColor(hexString: "333333")
        self.nameIncomingColor = nameIncomingColor != nil ? nameIncomingColor! : UIColor(hexString: "333333")
        self.fontSize = fontSize
        self.sizeMarginTop = sizeMarginTop
        self.sizeOutgoingColor = sizeOutgoingColor != nil ? sizeOutgoingColor! : UIColor(hexString: "989FB3")
        self.sizeIncomingColor = sizeIncomingColor != nil ? sizeIncomingColor! : UIColor(hexString: "989FB3")
    }
}

// MARK: - FileViewing
public struct FileViewingStyle {
    public var backButtonMargin: UIEdgeInsets
    public var backButtonImage: UIImage
    public var backButtonSize: CGSize

    public init(backButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 5, left: 2, bottom: 0, right: 0),
                backButtonImage: UIImage? = nil,
                backButtonSize: CGSize = CGSize(width: 26, height: 26)) {
        self.backButtonMargin = backButtonMargin
        self.backButtonImage = backButtonImage != nil ? backButtonImage! : UIImage.named("udBackInFileButton")
        self.backButtonSize = backButtonSize
    }
}

// MARK: - NoInternetStyle
public struct NoInternetStyle {
    public var backgroundColor: UIColor
    public var iconImage: UIImage
    public var iconImageSize: CGSize
    public var titleMargin: UIEdgeInsets
    public var titleFont: UIFont
    public var textMargin: UIEdgeInsets
    public var textFont: UIFont
    
    public init(backgroundColor: UIColor = .white,
                iconImage: UIImage? = nil,
                iconImageSize: CGSize = CGSize(width: 70, height: 70),
                titleMargin: UIEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 8, right: 20),
                titleFont: UIFont = UIFont.systemFont(ofSize: 21, weight: .semibold),
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12),
                textFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .medium)) {
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage != nil ? iconImage! : UIImage.named("udNoInternet")
        self.iconImageSize = iconImageSize
        self.titleMargin = titleMargin
        self.titleFont = titleFont
        self.textMargin = textMargin
        self.textFont = textFont
    }
}

// MARK: - Input View
public struct InputViewStyle {
    public var viewBackColor: UIColor
    public var textBackColor: UIColor
    public var textColor: UIColor
    public var placeholderTextColor: UIColor
    public var font: UIFont
    public var textHeightMin: CGFloat
    public var textHeightMax: CGFloat
    public var textMargin: UIEdgeInsets
    public var inputTextViewBorderWidth: CGFloat
    public var inputTextViewBorderColor: CGColor
    public var inputTextViewRadius: CGFloat
    public var inputTextViewMargin: UIEdgeInsets
    public var heightAssetsCollection: CGFloat
    public var topMarginAssetsCollection: CGFloat
    
    public init(viewBackColor: UIColor? = nil,
                textBackColor: UIColor = UIColor.white,
                textColor: UIColor = UIColor.black,
                placeholderTextColor: UIColor? = nil,
                font: UIFont = UIFont.systemFont(ofSize: 17),
                textHeightMin: CGFloat = 30,
                textHeightMax: CGFloat = 98,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16),
                inputTextViewBorderWidth: CGFloat = 0,
                inputTextViewBorderColor: CGColor = UIColor.clear.cgColor,
                inputTextViewRadius: CGFloat = 18,
                inputTextViewMargin: UIEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0),
                heightAssetsCollection: CGFloat = 72,
                topMarginAssetsCollection: CGFloat = 15) {
        self.viewBackColor = viewBackColor != nil ? viewBackColor! : UIColor(hexString: "F7F7F7")
        self.textBackColor = textBackColor
        self.textColor = textColor
        self.placeholderTextColor = placeholderTextColor != nil ? placeholderTextColor! : UIColor(hexString: "#BDBDBD")
        self.font = font
        self.textHeightMin = textHeightMin
        self.textHeightMax = textHeightMax
        self.textMargin = textMargin
        self.inputTextViewBorderWidth = inputTextViewBorderWidth
        self.inputTextViewBorderColor = inputTextViewBorderColor
        self.inputTextViewRadius = inputTextViewRadius
        self.inputTextViewMargin = inputTextViewMargin
        self.heightAssetsCollection = heightAssetsCollection
        self.topMarginAssetsCollection = topMarginAssetsCollection
    }
}
// MARK: - AttachButtonStyle
public struct AttachButtonStyle {
    public var margin: UIEdgeInsets
    public var size: CGSize
    public var image: UIImage
    
    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 7, right: 12),
                size: CGSize = CGSize(width: 24, height: 24),
                image: UIImage? = nil) {
        self.image = (image != nil) ? image! : UIImage.named("udAttachButton")
        self.margin = margin
        self.size = size
    }
}

// MARK: - SendButtonStyle
public struct SendButtonStyle {
    public var margin: UIEdgeInsets
    public var size: CGSize
    public var image: UIImage
    
    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 9, bottom: 0, right: 12),
                size: CGSize = CGSize(width: 32, height: 32),
                image: UIImage? = nil) {
        self.image = (image != nil) ? image! : UIImage.named("udSendButton")
        self.margin = margin
        self.size = size
    }
}

// MARK: - Message Button
public struct MessageButtonStyle {
    public var color: UIColor
    public var textColor: UIColor
    public var textFont: UIFont
    public var cornerRadius: CGFloat
    public var spacing: CGFloat
    public var minHeight: CGFloat
    public var margin: UIEdgeInsets
    public var maximumLine: Int
    
    public init(color: UIColor? = nil,
                textColor: UIColor? = nil,
                textFont: UIFont = UIFont.systemFont(ofSize: 15),
                cornerRadius: CGFloat = 8,
                spacing: CGFloat = 8,
                height: CGFloat = 36,
                margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 8, right: 6),
                maximumLine: Int = 1) {
        self.color = color != nil ? color! : UIColor(hexString: "333333")
        self.textColor = textColor != nil ? textColor! : UIColor(hexString: "FFFFFF")
        self.textFont = textFont
        self.cornerRadius = cornerRadius
        self.spacing = spacing
        self.minHeight = height
        self.margin = margin
        self.maximumLine = maximumLine
    }
}

// MARK: - FeedbackFormStyle
public struct FeedbackFormStyle {
    public var buttonColor: UIColor
    public var buttonColorDisabled: UIColor
    public var buttonTextColor: UIColor
    public var buttonFont: UIFont
    public var buttonCornerRadius: CGFloat
    public var textColor: UIColor
    public var textFont: UIFont
    public var headerFont: UIFont
    public var headerColor: UIColor
    public var headerSelectedColor: UIColor
    public var valueFont: UIFont
    public var valueColor: UIColor
    public var arrowImage: UIImage
    public var arrowImageSize: CGSize
    public var lineSeparatorColor: UIColor
    public var lineSeparatorActiveColor: UIColor
    public var errorColor: UIColor
    public var sendedImage: UIImage
    
    public init(buttonColor: UIColor? = nil,
                buttonColorDisabled: UIColor? = nil,
                buttonTextColor: UIColor? = nil,
                buttonFont: UIFont = UIFont.systemFont(ofSize: 16),
                buttonCornerRadius: CGFloat = 8,
                textColor: UIColor? = nil,
                textFont: UIFont = UIFont.systemFont(ofSize: 16),
                headerFont: UIFont = UIFont.systemFont(ofSize: 15),
                headerColor: UIColor? = nil,
                headerSelectedColor: UIColor? = nil,
                valueFont: UIFont = UIFont.systemFont(ofSize: 16),
                valueColor: UIColor? = nil,
                arrowImage: UIImage? = nil,
                arrowImageSize: CGSize = CGSize(width: 20, height: 22),
                lineSeparatorColor: UIColor? = nil,
                lineSeparatorActiveColor: UIColor? = nil,
                errorColor: UIColor? = nil,
                sendedImage: UIImage? = nil) {
        self.buttonColor = buttonColor != nil ? buttonColor! : UIColor(hexString: "333333")
        self.buttonColorDisabled = buttonColorDisabled != nil ? buttonColorDisabled! : UIColor(hexString: "565656")
        self.buttonTextColor = buttonTextColor != nil ? buttonTextColor! : .white
        self.buttonFont = buttonFont
        self.buttonCornerRadius = buttonCornerRadius
        self.textColor = textColor != nil ? textColor! : .black
        self.textFont = textFont
        self.headerFont = headerFont
        self.headerColor = headerColor != nil ? headerColor! : UIColor(hexString: "BDBDBD")
        self.headerSelectedColor = headerSelectedColor != nil ? headerSelectedColor! : UIColor(hexString: "EB5757")
        self.valueFont = valueFont
        self.valueColor = valueColor != nil ? valueColor! : UIColor(hexString: "333333")
        self.arrowImage =  (arrowImage != nil) ? arrowImage! : UIImage.named("udArrow")
        self.arrowImageSize = arrowImageSize
        self.lineSeparatorColor = lineSeparatorColor != nil ? lineSeparatorColor! : UIColor(hexString: "E0E0E0")
        self.lineSeparatorActiveColor = lineSeparatorActiveColor != nil ? lineSeparatorActiveColor! : UIColor(hexString: "EB5757")
        self.errorColor = errorColor != nil ? errorColor! : UIColor(hexString: "EB5757")
        self.sendedImage = (sendedImage != nil) ? sendedImage! : UIImage.named("udSended")
    }
}

// MARK: - SelectTopicFeedbackFormStyle
public struct SelectTopicFeedbackFormStyle {
    public var titleTopicFont: UIFont
    public var titleTopicColor: UIColor
    public var titleTopicMargin: UIEdgeInsets
    public var lineSeparatorColor: UIColor
    public var selectImage: UIImage
    public var selectedImage: UIImage
    public var selectImageSize: CGSize
    public var selectImageMarginRight: CGFloat
    
    public init(titleTopicFont: UIFont = UIFont.systemFont(ofSize: 16),
                titleTopicColor: UIColor? = nil,
                titleTopicMargin: UIEdgeInsets = UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 4),
                lineSeparatorColor: UIColor? = nil,
                selectImage: UIImage? = nil,
                selectedImage: UIImage? = nil,
                selectImageSize: CGSize = CGSize(width: 28, height: 30),
                selectImageMarginRight: CGFloat = 8) {
        self.titleTopicFont = titleTopicFont
        self.titleTopicColor = titleTopicColor != nil ? titleTopicColor! : UIColor(hexString: "333333")
        self.titleTopicMargin = titleTopicMargin
        self.lineSeparatorColor = lineSeparatorColor != nil ? lineSeparatorColor! : UIColor(hexString: "E0E0E0")
        self.selectImage = (selectImage != nil) ? selectImage! : UIImage.named("udSelectCircle")
        self.selectedImage = (selectedImage != nil) ? selectedImage! : UIImage.named("udSelectedCircle")
        self.selectImageSize = selectImageSize
        self.selectImageMarginRight = selectImageMarginRight
    }
}


// MARK: - Base
public struct BaseStyle {
    public var backColor: UIColor
    public var isNeedChat: Bool
    public var chatIconImage: UIImage
    public var chatButtonBackColor: UIColor
    public var chatButtonCornerRadius: CGFloat
    public var chatButtonSize: CGSize
    public var chatButtonMargin: UIEdgeInsets
    public var shadowOffset: CGSize
    public var shadowOpacity: Float
    public var shadowRadius: CGFloat
    public var shadowColor: CGColor
    public var searchBarTextBackgroundColor: UIColor
    public var searchBarTextColor: UIColor
    public var searchBarTintColor: UIColor
    public var searchCancelButtonColor: UIColor
    
    public init(backColor: UIColor? = nil,
                isNeedChat: Bool = true,
                chatIconImage: UIImage? = nil,
                chatButtonBackColor: UIColor? = nil,
                chatButtonCornerRadius: CGFloat = 28,
                chatButtonSize: CGSize = CGSize(width: 56, height: 56),
                chatButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 17, right: 12),
                shadowOffset: CGSize = CGSize(width: 0.0, height: 10.0),
                shadowOpacity: Float = 0.2,
                shadowRadius: CGFloat = 15,
                shadowColor: CGColor? = nil,
                searchBarTextBackgroundColor: UIColor = .white,
                searchBarTextColor: UIColor = .black,
                searchBarTintColor: UIColor = .red,
                searchCancelButtonColor: UIColor? = nil) {
        self.backColor = backColor != nil ? backColor! : .white
        self.isNeedChat = isNeedChat
        self.chatIconImage = (chatIconImage != nil) ? chatIconImage! : UIImage.named("udChatIcon")
        self.chatButtonBackColor = chatButtonBackColor != nil ? chatButtonBackColor! : UIColor(hexString: "333333")
        self.chatButtonCornerRadius = chatButtonCornerRadius
        self.chatButtonSize = chatButtonSize
        self.chatButtonMargin = chatButtonMargin
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor != nil ? shadowColor! : UIColor(hexString: "000000").cgColor
        self.searchBarTextBackgroundColor = searchBarTextBackgroundColor
        self.searchBarTextColor = searchBarTextColor
        self.searchBarTintColor = searchBarTintColor
        self.searchCancelButtonColor = searchCancelButtonColor != nil ? searchCancelButtonColor! : UIColor(hexString: "EB5757") 
    }
}
// MARK: - Base Section
public struct BaseSectionsStyle {
    // Cell Style
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var iconDefaultImage: UIImage
    public var iconFont: UIFont
    public var iconTextColor: UIColor
    public var iconSize: CGSize
    public var iconMargin: UIEdgeInsets
    public var arrowImage: UIImage
    public var arrowSize: CGSize
    public var arrowMargin: UIEdgeInsets
    public var separatorColor: UIColor
    public var separatorLeftMargin: CGFloat
    public var separatorHeight: CGFloat
    
    public init(textFont: UIFont = UIFont.boldSystemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 17, left: 14, bottom: 17, right: 14),
                iconDefaultImage: UIImage? = nil,
                iconFont: UIFont = UIFont.systemFont(ofSize: 22),
                iconTextColor: UIColor? = nil,
                iconSize: CGSize = CGSize(width: 44, height: 44),
                iconMargin: UIEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 0, right: 0),
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMargin: UIEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 20),
                separatorColor: UIColor? = nil,
                separatorLeftMargin: CGFloat = 73,
                separatorHeight: CGFloat = 1) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.iconDefaultImage = (iconDefaultImage != nil) ? iconDefaultImage! : UIImage.named("udIconBaseSection")
        self.iconFont = iconFont
        self.iconTextColor = iconTextColor != nil ? iconTextColor! : UIColor(hexString: "989FB3")
        self.iconSize = iconSize
        self.iconMargin = iconMargin
        self.arrowImage = (arrowImage != nil) ? arrowImage! : UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMargin = arrowMargin
        self.separatorColor = separatorColor != nil ? separatorColor! : UIColor(hexString: "D2D7E5")
        self.separatorLeftMargin = separatorLeftMargin
        self.separatorHeight = separatorHeight
    }
}
// MARK: - Base Categories
public struct BaseCategoriesStyle {
    // Cell Style
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var countArticlesFont: UIFont
    public var countArticlesColor: UIColor
    public var countArticlesMargin: UIEdgeInsets
    public var descriptionFont: UIFont
    public var descriptionColor: UIColor
    public var descriptionMargin: UIEdgeInsets
    public var arrowImage: UIImage
    public var arrowSize: CGSize
    public var arrowMargin: UIEdgeInsets
    public var separatorColor: UIColor
    public var separatorLeftMargin: CGFloat
    public var separatorHeight: CGFloat
    
    public init(textFont: UIFont = UIFont.systemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 17, left: 20, bottom: 6, right: 14),
                countArticlesFont: UIFont = UIFont.systemFont(ofSize: 15),
                countArticlesColor: UIColor? = nil,
                countArticlesMargin: UIEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 8),
                descriptionFont: UIFont = UIFont.systemFont(ofSize: 14),
                descriptionColor: UIColor? = nil,
                descriptionMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 16, right: 20),
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMargin: UIEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 20),
                separatorColor: UIColor? = nil,
                separatorLeftMargin: CGFloat = 16,
                separatorHeight: CGFloat = 1) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.countArticlesFont = countArticlesFont
        self.countArticlesColor = countArticlesColor != nil ? countArticlesColor! : UIColor(hexString: "989FB3")
        self.countArticlesMargin = countArticlesMargin
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor != nil ? descriptionColor! : UIColor(hexString: "989FB3")
        self.descriptionMargin = descriptionMargin
        self.arrowImage = (arrowImage != nil) ? arrowImage! : UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMargin = arrowMargin
        self.separatorColor = separatorColor != nil ? separatorColor! : UIColor(hexString: "D2D7E5")
        self.separatorLeftMargin = separatorLeftMargin
        self.separatorHeight = separatorHeight
    }
}
// MARK: - Articles List
public struct BaseArticlesListStyle {
    // Cell Style
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var separatorColor: UIColor
    public var separatorLeftMargin: CGFloat
    public var separatorHeight: CGFloat

    public init(textFont: UIFont = UIFont.systemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14),
                separatorColor: UIColor? = nil,
                separatorLeftMargin: CGFloat = 16,
                separatorHeight: CGFloat = 1) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.separatorColor = separatorColor != nil ? separatorColor! : UIColor(hexString: "D2D7E5")
        self.separatorLeftMargin = separatorLeftMargin
        self.separatorHeight = separatorHeight
    }
}
// MARK: - Base Search
public struct BaseSearchStyle {
    // Cell Style
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var titleMargin: UIEdgeInsets
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var pathFont: UIFont
    public var pathColor: UIColor
    public var pathMargin: UIEdgeInsets
    public var separatorColor: UIColor
    public var separatorLeftMargin: CGFloat
    public var separatorHeight: CGFloat
    
    public init(titleFont: UIFont = UIFont.systemFont(ofSize: 17),
                titleColor: UIColor? = nil,
                titleMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 4, right: 20),
                textFont: UIFont = UIFont.systemFont(ofSize: 14),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 6, right: 20),
                pathFont: UIFont = UIFont.systemFont(ofSize: 14),
                pathColor: UIColor? = nil,
                pathMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 20),
                separatorColor: UIColor? = nil,
                separatorLeftMargin: CGFloat = 16,
                separatorHeight: CGFloat = 1) {
        self.titleFont = titleFont
        self.titleColor = titleColor != nil ? titleColor! : UIColor(hexString: "333333")
        self.titleMargin = titleMargin
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.pathFont = pathFont
        self.pathColor = pathColor != nil ? pathColor! : UIColor(hexString: "989FB3")
        self.pathMargin = pathMargin
        self.separatorColor = separatorColor != nil ? separatorColor! : UIColor(hexString: "D2D7E5")
        self.separatorLeftMargin = separatorLeftMargin
        self.separatorHeight = separatorHeight
    }
}
// MARK: - Base Article
public struct BaseArticleStyle {

    public var titleFont: UIFont
    public var titleColor: UIColor
    public var titleMargin: UIEdgeInsets
    
    public var titleBigFont: UIFont
    public var titleBigColor: UIColor
    public var titleBigMargin: UIEdgeInsets
    
    public var closeButtonImage: UIImage
    public var closeButtonSize: CGSize
    public var closeButtonMargin: UIEdgeInsets
    
    public var topSeparatorViewColor: UIColor
    // Review Style
    public var isNeedReview: Bool
    public var reviewFont: UIFont
    public var reviewColor: UIColor
    public var reviewMargin: UIEdgeInsets
    
    public var reviewYesButtonColor: UIColor
    public var reviewYesButtonCornerRadius: CGFloat
    public var reviewYesFont: UIFont
    public var reviewYesColor: UIColor
    public var reviewYesButtonTextMargin: UIEdgeInsets
    public var reviewYesButtonMargin: UIEdgeInsets
    
    public var reviewNoButtonColor: UIColor
    public var reviewNoButtonCornerRadius: CGFloat
    public var reviewNoFont: UIFont
    public var reviewNoColor: UIColor
    public var reviewNoButtonTextMargin: UIEdgeInsets
    public var reviewNoButtonMargin: UIEdgeInsets
    
    public var reviewSendTextFont: UIFont
    public var reviewSendTextColor: UIColor
    public var reviewSendTextMargin: UIEdgeInsets
    
    public var reviewLineBottomColor: UIColor
    public var reviewLineMarginTop: CGFloat
    public var reviewLineHeight: CGFloat
    
    public var reviewSendButtonColor: UIColor
    public var reviewSendButtonCornerRadius: CGFloat
    public var reviewSendFont: UIFont
    public var reviewSendColor: UIColor
    public var reviewSendButtonTextMargin: UIEdgeInsets
    public var reviewSendButtonMargin: UIEdgeInsets
    // Transitions Style
    public var previousArticleImage: UIImage
    public var previousArticleImageSize: CGSize
    public var previousArticleImageMargin: UIEdgeInsets
    
    public var nextArticleImage: UIImage
    public var nextArticleImageSize: CGSize
    public var nextArticleImageMargin: UIEdgeInsets
    
    public var articlePreviousFont: UIFont
    public var articlePreviousColor: UIColor
    public var articlePreviousMargin: UIEdgeInsets
    
    public var articleNextFont: UIFont
    public var articleNextColor: UIColor
    public var articleNextMargin: UIEdgeInsets
    
    public var separatorViewColor: UIColor
    public var separatorViewMargin: UIEdgeInsets
    public var separatorViewHeight: CGFloat
    
    public init(isNeedReview: Bool = true,
                titleFont: UIFont = UIFont.boldSystemFont(ofSize: 17),
                titleColor: UIColor? = nil,
                titleMargin: UIEdgeInsets = UIEdgeInsets(top: 22, left: 55, bottom: 0, right: 8),
                titleBigFont: UIFont = UIFont.boldSystemFont(ofSize: 22),
                titleBigColor: UIColor? = nil,
                titleBigMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16),
                closeButtonImage: UIImage? = nil,
                closeButtonSize: CGSize = CGSize(width: 30, height: 30),
                closeButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 20, left: 8, bottom: 13, right: 16),
                topSeparatorViewColor: UIColor? = nil,
                reviewFont: UIFont = UIFont.boldSystemFont(ofSize: 16),
                reviewColor: UIColor? = nil,
                reviewMargin: UIEdgeInsets = UIEdgeInsets(top: 36, left: 16, bottom: 0, right: 16),
                reviewYesButtonColor: UIColor? = nil,
                reviewYesButtonCornerRadius: CGFloat = 0,
                reviewYesFont: UIFont = UIFont.boldSystemFont(ofSize: 12),
                reviewYesColor: UIColor? = nil,
                reviewYesButtonTextMargin: UIEdgeInsets = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22),
                reviewYesButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 26, right: 8),
                reviewNoButtonColor: UIColor? = nil,
                reviewNoButtonCornerRadius: CGFloat = 0,
                reviewNoFont: UIFont = UIFont.boldSystemFont(ofSize: 12),
                reviewNoColor: UIColor? = nil,
                reviewNoButtonTextMargin: UIEdgeInsets = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22),
                reviewNoButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 8, bottom: 26, right: 8),
                reviewSendTextFont: UIFont = UIFont.systemFont(ofSize: 14),
                reviewSendTextColor: UIColor = .black,
                reviewSendTextMargin: UIEdgeInsets = UIEdgeInsets(top: 23, left: 16, bottom: 56, right: 16),
                reviewLineBottomColor: UIColor? = nil,
                reviewLineMarginTop: CGFloat = 0,
                reviewLineHeight: CGFloat = 2,
                reviewSendButtonColor: UIColor? = nil,
                reviewSendButtonCornerRadius: CGFloat = 0,
                reviewSendFont: UIFont = UIFont.boldSystemFont(ofSize: 12),
                reviewSendColor: UIColor? = nil,
                reviewSendButtonTextMargin: UIEdgeInsets = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22),
                reviewSendButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 13, left: 16, bottom: 26, right: 16),
                previousArticleImage: UIImage? = nil,
                previousArticleImageSize: CGSize = CGSize(width: 24, height: 24),
                previousArticleImageMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 9),
                nextArticleImage: UIImage? = nil,
                nextArticleImageSize: CGSize = CGSize(width: 24, height: 24),
                nextArticleImageMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 9, bottom: 0, right: 16),
                articlePreviousFont: UIFont = UIFont.systemFont(ofSize: 17),
                articlePreviousColor: UIColor? = nil,
                articlePreviousMargin: UIEdgeInsets = UIEdgeInsets(top: 13, left: 0, bottom: 16, right: 15),
                articleNextFont: UIFont = UIFont.systemFont(ofSize: 17),
                articleNextColor: UIColor? = nil,
                articleNextMargin: UIEdgeInsets = UIEdgeInsets(top: 13, left: 15, bottom: 16, right: 0),
                separatorViewColor: UIColor? = nil,
                separatorViewMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
                separatorViewHeight: CGFloat = 1) {
        self.isNeedReview = isNeedReview
        self.titleFont = titleFont
        self.titleColor = titleColor != nil ? titleColor! : UIColor(hexString: "333333")
        self.titleMargin = titleMargin
        self.titleBigFont = titleBigFont
        self.titleBigColor = titleBigColor != nil ? titleBigColor! : UIColor(hexString: "333333")
        self.titleBigMargin = titleBigMargin
        self.closeButtonImage = (closeButtonImage != nil) ? closeButtonImage! : UIImage.named("udCloseArticle")
        self.closeButtonSize = closeButtonSize
        self.closeButtonMargin = closeButtonMargin
        self.topSeparatorViewColor = topSeparatorViewColor != nil ? topSeparatorViewColor! : UIColor(hexString: "D2D7E5")
        self.reviewFont = reviewFont
        self.reviewColor = reviewColor != nil ? reviewColor! : UIColor(hexString: "333333")
        self.reviewMargin = reviewMargin
        self.reviewYesButtonColor = reviewYesButtonColor != nil ? reviewYesButtonColor! : UIColor(hexString: "e9f8e6")
        self.reviewYesButtonCornerRadius = reviewYesButtonCornerRadius
        self.reviewYesFont = reviewYesFont
        self.reviewYesColor = reviewYesColor != nil ? reviewYesColor! : UIColor(hexString: "26BC00")
        self.reviewYesButtonTextMargin = reviewYesButtonTextMargin
        self.reviewYesButtonMargin = reviewYesButtonMargin
        self.reviewNoButtonColor = reviewNoButtonColor != nil ? reviewNoButtonColor! : UIColor(hexString: "fdeeee")
        self.reviewNoButtonCornerRadius = reviewNoButtonCornerRadius
        self.reviewNoFont = reviewNoFont
        self.reviewNoColor = reviewNoColor != nil ? reviewNoColor! : UIColor(hexString: "EB5757")
        self.reviewNoButtonTextMargin = reviewNoButtonTextMargin
        self.reviewNoButtonMargin = reviewNoButtonMargin
        self.reviewSendTextFont = reviewSendTextFont
        self.reviewSendTextColor = reviewSendTextColor
        self.reviewSendTextMargin = reviewSendTextMargin
        self.reviewLineBottomColor = reviewLineBottomColor != nil ? reviewLineBottomColor! : UIColor(hexString: "26BC00")
        self.reviewLineMarginTop = reviewLineMarginTop
        self.reviewLineHeight = reviewLineHeight
        self.reviewSendButtonColor = reviewSendButtonColor != nil ? reviewSendButtonColor! : UIColor(hexString: "e9f8e6")
        self.reviewSendButtonCornerRadius = reviewSendButtonCornerRadius
        self.reviewSendFont = reviewSendFont
        self.reviewSendColor = reviewSendColor != nil ? reviewSendColor! : UIColor(hexString: "26BC00")
        self.reviewSendButtonTextMargin = reviewSendButtonTextMargin
        self.reviewSendButtonMargin = reviewSendButtonMargin
        self.previousArticleImage = (previousArticleImage != nil) ? previousArticleImage! : UIImage.named("udPreviousArticle")
        self.previousArticleImageSize = previousArticleImageSize
        self.previousArticleImageMargin = previousArticleImageMargin
        self.nextArticleImage = (nextArticleImage != nil) ? nextArticleImage! : UIImage.named("udNextArticle")
        self.nextArticleImageSize = nextArticleImageSize
        self.nextArticleImageMargin = nextArticleImageMargin
        self.articlePreviousFont = articlePreviousFont
        self.articlePreviousColor = articlePreviousColor != nil ? articlePreviousColor! : UIColor(hexString: "2F80ED")
        self.articlePreviousMargin = articlePreviousMargin
        self.articleNextFont = articleNextFont
        self.articleNextColor = articleNextColor != nil ? articleNextColor! : UIColor(hexString: "2F80ED")
        self.articleNextMargin = articleNextMargin
        self.separatorViewColor = reviewYesColor != nil ? reviewYesColor! : UIColor(hexString: "D3D8E8")
        self.separatorViewMargin = separatorViewMargin
        self.separatorViewHeight = separatorViewHeight
    }
}
