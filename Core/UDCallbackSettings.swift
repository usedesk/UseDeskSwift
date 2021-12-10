//
//  UDCallbackSettings.swift
//  UseDesk_SDK_Swift


import Foundation

public class UDCallbackSettings: NSObject {
    @objc public var typeString = "NEVER"
    @objc public var title = ""
    @objc public var greeting = ""
    @objc public var isRequiredTopic = false
    @objc public var titleTopics = ""
    @objc public var customFields: [UDCallbackCustomField] = []
    @objc public var topics: [UDCallbackTopic] = []
    
    var type: UDCallbackType {
        switch self.typeString {
        case "NEVER":
            return UDCallbackType.never
        case "CHECK_WORKING_TIMES":
            return UDCallbackType.check_working_times
        case "ALWAYS_ENABLED_CALLBACK_WITHOUT_CHAT":
            return UDCallbackType.always
        case "ALWAYS_ENABLED_CALLBACK_WITH_CHAT":
            return UDCallbackType.always_and_chat
        default:
            return UDCallbackType.never
        }
    }
    
    @objc public var checkedTopics: [UDCallbackTopic] {
        var callbackTopics: [UDCallbackTopic] = []
        for topic in topics {
            if topic.isChecked {
                callbackTopics.append(topic)
            }
        }
        return callbackTopics
    }
    
    @objc public var checkedCustomFields: [UDCallbackCustomField] {
        var callbackCustomFields: [UDCallbackCustomField] = []
        for customField in customFields {
            if customField.isChecked {
                callbackCustomFields.append(customField)
            }
        }
        return callbackCustomFields
    }
}

public class UDCallbackTopic: NSObject {
    @objc public var text = ""
    @objc public var isChecked = false
}

public class UDCallbackCustomField: NSObject {
    @objc public var key = ""
    @objc public var title = ""
    @objc public var text = ""
    @objc public var isRequired = false
    @objc public var isChecked = false
    @objc public var isValid = true
    
    init(title: String = "", text: String = "", isRequired: Bool = false, isChecked: Bool = false) {
        self.title = title
        self.text = text
        self.isRequired = isRequired
        self.isChecked = isChecked
    }
}

public enum UDCallbackType {
    case never
    case check_working_times
    case always
    case always_and_chat
}
