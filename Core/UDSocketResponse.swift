//
//  UDSocketResponse.swift
//  UseDesk_SDK_Swift
//
//
import Foundation
import MarkdownKit
import SwiftSoup

class UDSocketResponse {
    
    // MARK: - Public Methods
    public class func actionItited(_ data: [Any]?, model: UseDeskModel, historyMessagesBlock: @escaping ([UDMessage]) -> Void, serverTokenBlock: @escaping (String) -> Void, setClientBlock: @escaping () -> Void) {
        let dicServer = data?[0] as? [AnyHashable : Any]
        
        var serverToken = ""
        let setup = dicServer?["setup"] as? [AnyHashable : Any]
        
        if dicServer?["token"] != nil {
            serverToken = dicServer?["token"] as? String ?? ""
            serverTokenBlock(serverToken)
        }
        
        if setup != nil {
            let historyMessages = getHistoryMessages(data: setup!, model: model)
            historyMessagesBlock(historyMessages)
            setClientBlock()
        }
    }
    
    public class func isNoOperators(_ data: [Any]?) -> Bool {
        let dicServer = data?[0] as? [AnyHashable : Any]

        let setup = dicServer?["setup"] as? [AnyHashable : Any]
        if setup != nil {
            let noOperators = setup?["noOperators"]
            if let noOperatorsBool = noOperators as? Bool {
                if noOperatorsBool == true {
                    return true
                }
            } else if let noOperatorsInt = noOperators as? Int {
                if noOperatorsInt == 1 {
                    return true
                }
            }
            let message = dicServer?["message"] as? [AnyHashable : Any]
            if message != nil {
                let payload = message?["payload"] as? [AnyHashable : Any]
                if payload != nil {
                    let noOperators = payload?["noOperators"]
                    if noOperators != nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    public class func actionItitedCallbackSettings(_ data: [Any]?, callbackSettingsBlock: @escaping (UDCallbackSettings) -> Void) -> UDCallbackSettings {
        let callbackSettings = UDCallbackSettings()
        let dicServer = data?[0] as? [AnyHashable : Any]
        let setup = dicServer?["setup"] as? [AnyHashable : Any]
        if setup != nil {
            if let callback_settings = setup!["callback_settings"] as? [AnyHashable : Any] {
                if let work_type = callback_settings["work_type"] as? String {
                    callbackSettings.typeString = work_type
                    if callbackSettings.type == .always_and_chat {
                        if let ticket = setup!["ticket"] as? [AnyHashable : Any] {
                            if let statusNumber = ticket["status_id"] as? Int {
                                if statusNumber == 1 || statusNumber == 5 || statusNumber == 6 || statusNumber == 8 {
                                    callbackSettings.typeString = "NEVER"
                                }
                            }
                        }
                    }
                }
                if let callback_title = callback_settings["callback_title"] as? String {
                    callbackSettings.title = callback_title
                }
                if let callback_greeting = callback_settings["callback_greeting"] as? String {
                    callbackSettings.greeting = callback_greeting
                }
                if let topics_title = callback_settings["topics_title"] as? String {
                    callbackSettings.titleTopics = topics_title
                }
                if let topics = callback_settings["topics"] as? [Any] {
                    for topicItem in topics {
                        if let topic = topicItem as? [String : Any] {
                            let callbackTopic = UDCallbackTopic()
                            if let text = topic["text"] as? String {
                                callbackTopic.text = text
                            }
                            if let checked = topic["checked"] as? Int {
                                if checked == 1 {
                                    callbackTopic.isChecked = true
                                }
                            }
                            callbackSettings.topics.append(callbackTopic)
                        }
                    }
                }
                if let topics_required = callback_settings["topics_required"] as? Int {
                    callbackSettings.isRequiredTopic = topics_required == 1 ? true : false
                }
                if let custom_fields = callback_settings["custom_fields"] as? [Any] {
                    for (index, custom_fieldItem) in custom_fields.enumerated() {
                        if let custom_field = custom_fieldItem as? [String : Any] {
                            let сallbackCustomField = UDCallbackCustomField()
                            сallbackCustomField.key = "custom_field_\(index)"
                            if let placeholder = custom_field["placeholder"] as? String {
                                сallbackCustomField.title = placeholder
                            }
                            if let placeholder = custom_field["required"] as? Int {
                                if placeholder == 1 {
                                    сallbackCustomField.isRequired = true
                                }
                            }
                            if let checked = custom_field["checked"] as? Int {
                                if checked == 1 {
                                    сallbackCustomField.isChecked = true
                                }
                            }
                            callbackSettings.customFields.append(сallbackCustomField)
                        }
                    }
                }
                callbackSettingsBlock(callbackSettings)
            }
        }
        return callbackSettings
    }
    
    public class func isAddInit(_ data: [Any]?) -> Bool {
        
        let dicServer = data?[0] as? [AnyHashable : Any]
        
        let type = dicServer?["type"] as? String
        if type == nil {
            return false
        }
        if (type == "@@chat/current/INITED") {
            return true
        }
        return false
    }
    
    public class func actionFeedbackAnswer(_ data: [Any]?, feedbackAnswerMessageBlock: UDFeedbackAnswerMessageBlock?) {
        let dicServer = data?[0] as? [AnyHashable : Any]
        
        let type = dicServer?["type"] as? String
        if type == nil {
            return
        }
        if !(type == "@@chat/current/CALLBACK_ANSWER") {
            return
        }
        
        let answer = dicServer?["answer"] as? [AnyHashable : Any]
        if (feedbackAnswerMessageBlock != nil) {
            feedbackAnswerMessageBlock!(answer?["status"] as! Bool)
        }
    }
    
    public class func actionAddMessage(_ data: [Any]?, newMessageBlock: UDMessageBlock?, feedbackMessageBlock: UDFeedbackMessageBlock?, sendAdditionalFieldsBlock: () -> Void, isSendedAdditionalField: Bool,  model: UseDeskModel) {
        let dicServer = data?[0] as? [AnyHashable : Any]
        let type = dicServer?["type"] as? String
        if type == nil {
            return
        }
        
        let message = dicServer?["message"] as? [AnyHashable : Any]
        
        if message != nil {
            if (message?["chat"] is NSNull) {
                return
            }
            var m: UDMessage? = nil
            var messageFile: UDMessage? = nil
            var messagesImageLink: [UDMessage] = []
            var textWithoutLinkImage: String? = nil
            var linksImage: [String] = []
            if var text = message!["text"] as? String {
                (linksImage, textWithoutLinkImage) = parseText(text)
                for index in 0..<linksImage.count {
                    text = text.replacingOccurrences(of: linksImage[index], with: "")
                    if let messageImageLink = UDSocketResponse.parseFileMessageDic(message, withImageUrl: linksImage[index], numberImageUrl: index) {
                        messagesImageLink.append(messageImageLink)
                    }
                }
            }
            if (message!["file"] as? [AnyHashable : Any] ) != nil {
                messageFile = parseFileMessageDic(message)
            }
            m = parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, model: model)
            
            var isAddMessage = false
            if m != nil {
                if m?.type == UD_TYPE_Feedback && (feedbackMessageBlock != nil) {
                    feedbackMessageBlock!(m)
                    isAddMessage = true
                    return
                } else {
                    if newMessageBlock != nil && m!.text != "​" {
                        newMessageBlock?(m)
                        isAddMessage = true
                    }
                }
            }
            if messageFile != nil {
                newMessageBlock!(messageFile!)
                isAddMessage = true
            }
            for m in messagesImageLink {
                newMessageBlock!(m)
                isAddMessage = true
            }
            if isAddMessage && model.token.count > 0 && !isSendedAdditionalField {
                sendAdditionalFieldsBlock()
            }
        }
    }
    
    public class func getHistoryMessages(data: [AnyHashable : Any], model: UseDeskModel) -> [UDMessage] {
        guard let messages = data["messages"] as? [Any] else {return []}
        return parseMessages(messages, model: model)
    }
    
    public class func parseMessages(_ messagesJson: [Any], model: UseDeskModel) -> [UDMessage] {
        var messages: [UDMessage] = []
        for mess in messagesJson {
            var m: UDMessage? = nil
            var messageFile: UDMessage? = nil
            var messagesImageLink: [UDMessage] = []
            if let message = mess as? [AnyHashable : Any] {
                var textWithoutLinkImage: String? = nil
                var linksImage: [String] = []
                if var text = message["text"] as? String {
                    (linksImage, textWithoutLinkImage) = parseText(text)
                    for index in 0..<linksImage.count {
                        text = text.replacingOccurrences(of: linksImage[index], with: "")
                        if let messageImageLink = UDSocketResponse.parseFileMessageDic(message, withImageUrl: linksImage[index], numberImageUrl: index) {
                            messagesImageLink.append(messageImageLink)
                        }
                    }
                }
                if (message["file"] as? [AnyHashable : Any] ) != nil {
                    messageFile = UDSocketResponse.parseFileMessageDic(message)
                }
                m = UDSocketResponse.parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, model: model)
            }
            if m != nil && m!.text != "​" {
                messages.append(m!)
            }
            for m in messagesImageLink {
                messages.append(m)
            }
            if messageFile != nil {
                messages.append(messageFile!)
            }
        }
        return messages
    }
    
    // MARK: - Private Methods
    private class func parseFileMessageDic(_ mess: [AnyHashable : Any]?, withImageUrl imageUrl: String? = nil, numberImageUrl: Int? = nil) -> UDMessage? {
        let m = UDMessage(text: "", incoming: false)
        m.statusSend = UD_STATUS_SEND_SUCCEED
        let createdAt = mess?["createdAt"] as? String ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if dateFormatter.date(from: createdAt) == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        if createdAt != "" {
            if dateFormatter.date(from: createdAt) != nil {
                m.date = dateFormatter.date(from: createdAt)!
            } else {
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                if dateFormatter.date(from: createdAt) != nil {
                    m.date = dateFormatter.date(from: createdAt)!
                }
            }
        }
        if let type = mess?["type"] as? String {
            m.typeSenderMessageString = type
        }
        m.incoming = (m.typeSenderMessage == .operator_to_client || m.typeSenderMessage == .bot_to_client) ? true : false
        m.name = mess?["name"] as? String ?? ""
        if m.typeSenderMessage == .operator_to_client {
            if let operatorId = mess?["type"] as? Int {
                m.operatorId = operatorId
            }
        }
        if let payload = mess?["payload"] as? [AnyHashable : Any] {
            if let avatar = payload["avatar"] as? String {
                m.avatar = avatar
            }
            if payload["message_id"] != nil {
                m.loadingMessageId = payload["message_id"] as? String ?? ""
            }
        }
        m.id = mess?["id"] as? Int ?? 0
        let fileDic = mess?["file"] as? [AnyHashable : Any]
        if let url = imageUrl, let numberImage = numberImageUrl {
            let imageUrlLowercased = imageUrl!.lowercased()
            if imageUrlLowercased.contains(".png") || imageUrlLowercased.contains(".gif") || imageUrlLowercased.contains(".jpg") || imageUrlLowercased.contains(".jpeg") || imageUrlLowercased.contains(".heic") || imageUrlLowercased.contains(".webp") {
                m.type = UD_TYPE_PICTURE
                let file = UDFile()
                file.urlFile = url
                file.id = m.id + numberImage
                m.file = file
            } else {
                return nil
            }
        } else if fileDic != nil {
            let file = UDFile()
            file.urlFile = fileDic?["content"] as! String
            file.name = fileDic?["name"] as! String
            let typeFileString = fileDic?["type"] as! String
            file.typeString = typeFileString
            switch typeFileString {
            case "image":
                file.type = .image
            case "video":
                file.type = .video
            default:
                file.type = .file
            }
            file.size = fileDic?["size"] as? String ?? ""
            file.id = fileDic?["fileId"] as? Int ?? 0
            m.file = file
            m.status = UD_STATUS_LOADING
            var type = ""
            if (fileDic?["file_name"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["file_name"] as? String ?? "")?.pathExtension ?? ""
            }
            if (fileDic?["fullLink"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["fullLink"] as? String ?? "")?.pathExtension ?? ""
            }
            if typeFileString.contains("image") || isImage(of: type) || isImage(of: typeFileString) {
                m.type = UD_TYPE_PICTURE
            } else if typeFileString.contains("video") || isVideo(of: type) || isVideo(of: typeFileString) {
                m.type = UD_TYPE_VIDEO
                m.file.typeExtension = type
                file.type = .video
            } else {
                m.type = UD_TYPE_File
            }
        } else {
            return nil
        }
        return m
    }
        
    class func parseMessageDic(_ mess: [AnyHashable : Any]?, textWithoutLinkImage: String? = nil, model: UseDeskModel) -> UDMessage? {
        let m = UDMessage(text: "", incoming: false)
        m.statusSend = UD_STATUS_SEND_SUCCEED
        let createdAt = mess?["createdAt"] as? String ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if dateFormatter.date(from: createdAt) == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        }
        if createdAt != "" {
            if let date = dateFormatter.date(from: createdAt) {
                m.date = date
            } else {
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = dateFormatter.date(from: createdAt) {
                    m.date = date
                }
            }
        }
        if mess?["id"] != nil {
            m.id = mess?["id"] as? Int ?? 0
        }
        if let type = mess?["type"] as? String {
            m.typeSenderMessageString = type
        }
        m.incoming = (m.typeSenderMessage == .operator_to_client || m.typeSenderMessage == .bot_to_client) ? true : false
        if m.typeSenderMessage == .operator_to_client {
            if let operatorId = mess?["type"] as? Int {
                m.operatorId = operatorId
            }
        }
        m.text = textWithoutLinkImage != nil ? textWithoutLinkImage! : mess?["text"] as? String ?? ""
        if m.incoming {
            //Buttons
            let stringsFromButtons = parseMessageFromButtons(text: m.text)
            for stringFromButton in stringsFromButtons {
                let button = buttonFromString(stringButton: stringFromButton)
                var textButton = ""
                if button != nil {
                    m.buttons.append(button!)
                    if button!.visible {
                        textButton = m.text.count > 0 ? " " : ""
                        textButton += button!.title
                    }
                }
                m.text = m.text.replacingOccurrences(of: stringFromButton, with: textButton)
            }
            //Forms
            let (textWithForms, forms) = UDFormMessageManager.parseForms(from: m.text)
            if forms.count > 0 {
                m.text = textWithForms.udRemoveFirstAndLastLineBreaksAndSpaces()
                m.forms = forms
            }
            //Name
            m.name = mess?["name"] as? String ?? ""
        }
        m.text = m.text.udRemoveMultipleLineBreaks()
        m.text = m.text.udRemoveFirstSymbol(with: "\n")
        m.text = m.text.udRemoveLastSymbol(with: "\n")
        if m.text == "" && m.buttons.count == 0 && m.forms.count == 0 {
            return nil
        }
        
        if m.buttons.count != 0 || m.forms.count != 0 {
            m.text += "\n"
        }
        
        if let payload = mess?["payload"] as? [AnyHashable : Any] {
            if let avatar = payload["avatar"] as? String {
                m.avatar = avatar
            }
            if payload["csi"] != nil {
                m.type = UD_TYPE_Feedback
            }
            if let userRating = payload["userRating"] as? String {
                m.type = UD_TYPE_Feedback
                if userRating == "LIKE" {
                    m.feedbackActionInt = 1
                    m.text = model.stringFor("CSIReviewLike")
                }
                if userRating == "DISLIKE" {
                    m.feedbackActionInt = 0
                    m.text = model.stringFor("CSIReviewDislike")
                }
            }
            if payload["message_id"] != nil {
                m.loadingMessageId = payload["message_id"] as? String ?? ""
            }
        }
        return m
    }
        
    private class func parseMessageFromButtons(text: String) -> [String] {
        var isAddingButton: Bool = false
        var characterArrayFromButton = [Character]()
        var stringsFromButton = [String]()
        if text.count > 2 {
            for index in 0..<text.count - 1 {
                let indexString = text.index(text.startIndex, offsetBy: index)
                let secondIndexString = text.index(text.startIndex, offsetBy: index + 1)
                if isAddingButton {
                    characterArrayFromButton.append(text[indexString])
                    if (text[indexString] == "}") && (text[secondIndexString] == "}") {
                        characterArrayFromButton.append(text[secondIndexString])
                        isAddingButton = false
                        let stringFromButton = String(characterArrayFromButton)
                        if !UDFormMessageManager.isForm(string: stringFromButton) {
                            stringsFromButton.append(stringFromButton)
                        }
                        characterArrayFromButton = []
                    }
                } else {
                    if (text[indexString] == "{") && (text[secondIndexString] == "{") {
                        characterArrayFromButton.append(text[indexString])
                        isAddingButton = true
                    }
                }
            }
        }
        return stringsFromButton
    }
    
    private class func parseText(_ textPars: String) -> ([String], String?) {
        var text = textPars
        text.udConverDoubleLinks()
        text = text.udRemoveFirstSymbol(with: "\u{200b}")
        text = text.udRemoveLastSymbol(with: "\u{200b}")
        text = text.udRemoveFirstSymbol(with: "\n")
        text = text.udRemoveMultipleLineBreaks()
        text = text.udRemoveLastSymbol(with: "\n")
        text.udConvertUrls()
        if text.udIsHtml() {
            do {
                let doc: Document = try SwiftSoup.parse(text)
                text = try doc.text()
            } catch {}
        }
        let textBeforeRemoveMarkdownUrls = text
        var textWithoutLinkImage: String? = nil
        let linksImage = text.udRemoveMarkdownUrlsAndReturnLinks()
        textWithoutLinkImage = text
        if linksImage.count == 0 {
            textWithoutLinkImage = textBeforeRemoveMarkdownUrls
        }
        return (linksImage, textWithoutLinkImage)
    }
    
    private class func buttonFromString(stringButton: String) -> UDMessageButton? {
        var stringsParameters = [String]()
        var charactersFromParameter = [Character]()
        var index = 9
        var isNameExists = true
        while (index < stringButton.count - 2) && isNameExists {
            let indexString = stringButton.index(stringButton.startIndex, offsetBy: index)
            if stringButton[indexString] == ";" || index == stringButton.count - 3 {
                // если первый параметр(имя) будет равно "" то не создавать кнопку
                if (stringsParameters.count == 0) && (charactersFromParameter.count == 0) {
                    isNameExists = false
                } else {
                    // если последний символ перед ковычками добавляем его в символы параметра
                    if index == stringButton.count - 3 {
                        charactersFromParameter.append(stringButton[indexString])
                    }
                    stringsParameters.append(String(charactersFromParameter))
                    charactersFromParameter = []
                    index += 1
                }
            } else {
                charactersFromParameter.append(stringButton[indexString])
                index += 1
            }
        }

        if isNameExists && (stringsParameters.count > 0) {
            stringsParameters.append(String(charactersFromParameter))
            let button = UDMessageButton()
            button.title = stringsParameters[0]
            if stringsParameters.count > 1 {
                button.url = stringsParameters[1]
            }
            if stringsParameters.count > 3 && stringsParameters[3] == "noshow" {
                button.visible = false
            }
            return button
        } else {
            return nil
        }
    }
    
    private class func isImage(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["gif", "xbm", "jpeg", "jpg", "pct", "bmpf", "ico", "tif", "tiff", "cur", "bmp", "png", "heic", "heif"]
        return typesImage.contains(typeLowercased)
    }
    
    private class func isVideo(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["mpeg", "mp4", "webm", "quicktime", "ogg", "mov", "mpe", "mpg", "mvc", "flv", "avi", "3g2", "3gp2", "vfw", "mpg", "mpeg"]
        return typesImage.contains(typeLowercased)
    }
}
