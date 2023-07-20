//
//  UDValidationManager.swift
//  UseDesk_SDK_Swift

public class UDValidationManager {
    
    class func validateInitionalsFields(companyID: String? = nil, chanelId: String? = nil, url: String? = nil, port: String? = nil, urlAPI: String? = nil, api_token: String? = nil, urlToSendFile: String? = nil, knowledgeBaseID: String? = nil, knowledgeBaseSectionId: NSNumber? = nil, knowledgeBaseCategoryId: NSNumber? = nil, knowledgeBaseArticleId: NSNumber? = nil, isReturnToParentFromKnowledgeBase: Bool = false, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: Data? = nil, avatarUrl: URL? = nil, token: String? = nil, additional_id: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], nameOperator: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, countMessagesOnInit: NSNumber? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isSaveTokensInUserDefaults: Bool = true, isPresentDefaultControllers: Bool = true, isOnlyKnowledgeBase : Bool = false, validModelBlock: @escaping UDValidModelBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        
        var model = UseDeskModel()
        
        model.additionalFields = additionalFields
        model.additionalNestedFields = additionalNestedFields
        
        if companyID != nil {
            model.companyID = companyID!
        }
        
        if chanelId != nil {
            guard chanelId!.trimmingCharacters(in: .whitespaces).count > 0 && Int(chanelId!) != nil else {
                errorBlock(.chanelIdError, UDError.chanelIdError.description)
                return
            }
            model.chanelId = chanelId!
        }
        
        model.isOnlyKnowledgeBase = isOnlyKnowledgeBase
        if isOnlyKnowledgeBase {
            if (knowledgeBaseID ?? "").count > 0 {
                model.knowledgeBaseID = knowledgeBaseID ?? ""
            } else {
                errorBlock(.emptyKnowledgeBaseID, UDError.emptyKnowledgeBaseID.description)
            }
        } else {
            model.knowledgeBaseID = knowledgeBaseID ?? ""
        }
        
        if Int(truncating: knowledgeBaseArticleId ?? 0) > 0 {
            model.knowledgeBaseArticleId = Int(truncating: knowledgeBaseArticleId!)
        }
        if Int(truncating: knowledgeBaseCategoryId ?? 0) > 0 {
            model.knowledgeBaseCategoryId = Int(truncating: knowledgeBaseCategoryId!)
        }
        if Int(truncating: knowledgeBaseSectionId ?? 0) > 0 {
            model.knowledgeBaseSectionId = Int(truncating: knowledgeBaseSectionId!)
        }
        
        model.isReturnToParentFromKnowledgeBase = isReturnToParentFromKnowledgeBase
        
        if api_token != nil {
            model.api_token = api_token!
        }
        
        if customLocale != nil {
            model.locale = customLocale!
        } else if localeIdentifier != nil {
            if let getLocale = UDLocalizeManager().getLocaleFor(localeId: localeIdentifier!) {
                model.locale = getLocale
                model.localeIdentifier = localeIdentifier!
            } else {
                model.locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
                model.localeIdentifier = "ru"
            }
        } else {
            model.locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
            model.localeIdentifier = "ru"
        }
        
        if port != nil {
            if port != "" {
                model.port = port!
            }
        }
        
        if url != nil {
            guard url!.udIsValidUrl() else {
                errorBlock(.urlError, UDError.urlError.description)
                return
            }
            var urlValue = url!
            if urlValue.last == "/" && urlValue.count > 2 {
                urlValue.removeLast()
            }
            model.urlWithoutPort = urlValue
            
            if isExistProtocol(url: urlValue) {
                model.url = "\(urlValue):\(model.port)"
            } else {
                model.url = "https://" + "\(urlValue):\(model.port)"
            }
        }
        
        if email != nil {
            if email != "" {
                if email!.udIsValidEmail() {
                    model.email = email!
                } else {
                    errorBlock(.emailError, UDError.emailError.description)
                    return
                }
            }
        }
        
        if let url = urlToSendFile {
            if url != "" {
                var urlValue = url
                guard urlValue.udIsValidUrl() else {
                    errorBlock(.urlToSendFileError, UDError.urlToSendFileError.description)
                    return
                }
                if urlValue.last == "/" && urlValue.count > 2 {
                    urlValue.removeLast()
                }
                if isExistProtocol(url: urlValue) {
                    model.urlToSendFile = urlValue
                } else {
                    model.urlToSendFile = "https://" + urlValue
                }
            }
        }
        
        if let url = urlAPI {
            if url != "" {
                var urlValue = url
                if !isExistProtocol(url: urlValue) {
                    urlValue = "https://" + urlValue
                }
                guard urlValue.udIsValidUrl() else {
                    errorBlock(.urlAPIError, UDError.urlAPIError.description)
                    return
                }
                if urlValue.last == "/" && urlValue.count > 2 {
                    urlValue.removeLast()
                }
                model.urlAPI = urlValue
            }
        }
        
        if name != nil {
            if name != "" {
                model.name = name!
            }
        }
        
        if avatar != nil {
            model.avatar = avatar!
        } else if avatarUrl != nil {
            model.avatarUrl = avatarUrl!
        }
        
        if nameOperator != nil {
            if nameOperator != "" {
                model.nameOperator = nameOperator!
            }
        }
        
        if phone != nil {
            if phone != "" {
                guard isValidPhone(phone: phone!) else {
                    errorBlock(.phoneError, UDError.phoneError.description)
                    return
                }
                model.phone = phone!
            }
        }
        
        if nameChat != nil {
            if nameChat != "" {
                model.nameChat = nameChat!
            } else {
                model.nameChat = model.stringFor("OnlineChat")

            }
        } else {
            model.nameChat = model.stringFor("OnlineChat")
        }
        
        if firstMessage != nil {
            if firstMessage != "" {
                model.firstMessage = firstMessage!
            }
        }
        
        if countMessagesOnInit != nil {
            guard Int(truncating: countMessagesOnInit!) >= 10 else {
                errorBlock(.countMessagesOnInitError, UDError.countMessagesOnInitError.description)
                return
            }
            model.countMessagesOnInit = Int(truncating: countMessagesOnInit!)
        } else {
            model.countMessagesOnInit = UD_LIMIT_PAGINATION_DEFAULT
        }
        
        
        if note != nil {
            if note != "" {
                model.note = note!
            }
        }
        
        if additional_id != nil {
            if additional_id != "" {
                model.additional_id = additional_id!
            }
        }
        
        if token != nil {
            if token != "" {
                if !token!.udIsValidToken() {
                    errorBlock(.tokenError, UDError.tokenError.description)
                    return
                }
                model.token = token!
            }
        }
        model.isPresentDefaultControllers = isPresentDefaultControllers
        model.isSaveTokensInUserDefaults = isSaveTokensInUserDefaults
        
        validModelBlock(model)
    }
    
    class func isValidApiParameters(model: UseDeskModel, errorBlock: @escaping UDErrorBlock) -> Bool {
        if model.knowledgeBaseID == "" {
            errorBlock(.emptyKnowledgeBaseID, UDError.emptyKnowledgeBaseID.description)
            return false
        }
        if model.api_token == "" {
            errorBlock(.emptyTokenAPI, UDError.emptyTokenAPI.description)
            return false
        }
        return true
    }
    
    class func isValidPhone(phone:String) -> Bool {
       do {
           let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
           let matches = detector.matches(in: phone, options: [], range: NSMakeRange(0, phone.count))
           if let res = matches.first {
               return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phone.count
           } else {
               return false
           }
       } catch {
           return false
       }
   }
    
    // MARK: - Private Methods
    private class func isExistProtocol(url: String) -> Bool {
        if url.count > 8 {
            let indexEndHttps = url.index(url.startIndex, offsetBy: 7)
            let indexEndHttp = url.index(url.startIndex, offsetBy: 6)
            if url[url.startIndex...indexEndHttps] != "https://" && url[url.startIndex...indexEndHttp] != "http://" {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
}
