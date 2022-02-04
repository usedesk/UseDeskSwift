//
//  UDValidationManager.swift
//  UseDesk_SDK_Swift
//
//

public class UDValidationManager {
    
    class func validateInitionalsFields(companyID: String, chanelId: String, urlAPI: String? = nil, knowledgeBaseID: String? = nil, api_token: String? = nil, email: String? = nil, phone: String? = nil, url: String, urlToSendFile: String? = nil, port: String? = nil, name: String? = nil, operatorName: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], additional_id: String? = nil, token: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isSaveTokensInUserDefaults: Bool = true, isPresentDefaultControllers: Bool = true, errorStatus errorBlock: @escaping UDSErrorBlock) -> (UseDeskModel?) {
        
        var model = UseDeskModel()
        
        model.additionalFields = additionalFields
        model.additionalNestedFields = additionalNestedFields
        
        model.companyID = companyID
        guard chanelId.trimmingCharacters(in: .whitespaces).count > 0 && Int(chanelId) != nil else {
            errorBlock(.chanelIdError, UDError.chanelIdError.description)
            return nil
        }
        model.chanelId = chanelId
        if knowledgeBaseID != nil {
            model.knowledgeBaseID = knowledgeBaseID!
        }
        if api_token != nil {
            model.api_token = api_token!
        }
        
        if customLocale != nil {
            model.locale = customLocale!
        } else if localeIdentifier != nil {
            if let getLocale = UDLocalizeManager().getLocaleFor(localeId: localeIdentifier!) {
                model.locale = getLocale
            } else {
                model.locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
            }
        } else {
            model.locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
        }
        
        if port != nil {
            if port != "" {
                model.port = port!
            }
        }
        
        guard isValidSite(path: url) else {
            errorBlock(.urlError, UDError.urlError.description)
            return nil
        }
        model.urlWithoutPort = url
        
        if isExistProtocol(url: url) {
            model.url = "\(url):\(model.port)"
        } else {
            model.url = "https://" + "\(url):\(model.port)"
        }
        
        if email != nil {
            if email != "" {
                if email!.udIsValidEmail() {
                    model.email = email!
                } else {
                    errorBlock(.emailError, UDError.emailError.description)
                    return nil
                }
            }
        }
        
        if urlToSendFile != nil {
            if urlToSendFile != "" {
                guard isValidSite(path: urlToSendFile!) else {
                    errorBlock(.urlToSendFileError, UDError.urlToSendFileError.description)
                    return nil
                }
                if isExistProtocol(url: urlToSendFile!) {
                    model.urlToSendFile = urlToSendFile!
                } else {
                    model.urlToSendFile = "https://" + urlToSendFile!
                }
            }
        }
        
        if urlAPI != nil {
            if urlAPI != "" {
                var urlAPIValue = urlAPI!
                if !isExistProtocol(url: urlAPIValue) {
                    urlAPIValue = "https://" + urlAPIValue
                }
                guard isValidSite(path: urlAPIValue) else {
                    errorBlock(.urlAPIError, UDError.urlAPIError.description)
                    return nil
                }
                model.urlAPI = urlAPIValue
            }
        }
        
        if name != nil {
            if name != "" {
                model.name = name!
            }
        }
        if operatorName != nil {
            if operatorName != "" {
                model.operatorName = operatorName!
            }
        }
        if phone != nil {
            if phone != "" {
                guard isValidPhone(phone: phone!) else {
                    errorBlock(.phoneError, UDError.phoneError.description)
                    return nil
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
                    return nil
                }
                model.token = token!
            }
        }
        model.isPresentDefaultControllers = isPresentDefaultControllers
        model.isSaveTokensInUserDefaults = isSaveTokensInUserDefaults
        return model
    }
    
    class func isValidApiParameters(model: UseDeskModel, errorBlock: @escaping UDSErrorBlock) -> Bool {
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
    
    // MARK: - Private Methods
    private class func isValidSite(path: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: path)
    }
    
    private class func isValidPhone(phone:String) -> Bool {
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
