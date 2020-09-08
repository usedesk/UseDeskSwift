//
//  RCMessagesView.swift

import AVFoundation
import Photos

enum Orientation {
    case portrait
    case landscape
}

class RCMessagesView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var viewInputHC: NSLayoutConstraint!
    @IBOutlet weak var buttonInputAttach: UIButton!
//    @IBOutlet weak var buttonInputAudio: UIButton!
    @IBOutlet weak var buttonInputSend: UIButton!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var textInputHC: NSLayoutConstraint!
    @IBOutlet weak var textInputBC: NSLayoutConstraint!
    @IBOutlet weak var textInputLC: NSLayoutConstraint!
    @IBOutlet weak var textInputTC: NSLayoutConstraint!
    @IBOutlet weak var attachCollectionView: UICollectionView!
    @IBOutlet weak var buttonInputAttachLC: NSLayoutConstraint!
    @IBOutlet weak var buttonInputSendTC: NSLayoutConstraint!
    // @IBOutlet var viewInputAudio: UIView!
    //@IBOutlet var labelInputAudio: UILabel!
    
    weak var usedesk: UseDeskSDK?
    
    public var sendAssets: [Any] = []
    
    private var previousOrientation: Orientation = .portrait

    private var initialized = false
    private var isShowKeyboard = false
    private var isChangeOffsetTable = false
    private var isAttachFiles = false
    private var isViewInputResizeFromAttach = false
    private var changeOffsetTableHeight: CGFloat = 0.0
    private var heightView: CGFloat = 0.0
    private var timerAudio: Timer?
    private var dateAudioStart: Date?
    private var pointAudioStart = CGPoint.zero
    private var audioRecorder: AVAudioRecorder?
    private var safeAreaInsetsBottom: CGFloat = 0.0
    private var centerPortait: CGPoint = CGPoint.zero
    private var centerPortaitWithKeyboard: CGPoint = CGPoint.zero
    private var centerLandscape: CGPoint = CGPoint.zero
    private var centerLandscapeWithKeyboard: CGPoint = CGPoint.zero
    private var keyboardHeightPortait: CGFloat = 0
    private var keyboardHeightLandscape: CGFloat = 0
    private var previousTextInputHeight: CGFloat = 0
    
    convenience init() {
        let nibName: String = "RCMessagesView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = tableView.backgroundColor
        
        tableView.register(RCSectionHeaderCell.self, forCellReuseIdentifier: "RCSectionHeaderCell")
        tableView.register(RCBubbleHeaderCell.self, forCellReuseIdentifier: "RCBubbleHeaderCell")
        tableView.register(RCBubbleFooterCell.self, forCellReuseIdentifier: "RCBubbleFooterCell")
        tableView.register(RCSectionFooterCell.self, forCellReuseIdentifier: "RCSectionFooterCell")
        tableView.register(RCStatusCell.self, forCellReuseIdentifier: "RCStatusCell")
        tableView.register(RCTextMessageCell.self, forCellReuseIdentifier: "RCTextMessageCell")
        tableView.register(RCEmojiMessageCell.self, forCellReuseIdentifier: "RCEmojiMessageCell")
        tableView.register(RCPictureMessageCell.self, forCellReuseIdentifier: "RCPictureMessageCell")
        tableView.register(RCVideoMessageCell.self, forCellReuseIdentifier: "RCVideoMessageCell")
        tableView.register(RCAudioMessageCell.self, forCellReuseIdentifier: "RCAudioMessageCell")
        tableView.register(RCLocationMessageCell.self, forCellReuseIdentifier: "RCLocationMessageCell")
        
        attachCollectionView.delegate = self
        attachCollectionView.dataSource = self
        attachCollectionView.register(RCAttachCollectionViewCell.self, forCellWithReuseIdentifier: "RCAttachCollectionViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.audioRecorderGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
//        buttonInputAudio.addGestureRecognizer(gesture)
        
        //viewInputAudio.isHidden = true
        
        inputPanelInit()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightView = view.frame.size.height
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = view.safeAreaInsets.bottom
        }
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if centerPortait == CGPoint.zero {
                centerPortait = view.center
            }
            if keyboardHeightPortait != 0 && centerPortaitWithKeyboard == CGPoint.zero {
                centerPortaitWithKeyboard = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightPortait)
            }
            if previousOrientation != .portrait {
                self.view.center = isShowKeyboard ? centerPortaitWithKeyboard : centerPortait
                previousOrientation = .portrait
            }
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: tableView.frame.height)
        } else {
            if centerLandscape == CGPoint.zero {
                centerLandscape = view.center
            }
            if keyboardHeightLandscape != 0 && centerLandscapeWithKeyboard == CGPoint.zero {
                centerLandscapeWithKeyboard = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightLandscape)
            }
            if previousOrientation != .landscape {
                self.view.center = isShowKeyboard ? centerLandscapeWithKeyboard : centerLandscape
                previousOrientation = .landscape
            }
            if #available(iOS 11.0, *) {
                if UIDevice.current.orientation == .landscapeLeft {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.left
                    tableView.frame = CGRect(x: tableView.frame.origin.x + safeAreaInsetsLeftOrRight, y: tableView.frame.origin.y, width: tableView.frame.width - safeAreaInsetsLeftOrRight, height: tableView.frame.height)
                } else {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.right
                    tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width - safeAreaInsetsLeftOrRight, height: tableView.frame.height)
                }
            }
        }
        inputPanelUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialized == false {
            initialized = true
            scroll(toBottom: true)
        }
        heightView = view.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    // MARK: - Message methods
    func rcmessage(_ indexPath: IndexPath?) -> RCMessage? {
        return nil
    }
    
    // MARK: - Avatar methods
    func avatarInitials(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    func avatarImage(_ indexPath: IndexPath?) -> UIImage? {
        return nil
    }
    
    // MARK: - Header, Footer methods
    
    func textBubbleHeader(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    func textBubbleFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    func textSectionFooter(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
    // MARK: - Menu controller methods
    func menuItems(_ indexPath: IndexPath?) -> [Any]? {
        return nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Keyboard methods
    @objc func keyboardShow(_ notification: Notification) {
        if !isShowKeyboard {
            let info = notification.userInfo
            let keyboard: CGRect? = (info?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let duration = TimeInterval((info?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {          if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                    if self.keyboardHeightPortait == 0 {
                        self.keyboardHeightPortait = CGFloat(keyboard?.size.height ?? 0)
                    }
                    if self.view.center == self.centerPortait {
                        self.view.center = CGPoint(x: self.centerPortait.x, y: self.centerPortait.y - self.keyboardHeightPortait)
                    }
                } else {
                    if self.view.center == self.centerLandscape {
                        if self.keyboardHeightLandscape == 0 {
                            self.keyboardHeightLandscape = CGFloat(keyboard?.size.height ?? 0)
                        }
                        self.view.center = CGPoint(x: self.centerLandscape.x, y: self.centerLandscape.y - self.keyboardHeightLandscape)
                    }
                }
            })
            isShowKeyboard = true
            UIMenuController.shared.menuItems = nil
            inputPanelUpdate()
        }
    }
    
    @objc func keyboardHide(_ notification: Notification?) {
        if isShowKeyboard {
            let info = notification?.userInfo
            let duration = TimeInterval((info?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                    self.view.center = self.centerPortait
                } else {
                    self.view.center = self.centerLandscape
                }
            })
            isShowKeyboard = false
            inputPanelUpdate()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Input panel methods
    func inputPanelInit() {
        viewInput.backgroundColor = RCMessages.inputViewBackColor()
        textInput.backgroundColor = RCMessages.inputTextBackColor()
        textInput.isScrollEnabled = true
        
        textInput.font = RCMessages.inputFont()
        textInput.textColor = RCMessages.inputTextTextColor()
        
        textInput.layer.borderColor = RCMessages.inputBorderColor()
        textInput.layer.borderWidth = RCMessages.inputBorderWidth()
        
        textInput.layer.cornerRadius = RCMessages.inputRadius()
        textInput.clipsToBounds = true
        
    }

    func inputPanelUpdate() {
        var heightText: CGFloat
        heightText = textInput.contentSize.height
        var heightInput: CGFloat = 0
        if heightText > 98 {
            heightInput = 98
        } else {
            heightInput = heightText < 30 ? 30 : heightText
            previousTextInputHeight = heightText
        }
        if safeAreaInsetsBottom != 0 {
            textInputBC.constant = isShowKeyboard ? 7 : safeAreaInsetsBottom + 7
        }
        viewInputHC.constant = isShowKeyboard ? heightInput + 14 : heightInput + safeAreaInsetsBottom + 14
        if isAttachFiles {
            viewInputHC.constant += Constants.heightAssetsCollection
            textInputBC.constant = 7 + Constants.heightAssetsCollection
        }
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            buttonInputAttachLC.constant = 0
            buttonInputSendTC.constant = 6
            textInputTC.constant = 56
            textInputLC.constant = 44
        } else {
            buttonInputAttachLC.constant = 0 + safeAreaInsetsLeftOrRight
            buttonInputSendTC.constant = 6 + safeAreaInsetsLeftOrRight
            textInputTC.constant = 56 + safeAreaInsetsLeftOrRight
            textInputLC.constant = 44 + safeAreaInsetsLeftOrRight
        }
        textInputHC.constant = heightInput
        buttonInputSend.isEnabled = textInput.text.count != 0 || sendAssets.count > 0
    }
    
    // MARK: - User actions (bubble tap)
    func actionTapBubble(_ indexPath: IndexPath?) {
    }
    
    // MARK: - User actions (avatar tap)
    func actionTapAvatar(_ indexPath: IndexPath?) {
    }

    // MARK: - User actions (input panel)
    @IBAction func actionInputAttach(_ sender: Any) {
        dismissKeyboard()
        actionAttachMessage()
    }
    
    @IBAction func actionInputSend(_ sender: Any) {
        actionSendMessage(textInput.text)
        dismissKeyboard()
        textInput.text = nil
        inputPanelUpdate()
    }
    
    @objc func buttonFromMessageAction() {
    }
    
    func actionAttachMessage() {
    }
    
    func actionSendAudio(_ path: String?) {
    }
    
    func actionSendMessage(_ text: String?) {
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != textInput {
            dismissKeyboard()
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return RCMessages.sectionHeaderMargin()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return RCMessages.sectionFooterMargin()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return RCSectionHeaderCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 1 {
            return RCBubbleHeaderCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 2 {
            let rcmessage: RCMessage? = self.rcmessage(indexPath)
            if rcmessage?.type == RC_TYPE_STATUS {
                return RCStatusCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RC_TYPE_TEXT {
                var heightButtons: CGFloat = 0
                for _ in rcmessage!.rcButtons {
                    heightButtons += 40
                }
                heightButtons += 25
                return RCTextMessageCell.height(indexPath, messagesView: self) + heightButtons
            }
            if rcmessage?.type == RC_TYPE_Feedback {
                return RCEmojiMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RC_TYPE_PICTURE {
                return RCPictureMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RC_TYPE_VIDEO {
                return RCVideoMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RC_TYPE_AUDIO {
                return RCAudioMessageCell.height(indexPath, messagesView: self)
            }
            if rcmessage?.type == RC_TYPE_LOCATION {
                return RCLocationMessageCell.height(indexPath, messagesView: self)
            }
        }
        if indexPath.row == 3 {
            return RCBubbleFooterCell.height(indexPath, messagesView: self)
        }
        if indexPath.row == 4 {
            return RCSectionFooterCell.height(indexPath, messagesView: self)
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionHeaderCell", for: indexPath) as? RCSectionHeaderCell
            cell!.bindData(indexPath, messagesView: self)
            return cell!
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleHeaderCell", for: indexPath) as! RCBubbleHeaderCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        } else if indexPath.row == 2 {
            let rcmessage: RCMessage? = self.rcmessage(indexPath)
            if rcmessage?.type == RC_TYPE_STATUS {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCStatusCell", for: indexPath) as! RCStatusCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage?.type == RC_TYPE_TEXT {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCTextMessageCell", for: indexPath) as! RCTextMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage?.type == RC_TYPE_Feedback {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCEmojiMessageCell", for: indexPath) as! RCEmojiMessageCell
                if usedesk != nil {
                    cell.usedesk = usedesk!
                }
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage?.type == RC_TYPE_PICTURE {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCPictureMessageCell", for: indexPath) as! RCPictureMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage!.type == RC_TYPE_VIDEO {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCVideoMessageCell", for: indexPath) as! RCVideoMessageCell
                
                let rcmessage = self.rcmessage(indexPath)
                if rcmessage?.video_path == "" {
                    cell.setData(indexPath, messagesView: self)
                    UDFileManager.downloadFile(indexPath: indexPath, urlPath: rcmessage!.file?.content ?? "", successBlock: { [weak self] (indexPath, urlVideo) in
                        guard let wSelf = self else {return}
                        if let rcmessage = wSelf.rcmessage(indexPath) {
                            rcmessage.video_path = urlVideo.path
                            rcmessage.picture_image = UDFileManager.videoPreview(filePath: urlVideo.path)
                            cell.addVideo(previewImage: rcmessage.picture_image!)
                        }
                    }, errorBlock: { (error) in
                        
                    })
                } else {
                    cell.setData(indexPath, messagesView: self)
                    if rcmessage != nil {
                        cell.addVideo(previewImage: rcmessage!.picture_image ?? UDFileManager.videoPreview(filePath: rcmessage!.video_path))                    }
                }
                return cell
            }
            if rcmessage!.type == RC_TYPE_AUDIO {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCAudioMessageCell", for: indexPath) as! RCAudioMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
            if rcmessage!.type == RC_TYPE_LOCATION {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RCLocationMessageCell", for: indexPath) as! RCLocationMessageCell
                cell.bindData(indexPath, messagesView: self)
                return cell
            }
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCBubbleFooterCell", for: indexPath) as! RCBubbleFooterCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        } else /*if indexPath.row == 4 */{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionFooterCell", for: indexPath) as! RCSectionFooterCell
            cell.bindData(indexPath, messagesView: self)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "RCSectionFooterCell", for: indexPath) as! RCSectionFooterCell
        cell.bindData(indexPath, messagesView: self)
        return cell
    }
    
    // MARK: - Table view data source
    func showAttachCollection(assets: [Any]) {
        attachCollectionView.reloadData()
        isAttachFiles = true
        if !isViewInputResizeFromAttach {
            UIView.animate(withDuration: 0.3) {
                self.viewInput.frame.size.height += Constants.heightAssetsCollection
                self.viewInput.frame.origin.y -= Constants.heightAssetsCollection
                self.textInputBC.constant = 7 + Constants.heightAssetsCollection
                self.attachCollectionView.alpha = 1
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = true
            }
        }
    }
    
    func closeAttachCollection() {
        if isAttachFiles {
            isAttachFiles = false
            UIView.animate(withDuration: 0.3) {
                self.viewInput.frame.size.height -= Constants.heightAssetsCollection
                self.viewInput.frame.origin.y += Constants.heightAssetsCollection
                self.textInputBC.constant = 7
                self.attachCollectionView.alpha = 0
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = false
            }
        }
    }
    // MARK: - Helper methods
    func scroll(toBottom animated: Bool) {
        if tableView.numberOfSections > 0 {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        inputPanelUpdate()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        inputPanelUpdate()
    }
    // MARK: - Audio recorder methods
    @objc func audioRecorderGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pointAudioStart = gestureRecognizer.location(in: view)
            audioRecorderInit()
            audioRecorderStart()
        case .changed:
            break
        case .ended:
            let pointAudioStop: CGPoint? = gestureRecognizer.location(in: view)
            let distanceAudio = sqrtf(powf(Float((pointAudioStop?.x ?? 0.0) - pointAudioStart.x), 2) + Float(pow((pointAudioStop?.y ?? 0.0) - pointAudioStart.y, 2)))
            audioRecorderStop((distanceAudio < 50))
        case .possible, .cancelled, .failed:
            break
        default:
            break
        }
    }
    
    func audioRecorderInit() {
        let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let path = URL(fileURLWithPath: dir ?? "").appendingPathComponent("audiorecorder.m4a").absoluteString
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } else {
                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSessionCategoryPlayAndRecord)
            }
        } catch {
        }
        var settings: [AnyHashable : Any] = [:]
        settings[AVFormatIDKey] = NSNumber(value: kAudioFormatMPEG4AAC)
        settings[AVSampleRateKey] = NSNumber(value: 44100)
        settings[AVNumberOfChannelsKey] = NSNumber(value: 2)
        
        if let settings = settings as? [String : Any] {
            audioRecorder = try? AVAudioRecorder(url: URL(fileURLWithPath: path), settings: settings)
        }
        audioRecorder!.isMeteringEnabled = true
        audioRecorder!.prepareToRecord()
    }

    func audioRecorderStart() {
        audioRecorder!.record()
        dateAudioStart = Date()
        timerAudio = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.audioRecorderUpdate), userInfo: nil, repeats: true)
        audioRecorderUpdate()
    }
    
    func audioRecorderStop(_ sending: Bool) {
        audioRecorder?.stop()
        timerAudio?.invalidate()
        timerAudio = nil
        if (sending) && (Date().timeIntervalSince(dateAudioStart!) >= 1) {
            dismissKeyboard()
            actionSendAudio(audioRecorder!.url.path)
        } else {
            audioRecorder!.deleteRecording()
        }
        //viewInputAudio.isHidden = true
    }
    
    @objc func audioRecorderUpdate() {
//        let interval: TimeInterval = Date().timeIntervalSince(dateAudioStart!)
//        let millisec = Int(interval * 100) % 100
//        let seconds = Int(interval) % 60
//        let minutes = Int(interval) / 60
        //labelInputAudio.text = String(format: "%01d:%02d,%02d", minutes, seconds, millisec)
    }
    
}


extension RCMessagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sendAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RCAttachCollectionViewCell", for: indexPath) as! RCAttachCollectionViewCell
        cell.delegate = self
        if (sendAssets[indexPath.row] as? UIImage) != nil {
            let image = sendAssets[indexPath.row] as! UIImage
            cell.setingCell(image: image, type: PHAssetMediaType.image, index: indexPath.row)
        } else if (sendAssets[indexPath.row] as? PHAsset) != nil {
            let asset = sendAssets[indexPath.row] as! PHAsset
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)), contentMode: .aspectFit, options: options, resultHandler: { [weak self] result, info in
                guard let wSelf = self else {return}
                if result != nil {
                    cell.setingCell(image: result!, type: asset.mediaType, videoDuration: asset.duration, index: indexPath.row)
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.heightAssetsCollection, height: Constants.heightAssetsCollection)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
}

extension RCMessagesView: RCAttachCVCellDelegate {
    func deleteFile(index: Int) {
        sendAssets.remove(at: index)
        attachCollectionView.reloadData()
        if sendAssets.count == 0 {
            sendAssets = []
            buttonInputSend.isEnabled = textInput.text.count != 0
            closeAttachCollection()
        }
    }
}
