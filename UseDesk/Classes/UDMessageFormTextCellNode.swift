//
//  UDMessageFormCellNode.swift
//  UseDesk_SDK_Swift

import Foundation
import AsyncDisplayKit

class UDMessageFormTextCellNode: UDMessageFormCellNode, ASEditableTextNodeDelegate {
    let backgroundNode = ASDisplayNode()
    let textNode = ASEditableTextNode()
    
    weak var delegateValue: FormValueCellNodeDelegate?
    weak var delegate: FormCellNodeDelegate?
    
    override func setCell(form: UDFormMessage, spacing: CGFloat = 0, index: Int, status: StatusForm) {
        super.setCell(form: form, spacing: spacing, index: index, status: status)
        
        backgroundNode.cornerRadius = messageFormStyle.textFormCornerRadius
        backgroundNode.borderWidth = messageFormStyle.textFormBorderWidth
        backgroundNode.borderColor = form.isErrorState ? messageFormStyle.textFormBorderErrorColor : messageFormStyle.textFormBorderColor
        backgroundNode.backgroundColor = isUserInteractionEnabled ? messageFormStyle.textFormBackgroundColor : messageFormStyle.textFormUnavailableBackgroundColor
        // Placeholder
        let attributedPlaceholderString = NSMutableAttributedString(string: form.name)
        attributedPlaceholderString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : messageFormStyle.textFormPlaceholderColor], range: NSRange(location: 0, length: attributedPlaceholderString.length))
        if form.isRequired {
            let requiredAttributedString = NSMutableAttributedString(string: "*")
            requiredAttributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : messageFormStyle.textFormTextRequiredColor], range: NSRange(location: 0, length: requiredAttributedString.length))
            attributedPlaceholderString.append(requiredAttributedString)
        }
        textNode.attributedPlaceholderText = attributedPlaceholderString
        // Value
        let attributedString = NSMutableAttributedString(string: form.value)
        attributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : status == .inputable ? messageFormStyle.textFormTextColor : messageFormStyle.textFormTextUnavailableColor], range: NSRange(location: 0, length: attributedString.length))
        textNode.attributedText = attributedString
        // Setting TextNode
        textNode.maximumLinesToDisplay = 1
        textNode.textView.typingAttributes = [.font : messageFormStyle.textFormTextFont, .foregroundColor : messageFormStyle.textFormTextColor]
        textNode.delegate = self
        
        switch form.type {
        case .phone:
            setForPhone()
        case .email:
            setForEmail()
        default:
            break
        }
        if textNode.supernode == nil {
            addSubnode(backgroundNode)
            addSubnode(textNode)
        }
    }
    
    public func setEditableState() {
        let attributedString = NSMutableAttributedString(string: form.value)
        attributedString.addAttributes([.font : messageFormStyle.textFormTextFont, .foregroundColor : messageFormStyle.textFormTextColor], range: NSRange(location: 0, length: attributedString.length))
        textNode.attributedText = attributedString
        textNode.becomeFirstResponder()
    }
    // MARK: - Private Methods
    private func setForPhone() {
        textNode.keyboardType = .phonePad
    }
    
    private func setForEmail() {
        textNode.keyboardType = .emailAddress
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        backgroundNode.borderColor = messageFormStyle.textFormBorderColor
        form.value = editableTextNode.attributedText?.string ?? ""
        delegateValue?.newValue(value: form.value, indexForm: indexForm)
    }
    
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        delegate?.tapForm(indexForm: indexForm)
    }
    
    // MARK: - LayoutSpecThatFits
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let verticalSpec = ASBackgroundLayoutSpec()
        verticalSpec.background = backgroundNode
        
        let textNodeInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.textFormMargin, child: textNode)
        let textNodeСenterSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: textNodeInsetSpec)
        textNodeСenterSpec.style.flexShrink = 1
        textNodeСenterSpec.style.flexGrow = 1
        
        verticalSpec.setChild(textNodeСenterSpec, at: 0)
        verticalSpec.style.alignSelf = .center
        let verticalSpecInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: spacing, left: 0, bottom: 0, right: 0), child: verticalSpec)
        return verticalSpecInsetSpec
    }
}
