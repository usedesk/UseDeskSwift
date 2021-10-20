//
//  UDFileManager.swift
//  UseDesk_SDK_Swift
//

import Foundation

@objc public enum UDFeedbackStatus: Int {
    case null
    case never
    case feedbackForm
    case feedbackFormAndChat
    
    var isNotOpenFeedbackForm: Bool {
        return self == .null || self == .never
    }
    
    var isOpenFeedbackForm: Bool {
        return self == .feedbackForm || self == .feedbackFormAndChat
    }
}
