//
//  RCMessagesView.swift

import AVFoundation

class RCMessagesView: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var labelTitle1: UILabel!
    @IBOutlet weak var labelTitle2: UILabel!
    @IBOutlet weak var buttonTitle: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewLoadEarlier: UIView!
    @IBOutlet weak var viewTypingIndicator: UIView!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var buttonInputAttach: UIButton!
    @IBOutlet weak var buttonInputAudio: UIButton!
    @IBOutlet weak var buttonInputSend: UIButton!
    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var textInputHC: NSLayoutConstraint!
    @IBOutlet weak var textInputBC: NSLayoutConstraint!
    // @IBOutlet var viewInputAudio: UIView!
    //@IBOutlet var labelInputAudio: UILabel!
    @IBOutlet var labelAttachmentFile: UILabel!
    
    weak var usedesk: UseDeskSDK?

    private var initialized = false
    private var isShowKeyboard = false
    private var isChangeOffsetTable = false
    private var isViewDidLayoutSubviews = false
    private var changeOffsetTableHeight: CGFloat = 0.0
    private var heightKeyboard: CGFloat = 0.0
    private var centerView = CGPoint.zero
    private var heightView: CGFloat = 0.0
    private var timerAudio: Timer?
    private var dateAudioStart: Date?
    private var pointAudioStart = CGPoint.zero
    private var audioRecorder: AVAudioRecorder?
    private var safeAreaInsetsBottom: CGFloat = 0.0
    
    convenience init() {
        self.init(nibName: "RCMessagesView", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationItem.titleView = viewTitle
        
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
        tableView.tableHeaderView = viewLoadEarlier
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.audioRecorderGesture(_:)))
        gesture.minimumPressDuration = 0
        gesture.cancelsTouchesInView = false
        buttonInputAudio.addGestureRecognizer(gesture)
        
        //viewInputAudio.isHidden = true
        
        inputPanelInit()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightView = view.frame.size.height
        if !isViewDidLayoutSubviews {
            isViewDidLayoutSubviews = true
            if #available(iOS 11.0, *) {
                safeAreaInsetsBottom = view.safeAreaInsets.bottom
                tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.width, height: tableView.frame.height - safeAreaInsetsBottom)
            } else {
                // Fallback on earlier versions
            }
            inputPanelUpdate()
        }
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
        
        centerView = view.center
        heightView = view.frame.size.height
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    // MARK: - Load earlier methods
    func loadEarlierShow(_ show: Bool) {
        viewLoadEarlier.isHidden = !show
        var frame: CGRect = viewLoadEarlier.frame
        frame.size.height = show ? 50 : 0
        viewLoadEarlier.frame = frame
        tableView.reloadData()
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
    func textSectionHeader(_ indexPath: IndexPath?) -> String? {
        return nil
    }
    
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

    // MARK: - Typing indicator methods
    func typingIndicatorShow(_ show: Bool, animated: Bool) {
        if show {
            tableView.tableFooterView = viewTypingIndicator
            scroll(toBottom: animated)
        } else {
            UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
                self.tableView.tableFooterView = nil
            })
        }
    }
    
//    func typingIndicatorUpdate() {
//    }
    
    // MARK: - Keyboard methods
    @objc func keyboardShow(_ notification: Notification?) {
        if !isShowKeyboard {
            let info = notification?.userInfo
            
            let keyboard: CGRect? = (info?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let duration = TimeInterval((info?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            
            let keyboardHeight: CGFloat? = keyboard?.size.height
            if keyboardHeight != nil {
                heightKeyboard = keyboardHeight!
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                if self.safeAreaInsetsBottom != 0 {
                    self.textInputBC.constant = 7
                }
                self.view.center = CGPoint(x: self.centerView.x, y: self.centerView.y - (keyboardHeight ?? 0.0))
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
                if self.safeAreaInsetsBottom != 0 {
                    self.textInputBC.constant = 7 + self.safeAreaInsetsBottom
                }
                self.view.center = self.centerView
            })
            isShowKeyboard = false
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Input panel methods
    func inputPanelInit() {
        viewInput.backgroundColor = RCMessages.inputViewBackColor()
        textInput.backgroundColor = RCMessages.inputTextBackColor()
        textInput.isScrollEnabled = false
        
        textInput.font = RCMessages.inputFont()
        textInput.textColor = RCMessages.inputTextTextColor()
        
        textInput.textContainer.lineFragmentPadding = 0
        textInput.textContainerInset = RCMessages.inputInset()
   
        textInput.layer.borderColor = RCMessages.inputBorderColor()
        textInput.layer.borderWidth = RCMessages.inputBorderWidth()
        
        textInput.layer.cornerRadius = RCMessages.inputRadius()
        textInput.clipsToBounds = true
    }

    func inputPanelUpdate() {
        let widthText = textInput.frame.size.width
        var heightText: CGFloat
        let sizeText = textInput.sizeThatFits(CGSize(width: widthText, height: CGFloat(MAXFLOAT)))
        
        heightText = CGFloat(fmaxf(Float(RCMessages.inputTextHeightMin()), Float(sizeText.height)))
        heightText = CGFloat(fminf(Float(RCMessages.inputTextHeightMax()), Float(heightText)))

        var heightInput: CGFloat = 0  // + (RCMessages.inputViewHeightMin() - RCMessages.inputTextHeightMin())
        if heightText > 104 {
            heightInput = 110
            textInput.isScrollEnabled = true
        } else {
            heightInput = heightText
            textInput.isScrollEnabled = false
        }
        

        var frameViewInput: CGRect = viewInput.frame
        frameViewInput.origin.y = isShowKeyboard ? (heightView - heightInput) : (heightView - heightInput - safeAreaInsetsBottom)
        if safeAreaInsetsBottom != 0 {
            textInputBC.constant = isShowKeyboard ? 7 : safeAreaInsetsBottom + 7
        }
        frameViewInput.size.height = isShowKeyboard ? heightInput : heightInput + safeAreaInsetsBottom
         
        viewInput.frame = frameViewInput
        viewInput.layoutIfNeeded()
        
        var frameTextInput: CGRect = textInput.frame
        frameTextInput.size.height = heightInput
        textInput.frame = frameTextInput
        textInputHC.constant = heightInput
        //tableView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: heightView - heightInput)
//        var frameAudio: CGRect = buttonInputAudio.frame
//        frameAudio.origin.y = heightInput - frameAudio.size.height
//        buttonInputAudio.frame = frameAudio
        self.view.layoutIfNeeded()
        
//        var frameSend: CGRect = buttonInputSend.frame
//        frameSend.origin.y = heightInput - frameSend.size.height
       // buttonInputSend.frame = frameSend
        
//        buttonInputAudio.isHidden = textInput.text.count != 0
        buttonInputSend.isHidden = textInput.text.count == 0
        
//        let offset = CGPoint(x: 0, y: sizeText.height - heightText)
//        textInput.setContentOffset(offset, animated: false)
        
//        scroll(toBottom: false)
    }
    
    // MARK: - User actions (title)
    @IBAction func actionTitle(_ sender: Any) {
        actionTitle()
    }
    
    func actionTitle() {
    }
    
    // MARK: - User actions (load earlier)
    @IBAction func actionLoadEarlier(_ sender: Any) {
        //-------------------------------------------------------------------------------------------------------------------------------------------------
        actionLoadEarlier()
    }
    
    func actionLoadEarlier() {
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
        //if ([textInput.text length] != 0)
        //{
        actionSendMessage(textInput.text)
        dismissKeyboard()
        textInput.text = nil
        inputPanelUpdate()
        //}
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
        dismissKeyboard()
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
//                for button in cell.buttons {
//                    button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.buttonFromMessageAction)))
//                }
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
                cell.bindData(indexPath, messagesView: self)
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
    // MARK: - Helper methods
    func scroll(toBottom animated: Bool) {
        if tableView.numberOfSections > 0 {
            let indexPath = IndexPath(row: 0, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
          inputPanelUpdate()
        //typingIndicatorUpdate()
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
        //---------------------------------------------------------------------------------------------------------------------------------------------
        if let settings = settings as? [String : Any] {
            audioRecorder = try? AVAudioRecorder(url: URL(fileURLWithPath: path), settings: settings)
        }
        //---------------------------------------------------------------------------------------------------------------------------------------------
        audioRecorder!.isMeteringEnabled = true
        //---------------------------------------------------------------------------------------------------------------------------------------------
        audioRecorder!.prepareToRecord()
    }

    func audioRecorderStart() {
        audioRecorder!.record()
        //---------------------------------------------------------------------------------------------------------------------------------------------
        dateAudioStart = Date()
        //---------------------------------------------------------------------------------------------------------------------------------------------
        timerAudio = Timer.scheduledTimer(timeInterval: 0.07, target: self, selector: #selector(self.audioRecorderUpdate), userInfo: nil, repeats: true)
        //RunLoop.main.add(timerAudio!, forMode: RunLoopMode.commonModes)
        //---------------------------------------------------------------------------------------------------------------------------------------------
        audioRecorderUpdate()
        //---------------------------------------------------------------------------------------------------------------------------------------------
        //viewInputAudio.isHidden = false
    }
    
    func audioRecorderStop(_ sending: Bool) {
        audioRecorder?.stop()
        //---------------------------------------------------------------------------------------------------------------------------------------------
        timerAudio?.invalidate()
        timerAudio = nil
        //---------------------------------------------------------------------------------------------------------------------------------------------
        if (sending) && (Date().timeIntervalSince(dateAudioStart!) >= 1) {
            dismissKeyboard()
            actionSendAudio(audioRecorder!.url.path)
        } else {
            audioRecorder!.deleteRecording()
        }
        //---------------------------------------------------------------------------------------------------------------------------------------------
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
