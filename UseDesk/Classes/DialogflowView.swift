//
//  DialogflowView.swift


import Foundation
import UIKit
import MBProgressHUD
import AVKit
import Photos

class DialogflowView: UDMessagesView {

    var messages: [UDMessage] = []
    var isFromBase = false
    
    private var hudErrorConnection: MBProgressHUD?
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
        hudErrorConnection = MBProgressHUD(view: view)
        hudErrorConnection?.removeFromSuperViewOnHide = true
        view.addSubview(hudErrorConnection!)
        
        hudErrorConnection?.mode = MBProgressHUDMode.indeterminate
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)
        
        messages = [UDMessage]()
        
        usedesk?.connectBlock = { [weak self] success, error in
            guard let wSelf = self else {return}
            wSelf.hudErrorConnection?.hide(animated: true)
        }
        
        usedesk?.newMessageBlock = { success, newMessage in
            if let message = newMessage {
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
        }
        
        usedesk?.feedbackMessageBlock = { newMessage in
            if let message = newMessage {
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
    func addMessage(_ text: String?, incoming: Bool) {
        let message = UDMessage(text: text, incoming: incoming)
        messages.append(message)
        refreshTableView()
    }
    // MARK: - Message Button methods
    @objc func openUrlFromMessageButton(_ notification: NSNotification) {
        if let url = notification.userInfo?["url"] as? String {
            let url = URL(string: url)
            if #available(iOS 10.0, *) {
                if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                    if let anUrl = url {
                        UIApplication.shared.open(anUrl, options: [:], completionHandler: nil)
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
        guard indexPath != nil else {return UIImage.named("avatarOperator")}
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        var image: UIImage? = nil
        do {
            if  URL(string: message.avatar) != nil {
                let anAvatar = URL(string: message.avatar)
                let anAvatar1 = try Data(contentsOf: anAvatar!)
                image = UIImage(data: anAvatar1)
            } else {
                return UIImage.named("avatarOperator")
            }
        } catch {}
        return image ?? UIImage.named("avatarOperator")
    }
    
    // MARK: - Header, Footer methods
    
    override func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        let menuItemCopy = UDMenuItem(title: "Copy", action: #selector(self.actionMenuCopy(_:)))
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
    
    func displayDialogflowResponse(_ dictionary: [AnyHashable : Any]?, delay: CGFloat) {
        let time = DispatchTime.now() + Double(Double(delay) )
        DispatchQueue.main.asyncAfter(deadline: time , execute: { [weak self] in
            guard let wSelf = self else {return}
            wSelf.displayDialogflowResponse(dictionary)
        })
    }
    
    func displayDialogflowResponse(_ dictionary: [AnyHashable : Any]?) {
        let result = dictionary?["result"] as? [AnyHashable : Any]
        let fulfillment = result?["fulfillment"] as? [AnyHashable : Any]
        let text = fulfillment?["speech"] as? String
        addMessage(text, incoming: true)
        //UDAudio.playMessageIncoming()
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
        if isFromBase {
            navigationController?.popViewController(animated: true)
        } else {
            usedesk?.dialogNavController.dismiss(animated: true, completion: nil)
        }
        usedesk?.releaseChat()
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
                usedesk?.sendMessage(text)
            }
        }
        if sendAssets.count > 0 {
            for i in 0..<sendAssets.count {
                if sendAssets[i] as? PHAsset != nil {
                    let asset = sendAssets[i] as! PHAsset
                    if asset.mediaType == .video {
                        let options = PHVideoRequestOptions()
                        options.version = .original
                        PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options){ [weak self] avasset, _, _ in
                            guard let wSelf = self else {return}
                            if let avassetURL = avasset as? AVURLAsset {
                                if let video = try? Data(contentsOf: avassetURL.url) {
                                    let content = "data:video/mp4;base64,\(video.base64EncodedString())"
                                    var fileName = String(format: "%ld", content.hash)
                                    fileName += ".mp4"
                                    wSelf.usedesk?.sendFile(fileName: fileName, data: video, status: {_,_ in })
                                }
                            }
                        }
                    } else {
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)), contentMode: .aspectFit, options: options, resultHandler: { [weak self] result, info in
                            guard let wSelf = self else {return}
                            if result != nil {
                                if let imageData = UIImagePNGRepresentation(result!) {
                                    let content = "data:image/png;base64,\(imageData)"
                                    var fileName = String(format: "%ld", content.hash)
                                    fileName += ".png"
                                    wSelf.usedesk?.sendFile(fileName: fileName, data: imageData, status: {_,_ in })
                                }
                            }
                        })
                    }
                } else if sendAssets[i] as? UIImage != nil {
                    let pickerImage = sendAssets[i] as! UIImage
                    if let imageData = UIImagePNGRepresentation(pickerImage) {
                        let content = "data:image/png;base64,\(imageData)"
                        var fileName = String(format: "%ld", content.hash)
                        fileName += ".png"
                        usedesk?.sendFile(fileName: fileName, data: imageData, status: {success, error in })
                    }
                } else if let urlFile = sendAssets[i] as? URL {
                    let fileName = urlFile.localizedName ?? urlFile.lastPathComponent
                    let dataFile = try? Data(contentsOf: urlFile)
                    if dataFile != nil {
                        usedesk?.sendFile(fileName: fileName, data: dataFile!, status: {success, error in })
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
    
    override func actionTapBubble(_ indexPath: IndexPath?) {
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        let file: UDFile = message.file
        if (file.type == "image" || message.type == RC_TYPE_PICTURE || file.type == "video" || file.type == "file") && message.status == RC_STATUS_SUCCEED {
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
            self.addChildViewController(self.fileViewingVC)
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
            } else if file.type == "video" {
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
        } else {
            let url = URL(string: file.content)
            
            if #available(iOS 10.0, *) {
                if UIApplication.shared.responds(to: #selector(UIApplication.open(_:options:completionHandler:))) {
                    if let anUrl = url {
                        UIApplication.shared.open(anUrl, options: [:], completionHandler: nil)
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
// MARK: - Extension Date
extension Date {
    var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
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
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter.string(from: self)
    }
    
    var timeAndDayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter.string(from: self)
    }
    
    var dateFromHeaderChat: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone.current
        var dayString = ""
        if calendar.isDateInYesterday(self) {
            dayString = "Вчера"
        } else if calendar.isDateInToday(self) {
            dayString = "Сегодня"
        } else {
            dateFormatter.dateFormat = "d MMMM"
            dayString = dateFormatter.string(from: self)
        }
        return dayString
    }
    
    var dateFormatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ru")
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}

// Helper which checks if application has access to Camera or Photos Library and show alert with link to settings if user previously forbid access
private class RequestAuthorizationHelper {

    static func requestCameraAccess(showErrorIn vc: UIViewController, handler: @escaping (Bool) -> Void) {
        requestDeviceAuthorization(showErrorIn: vc, mediaType: AVMediaType.video.rawValue, handler: handler)
    }

    private static let mediaTypeLibrary: String = "Library"
    static func requestLibraryAccess(showErrorIn vc: UIViewController, handler: @escaping (Bool) -> Void) {
        requestDeviceAuthorization(showErrorIn: vc, mediaType: mediaTypeLibrary, handler: handler)
    }

    private static func presentAccessDeniedAlert(from vc: UIViewController, mediaType: String) {
        DispatchQueue.main.async {
            var message: String = ""

            switch mediaType {
            case mediaTypeLibrary:
                message = "У приложения нет доступа к библиотеке фотографий. Пожалуйста, разрешите доступ в настройках."
            case AVMediaType.video.rawValue:
                message = "У приложения нет доступа к камере. Пожалуйста, разрешите доступ в настройках."
            default: break
            }

            presentMediaTypeDeniedAlertWithMessage(messageFormat: message, fromVC: vc)
        }
        
    }
    
    private static func requestDeviceAuthorization(showErrorIn vc: UIViewController, mediaType: String, handler: @escaping (Bool) -> Void) {
        if mediaType == mediaTypeLibrary {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization() { status in
                    guard status == .authorized else {
                        presentAccessDeniedAlert(from: vc, mediaType: mediaType)
                        handler(false)
                        return
                    }
                    handler(true)
                }
            case .denied:
                presentAccessDeniedAlert(from: vc, mediaType: mediaType)
                handler(false)
            default:
                handler(true)
            }
        } else {
            let mediaType: AVMediaType = AVMediaType(mediaType)

            switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
                    guard granted else {
                        presentAccessDeniedAlert(from: vc, mediaType: mediaType.rawValue)
                        handler(false)
                        return
                    }
                    handler(true)
                }
            case .denied:
                presentAccessDeniedAlert(from: vc, mediaType: mediaType.rawValue)
                handler(false)
            default:
                handler(true)
            }
        }
    }

    private static func presentMediaTypeDeniedAlertWithMessage(messageFormat: String, fromVC vc: UIViewController) {
        guard let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else {
            return
        }

        let message = String(format: messageFormat, arguments: [appName])

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)

        let settingsAction = UIAlertAction.init(title: "В настройки", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)

        vc.present(alertController, animated: true, completion: nil)
    }
}
