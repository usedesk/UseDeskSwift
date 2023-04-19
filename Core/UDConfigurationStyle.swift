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
    public var noInternetStyle: NoInternetStyle
    public var inputViewStyle: InputViewStyle
    public var attachButtonStyle: AttachButtonStyle
    public var sendButtonStyle: SendButtonStyle
    public var attachViewStyle: AttachViewStyle
    public var messageButtonStyle: MessageButtonStyle
    public var messageFormStyle: MessageFormStyle
    public var scrollButtonStyle: ScrollButtonStyle
    public var feedbackFormStyle: FeedbackFormStyle
    public var selectTopicFeedbackFormStyle: SelectTopicFeedbackFormStyle
    public var baseStyle: BaseStyle
    public var baseSectionsStyle: BaseSectionsStyle
    public var baseCategoriesStyle: BaseCategoriesStyle
    public var baseArticlesListStyle: BaseArticlesListStyle
    public var baseSearchStyle: BaseSearchStyle
    public var baseArticleStyle: BaseArticleStyle
    public var baseArticleReviewStyle: BaseArticleReviewStyle
    
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
                noInternetStyle: NoInternetStyle = NoInternetStyle(),
                inputViewStyle: InputViewStyle = InputViewStyle(),
                attachButtonStyle: AttachButtonStyle = AttachButtonStyle(),
                sendButtonStyle: SendButtonStyle = SendButtonStyle(),
                attachViewStyle: AttachViewStyle = AttachViewStyle(),
                messageButtonStyle: MessageButtonStyle = MessageButtonStyle(),
                messageFormStyle: MessageFormStyle = MessageFormStyle(),
                scrollButtonStyle: ScrollButtonStyle = ScrollButtonStyle(),
                feedbackFormStyle: FeedbackFormStyle = FeedbackFormStyle(),
                selectTopicFeedbackFormStyle: SelectTopicFeedbackFormStyle = SelectTopicFeedbackFormStyle(),
                baseStyle: BaseStyle = BaseStyle(),
                baseSectionsStyle: BaseSectionsStyle = BaseSectionsStyle(),
                baseCategoriesStyle: BaseCategoriesStyle = BaseCategoriesStyle(),
                articlesListStyle: BaseArticlesListStyle = BaseArticlesListStyle(),
                baseSearchStyle: BaseSearchStyle = BaseSearchStyle(),
                baseArticleStyle: BaseArticleStyle = BaseArticleStyle(),
                baseArticleReviewStyle: BaseArticleReviewStyle = BaseArticleReviewStyle()) {
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
        self.noInternetStyle = noInternetStyle
        self.inputViewStyle = inputViewStyle
        self.attachButtonStyle = attachButtonStyle
        self.sendButtonStyle = sendButtonStyle
        self.attachViewStyle = attachViewStyle
        self.messageButtonStyle = messageButtonStyle
        self.messageFormStyle = messageFormStyle
        self.scrollButtonStyle = scrollButtonStyle
        self.feedbackFormStyle = feedbackFormStyle
        self.selectTopicFeedbackFormStyle = selectTopicFeedbackFormStyle
        self.baseStyle = baseStyle
        self.baseSectionsStyle = baseSectionsStyle
        self.baseCategoriesStyle = baseCategoriesStyle
        self.baseArticlesListStyle = articlesListStyle
        self.baseSearchStyle = baseSearchStyle
        self.baseArticleStyle = baseArticleStyle
        self.baseArticleReviewStyle = baseArticleReviewStyle
    }
}

// MARK: - NavigationBar
public struct NavigationBarStyle {
    public var backgroundColor: UIColor
    public var textColor: UIColor
    public var font: UIFont
    public var statusBarStyle: UIStatusBarStyle
    public var backButtonColor: UIColor?
    public var backButtonImage: UIImage?
    public var backButtonInFileImage: UIImage?
    public var searchButtonImage: UIImage?
    
    public init(backgroundColor: UIColor? = nil,
                textColor: UIColor? = nil,
                font: UIFont = UIFont.boldSystemFont(ofSize: 19),
                statusBarStyle: UIStatusBarStyle = .default,
                backButtonColor: UIColor? = nil,
                backButtonImage: UIImage? = nil,
                backButtonInFileImage: UIImage? = nil,
                searchButtonImage: UIImage? = nil) {
        self.backgroundColor = backgroundColor ?? UIColor(hexString: "F7F7F7")
        self.textColor = textColor ?? UIColor(hexString: "333333")
        self.font = font
        self.statusBarStyle = statusBarStyle
        self.backButtonColor = backButtonColor ?? UIColor(hexString: "#454D63")
        self.backButtonImage = backButtonImage ?? UIImage.named("udBackButton")
        self.backButtonInFileImage = backButtonInFileImage ?? UIImage.named("udBackInFileButton")
        self.searchButtonImage = searchButtonImage ?? UIImage.named("udSearch")
    }
}
// MARK: - ChatStyle
public struct ChatStyle {
    public var backgroundColor: UIColor
    public var backgroundColorLoaderView: UIColor
    public var alphaLoaderView: CGFloat
    
    public init(backgroundColor: UIColor? = nil,
                backgroundColorLoaderView: UIColor? = nil,
                alphaLoaderView: CGFloat = 0.8) {
        self.backgroundColor = backgroundColor ?? UIColor(hexString: "FFFFFF")
        self.backgroundColorLoaderView = backgroundColorLoaderView ?? .lightGray
        self.alphaLoaderView = alphaLoaderView
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
        self.textColor = textColor ?? UIColor(hexString: "454D63")
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
    public var bubbleSelectColor: UIColor
    
    public init(backgroundImageOutgoing: UIImage? = nil,
                backgroundImageIncoming: UIImage? = nil,
                marginBefore: CGFloat = 10.0,
                marginAfter: CGFloat = 50.0,
                bubbleWidthMin: CGFloat = 7.0,
                bubbleHeightMin: CGFloat = 30.0,
                spacingOneSender: CGFloat = 4,
                spacingDifferentSender: CGFloat = 16,
                bubbleColorOutgoing: UIColor? = nil,
                bubbleColorIncoming: UIColor? = nil,
                bubbleSelectColor: UIColor? = nil) {
        self.backgroundImageOutgoing = backgroundImageOutgoing ?? UIImage.named("udBubbleOutgoing")
        self.backgroundImageIncoming = backgroundImageIncoming ?? UIImage.named("udBubbleIncoming")
        self.marginBefore = marginBefore
        self.marginAfter = marginAfter
        self.bubbleWidthMin = bubbleWidthMin
        self.bubbleHeightMin = bubbleHeightMin
        self.spacingOneSender = spacingOneSender
        self.spacingDifferentSender = spacingDifferentSender
        self.bubbleColorOutgoing = bubbleColorOutgoing ?? UIColor(hexString: "e0ecfc")
        self.bubbleColorIncoming = bubbleColorIncoming ?? UIColor(hexString: "F0F0F0")
        self.bubbleSelectColor = bubbleSelectColor ?? UIColor(hexString: "08A3E2")
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
    public var avatarImageDefault: UIImage
    
    public init(avatarDiameter: CGFloat = 30.0,
                margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
                avatarIncomingHidden: Bool = false,
                avatarBackColor: UIColor? = nil,
                avatarTextColor: UIColor = UIColor.white,
                avatarFont: UIFont = UIFont.systemFont(ofSize: 12),
                avatarImageDefault: UIImage? = nil) {
        self.avatarDiameter = avatarDiameter
        self.margin = margin
        self.avatarIncomingHidden = avatarIncomingHidden
        self.avatarBackColor = avatarBackColor ?? UIColor(hexString: "d6d6d6ff")
        self.avatarTextColor = avatarTextColor
        self.avatarFont = avatarFont
        self.avatarImageDefault = avatarImageDefault ?? UIImage.named("udAvatarOperator")
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
        self.textOutgoingColor = textOutgoingColor ?? UIColor(hexString: "333333")
        self.textIncomingColor = textIncomingColor ?? UIColor(hexString: "333333")
        self.linkOutgoingColor = linkOutgoingColor ?? UIColor(hexString: "007AFF")
        self.linkIncomingColor = linkIncomingColor ?? UIColor(hexString: "007AFF")
        self.font = font
        self.textMargin = textMargin
        self.timeOutgoingPictureColor = timeOutgoingPictureColor ?? UIColor(hexString: "FFFFFF")
        self.timeIncomingPictureColor = timeIncomingPictureColor ?? UIColor(hexString: "FFFFFF")
        self.timeOutgoingColor = timeOutgoingColor ?? UIColor(hexString: "989FB3")
        self.timeIncomingColor = timeIncomingColor ?? UIColor(hexString: "989FB3")
        self.timeFont = timeFont
        self.timeMargin = timeMargin
        self.timeBackViewOutgoingColor = timeBackViewOutgoingColor ?? UIColor(hexString: "333333")
        self.timeBackViewIncomingColor = timeBackViewIncomingColor ?? UIColor(hexString: "333333")
        self.timeBackViewOpacity = timeBackViewOpacity
        self.timeBackViewCornerRadius = timeBackViewCornerRadius
        self.timeBackViewPadding = timeBackViewPadding
        self.timeBackViewMargin = timeBackViewMargin
        self.sendStatusImage = sendStatusImage ?? UIImage.named("udSendStatusImage")
        self.sendedStatusImage = sendedStatusImage ?? UIImage.named("udSendedStatusImage")
        self.sendStatusImageForImageMessage = sendStatusImageForImageMessage ?? UIImage.named("udSendStatusImageWhite")
        self.sendedStatusImageForImageMessage = sendedStatusImageForImageMessage ?? UIImage.named("udSendedStatusImageWhite")
        self.sendedStatusSize = sendedStatusSize
        self.sendedStatusMargin = sendedStatusMargin
        self.notSentImage = notSentImage ?? UIImage.named("udNotSentImage")
        self.notSentImageSize = notSentImageSize
        self.notSentImageMarginToBubble = notSentImageMarginToBubble
        self.senderTextColor = senderTextColor ?? UIColor(hexString: "989FB3")
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
        self.likeOnImage = likeOnImage ?? UIImage.named("udLikeOn")
        self.likeOffImage = likeOffImage ?? UIImage.named("udLikeOff")
        self.dislikeOnImage = dislikeOnImage ?? UIImage.named("udDislikeOn")
        self.dislikeOffImage = dislikeOffImage ?? UIImage.named("udDislikeOff")
        self.isFirstDislike = isFirstDislike
        self.textColor = textColor ?? UIColor(hexString: "333333")
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
        self.imageDefault = imageDefault ?? UIImage.named("udPictureDefault")
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
        self.imageDefault = imageDefault ?? UIImage.named("udVideoDefault")
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
        self.imageIcon = imageIcon ?? UIImage.named("udFileIcon")
        self.iconSize = iconSize
        self.fontName = fontName
        self.nameMargin = nameMargin
        self.nameOutgoingColor = nameOutgoingColor ?? UIColor(hexString: "333333")
        self.nameIncomingColor = nameIncomingColor ?? UIColor(hexString: "333333")
        self.fontSize = fontSize
        self.sizeMarginTop = sizeMarginTop
        self.sizeOutgoingColor = sizeOutgoingColor ?? UIColor(hexString: "989FB3")
        self.sizeIncomingColor = sizeIncomingColor ?? UIColor(hexString: "989FB3")
    }
}

// MARK: - NoInternetStyle
public struct NoInternetStyle {
    public var backgroundColor: UIColor
    public var iconImage: UIImage
    public var iconImageSize: CGSize
    public var titleMargin: UIEdgeInsets
    public var titleFont: UIFont
    public var titleColor: UIColor
    public var textMargin: UIEdgeInsets
    public var textFont: UIFont
    public var textColor: UIColor
    
    public init(backgroundColor: UIColor? = nil,
                iconImage: UIImage? = nil,
                iconImageSize: CGSize = CGSize(width: 70, height: 70),
                titleMargin: UIEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 8, right: 20),
                titleFont: UIFont = UIFont.systemFont(ofSize: 21, weight: .semibold),
                titleColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12),
                textFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .medium),
                textColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor ?? UIColor(hexString: "#F7F7F7")
        self.iconImage = iconImage != nil ? iconImage! : UIImage.named("udNoInternet")
        self.iconImageSize = iconImageSize
        self.titleMargin = titleMargin
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.textMargin = textMargin
        self.textFont = textFont
        self.textColor = textColor ?? UIColor(hexString: "7F8085")
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
        self.viewBackColor = viewBackColor ?? UIColor(hexString: "F7F7F7")
        self.textBackColor = textBackColor
        self.textColor = textColor
        self.placeholderTextColor = placeholderTextColor ?? UIColor(hexString: "#BDBDBD")
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
        self.image = image ?? UIImage.named("udAttachButton")
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
        self.image = image ?? UIImage.named("udSendButton")
        self.margin = margin
        self.size = size
    }
}

// MARK: - AttachView Style
public struct AttachViewStyle {
    public var backgroundColor: UIColor
    public var textButtonColor: UIColor
    
    public init(backgroundColor: UIColor? = nil,
                textButtonColor: UIColor? = nil) {
        self.backgroundColor = backgroundColor ?? UIColor(hexString: "F9F9F9")
        self.textButtonColor = textButtonColor ?? UIColor(hexString: "007AFF")
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
                minHeight: CGFloat = 36,
                margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 8, right: 6),
                maximumLine: Int = 3) {
        self.color = color ?? UIColor(hexString: "333333")
        self.textColor = textColor ?? UIColor(hexString: "FFFFFF")
        self.textFont = textFont
        self.cornerRadius = cornerRadius
        self.spacing = spacing
        self.minHeight = minHeight
        self.margin = margin
        self.maximumLine = maximumLine
    }
}

// MARK: - Message Form
public struct MessageFormStyle {
    public var margin: UIEdgeInsets
    public var spacing: CGFloat
    
    public var textFormMargin: UIEdgeInsets
    public var textFormHeight: CGFloat
    public var textFormBackgroundColor: UIColor
    public var textFormUnavailableBackgroundColor: UIColor
    public var textFormPlaceholderColor: UIColor
    public var textFormTextColor: UIColor
    public var textFormTextUnavailableColor: UIColor
    public var textFormTextRequiredColor: UIColor
    public var textFormTextFont: UIFont
    public var textFormCornerRadius: CGFloat
    public var textFormBorderWidth: CGFloat
    public var textFormBorderColor: CGColor
    public var textFormBorderErrorColor: CGColor
    public var textFormIconSelect: UIImage
    public var textFormIconSelectSize: CGSize
    public var textFormIconMargin: UIEdgeInsets // left, right
    
    public var checkboxFormImageSize: CGSize
    public var checkboxFormImageMargin: UIEdgeInsets
    public var checkboxFormTextMargin: UIEdgeInsets
    public var checkboxFormImageNotSelected: UIImage
    public var checkboxFormImageSelected: UIImage
    public var checkboxFormImageSelectedUnavailable: UIImage
    public var checkboxFormImageError: UIImage
    
    public var sendFormButtonColor: UIColor
    public var sendFormButtonErrorColor: UIColor
    public var sendFormButtonUnavailableColor: UIColor
    public var sendFormButtonTitleColor: UIColor
    public var sendFormButtonTitleTouchedColor: UIColor
    public var sendFormButtonFont: UIFont
    public var sendFormButtonCornerRadius: CGFloat
    public var sendFormButtonMargin: UIEdgeInsets
    public var sendFormButtonHeight: CGFloat
    public var sendFormActivityIndicatorStyle: UIActivityIndicatorView.Style
    
    public var pickerDoneButtonColor: UIColor
    public var pickerTopViewColor: UIColor
    
    public init(margin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 6),
                spacing: CGFloat = 10,
                textFormMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
                textFormHeight: CGFloat = 36,
                textFormBackgroundColor: UIColor? = nil,
                textFormUnavailableBackgroundColor: UIColor? = nil,
                textFormPlaceholderColor: UIColor? = nil,
                textFormTextColor: UIColor? = nil,
                textFormTextUnavailableColor: UIColor? = nil,
                textFormTextRequiredColor: UIColor? = nil,
                textFormTextFont: UIFont = UIFont.systemFont(ofSize: 15),
                textFormCornerRadius: CGFloat = 8,
                textFormBorderWidth: CGFloat = 1,
                textFormBorderColor: CGColor? = nil,
                textFormBorderErrorColor: CGColor? = nil,
                textFormIconSelect: UIImage? = nil,
                textFormIconSelectSize: CGSize = CGSize(width: 8, height: 8),
                textFormIconMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
                checkboxFormImageSize: CGSize = CGSize(width: 16, height: 16),
                checkboxFormImageMargin: UIEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 0, right: 0),
                checkboxFormTextMargin: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 12),
                checkboxFormImageNotSelected: UIImage? = nil,
                checkboxFormImageSelected: UIImage? = nil,
                checkboxFormImageSelectedUnavailable: UIImage? = nil,
                checkboxFormImageError: UIImage? = nil,
                sendFormButtonColor: UIColor? = nil,
                sendFormButtonErrorColor: UIColor? = nil,
                sendFormButtonUnavailableColor: UIColor? = nil,
                sendFormButtonTitleColor: UIColor? = nil,
                sendFormButtonTitleTouchedColor: UIColor? = nil,
                sendFormButtonFont: UIFont = UIFont.systemFont(ofSize: 15),
                sendFormButtonCornerRadius: CGFloat = 8,
                sendFormButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 6),
                sendFormButtonHeight: CGFloat = 36,
                sendFormActivityIndicatorStyle: UIActivityIndicatorView.Style = .gray,
                pickerDoneButtonColor: UIColor = .blue,
                pickerTopViewColor: UIColor? = nil) {
        self.margin = margin
        self.spacing = spacing
        self.textFormMargin = textFormMargin
        self.textFormHeight = textFormHeight
        self.textFormBackgroundColor = textFormBackgroundColor ?? UIColor(hexString: "FAFBFC")
        self.textFormUnavailableBackgroundColor = textFormUnavailableBackgroundColor ?? UIColor(hexString: "FAFBFC")
        self.textFormPlaceholderColor = textFormPlaceholderColor ?? UIColor(hexString: "989FB3")
        self.textFormTextColor = textFormTextColor ?? UIColor(hexString: "333333")
        self.textFormTextUnavailableColor = textFormTextUnavailableColor ?? UIColor(hexString: "989FB3")
        self.textFormTextRequiredColor = textFormTextRequiredColor ?? UIColor(hexString: "E74450")
        self.textFormTextFont = textFormTextFont
        self.textFormCornerRadius = textFormCornerRadius
        self.textFormBorderWidth = textFormBorderWidth
        self.textFormBorderColor = textFormBorderColor ?? UIColor(hexString: "D3D6E3").cgColor
        self.textFormBorderErrorColor = textFormBorderErrorColor ?? UIColor(hexString: "E74450").cgColor
        self.textFormIconSelect = textFormIconSelect ?? UIImage.named("udFormListIcon")
        self.textFormIconSelectSize = textFormIconSelectSize
        self.textFormIconMargin = textFormIconMargin
        self.checkboxFormImageSize = checkboxFormImageSize
        self.checkboxFormImageMargin = checkboxFormImageMargin
        self.checkboxFormTextMargin = checkboxFormTextMargin
        self.checkboxFormImageNotSelected = checkboxFormImageNotSelected ?? UIImage.named("udFormCheckboxNotSelected")
        self.checkboxFormImageSelected = checkboxFormImageSelected ?? UIImage.named("udFormCheckboxSelected")
        self.checkboxFormImageSelectedUnavailable = checkboxFormImageSelectedUnavailable ?? UIImage.named("udFormCheckboxSelectedUnavailable")
        self.checkboxFormImageError = checkboxFormImageError ?? UIImage.named("udFormCheckboxError")
        self.sendFormButtonColor = sendFormButtonColor ?? UIColor(hexString: "333333")
        self.sendFormButtonErrorColor = sendFormButtonErrorColor ?? UIColor(hexString: "E74450")
        self.sendFormButtonUnavailableColor = sendFormButtonUnavailableColor ?? UIColor(hexString: "BCBCBC")
        self.sendFormButtonTitleColor = sendFormButtonTitleColor ?? UIColor(hexString: "FFFFFF")
        self.sendFormButtonTitleTouchedColor = sendFormButtonTitleTouchedColor ?? UIColor(hexString: "4d4d4d")
        self.sendFormButtonFont = sendFormButtonFont
        self.sendFormButtonCornerRadius = sendFormButtonCornerRadius
        self.sendFormButtonMargin = sendFormButtonMargin
        self.sendFormButtonHeight = sendFormButtonHeight
        self.sendFormActivityIndicatorStyle = sendFormActivityIndicatorStyle
        self.pickerDoneButtonColor = pickerDoneButtonColor
        self.pickerTopViewColor = pickerTopViewColor ?? UIColor(hexString: "F7F7F7")
    }
}

// MARK: - ScrollButtonStyle
public struct ScrollButtonStyle {
    public var scrollButtonImage: UIImage
    public var scrollButtonSize: CGSize
    public var scrollButtonMargin: UIEdgeInsets
    public var newMessagesViewHeight: CGFloat
    public var newMessagesViewMarginBottom: CGFloat
    public var newMessagesViewColor: UIColor
    public var newMessagesLabelFont: UIFont
    public var newMessagesLabelColor: UIColor
    
    public init(scrollButtonImage: UIImage? = nil,
                scrollButtonSize: CGSize = CGSize(width: 40, height: 40),
                scrollButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 12),
                newMessagesViewDiameter: CGFloat = 20,
                newMessagesViewMarginBottom: CGFloat = 10,
                newMessagesViewColor: UIColor? = nil,
                newMessagesLabelFont: UIFont = .systemFont(ofSize: 13),
                newMessagesLabelColor: UIColor? = nil) {
        self.scrollButtonImage = scrollButtonImage ?? UIImage.named("udScrollButton")
        self.scrollButtonSize = scrollButtonSize
        self.scrollButtonMargin = scrollButtonMargin
        self.newMessagesViewHeight = newMessagesViewDiameter
        self.newMessagesViewMarginBottom = newMessagesViewMarginBottom
        self.newMessagesViewColor = newMessagesViewColor ?? UIColor(hexString: "EB5757")
        self.newMessagesLabelFont = newMessagesLabelFont
        self.newMessagesLabelColor = newMessagesLabelColor ?? .white
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
    public var attachButtonTitleColor: UIColor
    public var attachButtonTitleFont: UIFont
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
                attachButtonTitleColor: UIColor? = nil,
                attachButtonTitleFont: UIFont = UIFont.systemFont(ofSize: 13),
                errorColor: UIColor? = nil,
                sendedImage: UIImage? = nil) {
        self.buttonColor = buttonColor ?? UIColor(hexString: "333333")
        self.buttonColorDisabled = buttonColorDisabled ?? UIColor(hexString: "565656")
        self.buttonTextColor = buttonTextColor ?? .white
        self.buttonFont = buttonFont
        self.buttonCornerRadius = buttonCornerRadius
        self.textColor = textColor ?? .black
        self.textFont = textFont
        self.headerFont = headerFont
        self.headerColor = headerColor ?? UIColor(hexString: "BDBDBD")
        self.headerSelectedColor = headerSelectedColor ?? UIColor(hexString: "EB5757")
        self.valueFont = valueFont
        self.valueColor = valueColor ?? UIColor(hexString: "333333")
        self.arrowImage =  arrowImage ?? UIImage.named("udArrow")
        self.arrowImageSize = arrowImageSize
        self.lineSeparatorColor = lineSeparatorColor ?? UIColor(hexString: "E0E0E0")
        self.lineSeparatorActiveColor = lineSeparatorActiveColor ?? UIColor(hexString: "EB5757")
        self.attachButtonTitleColor = attachButtonTitleColor ?? UIColor(hexString: "333333")
        self.attachButtonTitleFont = attachButtonTitleFont
        self.errorColor = errorColor ?? UIColor(hexString: "EB5757")
        self.sendedImage = sendedImage ?? UIImage.named("udSended")
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
        self.titleTopicColor = titleTopicColor ?? UIColor(hexString: "333333")
        self.titleTopicMargin = titleTopicMargin
        self.lineSeparatorColor = lineSeparatorColor ?? UIColor(hexString: "E0E0E0")
        self.selectImage = selectImage ?? UIImage.named("udSelectCircle")
        self.selectedImage = selectedImage ?? UIImage.named("udSelectedCircle")
        self.selectImageSize = selectImageSize
        self.selectImageMarginRight = selectImageMarginRight
    }
}

// MARK: - Base
public struct BaseStyle {
    public var windowBottomMargin: CGFloat
    
    public var loaderStyle: UIActivityIndicatorView.Style
    
    public var backgroundColor: UIColor
    public var backButtonImage: UIImage
    public var backButtonSize: CGSize
    public var backButtonMargin: UIEdgeInsets
    
    public var topBlurСoefficient: CGFloat
    
    public var titleSmallFont: UIFont
    public var titleSmallColor: UIColor
    public var titleSmallMargin: UIEdgeInsets
    
    public var contentMarginLeft: CGFloat
    public var contentMarginRight: CGFloat
    
    public var contentViewsBackgroundColor: UIColor
    public var contentViewsCornerRadius: CGFloat
    public var contentViewsShadowOffset: CGSize
    public var contentViewsShadowOpacity: Float
    public var contentViewsShadowRadius: CGFloat
    public var contentViewsShadowColor: CGColor
    
    public var titleBigFont: UIFont
    public var titleBigColor: UIColor
    public var titleBigMarginTop: CGFloat
    
    public var tableMarginTop: CGFloat
    
    public var isNeedChat: Bool
    public var chatIconImage: UIImage
    public var chatButtonBackColor: UIColor
    public var chatButtonCornerRadius: CGFloat
    public var chatButtonSize: CGSize
    public var chatButtonMargin: UIEdgeInsets
    public var chatButtonShadowOffset: CGSize
    public var chatButtonShadowOpacity: Float
    public var chatButtonShadowRadius: CGFloat
    public var chatButtonShadowColor: CGColor
    
    public var searchBarHeight: CGFloat
    public var searchBarTextBackgroundColor: UIColor
    public var searchBarTextColor: UIColor
    public var searchBarTintColor: UIColor
    public var searchCancelButtonColor: UIColor
    public var searchCancelButtonFont: UIFont
    public var searchSeparatorColor: UIColor
    public var searchNotFoundLabelFont: UIFont
    public var searchNotFoundLabelColor: UIColor
    public var searchNotFoundLabelMarginTop: CGFloat
    
    public var errorLoadImage: UIImage
    public var errorLoadImageMargin: UIEdgeInsets // Left and right
    public var errorLoadImageAspectRatioMultiplier: CGFloat
    public var errorLoadImageCenterYMultiplier: CGFloat
    public var errorLoadTextFont: UIFont
    public var errorLoadTextColor: UIColor
    
    public init(windowBottomMargin: CGFloat = 0,
                loaderStyle: UIActivityIndicatorView.Style = .gray,
                backgroundColor: UIColor? = nil,
                backButtonImage: UIImage? = nil,
                backButtonSize: CGSize = CGSize(width: 48, height: 40),
                backButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 5, bottom: 0, right: 0),
                topBlurСoefficient: CGFloat = 0.1,
                titleSmallFont: UIFont = UIFont.systemFont(ofSize: 17),
                titleSmallColor: UIColor = .black,
                titleSmallMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                contentMarginLeft: CGFloat = 16,
                contentMarginRight: CGFloat = 16,
                contentViewsBackgroundColor: UIColor = .white,
                contentViewsCornerRadius: CGFloat = 10,
                contentViewsShadowOffset: CGSize = CGSize(width: 0, height: 4),
                contentViewsShadowOpacity: Float = 10,
                contentViewsShadowRadius: CGFloat = 4,
                contentViewsShadowColor: CGColor? = nil,
                titleBigFont: UIFont = UIFont.boldSystemFont(ofSize: 24),
                titleBigColor: UIColor = .black,
                titleBigMarginTop: CGFloat = 7,
                tableMarginTop: CGFloat = 20,
                isNeedChat: Bool = true,
                chatIconImage: UIImage? = nil,
                chatButtonBackColor: UIColor? = nil,
                chatButtonCornerRadius: CGFloat = 28,
                chatButtonSize: CGSize = CGSize(width: 56, height: 56),
                chatButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 17, right: 12),
                chatButtonShadowOffset: CGSize = CGSize(width: 0, height: 10),
                chatButtonShadowOpacity: Float = 0.2,
                chatButtonShadowRadius: CGFloat = 15,
                chatButtonShadowColor: CGColor? = nil,
                searchBarHeight: CGFloat = 56,
                searchBarTextBackgroundColor: UIColor? = nil,
                searchBarTextColor: UIColor? = nil,
                searchBarTintColor: UIColor = .systemBlue,
                searchCancelButtonColor: UIColor? = nil,
                searchCancelButtonFont: UIFont = UIFont.systemFont(ofSize: 17),
                searchSeparatorColor: UIColor? = nil,
                searchNotFoundLabelFont: UIFont = UIFont.systemFont(ofSize: 18),
                searchNotFoundLabelColor: UIColor? = nil,
                searchNotFoundLabelMarginTop: CGFloat = 20,
                errorLoadImage: UIImage? = nil,
                errorLoadImageMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                errorLoadImageAspectRatioMultiplier: CGFloat = 1.555,
                errorLoadImageCenterYMultiplier: CGFloat = 0.7,
                errorLoadTextFont: UIFont = UIFont.systemFont(ofSize: 21),
                errorLoadTextColor: UIColor = .black) {
        self.windowBottomMargin = windowBottomMargin
        self.loaderStyle = loaderStyle
        self.backgroundColor = backgroundColor ?? UIColor(hexString: "#F7F7F7")
        self.backButtonImage = backButtonImage ?? UIImage.named("udBackKnowledge")
        self.backButtonSize = backButtonSize
        self.backButtonMargin = backButtonMargin
        self.topBlurСoefficient = topBlurСoefficient
        self.titleSmallFont = titleSmallFont
        self.titleSmallColor = titleSmallColor
        self.titleSmallMargin = titleSmallMargin
        self.contentMarginLeft = contentMarginLeft
        self.contentMarginRight = contentMarginRight
        self.contentViewsBackgroundColor = contentViewsBackgroundColor
        self.contentViewsCornerRadius = contentViewsCornerRadius
        self.contentViewsShadowOffset = contentViewsShadowOffset
        self.contentViewsShadowOpacity = contentViewsShadowOpacity
        self.contentViewsShadowRadius = contentViewsShadowRadius
        self.contentViewsShadowColor = contentViewsShadowColor ?? UIColor(hexString: "FAFAFA").cgColor
        self.titleBigFont = titleBigFont
        self.titleBigColor = titleBigColor
        self.titleBigMarginTop = titleBigMarginTop
        self.tableMarginTop = tableMarginTop
        self.isNeedChat = isNeedChat
        self.chatIconImage = chatIconImage ?? UIImage.named("udChatIcon")
        self.chatButtonBackColor = chatButtonBackColor ?? UIColor(hexString: "333333")
        self.chatButtonCornerRadius = chatButtonCornerRadius
        self.chatButtonSize = chatButtonSize
        self.chatButtonMargin = chatButtonMargin
        self.chatButtonShadowOffset = chatButtonShadowOffset
        self.chatButtonShadowOpacity = chatButtonShadowOpacity
        self.chatButtonShadowRadius = chatButtonShadowRadius
        self.chatButtonShadowColor = chatButtonShadowColor ?? UIColor(hexString: "000000").cgColor
        self.searchBarHeight = searchBarHeight
        self.searchBarTextBackgroundColor = searchBarTextBackgroundColor ?? UIColor(hexString: "#EFEFF0")
        self.searchBarTextColor = searchBarTextColor ?? .black
        self.searchBarTintColor = searchBarTintColor
        self.searchCancelButtonColor = searchCancelButtonColor ?? UIColor(hexString: "EB5757")
        self.searchCancelButtonFont = searchCancelButtonFont
        self.searchSeparatorColor = searchSeparatorColor ?? UIColor(hexString: "FBFBFB")
        self.searchNotFoundLabelFont = searchNotFoundLabelFont
        self.searchNotFoundLabelColor = searchNotFoundLabelColor ?? UIColor(hexString: "989FB3")
        self.searchNotFoundLabelMarginTop = searchNotFoundLabelMarginTop
        self.errorLoadImage = errorLoadImage ?? UIImage.named("udErrorLoad")
        self.errorLoadImageMargin = errorLoadImageMargin
        self.errorLoadImageAspectRatioMultiplier = errorLoadImageAspectRatioMultiplier
        self.errorLoadImageCenterYMultiplier = errorLoadImageCenterYMultiplier
        self.errorLoadTextFont = errorLoadTextFont
        self.errorLoadTextColor = errorLoadTextColor
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
    public var arrowMarginRight: CGFloat
    
    public init(textFont: UIFont = UIFont.systemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 17, left: 10, bottom: 17, right: 10),
                iconDefaultImage: UIImage? = nil,
                iconFont: UIFont = UIFont.boldSystemFont(ofSize: 22),
                iconTextColor: UIColor? = nil,
                iconSize: CGSize = CGSize(width: 44, height: 44),
                iconMargin: UIEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 0, right: 0),
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMarginRight: CGFloat = 17) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.iconDefaultImage = iconDefaultImage ?? UIImage.named("udIconBaseSection")
        self.iconFont = iconFont
        self.iconTextColor = iconTextColor ?? UIColor(hexString: "989FB3")
        self.iconSize = iconSize
        self.iconMargin = iconMargin
        self.arrowImage = arrowImage ?? UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMarginRight = arrowMarginRight
    }
}
// MARK: - Base Categories
public struct BaseCategoriesStyle {
    // Cell Style
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var descriptionFont: UIFont
    public var descriptionColor: UIColor
    public var descriptionMargin: UIEdgeInsets
    public var arrowImage: UIImage
    public var arrowSize: CGSize
    public var arrowMarginRight: CGFloat
    
    public init(textFont: UIFont = UIFont.systemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 13, left: 20, bottom: 5, right: 10),
                descriptionFont: UIFont = UIFont.systemFont(ofSize: 12),
                descriptionColor: UIColor? = nil,
                descriptionMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 0),
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMarginRight: CGFloat = 17) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor ?? UIColor(hexString: "989FB3")
        self.descriptionMargin = descriptionMargin
        self.arrowImage = arrowImage ?? UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMarginRight = arrowMarginRight
    }
}
// MARK: - Articles List
public struct BaseArticlesListStyle {
    // Cell Style
    public var textFont: UIFont
    public var textColor: UIColor
    public var textMargin: UIEdgeInsets
    public var arrowImage: UIImage
    public var arrowSize: CGSize
    public var arrowMarginRight: CGFloat
    
    public init(textFont: UIFont = UIFont.systemFont(ofSize: 17),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14),
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMarginRight: CGFloat = 17) {
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.arrowImage = arrowImage ?? UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMarginRight = arrowMarginRight
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
    public var contentMarginRight: CGFloat
    public var arrowImage: UIImage
    public var arrowSize: CGSize
    public var arrowMarginRight: CGFloat
    
    public init(titleFont: UIFont = UIFont.systemFont(ofSize: 17),
                titleColor: UIColor? = nil,
                titleMargin: UIEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 4, right: 0),
                textFont: UIFont = UIFont.systemFont(ofSize: 14),
                textColor: UIColor = .black,
                textMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 8, right: 0),
                pathFont: UIFont = UIFont.systemFont(ofSize: 14),
                pathColor: UIColor? = nil,
                pathMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 12, right: 0),
                contentMarginRight: CGFloat = 10,
                arrowImage: UIImage? = nil,
                arrowSize: CGSize = CGSize(width: 24, height: 24),
                arrowMarginRight: CGFloat = 17) {
        self.titleFont = titleFont
        self.titleColor = titleColor ?? UIColor(hexString: "333333")
        self.titleMargin = titleMargin
        self.textFont = textFont
        self.textColor = textColor
        self.textMargin = textMargin
        self.pathFont = pathFont
        self.pathColor = pathColor ?? UIColor(hexString: "989FB3")
        self.pathMargin = pathMargin
        self.contentMarginRight = contentMarginRight
        self.arrowImage = arrowImage ?? UIImage.named("udArrow")
        self.arrowSize = arrowSize
        self.arrowMarginRight = arrowMarginRight
    }
}
// MARK: - Base Article
public struct BaseArticleStyle {
    public var articleViewMarginTop: CGFloat
    
    public var reviewViewMarginTop: CGFloat
    public var isNeedReview: Bool
    
    public var reviewTitleFont: UIFont
    public var reviewTitleColor: UIColor
    public var reviewTitleMargin: UIEdgeInsets
    
    public var reviewButtonCornerRadius: CGFloat
    public var reviewButtonFont: UIFont
    public var reviewButtonContentInsets: UIEdgeInsets
    public var reviewButtonImagePadding: CGFloat
    public var isNeedImageForReviewButton: Bool
    
    public var reviewYesButtonColor: UIColor
    public var reviewYesTextColor: UIColor
    public var reviewYesImage: UIImage
    public var reviewYesButtonMargin: UIEdgeInsets
    
    public var reviewNoButtonColor: UIColor
    public var reviewNoTextColor: UIColor
    public var reviewNoImage: UIImage
    public var reviewNoButtonMargin: UIEdgeInsets
    
    public var reviewPositiveTextFont: UIFont
    public var reviewPositiveTextColor: UIColor
    public var reviewPositiveTextMargin: UIEdgeInsets
    
    public init(isNeedReview: Bool = true,
                articleViewMarginTop: CGFloat = 20,
                reviewViewMarginTop: CGFloat = 20,
                reviewTitleFont: UIFont = UIFont.systemFont(ofSize: 12),
                reviewTitleColor: UIColor? = nil,
                reviewTitleMargin: UIEdgeInsets = UIEdgeInsets(top: 15, left: 13, bottom: 0, right: 13),
                reviewButtonCornerRadius: CGFloat = 5,
                reviewButtonFont: UIFont = UIFont.systemFont(ofSize: 14),
                reviewButtonContentInsets: UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 9, right: 9),
                reviewButtonImagePadding: CGFloat = 10,
                isNeedImageForReviewButton: Bool = true,
                reviewYesButtonColor: UIColor? = nil,
                reviewYesTextColor: UIColor? = nil,
                reviewYesImage: UIImage? = nil,
                reviewYesButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 6, left: 13, bottom: 19, right: 10),
                reviewNoButtonColor: UIColor? = nil,
                reviewNoTextColor: UIColor? = nil,
                reviewNoImage: UIImage? = nil,
                reviewNoButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 19, right: 8),
                reviewPositiveTextFont: UIFont = UIFont.systemFont(ofSize: 16),
                reviewPositiveTextColor: UIColor = .black,
                reviewPositiveTextMargin: UIEdgeInsets = UIEdgeInsets(top: 6, left: 13, bottom: 10, right: 13)) {
        self.isNeedReview = isNeedReview
        self.articleViewMarginTop = articleViewMarginTop
        self.reviewViewMarginTop = reviewViewMarginTop
        self.reviewTitleFont = reviewTitleFont
        self.reviewTitleColor = reviewTitleColor ?? UIColor(hexString: "989FB3")
        self.reviewTitleMargin = reviewTitleMargin
        self.reviewYesButtonColor = reviewYesButtonColor ?? UIColor(hexString: "e9f8e6")
        self.reviewButtonCornerRadius = reviewButtonCornerRadius
        self.reviewButtonFont = reviewButtonFont
        self.reviewButtonContentInsets = reviewButtonContentInsets
        self.reviewButtonImagePadding = reviewButtonImagePadding
        self.isNeedImageForReviewButton = isNeedImageForReviewButton
        self.reviewYesTextColor = reviewYesTextColor ?? UIColor(hexString: "26BC00")
        self.reviewYesImage = reviewYesImage ?? UIImage.named("udReviewPositiveButton")
        self.reviewYesButtonMargin = reviewYesButtonMargin
        self.reviewNoButtonColor = reviewNoButtonColor ?? UIColor(hexString: "fdeeee")
        self.reviewNoTextColor = reviewNoTextColor ?? UIColor(hexString: "EB5757")
        self.reviewNoImage = reviewYesImage ?? UIImage.named("udReviewNegativeButton")
        self.reviewNoButtonMargin = reviewNoButtonMargin
        self.reviewPositiveTextFont = reviewPositiveTextFont
        self.reviewPositiveTextColor = reviewPositiveTextColor
        self.reviewPositiveTextMargin = reviewPositiveTextMargin
    }
}

// MARK: - Base Article
public struct BaseArticleReviewStyle {
    public var isNeedTags: Bool
    public var tags: [String]
    public var tagsViewMarginTop: CGFloat
    public var tagBackActiveColor: UIColor
    public var tagBackNoActiveColor: UIColor
    public var tagCornerRadius: CGFloat
    public var tagLineSpacing: CGFloat
    public var tagInteritemSpacing: CGFloat
    public var tagTextFont: UIFont
    public var tagTextActiveColor: UIColor
    public var tagTextNoActiveColor: UIColor
    public var tagTextMargin: UIEdgeInsets
    
    public var reviewViewMarginTop: CGFloat
    public var reviewViewBackground: UIColor
    public var reviewViewCornerRadius: CGFloat
    
    public var reviewTextFont: UIFont
    public var reviewTextColor: UIColor
    public var reviewPlaceholderColor: UIColor
    public var reviewTextMargin: UIEdgeInsets
    
    public var reviewSendButtonColor: UIColor
    public var reviewSendButtonCornerRadius: CGFloat
    public var reviewSendButtonTitleFont: UIFont
    public var reviewSendButtonTitleColorNormal: UIColor
    public var reviewSendButtonTitleColorHighlighted: UIColor
    public var reviewSendButtonMargin: UIEdgeInsets
    public var reviewSendButtonHeight: CGFloat
    
    public init(isNeedTags: Bool = true,
                tags: [String] = [],
                tagsViewMarginTop: CGFloat = 20,
                tagBackActiveColor: UIColor? = nil,
                tagBackNoActiveColor: UIColor? = nil,
                tagCornerRadius: CGFloat = 5,
                tagMargin: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                tagLineSpacing: CGFloat = 10,
                tagInteritemSpacing: CGFloat = 10,
                tagTextFont: UIFont = UIFont.systemFont(ofSize: 14),
                tagTextActiveColor: UIColor = .white,
                tagTextNoActiveColor: UIColor = .black,
                tagTextMargin: UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 9, right: 10),
                reviewViewMarginTop: CGFloat = 20,
                reviewViewBackground: UIColor = .white,
                reviewViewCornerRadius: CGFloat = 10,
                reviewTextFont: UIFont = UIFont.systemFont(ofSize: 14),
                reviewTextColor: UIColor = .black,
                reviewPlaceholderColor: UIColor? = nil,
                reviewTextMargin: UIEdgeInsets = UIEdgeInsets(top: 17, left: 12, bottom: 17, right: 12),
                reviewSendButtonColor: UIColor? = nil,
                reviewSendButtonCornerRadius: CGFloat = 8,
                reviewSendButtonTitleFont: UIFont = UIFont.boldSystemFont(ofSize: 18),
                reviewSendButtonTitleColorNormal: UIColor = .white,
                reviewSendButtonTitleColorHighlighted: UIColor = .lightGray,
                reviewSendButtonMargin: UIEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 20, right: 24),
                reviewSendButtonHeight: CGFloat = 48) {
        self.isNeedTags = isNeedTags
        self.tags = tags
        self.tagsViewMarginTop = tagsViewMarginTop
        self.tagBackActiveColor = tagBackActiveColor ?? UIColor(hexString: "3E4347")
        self.tagBackNoActiveColor = tagBackNoActiveColor ?? UIColor(hexString: "DADADA")
        self.tagCornerRadius = tagCornerRadius
        self.tagLineSpacing = tagLineSpacing
        self.tagInteritemSpacing = tagInteritemSpacing
        self.tagTextFont = tagTextFont
        self.tagTextActiveColor = tagTextActiveColor
        self.tagTextNoActiveColor = tagTextNoActiveColor
        self.tagTextMargin = tagTextMargin
        self.reviewViewMarginTop = reviewViewMarginTop
        self.reviewViewBackground = reviewViewBackground
        self.reviewViewCornerRadius = reviewViewCornerRadius
        self.reviewTextFont = reviewTextFont
        self.reviewTextColor = reviewTextColor
        self.reviewPlaceholderColor = reviewPlaceholderColor ?? UIColor(hexString: "989FB3")
        self.reviewTextMargin = reviewTextMargin
        self.reviewSendButtonColor = reviewSendButtonColor ?? UIColor(hexString: "3E4347")
        self.reviewSendButtonCornerRadius = reviewSendButtonCornerRadius
        self.reviewSendButtonTitleFont = reviewSendButtonTitleFont
        self.reviewSendButtonTitleColorNormal = reviewSendButtonTitleColorNormal
        self.reviewSendButtonTitleColorHighlighted = reviewSendButtonTitleColorHighlighted
        self.reviewSendButtonMargin = reviewSendButtonMargin
        self.reviewSendButtonHeight = reviewSendButtonHeight
    }
    
    func tags(locale: String) -> [String] {
        var tagsForArticleReview: [String] = []
        switch locale {
        case "ru":
            tagsForArticleReview = ["Нет ответа на мой вопрос", "Нет иллюстраций", "Инструкция не работает", "Маленький шрифт", "Трудно найти то, что я искал"]
        case "en":
            tagsForArticleReview = ["I didn't find the answer", "No pics", "It won't work", "The font size is too small", "It's challenging to find what I looked for"]
        case "es":
            tagsForArticleReview = ["No encontre la respuesta", "Sin fotos", "No funcionará", "El tamaño de fuente es demasiado pequeño.", "Es difícil encontrar lo que buscaba."]
        case "pt":
            tagsForArticleReview = ["Não encontrei a resposta", "Sem fotos", "Não funcionará", "O tamanho da fonte é muito pequeno", "É um desafio encontrar o que estava  procurando"]
        default:
            break
        }
        return tagsForArticleReview
    }
}
