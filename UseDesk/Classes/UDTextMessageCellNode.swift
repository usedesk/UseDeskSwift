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
    func formListAction(message: UDMessage, indexForm: Int, selectedOption: FieldOption?)
    func newFormValue(value: String, message: UDMessage, indexForm: Int)
    func sendFormAction(message: UDMessage)
}

class UDTextMessageCellNode: UDMessageCellNode {
    
    private var isOutgoing = false
    private var textMessageNode = ASTextNode()
    private var tableButtonsNode = ASTableNode()
    private var tableFormsNode = ASTableNode()
    private var sendFormButton = ASButtonNode()
    private var loaderNode = ASDisplayNode()
    
    weak var delegateText: TextMessageCellNodeDelegate?
    weak var delegateForm: FormDelegate?
    
    var isLoadedFields = true
    
    private var messageFormStyle: MessageFormStyle {
        get {
            return configurationStyle.messageFormStyle
        }
    }
    
    override init() {
        super.init()
        self.addSubnode(self.textMessageNode)
    }
    
    override func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage) {
        messagesView = messagesView_
        isOutgoing = message.outgoing
        self.message = message
        configurationStyle = messagesView?.usedesk?.configurationStyle ?? ConfigurationStyle()
        setSell()
    }
    
    private func setSell() {
        let messageFormStyle = configurationStyle.messageFormStyle
        
        setTextMessageNode()
        
        if message.buttons.count > 0 {
            tableButtonsNode.dataSource = self
            tableButtonsNode.delegate = self
            tableButtonsNode.backgroundColor = .clear
            addSubnode(tableButtonsNode)
        }
        
        isLoadedFields = true
        for form in message.forms {
            if form.field == nil && form.type == .additionalField {
                isLoadedFields = false
            }
        }
        if message.forms.count > 0 {
            if isLoadedFields {
                if tableFormsNode.supernode == nil {
                    tableFormsNode.dataSource = self
                    tableFormsNode.delegate = self
                    tableFormsNode.backgroundColor = .clear
                    DispatchQueue.main.async {
                        self.tableFormsNode.view.separatorStyle = .none
                    }
                    addSubnode(tableFormsNode)
                    
                    sendFormButton.cornerRadius = messageFormStyle.sendFormButtonCornerRadius
                    sendFormButton.addTarget(self, action: #selector(sendFormAcction), forControlEvents: .touchUpInside)
                    addSubnode(sendFormButton)
                } else {
                    updateFormsNodes()
                }
                DispatchQueue.main.async {
                    if self.message.statusForms == .loading {
                        (self.loaderNode.view as? UIActivityIndicatorView)?.startAnimating()
                    } else {
                        (self.loaderNode.view as? UIActivityIndicatorView)?.stopAnimating()
                    }
                }
                loaderNode.alpha = message.statusForms == .loading ? 1 : 0

                setDefaultConfigSendFormButton()
                sendFormButton.alpha = message.statusForms == .loading ? 0 : 1
            } 
            if loaderNode.supernode == nil {
                self.loaderNode = ASDisplayNode { [weak self] () -> UIView in
                    guard let wSelf = self else {return UIView()}
                    wSelf.activityIndicator = UIActivityIndicatorView(style: messageFormStyle.sendFormActivityIndicatorStyle)
                    wSelf.activityIndicator?.hidesWhenStopped = false
                    wSelf.activityIndicator?.startAnimating()
                    return wSelf.activityIndicator ?? UIView()
                }
                addSubnode(loaderNode)
            }
        }
        super.bindData(messagesView: messagesView, message: message)
        DispatchQueue.main.async {
            self.tableButtonsNode.view.separatorStyle = .none
        }
    }
    
    private func setTextMessageNode() {
        let messageStyle = configurationStyle.messageStyle
        
        let linkColor = message.outgoing ? messageStyle.linkOutgoingColor : messageStyle.linkIncomingColor
        var attributedString = UDMarkdownParser.mutableAttributedString(for: message.text,
                                                                               font: messageStyle.font,
                                                                               color: message.outgoing ? messageStyle.textOutgoingColor : messageStyle.textIncomingColor)
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSMakeRange(0, attributedString.string.count)
        let mutableString = NSMutableAttributedString()
        mutableString.append(attributedString)
        detector?.enumerateMatches(in: attributedString.string, range: range) { (resultDetector, _, _) in
            if let result = resultDetector {
                mutableString.addAttribute(.underlineColor, value: linkColor, range: result.range)
                mutableString.addAttribute(.link, value: result.url, range: result.range)
                mutableString.addAttribute(.foregroundColor, value: linkColor, range: result.range)
            }
        }
        attributedString = mutableString
        
        textMessageNode.attributedText = attributedString
        textMessageNode.isUserInteractionEnabled = true
        textMessageNode.delegate = self
    }
    
    func setDefaultConfigSendFormButton() {
        let titleSendFormButton = message.statusForms == .sended ? messagesView?.usedesk?.model.stringFor("Sended") ?? "Sended" : messagesView?.usedesk?.model.stringFor("Send") ?? "Send"
        sendFormButton.setTitle(titleSendFormButton, with: messageFormStyle.sendFormButtonFont, with: messageFormStyle.sendFormButtonTitleColor, for: .normal)
        sendFormButton.setTitle(titleSendFormButton, with: messageFormStyle.sendFormButtonFont, with: messageFormStyle.sendFormButtonTitleTouchedColor, for: .highlighted)
        sendFormButton.backgroundColor = message.statusForms == .inputable ? messageFormStyle.sendFormButtonColor : messageFormStyle.sendFormButtonUnavailableColor
        sendFormButton.isUserInteractionEnabled = true
    }
    
    @objc func sendFormAcction() {
        guard message.statusForms == .inputable else {return}
        delegateText?.sendFormAction(message: message)
    }
    
    func tapForm(indexPath: IndexPath, form: UDFormMessage) {
        let rectForm = tableFormsNode.rectForRow(at: indexPath)
        let offsetY = tableFormsNode.frame.origin.y + rectForm.origin.y
        delegateForm?.tapForm(message: message, form: form, offsetY: offsetY)
    }
    
    func showErrorForm() {
        (loaderNode.view as? UIActivityIndicatorView)?.stopAnimating()
        loaderNode.alpha = 0
        sendFormButton.alpha = 1
        sendFormButton.isUserInteractionEnabled = false
        updateFormsNodes()
        UIView.transition(with: sendFormButton.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            let titleSendFormButton = self.messagesView?.usedesk?.model.stringFor("Error") ?? "Error"
            self.sendFormButton.setTitle(titleSendFormButton, with: self.messageFormStyle.sendFormButtonFont, with: self.messageFormStyle.sendFormButtonTitleColor, for: .normal)
            self.sendFormButton.backgroundColor = self.messageFormStyle.sendFormButtonErrorColor
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIView.transition(with: self.sendFormButton.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    self.setDefaultConfigSendFormButton()
                })
            }
        })
    }
    
    private func updateFormsNodes() {
        for index in 0..<message.forms.count {
            let indexPath = IndexPath(row: index, section: 0)
            let form = message.forms[index]
            switch form.type {
            case .additionalField:
                switch form.field?.type {
                case .text:
                    if let cell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormTextCellNode {
                        cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : messageFormStyle.spacing, index: indexPath.row, status: message.statusForms)
                    }
                case .checkbox:
                    if let cell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormCheckboxCellNode {
                        cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : messageFormStyle.spacing, index: indexPath.row, status: message.statusForms)
                    }
                case .list:
                    if let cell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormListCellNode {
                        cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : messageFormStyle.spacing, index: indexPath.row, status: isFormListEnableForSelect(form: form) ? message.statusForms : .loading)
                    }
                case .none:
                    if let cell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormTextCellNode {
                        cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : messageFormStyle.spacing, index: indexPath.row, status: message.statusForms)
                    }
                }
            default:
                if let cell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormTextCellNode {
                    cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : messageFormStyle.spacing, index: indexPath.row, status: message.statusForms)
                }
            }
        }
    }
    
    private func isFormListEnableForSelect(form: UDFormMessage) -> Bool {
        guard let idParentField = form.field?.idParentField else {return false}
        if idParentField > 0 {
            if let parentForm = message.forms.filter({$0.field?.id ?? 0 == idParentField}).first, parentForm.field?.selectedOption != nil {
                return true
            } else {
                return false
            }
        } else {
            return true
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
            wSelf.tableFormsNode.reloadData()
        })
        //Buttons
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
        //Forms
        if message.forms.count > 0 {
            if isLoadedFields {
                var height: CGFloat = 0 // height tableFormNode
                for index in 0..<message.forms.count {
                    height += heightNodeCellForm(for: IndexPath(row: index, section: 0))
                }
                height += messageFormStyle.spacing
                tableFormsNode.style.minHeight = ASDimensionMakeWithPoints(height)
                tableFormsNode.style.minWidth = ASDimensionMakeWithPoints(60000.0)
                let insetSpec = ASInsetLayoutSpec(insets: messageFormStyle.margin, child: tableFormsNode)
                vMessageStack.setChild(insetSpec, at: 2)
                
                sendFormButton.style.minHeight = ASDimensionMakeWithPoints(messageFormStyle.sendFormButtonHeight)
                sendFormButton.style.minWidth = ASDimensionMakeWithPoints(60000.0)
                
                loaderNode.alpha = message.statusForms == .loading ? 1 : 0
                let loaderAndIconOverlaySpec = ASOverlayLayoutSpec()
                let centerLoaderSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: loaderNode)
                loaderAndIconOverlaySpec.overlay = centerLoaderSpec
                loaderAndIconOverlaySpec.child = sendFormButton
    
                let sendFormButtonInsetSpec = ASInsetLayoutSpec(insets: messageFormStyle.sendFormButtonMargin, child: loaderAndIconOverlaySpec)
                vMessageStack.setChild(sendFormButtonInsetSpec, at: 3)
            } else {
                loaderNode.alpha = 1
                let loaderNodeСenterSpec = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: [], child: loaderNode)
                loaderNodeСenterSpec.style.minHeight = ASDimensionMakeWithPoints(30)
                let insetSpec = ASInsetLayoutSpec(insets: messageFormStyle.sendFormButtonMargin, child: loaderNodeСenterSpec)
                vMessageStack.setChild(insetSpec, at: 2)
            }
        }
        
        if (textMessageNode.attributedText?.string.isEmpty ?? true) && (message.buttons.count > 0 || message.forms.count > 0) {
            textMessageNode.style.maxHeight = ASDimensionMakeWithPoints(0)
        } else {
            textMessageNode.style.maxHeight = ASDimensionMakeWithPoints(constrainedSize.max.height)
        }
        
        let timeInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: messageStyle.timeMargin.bottom, right: message.outgoing ? 0 : messageStyle.timeMargin.right), child: timeNode)
        timeInsetSpec.style.flexShrink = 0
        timeInsetSpec.style.flexGrow = 0
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
    
    func heightNodeCellForm(for indexPath: IndexPath) -> CGFloat {
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        var height: CGFloat = 0
        let form = message.forms[indexPath.row]
        
        if form.field?.type == .checkbox {
            let widthTitle = sizeMessagesManager.maxWidthBubbleMessage - messageFormStyle.checkboxFormImageMargin.left - messageFormStyle.checkboxFormImageSize.width - messageFormStyle.checkboxFormImageMargin.right - messageFormStyle.checkboxFormTextMargin.right
            height = form.name.size(availableWidth: widthTitle, attributes: [.font : messageFormStyle.textFormTextFont]).height
            height += messageFormStyle.checkboxFormTextMargin.top + messageFormStyle.checkboxFormTextMargin.bottom
            if indexPath.row != 0 {
                height += messageFormStyle.spacing
            }
        } else {
            height = messageFormStyle.textFormHeight
            if indexPath.row != 0 {
                height += messageFormStyle.spacing
            }
        }
        return height
    }
}

extension UDTextMessageCellNode: ASTableDelegate, ASTableDataSource {
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if tableNode == tableButtonsNode {
            return message.buttons.count
        } else {
            return message.forms.count
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if tableNode == tableButtonsNode {
            let cell = UDMessageButtonCellNode()
            cell.configurationStyle = configurationStyle
            cell.setCell(titleButton: message.buttons[indexPath.row].title, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing)
            return cell
        } else {
            let form = message.forms[indexPath.row]
            switch form.type {
            case .additionalField:
                switch form.field?.type {
                case .text:
                    let cell = UDMessageFormTextCellNode()
                    cell.configurationStyle = configurationStyle
                    cell.delegateValue = self
                    cell.delegate = self
                    cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing, index: indexPath.row, status: message.statusForms)
                    return cell
                case .checkbox:
                    let cell = UDMessageFormCheckboxCellNode()
                    cell.configurationStyle = configurationStyle
                    cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing, index: indexPath.row, status: message.statusForms)
                    return cell
                case .list:
                    let cell = UDMessageFormListCellNode()
                    cell.configurationStyle = configurationStyle
                    cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing, index: indexPath.row, status: isFormListEnableForSelect(form: form) ? message.statusForms : .loading)
                    return cell
                case .none:
                    let cell = UDMessageFormTextCellNode()
                    cell.configurationStyle = configurationStyle
                    cell.delegateValue = self
                    cell.delegate = self
                    cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing, index: indexPath.row, status: message.statusForms)
                    return cell
                }
            default:
                let cell = UDMessageFormTextCellNode()
                cell.configurationStyle = configurationStyle
                cell.delegateValue = self
                cell.delegate = self
                cell.setCell(form: form, spacing: indexPath.row == 0 ? 0 : configurationStyle.messageButtonStyle.spacing, index: indexPath.row, status: message.statusForms)
                return cell
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if tableNode == tableButtonsNode {
            if message.buttons[indexPath.row].url != "" {
                let urlDataDict:[String: String] = ["url": message.buttons[indexPath.row].url]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("UseDeskMessageButtonURLOpen1!"), object: nil, userInfo: urlDataDict)
                }
            } else {
                let textDataDict:[String: String] = ["text": message.buttons[indexPath.row].title]
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("UseDeskMessageButtonSend1!"), object: nil, userInfo: textDataDict)
                }
            }
        } else {
            guard message.statusForms == .inputable else {return}
            let form = message.forms[indexPath.row]
            switch form.field?.type {
            case .checkbox:
                message.forms[indexPath.row].value = message.forms[indexPath.row].value == "1" ? "0" : "1"
                message.forms[indexPath.row].field?.value = message.forms[indexPath.row].value
                if let chekboxNodeCell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormCheckboxCellNode {
                    chekboxNodeCell.setCheckbox(isOn: message.forms[indexPath.row].value == "1")
                }
                delegateText?.newFormValue(value: message.forms[indexPath.row].value, message: message, indexForm: indexPath.row)
            case .list:
                if isFormListEnableForSelect(form: message.forms[indexPath.row]) {
                    tapForm(indexPath: indexPath, form: form)
                    delegateText?.formListAction(message: message, indexForm: indexPath.row, selectedOption: message.forms[indexPath.row].field?.selectedOption)
                }
            default:
                tapForm(indexPath: indexPath, form: form)
                if let textNodeCell = tableFormsNode.nodeForRow(at: indexPath) as? UDMessageFormTextCellNode {
                    textNodeCell.setEditableState()
                }
            }
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        if tableNode == tableButtonsNode {
            let heightButton = heightNodeCellButton(for: indexPath)
            let min = CGSize(width: UIScreen.main.bounds.size.width, height: heightButton)
            let max = CGSize(width: UIScreen.main.bounds.size.width, height: heightButton)
            return ASSizeRange(min: min, max: max)
        } else {
            let heightForm = heightNodeCellForm(for: indexPath)
            let min = CGSize(width: UIScreen.main.bounds.size.width, height: heightForm)
            let max = CGSize(width: UIScreen.main.bounds.size.width, height: heightForm)
            return ASSizeRange(min: min, max: max)
        }
    }
}
// MARK: - ASTextNodeDelegate
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
// MARK: - FormValueCellNodeDelegate
extension UDTextMessageCellNode: FormValueCellNodeDelegate {
    func newValue(value: String, indexForm: Int) {
        message.forms[indexForm].value = value
        delegateText?.newFormValue(value: value, message: message, indexForm: indexForm)
    }
}
// MARK: - FormCellNodeDelegate
extension UDTextMessageCellNode: FormCellNodeDelegate {
    func tapForm(indexForm: Int) {
        tapForm(indexPath: IndexPath(row: indexForm, section: 0), form: message.forms[indexForm])
    }
}
