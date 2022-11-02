//
//  UDTextMessageCellNode.swift
//  UseDesk_SDK_Swift
//

import Foundation
import AsyncDisplayKit
import UIKit
import MarkdownKit

protocol TextMessageCellNodeDelegate: AnyObject {
    func longPressText(text: String)
}

class UDTextMessageCellNode: UDMessageCellNode {
    
    private var isOutgoing = false
    private var textMessageNode = ASTextNode()
    private var tableButtonsNode = ASTableNode()
    
    weak var delegateText: TextMessageCellNodeDelegate?
    
    override init() {
        super.init()
    }
    
    override func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage, avatarImage: UIImage?) {
        messagesView = messagesView_
        self.isOutgoing = message.outgoing
        self.message = message
        let messageStyle = configurationStyle.messageStyle
        let linkColor = message.outgoing ? messageStyle.linkOutgoingColor : messageStyle.linkIncomingColor
        
        var attributedString = NSMutableAttributedString()
        let markdownParser = MarkdownParser(font: messageStyle.font, color: message.outgoing ? messageStyle.textOutgoingColor : messageStyle.textIncomingColor)
        attributedString = NSMutableAttributedString(attributedString: markdownParser.parse(message.text))
        attributedString.enumerateAttributes(in: NSRange(0..<attributedString.length), options: []) { (attributes, range, _) -> Void in
            for (attribute, _) in attributes {
                if attribute == .link {
                    attributedString.addAttribute(.foregroundColor, value: linkColor, range: range)
                    attributedString.addAttribute(.underlineColor, value: linkColor, range: range)
                }
            }
        }
        textMessageNode.attributedText = attributedString
        textMessageNode.isUserInteractionEnabled = true
        textMessageNode.delegate = self
        addSubnode(textMessageNode)

        if message.buttons.count > 0 {
            tableButtonsNode.dataSource = self
            tableButtonsNode.delegate = self
            tableButtonsNode.backgroundColor = .clear
            addSubnode(tableButtonsNode)
        }
        super.bindData(messagesView: messagesView, message: message, avatarImage: avatarImage)
        DispatchQueue.main.async {
            self.tableButtonsNode.view.separatorStyle = .none
        }
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
        vMessageStack.style.maxWidth = sizeMessagesManager.maxWidthBubbleMessageDimension
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
            var height: CGFloat = 0 // height tableButtonsNode
            for index in 0..<message.buttons.count {
                height += heightNodeCellButton(for: IndexPath(row: index, section: 0))
            }
            height += messageButtonStyle.margin.top + messageButtonStyle.margin.bottom
            tableButtonsNode.style.minHeight = ASDimensionMakeWithPoints(height)
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
    
    @objc func longPressTextAction() {
        delegateText?.longPressText(text: message.text)
    }
    
    func heightNodeCellButton(for indexPath: IndexPath) -> CGFloat {
        let messageButtonStyle = configurationStyle.messageButtonStyle
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        
        var heightButton: CGFloat = 0
        
        let widthTitle = sizeMessagesManager.maxWidthBubbleMessage - messageButtonStyle.margin.left - messageButtonStyle.margin.right - 16
        let heightLine = "1".size(attributes: [.font : messageButtonStyle.textFont]).height
        let heightTitle = message.buttons[indexPath.row].title.size(availableWidth: widthTitle, attributes: [.font : messageButtonStyle.textFont]).height

        if (heightTitle / heightLine).rounded(.up) > CGFloat(messageButtonStyle.maximumLine) {
            heightButton += heightLine * CGFloat(messageButtonStyle.maximumLine)
        } else {
            heightButton += heightTitle
        }
        
        heightButton += 16
        heightButton = heightButton < messageButtonStyle.minHeight ? messageButtonStyle.minHeight : heightButton
        if indexPath.row != 0 {
            heightButton += messageButtonStyle.spacing
        }
        
        return heightButton
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
        cell.configurationStyle = configurationStyle
        cell.setCell(titleButton: message.buttons[indexPath.row].title, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing)
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
        let heightButton = heightNodeCellButton(for: indexPath)
        let min = CGSize(width: UIScreen.main.bounds.size.width, height: heightButton)
        let max = CGSize(width: UIScreen.main.bounds.size.width, height: heightButton)
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
        } else if let valueString = value as? String {
            if let url = URL(string: valueString) {
                UIApplication.shared.open(url)
            }
        }
    }
}
