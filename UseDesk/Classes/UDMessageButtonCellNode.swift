//  UDMessageButtonCellNode.swift
//  UseDesk_SDK_Swift
//

import Foundation
import AsyncDisplayKit

class UDMessageButtonCellNode: ASCellNode {
    
    var titleNode = ASTextNode()
    let backgroundNode = ASDisplayNode()
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setCell(titleButton: String) {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        let messageStyle = configurationStyle.messageStyle
        let attributedString = NSMutableAttributedString(string: titleButton)
        attributedString.addAttributes([NSAttributedString.Key.font : messageStyle.font, .foregroundColor : UIColor.white], range: NSRange(location: 0, length: attributedString.length))
        titleNode.attributedText = attributedString
        titleNode.style.alignSelf = .center
        
        backgroundNode.backgroundColor = configurationStyle.messageButtonStyle.color
        backgroundNode.cornerRadius = configurationStyle.messageButtonStyle.cornerRadius
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
                    justifyContent: .center,
                    alignItems: .center,
                    children: [titleNodeInsetSpec])
        verticalSpec.setChild(vMessageStack, at: 0)
        verticalSpec.style.alignSelf = .center
        let verticalSpecInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: indexPath?.row == 0 ? 0 : 10, left: 0, bottom: 0, right: 0), child: verticalSpec)
        return verticalSpecInsetSpec
    }
}
