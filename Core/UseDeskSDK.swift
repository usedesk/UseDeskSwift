//
//  UseDeskSDK.swift

import Foundation
import SocketIO
import UserNotifications
import Reachability
import CoreTelephony

/// The main entry point of the UseDesk SDK.
///
/// Create a single instance, then start a session with one of the `start` methods to open the
/// built-in chat UI, run headless (without GUI), or show only the knowledge base. Customize the
/// appearance through ``configurationStyle`` before starting.

public class UseDeskSDK: NSObject {
    /// Called for every new incoming message while the built-in chat UI is shown.
    @objc public var newMessageWithGUIBlock: UDMessageBlock?
    /// Called for every new incoming message. Use only in the without-GUI mode.
    var internalNewMessageBlock: UDMessageBlock?
    /// Called whenever the socket connection state changes.
    @objc public var connectBlock: UDConnectBlock?
    /// Called when the server requests a message rating (feedback) from the user.
    @objc public var feedbackMessageBlock: UDFeedbackMessageBlock?
    /// Called when a feedback rating is acknowledged by the server.
    @objc public var feedbackAnswerMessageBlock: UDFeedbackAnswerMessageBlock?
    /// Called once the SDK finishes dismissing its UI after ``releaseChat()``.
    @objc public var presentationCompletionBlock: UDVoidBlock?
    /// The message history received from the server for the current session.
    @objc public var historyMess: [UDMessage] = []
    /// Maximum number of assets the user can attach to a single message. Defaults to `10`.
    @objc public var maxCountAssets: Int = 10
    /// Restricts the attachment picker to photos only.
    @objc public var isSupportedAttachmentOnlyPhoto: Bool = false
    /// Restricts the attachment picker to videos only.
    @objc public var isSupportedAttachmentOnlyVideo: Bool = false
    /// Visual configuration or the built-in chat UI.
    /// Set before calling a `start` method.
    public var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    /// Server-provided callback settings for the current channel.
    public var callbackSettings = UDCallbackSettings()
    /// `true` while an SDK session is active. Starting a new session while `true` returns an error.
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
    var isConnecting: Bool = false
    // Network
    var networkManager: UDNetworkManager? = nil
    
    private var isStartWithDefaultGUI = false
    
    
    // MARK: - Start Methods

    /// Starts a full session and presents the built-in chat UI (and knowledge base, if configured).
    @objc public func start(withCompanyID companyID: String, chanelId: String, url: String, port: String? = nil, urlAPI: String? = nil, api_token: String? = nil, urlToSendFile: String? = nil, knowledgeBaseID: String? = nil, knowledgeBaseSectionId: NSNumber? = nil, knowledgeBaseCategoryId: NSNumber? = nil, knowledgeBaseArticleId: NSNumber? = nil, isReturnToParentFromKnowledgeBase: Bool = false, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: Data? = nil, avatarUrl: URL? = nil, token: String? = nil, additional_id: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], nameOperator: String? = nil, nameChat: String? = nil, firstMessage: String? = nil, countMessagesOnInit: NSNumber? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, storage storageOutside: UDStorage? = nil, isCacheMessagesWithFile: Bool = true, isSaveTokensInUserDefaults: Bool = true, isPresentDefaultControllers: Bool = true, presentIn parentController: UIViewController? = nil, connectionStatus startBlock: @escaping UDStartBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        guard !isOpenSDKUI else {
            errorBlock(.initChatWhenChatOpenError, "")
            return
        }
        closureStartBlock = startBlock
        closureErrorBlock = errorBlock
        isStartWithDefaultGUI = true

        UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, url: url, port: port, urlAPI: urlAPI, api_token: api_token, urlToSendFile: urlToSendFile, knowledgeBaseID: knowledgeBaseID, knowledgeBaseSectionId: knowledgeBaseSectionId, knowledgeBaseCategoryId: knowledgeBaseCategoryId, knowledgeBaseArticleId: knowledgeBaseArticleId, isReturnToParentFromKnowledgeBase: isReturnToParentFromKnowledgeBase, name: name, email: email, phone: phone, avatar: avatar, avatarUrl: avatarUrl, token: token, additional_id: additional_id, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, nameOperator: nameOperator, nameChat: nameChat, firstMessage: firstMessage, countMessagesOnInit: countMessagesOnInit, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, isPresentDefaultControllers: isPresentDefaultControllers, validModelBlock: { [weak self] validModel in
            self?.model = validModel
            self?.startWithGUI(storageOutside: storageOutside, isCacheMessagesWithFile: isCacheMessagesWithFile, parentController: parentController, startBlock: startBlock, errorBlock: errorBlock)
        }, errorStatus: errorBlock)
        
    }
    /// Starts a session that presents only the knowledge base (no chat connection).
    @objc public func startKnowledgeBase(urlAPI: String? = nil, api_token: String? = nil, knowledgeBaseID: String? = nil, knowledgeBaseSectionId: NSNumber? = nil, knowledgeBaseCategoryId: NSNumber? = nil, knowledgeBaseArticleId: NSNumber? = nil, isReturnToParentFromKnowledgeBase: Bool = false, name: String? = nil, email: String? = nil, phone: String? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isPresentDefaultControllers: Bool = true, presentIn parentController: UIViewController? = nil, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        guard !isOpenSDKUI else {
            errorBlock(.initChatWhenChatOpenError, "")
            return
        }
        
        UDValidationManager.validateInitionalsFields(urlAPI: urlAPI, api_token: api_token, knowledgeBaseID: knowledgeBaseID, knowledgeBaseSectionId: knowledgeBaseSectionId, knowledgeBaseCategoryId: knowledgeBaseCategoryId, knowledgeBaseArticleId: knowledgeBaseArticleId, isReturnToParentFromKnowledgeBase: isReturnToParentFromKnowledgeBase, name: name, email: email, phone: phone, localeIdentifier: localeIdentifier, customLocale: customLocale, isPresentDefaultControllers: isPresentDefaultControllers, isOnlyKnowledgeBase: true, validModelBlock: { [weak self] validModel in
            self?.model = validModel
            self?.startOnlyKnowledgeBase(parentController: parentController, connectBlock: connectBlock, errorBlock: errorBlock)
        }, errorStatus: errorBlock)
    }
    /// Starts a headless session (no built-in UI).
    @objc public func startWithoutGUICompanyID(companyID: String, chanelId: String, url: String, port: String? = nil, urlAPI: String? = nil, api_token: String? = nil, urlToSendFile: String? = nil, knowledgeBaseID: String? = nil, name: String? = nil, email: String? = nil, phone: String? = nil, avatar: Data? = nil, avatarUrl: URL? = nil, token: String? = nil, additional_id: String? = nil, note: String? = nil, additionalFields: [Int : String] = [:], additionalNestedFields: [[Int : String]] = [], firstMessage: String? = nil, countMessagesOnInit: NSNumber? = nil, localeIdentifier: String? = nil, customLocale: [String : String]? = nil, isSaveTokensInUserDefaults: Bool = true, connectionStatus startBlock: @escaping UDStartBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        if !isStartWithDefaultGUI {
            UDValidationManager.validateInitionalsFields(companyID: companyID, chanelId: chanelId, url: url, port: port, urlAPI: urlAPI, api_token: api_token, urlToSendFile: urlToSendFile, knowledgeBaseID: knowledgeBaseID, name: name, email: email, phone: phone, avatar: avatar, avatarUrl: avatarUrl, token: token, additional_id: additional_id, note: note, additionalFields: additionalFields, additionalNestedFields: additionalNestedFields, firstMessage: firstMessage, countMessagesOnInit: countMessagesOnInit, localeIdentifier: localeIdentifier, customLocale: customLocale, isSaveTokensInUserDefaults: isSaveTokensInUserDefaults, validModelBlock: { [weak self] validModel in
                self?.model = validModel
                self?.startWithuotGUI(startBlock: startBlock, errorBlock: errorBlock)
            }, errorStatus: errorBlock)
        } else {
            startWithuotGUI(startBlock: startBlock, errorBlock: errorBlock)
        }
    }
    
    // MARK: - Public Methods

    /// Uploads the client avatar provided at start to the server.
    /// - Parameters:
    ///   - connectBlock: Called with `true` when the avatar is accepted.
    ///   - errorBlock: Called when the upload fails.
    @objc public func sendAvatarClient(connectBlock: @escaping UDConnectBlock, errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendAvatarClient(connectBlock: connectBlock, errorBlock: errorBlock)
    }

    /// Loads a page of chat history, using a reference message id to sequentially load older messages.
    /// - Parameters:
    ///   - idComment: The id of the oldest already-loaded message; pass `0` for the first page.
    ///   - newMessagesBlock: Called with the fetched messages.
    ///   - errorBlock: Called when the request fails.
    @objc public func getMessages(idComment: Int, newMessagesBlock: @escaping UDNewMessagesBlock, errorBlock: @escaping UDErrorBlock) {
        networkManager?.getMessages(idComment: idComment, newMessagesBlock: newMessagesBlock, errorBlock: errorBlock)
    }

    /// Sends a text message to the chat.
    /// - Parameters:
    ///   - text: The message text.
    ///   - messageId: Optional client-side id used to correlate the local draft with the sent message.
    ///   - completionBlock: Called once the message is emitted to the socket.
    @objc public func sendMessage(_ text: String, messageId: String? = nil, completionBlock: UDVoidBlock? = nil) {
        let mess = UseDeskSDKHelp.messageText(text, messageId: messageId)
        socket?.connect()
        socket?.emit("dispatch", with: mess!, completion: completionBlock)
    }
    
    /// Uploads a single file attachment to the chat, reporting progress. To send several files, call this method once per file.
    /// - Parameters:
    ///   - fileName: The display name of the file (with extension).
    ///   - data: The file contents.
    ///   - messageId: Optional client-side id used to correlate the local draft with the sent message.
    ///   - progressBlock: Reports upload progress in the range `0...1`.
    ///   - connectBlock: Called with `true` when the upload succeeds.
    ///   - errorBlock: Called when the upload fails.
    @objc public func sendFile(fileName: String, data: Data, messageId: String? = nil, progressBlock: UDProgressUploadBlock? = nil, connectBlock: UDConnectBlock? = nil, errorBlock: UDErrorBlock? = nil) {
        let url = model.urlToSendFile != "" ? model.urlToSendFile : "https://secure.usedesk.ru/uapi/v1/send_file"
        networkManager?.sendFile(url: url, fileName: fileName, data: data, messageId: messageId, progressBlock: progressBlock, connectBlock: connectBlock, errorBlock: errorBlock)
    }
    
    /// Loads the knowledge-base structure (sections, categories and articles).
    /// - Parameters:
    ///   - baseBlock: Called with the loaded knowledge-base tree.
    ///   - errorBlock: Called when the request fails.
    @objc public func getCollections(connectionStatus baseBlock: @escaping UDBaseBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getCollections(baseBlock: baseBlock, errorBlock: errorBlock)
    }

    /// Loads a single knowledge-base article by id.
    /// - Parameters:
    ///   - articleID: The article identifier.
    ///   - baseBlock: Called with the loaded article.
    ///   - errorBlock: Called when the request fails.
    @objc public func getArticle(articleID: Int, connectionStatus baseBlock: @escaping UDArticleBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getArticle(articleID: articleID, baseBlock: baseBlock, errorBlock: errorBlock)
    }

    /// Reports article views to the analytics endpoint.
    /// - Parameters:
    ///   - articleID: The article identifier.
    ///   - count: Number of views to add.
    ///   - connectBlock: Called with `true` on success.
    ///   - errorBlock: Called when the request fails.
    @objc public func addViewsArticle(articleID: Int, count: Int, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.addViewsArticle(articleID: articleID, count: count, connectBlock: connectBlock, errorBlock: errorBlock)
    }

    /// Submits positive/negative ratings for an article.
    /// - Parameters:
    ///   - articleID: The article identifier.
    ///   - countPositive: Number of positive ratings to add.
    ///   - countNegative: Number of negative ratings to add.
    ///   - connectBlock: Called with `true` on success.
    ///   - errorBlock: Called when the request fails.
    @objc public func addReviewArticle(articleID: Int, countPositive: Int = 0, countNegative: Int = 0, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.addReviewArticle(articleID: articleID, countPositive: countPositive, countNegative: countNegative, connectBlock: connectBlock, errorBlock: errorBlock)
    }

    /// Sends a free-form review comment for an article.
    /// - Parameters:
    ///   - articleID: The article identifier.
    ///   - message: The review text.
    ///   - connectBlock: Called with `true` on success.
    ///   - errorBlock: Called when the request fails.
    @objc public func sendReviewArticleMesssage(articleID: Int, message: String, connectionStatus connectBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendReviewArticleMesssage(articleID: articleID, subject: model.stringFor("ArticleReviewForSubject"), message: message, tag: model.stringFor("KnowlengeBaseTag"), email: model.email, phone: model.phone, name: model.name, connectionStatus: connectBlock, errorStatus:errorBlock)
    }

    /// Searches knowledge-base articles.
    /// - Parameters:
    ///   - collection_ids: Restrict search to these collections (empty for all).
    ///   - category_ids: Restrict search to these categories (empty for all).
    ///   - article_ids: Restrict search to these articles (empty for all).
    ///   - count: Page size. Defaults to `20`.
    ///   - page: 1-based page number. Defaults to `1`.
    ///   - query: The search query.
    ///   - type: Article type filter.
    ///   - sort: Sort field.
    ///   - order: Sort order.
    ///   - searchBlock: Called with the matching articles.
    ///   - errorBlock: Called when the request fails.
    @objc public func getSearchArticles(collection_ids:[Int], category_ids:[Int], article_ids:[Int], count: Int = 20, page: Int = 1, query: String, type: TypeArticle = .all, sort: SortArticle = .id, order: OrderArticle = .asc, connectionStatus searchBlock: @escaping UDArticleSearchBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.getSearchArticles(collection_ids: collection_ids, category_ids: category_ids, article_ids: article_ids, count: count, page: page, query: query, type: type, sort: sort, order: order, searchBlock: searchBlock, errorBlock: errorBlock)
    }
    
    func sendOfflineForm(name nameClient: String?, email emailClient: String?, message: String, file: UDFile? = nil, topic: String? = nil, fields: [UDCallbackCustomField]? = nil, callback resultBlock: @escaping UDConnectBlock, errorStatus errorBlock: @escaping UDErrorBlock) {
        networkManager?.sendOfflineForm(companyID: model.companyID, chanelID: model.chanelId, name: nameClient ?? model.name, email: emailClient ?? model.email, message: message, file: file, topic: topic, fields: fields, connectBlock: resultBlock, errorBlock: errorBlock)
    }
    
    /// Submits a CSI (Customer Satisfaction Index) rating for a specific message.
    /// - Parameters:
    ///   - ratingId: The id of the selected rating option.
    ///   - message_id: The id of the message being rated.
    @objc public func sendMessageFeedBack(ratingId: String, message_id: Int) {
        socket?.emit("dispatch", with: UseDeskSDKHelp.feedback(ratingId: ratingId, message_id: message_id)!, completion: nil)
    }

    /// Returns the chat view controller for embedding the chat into your own layout (when `isPresentDefaultControllers` is `false`).
    /// - Returns: The chat view controller, or `nil` if no session is active.
    @objc public func chatViewController() -> UIViewController? {
        return uiManager?.chatViewController()
    }

    /// Returns the knowledge-base navigation controller for embedding the knowledge base into your own layout.
    /// - Returns: The knowledge-base navigation controller, or `nil` if no session is active.
    @objc public func baseNavigationController() -> UIViewController? {
        return uiManager?.baseNavigationController()
    }

    /// Clears the message history and terminates the websocket connection, keeping the session reusable.
    @objc public func closeChat() {
        uiManager?.resetUI()
        socket?.disconnect()
        deleteDownloadedFiles(for: historyMess)
        historyMess = []
    }

    /// Completely clears all SDK parameters and terminates the websocket connection: releases the socket
    /// and network manager and resets all state. Call when you are done with the SDK.
    @objc public func releaseChat() {
        uiManager?.resetUI()
        networkManager = nil
        socket?.disconnect()
        manager?.disconnect()
        socket = nil
        manager = nil
        deleteDownloadedFiles(for: historyMess)
        historyMess = []
        model = UseDeskModel()
        isOpenSDKUI = false
        presentationCompletionBlock?()
    }

    private func cleanupOrphanedCacheFiles() {
        let keepPaths = Set((storage?.getMessages() ?? []).flatMap { message in
            [message.file.path, message.file.defaultPath, message.file.previewPath].filter { !$0.isEmpty }
        })
        FileManager.default.udRemoveOrphanedCacheFiles(keepPaths: keepPaths)
    }

    // MARK: - Private Methods
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
                wSelf.cleanupOrphanedCacheFiles()
                wSelf.uiManager?.reloadDialogFlow(success: success, feedBackStatus: feedbackStatus)
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
        manager = SocketManager(socketURL: urlAdress!, config: [.log(isNeedLogSocket),
                                                                .version(.three),
                                                                .reconnects(true),
                                                                .reconnectWaitMax(1),
                                                                .reconnectWait(0),
                                                                .forceWebsockets(true)])
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
        networkManager?.socketDispatch(socket: socket, startBlock: { [weak self] success, feedbackStatus, token in
            startBlock(success, feedbackStatus, token)
            self?.connectBlock?(true)
        }, historyMessagesBlock: { [weak self] messages in
            self?.historyMess = messages
        }, callbackSettingsBlock: { [weak self] callbackSettings in
            self?.callbackSettings = callbackSettings
        }, newMessageBlock: { [weak self] message in
            self?.internalNewMessageBlock?(message)
            self?.newMessageWithGUIBlock?(message)
        }, feedbackMessageBlock: { [weak self] message in
            self?.feedbackMessageBlock?(message)
        }, feedbackAnswerMessageBlock: { [weak self] bool in
            self?.feedbackAnswerMessageBlock?(bool)
        })
    }
    
    private func startOnlyKnowledgeBase(parentController: UIViewController? = nil, connectBlock: @escaping UDConnectBlock, errorBlock: UDErrorBlock? = nil) {
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
        }, errorBlock: { [weak self] error, description in
            self?.uiManager?.reloadBaseFlow(success: false)
            errorBlock?(error, description)
        })
    }
    
    private func setNetworkTracking() {
        reachability = try! Reachability()
        reachability?.whenReachable = { [weak self] _ in
            guard let wSelf = self else { return }
            wSelf.uiManager?.closeNoInternet()
            wSelf.socket?.connect()
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
    
    private func deleteDownloadedFiles(for messages: [UDMessage]) {
        for message in messages {
            for path in [message.file.path, message.file.defaultPath, message.file.previewPath] where !path.isEmpty {
                try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
}
