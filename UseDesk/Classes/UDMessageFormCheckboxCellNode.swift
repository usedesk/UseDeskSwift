//
//  UDMessageFormCheckboxCellNode.swift
//  UseDesk_SDK_Swift

import Foundation
import AsyncDisplayKit

class UDMessageFormCheckboxCellNode: UDMessageFormCellNode {
    
    let checkboxImageNode = ASImageNode()
    let titleNode = ASTextNode()
    
    weak var delegate: FormValueCellNodeDelegate?
    
    override func setCell(form: UDFormMessage, spacing: CGFloat = 0, index: Int, status: StatusForm) {
        super.setCell(form: form, spacing: spacing, index: index, status: status)
        
        if form.isErrorState {
            checkboxImageNode.image = messageFormStyle.checkboxFormImageError
        } else if status == .sended {
            checkboxImageNode.image = form.value == "1" ? messageFormStyle.checkboxFormImageSelectedUnavailable : messageFormStyle.checkboxFormImageNotSelected
        } else {
            checkboxImageNode.image = form.value == "1" ? messageFormStyle.checkboxFormImageSelected : messageFormStyle.checkboxFormImageNotSelected
        }
        checkboxImageNode.style.maxSize = messageFormStyle.checkboxFormImageSize
        
        let attributedString = NSMutableAttributedString(string: form.name)
        attributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : status == .inputable ? messageFormStyle.textFormTextColor : messageFormStyle.textFormTextUnavailableColor], range: NSRange(location: 0, length: attributedString.length))
        titleNode.attributedText = attributedString
        
        if checkboxImageNode.supernode == nil {
            addSubnode(checkboxImageNode)
            addSubnode(titleNode)
        }
    }
    
    public func setCheckbox(isOn: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.checkboxImageNode.image = isOn ? self.messageFormStyle.checkboxFormImageSelected : self.messageFormStyle.checkboxFormImageNotSelected
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let checkboxImageNodeInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.checkboxFormImageMargin, child: checkboxImageNode)
        titleNode.style.maxWidth = constrainedSize.max.width > 0 ? ASDimensionMakeWithPoints(constrainedSize.max.width - messageFormStyle.checkboxFormImageMargin.left - messageFormStyle.checkboxFormImageMargin.right - messageFormStyle.checkboxFormImageSize.width - messageFormStyle.checkboxFormTextMargin.left - messageFormStyle.checkboxFormTextMargin.right) : ASDimensionMakeWithPoints(0)
        let titleNodeInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.checkboxFormTextMargin, child: titleNode)
        titleNodeInsetSpec.style.flexGrow = 1
        let vMessageStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 0,
            justifyContent: .start,
            alignItems: .start,
            children: [checkboxImageNodeInsetSpec, titleNodeInsetSpec])
        vMessageStack.style.flexShrink = 1
        vMessageStack.style.flexGrow = 0
        let verticalSpecInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: spacing, left: 0, bottom: 0, right: 0), child: vMessageStack)
        return verticalSpecInsetSpec
    }
}

