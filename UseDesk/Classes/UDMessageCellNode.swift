//
//  UDMessageCellNode.swift
//  UseDesk_SDK_Swift
//

import AsyncDisplayKit

class UDMessageCellNode: ASCellNode {
    var nameNode = ASTextNode()
    var bubbleImageNode = ASImageNode()
    var bubbleSelectingImageNode = ASImageNode()
    var avatarImageNode = ASNetworkImageNode()
    var timeBackNode = ASDisplayNode()
    var timeNode = ASTextNode()
    var sendedImageNode = ASImageNode()
    var notSentImageNode = ASImageNode()
    var activityIndicator: UIActivityIndicatorView?
    
    weak var messagesView: UDMessagesView?
    
    var message = UDMessage()
    var configurationStyle: ConfigurationStyle!
    var isNeedShowSender: Bool = false
    var isPictureOrVideoType: Bool = false
    var contentMessageInsetSpec = ASInsetLayoutSpec()
    var orientaion: Orientation = .portrait
    
    override init() {
        super.init()
        addSubnode(bubbleImageNode)
        addSubnode(bubbleSelectingImageNode)
    }
    
    func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage) {
        messagesView = messagesView_
        self.message = message
        configurationStyle = messagesView?.usedesk?.configurationStyle ?? ConfigurationStyle()
        let messageStyle = configurationStyle.messageStyle
        let bubbleStyle = configurationStyle.bubbleStyle
        
        backgroundColor = configurationStyle.chatStyle.backgroundColor
        
        var bubbleImage = message.outgoing ? bubbleStyle.backgroundImageOutgoing : bubbleStyle.backgroundImageIncoming
        bubbleImage = bubbleImage.stretchableImage(withLeftCapWidth: 23, topCapHeight: 16).withRenderingMode(.alwaysTemplate)
        bubbleImageNode.image = bubbleImage
        bubbleImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(message.incoming != false ? bubbleStyle.bubbleColorIncoming : bubbleStyle.bubbleColorOutgoing)
        
        bubbleSelectingImageNode.image = bubbleImage
        bubbleSelectingImageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(bubbleStyle.bubbleSelectColor)
        bubbleSelectingImageNode.alpha = 0
        
        //avatar and time
        if isPictureOrVideoType {
            timeBackNode.removeFromSupernode()
            timeBackNode.alpha = 0.6
            timeBackNode.backgroundColor = message.outgoing ? messageStyle.timeBackViewOutgoingColor : messageStyle.timeBackViewIncomingColor
            timeBackNode.cornerRadius = messageStyle.timeBackViewCornerRadius
            addSubnode(timeBackNode)
        }
        
        avatarImageNode.removeFromSupernode()
        notSentImageNode.removeFromSupernode()
        sendedImageNode.removeFromSupernode()
        nameNode.removeFromSupernode()
        
        avatarImageNode.image = message.avatarImage ?? configurationStyle.avatarStyle.avatarImageDefault
        
        if message.outgoing {
            avatarImageNode.style.preferredSize = CGSize.zero
            var imageSended = message.statusSend == UD_STATUS_SEND_SUCCEED ? messageStyle.sendedStatusImage : messageStyle.sendStatusImage
            if isPictureOrVideoType {
                imageSended = message.statusSend == UD_STATUS_SEND_SUCCEED ? messageStyle.sendedStatusImageForImageMessage : messageStyle.sendStatusImageForImageMessage
            }
            sendedImageNode.image = imageSended
            addSubnode(sendedImageNode)
            if message.statusSend == UD_STATUS_SEND_FAIL {
                notSentImageNode.alpha = 1
                notSentImageNode.image = messageStyle.notSentImage
                notSentImageNode.isUserInteractionEnabled = false
                addSubnode(notSentImageNode)
            } else {
                notSentImageNode.alpha = 0
            }
        } else {
            avatarImageNode.style.preferredSize = CGSize(width: configurationStyle.avatarStyle.avatarDiameter, height: configurationStyle.avatarStyle.avatarDiameter)
            avatarImageNode.cornerRadius = configurationStyle.avatarStyle.avatarDiameter / 2
            avatarImageNode.clipsToBounds = true
            addSubnode(avatarImageNode)

            nameNode.textContainerInset = messageStyle.senderTextMargin
            nameNode.attributedText = NSAttributedString(string: message.operatorName != "" ? message.operatorName : message.name, attributes: [.foregroundColor: messageStyle.senderTextColor, .font: messageStyle.senderTextFont])
            nameNode.alpha = isNeedShowSender ? 1 : 0
            addSubnode(nameNode)
        }
        
        timeNode.removeFromSupernode()
        var timeColor = UIColor.clear
        if isPictureOrVideoType {
            timeColor = message.outgoing ? messageStyle.timeOutgoingPictureColor : messageStyle.timeIncomingPictureColor
        } else {
            timeColor = message.outgoing ? messageStyle.timeOutgoingColor : messageStyle.timeIncomingColor
        }
        timeNode.attributedText = NSAttributedString(string: message.date.time, attributes : [.foregroundColor: timeColor, .font: messageStyle.timeFont])
        addSubnode(timeNode)
    }
    
    public func updateAnimateLoader() {
        guard activityIndicator != nil else {return}
        guard activityIndicator?.alpha == 1 && !(activityIndicator?.isAnimating ?? false) else {return}
        activityIndicator?.startAnimating()
    }
    
    public func setAvatarImage(_ avatarImage: UIImage) {
        avatarImageNode.image = avatarImage
    }
    
    public func startSelectionAnimate() {
        UIView.animate(withDuration: 0.3, delay: 0.0) {
            self.bubbleSelectingImageNode.alpha = 0.1
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.2) {
                self.bubbleSelectingImageNode.alpha = 0
            }
        }
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageStyle = configurationStyle.messageStyle
        let avatarStyle = configurationStyle.avatarStyle
        let bubbleStyle = configurationStyle.bubbleStyle
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        
        timeNode.style.alignSelf = .end

        sendedImageNode.style.alignSelf = .end
        sendedImageNode.style.maxSize = messageStyle.sendedStatusSize
        
        let contentMessageBackgroundSelectingSpec = ASBackgroundLayoutSpec()
        contentMessageBackgroundSelectingSpec.background = bubbleImageNode
        contentMessageBackgroundSelectingSpec.child = bubbleSelectingImageNode
        contentMessageBackgroundSelectingSpec.style.maxWidth = sizeMessagesManager.maxWidthBubbleMessageDimension
        contentMessageBackgroundSelectingSpec.style.flexShrink = 1
        contentMessageBackgroundSelectingSpec.style.flexGrow = 0

        let contentMessageBackgroundSpec = ASBackgroundLayoutSpec()
        contentMessageBackgroundSpec.background = contentMessageBackgroundSelectingSpec
        contentMessageBackgroundSpec.child = contentMessageInsetSpec
        contentMessageBackgroundSpec.style.maxWidth = sizeMessagesManager.maxWidthBubbleMessageDimension
        contentMessageBackgroundSpec.style.flexShrink = 1
        contentMessageBackgroundSpec.style.flexGrow = 0
        
        var layoutElements: [ASLayoutElement] = [contentMessageBackgroundSpec]
        if message.incoming && isNeedShowSender {
            nameNode.alpha = 1
            layoutElements.insert(nameNode, at: 0)
        }
        
        let contentMessageBackgroundAndNameStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: layoutElements)
        
        let hMessageStack = ASStackLayoutSpec()
        hMessageStack.direction = .horizontal
        hMessageStack.spacing = 0
        hMessageStack.style.alignSelf = .end
        
        if message.outgoing {
            let notSentImageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: messageStyle.notSentImageMarginToBubble), child: notSentImageNode)
            let notSentImageCenterSpec = ASCenterLayoutSpec(horizontalPosition: .end, verticalPosition: .center, sizingOption: [], child: notSentImageInsetSpec)
            if message.statusSend == UD_STATUS_SEND_FAIL {
                hMessageStack.setChild(notSentImageCenterSpec, at: 0)
            }
            hMessageStack.setChild(contentMessageBackgroundAndNameStack, at: 1)
            hMessageStack.horizontalAlignment = .right
        } else {
            avatarImageNode.style.width = ASDimensionMake(avatarStyle.avatarDiameter)
            avatarImageNode.style.height = ASDimensionMake(avatarStyle.avatarDiameter)
            let avatarImageInsetSpec = ASInsetLayoutSpec(insets: avatarStyle.margin, child: avatarImageNode)
            let avatarImageCenterSpec = ASCenterLayoutSpec(horizontalPosition: .start, verticalPosition: .end, sizingOption: [], child: avatarImageInsetSpec)
            hMessageStack.setChild(avatarImageCenterSpec, at: 0)
            hMessageStack.setChild(contentMessageBackgroundAndNameStack, at: 1)
            hMessageStack.horizontalAlignment = .left
        }
        
        hMessageStack.style.flexShrink = 1
        hMessageStack.style.flexGrow = 1
        
        //space it
        var insetshMessageStack = UIEdgeInsets.zero
        let isLast = indexPath?.section == 0 && indexPath?.row == 0
        if message.outgoing {
            insetshMessageStack = UIEdgeInsets(top: sizeMessagesManager.marginTopBubble(), left: bubbleStyle.marginAfter, bottom: isLast ? bubbleStyle.spacingOneSender : 0, right: bubbleStyle.marginBefore)
        } else if avatarStyle.avatarIncomingHidden {
            insetshMessageStack = UIEdgeInsets(top: sizeMessagesManager.marginTopBubble(), left: bubbleStyle.marginBefore, bottom: isLast ? bubbleStyle.spacingOneSender : 0, right: bubbleStyle.marginAfter)
        } else {
            insetshMessageStack = UIEdgeInsets(top: sizeMessagesManager.marginTopBubble(), left: 0, bottom: isLast ? bubbleStyle.spacingOneSender : 0, right: bubbleStyle.marginAfter)
        }
        let insethMessageSpec = ASInsetLayoutSpec(insets: insetshMessageStack, child: hMessageStack)
        
        let allMessageStack = ASStackLayoutSpec()
        allMessageStack.direction = .vertical
        allMessageStack.justifyContent = .spaceAround
        allMessageStack.alignItems = message.outgoing ? .end : .start
        
        allMessageStack.spacing = 0
        allMessageStack.children = [insethMessageSpec]
        return allMessageStack
    }
    
    func setSendedStatus() {
        sendedImageNode.image = isPictureOrVideoType ? configurationStyle.messageStyle.sendedStatusImageForImageMessage : configurationStyle.messageStyle.sendedStatusImage
        notSentImageNode.alpha = 0
    }
}
