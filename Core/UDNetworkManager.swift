//
//  UDNetworkManager.swift
//  UseDesk_SDK_Swift
//
//
import SocketIO
import Alamofire

public class UDNetworkManager {
    
    public var model = UseDeskModel()
    
    public weak var socket: SocketIOClient?
    private var isAuthInited = false
    private var isSendedAdditionalField = false
    private var token: String? {
        return model.token != "" ? model.token : loadToken()
    }
    
    init(model: UseDeskModel) {
        self.model = model
    }
    
    // MARK: - Methods
    public func newIdLoadingMessages() -> String {
        var count = 89000
        var id = Int.random(in: 1..<90000)
        while model.idLoadingMessages.contains(String(id)) && count > 0 {
            count -= 1
            id = Int.random(in: 1..<90000)
        }
        model.idLoadingMessages.append(String(id))
        return String(id)
    }
    
    // MARK: - API Methods
    public func sendOfflineForm(companyID: String, chanelID: String, name: String, email: String, message: String, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, connectBlock: @escaping UDSConnectBlock, errorBlock: @escaping UDSErrorBlock) {
        let companyAndChanelIds = "\(companyID)_\(chanelID)"
        var parameters: [String : Any] = [
            "company_id" : companyAndChanelIds,
            "message" : message,
            "name" : name,
            "email" : email
        ]
        
        if topic != nil {
            if topic != "" {
                parameters["topic"] = topic!
            }
        }
        
        if fields != nil {
            for field in fields! {
                parameters[field.key] = field.text
            }
        }
        
        let url = "https://secure.usedesk.ru/widget.js/post"
        request(url: url, parameters: parameters, isJSONEncoding: true, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func sendFile(url: String, fileName: String, data: Data, messageId: String? = nil, progressBlock: UDSProgressUploadBlock? = nil, connectBlock: @escaping UDSConnectBlock, errorBlock: @escaping UDSErrorBlock) {
        if let currentToken = token {
            DispatchQueue.global(qos: .utility).async { 
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(currentToken.data(using: String.Encoding.utf8)!, withName: "chat_token")
                    multipartFormData.append(data, withName: "file", fileName: fileName)
                    if messageId != nil {
                        if messageId != "" {
                            multipartFormData.append(messageId!.data(using: String.Encoding.utf8)!, withName: "message_id")
                        }
                    }
                }, to: url).uploadProgress(closure: { (progress) in
                    progressBlock?(progress)
                }).responseJSON { (responseJSON) in
                    switch responseJSON.result {
                    case .success(let value):
                        let valueJSON = value as! [String:Any]
                        if valueJSON["error"] == nil {
                            connectBlock(true)
                        } else {
                            errorBlock(.serverError, "Тhe file is not accepted by the server ")
                        }
                    case .failure(let error):
                        errorBlock(.null, error.localizedDescription)
                    }
                }
            }
        } else {
            errorBlock(.tokenError, "")
        }
    }
    
    public func sendAdditionalFields() {
        guard !isSendedAdditionalField && (model.additionalFields.count > 0 || model.additionalNestedFields.count > 0) else {return}
        var allFields: [Any] = []
        for (id, value) in model.additionalFields {
            allFields.append([
                "id" : id,
                "value" : value
            ])
        }
        for nestedField in model.additionalNestedFields {
            var fieldsArray: [[String : Any]] = []
            for (id, value) in nestedField {
                if id > 0 {
                    fieldsArray.append([
                        "id" : id,
                        "value" : value
                    ])
                }
            }
            allFields.append(fieldsArray)
        }
        let parameters: [String : Any] = [
            "additional_fields" : allFields,
            "chat_token" : model.token
        ]
        var url = urlBase()
        url += "/v1/addFieldsToChat"
        request(url: url, method: .post, parameters: parameters, isJSONEncoding: true, successBlock: {[weak self] _ in
            guard let wSelf = self else {return}
            wSelf.isSendedAdditionalField = true
        }, errorBlock: {_,_  in})
    }
    
    // MARK: - API Base Methods
    public func getCollections(baseBlock: @escaping UDSBaseBlock, errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/list"
        let parameters = ["api_token" : model.api_token]
        request(url: url, method: .get, parameters: parameters, successBlock: { value in
            if let collections = UDBaseCollection.getArray(from: value) {
                baseBlock(true, collections)
            } else {
                errorBlock(.serverError, UDError.serverError.description)
            }
        }, errorBlock: errorBlock)
    }
    
    public func getArticle(articleID: Int, baseBlock: @escaping UDSArticleBlock, errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/\(articleID)"
        let parameters = ["api_token" : model.api_token]
        request(url: url, method: .get, parameters: parameters, successBlock: { value in
            if let article = UDArticle.get(from: value) {
                baseBlock(true, article)
            } else {
                errorBlock(.serverError, UDError.serverError.description)
            }
        }, errorBlock: errorBlock)
    }
    
    public func addViewsArticle(articleID: Int, count: Int, connectBlock: @escaping UDSConnectBlock, errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/\(articleID)/add-views"
        let parameters: [String : Any] = [
            "api_token" : model.api_token,
            "count"     : count
        ]
        request(url: url, method: .get, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func addReviewArticle(articleID: Int, countPositiv: Int = 0, countNegativ: Int = 0, connectBlock: @escaping UDSConnectBlock, errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/\(articleID)/change-rating"
        var parameters = ["api_token" : model.api_token]
        if countPositiv > 0 {
            parameters["count_positive"] = String(countPositiv)
        }
        if countNegativ > 0 {
            parameters["count_negative"] = String(countNegativ)
        }
        request(url: url, method: .get, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func sendReviewArticleMesssage(articleID: Int, subject: String, message: String, tag: String, email: String, name: String = "", connectionStatus connectBlock: @escaping UDSConnectBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/create/ticket"
        var parameters = [
            "api_token" : model.api_token,
            "subject" : subject,
            "message" : message + "\n" + "id \(articleID)",
            "tag" : tag,
            "client_email" : email
        ]
        if name != "" {
            parameters["client_name"] = name
        }
        request(url: url, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, searchBlock: @escaping UDSArticleSearchBlock, errorBlock: @escaping UDSErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/list"
        var parameters: [String : Any] = [
            "api_token"  : model.api_token,
            "query"      : query,
            "count"      : count,
            "page"       : page,
            "short_text" : "1"
        ]
        switch type {
        case .close:
            parameters["type"] = "public"
        case .open:
            parameters["type"] = "private"
        default:
            break
        }
        
        switch sort {
        case .id:
            parameters["sort"] = "id"
        case .category_id:
            parameters["sort"] = "category_id"
        case .created_at:
            parameters["sort"] = "created_at"
        case .open:
            parameters["sort"] = "public"
        case .title:
            parameters["sort"] = "title"
        default:
            break
        }
        
        switch order {
        case .asc:
            parameters["order"] = "asc"
        case .desc:
            parameters["order"] = "desc"
        default:
            break
        }
        if collection_ids.count > 0 {
            var idsStrings = ""
            for id in collection_ids {
                if idsStrings == "" {
                    idsStrings += "\(id)"
                } else {
                    idsStrings += ",\(id)"
                }
            }
            parameters["collection_ids"] = idsStrings
        }
        if category_ids.count > 0 {
            var idsStrings = ""
            for id in category_ids {
                if idsStrings == "" {
                    idsStrings += "\(id)"
                } else {
                    idsStrings += ",\(id)"
                }
            }
            parameters["category_ids"] = idsStrings
        }
        if article_ids.count > 0 {
            var idsStrings = ""
            for id in article_ids {
                if idsStrings == "" {
                    idsStrings += "\(id)"
                } else {
                    idsStrings += ",\(id)"
                }
            }
            parameters["article_ids"] = idsStrings
        }
        request(url: url, method: .get, parameters: parameters, successBlock: { value in
            if let articles = UDSearchArticle(from: value) {
                searchBlock(true, articles)
            } else {
                errorBlock(.serverError, UDError.serverError.description)
            }
        }, errorBlock: errorBlock)
    }
    
    // MARK: - Socket Methods
    public func socketConnect(socket: SocketIOClient?, connectBlock: UDSConnectBlock? = nil) {
        socket?.connect()
        socket?.on("connect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            connectBlock?(true)
            print("socket connected")
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.model.companyID, chanelId: wSelf.model.chanelId, email: wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, url: wSelf.model.url, token: wSelf.token)
            socket?.emit("dispatch", with: arrConfStart!, completion: nil)
        })
    }
    
    public func socketError(socket: SocketIOClient?, errorBlock: UDSErrorBlock?) {
        socket?.on("error", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            if !wSelf.isAuthInited {
                errorBlock?(.falseInitChatError, UDError.falseInitChatError.description)
            } else {
                errorBlock?(.socketError, data.description)
            }
        })
    }
    
    public func socketDisconnect(socket: SocketIOClient?, connectBlock: UDSConnectBlock? = nil) {
        socket?.on("disconnect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            connectBlock?(false)
            print("socket disconnect")
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.model.companyID, chanelId: wSelf.model.chanelId, email: wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, url: wSelf.model.url, token: wSelf.token)
            socket?.emit("dispatch", with: arrConfStart!, completion: nil)
        })
    }
    
    public func socketDispatch(socket: SocketIOClient?, startBlock: @escaping UDSStartBlock, historyMessagesBlock: @escaping ([UDMessage]) -> Void, callbackSettingsBlock: @escaping (UDCallbackSettings) -> Void, newMessageBlock: UDSNewMessageBlock?, feedbackMessageBlock: UDSFeedbackMessageBlock?, feedbackAnswerMessageBlock: UDSFeedbackAnswerMessageBlock?) {
        socket?.on("dispatch", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            if data.count == 0 {
                return
            }
            UDSocketResponse.actionItited(data, model: wSelf.model, historyMessagesBlock: historyMessagesBlock, serverTokenBlock: { [weak self] token in
                self?.save(token: token)
            }, setClientBlock: { [weak self] in
                guard let wSelf = self else {return}
                wSelf.socket?.emit("dispatch", with: UseDeskSDKHelp.dataClient(wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, note: wSelf.model.note, token: wSelf.token ?? "", additional_id: wSelf.model.additional_id)!, completion: nil)
            })

            let isNoOperators = UDSocketResponse.isNoOperators(data)
            
            let callbackSettings = UDSocketResponse.actionItitedCallbackSettings(data, callbackSettingsBlock: callbackSettingsBlock)
            
            if isNoOperators || callbackSettings.type == .always {
                startBlock(false, .feedbackForm, wSelf.model.token)
            } else if callbackSettings.type == .always_and_chat {
                startBlock(false, .feedbackFormAndChat, wSelf.model.token)
            } else {
                let isAuthSuccess = UDSocketResponse.isAddInit(data)
                
                if isAuthSuccess {
                    if wSelf.model.firstMessage != "" {
                        let id = wSelf.newIdLoadingMessages()
                        wSelf.model.idLoadingMessages.append(id)
                        wSelf.sendMessage(wSelf.model.firstMessage, messageId: id)
                        wSelf.model.firstMessage = ""
                    }
                    wSelf.isAuthInited = true
                    startBlock(isAuthSuccess, .never, wSelf.token ?? "")
                }
                
                UDSocketResponse.actionFeedbackAnswer(data, feedbackAnswerMessageBlock: feedbackAnswerMessageBlock)
                
                UDSocketResponse.actionAddMessage(data, newMessageBlock: newMessageBlock, feedbackMessageBlock: feedbackMessageBlock, sendAdditionalFieldsBlock: {
                    wSelf.sendAdditionalFields()
                }, isSendedAdditionalField: wSelf.isSendedAdditionalField, model: wSelf.model)
            }
        })
    }
    
    public func sendMessage(_ text: String, messageId: String? = nil) {
        let mess = UseDeskSDKHelp.messageText(text, messageId: messageId)
        socket?.emit("dispatch", with: mess!, completion: nil)
    }
    
    // MARK: - Private Methods
    private func request(url: String, method: HTTPMethod = .post, parameters: [String : Any], isJSONEncoding: Bool = false, successBlock: @escaping (Any) -> Void, errorBlock: @escaping UDSErrorBlock) {
        AF.request(url, method: method, parameters: parameters, encoding: isJSONEncoding ? JSONEncoding.default : URLEncoding.default).responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let value):
                if let valueDictionary = value as? [String : Any] {
                    if valueDictionary["error"] != nil {
                        if let code = valueDictionary["code"] as? Int {
                            errorBlock(UDError(errorCode: code), UDError(errorCode: code).description)
                        }
                    } else {
                        successBlock(value)
                    }
                } else {
                    successBlock(value)
                }
            case .failure(let error):
                errorBlock(.null, error.localizedDescription)
            }
        }
    }
    
    private func urlBase() -> String {
        var url = ""
        if model.urlAPI != "" {
            url += model.urlAPI + "/uapi"
        } else {
            url += "https://secure.usedesk.ru/uapi"
        }
        return url
    }
    
    private func loadToken() -> String? {
        let key = "usedeskClientToken\(model.email)\(model.phone)\(model.name)\(model.chanelId)"
        return UserDefaults.standard.string(forKey: key)
    }
    
    private func save(token: String) {
        model.token = token
        if model.isSaveTokensInUserDefaults {
            let key = "usedeskClientToken\(model.email)\(model.phone)\(model.name)\(model.chanelId)"
            UserDefaults.standard.set(token, forKey: key)
        }
    }
}
