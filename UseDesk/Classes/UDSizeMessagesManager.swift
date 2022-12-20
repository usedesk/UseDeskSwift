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
    
}

