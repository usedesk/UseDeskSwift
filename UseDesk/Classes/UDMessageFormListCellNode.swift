//
//  UDMessageFormListCellNode.swift
//  UseDesk_SDK_Swift


import Foundation
import AsyncDisplayKit

class UDMessageFormListCellNode: UDMessageFormCellNode {
    let backgroundNode = ASDisplayNode()
    let textNode = ASTextNode()
    let iconNode = ASImageNode()
    
    override func setCell(form: UDFormMessage, spacing: CGFloat = 0, index: Int, status: StatusForm) {
        super.setCell(form: form, spacing: spacing, index: index, status: status)
        
        backgroundNode.cornerRadius = messageFormStyle.textFormCornerRadius
        backgroundNode.borderWidth = messageFormStyle.textFormBorderWidth
        backgroundNode.borderColor = form.isErrorState ? messageFormStyle.textFormBorderErrorColor : messageFormStyle.textFormBorderColor
        backgroundNode.backgroundColor = isUserInteractionEnabled ? messageFormStyle.textFormBackgroundColor : messageFormStyle.textFormUnavailableBackgroundColor
        
        let attributedString = NSMutableAttributedString(string: form.field?.selectedOption != nil ? form.field!.selectedOption!.value : form.name)
        attributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : status == .inputable ? messageFormStyle.textFormTextColor : messageFormStyle.textFormTextUnavailableColor], range: NSRange(location: 0, length: attributedString.length))
        if form.isRequired && form.field?.selectedOption == nil {
            let requiredAttributedString = NSMutableAttributedString(string: "*")
            requiredAttributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : messageFormStyle.textFormTextRequiredColor], range: NSRange(location: 0, length: requiredAttributedString.length))
            attributedString.append(requiredAttributedString)
        }
        textNode.attributedText = attributedString
        textNode.truncationMode = .byTruncatingMiddle
        textNode.maximumNumberOfLines = 1
        
        iconNode.image = messageFormStyle.textFormIconSelect
        iconNode.style.maxSize = messageFormStyle.textFormIconSelectSize
        iconNode.style.alignSelf = .end
        iconNode.alpha = status == .sended ? 0 : 1
        
        if backgroundNode.supernode == nil {
            addSubnode(backgroundNode)
            addSubnode(textNode)
            addSubnode(iconNode)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = backgroundNode
        let textNodeInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.textFormMargin, child: textNode)
        let textNodeСenterSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: textNodeInsetSpec)
        textNodeСenterSpec.style.flexShrink = 1
        
        let iconNodeСenterSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: iconNode)
        let iconNodeInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.textFormIconMargin, child: iconNodeСenterSpec)
        iconNodeInsetSpec.style.alignSelf = .end
        let iconNodeStack = ASStackLayoutSpec(
                    direction: .horizontal,
                    spacing: 0,
                    justifyContent: .end,
                    alignItems: .end,
                    children: [iconNodeInsetSpec])
        iconNodeStack.style.flexShrink = 0
        iconNodeStack.style.flexGrow = 1
        
        let vMessageStack = ASStackLayoutSpec(
                    direction: .horizontal,
                    spacing: 0,
                    justifyContent: .start,
                    alignItems: .start,
                    children: [textNodeСenterSpec, iconNodeStack])
        vMessageStack.style.flexShrink = 1
        vMessageStack.style.flexGrow = 1
        verticalSpec.setChild(vMessageStack, at: 0)
        verticalSpec.style.alignSelf = .center
        let verticalSpecInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: spacing, left: 0, bottom: 0, right: 0), child: verticalSpec)
        return verticalSpecInsetSpec
    }
}
