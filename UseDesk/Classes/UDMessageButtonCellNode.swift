//  UDMessageButtonCellNode.swift
//  UseDesk_SDK_Swift
//

import Foundation
import AsyncDisplayKit

class UDMessageButtonCellNode: ASCellNode {
    
    var titleNode = ASTextNode()
    let backgroundNode = ASDisplayNode()
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    var spacing: CGFloat = 0
    
    func setCell(titleButton: String, spacing: CGFloat = 0) {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.spacing = spacing
        let messageButtonStyle = configurationStyle.messageButtonStyle
        let attributedString = NSMutableAttributedString(string: titleButton)
        attributedString.addAttributes([.font : messageButtonStyle.textFont, .foregroundColor : messageButtonStyle.textColor], range: NSRange(location: 0, length: attributedString.length))
        titleNode.attributedText = attributedString
        titleNode.maximumNumberOfLines = UInt(messageButtonStyle.maximumLine)
        titleNode.truncationMode = .byTruncatingTail
        titleNode.style.alignSelf = .center
        
        backgroundNode.backgroundColor = messageButtonStyle.color
        backgroundNode.cornerRadius = messageButtonStyle.cornerRadius
        addSubnode(backgroundNode)
        addSubnode(titleNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = backgroundNode
        let titleNodeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), child: titleNode)
        let vMessageStack = ASStackLayoutSpec(
                    direction: .vertical,
                    spacing: 0,
                    justifyContent: .start,
                    alignItems: .center,
                    children: [titleNodeInsetSpec])
        verticalSpec.setChild(vMessageStack, at: 0)
        verticalSpec.style.alignSelf = .center
        let verticalSpecInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: spacing, left: 0, bottom: 0, right: 0), child: verticalSpec)
        return verticalSpecInsetSpec
    }
}
