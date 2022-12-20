//
//  UDFileMessageCellNode.swift
//  UseDesk_SDK_Swift


import UIKit
import Foundation
import AsyncDisplayKit

class UDFileMessageCellNode: UDMessageCellNode {
    private var iconNode = ASImageNode()
    private var nameFileTextNode = ASTextNode()
    private var sizeTextNode = ASTextNode()
    private var loaderNode = ASDisplayNode()
    
    var messageTextParagraphStyle = NSMutableParagraphStyle()
    
    weak var usedesk: UseDeskSDK?
    
    override init() {
        super.init()
        iconNode.addTarget(self, action: #selector(self.actionTapBubble), forControlEvents: .touchUpInside)
        nameFileTextNode.addTarget(self, action: #selector(self.actionTapBubble), forControlEvents: .touchUpInside)
        sizeTextNode.addTarget(self, action: #selector(self.actionTapBubble), forControlEvents: .touchUpInside)
        bubbleImageNode.addTarget(self, action: #selector(self.actionTapBubble), forControlEvents: .touchUpInside)
    }
    
    override func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage) {
        guard usedesk != nil else {return}
        messagesView = messagesView_
        self.message = message
        configurationStyle = messagesView?.usedesk?.configurationStyle ?? ConfigurationStyle()
        let fileStyle = configurationStyle.fileStyle
        let messageStyle = configurationStyle.messageStyle
        
        iconNode.image = fileStyle.imageIcon
        iconNode.style.width = ASDimensionMakeWithPoints(fileStyle.iconSize.width)
        iconNode.style.height = ASDimensionMakeWithPoints(fileStyle.iconSize.height)
        
        loaderNode = ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            guard let wSelf = self else {return UIView()}
            wSelf.activityIndicator = UIActivityIndicatorView(style: .white)
            wSelf.activityIndicator?.hidesWhenStopped = false
            if message.status == UD_STATUS_OPENIMAGE || message.file.path == "" {
                wSelf.activityIndicator?.startAnimating()
                wSelf.activityIndicator?.alpha = 1
                wSelf.iconNode.alpha = 0
            } else {
                if message.status == UD_STATUS_SUCCEED {
                    wSelf.activityIndicator?.stopAnimating()
                    wSelf.activityIndicator?.alpha = 0
                    wSelf.iconNode.alpha = 1
                } else {
                    wSelf.activityIndicator?.startAnimating()
                    wSelf.activityIndicator?.alpha = 1
                    wSelf.iconNode.alpha = 0
                }
            }
            return wSelf.activityIndicator ?? UIView()
        })
        
        let nameFileAttributedString = NSMutableAttributedString(string: message.file.name != "" ? message.file.name : "file")
        nameFileAttributedString.addAttributes([NSAttributedString.Key.font : fileStyle.fontName, .foregroundColor : message.outgoing ? fileStyle.nameOutgoingColor : fileStyle.nameIncomingColor], range: NSRange(location: 0, length: nameFileAttributedString.length))
        nameFileTextNode.attributedText = nameFileAttributedString
        nameFileTextNode.maximumNumberOfLines = 1
        nameFileTextNode.truncationMode = .byTruncatingMiddle
        
        let sizeAttributedString = NSMutableAttributedString(string: message.file.sizeString(model: usedesk!.model))
        sizeAttributedString.addAttributes([NSAttributedString.Key.font : fileStyle.fontSize, .foregroundColor : message.outgoing ? fileStyle.sizeOutgoingColor : fileStyle.sizeIncomingColor], range: NSRange(location: 0, length: sizeAttributedString.length))
        sizeTextNode.attributedText = sizeAttributedString

        if iconNode.supernode == nil {
            addSubnode(iconNode)
            addSubnode(nameFileTextNode)
            addSubnode(sizeTextNode)
            addSubnode(loaderNode)
        }
        
        super.bindData(messagesView: messagesView, message: message)
        
        var timeBlockWidth = messageStyle.timeMargin.left + (timeNode.attributedText?.size().width ?? 0)
        if message.outgoing {
            timeBlockWidth += messageStyle.sendedStatusMargin.left + messageStyle.sendedStatusSize.width + messageStyle.sendedStatusMargin.right
        } else {
            timeBlockWidth += messageStyle.timeMargin.right
        }
        sizeTextNode.style.minWidth = ASDimensionMakeWithPoints(sizeAttributedString.size().width + timeBlockWidth)
    }
    
    public func removeLoader() {
        DispatchQueue.main.async {
            guard self.iconNode.alpha == 0 else {return}
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.alpha = 0
            self.iconNode.alpha = 1
        }
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageStyle = configurationStyle.messageStyle
        let fileStyle = configurationStyle.fileStyle
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        
        let loaderAndIconOverlaySpec = ASOverlayLayoutSpec()
        let centerLoaderSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: loaderNode)
        loaderAndIconOverlaySpec.overlay = centerLoaderSpec
        loaderAndIconOverlaySpec.child = iconNode
        let loaderAndIconInsetSpec = ASInsetLayoutSpec(insets: fileStyle.iconMargin, child: loaderAndIconOverlaySpec)
        
        let nameFileTextInsetSpec = ASInsetLayoutSpec(insets: fileStyle.nameMargin, child: nameFileTextNode)
        let sizeTextInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: fileStyle.nameMargin.right), child: sizeTextNode)
        
        let vTextsStack = ASStackLayoutSpec()
        vTextsStack.direction = .vertical
        vTextsStack.spacing = fileStyle.sizeMarginTop
        vTextsStack.alignItems = .start
        vTextsStack.style.flexShrink = 1
        vTextsStack.style.flexGrow = 0
        vTextsStack.setChild(nameFileTextInsetSpec, at: 0)
        vTextsStack.setChild(sizeTextInsetSpec, at: 1)
        
        let vTextsStackCenterSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: vTextsStack)
        vTextsStackCenterSpec.style.flexShrink = 1
        vTextsStackCenterSpec.style.flexGrow = 0
        
        let hIconAndTextsStack = ASStackLayoutSpec()
        hIconAndTextsStack.direction = .horizontal
        hIconAndTextsStack.spacing = 0
        hIconAndTextsStack.style.flexShrink = 0
        hIconAndTextsStack.style.flexGrow = 0
        hIconAndTextsStack.style.alignSelf = .auto
        hIconAndTextsStack.style.maxWidth = sizeMessagesManager.maxWidthBubbleMessageDimension
        hIconAndTextsStack.alignItems = .start
        hIconAndTextsStack.setChild(loaderAndIconInsetSpec, at: 0)
        hIconAndTextsStack.setChild(vTextsStackCenterSpec, at: 1)
        
        let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: messageStyle.timeMargin.bottom, right: message.outgoing ? 0 : messageStyle.timeMargin.right), child: timeNode)
        let timeAndSendedStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .end, alignItems: .end, children: [timeInsetSpec])
        if message.outgoing {
            let sendedImageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: messageStyle.sendedStatusMargin.left, bottom: messageStyle.sendedStatusMargin.bottom, right: messageStyle.sendedStatusMargin.right), child: sendedImageNode)
            timeAndSendedStack.setChild(sendedImageInsetSpec, at: 1)
        }
        
        let timeAndSendedCenterSpec = ASCenterLayoutSpec(horizontalPosition: .end, verticalPosition: .end, sizingOption: .minimumWidth, child: timeAndSendedStack)
        let timeAndSendedForBubbleOverlaySpec = ASOverlayLayoutSpec()
        timeAndSendedForBubbleOverlaySpec.overlay = timeAndSendedCenterSpec
        timeAndSendedForBubbleOverlaySpec.child = hIconAndTextsStack
        
        contentMessageInsetSpec = ASInsetLayoutSpec(insets: .zero, child: timeAndSendedForBubbleOverlaySpec)
        let messageLayoutSpec = super.layoutSpecThatFits(constrainedSize)
        return messageLayoutSpec
    }
    
    func setLoadedFileStatus() {
        activityIndicator?.stopAnimating()
        activityIndicator?.alpha = 0
        iconNode.alpha = 1
    }
    
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
}

