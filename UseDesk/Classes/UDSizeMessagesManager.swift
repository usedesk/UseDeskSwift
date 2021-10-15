//
//  UDSizeMessagesManager.swift
//  UseDesk_SDK_Swift
//
import AsyncDisplayKit

class UDSizeMessagesManager: NSObject {
    
    private weak var messagesView: UDMessagesView?
    private var message = UDMessage()
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var indexPath: IndexPath?
    
    public var maxWidthBubbleMessage: CGFloat = 0
    public var maxWidthBubbleMessageDimension: ASDimension = ASDimensionMakeWithPoints(0)
    
    init(messagesView _messagesView: UDMessagesView?, message _message: UDMessage, indexPath _indexPath: IndexPath?, configurationStyle _configurationStyle: ConfigurationStyle) {
        super.init()
        self.messagesView = _messagesView
        self.message = _message
        self.indexPath = _indexPath
        self.configurationStyle = _configurationStyle
        setMaxWidthBubbleMessage()
    }
    
    func marginTopBubble() -> CGFloat {
        var marginBottom: CGFloat = 0
        let bubbleStyle = configurationStyle.bubbleStyle
        guard indexPath != nil else {return marginBottom}
        if let nextMessage = messagesView?.getMessage(IndexPath(row: indexPath!.row + 1, section: indexPath!.section)) {
            if message.typeSenderMessage == nextMessage.typeSenderMessage {
                marginBottom = bubbleStyle.spacingOneSender
                if nextMessage.typeSenderMessage == .operator_to_client {
                    marginBottom = message.operatorId == nextMessage.operatorId ? bubbleStyle.spacingOneSender : bubbleStyle.spacingDifferentSender
                }
            } else {
                marginBottom = bubbleStyle.spacingDifferentSender
            }
        } else {
            marginBottom = bubbleStyle.spacingOneSender
        }
        return marginBottom
    }
    
    func setMaxWidthBubbleMessage() {
        let avatarStyle = configurationStyle.avatarStyle
        let bubbleStyle = configurationStyle.bubbleStyle
        let messageStyle = configurationStyle.messageStyle
        
        var widthTimeAndSendedIcon = "99:99".size(attributes: [.foregroundColor: message.outgoing ? messageStyle.timeOutgoingColor : messageStyle.timeIncomingColor, .font: messageStyle.timeFont]).width
        
        if message.outgoing || (message.incoming && avatarStyle.avatarIncomingHidden) {
            maxWidthBubbleMessage = SCREEN_WIDTH - bubbleStyle.marginBefore - bubbleStyle.marginAfter
            widthTimeAndSendedIcon += messageStyle.sendedStatusSize.width + messageStyle.sendedStatusMargin.left + messageStyle.sendedStatusMargin.right
        } else {
            maxWidthBubbleMessage = SCREEN_WIDTH - avatarStyle.avatarDiameter - avatarStyle.margin.left - avatarStyle.margin.right - bubbleStyle.marginAfter
            widthTimeAndSendedIcon += messageStyle.timeMargin.right
        }
        maxWidthBubbleMessage -= widthTimeAndSendedIcon
        maxWidthBubbleMessageDimension = ASDimensionMakeWithPoints(maxWidthBubbleMessage)
    }
    
    func sizeImageMessageFrom(size: CGSize) -> CGSize {
        var heightPicture = size.height
        var widthPicture = size.width
        if heightPicture > 0 && widthPicture > 0 {
            let maxWidth = MAX_WIDTH_MESSAGE - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - configurationStyle.bubbleStyle.marginAfter
            if widthPicture > maxWidth {
                while widthPicture > maxWidth {
                    widthPicture = widthPicture * 0.95
                    if heightPicture > configurationStyle.bubbleStyle.bubbleHeightMin {
                        heightPicture = heightPicture * 0.95
                    }
                }
            } else if widthPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                while widthPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                    widthPicture = widthPicture * 1.05
                    if heightPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                        heightPicture = heightPicture * 1.05
                    }
                }
            }
            return CGSize(width: widthPicture, height: heightPicture)
        } else {
            return CGSize(width: configurationStyle.pictureStyle.sizeDefault.width, height: configurationStyle.pictureStyle.sizeDefault.height)
        }
    }
    
}

