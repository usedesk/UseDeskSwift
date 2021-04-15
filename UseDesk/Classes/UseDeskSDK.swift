//
//  UseDeskSDK.swift

import Foundation
import SocketIO
import Alamofire
import UserNotifications
import Down


public typealias UDSStartBlock = (Bool, String?) -> Void
public typealias UDSBaseBlock = (Bool, [UDBaseCollection]?, String?) -> Void
public typealias UDSArticleBlock = (Bool, UDArticle?, String?) -> Void
public typealias UDSArticleSearchBlock = (Bool, UDSearchArticle?, String?) -> Void
public typealias UDSConnectBlock = (Bool, String?) -> Void
public typealias UDSNewMessageBlock = (Bool, UDMessage?) -> Void
public typealias UDSErrorBlock = ([Any]?) -> Void
public typealias UDSFeedbackMessageBlock = (UDMessage?) -> Void
public typealias UDSFeedbackAnswerMessageBlock = (Bool) -> Void

let RootView = UIApplication.shared.keyWindow?.rootViewController

public class UseDeskSDK: NSObject {
    @objc public var newMessageBlock: UDSNewMessageBlock?
    @objc public var connectBlock: UDSConnectBlock?
    @objc public var errorBlock: UDSErrorBlock?
    @objc public var feedbackMessageBlock: UDSFeedbackMessageBlock?
    @objc public var feedbackAnswerMessageBlock: UDSFeedbackAnswerMessageBlock?
    @objc public var historyMess: [UDMessage] = []
    @objc public var maxCountAssets: Int = 10
    @objc public var isSupportedAttachmentOnlyPhoto: Bool = false
    @objc public var isSupportedAttachmentOnlyVideo: Bool = false
    // Style
    public var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    // UDCallbackSettings
    public var callbackSettings = UDCallbackSettings()
    // isOpenSDKUI
    public var isOpenSDKUI: Bool = false
    // Socket
    var manager: SocketManager?
    var socket: SocketIOClient?
    // Configutation
    var companyID = ""
    var chanelId = ""
    var email = ""
    var phone = ""
    var url = ""
    var urlToSendFile = ""
    var urlWithoutPort = ""
    var urlAPI = ""
    var knowledgeBaseID = ""
    var api_token = ""
    var port = ""
    var name = ""
    var operatorName = ""
    var nameChat = ""
    var firstMessage = ""
    var note = ""
    var signature = ""
    // Lolace
    var locale: [String:String] = [:]
    
    var navController = UDNavigationController()
    var idLoadingMessages: [String] = []
    var loader: UDLoader? = nil
    
    private var token = ""
    private var dialogflowVC: DialogflowView = DialogflowView()
    private var offlineVC: UDOfflineForm = UDOfflineForm()
    
    @objc public func start(withCompanyID _companyID: String, chanelId _chanelId: String, urlAPI _urlAPI: String? = nil, knowledgeBaseID _knowledgeBaseID: String? = nil, api_token _api_token: String, email _email: String? = nil, phone _phone: String? = nil, url _url: String, urlToSendFile _urlToSendFile: String? = nil, port _port: String? = nil, name _name: String? = nil, operatorName _operatorName: String? = nil, nameChat _nameChat: String? = nil, firstMessage _firstMessage: String? = nil, note _note: String? = nil, signature _signature: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, presentIn parentController: UIViewController? = nil, connectionStatus startBlock: UDSStartBlock) {
        
        let parentController: UIViewController? = parentController ?? RootView
        
        loader = UDLoader(view: parentController?.view ?? UIView(), colorBackView: configurationStyle.chatStyle.backgroundColorLoaderView, alphaBackView: configurationStyle.chatStyle.alphaLoaderView)
        loader?.show()
        
        companyID = _companyID
        guard _chanelId.trimmingCharacters(in: .whitespaces).count > 0 && Int(_chanelId) != nil else {
            startBlock(false, "chanelIdError")
            return
        }
        chanelId = _chanelId
        api_token = _api_token
       
        if _port != nil {
            if _port != "" {
                port = _port!
            }
        }
        
        guard isValidSite(path: _url) else {
            startBlock(false, "urlError")
            return
        }
        urlWithoutPort = _url
        
        if isExistProtocol(url: _url) {
            url = "\(_url):\(port)"
        } else {
            url = "https://" + "\(_url):\(port)"
        }
        
        
        if _email != nil {
            if _email != "" {
                email = _email!
                if !email.udIsValidEmail() {
                    startBlock(false, "emailError")
                    loader?.hide(animated: true)
                    return
                }
            }
        }
        
        if _urlToSendFile != nil {
            if _urlToSendFile != "" {
                guard isValidSite(path: _urlToSendFile!) else {
                    startBlock(false, "urlToSendFileError")
                    return
                }
                if isExistProtocol(url: _urlToSendFile!) {
                    urlToSendFile = _urlToSendFile!
                } else {
                    urlToSendFile = "https://" + _urlToSendFile!
                }
            }
        }
        
        if _knowledgeBaseID != nil {
            knowledgeBaseID = _knowledgeBaseID!
        }
        
        if _urlAPI != nil {
            if _urlAPI != "" {
                if isExistProtocol(url: _urlAPI!) {
                    urlAPI = _urlAPI!
                } else {
                    urlAPI = "https://" + _urlAPI!
                }
                guard isValidSite(path: urlAPI) else {
                    startBlock(false, "urlAPIError")
                    return
                }
            }
        }
        
        if _name != nil {
            if _name != "" {
                name = _name!
            }
        }
        if _operatorName != nil {
            if _operatorName != "" {
                operatorName = _operatorName!
            }
        }
        if _phone != nil {
            if _phone != "" {
                phone = _phone!
                guard isValidPhone(phone: _phone!) else {
                    startBlock(false, "phoneError")
                    loader?.hide(animated: true)
                    return
                }
            }
        }
        if _nameChat != nil {
            if _nameChat != "" {
                nameChat = _nameChat!
            } else {
                nameChat = stringFor("OnlineChat")

            }
        } else {
            nameChat = stringFor("OnlineChat")
        }
        if _firstMessage != nil {
            if _firstMessage != "" {
                firstMessage = _firstMessage!
            }
        }
        if _note != nil {
            if _note != "" {
                note = _note!
            }
        }
        if _signature != nil {
            if _signature != "" {
                if !_signature!.udIsValidSignature() {
                    startBlock(false, "signatureError")
                    loader?.hide(animated: true)
                    return
                }
                signature = _signature!
            }
        }
//        if _additional_id != nil {
//            if _additional_id != "" {
//                additional_id = _additional_id!
//            }
//        }
        if customLocale != nil {
            locale = customLocale!
        } else if localeIdentifier != nil {
            if let getLocale = UDLocalizeManager().getLocaleFor(localeId: localeIdentifier!) {
                locale = getLocale
            } else {
                locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
            }
        } else {
            locale = UDLocalizeManager().getLocaleFor(localeId: "ru")!
        }
        
        isOpenSDKUI = true
        if knowledgeBaseID != "" {
            let baseView = UDBaseSectionsView()
            baseView.usedesk = self
            baseView.url = self.url
            navController = UDNavigationController(rootViewController: baseView)
            navController.configurationStyle = configurationStyle
            navController.setTitleTextAttributes()
            navController.modalPresentationStyle = .fullScreen
            parentController?.present(navController, animated: true)
            loader?.hide(animated: true)
        } else {
            startWithoutGUICompanyID(companyID: companyID, chanelId: chanelId, knowledgeBaseID: knowledgeBaseID, api_token: api_token, email: email, phone: _phone, url: urlWithoutPort, port: port, name: _name, operatorName: operatorName, nameChat: _nameChat, connectionStatus: { [weak self] success, error in
                guard let wSelf = self else {return}
                if success {
                    wSelf.dialogflowVC.usedesk = wSelf
                    if wSelf.navController.presentingViewController == nil {
                        wSelf.navController = UDNavigationController(rootViewController: wSelf.dialogflowVC)
                        wSelf.navController.configurationStyle = wSelf.configurationStyle
                        wSelf.navController.setTitleTextAttributes()
                        wSelf.navController.modalPresentationStyle = .fullScreen
                        parentController?.present(wSelf.navController, animated: true)
                    }
                } else {
                    if error == "feedback_form" || error == "feedback_form_and_chat" {
                        if wSelf.offlineVC.presentingViewController == nil {
                            wSelf.dialogflowVC.dismiss(animated: true)
                            wSelf.offlineVC = UDOfflineForm()
                            wSelf.offlineVC.url = wSelf.url
                            wSelf.offlineVC.usedesk = wSelf
                            wSelf.navController = UDNavigationController(rootViewController: wSelf.offlineVC)
                            wSelf.navController.configurationStyle = wSelf.configurationStyle
                            wSelf.navController.setTitleTextAttributes()
                            wSelf.navController.modalPresentationStyle = .fullScreen
                            parentController?.present(wSelf.navController, animated: true)
                        }
                        wSelf.loader?.hide(animated: true)
                    }
                }
            })
        }
    }

    @objc public func sendMessage(_ text: String, messageId: String? = nil) {
        let mess = UseDeskSDKHelp.messageText(text, messageId: messageId)
        socket?.emit("dispatch", with: mess!)
    }
    
    @objc public func sendFile(fileName: String, data: Data, messageId: String? = nil, status: @escaping (Bool, String?) -> Void) {
        let url = urlToSendFile != "" ? urlToSendFile : "https://secure.usedesk.ru/uapi/v1/send_file"
        if let currentToken = signature != "" ? signature : loadToken() {
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(currentToken.data(using: String.Encoding.utf8)!, withName: "chat_token")
                multipartFormData.append(data, withName: "file", fileName: fileName)
                if messageId != nil {
                    if messageId != "" {
                        multipartFormData.append(messageId!.data(using: String.Encoding.utf8)!, withName: "message_id")
                    }
                }
            }, to: url).responseJSON { (responseJSON) in
                switch responseJSON.result {
                case .success(let value):
                    let valueJSON = value as! [String:Any]
                    if valueJSON["error"] == nil {
                        status(true, nil)
                    } else {
                        status(false, "Тhe file is not accepted by the server ")
                    }
                case .failure(let error):
                    status(false, error.localizedDescription)
                }
            }
        } else {
            status(false, "Тhe file is not accepted by the server ")
        }
    }
    
    @objc public func startWithoutGUICompanyID(companyID _companyID: String, chanelId _chanelId: String, urlAPI _urlAPI: String? = nil, knowledgeBaseID _knowledgeBaseID: String? = nil, api_token _api_token: String, email _email: String? = nil, phone _phone: String? = nil, url _url: String, urlToSendFile _urlToSendFile: String? = nil, port _port: String? = nil, name _name: String? = nil, operatorName _operatorName: String? = nil, nameChat _nameChat: String? = nil, firstMessage _firstMessage: String? = nil, note _note: String? = nil, signature _signature: String? = nil, isBeforeFeedbackForm: Bool = false, connectionStatus startBlock: @escaping UDSStartBlock) {
        
        var isAuthInited = false
        
        companyID = _companyID
        guard _chanelId.trimmingCharacters(in: .whitespaces).count > 0 && Int(_chanelId) != nil else {
            startBlock(false, "chanelIdError")
            return
        }
        chanelId = _chanelId
        api_token = _api_token
        
        if _port != nil {
            if _port != "" {
                port = _port!
            }
        }
        
        guard isValidSite(path: _url) else {
            startBlock(false, "urlError")
            return
        }
        if isExistProtocol(url: _url) {
            url = "\(_url):\(port)"
        } else {
            url = "https://" + "\(_url):\(port)"
        }
        
        if _email != nil {
            if _email != "" {
                email = _email!
                if !email.udIsValidEmail() {
                    startBlock(false, "emailError")
                    return
                }
            }
        }
        
        if _urlToSendFile != nil {
            if _urlToSendFile != "" {
                guard isValidSite(path: _urlToSendFile!) else {
                    startBlock(false, "urlToSendFileError")
                    return
                }
                if isExistProtocol(url: _urlToSendFile!) {
                    urlToSendFile = _urlToSendFile!
                } else {
                    urlToSendFile = "https://" + _urlToSendFile!
                }
            }
        }
        
        if _knowledgeBaseID != nil {
            knowledgeBaseID = _knowledgeBaseID!
        }
        
        if _urlAPI != nil {
            if _urlAPI != "" {
                if isExistProtocol(url: _urlAPI!) {
                    urlAPI = _urlAPI!
                } else {
                    urlAPI = "https://" + _urlAPI!
                }
                guard isValidSite(path: urlAPI) else {
                    startBlock(false, "urlAPIError")
                    return
                }
            }
        }
        
        if _name != nil {
            if _name != "" {
                name = _name!
            }
        }
        if _operatorName != nil {
            if _operatorName != "" {
                operatorName = _operatorName!
            }
        }
        if _phone != nil {
            if _phone != "" {
                phone = _phone!
            }
        }
        if _nameChat != nil {
            if _nameChat != "" {
                nameChat = _nameChat!
            } else {
                nameChat = stringFor("OnlineChat")
            }
        } else {
            nameChat = stringFor("OnlineChat")
        }
        if _firstMessage != nil {
            if _firstMessage != "" {
                firstMessage = _firstMessage!
            }
        }
        if _note != nil {
            if _note != "" {
                note = _note!
            }
        }
        if _signature != nil {
            if _signature != "" {
                if !_signature!.udIsValidSignature() {
                    startBlock(false, "signatureError")
                    return
                }
                signature = _signature!
            }
        }
//        if _additional_id != nil {
//            if _additional_id != "" {
//                additional_id = _additional_id!
//            }
//        }
        // validation
        guard isValidPhone(phone: phone) || phone == "" else {
            startBlock(false, "phoneError")
            return
        }
        
        let urlAdress = URL(string: url)
        guard urlAdress != nil else {
            startBlock(false, "urlError")
            return
        }
        let config = ["log": true]
        manager = SocketManager(socketURL: urlAdress!, config: config)
        
        socket = manager?.defaultSocket

        socket?.connect()
        
        socket?.on("connect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            print("socket connected")
            let token = wSelf.signature != "" ? wSelf.signature : wSelf.loadToken()
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.companyID, chanelId: wSelf.chanelId, email: wSelf.email, phone: wSelf.phone, name: wSelf.name, url: wSelf.url, token: token)
            wSelf.socket?.emit("dispatch", with: arrConfStart!)
        })
        
        socket?.on("error", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            if (wSelf.errorBlock != nil) {
                wSelf.errorBlock!(data)
                if !isAuthInited {
                    startBlock(false, "false inited")
                }
            }
        })
        socket?.on("disconnect", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            print("socket disconnect")
            let token = wSelf.signature != "" ? wSelf.signature : wSelf.loadToken()
            let arrConfStart = UseDeskSDKHelp.config_CompanyID(wSelf.companyID, chanelId: wSelf.chanelId, email: wSelf.email, phone: wSelf.phone, name: wSelf.name, url: wSelf.url, token: token)
            wSelf.socket?.emit("dispatch", with: arrConfStart!)
        })
        
        socket?.on("dispatch", callback: { [weak self] data, ack in
            guard let wSelf = self else {return}
            if data.count == 0 {
                return
            }
            
            wSelf.action_INITED(data)
            
            let no_operators = wSelf.action_INITED_no_operators(data)
            
            wSelf.action_INITED_callback_settings(data)
            
            if no_operators || wSelf.callbackSettings.type == .always {
                startBlock(false, "feedback_form")
            } else if wSelf.callbackSettings.type == .always_and_chat && !isBeforeFeedbackForm {
                startBlock(false, "feedback_form_and_chat")
            } else {
                let auth_success = wSelf.action_ADD_INIT(data)
                
                if auth_success {
                    if wSelf.firstMessage != "" {
                        let id = wSelf.newIdLoadingMessages()
                        wSelf.idLoadingMessages.append(id)
                        wSelf.sendMessage(wSelf.firstMessage, messageId: id)
                        wSelf.firstMessage = ""
                    }
                    isAuthInited = true
                    startBlock(auth_success, "")
                }
                
                wSelf.action_Feedback_Answer(data)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    wSelf.action_ADD_MESSAGE(data)
                }
            }
        })
    }
    
    @objc public func getCollections(connectionStatus baseBlock: @escaping UDSBaseBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/support/\(self.knowledgeBaseID)/list?api_token=\(self.api_token)"
            AF.request(url).responseJSON{  responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    guard let collections = UDBaseCollection.getArray(from: value) else {
                        baseBlock(false, nil, "error parsing")
                        return }
                    baseBlock(true, collections, "")
                case .failure(let error):
                    baseBlock(false, nil, error.localizedDescription)
                }
            }
        } else {
            baseBlock(false, nil, "You did not specify knowledgeBaseID")
        }
    }
    
    @objc public func getArticle(articleID: Int, connectionStatus baseBlock: @escaping UDSArticleBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/support/\(self.knowledgeBaseID)/articles/\(articleID)?api_token=\(self.api_token)"
            AF.request(url).responseJSON{ responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    guard let article = UDArticle.get(from: value) else {
                        baseBlock(false, nil, "error parsing")
                        return }
                    baseBlock(true, article, "")
                case .failure(let error):
                    baseBlock(false, nil, error.localizedDescription)
                }
            }
        } else {
            baseBlock(false, nil, "You did not specify knowledgeBaseID")
        }
    }
    
    @objc public func addViewsArticle(articleID: Int, count: Int, connectionStatus connectBlock: @escaping UDSConnectBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/support/\(self.knowledgeBaseID)/articles/\(articleID)/add-views?api_token=\(self.api_token)&count=\(count)"
            AF.request(url).responseJSON{ responseJSON in
                switch responseJSON.result {
                case .success( _):
                    connectBlock(true, "")
                case .failure(let error):
                    connectBlock(false, error.localizedDescription)
                }
            }
        } else {
            connectBlock(false, "You did not specify knowledgeBaseID")
        }
    }
    
    @objc public func addReviewArticle(articleID: Int, countPositiv: Int = 0, countNegativ: Int = 0, connectionStatus connectBlock: @escaping UDSConnectBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/support/\(self.knowledgeBaseID)/articles/\(articleID)/change-rating?api_token=\(self.api_token)"
            url += countPositiv > 0 ? "&count_positive=\(countPositiv)" : ""
            url += countNegativ > 0 ? "&count_negative=\(countNegativ)" : ""
            AF.request(url).responseJSON{ responseJSON in
                switch responseJSON.result {
                case .success( _):
                    connectBlock(true, "")
                case .failure(let error):
                    connectBlock(false, error.localizedDescription)
                }
            }
        } else {
            connectBlock(false, "You did not specify knowledgeBaseID")
        }
    }
    
    @objc public func sendReviewArticleMesssage(articleID: Int, message: String, connectionStatus connectBlock: @escaping UDSConnectBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/create/ticket?api_token=\(self.api_token)"
            var parameters = [
                "subject" : stringFor("ArticleReviewForSubject"),
                "message" : message + "\n" + "id \(articleID)",
                "tag" : stringFor("KnowlengeBaseTag"),
                "client_email" : email
            ]
            if name != "" {
                parameters["client_name"] = name
            }
            AF.request(url, method: .post, parameters: parameters).responseJSON{ responseJSON in
                switch responseJSON.result {
                case .success( _):
                    connectBlock(true, "")
                case .failure(let error):
                    connectBlock(false, error.localizedDescription)
                }
            }
        } else {
            connectBlock(false, "You did not specify knowledgeBaseID")
        }
    }
    
    @objc public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, connectionStatus searchBlock: @escaping UDSArticleSearchBlock) {
        if knowledgeBaseID != "" {
            var url = ""
            if self.urlAPI != "" {
                url += self.urlAPI + "/uapi"
            } else {
                url += "api.usedesk.ru"
            }
            url += "/support/\(knowledgeBaseID)/articles/list?api_token=\(api_token)"
            var urlForEncode = "&query=\(query)&count=\(count)&page=\(page)&short_text=\(1)"
            switch type {
            case .close:
                urlForEncode += "&type=public"
            case .open:
                urlForEncode += "&type=private"
            default:
                break
            }
            
            switch sort {
            case .id:
                urlForEncode += "&sort=id"
            case .category_id:
                urlForEncode += "&sort=category_id"
            case .created_at:
                urlForEncode += "&sort=created_at"
            case .open:
                urlForEncode += "&sort=public"
            case .title:
                urlForEncode += "&sort=title"
            default:
                break
            }
            
            switch order {
            case .asc:
                urlForEncode += "&order=asc"
            case .desc:
                urlForEncode += "&order=desc"
            default:
                break
            }
            if collection_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&collection_ids="
                for id in collection_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }
            if category_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&category_ids="
                for id in category_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }
            if article_ids.count > 0 {
                var idsStrings = ""
                urlForEncode += "&article_ids="
                for id in article_ids {
                    if idsStrings == "" {
                        idsStrings += "\(id)"
                    } else {
                        idsStrings += ",\(id)"
                    }
                }
                urlForEncode += idsStrings
            }

            let escapedUrl = urlForEncode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            url += escapedUrl ?? ""
            AF.request(url).responseJSON{ responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    guard let articles = UDSearchArticle(from: value) else {
                        searchBlock(false, nil, "error parsing")
                        return }
                    searchBlock(true, articles, "")
                case .failure(let error):
                    searchBlock(false, nil, error.localizedDescription)
                }
            }
        } else {
            searchBlock(false, nil, "You did not specify knowledgeBaseID")
        }
        
    }
    
    func sendOfflineForm(name nameClient: String?, email emailClient: String?, message: String, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, callback resultBlock: @escaping UDSStartBlock) {
        var param = [
            "company_id" : companyID,
            "message" : message
        ]
        param["name"] = nameClient != nil ? nameClient : name
        param["email"] = emailClient != nil ? emailClient : email
        
        if topic != nil {
            if topic != "" {
                param["topic"] = topic!
            }
        }
        
        if fields != nil {
            for field in fields! {
                param[field.title] = field.text
            }
        }
        
        let urlStr = "https://secure.usedesk.ru/widget.js/post"
        AF.request(urlStr, method: .post, parameters: param as Parameters, encoding: JSONEncoding.default).responseJSON{ responseJSON in
            switch responseJSON.result {
            case .success( _):
                resultBlock(true, nil)
            case .failure(let error):
                resultBlock(false, error.localizedDescription)
            }
        }
    }
    
    func action_INITED(_ data: [Any]?) {
        let dicServer = data?[0] as? [AnyHashable : Any]
        
        if dicServer?["token"] != nil && signature == "" {
            token = dicServer?["token"] as? String ?? ""
            save(token: token)
        }
        
        let setup = dicServer?["setup"] as? [AnyHashable : Any]
        
        if setup != nil {
            let messages = setup?["messages"] as? [Any]
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
                                let down = Down(markdownString: text)
                                if let attributedString = try? down.toAttributedString() {
                                    mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                                    mutableAttributedString!.mutableString.replaceCharacters(in: NSRange(location: mutableAttributedString!.length - 1, length: 1), with: "")
                                }
                            }
                        }
                        if (message["file"] as? [AnyHashable : Any] ) != nil {
                            messageFile = parseFileMessageDic(message)
                        }
                        m = parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, attributedString: mutableAttributedString)
                    }
                    if m != nil {
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
            socket?.emit("dispatch", with: UseDeskSDKHelp.dataClient(email, phone: phone, name: name, note: note, signature: signature)!)
        }
    }
    
    func parseFileMessageDic(_ mess: [AnyHashable : Any]?, withImageUrl imageUrl: String? = nil) -> UDMessage? {
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
        if mess?["id"] != nil {
            m.messageId = Int(mess?["id"] as? Int ?? 0)
        }
        if let type = mess?["type"] as? String {
            m.typeSenderMessageString = type
        }
        m.incoming = (m.typeSenderMessage == .operator_to_client || m.typeSenderMessage == .bot_to_client) ? true : false
        m.outgoing = !m.incoming
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
                m.type = RC_TYPE_PICTURE
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
            m.file = file
            m.status = RC_STATUS_LOADING
            var type = ""
            if (fileDic?["file_name"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["file_name"] as? String ?? "")?.pathExtension ?? ""
            }
            if (fileDic?["fullLink"] as? String ?? "") != "" {
                type = URL.init(string: fileDic?["fullLink"] as? String ?? "")?.pathExtension ?? ""
            }
            if file.type.contains("image") || isImage(of: type) {
                m.type = RC_TYPE_PICTURE
            } else if file.type.contains("video") || isVideo(of: type) {
                m.type = RC_TYPE_VIDEO
                m.file.typeExtension = type
                file.type = "video"
            } else {
                m.type = RC_TYPE_File
            }
        } else {
            return nil
        }
        return m
    }
    
    func parseMessageDic(_ mess: [AnyHashable : Any]?, textWithoutLinkImage: String? = nil, attributedString: NSMutableAttributedString? = nil) -> UDMessage? {
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
        if mess?["id"] != nil {
            m.messageId = Int(mess?["id"] as? Int ?? 0)
        }
        if let type = mess?["type"] as? String {
            m.typeSenderMessageString = type
        }
        m.incoming = (m.typeSenderMessage == .operator_to_client || m.typeSenderMessage == .bot_to_client) ? true : false
        m.outgoing = !m.incoming
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
                let rsButton = buttonFromString(stringButton: stringFromButton)
                if rsButton != nil {
                    m.buttons.append(rsButton!)
                }
                if m.attributedString != nil {
                    m.attributedString!.mutableString.replaceOccurrences(of: stringFromButton, with: "", options: .caseInsensitive, range: NSRange(location: 0, length: m.attributedString!.length))
                } else {
                    m.text = m.text.replacingOccurrences(of: stringFromButton, with: "")
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
                m.type = RC_TYPE_Feedback
            }
            if let userRating = payload["userRating"] as? String {
                m.type = RC_TYPE_Feedback
                if userRating == "LIKE" {
                    m.feedbackActionInt = 1
                    m.text = stringFor("CSIReviewLike")
                }
                if userRating == "DISLIKE" {
                    m.feedbackActionInt = 0
                    m.text = stringFor("CSIReviewDislike")
                }
            }
            if payload["message_id"] != nil {
                m.loadingMessageId = payload["message_id"] as? String ?? ""
            }
        }
        return m
    }
    
    func parseMessageFromButtons(text: String) -> [String] {
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
    
    func buttonFromString(stringButton: String) -> UDMessageButton? {
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
    
    func action_INITED_callback_settings(_ data: [Any]?) {
        let dicServer = data?[0] as? [AnyHashable : Any]

        let setup = dicServer?["setup"] as? [AnyHashable : Any]
        if setup != nil {
            if let callback_settings = setup!["callback_settings"] as? [AnyHashable : Any] {
                callbackSettings = UDCallbackSettings()
                if let work_type = callback_settings["work_type"] as? String {
                    callbackSettings.typeString = work_type
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
                    for custom_fieldItem in custom_fields {
                        if let custom_field = custom_fieldItem as? [String : Any] {
                            let сallbackCustomField = UDCallbackCustomField()
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
            }
        }

    }
    
    func action_INITED_no_operators(_ data: [Any]?) -> Bool {
        let dicServer = data?[0] as? [AnyHashable : Any]
        
        if dicServer?["token"] != nil && signature == "" {
            token = dicServer?["token"] as? String ?? ""
            save(token: token)
        }

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
    
    func action_ADD_INIT(_ data: [Any]?) -> Bool {
        
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
    
    func action_Feedback_Answer(_ data: [Any]?) {
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
    
    func action_ADD_MESSAGE(_ data: [Any]?) {
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
                    let down = Down(markdownString: text)
                    if let attributedString = try? down.toAttributedString() {
                        mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                        mutableAttributedString!.mutableString.replaceCharacters(in: NSRange(location: mutableAttributedString!.length - 1, length: 1), with: "")
                    }
                }
            }
            if (message!["file"] as? [AnyHashable : Any] ) != nil {
                messageFile = parseFileMessageDic(message)
            }
            m = parseMessageDic(message, textWithoutLinkImage: textWithoutLinkImage, attributedString: mutableAttributedString)
            
            if m != nil {
                if m?.type == RC_TYPE_Feedback && (feedbackMessageBlock != nil) {
                    feedbackMessageBlock!(m)
                    return
                } else {
                    if newMessageBlock != nil {
                        newMessageBlock!(true, m)
                    }
                }
            }
            if messageFile != nil {
                newMessageBlock!(true, messageFile!)
            }
            for m in messagesImageLink {
                newMessageBlock!(true, m)
            }
        }
    }
    
    @objc public func sendMessageFeedBack(_ status: Bool, message_id: Int) {
        socket?.emit("dispatch", with: UseDeskSDKHelp.feedback(status, message_id: message_id)!)
    }
    
    func stringFor(_ key: String) -> String {
        if let word = locale[key] {
            return word
        } else {
            let ruLocal = UDLocalizeManager().getLocaleFor(localeId: "ru") ?? [:]
            return ruLocal[key] ?? ""
        }
    }
    
    func save(token: String) {
        UserDefaults.standard.set(token, forKey: "usedeskTokenClient")
    }
    
    func loadToken() -> String? {
        return UserDefaults.standard.string(forKey: "usedeskTokenClient")
    }
    
    func isImage(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["gif", "xbm", "jpeg", "jpg", "pct", "bmpf", "ico", "tif", "tiff", "cur", "bmp", "png"]
        return typesImage.contains(typeLowercased)
    }
    
    func isVideo(of type: String) -> Bool {
        let typeLowercased = type.lowercased()
        let typesImage = ["mpeg", "mp4", "webm", "quicktime", "ogg", "mov", "mpe", "mpg", "mvc", "flv", "avi", "3g2", "3gp2", "vfw", "mpg", "mpeg"]
        return typesImage.contains(typeLowercased)
    }
    
    private func isValidSite(path: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: path)
    }
    
    func isValidPhone(phone:String) -> Bool {
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
    
    private func isExistProtocol(url: String) -> Bool {
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
    
    @objc public func closeChat() {
        dialogflowVC = DialogflowView()
        offlineVC = UDOfflineForm()
        socket?.disconnect()
        historyMess = []
    }
    
    @objc public func releaseChat() {
        dialogflowVC = DialogflowView()
        offlineVC = UDOfflineForm()
        idLoadingMessages = []
        socket?.disconnect()
        historyMess = []
        companyID = ""
        chanelId = ""
        email = ""
        phone = ""
        url = ""
        urlToSendFile = ""
        urlWithoutPort = ""
        urlAPI = ""
        knowledgeBaseID = ""
        api_token = ""
        port = ""
        name = ""
        operatorName = ""
        nameChat = ""
        firstMessage = ""
        note = ""
        signature = ""
        isOpenSDKUI = false
    }
    
    public func newIdLoadingMessages() -> String {
        var count = 89000
        var id = Int.random(in: 1..<90000)
        while idLoadingMessages.contains(String(id)) && count > 0 {
            count -= 1
            id = Int.random(in: 1..<90000)
        }
        return String(id)
    }
    
}

class UDLoader: NSObject {
    var loader = UIActivityIndicatorView()
    var view: UIView!
    var backView = UIView()
    var alphaBackView: CGFloat!
    var colorBackView: UIColor!
    
    public init(view: UIView, colorBackView: UIColor, alphaBackView: CGFloat) {
        self.view = view
        self.alphaBackView = alphaBackView
        self.colorBackView = colorBackView
    }
    
    func show() {
        if #available(iOS 13.0, *) {
            loader.style = .large
        } else {
            loader.style = .whiteLarge
        }
        loader.startAnimating()
        loader.alpha = 7
        backView.backgroundColor = colorBackView
        backView.alpha = alphaBackView
        backView.clipsToBounds = true
        backView.frame.size = CGSize(width: 50, height: 50)
        backView.center = view.center
        backView.layer.cornerRadius = 25
        view.addSubview(backView)
        backView.addSubview(loader)
        loader.center = CGPoint(x: 26.5, y: 26.5)
    }
    
    func hide(animated: Bool = false) {
        loader.stopAnimating()
        loader.alpha = 0
        backView.removeFromSuperview()
        backView.alpha = 0
    }
}
