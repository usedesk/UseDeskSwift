//
//  DialogflowView.swift


import Foundation
import UIKit
import AVKit
import Photos
import AsyncDisplayKit
import MobileCoreServices

protocol DialogflowVCDelegate: AnyObject {
    func close()
}

class DialogflowView: UDMessagesView {

    var messages: [UDMessage] = []
    var isFromBase = false
    var isFromOfflineForm = false
    
    weak var delegate: DialogflowVCDelegate?
    
    private var fileViewingVC: UDFileViewingVC!
    private var noInternetVC: UDNoInternetVC!
    private var isDark = false
    private var isShowNoInternet = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = navigationController as? UDNavigationController {
            isDark = navController.isDark
        }
        
        navigationController?.navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
        navigationController?.navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = configurationStyle.navigationBarStyle.textColor
        (navigationController as? UDNavigationController)?.setTitleTextAttributes()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.actionDone))
        navigationItem.title = usedesk?.model.nameChat
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)
        
        messages = [UDMessage]()
        
        usedesk?.newMessageBlock = { messageOptional in
            DispatchQueue.main.async { [weak self] in
                guard let wSelf = self else {return}
                guard let message = messageOptional else {return}
                if message.loadingMessageId != "" && message.outgoing {
                    let loadingMessageId = message.loadingMessageId
                    var indexSection = 0
                    var index = 0
                    var isFind = false
                    while !isFind && indexSection < wSelf.messagesWithSection.count {
                        index = 0
                        while !isFind && index < wSelf.messagesWithSection[indexSection].count {
                            if wSelf.messagesWithSection[indexSection][index].loadingMessageId == loadingMessageId {
                                if let failMessage = wSelf.failMessages.filter({$0.loadingMessageId == message.loadingMessageId}).first {
                                    if let index = wSelf.failMessages.firstIndex(of: failMessage) {
                                        wSelf.deleteMeessage(from: &wSelf.failMessages, index: index)
                                    }
                                }
                                isFind = true
                                message.loadingMessageId = ""
                                message.statusSend = UD_STATUS_SEND_SUCCEED
                                message.file = wSelf.messagesWithSection[indexSection][index].file
                                message.status = wSelf.messagesWithSection[indexSection][index].status
                                wSelf.messagesWithSection[indexSection][index] = message
                                if let cell = (wSelf.tableNode.nodeForRow(at: IndexPath(row: index, section: indexSection)) as? UDMessageCellNode) {
                                    cell.setSendedStatus()
                                    cell.setNeedsLayout()
                                    cell.layoutIfNeeded()
                                } else {
                                    wSelf.tableNode.reloadRows(at: [IndexPath(row: index, section: indexSection)], with: .automatic)
                                }
                            }
                            index += 1
                        }
                        indexSection += 1
                    }
                    if let replaceMessage = wSelf.messages.filter({ $0.loadingMessageId == loadingMessageId}).first {
                        if let index = wSelf.messages.firstIndex(of: replaceMessage) {
                            wSelf.messages[index] = message
                        }
                    }
                    if !isFind {
                        message.loadingMessageId = ""
                        message.statusSend = UD_STATUS_SEND_SUCCEED
                        wSelf.addMessage(message)
                    }
                } else {
                    wSelf.addMessage(message)
                }
            }
        }
        
        usedesk?.feedbackMessageBlock = { [weak self] newMessage in
            guard let wSelf = self else {return}
            if let message = newMessage {
                wSelf.addMessage(message)
            }
        }
        loadHistory()
    }
    
    func reloadHistory() {
        isShowNoInternet = false
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            if wSelf.usedesk != nil {
                var unknownMessages: [UDMessage] = []
                for message in wSelf.messages {
                    if let historyMessage = wSelf.usedesk!.historyMess.filter({$0.id == message.id}).first {
                        if let index = wSelf.messages.firstIndex(of: message) {
                            wSelf.messages[index].date = historyMessage.date
                        }
                    } else {
                        unknownMessages.append(message)
                    }
                }
                for message in unknownMessages {
                    if let index = wSelf.messages.firstIndex(of: message) {
                        wSelf.messages.remove(at: index)
                    }
                }
                if wSelf.usedesk!.historyMess.count == 0 || wSelf.messages.count == 0 {
                    if wSelf.messages.count == 0 {
                        wSelf.messages = wSelf.usedesk!.historyMess
                    var newMessages: [UDMessage] = []
                    for index in 0..<wSelf.messages.count {
                            newMessages.append(wSelf.messages[wSelf.messages.count - 1 - index])
                    }
                        wSelf.messages = newMessages
                    }
                    wSelf.updateChat()
                } else if wSelf.usedesk!.historyMess.count > wSelf.messages.count {
                    let countNewMessages = wSelf.usedesk!.historyMess.count - wSelf.messages.count
                    let countMessages = wSelf.messages.count
                    for index in 0..<countNewMessages {
                        wSelf.addMessage(wSelf.usedesk!.historyMess[countMessages + index])
                    }
                }
                wSelf.textInput.isUserInteractionEnabled = true
                wSelf.loader.stopAnimating()
                wSelf.loader.alpha = 0
                wSelf.buttonAttach.isEnabled = true
            }
        }
    }
    
    func updateChat() {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            wSelf.loadMessagesFromStorage()
            wSelf.generateSectionFromModel()
            wSelf.buttonAttach.isEnabled = true
            wSelf.textInput.isUserInteractionEnabled = true
            if !wSelf.isFromOfflineForm && !wSelf.isFromBase {
                wSelf.tableNode.reloadData()
                wSelf.loader.stopAnimating()
                wSelf.loader.alpha = 0
            }
        }
    }
    
    func loadHistory() {
        for message in messages {
            if message.file.path != "" {
                let url = URL(fileURLWithPath: message.file.path)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
            }
            if message.file.defaultPath != "" {
                let url = URL(fileURLWithPath: message.file.defaultPath)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
            }
            if message.file.previewPath != "" {
                let url = URL(fileURLWithPath: message.file.previewPath)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
            }
        }
        messages = []
        if usedesk != nil {
            for message in (usedesk!.historyMess) {
                messages.append(message)
            }
        }
        refreshTableView()
    }
    
    func generateSectionFromModel() {
        messagesWithSection = []
        insertFailSendMessages()
        guard messages.count > 0 else {return}
        messagesWithSection.append([messages[0]])
        var indexSection = 0
        for index in 1..<messages.count {
            var dateStringSection = ""
            var dateStringObject = ""
            // date section
            if messagesWithSection[indexSection][0].date != nil {
                dateStringSection = messagesWithSection[indexSection][0].date!.dateFormatString
            }
            if messages[index].date != nil {
                dateStringObject = messages[index].date!.dateFormatString
            }
            if dateStringSection.count > 0 && dateStringObject.count > 0 {
                if dateStringSection == dateStringObject {
                    messagesWithSection[indexSection].append(messages[index])
                } else {
                    messagesWithSection.append([messages[index]])
                    indexSection += 1
                }
            }
        }
    }
    
    func insertFailSendMessages() {
        guard usedesk != nil else {return}
        var failMessagesInsert = failMessages
        var insertArray: [[Int]] = []
        for index in 0..<messages.count {
            let invertedIndex = messages.count - index - 1
            if messages[invertedIndex].date != nil {
                var insertMessages: [UDMessage] = []
                for indexFail in 0..<failMessagesInsert.count {
                    if failMessagesInsert[indexFail].date != nil {
                        if failMessagesInsert[indexFail].date! < messages[invertedIndex].date! {
                            insertMessages.append(failMessagesInsert[indexFail])
                        }
                    }
                }
                var insertMessagesIndexes: [Int] = [invertedIndex > 0 ? invertedIndex : invertedIndex + 1]
                insertMessages.forEach { message in
                    if let deleteIndex = failMessages.firstIndex(of: message) {
                        insertMessagesIndexes.append(deleteIndex)
                        if let deleteIndex = failMessagesInsert.firstIndex(of: message) {
                            failMessagesInsert.remove(at: deleteIndex)
                        }
                    }
                }
                if insertMessagesIndexes.count > 1 {
                    insertArray.append(insertMessagesIndexes)
                }
                if (invertedIndex == 0) && (failMessagesInsert.count > 0) {
                    insertMessagesIndexes = [invertedIndex]
                    insertMessages = failMessagesInsert
                    insertMessages.forEach { message in
                        if let deleteIndex = failMessages.firstIndex(of: message) {
                            insertMessagesIndexes.append(deleteIndex)
                            if let deleteIndex = failMessagesInsert.firstIndex(of: message) {
                                failMessagesInsert.remove(at: deleteIndex)
                            }
                        }
                    }
                    if insertMessagesIndexes.count > 1 {
                        insertArray.append(insertMessagesIndexes)
                    }
                }
            }
        }
        for SectionInsertArray in 0..<insertArray.count {
            for indexInsertFailMess in 1..<insertArray[SectionInsertArray].count {
                messages.insert(failMessages[insertArray[SectionInsertArray][indexInsertFailMess]], at: insertArray[SectionInsertArray][0])
            }
        }
    }
    
    // MARK: - Message methods
    func addMessage(_ message: UDMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            wSelf.messages.append(message)
            var isNewSection = true
            if wSelf.messagesWithSection.count > 0 {
                if wSelf.messagesWithSection[0].count > 0 {
                    if wSelf.messagesWithSection[0].first?.date?.dateFormatString == message.date?.dateFormatString {
                        wSelf.messagesWithSection[0].insert(message, at: 0)
                        isNewSection = false
                    } else {
                        wSelf.messagesWithSection.insert([message], at: 0)
                    }
                } else {
                    wSelf.messagesWithSection.insert([message], at: 0)
                }
            } else {
                wSelf.messagesWithSection.insert([message], at: 0)
            }
            if isNewSection {
                wSelf.tableNode.insertSections([0], with: .top)
                wSelf.tableNode.setNeedsLayout()
                wSelf.tableNode.layoutIfNeeded()
                
                let secondNodeIndexPath = IndexPath(row: 1, section: 1)
                let firstNodeIndexPath = IndexPath(row: 0, section: 1)
                
                guard wSelf.messagesWithSection.count > 1 else {return}
                if wSelf.messagesWithSection[1].count > 1 {
                    if let cellNode = wSelf.tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                        cellNode.bindData(messagesView: self, message: wSelf.messagesWithSection[1][1], avatarImage: wSelf.avatarImage(secondNodeIndexPath))
                        cellNode.setNeedsLayout()
                        cellNode.layoutIfNeeded()
                    }
                }
                if wSelf.messagesWithSection[1].count > 1 {
                    if let cellNode = wSelf.tableNode.nodeForRow(at: secondNodeIndexPath) as? UDMessageCellNode {
                        cellNode.setNeedsLayout()
                        cellNode.layoutIfNeeded()
                    }
                }
            } else {
                let secondNodeIndexPath = IndexPath(row: 1, section: 0)
                let firstNodeIndexPath = IndexPath(row: 0, section: 0)
                
                if wSelf.messagesWithSection[0].count > 1 {
                    if let cellNode = wSelf.tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                        cellNode.bindData(messagesView: self, message: wSelf.messagesWithSection[0][1], avatarImage: wSelf.avatarImage(secondNodeIndexPath))
                        cellNode.setNeedsLayout()
                        cellNode.layoutIfNeeded()
                    }
                }
                wSelf.tableNode.insertRows(at: [firstNodeIndexPath], with: .top)
                if let cellNode = wSelf.tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                    cellNode.setNeedsLayout()
                    cellNode.layoutIfNeeded()
                }
                if wSelf.messagesWithSection[0].count > 1 {
                    if let cellNode = wSelf.tableNode.nodeForRow(at: secondNodeIndexPath) as? UDMessageCellNode {
                        cellNode.setNeedsLayout()
                        cellNode.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    func chekSentMessage(_ message: UDMessage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            guard let wSelf = self else {return}
            if message.id == 0 {
                wSelf.setNotSendMessageFor(message)
            } else if let messageNow = wSelf.getMessage(wSelf.indexPathForMessage(at: message.id)) {
                wSelf.setNotSendMessageFor(messageNow)
            }
        }
    }
    
    func setNotSendMessageFor(_ message: UDMessage) {
        let loadingMessageId = message.loadingMessageId
        var indexSection = 0
        var index = 0
        var isFind = false
        while !isFind && indexSection < messagesWithSection.count {
            index = 0
            while !isFind && index < messagesWithSection[indexSection].count {
                if messagesWithSection[indexSection][index].loadingMessageId == loadingMessageId {
                    isFind = true
                    if messagesWithSection[indexSection][index].loadingMessageId != "" {
                        message.statusSend = UD_STATUS_SEND_FAIL
                        if failMessages.filter({$0.loadingMessageId == message.loadingMessageId}).count == 0 {
                            failMessages.append(message)
                        }
                        messagesWithSection[indexSection][index] = message
                        tableNode.reloadRows(at: [IndexPath(row: index, section: indexSection)], with: .automatic)
                        if let replaceMessage = messages.filter({ $0.loadingMessageId == loadingMessageId}).first {
                            if let index = messages.firstIndex(of: replaceMessage) {
                                messages[index] = message
                            }
                        }
                    }
                }
                index += 1
            }
            indexSection += 1
        }
    }
    
    // MARK: - Message Button methods
    @objc func openUrlFromMessageButton(_ notification: NSNotification) {
        DispatchQueue.main.async {
            if let url = notification.userInfo?["url"] as? String {
                let url = URL(string: url)
                if #available(iOS 10.0, *) {
                    if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                        if let anUrl = url {
                            UIApplication.shared.open(anUrl, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        }
                    } else {
                        // Fallback on earlier versions
                        if let anUrl = url {
                            UIApplication.shared.openURL(anUrl)
                        }
                    }
                } else {
                    if let anUrl = url {
                        UIApplication.shared.openURL(anUrl)
                    }
                }
            }
        }
    }
    
    @objc func sendMessageButton(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            if let text = notification.userInfo?["text"] as? String {
                wSelf.usedesk?.sendMessage(text)
            }
        }
    }
    
    // MARK: - Avatar methods    
    override func avatarImage(_ indexPath: IndexPath?) -> UIImage {
        guard indexPath != nil else {return UIImage.named("udAvatarOperator")}
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        var image: UIImage? = nil
        do {
            if  URL(string: message.avatar) != nil {
                let anAvatar = URL(string: message.avatar)
                let anAvatar1 = try Data(contentsOf: anAvatar!)
                image = UIImage(data: anAvatar1)
            } else {
                return UIImage.named("udAvatarOperator")
            }
        } catch {}
        return image ?? UIImage.named("udAvatarOperator")
    }
    
    // MARK: - Header, Footer methods
    
    override func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        guard usedesk != nil else {return nil}
        let menuItemCopy = UDMenuItem(title: usedesk!.model.stringFor("Copy"), action: #selector(self.actionMenuCopy(_:)))
        menuItemCopy.indexPath = indexPath
        return [menuItemCopy]
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(self.actionMenuCopy(_:)) {
            return true
        }
        return false
    }
    
    // MARK: - Refresh methods
    func refreshTableView() {
        // inverter messages
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            var newMessages: [UDMessage] = []
            for index in 0..<wSelf.messages.count {
                newMessages.append(wSelf.messages[wSelf.messages.count - 1 - index])
            }
            wSelf.messages = newMessages
            wSelf.generateSectionFromModel()
            wSelf.tableNode.reloadData()
            if wSelf.isFromOfflineForm || wSelf.isFromBase {
                wSelf.buttonAttach.isEnabled = true
                wSelf.textInput.isUserInteractionEnabled = true
                wSelf.loader.stopAnimating()
                wSelf.loader.alpha = 0
            }
        }
    }
    
    // MARK: - Send methods
    func sendMessage(_ message: UDMessage) {
        message.date = Date()
        message.typeSenderMessageString = "client_to_operator"
        if let id = usedesk?.networkManager?.newIdLoadingMessages() {
            message.loadingMessageId = id
            if message.type == UD_TYPE_TEXT {
                message.text = message.text.trimmingCharacters(in: .newlines)
                addMessage(message)
                usedesk?.sendMessage(message.text, messageId: id)
                if failMessages.filter({$0.loadingMessageId == message.loadingMessageId}).count == 0 {
                    failMessages.append(message)
                }
                chekSentMessage(message)
            } else {
                addMessage(message)
                if let data = message.file.data {
                    usedesk?.sendFile(fileName: message.file.name, data: data, messageId: id, connectBlock: { [weak self] _ in
                        guard let wSelf = self else {return}
                        wSelf.chekSentMessage(message)
                    }, errorBlock: { [weak self] _, _ in
                        guard let wSelf = self else {return}
                        wSelf.setNotSendMessageFor(message)
                    })
                }
            }
        } else {
            if message.type == UD_TYPE_TEXT {
                usedesk?.sendMessage(message.text)
            } 
        }
    }
    
    // MARK: - User actions
    func closeVC() {
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
        self.removeFromParent()
    }
    
    @objc func actionDone() {
        for message in messages {
            if message.statusSend == UD_STATUS_SEND_SUCCEED && (message.file.path != "" || message.file.defaultPath != "" || message.file.previewPath != "") {
                let url = URL(fileURLWithPath: message.file.path)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
                if message.file.defaultPath != "" {
                    let url = URL(fileURLWithPath: message.file.defaultPath)
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {}
                }
                if message.file.previewPath != "" {
                    let url = URL(fileURLWithPath: message.file.previewPath)
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {}
                }
            }
        }
        saveMessagesDraftAndFail()
        delegate?.close()
        if isFromBase {
            usedesk?.closeChat()
            navigationController?.popViewController(animated: true)
        } else {
            usedesk?.releaseChat()
            usedesk?.uiManager?.dismiss()
        }
    }
    
    @objc func closeFileViewingVC() {
        fileViewingVC.view.removeFromSuperview()
        navigationItem.title = usedesk?.model.nameChat
        navigationController?.navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
        navigationController?.navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = configurationStyle.navigationBarStyle.textColor
        (navigationController as? UDNavigationController)?.setTitleTextAttributes()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.actionDone))
        (navigationController as? UDNavigationController)?.isDark = isDark
        navigationController?.navigationBar.layoutSubviews()
    }
    
    override func actionSendMessage() {
        buttonSend.alpha = 0
        buttonSendLoader.alpha = 1
        buttonSendLoader.startAnimating()
        
        draftMessages.forEach { message in
            if message.type == UD_TYPE_File || message.type == UD_TYPE_PICTURE || message.type == UD_TYPE_VIDEO {
                if message.file.sourceType != nil {
                    sendMessage(message)
                }
            } else {
                sendMessage(message)
            }
        }
        
        draftMessages.removeAll()
        
        closeAttachCollection()
        buttonSend.alpha = 1
        buttonSendLoader.alpha = 0
        buttonSendLoader.stopAnimating()
    }
    
    // MARK: - TableNode
    func showNoInternet() {
        startDownloadFileIds.removeAll()
        guard isShowNoInternet else {return}
        noInternetVC = UDNoInternetVC()
        noInternetVC.usedesk = usedesk
        if usedesk?.model.isPresentDefaultControllers ?? true {
            self.addChild(self.noInternetVC)
            self.view.addSubview(self.noInternetVC.view)
        } else {
            noInternetVC.modalPresentationStyle = .fullScreen
            self.present(noInternetVC, animated: false, completion: nil)
        }
        var width: CGFloat = self.view.frame.width
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            width += safeAreaInsetsLeftOrRight * 2
        }
        noInternetVC.view.frame = CGRect(x:0, y:0, width: width, height: self.view.frame.height)
        noInternetVC.setViews()
    }
    
    func closeNoInternet() {
        // update download files
        for node in tableNode.visibleNodes {
            guard let nodeCell = node as? UDMessageCellNode else {break}
            downloadFile(node: nodeCell)
        }
        // view no internet
        guard isShowNoInternet, noInternetVC != nil else {return}
        isShowNoInternet = false
        if usedesk?.model.isPresentDefaultControllers ?? true {
            noInternetVC.removeFromParent()
            noInternetVC.view.removeFromSuperview()
        } else {
            noInternetVC.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - User actions (menu)
    @objc func actionMenuCopy(_ sender: Any?) {
        if let indexPath: IndexPath = UDMenuItem.indexPath((sender as! UIMenuController)) {
            let message: UDMessage? = self.getMessage(indexPath)
            UIPasteboard.general.string = message?.text
        }
    }
   
    // MARK: - TableNode
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if messagesWithSection[indexPath.section][indexPath.row].statusSend == UD_STATUS_SEND_FAIL {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

            let removeAction = UIAlertAction(title: usedesk!.model.stringFor("DeleteMessage"), style: .destructive, handler: { [weak self] (alert: UIAlertAction!)  in
                guard let wSelf = self else {return}
                if let removeMessage = wSelf.messages.filter({ $0.loadingMessageId == wSelf.messagesWithSection[indexPath.section][indexPath.row].loadingMessageId}).first {
                    if let index = wSelf.messages.firstIndex(of: removeMessage) {
                        wSelf.messages.remove(at: index)
                    }
                }
                wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableNode.reloadData()
                }
            })

            let repeatAction = UIAlertAction(title: usedesk!.model.stringFor("SendAgain"), style: .default, handler: { [weak self] (alert: UIAlertAction!) in
                guard let wSelf = self else {return}
                let message = wSelf.messagesWithSection[indexPath.section][indexPath.row]
                if let removeMessage = wSelf.messages.filter({ $0.loadingMessageId == wSelf.messagesWithSection[indexPath.section][indexPath.row].loadingMessageId}).first {
                    if let index = wSelf.messages.firstIndex(of: removeMessage) {
                        wSelf.messages.remove(at: index)
                    }
                }
                wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableNode.reloadData()
                    wSelf.tableNode.contentOffset.y = 0
                }
                wSelf.sendMessage(message)
            })

            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: {(alert: UIAlertAction!) in
            })
            alertController.addAction(repeatAction)
            alertController.addAction(removeAction)
            alertController.addAction(cancelAction)

            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion:{})
            }
        }
    }
    
    override func actionTapBubble(_ indexPath: IndexPath?) {
        guard usedesk != nil else {return}
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        let file: UDFile = message.file
        if (file.type == "image" || message.type == UD_TYPE_PICTURE || file.type == "video" || message.type == UD_TYPE_VIDEO || file.type == "file" || message.type == UD_TYPE_File) && message.status == UD_STATUS_SUCCEED {
            navigationItem.title = message.file.name
            navigationController?.navigationBar.barTintColor = .black
            navigationController?.navigationBar.tintColor = .white
            var attributes: [NSAttributedString.Key: Any] = [:]
            attributes[.foregroundColor] = UIColor.white
            attributes[.font] = UIFont.systemFont(ofSize: 18)
            navigationController?.navigationBar.titleTextAttributes = attributes
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonInFileImage, style: .plain, target: self, action: #selector(self.closeFileViewingVC))
            (navigationController as? UDNavigationController)?.isDark = true
            navigationController?.navigationBar.layoutSubviews()
            fileViewingVC = UDFileViewingVC()
            fileViewingVC.configurationStyle = configurationStyle
            fileViewingVC.isShowBackButton = !(usedesk?.model.isPresentDefaultControllers ?? true)
            fileViewingVC.isPresentDefaultControllers = usedesk?.model.isPresentDefaultControllers ?? true
            if usedesk?.model.isPresentDefaultControllers ?? true {
                self.addChild(self.fileViewingVC)
                self.view.addSubview(self.fileViewingVC.view)
            } else {
                fileViewingVC.modalPresentationStyle = .fullScreen
                self.present(fileViewingVC, animated: false, completion: nil)
            }
            fileViewingVC.setBottomViewHC(safeAreaInsetsBottom)
            var width: CGFloat = self.view.frame.width
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                width += safeAreaInsetsLeftOrRight * 2
            }
            fileViewingVC.view.frame = CGRect(x:0, y:0, width: width, height: self.view.frame.height)
            if file.type == "image" || message.type == UD_TYPE_PICTURE {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .image
                fileViewingVC.viewimage.image = file.image
            } else if file.type == "video" || message.type == UD_TYPE_VIDEO {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .video
                fileViewingVC.videoImage = file.previewImage
            } else {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .file
                fileViewingVC.fileName = file.name
                fileViewingVC.fileSize = file.sizeString(model: usedesk!.model)
            }
            fileViewingVC.updateState()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
