//
//  UDTextView.swift
//  UseDesk_SDK_Swift
//

import Foundation
class UDTextView: UITextView {
    
    var isNeedCustomTextContainerInset = false
    var customTextContainerInset: UIEdgeInsets = .zero
    
    override func layoutSubviews() {
//        super.layoutSubviews()
        if isNeedCustomTextContainerInset {
            self.textContainerInset = customTextContainerInset
            self.textContainer.lineFragmentPadding = 0
            self.contentInset.top = customTextContainerInset.top
        }
    }
}
