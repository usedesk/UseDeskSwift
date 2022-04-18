//
//  UseDeskSDK.swift

import Foundation
import SocketIO
import UserNotifications
import Reachability

public class UseDeskSDK: NSObject, UDUISetupable {
    @objc public var newMessageBlock: UDSNewMessageBlock?
    @objc public var newMessageWithGUIBlock: UDSNewMessageBlock?
    @objc public var connectBlock: UDSConnectBlock?
    @objc public var feedbackMessageBlock: UDSFeedbackMessageBlock?
    @objc public var feedbackAnswerMessageBlock: UDSFeedbackAnswerMessageBlock?
    @objc public var presentationCompletionBlock: UDSVoidBlock?
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
    // closure StartBlock
    var closureStartBlock: UDSStartBlock? = nil
    var closureErrorBlock: UDSErrorBlock? = nil
    // Storage
    var storage: UDStorage? = nil
    var isCacheMessagesWithFile: Bool = true
    // UIManager
    var uiManager: UDUIProtocole?
    // Configutation
    var model = UseDeskModel() {
        didSet {
            networkManager?.model = model
        }
    }
    // Network
    var networkManager: UDNetworkManager? = nil
    
    
    private var isStartWithDefaultGUI = false
    private var reachability: Reachability?
    
    // MARK: - Start Methods
    @objc public func start(withCompanyID companyID: String, chanelId: String, urlAPI: String? = nil, knowledgeBaseID: String? = nil, api_token: String? = nil, email: String? = nil, phone: String? = nil, url: String, urlToSendFile: String? = nil, port: String? = nil, name: String? = nil, operatorName: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], additional_id: String? = nil, token: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, storage storageOutside: UDStorage? = nil, isCacheMessagesWithFile: Bool = true, isSaveTokensInUserDefaults: Bool = true, presentIn parentController: UIViewController? = nil, isPresentDefaultControllers: Bool = true, connectionStatus startBlock: @escaping UDSStartBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        
        guard !isOpenSDKUI || !isPresentDefaultControllers else {
            errorBlock(.initChatWhenChatOpenError, "")
            return
        }
        
        closureStartBlock = startBlock
        closureErrorBlock = errorBlock
        isStartWithDefaultGUI = true

        model = UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, urlAPI: urlAPI, knowledgeBaseID: knowledgeBaseID, api_token: api_token, email: email, phone: phone, url: url, urlToSendFile: urlToSendFile, port: port, name: name, operatorName: operatorName, nameChat: nameChat, firstMessage: firstMessage, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, additional_id: additional_id, token: token, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, isPresentDefaultControllers: isPresentDefaultControllers, errorStatus: errorBlock) ?? UseDeskModel()
        
        storage = storageOutside != nil ? storageOutside : UDStorageMessages(token: model.token)
        self.isCacheMessagesWithFile = isCacheMessagesWithFile
        
        networkManager = UDNetworkManager(model: model)
        setupUI()
        
        isOpenSDKUI = true
        if model.isOpenKnowledgeBase {
            if model.isPresentDefaultControllers {
                uiManager?.showBaseView(in: parentController, url: url)
            }
        } else {
            if model.isPresentDefaultControllers {
                uiManager?.startDialogFlow(in: parentController)
            }
            startWithoutGUICompanyID(companyID: companyID, chanelId: chanelId, knowledgeBaseID: knowledgeBaseID, api_token: api_token, email: email, phone: phone, url: model.urlWithoutPort, port: port, name: name, operatorName: operatorName, nameChat: nameChat, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields) { [weak self] success, feedbackStatus, token in
                guard let wSelf = self else { return }
                startBlock(success, feedbackStatus, token)
                wSelf.uiManager?.reloadDialogFlow(success: success, feedBackStatus: feedbackStatus, url: wSelf.model.url)
            } errorStatus: { [weak self] error, description in
                guard let wSelf = self else { return }
                errorBlock(error, description)
                wSelf.closureErrorBlock?(error, description)
            }
        }
        setNetworkTracking()
    }
    
    @objc public func startWithoutGUICompanyID(companyID: String, chanelId: String, urlAPI: String? = nil, knowledgeBaseID: String? = nil, api_token: String? = nil, email: String? = nil, phone: String? = nil, url: String, urlToSendFile: String? = nil, port: String? = nil, name: String? = nil, operatorName: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, note: String? = nil, additional_id: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], token: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isSaveTokensInUserDefaults: Bool = true, connectionStatus startBlock: @escaping UDSStartBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        
        if !isStartWithDefaultGUI {
            model = UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, urlAPI: urlAPI, knowledgeBaseID: knowledgeBaseID, api_token: api_token, email: email, phone: phone, url: url, urlToSendFile: urlToSendFile, port: port, name: name, operatorName: operatorName, nameChat: nameChat, firstMessage: firstMessage, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, additional_id: additional_id, token: token, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, errorStatus: errorBlock) ?? UseDeskModel()
        }
        
        let urlAdress = URL(string: model.url)
        guard urlAdress != nil else {
            errorBlock(.urlError, UDError.urlError.description)
            return
        }
        
        var isNeedLogSocket = false
        #if DEBUG
            isNeedLogSocket = true
        #endif
        manager = SocketManager(socketURL: urlAdress!, config: [.log(isNeedLogSocket), .version(.three)])
        socket = manager?.defaultSocket

        if networkManager == nil {
            networkManager = UDNetworkManager(model: model)
        }
        networkManager?.model = model
        networkManager?.socket = socket
        
        networkManager?.socketConnect(socket: socket, connectBlock: connectBlock)
        networkManager?.socketError(socket: socket, errorBlock: errorBlock)
        networkManager?.socketDisconnect(socket: socket, connectBlock: connectBlock)
        networkManager?.socketDispatch(socket: socket, startBlock: { [weak self] success, feedbackstatus, error in
            startBlock(success, feedbackstatus, error)
            self?.connectBlock?(true)
        }, historyMessagesBlock: { [weak self] messages in
            self?.historyMess = messages
        }, callbackSettingsBlock: { [weak self] callbackSettings in
            self?.callbackSettings = callbackSettings
        }, newMessageBlock: { [weak self] message in
            self?.newMessageBlock?(message)
            self?.newMessageWithGUIBlock?(message)
        }, feedbackMessageBlock: { [weak self] message in
            self?.feedbackMessageBlock?(message)
        }, feedbackAnswerMessageBlock: { [weak self] bool in
            self?.feedbackAnswerMessageBlock?(bool)
        })
    }
    
    // MARK: - Public Methods
    @objc public func sendMessage(_ text: String, messageId: String? = nil) {
        let mess = UseDeskSDKHelp.messageText(text, messageId: messageId)
        socket?.emit("dispatch", with: mess!, completion: nil)
    }
    
    @objc public func sendFile(fileName: String, data: Data, messageId: String? = nil, progressBlock: UDSProgressUploadBlock? = nil, connectBlock: @escaping UDSConnectBlock, errorBlock: @escaping UDSErrorBlock) {
        let url = model.urlToSendFile != "" ? model.urlToSendFile : "https://secure.usedesk.ru/uapi/v1/send_file"
        networkManager?.sendFile(url: url, fileName: fileName, data: data, messageId: messageId, progressBlock: progressBlock, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    private func sendAdditionalFields(fields: [Int : String], nestedFields: [[Int : String]]) {
        networkManager?.sendAdditionalFields()
    }
    
    @objc public func getCollections(connectionStatus baseBlock: @escaping UDSBaseBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.getCollections(baseBlock: baseBlock, errorBlock: errorBlock)
    }
    
    @objc public func getArticle(articleID: Int, connectionStatus baseBlock: @escaping UDSArticleBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.getArticle(articleID: articleID, baseBlock: baseBlock, errorBlock: errorBlock)
    }
    
    @objc public func addViewsArticle(articleID: Int, count: Int, connectionStatus connectBlock: @escaping UDSConnectBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.addViewsArticle(articleID: articleID, count: count, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func addReviewArticle(articleID: Int, countPositiv: Int = 0, countNegativ: Int = 0, connectionStatus connectBlock: @escaping UDSConnectBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.addReviewArticle(articleID: articleID, countPositiv: countPositiv, countNegativ: countNegativ, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func sendReviewArticleMesssage(articleID: Int, message: String, connectionStatus connectBlock: @escaping UDSConnectBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.sendReviewArticleMesssage(articleID: articleID, subject: model.stringFor("ArticleReviewForSubject"), message: message, tag: model.stringFor("KnowlengeBaseTag"), email: model.email, name: model.name, connectionStatus: connectBlock, errorStatus:errorBlock)
    }
    
    @objc public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, connectionStatus searchBlock: @escaping UDSArticleSearchBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.getSearchArticles(collection_ids: collection_ids, category_ids: category_ids, article_ids: article_ids, count: count, page: page, query: query, type: type, sort: sort, order: order, searchBlock: searchBlock, errorBlock: errorBlock)
    }
    
    func sendOfflineForm(name nameClient: String?, email emailClient: String?, message: String, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, callback resultBlock: @escaping UDSConnectBlock, errorStatus errorBlock: @escaping UDSErrorBlock) {
        networkManager?.sendOfflineForm(companyID: model.companyID, chanelID: model.chanelId, name: nameClient ?? model.name, email: emailClient ?? model.email, message: message, topic: topic, fields: fields, connectBlock: resultBlock, errorBlock: errorBlock)
    }
    
    @objc public func sendMessageFeedBack(_ status: Bool, message_id: Int) {
        socket?.emit("dispatch", with: UseDeskSDKHelp.feedback(status, message_id: message_id)!, completion: nil)
    }
    
    @objc public func chatViewController() -> UIViewController? {
        return uiManager?.chatViewController()
    }
    
    @objc public func closeChat() {
        uiManager?.resetUI()
        socket?.disconnect()
        historyMess = []
    }
    
    @objc public func releaseChat() {
        uiManager?.resetUI()
        socket?.disconnect()
        historyMess = []
        model = UseDeskModel()
        networkManager = nil
        isOpenSDKUI = false
        presentationCompletionBlock?()
    }
    
    // MARK: - Ppivate Methods
    func setNetworkTracking() {
        reachability = try! Reachability()
        reachability?.whenReachable = { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.uiManager?.closeNoInternet()
        }
        reachability?.whenUnreachable = { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.uiManager?.showNoInternet()
        }
        do {
            try reachability?.startNotifier()
        } catch {}
    }
}
