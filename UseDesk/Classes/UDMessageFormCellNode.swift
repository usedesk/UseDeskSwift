//
//  UDMessageFormCellNode.swift
//  UseDesk_SDK_Swift

import Foundation
import AsyncDisplayKit

protocol FormCellNodeDelegate: AnyObject {
    func tapForm(indexForm: Int)
}

protocol FormDelegate: AnyObject {
    func tapForm(message: UDMessage, form: UDFormMessage, offsetY: CGFloat)
}

protocol FormValueCellNodeDelegate: AnyObject {
    func newValue(value: String, indexForm: Int)
}

class UDMessageFormCellNode: ASCellNode {
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var spacing: CGFloat = 0
    var form: UDFormMessage!
    var indexForm: Int = 0
    var status: StatusForm = .inputable
    var messageFormStyle: MessageFormStyle {
        get {
            return configurationStyle.messageFormStyle
        }
    }
    
    public func setCell(form: UDFormMessage, spacing: CGFloat = 0, index: Int, status: StatusForm) {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.form = form
        self.spacing = spacing
        self.isUserInteractionEnabled = status == .inputable
        indexForm = index
        self.status = status
    }
}
