//
//  UDNetworkManager.swift
//  UseDesk_SDK_Swift
//
//
import SocketIO
import Alamofire

public class UDNetworkManager {
    
    public var model = UseDeskModel()
    weak var usedesk: UseDeskSDK?
    
    public weak var socket: SocketIOClient?
    private var isAuthInited = false
    private var isSendedAdditionalField = false
    private var isSendedFirstMessage = false
    private var isAuthSuccess = false
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
    public func sendOfflineForm(companyID: String, chanelID: String, name: String, email: String, message: String, file: UDFile? = nil, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        let companyAndChanelIds = "\(companyID)_\(chanelID)"
        var parameterUser: [String : Any] = [
            "os" : "iOS"
        ]
        if let targetName = Bundle.main.infoDictionary?["CFBundleName"] {
            parameterUser["browserName"] = targetName
        }
        
        var parameters: [String : Any] = [
            "company_id" : companyAndChanelIds,
            "message" : message,
            "name" : name,
            "email" : email,
            "userData" : parameterUser
        ]
        
        if let sendFile = file, !sendFile.content.isEmpty {
            let parameterFile: [String : Any] = [
                "name" : sendFile.name,
                "content" : sendFile.content,
                "type" : sendFile.mimeType,
                "size" : "NaN undefined"
            ]
            parameters["file"] = parameterFile
        }
        
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
    
    public func sendAvatarClient(connectBlock: UDConnectBlock? = nil, errorBlock: UDErrorBlock? = nil) {
        DispatchQueue.global(qos: .utility).async {
            if let data = self.model.avatar {
                self.uploadAvatarData(data, connectBlock: connectBlock, errorBlock: errorBlock)
            } else if let urlAvatar = self.model.avatarUrl {
                URLSession.shared.dataTask(with: urlAvatar, completionHandler: { [weak self] data, _, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            errorBlock?(.urlAvatarError, error.localizedDescription)
                            return
                        }
                        guard let dataAvatar = data else {return}
                        self?.uploadAvatarData(dataAvatar, connectBlock: connectBlock, errorBlock: errorBlock)
                    }
                }).resume()
            }
        }
    }
    
    private func uploadAvatarData(_ data: Data, connectBlock: UDConnectBlock? = nil, errorBlock: UDErrorBlock? = nil) {
        guard let currentToken = token else {
            errorBlock?(.tokenError, "")
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let url = self.urlBase(isOnlyHost: true) + "/v1/chat/setClient"
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(currentToken.data(using: String.Encoding.utf8)!, withName: "token")
                multipartFormData.append(data, withName: "avatar", fileName: "avatar")
                if self.model.email != "" {
                    multipartFormData.append(self.model.email.data(using: String.Encoding.utf8)!, withName: "email")
                }
                if self.model.phone != "" {
                    multipartFormData.append(self.model.phone.data(using: String.Encoding.utf8)!, withName: "phone")
                }
                if self.model.name != "" {
                    multipartFormData.append(self.model.name.data(using: String.Encoding.utf8)!, withName: "username")
                }
                if self.model.companyID != "" {
                    multipartFormData.append(self.model.companyID.data(using: String.Encoding.utf8)!, withName: "company_id")
                }
            }, to: url).responseJSON { (responseJSON) in
                switch responseJSON.result {
                case .success(let value):
                    let valueJSON = value as! [String:Any]
                    if valueJSON["error"] == nil {
                        connectBlock?(true)
                    } else {
                        errorBlock?(.serverError, "Тhe file is not accepted by the server ")
                    }
                case .failure(let error):
                    errorBlock?(.null, error.localizedDescription)
                }
            }
        }
    }
    
    public func getMessages(idComment: Int, newMessagesBlock: UDNewMessagesBlock? = nil, errorBlock: UDErrorBlock? = nil) {
        guard let currentToken = token else {
            errorBlock?(.tokenError, "")
            return
        }
        let parameters: [String : Any] = [
            "chat_token" : currentToken,
            "comment_id" : idComment
        ]
        let url = urlBase() + "/chat/getChatMessage"
        request(url: url, method: .get, parameters: parameters, isJSONEncoding: false, successBlock: { [weak self] value in
            var messages: [UDMessage] = []
            if let messagesJson = value as? [Any] {
                messages = UDSocketResponse.parseMessages(messagesJson, model: self?.model ?? UseDeskModel())
            }
            newMessagesBlock?(messages)
        }, errorBlock: { error, descriptionError in
            errorBlock?(error, descriptionError)
        })
    }
    
    public func sendFile(url: String, fileName: String, data: Data, messageId: String? = nil, progressBlock: UDProgressUploadBlock? = nil, connectBlock: UDConnectBlock? = nil, errorBlock: UDErrorBlock? = nil) {
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
                            connectBlock?(true)
                        } else {
                            errorBlock?(.serverError, "Тhe file is not accepted by the server ")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        errorBlock?(.null, error.localizedDescription)
                    }
                }
            }
        } else {
            errorBlock?(.tokenError, "")
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
    
    public func getAdditionalFields(for message: UDMessage, successBlock: @escaping UDMessageBlock, errorBlock: @escaping UDErrorBlock) {
        guard token != nil else {
            errorBlock(.tokenError, nil)
            return
        }
        var idsAdditionalFields = [Int]()
        for form in message.forms {
            if form.type == .additionalField, form.idAdditionalField > 0 {
                idsAdditionalFields.append(form.idAdditionalField)
            }
        }
        guard idsAdditionalFields.count > 0 else {
            errorBlock(.null, nil)
            return
        }
        var url = urlBase(isOnlyHost: true)
        url += "/v1/widget/field_list"
        var idsString = ""
        for index in 0..<idsAdditionalFields.count {
            idsString += "\(idsAdditionalFields[index])"
            if index != idsAdditionalFields.count - 1 {
                idsString += ","
            }
        }
        let parameters: [String : Any] = [
            "chat" : token!,
            "ids" : idsString
        ]
        DispatchQueue.global(qos: .background).async {
            self.request(url: url, method: .post, parameters: parameters, isJSONEncoding: true, successBlock: {[weak self] response in
                guard self != nil else {return}
                let newMessage = message
                let fields = UDField.parse(from: response, ids: idsAdditionalFields)
                // create form for childe fields
                for field in fields {
                    if let index = newMessage.forms.firstIndex(where: {$0.idAdditionalField == field.id}) {
                        newMessage.forms[index].field = field
                        if newMessage.forms[index].name.isEmpty {
                            newMessage.forms[index].name = field.name
                        }
                    } else {
                        let form = UDFormMessage(name: field.name, type: .additionalField, field: field)
                        if let index = newMessage.forms.firstIndex(where: {$0.idAdditionalField == field.idParentField}) {
                            newMessage.forms.insert(form, at: index + 1)
                        } else {
                            newMessage.forms.append(form)
                        }
                    }
                }
                var loadedForms: [UDFormMessage] = []
                for form in newMessage.forms {
                    if form.type == .additionalField {
                        if form.field != nil {
                            loadedForms.append(form)
                        }
                    } else {
                        loadedForms.append(form)
                    }
                }
                newMessage.forms = loadedForms
                // set required status for additionalField
                for indexForm in 0..<newMessage.forms.count {
                    if newMessage.forms[indexForm].type == .additionalField {
                        if let index = newMessage.forms.firstIndex(where: {$0.idAdditionalField == newMessage.forms[indexForm].field?.idParentField}) {
                            newMessage.forms[indexForm].isRequired = newMessage.forms[index].isRequired
                        }
                    }
                }
                successBlock(newMessage)
            }, errorBlock: { error, description in
                errorBlock(error, description)
            })
        }
    }
    
    public func sendAdditionalFields(for message: UDMessage, successBlock: @escaping UDVoidBlock, errorBlock: @escaping UDErrorBlock) {
        guard token != nil else {
            errorBlock(.tokenError, nil)
            return
        }
        var url = urlBase(isOnlyHost: true)
        url += "/v1/widget/custom_form/save"
        var formsParameters: [[String : Any]] = []
        var forms = message.forms
        while forms.count > 0 {
            let form = forms[0]
            forms.remove(at: 0)
            if form.type == .additionalField, let field = form.field {
                if field.type == .text {
                    let formParameters: [String : Any] = [
                        "associate" : form.idAdditionalField,
                        "value"     : field.value
                    ]
                    formsParameters.append(formParameters)
                } else if field.type == .checkbox {
                    let formParameters: [String : Any] = [
                        "associate" : form.idAdditionalField,
                        "value"     : field.value == "1" ? "true" : "false"
                    ]
                    formsParameters.append(formParameters)
                } else if let selectedOptionFirstField = field.selectedOption?.id {
                    var formParameters: [String : Any] = ["associate" : form.idAdditionalField]
                    var formsChildeParameters: [[String : Any]] = []
                    formsChildeParameters.append(["id" : form.field!.id, "value" : String(selectedOptionFirstField)])
                    var isExistChildeFields = true
                    var idParentField = form.idAdditionalField
                    while forms.count > 0 && isExistChildeFields {
                        if forms[0].field?.idParentField == idParentField {
                            if let selectedOption = forms[0].field!.selectedOption {
                                formsChildeParameters.append(["id" : forms[0].field!.id, "value" : String(selectedOption.id)])
                            }
                            idParentField = forms[0].idAdditionalField
                            forms.remove(at: 0)
                        } else {
                            isExistChildeFields = false
                        }
                    }
                    if formsChildeParameters.count > 1 {
                        formParameters["value"] = formsChildeParameters
                    } else {
                        formParameters["value"] = String(selectedOptionFirstField)
                    }
                    formsParameters.append(formParameters)
                }
            } else {
                let formParameters: [String : Any] = [
                    "associate" : form.type.rawValue,
                    "required" : form.isRequired,
                    "value" : form.value
                ]
                formsParameters.append(formParameters)
            }
        }
        let parameters: [String : Any] = [
            "chat" : token!,
            "form" : formsParameters
        ]
        request(url: url, method: .post, parameters: parameters, isJSONEncoding: true, successBlock: {[weak self] response in
            guard self != nil else {return}
            successBlock()
        }, errorBlock: { error, description in
            errorBlock(error, description)
        })
    }
    
    // MARK: - API Base Methods
    public func getCollections(baseBlock: @escaping UDBaseBlock, errorBlock: @escaping UDErrorBlock) {
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
    
    public func getArticle(articleID: Int, baseBlock: @escaping UDArticleBlock, errorBlock: @escaping UDErrorBlock) {
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
    
    public func addViewsArticle(articleID: Int, count: Int, connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/\(articleID)/add-views"
        let parameters: [String : Any] = [
            "api_token" : model.api_token,
            "count"     : count
        ]
        request(url: url, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func addReviewArticle(articleID: Int, countPositive: Int = 0, countNegative: Int = 0, connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/support/\(model.knowledgeBaseID)/articles/\(articleID)/change-rating"
        var parameters = ["api_token" : model.api_token]
        if countPositive > 0 {
            parameters["count_positive"] = String(countPositive)
        }
        if countNegative > 0 {
            parameters["count_negative"] = String(countNegative)
        }
        request(url: url, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func sendReviewArticleMesssage(articleID: Int, subject: String, message: String, tag: String, email: String = "", phone: String = "", name: String = "", connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        guard UDValidationManager.isValidApiParameters(model: model, errorBlock: errorBlock) else {return}
        var url = urlBase()
        url += "/create/ticket"
        var parameters = [
            "api_token" : model.api_token,
            "subject" : subject,
            "message" : message + "\n" + "id \(articleID)",
            "tag" : tag
        ]
        if email != "" {
            parameters["client_email"] = email
        }
        if phone != "" {
            parameters["client_phone"] = phone
        }
        if name != "" {
            parameters["client_name"] = name
        }
        request(url: url, parameters: parameters, successBlock: { value in
            connectBlock(true)
        }, errorBlock: errorBlock)
    }
    
    public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, searchBlock: @escaping UDArticleSearchBlock, errorBlock: @escaping UDErrorBlock) {
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
    public func socketConnect(socket: SocketIOClient?, connectBlock: UDConnectBlock? = nil) {
        socket?.connect()
        socket?.on("connect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            wSelf.usedesk?.isConnecting = true
            connectBlock?(true)
            print("socket connected")
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.model.companyID, chanelId: wSelf.model.chanelId, email: wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, url: wSelf.model.url, countMessagesOnInit: wSelf.model.countMessagesOnInit, token: wSelf.token)
            socket?.emit("dispatch", with: arrConfStart!, completion: nil)
        })
    }
    
    public func socketError(socket: SocketIOClient?, errorBlock: UDErrorBlock?) {
        socket?.on("error", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            print(data.description)
            if wSelf.isAuthInited {
                errorBlock?(.socketError, data.description)
            } else {
                errorBlock?(.falseInitChatError, data.description)
            }
        })
    }
    
    public func socketDisconnect(socket: SocketIOClient?, connectBlock: UDConnectBlock? = nil) {
        socket?.on("disconnect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            wSelf.usedesk?.isConnecting = false
            connectBlock?(false)
            print("socket disconnect")
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.model.companyID, chanelId: wSelf.model.chanelId, email: wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, url: wSelf.model.url, countMessagesOnInit: wSelf.model.countMessagesOnInit, token: wSelf.token)
            socket?.emit("dispatch", with: arrConfStart!, completion: nil)
        })
    }
    
    public func socketDispatch(socket: SocketIOClient?, startBlock: @escaping UDStartBlock, historyMessagesBlock: @escaping ([UDMessage]) -> Void, callbackSettingsBlock: @escaping (UDCallbackSettings) -> Void, newMessageBlock: UDMessageBlock?, feedbackMessageBlock: UDFeedbackMessageBlock?, feedbackAnswerMessageBlock: UDFeedbackAnswerMessageBlock?) {
        socket?.on("dispatch", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            if data.count == 0 {
                return
            }
            UDSocketResponse.actionItited(data, model: wSelf.model, historyMessagesBlock: historyMessagesBlock, serverTokenBlock: { [weak self] token in
                self?.save(token: token)
            }, setClientBlock: { [weak self] in
                guard let wSelf = self else {return}
                wSelf.socket?.emit("dispatch", with: UseDeskSDKHelp.dataClient(wSelf.model.email, phone: wSelf.model.phone, name: wSelf.model.name, note: wSelf.model.note, token: wSelf.token ?? "", additional_id: wSelf.model.additional_id)!) { [weak self] in
                    if (self?.isAuthSuccess ?? false) && !wSelf.isSendedFirstMessage {
                        wSelf.isSendedFirstMessage = true
                        if wSelf.model.firstMessage != "" {
                            let id = wSelf.newIdLoadingMessages()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                wSelf.sendMessage(wSelf.model.firstMessage, messageId: id)
                                wSelf.model.firstMessage = ""
                            }
                        }
                    }
                }
                wSelf.sendAvatarClient()
            })

            let isNoOperators = UDSocketResponse.isNoOperators(data)
            
            let callbackSettings = UDSocketResponse.actionItitedCallbackSettings(data, callbackSettingsBlock: callbackSettingsBlock)
            
            if isNoOperators || callbackSettings.type == .always {
                startBlock(false, .feedbackForm, wSelf.model.token)
            } else if callbackSettings.type == .always_and_chat {
                startBlock(false, .feedbackFormAndChat, wSelf.model.token)
            } else {
                wSelf.isAuthSuccess = UDSocketResponse.isAddInit(data)
                
                if wSelf.isAuthSuccess {
                    wSelf.isAuthInited = true
                    startBlock(wSelf.isAuthSuccess, .never, wSelf.token ?? "")
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
    private func request(url: String, method: HTTPMethod = .post, parameters: [String : Any], isJSONEncoding: Bool = false, successBlock: @escaping (Any) -> Void, errorBlock: @escaping UDErrorBlock) {
        AF.request(url, method: method, parameters: parameters, encoding: isJSONEncoding ? JSONEncoding.default : URLEncoding.default).responseJSON { responseJSON in
            switch responseJSON.result {
            case .success(let value):
                if let valueDictionary = value as? [String : Any] {
                    if valueDictionary["error"] != nil {
                        errorBlock(.serverError, UDError.serverError.description)
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
    
    private func urlBase(isOnlyHost: Bool = false) -> String {
        var url = ""
        if model.urlAPI != "" {
            url += model.urlAPI
        } else {
            url += "https://secure.usedesk.ru"
        }
        if !isOnlyHost {
            url += "/uapi"
        }
        return url
    }
    
    private func loadToken() -> String? {
        let key = "usedeskClientToken\(model.email)\(model.phone)\(model.name)\(model.chanelId)"
        return UserDefaults.standard.string(forKey: key)
    }
    
    private func save(token: String) {
        usedesk?.model.token = token
        if model.isSaveTokensInUserDefaults {
            let key = "usedeskClientToken\(model.email)\(model.phone)\(model.name)\(model.chanelId)"
            UserDefaults.standard.set(token, forKey: key)
        }
    }
}
