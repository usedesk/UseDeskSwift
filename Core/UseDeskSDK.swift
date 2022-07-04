//
//  UseDeskSDK.swift

import Foundation
import SocketIO
import UserNotifications
import Reachability

public class UseDeskSDK: NSObject {
    @objc public var newMessageBlock: UDNewMessageBlock?
    @objc public var newMessageWithGUIBlock: UDNewMessageBlock?
    @objc public var connectBlock: UDConnectBlock?
    @objc public var feedbackMessageBlock: UDFeedbackMessageBlock?
    @objc public var feedbackAnswerMessageBlock: UDFeedbackAnswerMessageBlock?
    @objc public var presentationCompletionBlock: UDVoidBlock?
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
    var closureStartBlock: UDStartBlock? = nil
    var closureErrorBlock: UDErrorBlock? = nil
    // Storage
    var storage: UDStorage? = nil
    var isCacheMessagesWithFile: Bool = true
    // UIManager
    var uiManager: UDUIProtocole? = nil
    // Reachability
    var reachability: Reachability?
    // Configutation
    var model = UseDeskModel() {
        didSet {
            networkManager?.model = model
        }
    }
    // Network
    var networkManager: UDNetworkManager? = nil
    
    private var isStartWithDefaultGUI = false
    
    
    // MARK: - Start Methods
    
    // Start with GUI, chat and knowledgeBase
    @objc public func start(withCompanyID companyID: String, chanelId: String, url: String, port: String? = nil, urlAPI: String? = nil, api_token: String? = nil, urlToSendFile: String? = nil, knowledgeBaseID: String? = nil, knowledgeBaseSectionId: NSNumber? = nil, knowledgeBaseCategoryId: NSNumber? = nil, knowledgeBaseArticleId: NSNumber? = nil, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: Data? = nil, token: String? = nil, additional_id: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], nameOperator: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, countMessagesOnInit: NSNumber? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, storage storageOutside: UDStorage? = nil, isCacheMessagesWithFile: Bool = true, isSaveTokensInUserDefaults: Bool = true, isPresentDefaultControllers: Bool = true, presentIn parentController: UIViewController? = nil, connectionStatus startBlock: @escaping UDStartBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        guard !isOpenSDKUI else {
            errorBlock(.initChatWhenChatOpenError, "")
            return
        }
        closureStartBlock = startBlock
        closureErrorBlock = errorBlock
        isStartWithDefaultGUI = true

        UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, url: url, port: port, urlAPI: urlAPI, api_token: api_token, urlToSendFile: urlToSendFile, knowledgeBaseID: knowledgeBaseID, knowledgeBaseSectionId: knowledgeBaseSectionId, knowledgeBaseCategoryId: knowledgeBaseCategoryId, knowledgeBaseArticleId: knowledgeBaseArticleId, name: name, email: email, phone: phone, avatar: avatar, token: token, additional_id: additional_id, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, nameOperator: nameOperator, nameChat: nameChat, firstMessage: firstMessage, countMessagesOnInit: countMessagesOnInit, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, isPresentDefaultControllers: isPresentDefaultControllers, validModelBlock: { [weak self] validModel in
            self?.model = validModel
            self?.startWithGUI(storageOutside: storageOutside, isCacheMessagesWithFile: isCacheMessagesWithFile, parentController: parentController, startBlock: startBlock, errorBlock: errorBlock)
        }, errorStatus: errorBlock)
        
    }
    // Start with GUI, only knowledgeBase
    @objc public func startKnowledgeBase(urlAPI: String? = nil, api_token: String? = nil, knowledgeBaseID: String? = nil, knowledgeBaseSectionId: NSNumber? = nil, knowledgeBaseCategoryId: NSNumber? = nil, knowledgeBaseArticleId: NSNumber? = nil, name: String? = nil, email: String? = nil, phone: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isPresentDefaultControllers: Bool = true, presentIn parentController: UIViewController? = nil, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        guard !isOpenSDKUI else {
            errorBlock(.initChatWhenChatOpenError, "")
            return
        }
        
        UDValidationManager.validateInitionalsFields(urlAPI: urlAPI, api_token: api_token, knowledgeBaseID: knowledgeBaseID, knowledgeBaseSectionId: knowledgeBaseSectionId, knowledgeBaseCategoryId: knowledgeBaseCategoryId, knowledgeBaseArticleId: knowledgeBaseArticleId, name: name, email: email, phone: phone, localeIdentifier: localeIdentifier, customLocale: customLocale, isPresentDefaultControllers: isPresentDefaultControllers, isOnlyKnowledgeBase: true, validModelBlock: { [weak self] validModel in
            self?.model = validModel
            self?.startOnlyKnowledgeBase(parentController: parentController, connectBlock: connectBlock)
        }, errorStatus: errorBlock)
    }
    // Start without GUI, chat and knowledgeBase
    @objc public func startWithoutGUICompanyID(companyID: String, chanelId: String, url: String, port: String? = nil, urlAPI: String? = nil, api_token: String? = nil, urlToSendFile: String? = nil, knowledgeBaseID: String? = nil, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: Data? = nil, token: String? = nil, additional_id: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], firstMessage: String? = nil, countMessagesOnInit: NSNumber? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isSaveTokensInUserDefaults: Bool = true, connectionStatus startBlock: @escaping UDStartBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        
        if !isStartWithDefaultGUI {
            UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, url: url, port: port, urlAPI: urlAPI, api_token: api_token, urlToSendFile: urlToSendFile, knowledgeBaseID: knowledgeBaseID, name: name, email: email, phone: phone, avatar: avatar, token: token, additional_id: additional_id, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, firstMessage: firstMessage, countMessagesOnInit: countMessagesOnInit, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, validModelBlock: { [weak self] validModel in
                self?.model = validModel
                self?.startWithuotGUI(startBlock: startBlock, errorBlock: errorBlock)
            }, errorStatus: errorBlock)
        } else {
            startWithuotGUI(startBlock: startBlock, errorBlock: errorBlock)
        }
    }
    
    // MARK: - Public Methods
    @objc public func sendAvatarClient(avatarData: Data, connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendAvatarClient(avatarData: avatarData, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func getMessages(idComment: Int, newMessagesBlock: @escaping UDNewMessagesBlock, errorBlock: @escaping UDErrorBlock) {
        networkManager?.getMessages(idComment: idComment, newMessagesBlock: newMessagesBlock, errorBlock: errorBlock)
    }
    
    @objc public func sendMessage(_ text: String, messageId: String? = nil) {
        let mess = UseDeskSDKHelp.messageText(text, messageId: messageId)
        socket?.emit("dispatch", with: mess!, completion: nil)
    }
    
    @objc public func sendFile(fileName: String, data: Data, messageId: String? = nil, progressBlock: UDProgressUploadBlock? = nil, connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        let url = model.urlToSendFile != "" ? model.urlToSendFile : "https://secure.usedesk.ru/uapi/v1/send_file"
        networkManager?.sendFile(url: url, fileName: fileName, data: data, messageId: messageId, progressBlock: progressBlock, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func getCollections(connectionStatus baseBlock: @escaping UDBaseBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getCollections(baseBlock: baseBlock, errorBlock: errorBlock)
    }
    
    @objc public func getArticle(articleID: Int, connectionStatus baseBlock: @escaping UDArticleBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getArticle(articleID: articleID, baseBlock: baseBlock, errorBlock: errorBlock)
    }
    
    @objc public func addViewsArticle(articleID: Int, count: Int, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.addViewsArticle(articleID: articleID, count: count, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func addReviewArticle(articleID: Int, countPositive: Int = 0, countNegative: Int = 0, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.addReviewArticle(articleID: articleID, countPositive: countPositive, countNegative: countNegative, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    @objc public func sendReviewArticleMesssage(articleID: Int, message: String, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendReviewArticleMesssage(articleID: articleID, subject: model.stringFor("ArticleReviewForSubject"), message: message, tag: model.stringFor("KnowlengeBaseTag"), email: model.email, phone: model.phone, name: model.name, connectionStatus: connectBlock, errorStatus:errorBlock)
    }
    
    @objc public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, connectionStatus searchBlock: @escaping UDArticleSearchBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getSearchArticles(collection_ids: collection_ids, category_ids: category_ids, article_ids: article_ids, count: count, page: page, query: query, type: type, sort: sort, order: order, searchBlock: searchBlock, errorBlock: errorBlock)
    }
    
    func sendOfflineForm(name nameClient: String?, email emailClient: String?, message: String, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, callback resultBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendOfflineForm(companyID: model.companyID, chanelID: model.chanelId, name: nameClient ?? model.name, email: emailClient ?? model.email, message: message, topic: topic, fields: fields, connectBlock: resultBlock, errorBlock: errorBlock)
    }
    
    @objc public func sendMessageFeedBack(_ status: Bool, message_id: Int) {
        socket?.emit("dispatch", with: UseDeskSDKHelp.feedback(status, message_id: message_id)!, completion: nil)
    }
    
    @objc public func chatViewController() -> UIViewController? {
        return uiManager?.chatViewController()
    }
    
    @objc public func baseNavigationController() -> UIViewController? {
        return uiManager?.baseNavigationController()
    }
    
    @objc public func closeChat() {
        uiManager?.resetUI()
        socket?.disconnect()
        historyMess = []
    }
    
    @objc public func releaseChat() {
        uiManager?.resetUI()
        networkManager = nil
        socket?.disconnect()
        socket = nil
        manager = nil
        historyMess = []
        model = UseDeskModel()
        isOpenSDKUI = false
        presentationCompletionBlock?()
    }
    
    // MARK: - Ppivate Methods
    private func startWithGUI(storageOutside: UDStorage? = nil, isCacheMessagesWithFile: Bool = true, parentController: UIViewController? = nil, startBlock: @escaping UDStartBlock, errorBlock: @escaping UDErrorBlock) {
        self.isCacheMessagesWithFile = isCacheMessagesWithFile
        
        networkManager = UDNetworkManager(model: model)
        setupUI()
        isOpenSDKUI = true
        setNetworkTracking()
        storage = storageOutside
        
        if model.isOpenKnowledgeBase {
            startOnlyKnowledgeBase(parentController: parentController) { success in
                startBlock(success, .null, "")
            }
        } else {
            if model.isPresentDefaultControllers {
                uiManager?.startDialogFlow(in: parentController, isFromBase: false)
            }
            startWithoutGUICompanyID(companyID: model.companyID, chanelId: model.chanelId, url: model.urlWithoutPort, port: model.port, api_token: model.api_token, knowledgeBaseID: model.knowledgeBaseID, name: model.name, email: model.email, phone: model.phone, additionalFields: model.additionalFields, additionalNestedFields: model.additionalNestedFields) { [weak self] success, feedbackStatus, token in
                guard let wSelf = self else { return }
                wSelf.storage = storageOutside != nil ? storageOutside : UDStorageMessages(token: token)
                wSelf.uiManager?.reloadDialogFlow(success: success, feedBackStatus: feedbackStatus, url: wSelf.model.url)
                startBlock(success, feedbackStatus, token)
            } errorStatus: { [weak self] error, description in
                guard let wSelf = self else { return }
                errorBlock(error, description)
                wSelf.closureErrorBlock?(error, description)
            }
        }
    }
    
    private func startWithuotGUI(startBlock: @escaping UDStartBlock, errorBlock: @escaping UDErrorBlock) {
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
        networkManager?.usedesk = self
        networkManager?.model = model
        networkManager?.socket = socket
        
        networkManager?.socketConnect(socket: socket, connectBlock: connectBlock)
        networkManager?.socketError(socket: socket, errorBlock: errorBlock)
        networkManager?.socketDisconnect(socket: socket, connectBlock: connectBlock)
        networkManager?.socketDispatch(socket: socket, startBlock: { [weak self] success, feedbackstatus, token in
            startBlock(success, feedbackstatus, token)
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
    
    private func startOnlyKnowledgeBase(parentController: UIViewController? = nil, connectBlock: @escaping UDConnectBlock) {
        if networkManager == nil {
            networkManager = UDNetworkManager(model: model)
        }
        if uiManager == nil {
            setupUI()
        }
        
        if model.isPresentDefaultControllers {
            uiManager?.startBaseFlow(in: parentController)
        }
        setNetworkTracking()
        
        networkManager?.getCollections(baseBlock: { [weak self] success, baseSections in
            DispatchQueue.main.async {
                if baseSections != nil {
                    self?.model.baseSections = baseSections!
                    (self?.uiManager as? UDUIManager)?.usedesk = self
                    self?.uiManager?.reloadBaseFlow(success: success)
                    connectBlock(true)
                }
            }
        }, errorBlock: { [weak self] _, _ in
            self?.uiManager?.reloadBaseFlow(success: false)
        })
    }
    
    private func setNetworkTracking() {
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
    
    private func setupUI() {
        let uiManager = UDUIManager()
        uiManager.usedesk = self
        self.uiManager = uiManager
    }
}
