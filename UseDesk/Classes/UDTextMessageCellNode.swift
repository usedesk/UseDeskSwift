//
//  UDTextMessageCellNode.swift
//  UseDesk_SDK_Swift
//

import Foundation
import AsyncDisplayKit

class UDTextMessageCellNode: UDMessageCellNode {
    
    private var isOutgoing = false
    private var textMessageNode =  ASTextNode()
    private var tableButtonsNode = ASTableNode()
    
    override init() {
        super.init()
    }
    
    override func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage, avatarImage: UIImage?) {
        messagesView = messagesView_
        self.isOutgoing = message.outgoing
        self.message = message
        let messageStyle = configurationStyle.messageStyle
        
        var attributedString = NSMutableAttributedString()
        if message.attributedString != nil {
            attributedString = message.attributedString!
        } else {
            attributedString = NSMutableAttributedString(string: message.text)
        }
        attributedString.addAttributes([NSAttributedString.Key.font : messageStyle.font, .foregroundColor : message.outgoing ? messageStyle.textOutgoingColor : messageStyle.textIncomingColor], range: NSRange(location: 0, length: attributedString.length))
        attributedString.enumerateAttribute(.link, in: NSRange(location: 0, length: attributedString.string.count)) { value, range, _ in
            if value != nil {
                attributedString.addAttribute(.underlineColor, value: message.outgoing ? messageStyle.linkOutgoingColor : messageStyle.linkIncomingColor, range: range)
                attributedString.addAttribute(.foregroundColor, value: message.outgoing ? messageStyle.linkOutgoingColor : messageStyle.linkIncomingColor, range: range)
            }
        }
        textMessageNode.attributedText = attributedString
        textMessageNode.isUserInteractionEnabled = true
        textMessageNode.delegate = self
        
        addSubnode(textMessageNode)

        if message.buttons.count > 0 {
            tableButtonsNode.view.separatorStyle = .none
            tableButtonsNode.dataSource = self
            tableButtonsNode.delegate = self
            tableButtonsNode.backgroundColor = .clear
            addSubnode(tableButtonsNode)
        }
        super.bindData(messagesView: messagesView, message: message, avatarImage: avatarImage)
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageStyle = configurationStyle.messageStyle
        let messageButtonStyle = configurationStyle.messageButtonStyle
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        
        textMessageNode.style.maxWidth = ASDimensionMakeWithPoints(constrainedSize.max.width)
        let textMessageInsets = ASInsetLayoutSpec(insets: UIEdgeInsets(top: messageStyle.textMargin.top, left: messageStyle.textMargin.left, bottom: messageStyle.textMargin.bottom, right: messageStyle.textMargin.right), child: textMessageNode)

        let vMessageStack = ASStackLayoutSpec()
        vMessageStack.direction = .vertical
        vMessageStack.style.flexShrink = 1.0
        vMessageStack.style.flexGrow = 1.0
        vMessageStack.style.maxWidth = ASDimensionMakeWithPoints(sizeMessagesManager.maxWidthBubbleMessage)
        vMessageStack.spacing = 0
        vMessageStack.alignItems = .start
        vMessageStack.setChild(textMessageInsets, at: 0)
        DispatchQueue.main.async(execute: { [weak self] in
            guard let wSelf = self else {return}
            wSelf.tableButtonsNode.reloadData()
        })
        if message.buttons.count > 0 {
            let insetSpec = ASInsetLayoutSpec(insets: messageButtonStyle.margin, child: tableButtonsNode)
            tableButtonsNode.style.minWidth = ASDimensionMakeWithPoints(60000.0)
            tableButtonsNode.style.flexGrow = 1.0
            tableButtonsNode.style.minHeight = ASDimensionMakeWithPoints(CGFloat(message.buttons.count) * (messageButtonStyle.height + messageButtonStyle.spacing) - messageButtonStyle.spacing)
            vMessageStack.setChild(insetSpec, at: 1)
        }
        
        let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: messageStyle.timeMargin.bottom, right: message.outgoing ? 0 : messageStyle.timeMargin.right), child: timeNode)
        let messageAndTimeAndSendedStack = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .end, alignItems: .end, children: [vMessageStack , timeInsetSpec])
        if message.outgoing {
            let sendedImageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: messageStyle.sendedStatusMargin.left, bottom: messageStyle.sendedStatusMargin.bottom, right: messageStyle.sendedStatusMargin.right), child: sendedImageNode)
            messageAndTimeAndSendedStack.setChild(sendedImageInsetSpec, at: 2)
        }
        messageAndTimeAndSendedStack.style.flexShrink = 1
        messageAndTimeAndSendedStack.style.flexGrow = 0
        
        contentMessageInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: messageAndTimeAndSendedStack)
        let messageLayoutSpec = super.layoutSpecThatFits(constrainedSize)
        return messageLayoutSpec
    }
}

extension UDTextMessageCellNode: ASTableDelegate, ASTableDataSource {
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return message.buttons.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = UDMessageButtonCellNode()
        cell.setCell(titleButton: message.buttons[indexPath.row].title)
        return cell
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if message.buttons[indexPath.row].url != "" {
            let urlDataDict:[String: String] = ["url": message.buttons[indexPath.row].url]
            DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("messageButtonURLOpen"), object: nil, userInfo: urlDataDict)
            }
        } else {
            let textDataDict:[String: String] = ["text": message.buttons[indexPath.row].title]
            DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("messageButtonSend"), object: nil, userInfo: textDataDict)
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let messageButtonStyle = configurationStyle.messageButtonStyle
        let min = CGSize(width: UIScreen.main.bounds.size.width, height: indexPath.row == 0 ? messageButtonStyle.height : messageButtonStyle.height + messageButtonStyle.spacing)
        let max = CGSize(width: UIScreen.main.bounds.size.width, height: indexPath.row == 0 ? messageButtonStyle.height : messageButtonStyle.height + messageButtonStyle.spacing)
        return ASSizeRange(min: min, max: max)
    }
}

extension UDTextMessageCellNode: ASTextNodeDelegate {
    public func textNode(_ textNode: ASTextNode, shouldHighlightLinkAttribute attribute: String, value: Any, at point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(_ textNode: ASTextNode, tappedLinkAttribute attribute: String, value: Any, at point: CGPoint, textRange: NSRange) {
        if let url = value as? URL {
            UIApplication.shared.open(url)
        }
    }
}

