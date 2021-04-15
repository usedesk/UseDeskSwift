//
//  DialogflowView.swift


import Foundation
import UIKit
import AVKit
import Photos

protocol DialogflowVCDelegate: class {
    func close()
}

class DialogflowView: UDMessagesView {

    var messages: [UDMessage] = []
    var isFromBase = false
    
    weak var delegate: DialogflowVCDelegate?
    
    private var fileViewingVC: UDFileViewingVC!
    private var isDark = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navController = navigationController as? UDNavigationController {
            isDark = navController.isDark
        }
        
        if let backButtonImage = configurationStyle.navigationBarStyle.backButtonImage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.actionDone))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionDone))
        }
        
        navigationItem.title = usedesk?.nameChat
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)
        
        messages = [UDMessage]()
        
        usedesk?.connectBlock = { [weak self] success, error in
            guard let wSelf = self else {return}
        }
        
        usedesk?.newMessageBlock = { success, messageOptional in
            DispatchQueue.main.async(execute: { [weak self] in
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
                                isFind = true
                                message.loadingMessageId = ""
                                message.isNotSent = false
                                message.file = wSelf.messagesWithSection[indexSection][index].file
                                message.status = wSelf.messagesWithSection[indexSection][index].status
                                wSelf.messagesWithSection[indexSection][index] = message
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
                } else {
                    wSelf.addMessage(message)
                }
                wSelf.tableView.reloadData()
            })
        }
        
        usedesk?.feedbackMessageBlock = { [weak self] newMessage in
            guard let wSelf = self else {return}
            if let message = newMessage {
                wSelf.addMessage(message)
            }
        }
        reloadhistory()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonSend"), object: nil)
    }
    
    func reloadhistory() {
        if usedesk != nil {
            for message in messages {
                if message.file.path != "" {
                    let url = URL(fileURLWithPath: message.file.path)
                    do {
                        try FileManager.default.removeItem(at: url)
                    } catch {}
                }
            }
            messages = []
            for message in (usedesk!.historyMess) {
                messages.append(message)
            }
            refreshTableView()
        }
    }
    
    func generateSectionFromModel(messagesArray: [UDMessage]) {
        messagesWithSection = []
        guard messagesArray.count > 0 else {return}
        messagesWithSection.append([messagesArray[0]])
        var indexSection = 0
        for index in 1..<messagesArray.count {
            var dateStringSection = ""
            var dateStringObject = ""
            // date section
            if messagesWithSection[indexSection][0].date != nil {
                dateStringSection = messagesWithSection[indexSection][0].date!.dateFormatString
            }
            if messagesArray[index].date != nil {
                dateStringObject = messagesArray[index].date!.dateFormatString
            }
            if dateStringSection.count > 0 && dateStringObject.count > 0 {
                if dateStringSection == dateStringObject {
                    messagesWithSection[indexSection].append(messagesArray[index])
                } else {
                    messagesWithSection.append([messagesArray[index]])
                    indexSection += 1
                }
            }
        }
    }
    
    // MARK: - Message methods
    func addMessage(_ message: UDMessage) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let wSelf = self else {return}
            wSelf.messages.append(message)
            if wSelf.messagesWithSection.count > 0 {
                wSelf.messagesWithSection[0].insert(message, at: 0)
            } else {
                wSelf.messagesWithSection.append([message])
            }
            wSelf.tableView.reloadData()
        })
    }
    func chekSentMessage(_ message: UDMessage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            guard let wSelf = self else {return}
            let loadingMessageId = message.loadingMessageId
            var indexSection = 0
            var index = 0
            var isFind = false
            while !isFind && indexSection < wSelf.messagesWithSection.count {
                index = 0
                while !isFind && index < wSelf.messagesWithSection[indexSection].count {
                    if wSelf.messagesWithSection[indexSection][index].loadingMessageId == loadingMessageId {
                        isFind = true
                        if wSelf.messagesWithSection[indexSection][index].loadingMessageId != "" {
                            wSelf.messagesWithSection[indexSection][index] = message
                            if let replaceMessage = wSelf.messages.filter({ $0.loadingMessageId == loadingMessageId}).first {
                                if let index = wSelf.messages.firstIndex(of: replaceMessage) {
                                    wSelf.messages[index] = message
                                }
                            }
                        }
                    }
                    index += 1
                }
                indexSection += 1
            }
            wSelf.tableView.reloadData()
        }
    }
    
    // MARK: - Message Button methods
    @objc func openUrlFromMessageButton(_ notification: NSNotification) {
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
    
    @objc func sendMessageButton(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            usedesk?.sendMessage(text)
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
        let menuItemCopy = UDMenuItem(title: usedesk!.stringFor("Copy"), action: #selector(self.actionMenuCopy(_:)))
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
        var newMessages: [UDMessage] = []
        for index in 0..<messages.count {
            newMessages.append(messages[messages.count - 1 - index])
        }
        messages = newMessages
        generateSectionFromModel(messagesArray: messages)
        tableView.reloadData()
    }
    
    // MARK: - User actions
    @objc func actionDone() {
        for message in messages {
            if message.file.path != "" {
                let url = URL(fileURLWithPath: message.file.path)
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
            }
        }
        delegate?.close()
        if isFromBase {
            usedesk?.closeChat()
            navigationController?.popViewController(animated: true)
        } else {
            usedesk?.releaseChat()
            usedesk?.navController.dismiss(animated: true, completion: nil)
        }
        self.view.removeFromSuperview()
    }
    
    @objc func closeFileViewingVC() {
        fileViewingVC.view.removeFromSuperview()
        navigationItem.title = usedesk?.nameChat
        navigationController?.navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
        navigationController?.navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = configurationStyle.navigationBarStyle.textColor
        (navigationController as? UDNavigationController)?.setTitleTextAttributes()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.actionDone))
        (navigationController as? UDNavigationController)?.isDark = isDark
        navigationController?.navigationBar.layoutSubviews()
    }
    
    override func actionSendMessage(_ text: String?) {
        if text != nil {
            if text!.count > 0 {
                let message = UDMessage()
                message.date = Date()
                message.type = RC_TYPE_TEXT
                message.incoming = false
                message.outgoing = !message.incoming
                message.text = text!
                message.typeSenderMessageString = "client_to_operator"
                if let id = usedesk?.newIdLoadingMessages() {
                    usedesk!.idLoadingMessages.append(id)
                    message.loadingMessageId = id
                    usedesk?.sendMessage(text!, messageId: id)
                    chekSentMessage(message)
                } else {
                    usedesk?.sendMessage(text!)
                }
                addMessage(message)
            }
        }
        if sendAssets.count > 0 {
            for i in 0..<sendAssets.count {
                if sendAssets[i] as? PHAsset != nil {
                    let asset = sendAssets[i] as! PHAsset
                    if asset.mediaType == .video {
                        DispatchQueue.global(qos: .userInitiated).async {
                        let options = PHVideoRequestOptions()
                        options.version = .original
                        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options){ [weak self] avasset, _, _ in
                            guard let wSelf = self else {return}
                            if let avassetURL = avasset as? AVURLAsset {
                                if let videoData = try? Data(contentsOf: avassetURL.url) {
                                    let content = "data:video/mp4;base64,\(videoData.base64EncodedString())"
                                    var fileName = String(format: "%ld", content.hash)
                                    fileName += ".mp4"
                                    let message = UDMessage()
                                    message.date = Date()
                                    message.type = RC_TYPE_VIDEO
                                    message.incoming = false
                                    message.outgoing = !message.incoming
                                    message.typeSenderMessageString = "client_to_operator"
                                    message.file.path = avassetURL.url.path
                                    message.file.picture = UDFileManager.videoPreview(filePath: avassetURL.url.path)
                                    message.file.name = fileName
                                    message.data = videoData
                                    message.status = RC_STATUS_SUCCEED
                                    if let id = wSelf.usedesk?.newIdLoadingMessages() {
                                        wSelf.usedesk!.idLoadingMessages.append(id)
                                        message.loadingMessageId = id
                                        wSelf.usedesk?.sendFile(fileName: fileName, data: videoData, messageId: id, status: {_,_ in })
                                        wSelf.chekSentMessage(message)
                                    } else {
                                        wSelf.usedesk?.sendFile(fileName: fileName, data: videoData, status: {_,_ in })
                                    }
                                    wSelf.addMessage(message)
                                }
                            }
                        }
                        }
                    } else {
                        DispatchQueue.global(qos: .userInitiated).async {
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)), contentMode: .aspectFit, options: options, resultHandler: { [weak self] resultImage, info in
                            guard let wSelf = self else {return}
                            if resultImage != nil {
                                if let imageData = resultImage!.pngData() {
                                    let content = "data:image/png;base64,\(imageData)"
                                    var fileName = String(format: "%ld", content.hash)
                                    fileName += ".png"
                                    let message = UDMessage()
                                    message.date = Date()
                                    message.type = RC_TYPE_PICTURE
                                    message.incoming = false
                                    message.outgoing = !message.incoming
                                    message.typeSenderMessageString = "client_to_operator"
                                    message.file.picture = resultImage
                                    message.file.name = fileName
                                    message.data = imageData
                                    message.status = RC_STATUS_SUCCEED
                                    if let id = wSelf.usedesk?.newIdLoadingMessages() {
                                        wSelf.usedesk!.idLoadingMessages.append(id)
                                        message.loadingMessageId = id
                                        wSelf.usedesk?.sendFile(fileName: fileName, data: imageData, messageId: id, status: {_,_ in })
                                        wSelf.chekSentMessage(message)
                                    } else {
                                        wSelf.usedesk?.sendFile(fileName: fileName, data: imageData, status: {_,_ in })
                                    }
                                    wSelf.addMessage(message)
                                }
                            }
                        })
                    }
                    }
                } else if sendAssets[i] as? UIImage != nil {
                    let pickerImage = sendAssets[i] as! UIImage
                    if let imageData = pickerImage.pngData() {
                        let content = "data:image/png;base64,\(imageData)"
                        var fileName = String(format: "%ld", content.hash)
                        fileName += ".png"
                        let message = UDMessage()
                        message.date = Date()
                        message.type = RC_TYPE_PICTURE
                        message.incoming = false
                        message.outgoing = !message.incoming
                        message.typeSenderMessageString = "client_to_operator"
                        message.file.picture = pickerImage
                        message.file.name = fileName
                        message.data = imageData
                        message.status = RC_STATUS_SUCCEED
                        if let id = usedesk?.newIdLoadingMessages() {
                            usedesk!.idLoadingMessages.append(id)
                            message.loadingMessageId = id
                            usedesk?.sendFile(fileName: fileName, data: imageData, messageId: id, status: {_,_ in })
                            chekSentMessage(message)
                        } else {
                            usedesk?.sendFile(fileName: fileName, data: imageData, status: {_,_ in })
                        }
                        addMessage(message)
                    }
                } else if let urlFile = sendAssets[i] as? URL {
                    let fileName = urlFile.localizedName ?? urlFile.lastPathComponent
                    let dataFile = try? Data(contentsOf: urlFile)
                    if dataFile != nil {
                        let message = UDMessage()
                        message.date = Date()
                        message.type = RC_TYPE_File
                        message.incoming = false
                        message.outgoing = !message.incoming
                        message.typeSenderMessageString = "client_to_operator"
                        message.file.name = fileName
                        message.file.sizeInt = dataFile!.count
                        message.file.path = urlFile.path
                        message.data = dataFile!
                        message.status = RC_STATUS_SUCCEED
                        if let id = usedesk?.newIdLoadingMessages() {
                            usedesk!.idLoadingMessages.append(id)
                            message.loadingMessageId = id
                            usedesk?.sendFile(fileName: fileName, data: dataFile!, messageId: id, status: {_,_ in })
                            chekSentMessage(message)
                        } else {
                            usedesk?.sendFile(fileName: fileName, data: dataFile!, status: {_,_ in })
                        }
                        addMessage(message)
                    }
                }
            }
            sendAssets = []
        }
        closeAttachCollection()
    }
    
    // MARK: - User actions (menu)
    @objc func actionMenuCopy(_ sender: Any?) {
        if let indexPath: IndexPath = UDMenuItem.indexPath((sender as! UIMenuController)) {
            let message: UDMessage? = self.getMessage(indexPath)
            UIPasteboard.general.string = message?.text
        }
    }
   
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return messagesWithSection.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard usedesk != nil else {return}
        if messagesWithSection[indexPath.section][indexPath.row].isNotSent {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let removeAction = UIAlertAction(title: usedesk!.stringFor("DeleteMessage"), style: .destructive, handler: { [weak self] (alert: UIAlertAction!)  in
                guard let wSelf = self else {return}
                if let removeMessage = wSelf.messages.filter({ $0.loadingMessageId == wSelf.messagesWithSection[indexPath.section][indexPath.row].loadingMessageId}).first {
                    if let index = wSelf.messages.firstIndex(of: removeMessage) {
                        wSelf.messages.remove(at: index)
                    }
                }
                wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableView.reloadData()
                })
            })
            
            let repeatAction = UIAlertAction(title: usedesk!.stringFor("SendAgain"), style: .default, handler: { [weak self] (alert: UIAlertAction!) in
                guard let wSelf = self else {return}
                let message = wSelf.messagesWithSection[indexPath.section][indexPath.row]
                if let removeMessage = wSelf.messages.filter({ $0.loadingMessageId == wSelf.messagesWithSection[indexPath.section][indexPath.row].loadingMessageId}).first {
                    if let index = wSelf.messages.firstIndex(of: removeMessage) {
                        wSelf.messages.remove(at: index)
                    }
                }
                wSelf.messagesWithSection[indexPath.section].remove(at: indexPath.row)
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableView.reloadData()
                    wSelf.tableView.contentOffset.y = 0
                })
                message.isNotSent = false
                switch message.type {
                case RC_TYPE_VIDEO, RC_TYPE_PICTURE, RC_TYPE_File:
                    if message.data != nil {
                        wSelf.usedesk?.sendFile(fileName: message.file.name, data: message.data!, messageId: message.loadingMessageId, status: {_,_ in })
                        wSelf.chekSentMessage(message)
                    }
                default:
                    wSelf.actionSendMessage(message.text)
                }
                wSelf.addMessage(message)
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
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        guard !message.isNotSent else { return }
        let file: UDFile = message.file
        if (file.type == "image" || message.type == RC_TYPE_PICTURE || file.type == "video" || message.type == RC_TYPE_VIDEO || file.type == "file" || message.type == RC_TYPE_File) && message.status == RC_STATUS_SUCCEED {
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
            self.addChild(self.fileViewingVC)
            self.view.addSubview(self.fileViewingVC.view)
            fileViewingVC.setBottomViewHC(safeAreaInsetsBottom)
            var width: CGFloat = self.view.frame.width
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                width += safeAreaInsetsLeftOrRight * 2
            }
            fileViewingVC.view.frame = CGRect(x:0, y:0, width: width, height: self.view.frame.height)
            if file.type == "image" || message.type == RC_TYPE_PICTURE {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .image
                fileViewingVC.viewimage.image = file.picture
            } else if file.type == "video" || message.type == RC_TYPE_VIDEO {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .video
                fileViewingVC.videoImage = file.picture
            } else {
                fileViewingVC.filePath = file.path
                fileViewingVC.typeFile = .file
                fileViewingVC.fileName = file.name
                fileViewingVC.fileSize = file.sizeString
            }
            fileViewingVC.updateState()
        }
    }
}
// MARK: - Extension Date
extension Date {
    var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        let date1 = dateFormatter.string(from: self)
        let date2 = dateFormatter.string(from: Date())
        if date1 == date2 {
            return true
        } else {
            return false
        }
    }
    
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    var timeAndDayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    func dateFromHeaderChat(_ usedesk : UseDeskSDK) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        var dayString = ""
        if calendar.isDateInYesterday(self) {
            dayString = usedesk.stringFor("Yesterday")
        } else if calendar.isDateInToday(self) {
            dayString = usedesk.stringFor("Today")
        } else {
            dateFormatter.dateFormat = "d MMMM"
            dayString = dateFormatter.string(from: self)
        }
        return dayString
    }
    
    var dateFormatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
