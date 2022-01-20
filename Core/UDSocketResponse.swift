//
//  UDSocketResponse.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import Down

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
    
    public class func actionFeedbackAnswer(_ data: [Any]?, feedbackAnswerMessageBlock: UDSFeedbackAnswerMessageBlock?) {
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
    
    public class func actionAddMessage(_ data: [Any]?, newMessageBlock: UDSNewMessageBlock?, feedbackMessageBlock: UDSFeedbackMessageBlock?, sendAdditionalFieldsBlock: () -> Void, isSendedAdditionalField: Bool,  model: UseDeskModel) {
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
            
            var mutableAttributedString: NSMutableAttributedString? = nil
            var textWithoutLinkImage: String? = nil
            if var text = message!["text"] as? String {
                let linksImage = text.udRemoveMarkdownUrlsAndReturnLinks()
                for link in linksImage {
                    text = text.replacingOccurrences(of: link, with: "")
                    if let messageImageLink = parseFileMessageDic(message, withImageUrl: link) {
                        messagesImageLink.append(messageImageLink)
                    }
                }
                textWithoutLinkImage = text
                if text.count > 0 {
                    text = text.replacingOccurrences(of: "\n", with: "<№;%br>")
                    let down = Down(markdownString: text)
                    if let attributedString = try? down.toAttributedString() {
                        mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                        mutableAttributedString!.mutableString.replaceCharacters(in: NSRange(location: mutableAttributedString!.length - 1, length: 1), with: "")
                        mutableAttributedString!.mutableString.replaceOccurrences(of: "<№;%br>", with: "\n", options: .caseInsensitive, range: NSRange(location: 0, length: mutableAttributedString!.length))
                    }
                }
            }
            if (message!["file"] as? [AnyHashable : Any] ) != nil {
                messageFile = parseFileMessageDic(message)
            }
            m = parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, attributedString: mutableAttributedString, model: model)
            
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
        var historyMess: [UDMessage] = []
        let messages = data["messages"] as? [Any]
        historyMess = [UDMessage]()
        if messages != nil {
            for mess in messages!  {
                var m: UDMessage? = nil
                var messageFile: UDMessage? = nil
                var messagesImageLink: [UDMessage] = []
                if let message = mess as? [AnyHashable : Any] {
                    var mutableAttributedString: NSMutableAttributedString? = nil
                    var textWithoutLinkImage: String? = nil
                    if var text = message["text"] as? String {
                        let linksImage = text.udRemoveMarkdownUrlsAndReturnLinks()
                        for link in linksImage {
                            text = text.replacingOccurrences(of: link, with: "")
                            if let messageImageLink = parseFileMessageDic(message, withImageUrl: link) {
                                messagesImageLink.append(messageImageLink)
                            }
                        }
                        textWithoutLinkImage = text
                        if text.count > 0 {
                            text = text.replacingOccurrences(of: "\n", with: "<№;%br>")
                            let down = Down(markdownString: text)
                            if let attributedString = try? down.toAttributedString() {
                                mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                                mutableAttributedString!.mutableString.replaceCharacters(in: NSRange(location: mutableAttributedString!.length - 1, length: 1), with: "")
                                mutableAttributedString!.mutableString.replaceOccurrences(of: "<№;%br>", with: "\n", options: .caseInsensitive, range: NSRange(location: 0, length: mutableAttributedString!.length))
                            }
                        }
                    }
                    if (message["file"] as? [AnyHashable : Any] ) != nil {
                        messageFile = parseFileMessageDic(message)
                    }
                    m = parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, attributedString: mutableAttributedString, model: model)
                }
                if m != nil && m!.text != "​" {
                    historyMess.append(m!)
                }
                for m in messagesImageLink {
                    historyMess.append(m)
                }
                if messageFile != nil {
                    historyMess.append(messageFile!)
                }
            }
        }
        return historyMess
    }
    // MARK: - Private Methods
    private class func parseFileMessageDic(_ mess: [AnyHashable : Any]?, withImageUrl imageUrl: String? = nil) -> UDMessage? {
        let m = UDMessage(text: "", incoming: false)
        
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
        if m.typeSenderMessage == .operator_to_client {
            if let operatorId = mess?["type"] as? Int {
                m.operatorId = operatorId
            }
        }
        if let payload = mess?["payload"] as? [AnyHashable : Any] {
            let avatar = payload["avatar"]
            if avatar != nil {
                m.avatar = payload["avatar"] as! String
            }
            if payload["message_id"] != nil {
                m.loadingMessageId = payload["message_id"] as? String ?? ""
            }
        }
        let fileDic = mess?["file"] as? [AnyHashable : Any]
        if imageUrl != nil {
            if imageUrl!.contains(".png") || imageUrl!.contains(".gif") || imageUrl!.contains(".jpg") || imageUrl!.contains(".jpeg") {
                m.type = UD_TYPE_PICTURE
                let file = UDFile()
                file.content = imageUrl!
                m.file = file
            } else {
                return nil
            }
        } else if fileDic != nil {
            let file = UDFile()
            file.content = fileDic?["content"] as! String
            file.name = fileDic?["name"] as! String
            file.type = fileDic?["type"] as! String
            file.size = fileDic?["size"] as? String ?? ""
            m.id = fileDic?["fileId"] as? Int ?? 0
            m.file = file
            m.status = UD_STATUS_LOADING
            var type = ""
            if (fileDic?["file_name"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["file_name"] as? String ?? "")?.pathExtension ?? ""
            }
            if (fileDic?["fullLink"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["fullLink"] as? String ?? "")?.pathExtension ?? ""
            }
            if file.type.contains("image") || isImage(of: type) {
                m.type = UD_TYPE_PICTURE
            } else if file.type.contains("video") || isVideo(of: type) {
                m.type = UD_TYPE_VIDEO
                m.file.typeExtension = type
                file.type = "video"
            } else {
                m.type = UD_TYPE_File
            }
        } else {
            return nil
        }
        return m
    }
        
    private class func parseMessageDic(_ mess: [AnyHashable : Any]?, textWithoutLinkImage: String? = nil, attributedString: NSMutableAttributedString? = nil, model: UseDeskModel) -> UDMessage? {
        let m = UDMessage(text: "", incoming: false)
        
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
            m.id = Int(mess?["id"] as? Int ?? 0)
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
        m.attributedString = attributedString
        if m.incoming {
            let stringsFromButtons = parseMessageFromButtons(text: m.attributedString != nil ? m.attributedString!.string : m.text)
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
                if m.attributedString != nil {
                    m.attributedString!.mutableString.replaceOccurrences(of: stringFromButton, with: textButton, options: .caseInsensitive, range: NSRange(location: 0, length: m.attributedString!.length))
                } else {
                    m.text = m.text.replacingOccurrences(of: stringFromButton, with: textButton)
                }
            }
            for index in 0..<m.buttons.count {
                let invertIndex = (m.buttons.count - 1) - index
                if m.buttons[invertIndex].visible {
                    m.text = m.buttons[invertIndex].title + " " + m.text
                }
            }
            m.name = mess?["name"] as? String ?? ""
        }
        
        if m.text == "" && m.buttons.count == 0 {
            return nil
        }
        
        if let payload = mess?["payload"] as? [AnyHashable : Any] {
            let avatar = payload["avatar"]
            if avatar != nil {
                m.avatar = payload["avatar"] as! String
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
                        stringsFromButton.append(String(characterArrayFromButton))
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
    
    private class func buttonFromString(stringButton: String) -> UDMessageButton? {
        var stringsParameters = [String]()
        var charactersFromParameter = [Character]()
        var index = 9
        var isNameExists = true
        while (index < stringButton.count - 2) && isNameExists {
            let indexString = stringButton.index(stringButton.startIndex, offsetBy: index)
            if stringButton[indexString] != ";" {
                charactersFromParameter.append(stringButton[indexString])
                index += 1
            } else {
                // если первый параметр(имя) будет равно "" то не создавать кнопку
                if (stringsParameters.count == 0) && (charactersFromParameter.count == 0) {
                    isNameExists = false
                } else {
                    stringsParameters.append(String(charactersFromParameter))
                    charactersFromParameter = []
                    index += 1
                }
            }
        }

        if isNameExists && (stringsParameters.count == 3) {
            stringsParameters.append(String(charactersFromParameter))
            let button = UDMessageButton()
            button.title = stringsParameters[0]
            button.url = stringsParameters[1]
            if stringsParameters[3] == "show" {
                button.visible = true
            } else {
                button.visible = false
            }
            return button
        } else {
            return nil
        }
    }
    
    private class func isImage(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["gif", "xbm", "jpeg", "jpg", "pct", "bmpf", "ico", "tif", "tiff", "cur", "bmp", "png"]
        return typesImage.contains(typeLowercased)
    }
    
    private class func isVideo(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["mpeg", "mp4", "webm", "quicktime", "ogg", "mov", "mpe", "mpg", "mvc", "flv", "avi", "3g2", "3gp2", "vfw", "mpg", "mpeg"]
        return typesImage.contains(typeLowercased)
    }
}
