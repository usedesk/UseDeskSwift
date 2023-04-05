//
//  UDTextAnimateTableViewCell.swift
//  UseDesk_SDK_Swift-UseDesk


import Foundation
import UIKit

protocol ChangeabelTextCellDelegate: AnyObject {
    func newValue(indexPath: IndexPath, value: String, isValid: Bool, positionCursorY: CGFloat)
    func tapingTextView(indexPath: IndexPath, position: CGFloat)
    func endWrite(indexPath: IndexPath)
}

class UDTextAnimateTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTCFromSelectImage: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var myTextViewTCFromSelectImage: NSLayoutConstraint!
    @IBOutlet weak var myTextViewTC: NSLayoutConstraint!
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var selectImageViewWC: NSLayoutConstraint!
    @IBOutlet weak var selectImageViewHC: NSLayoutConstraint!
    @IBOutlet weak var lineView: UDSeparatorView!
    @IBOutlet weak var lastLineView: UDSeparatorView!
    
    weak var delegate: ChangeabelTextCellDelegate?
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    var indexPath = IndexPath()
    var defaultTitle = ""
    var defaultAttributedTitle: NSAttributedString? = nil
    
    var isValid = false
    var isLast = false
    var isTitleErrorState = false
    var isLimitLengthText = true
    var title = ""
    var titleAttributed: NSAttributedString? = nil
    var textAttributed: NSAttributedString? = nil
    
    func setCell(title _title: String, titleAttributed _titleAttributed: NSAttributedString? = nil, text: String, textAttributed _textAttributed: NSAttributedString? = nil, indexPath indexPathCell: IndexPath, isValid isValidText: Bool = true, isTitleErrorState isTitleError: Bool = false, isLast isLastText: Bool = false, isNeedLastLine: Bool = false, isNeedSelectImage: Bool = false, isUserInteractionEnabled: Bool = true, isLimitLengthText isLimitLength: Bool = true, isOneLine: Bool = false) {
        indexPath = indexPathCell
        isValid = isValidText
        isLast = isLastText
        isTitleErrorState = isTitleError
        isLimitLengthText = isLimitLength
        title = _title
        titleAttributed = _titleAttributed
        textAttributed = _textAttributed
        let feedbackFormStyle = configurationStyle.feedbackFormStyle
        titleLabel.textColor = feedbackFormStyle.headerColor
        titleLabel.font = feedbackFormStyle.headerFont
        titleLabel.isUserInteractionEnabled = isUserInteractionEnabled
        if titleAttributed != nil {
            titleLabel.attributedText = titleAttributed
            defaultAttributedTitle = titleAttributed!
            defaultTitle = ""
        } else {
            titleLabel.text = title
            defaultTitle = title
            defaultAttributedTitle = nil
        }
        if !isValid {
            titleLabel.textColor = feedbackFormStyle.errorColor
        }
        titleLabelTC.isActive = isNeedSelectImage ? false : true
        titleLabelTCFromSelectImage.isActive = isNeedSelectImage ? true : false
        
        myTextView.textContainerInset = UIEdgeInsets.zero
        myTextView.textColor = feedbackFormStyle.valueColor 
        myTextView.text = text
        myTextView.font = feedbackFormStyle.valueFont
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = isUserInteractionEnabled
        myTextView.isSelectable = true
        myTextView.delegate = self
        myTextViewTC.isActive = isNeedSelectImage ? false : true
        myTextViewTCFromSelectImage.isActive = isNeedSelectImage ? true : false
        if isOneLine {
            myTextView.textContainer.maximumNumberOfLines = 1
        }
        if textAttributed != nil {
            myTextView.text = ""
            myTextView.attributedText = textAttributed
        }
        
        if myTextView.text.count == 0 {
            if textAttributed != nil {
                titleLabelTopC.constant = textAttributed!.string.count > 0 ? 10 : 34
            } else {
                titleLabelTopC.constant = 34
            }
        } else {
            titleLabelTopC.constant = 10
        }
        
        selectImageView.image = configurationStyle.feedbackFormStyle.arrowImage
        selectImageView.alpha = isNeedSelectImage ? 1 : 0
        selectImageViewWC.constant = configurationStyle.feedbackFormStyle.arrowImageSize.width
        selectImageViewHC.constant = configurationStyle.feedbackFormStyle.arrowImageSize.height
        
        lastLineView.alpha = isNeedLastLine ? 1 : 0
        lineView.alpha = isLast && isValid ? 0 : 1
        lineView.backgroundColor = isValid ? feedbackFormStyle.lineSeparatorColor : feedbackFormStyle.lineSeparatorActiveColor
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.layoutIfNeeded()
    }
    
    func setSelectedAnimate(isNeedFocusedTextView: Bool = true) {
        if isNeedFocusedTextView {
            DispatchQueue.main.async {
                self.myTextView.becomeFirstResponder()
            }
        }
        UIView.animate(withDuration: 0.3) {
            let feedbackFormStyle = self.configurationStyle.feedbackFormStyle
            self.lineView.alpha = 1
            self.lineView.backgroundColor = self.configurationStyle.feedbackFormStyle.lineSeparatorActiveColor            
            if self.titleAttributed != nil {
                if self.myTextView.attributedText == self.titleAttributed {
                    self.titleLabel.attributedText = self.titleAttributed
                    self.myTextView.text = ""
                    self.myTextView.textColor = feedbackFormStyle.valueColor
                }
            } else if self.myTextView.text == self.title || self.myTextView.attributedText == self.textAttributed {
                    self.titleLabel.text = self.title
                    self.myTextView.text = ""
                    self.myTextView.textColor = feedbackFormStyle.valueColor
            }
            self.titleLabel.textColor = self.isValid && !self.isTitleErrorState ? feedbackFormStyle.headerSelectedColor : feedbackFormStyle.errorColor
            self.titleLabelTopC.constant = 10
            self.layoutIfNeeded()
        }
    }
    
    func setNotSelectedAnimate() {
        UIView.animate(withDuration: 0.3) {
            let feedbackFormStyle = self.configurationStyle.feedbackFormStyle
            self.lineView.alpha = self.isLast ? 0 : 1
            self.lineView.backgroundColor = self.isValid ? feedbackFormStyle.lineSeparatorColor : feedbackFormStyle.lineSeparatorActiveColor
            self.titleLabel.textColor = self.isValid && !self.isTitleErrorState ? feedbackFormStyle.headerColor : feedbackFormStyle.errorColor
            if self.defaultAttributedTitle != nil {
                self.titleLabel.attributedText = self.defaultAttributedTitle
            }
            
            if self.myTextView.text.count == 0 {
                if self.textAttributed != nil {
                    self.titleLabelTopC.constant = self.textAttributed!.string.count > 0 && !self.isValid ? 10 : 34
                } else {
                    self.titleLabelTopC.constant = 34
                }
            } else {
                self.titleLabelTopC.constant = 10
            }
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - TextView
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.delegate?.tapingTextView(indexPath: self.indexPath, position: self.positionIn(textView: textView))
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != nil {
            delegate?.newValue(indexPath: indexPath, value: textView.text!, isValid: true, positionCursorY: positionIn(textView: textView))
        }
        if textView.text != defaultTitle {
            UIView.animate(withDuration: 0.3) {
                if self.defaultAttributedTitle != nil {
                    self.titleLabel.attributedText = self.defaultAttributedTitle
                } else {
                    self.titleLabel.text = self.defaultTitle
                }
                self.titleLabel.textColor = self.configurationStyle.feedbackFormStyle.headerSelectedColor
            }
        }
        isValid = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            DispatchQueue.main.async {
                self.delegate?.endWrite(indexPath: self.indexPath)
            }
            textView.resignFirstResponder()
            return false
        }
        if titleLabel.text != defaultTitle {
            if self.defaultAttributedTitle != nil {
                self.titleLabel.attributedText = self.defaultAttributedTitle
            } else {
                self.titleLabel.text = self.defaultTitle
            }
            self.titleLabel.textColor = self.configurationStyle.feedbackFormStyle.headerSelectedColor
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
        var countCharacters = (textView.offset(from: textView.beginningOfDocument, to: textView.selectedTextRange?.start ?? UITextPosition()))
        let text: String = textView.text
        if countCharacters > text.count {
            countCharacters = text.count
        }
        let endIndex = text.index(textView.text.startIndex, offsetBy: countCharacters)
        let stringBeforeCursor = String(text[text.startIndex..<endIndex])
        return stringBeforeCursor.size(availableWidth: textView.frame.width, attributes: [NSAttributedString.Key.font : configurationStyle.feedbackFormStyle.valueFont], usesFontLeading: true).height
    }
}

