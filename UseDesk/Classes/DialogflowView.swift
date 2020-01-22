//
//  DialogflowView.swift


import Foundation
import UIKit
import QBImagePickerController
import MBProgressHUD
import AVKit

class DialogflowView: RCMessagesView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate {

    var rcmessages: [RCMessage] = []
    var isFromBase = false
    
    private var hudErrorConnection: MBProgressHUD?
    private var imageVC: UDImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionDone))
        navigationItem.title = usedesk?.nameChat
        hudErrorConnection = MBProgressHUD(view: view)
        hudErrorConnection?.removeFromSuperViewOnHide = true
        view.addSubview(hudErrorConnection!)
        
        hudErrorConnection?.mode = MBProgressHUDMode.indeterminate//MBProgressHUDModeIndeterminate
        //hudErrorConnection.label.text = @"Loading";
        //dicLoadingBuffer = [AnyHashable : Any]()
        
        //buttonInputAttach.isUserInteractionEnabled = false
        //if ([FUser wallpaper] != nil)
        //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[FUser wallpaper]]];
        
        //Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.openUrlFromMessageButton(_:)), name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendMessageButton(_:)), name: Notification.Name("messageButtonSend"), object: nil)
        
        rcmessages = [RCMessage]()
        loadEarlierShow(false)
        
        updateTitleDetails()
        
        guard usedesk != nil else {
            reloadhistory()
            return
        }
        usedesk!.connectBlock = { [weak self] success, error in
            guard let wSelf = self else {return}
            wSelf.hudErrorConnection?.hide(animated: true)
            wSelf.reloadhistory()
        }
        
        usedesk!.newMessageBlock = { [weak self] success, message in
            guard let wSelf = self else {return}
            if let aMessage = message {
                wSelf.rcmessages.append(aMessage)
            }
            wSelf.refreshTableView1()
//            if message?.incoming != false {
//                UDAudio.playMessageIncoming()
//            }
        }
        
        usedesk!.feedbackAnswerMessageBlock = { [weak self] success in
            guard let wSelf = self else {return}
            let alert = UIAlertController(title: "", message: "Спасибо за вашу оценку", preferredStyle: .alert)
            
            
            let yesButton = UIAlertAction(title: "Ok", style: .default, handler: { action in
                //Handle your yes please button action here
            })
            
            alert.addAction(yesButton)
            
            wSelf.present(alert, animated: true)
        }
        
        usedesk!.errorBlock = { [weak self] errors in
            guard let wSelf = self else {return}
            if (errors?.count ?? 0) > 0 {
                wSelf.hudErrorConnection?.label.text = (errors?[0] as! String)
            }
            wSelf.hudErrorConnection?.show(animated: true)
        }
        
        usedesk!.feedbackMessageBlock = { [weak self] message in
            guard let wSelf = self else {return}
            if let aMessage = message {
                wSelf.rcmessages.append(aMessage)
            }
            wSelf.refreshTableView1()
        }
        
        reloadhistory()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonURLOpen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("messageButtonSend"), object: nil)
    }
    
    func reloadhistory() {
        if usedesk != nil {
            rcmessages = []
            for message in (usedesk!.historyMess) {
                rcmessages.append(message)
            }
            refreshTableView1()
        }
    }
    
    // MARK: - Message methods
    override func rcmessage(_ indexPath: IndexPath?) -> RCMessage? {
        return (rcmessages[indexPath!.section] as! RCMessage)
    }
    
    func addMessage(_ text: String?, incoming: Bool) {
        let rcmessage = RCMessage(text: text, incoming: incoming)
        rcmessages.append(rcmessage)
        refreshTableView1()
    }
    // MARK: - Message Button methods
    @objc func openUrlFromMessageButton(_ notification: NSNotification) {
        if let url = notification.userInfo?["url"] as? String {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    @objc func sendMessageButton(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            usedesk?.sendMessage(text)
        }
    }
    
    // MARK: - Avatar methods
    override func avatarInitials(_ indexPath: IndexPath?) -> String? {
        let rcmessage = rcmessages[indexPath!.section] as? RCMessage
        if (rcmessage?.outgoing)! {
            return "you"
        } else {
            return "Ad"
        }
    }
    
    override func avatarImage(_ indexPath: IndexPath?) -> UIImage? {
        let rcmessage = rcmessages[indexPath!.section] as? RCMessage
        if rcmessage?.avatar == nil {
            return nil
        }
        var image: UIImage? = nil
        do {
            if  URL(string: rcmessage!.avatar) != nil {
                let anAvatar = URL(string: rcmessage!.avatar)
                let anAvatar1 = try Data(contentsOf: anAvatar!)
                image = UIImage(data: anAvatar1)
                
            } else {
                if rcmessage?.outgoing == true {
                    return UIImage.named("avatarClient")
                } else {
                    return UIImage.named("avatarOperator") 
                }
            }
        } catch {
        }
//        if let anAvatar = URL(string: rcmessage.avatar ?? ""), let anAvatar1 = Data(contentsOf: anAvatar) {
//            image = UIImage(data: anAvatar1)
//        }
        return image
    }
    
    // MARK: - Header, Footer methods
    override func textSectionHeader(_ indexPath: IndexPath?) -> String? {
        let rcmessage = rcmessages[indexPath!.section] as! RCMessage
        
        if rcmessage.date!.isToday{
            return rcmessage.date!.timeString
        }
        return rcmessage.date!.timeAndDayString
    }
    
    override func textBubbleHeader(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    override func textBubbleFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    override func textSectionFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    override func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        let menuItemCopy = RCMenuItem(title: "Copy", action: #selector(self.actionMenuCopy(_:)))
        menuItemCopy.indexPath = indexPath
        return [menuItemCopy]
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(self.actionMenuCopy(_:)) {
            return true
        }
        return false
    }
    
//    var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    // MARK: - Typing indicator methods
    func typingIndicatorShow(_ show: Bool, animated: Bool, delay: CGFloat) {
        let time = DispatchTime.now() + (Double(delay))
        DispatchQueue.main.asyncAfter(deadline: (time), execute: { [weak self] in
            guard let wSelf = self else {return}
            wSelf.typingIndicatorShow(show, animated: animated)
        })
    }
    
    // MARK: - Title details methods
    func updateTitleDetails() {
        labelTitle1.text = "UseDesk"
        labelTitle2.text = "online now"
    }
    
    // MARK: - Refresh methods
    func refreshTableView1() {
        refreshTableView2()
        scroll(toBottom: true)
    }
    
    func refreshTableView2() {
        tableView.reloadData()
    }
    
    func sendDialogflowRequest(_ text: String?) {
        typingIndicatorShow(true, animated: true, delay: 0.5)
        /*AITextRequest *aiRequest = [apiAI textRequest];
         aiRequest.query = @[text];
         [aiRequest setCompletionBlockSuccess:^(AIRequest *request, id response)
         {
         [self typingIndicatorShow:NO animated:YES delay:1.0];
         [self displayDialogflowResponse:response delay:1.1];
         }
         failure:^(AIRequest *request, NSError *error)
         {
         [ProgressHUD showError:@"Dialogflow request error."];
         }];
         [apiAI enqueue:aiRequest];*/
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
        for rcmessage in rcmessages {
            if rcmessage.video_path != "" {
                do {
                    try? FileManager().removeItem(atPath: rcmessage.video_path)
                }
            }
        }
        usedesk?.releaseChat()
        if isFromBase {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    override func actionSendMessage(_ text: String?) {
        usedesk?.sendMessage(text)
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
                                    wSelf.usedesk?.sendMessage("", withFileName: fileName, fileType: "video/mp4", contentBase64: content)
                                }
                                
                            }
                        }
                    } else {
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)), contentMode: .aspectFit, options: options, resultHandler: { [weak self] result, info in
                            guard let wSelf = self else {return}
                            if result != nil {
                                let content = "data:image/png;base64,\(UseDeskSDKHelp.image(toNSString: result!))"
                                var fileName = String(format: "%ld", content.hash)
                                fileName += ".png"
                                //self.dicLoadingBuffer.updateValue("1", forKey: fileName)
                                //dicLoadingBuffer[fileName] = "1"
                                wSelf.usedesk?.sendMessage("", withFileName: fileName, fileType: "image/png", contentBase64: content)
                            }
                        })
                    }
                } else if sendAssets[i] as? UIImage != nil {
                    let pickerImage = sendAssets[i] as! UIImage
                    let content = "data:image/png;base64,\(UseDeskSDKHelp.image(toNSString: pickerImage))"
                    var fileName = String(format: "%ld", content.hash)
                    fileName += ".png"
                    usedesk?.sendMessage("", withFileName: fileName, fileType: "image/png", contentBase64: content)
                }
            }
            sendAssets = []
        }
        closeAttachCollection()
    }
    
    override func actionAttachMessage() {
        if sendAssets.count < Constants.maxCountAssets {
            let alertController = UIAlertController(title: "Прикрепить файл", message: nil, preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Отмена", style: .destructive) { (_) -> Void in }
            let takePhotoAction = UIAlertAction(title: "Камера", style: .default) { (_) -> Void in
                self.takePhoto()
            }
            let selectFromPhotosAction = UIAlertAction(title: "Галерея", style: .default) { (_) -> Void in
                self.selectPhoto()
            }
            alertController.addAction(takePhotoAction)
            alertController.addAction(selectFromPhotosAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Прикреплено максимальное колличество файлов", message: nil, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ок", style: .default) { (_) -> Void in }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func takePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func selectPhoto() {        
        let imagePickerController = QBImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsMultipleSelection = true
        imagePickerController.maximumNumberOfSelection = UInt(Constants.maxCountAssets - sendAssets.count)
        imagePickerController.showsNumberOfSelectedAssets = true
        
        present(imagePickerController, animated: true)
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController?, didFinishPickingAssets assets: [Any]?) {
        var countReturned: Int = 0
        if assets != nil {
            for asset in assets! {
                if ((asset as? PHAsset) != nil) {
                    let anAsset = asset as! PHAsset
                    if anAsset.mediaType == .image || anAsset.mediaType == .video {
                        sendAssets.append(anAsset)
                    }
                }
            }
            showAttachCollection(assets: sendAssets)
            //                        }
        }
        buttonInputSend.isHidden = false
        
        dismiss(animated: true)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController?) {
        print("Canceled.")
        
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        if chosenImage != nil {
            sendAssets.append(chosenImage!)
            
            buttonInputSend.isHidden = false
        
            showAttachCollection(assets: sendAssets)
        }
        picker.dismiss(animated: true)
    }
    
    // MARK: - User actions (menu)
    @objc func actionMenuCopy(_ sender: Any?) {
        let indexPath: IndexPath? = RCMenuItem.indexPath((sender as! UIMenuController))
        let rcmessage: RCMessage? = self.rcmessage(indexPath)
        UIPasteboard.general.string = rcmessage?.text
    }
   
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rcmessages.count
    }
    
    override func actionTapBubble(_ indexPath: IndexPath?) {
        let rcmessage = rcmessages[indexPath!.section] 
        guard rcmessage.file != nil else {return}
        if rcmessage.file!.type == "image" {
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.tintColor = .clear
            if let cell = tableView.cellForRow(at: indexPath!) as? RCPictureMessageCell {
                rcmessage.status = RC_STATUS_OPENIMAGE
                cell.bindData(indexPath!, messagesView: self)
            }
            imageVC = UDImageView(nibName: "UDImageView", bundle: nil)
            self.addChildViewController(self.imageVC)
            self.view.addSubview(self.imageVC.view)
            imageVC.view.frame = CGRect(x:0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            imageVC.delegate = self
                let session = URLSession.shared
                if let url = URL(string: rcmessage.file!.content) {
                    (session.dataTask(with: url, completionHandler: { data, response, error in
                        if error == nil {
                            DispatchQueue.main.async(execute: { [weak self] in
                                guard let wSelf = self else {return}
                                rcmessage.picture_image = UIImage(data: data!)
                                if rcmessage.picture_image != nil {
                                    wSelf.imageVC.showImage(image: rcmessage.picture_image!)
                                }
                                if let cell = wSelf.tableView.cellForRow(at: indexPath!) as? RCPictureMessageCell {
                                    rcmessage.status = RC_STATUS_SUCCEED
                                    cell.bindData(indexPath!, messagesView: wSelf)
                                }
                            })
                        }
                    })).resume()
                }
        } else if rcmessage.file!.type == "video" {
            if rcmessage.video_path != "" {
                let videoURL = URL(fileURLWithPath: rcmessage.video_path)
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        } else {
            let url = URL(string: rcmessage.file!.content )
            
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
                // Fallback on earlier versions
            }
            
            
        }
        
    }
    
}

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
    
    var timeString: String {
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
}

extension DialogflowView: UDImageViewDelegate {
    func close() {
        imageVC.view.removeFromSuperview()
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.tintColor = nil
    }
    
}
