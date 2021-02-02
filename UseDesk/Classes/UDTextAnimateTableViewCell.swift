//
//  UDTextAnimateTableViewCell.swift
//  UseDesk_SDK_Swift-UseDesk


import Foundation
import UIKit

protocol ChangeabelTextCellDelegate: class {
    func newValue(indexPath: IndexPath, value: String, isValid: Bool, positionCursorY: CGFloat)
    func tapingTextView(indexPath: IndexPath, position: CGFloat)
}

class UDTextAnimateTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var lineView: UDSeparatorView!
    @IBOutlet weak var lastLineView: UDSeparatorView!
    
    weak var delegate: ChangeabelTextCellDelegate?
    
    var configurationStyle = ConfigurationStyle()
    
    var indexPath = IndexPath()
    var defaultTitle = ""
    
    var isValid = false
    var isLast = false
    var isTitleErrorState = false
    var isLimitLengthText = true
    
    func setCell(title: String, text: String, indexPath indexPathCell: IndexPath, isValid isValidText: Bool = true, isTitleErrorState isTitleError: Bool = false, isLast isLastText: Bool = false, isNeedLastLine: Bool = false, isLimitLengthText isLimitLength: Bool = true, isOneLine: Bool = false, backgroundColor: UIColor? = nil) {
        indexPath = indexPathCell
        isValid = isValidText
        isLast = isLastText
        isTitleErrorState = isTitleError
        isLimitLengthText = isLimitLength
        titleLabel.text = title
        defaultTitle = title
        let feedbackFormStyle = configurationStyle.feedbackFormStyle
        titleLabel.textColor = feedbackFormStyle.headerColor
        titleLabel.font = feedbackFormStyle.headerFont
        myTextView.textContainerInset = UIEdgeInsets.zero
        myTextView.text = text
        myTextView.font = feedbackFormStyle.valueFont
        myTextView.isEditable = true
        myTextView.isSelectable = true
        myTextView.delegate = self
        myTextView.textColor = feedbackFormStyle.valueColor
        if isOneLine {
            myTextView.textContainer.maximumNumberOfLines = 1
        }
        if myTextView.text?.count ?? 0 > 0 {
            titleLabelTopC.constant = 10
        } else {
            titleLabelTopC.constant = 34
        }
        lastLineView.alpha = isNeedLastLine ? 1 : 0
        lineView.alpha = isLast && isValid ? 0 : 1
        lineView.backgroundColor = isValid ? feedbackFormStyle.lineSeparatorColor : feedbackFormStyle.errorColor
        if backgroundColor != nil {
            self.backgroundColor = backgroundColor!
        }
        self.selectionStyle = .none
    }
    
    func setSelectedAnimate(isNeedFocusedTextView: Bool = true) {
        myTextView.isEditable = true
        if isNeedFocusedTextView {
            DispatchQueue.main.async {
                self.myTextView.becomeFirstResponder()
            }
        }
        UIView.animate(withDuration: 0.3) {
            let feedbackFormStyle = self.configurationStyle.feedbackFormStyle
            self.lineView.alpha = 1
            self.lineView.backgroundColor = self.configurationStyle.feedbackFormStyle.lineSeparatorActiveColor
            self.titleLabel.textColor = self.isValid && !self.isTitleErrorState ? feedbackFormStyle.valueColor : feedbackFormStyle.errorColor
            self.titleLabelTopC.constant = 10
            self.layoutIfNeeded()
        }
    }
    
    func setNotSelectedAnimate() {
        UIView.animate(withDuration: 0.3) {
            let feedbackFormStyle = self.configurationStyle.feedbackFormStyle
            self.lineView.alpha = self.isLast ? 0 : 1
            self.lineView.backgroundColor = feedbackFormStyle.lineSeparatorColor
            self.titleLabel.textColor = self.isValid && !self.isTitleErrorState ? feedbackFormStyle.valueColor : feedbackFormStyle.errorColor
            if self.myTextView.text.count == 0 {
                self.titleLabelTopC.constant = 34
            } else {
                self.titleLabelTopC.constant = 10
            }
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - TextView
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        DispatchQueue.main.async {
            self.delegate?.tapingTextView(indexPath: self.indexPath, position: self.positionIn(textView: textView))
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil {
            delegate?.newValue(indexPath: indexPath, value: textView.text!, isValid: true, positionCursorY: positionIn(textView: textView))
        }
        if textView.text != defaultTitle {
            UIView.animate(withDuration: 0.3) {
                self.titleLabel.text = self.defaultTitle
            }
        }
        isValid = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        if titleLabel.text != defaultTitle {
            UIView.animate(withDuration: 0.3) {
                self.titleLabel.text = self.defaultTitle
            }
        }
        if isLimitLengthText {
            if textView.text.count > 255 {
                if text.count > 0 {
                    return false
                } else {
                    return true
                }
            }
            if (textView.text + text).count > 255 {
                let index = text.index(text.startIndex, offsetBy: 255 - textView.text.count)
                textView.text = textView.text + text[..<index]
                delegate?.newValue(indexPath: indexPath, value: textView.text!, isValid: true, positionCursorY: positionIn(textView: textView))
                return false
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func positionIn(textView: UITextView) -> CGFloat {
        let countCharacters = (textView.offset(from: textView.beginningOfDocument, to: textView.selectedTextRange?.start ?? UITextPosition()))
        let text: String = textView.text
        let endIndex = text.index(textView.text.startIndex, offsetBy: countCharacters)
        let stringBeforeCursor = String(text[text.startIndex..<endIndex])
        return stringBeforeCursor.size(availableWidth: textView.frame.width, attributes: [NSAttributedString.Key.font : configurationStyle.feedbackFormStyle.valueFont], usesFontLeading: true).height
    }
}

