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
    
    weak var delegate: DialogflowVCDelegate?
    
    private var noInternetVC: UDNoInternetVC!
    private var isShowNoInternet = true
    private var isNoInternet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (navigationController as? UDNavigationController)?.setTitleTextAttributes()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.actionDone))
        navigationItem.title = usedesk?.model.nameChat
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("UseDeskMessageButtonURLOpen1!"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("UseDeskMessageButtonSend1!"), object: nil)
        
        allMessages = [UDMessage]()
        
        usedesk?.newMessageBlock = { messageOptional in
            DispatchQueue.main.async { [weak self] in
                guard let wSelf = self else {return}
                guard let message = messageOptional else {return}
                if wSelf.loader.alpha == 1 {
                    wSelf.loader.alpha = 0
                    wSelf.loader.stopAnimating()
                }
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
                                wSelf.usedesk?.storage?.removeMessage([message])
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
                    if let replaceMessage = wSelf.allMessages.filter({ $0.loadingMessageId == loadingMessageId}).first {
                        if let index = wSelf.allMessages.firstIndex(of: replaceMessage) {
                            wSelf.allMessages[index] = message
                        }
                    }
                    if !isFind {
                        message.statusSend = UD_STATUS_SEND_SUCCEED
                        wSelf.addMessage(message)
                    }
                } else {
                    wSelf.addMessage(message)
                }
                wSelf.sendOtherMessages()
                wSelf.isScrollChatToBottom = true
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
        DispatchQueue.main.async(execute: { [weak self] in
            guard let wSelf = self else {return}
            if wSelf.usedesk != nil {
                var unknownMessages: [UDMessage] = []
                for message in wSelf.allMessages {
                    if let historyMessage = wSelf.usedesk!.historyMess.filter({$0.id == message.id}).first {
                        if let index = wSelf.allMessages.firstIndex(of: message) {
                            wSelf.allMessages[index].date = historyMessage.date
                        }
                    } else {
                        unknownMessages.append(message)
                    }
                }
                for message in unknownMessages {
                    if let index = wSelf.allMessages.firstIndex(of: message) {
                        wSelf.allMessages.remove(at: index)
                    }
                }
                if wSelf.usedesk!.historyMess.count == 0 || wSelf.allMessages.count == 0 {
                    if wSelf.allMessages.count == 0 {
                        wSelf.allMessages = wSelf.usedesk!.historyMess
                    var newMessages: [UDMessage] = []
                    for index in 0..<wSelf.allMessages.count {
                            newMessages.append(wSelf.allMessages[wSelf.allMessages.count - 1 - index])
                    }
                        wSelf.allMessages = newMessages
                    }
                    wSelf.updateChat()
                } else if wSelf.usedesk!.historyMess.count > wSelf.allMessages.count {
                    let countNewMessages = wSelf.usedesk!.historyMess.count - wSelf.allMessages.count
                    let countMessages = wSelf.allMessages.count
                    for index in 0..<countNewMessages {
                        wSelf.addMessage(wSelf.usedesk!.historyMess[countMessages + index])
                    }
                }
                wSelf.textInput.isUserInteractionEnabled = true
                wSelf.loader.stopAnimating()
                wSelf.loader.alpha = 0
                wSelf.buttonAttach.isEnabled = true
            }
        })
    }
    
    func updateChat() {
        DispatchQueue.main.async { [weak self] in
            guard let wSelf = self else {return}
            wSelf.loadMessagesFromStorage()
            wSelf.messagesWithSection = wSelf.generateSection()
            wSelf.configureAttachCollection()
            wSelf.setFirstTextInTextInput()
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
        for message in allMessages {
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
        allMessages = []
        if usedesk != nil {
            for message in (usedesk!.historyMess) {
                allMessages.append(message)
            }
        }
        if allMessages.count > 0 {
            refreshTableView()
        }
    }
    
    // MARK: - Message methods
    func addMessage(_ message: UDMessage, incoming: Bool = false) {
        allMessages.append(message)
        if !incoming {
            newMessagesIds.append(message.id > 0 ? message.id : Int(message.loadingMessageId) ?? 0)
            updateCountNewMessagesView()
        }
        var isNewSection = true
        if messagesWithSection.count > 0 {
            if messagesWithSection[0].count > 0 {
                if messagesWithSection[0].first?.date.dateFormatString == message.date.dateFormatString {
                    messagesWithSection[0].insert(message, at: 0)
                    isNewSection = false
                } else {
                    messagesWithSection.insert([message], at: 0)
                }
            } else {
                messagesWithSection.insert([message], at: 0)
            }
        } else {
            messagesWithSection.insert([message], at: 0)
        }
        if isNewSection {
            tableNode.insertSections([0], with: .top)
            tableNode.setNeedsLayout()
            tableNode.layoutIfNeeded()
            
            let secondNodeIndexPath = IndexPath(row: 1, section: 1)
            let firstNodeIndexPath = IndexPath(row: 0, section: 1)
            
            guard messagesWithSection.count > 1 else {return}
            if messagesWithSection[1].count > 0 {
                if let cellNode = tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                    cellNode.setNeedsLayout()
                    cellNode.layoutIfNeeded()
                }
            }
            if messagesWithSection[1].count > 1 {
                if let cellNode = tableNode.nodeForRow(at: secondNodeIndexPath) as? UDMessageCellNode {
                    cellNode.setNeedsLayout()
                    cellNode.layoutIfNeeded()
                }
            }
        } else {
            let secondNodeIndexPath = IndexPath(row: 1, section: 0)
            let firstNodeIndexPath = IndexPath(row: 0, section: 0)
            
            if messagesWithSection[0].count > 0 {
                if let cellNode = tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                    cellNode.setNeedsLayout()
                    cellNode.layoutIfNeeded()
                }
            }
            tableNode.performBatchUpdates {
                tableNode.insertRows(at: [firstNodeIndexPath], with: .top)
            }
            if let cellNode = tableNode.nodeForRow(at: firstNodeIndexPath) as? UDMessageCellNode {
                cellNode.setNeedsLayout()
                cellNode.layoutIfNeeded()
            }
            if messagesWithSection[0].count > 1 {
                if let cellNode = tableNode.nodeForRow(at: secondNodeIndexPath) as? UDMessageCellNode {
                    cellNode.setNeedsLayout()
                    cellNode.layoutIfNeeded()
                }
            }
        }
        if incoming {
            scrollChatToStart()
        }
    }
    
    func chekSentMessage(_ message: UDMessage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let wSelf = self else {return}
            if let messageNow = wSelf.getMessage(wSelf.indexPathForMessage(at: Int(message.loadingMessageId) ?? 0)), messageNow.id == 0 {
                wSelf.setNotSendMessageFor(messageNow)
            }
        }
    }
    
    func setNotSendMessageFor(_ message: UDMessage) {
        let loadingMessageId = message.loadingMessageId
        var indexSection = 0
        var isFind = false
        while !isFind && indexSection < messagesWithSection.count {
            if let index = messagesWithSection[indexSection].firstIndex(where: {$0.loadingMessageId == loadingMessageId}) {
                isFind = true
                if messagesWithSection[indexSection][index].loadingMessageId != "" {
                    message.statusSend = UD_STATUS_SEND_FAIL
                    if failMessages.filter({$0.loadingMessageId == message.loadingMessageId}).count == 0 {
                        failMessages.append(message)
                        usedesk?.storage?.saveMessages([message])
                    }
                    messagesWithSection[indexSection][index] = message
                    tableNode.reloadRows(at: [IndexPath(row: index, section: indexSection)], with: .automatic)
                    if let replaceMessage = allMessages.filter({ $0.loadingMessageId == loadingMessageId}).first {
                        if let index = allMessages.firstIndex(of: replaceMessage) {
                            allMessages[index] = message
                        }
                    }
                }
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
            for index in 0..<wSelf.allMessages.count {
                newMessages.append(wSelf.allMessages[wSelf.allMessages.count - 1 - index])
            }
            wSelf.allMessages = newMessages
            wSelf.messagesWithSection = wSelf.generateSection()
            wSelf.tableNode.reloadData()
            wSelf.buttonAttach.isEnabled = true
            wSelf.textInput.isUserInteractionEnabled = true
            wSelf.loader.stopAnimating()
            wSelf.loader.alpha = 0
        }
    }
    
    // MARK: - Send methods
    func sendMessage(_ message: UDMessage) {
        message.date = Date()
        message.typeSenderMessageString = "client_to_operator"
        let messageSend = message.copyMessage()
        if isNoInternet {
            setNotSendMessageFor(messageSend)
            setNotSendedOtherMessages()
        } else {
            if messageSend.type == UD_TYPE_TEXT {
                messageSend.text = messageSend.text.trimmingCharacters(in: .newlines)
                usedesk?.sendMessage(messageSend.text, messageId: messageSend.loadingMessageId)
                if failMessages.filter({$0.loadingMessageId == messageSend.loadingMessageId}).count == 0 {
                    messageSend.statusSend = UD_STATUS_SEND_FAIL
                    failMessages.append(messageSend)
                    usedesk?.storage?.saveMessages([messageSend])
                }
                chekSentMessage(messageSend)
            } else {
                if let data = messageSend.file.data {
                    usedesk?.sendFile(fileName: messageSend.file.name, data: data, messageId: messageSend.loadingMessageId, connectBlock: { [weak self] _ in
                        guard let wSelf = self else {return}
                        wSelf.chekSentMessage(messageSend)
                        wSelf.sendOtherMessages()
                    }, errorBlock: { [weak self] _, _ in
                        guard let wSelf = self else {return}
                        wSelf.setNotSendMessageFor(messageSend)
                        wSelf.sendOtherMessages()
                    })
                }
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
        for message in allMessages {
            if message.statusSend == UD_STATUS_SEND_SUCCEED && (message.file.path != "" || message.file.defaultPath != "" || message.file.previewPath != "") {
                if message.file.path.count > 0 {
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
    
    override func actionSendMessage() {
        buttonSend.alpha = 0
        buttonSendLoader.alpha = 1
        buttonSendLoader.startAnimating()
        draftMessages = draftMessages.sorted(by: {$0.type < $1.type})
        if let firstMessage = draftMessages.first, queueOfSendMessages.count == 0 {
            if let id = usedesk?.networkManager?.newIdLoadingMessages() {
                firstMessage.loadingMessageId = id
            }
            var text = firstMessage.text
            text = text.udRemoveFirstSymbol(with: "\n")
            text = text.udRemoveMultipleLineBreaks()
            text = text.udRemoveLastSymbol(with: "\n")
            firstMessage.text = text
            addMessage(firstMessage, incoming: true)
            sendMessage(firstMessage)
            draftMessages.removeFirst()
        }
        if draftMessages.count > 0 {
            for message in draftMessages[0...draftMessages.count - 1] {
                if let id = usedesk?.networkManager?.newIdLoadingMessages() {
                    message.loadingMessageId = id
                }
                addMessage(message, incoming: true)
                queueOfSendMessages.append(message)
            }
            if isNoInternet {
                setNotSendedOtherMessages()
            }
        }
        draftMessages.removeAll()
        closeAttachCollection()
        buttonSend.alpha = 1
        buttonSendLoader.alpha = 0
        buttonSendLoader.stopAnimating()
    }
    
    func sendOtherMessages() {
        guard queueOfSendMessages.count > 0 else {return}
        let sendMessages = queueOfSendMessages
        queueOfSendMessages.removeAll()
        sendMessages.forEach { message in
            if message.type == UD_TYPE_File || message.type == UD_TYPE_PICTURE || message.type == UD_TYPE_VIDEO {
                if message.file.sourceType != nil {
                    sendMessage(message)
                }
            } else {
                sendMessage(message)
            }
        }
    }
    
    func setNotSendedOtherMessages() {
        guard queueOfSendMessages.count > 0 else {return}
        let sendMessages = queueOfSendMessages
        queueOfSendMessages.removeAll()
        sendMessages.forEach { message in
            setNotSendMessageFor(message)
        }
    }
    
    // MARK: - TableNode
    func showNoInternet() {
        isNoInternet = true
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
        isNoInternet = false
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
            
            let repeatAction = UIAlertAction(title: usedesk!.model.stringFor("SendAgain"), style: .default, handler: { [weak self] (alert: UIAlertAction!) in
                guard let wSelf = self, wSelf.usedesk?.isConnecting ?? false else {return}
                DispatchQueue.main.async {
                    let message = wSelf.messagesWithSection[indexPath.section][indexPath.row]
                    wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                    wSelf.usedesk!.storage?.removeMessage([message])
                    if let index = wSelf.failMessages.firstIndex(where: {$0.loadingMessageId == message.loadingMessageId}) {
                        wSelf.failMessages.remove(at: index)
                    }
                    message.statusSend = UD_STATUS_SEND_DRAFT
                    tableNode.deleteRows(at: [indexPath], with: .bottom)
                    wSelf.addMessage(message)
                    wSelf.sendMessage(message)
                }
            })
            
            let removeAction = UIAlertAction(title: usedesk!.model.stringFor("DeleteMessage"), style: .destructive, handler: { [weak self] (alert: UIAlertAction!)  in
                guard let wSelf = self else {return}
                let deleteMessage = wSelf.messagesWithSection[indexPath.section][indexPath.row]
                if let removeMessage = wSelf.allMessages.filter({ $0.loadingMessageId == deleteMessage.loadingMessageId}).first {
                    if let index = wSelf.allMessages.firstIndex(of: removeMessage) {
                        wSelf.allMessages.remove(at: index)
                    }
                }
                wSelf.usedesk!.storage?.removeMessage([deleteMessage])
                if let index = wSelf.failMessages.firstIndex(where: {$0.loadingMessageId == deleteMessage.loadingMessageId}) {
                    wSelf.failMessages.remove(at: index)
                }
                wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableNode.reloadData()
                })
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
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
