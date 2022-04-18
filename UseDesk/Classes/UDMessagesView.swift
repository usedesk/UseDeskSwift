//
//  UDMessagesView.swift

import AVFoundation
import Photos
import PhotosUI
import Alamofire
import Swime
import MobileCoreServices
import AsyncDisplayKit
import MapKit

enum Orientation {
    case portrait
    case landscape
}

enum LandscapeOrientation {
    case left
    case right
}

class UDMessagesView: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASTableDataSource, ASTableDelegate, PHPhotoLibraryChangeObserver {

    @IBOutlet weak var viewForTable: UIView!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var viewInputHC: NSLayoutConstraint!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    // TextView input
    @IBOutlet weak var textInputViewBC: NSLayoutConstraint!
    @IBOutlet weak var textInput: UDTextView!
    @IBOutlet weak var textInputHC: NSLayoutConstraint!
    @IBOutlet weak var textInputBC: NSLayoutConstraint!
    @IBOutlet weak var textInputLC: NSLayoutConstraint!
    @IBOutlet weak var textInputTC: NSLayoutConstraint!
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var scrollButtonTC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonBC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonHC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonWC: NSLayoutConstraint!
    // Attach Collection Message
    @IBOutlet weak var attachCollectionMessageView: UICollectionView!
    @IBOutlet weak var attachCollectionMessageViewTopC: NSLayoutConstraint!
    @IBOutlet weak var attachCollectionMessageViewHC: NSLayoutConstraint!
    // Attach Button
    @IBOutlet weak var buttonAttach: UIButton!
    @IBOutlet weak var buttonAttachLC: NSLayoutConstraint!
    @IBOutlet weak var buttonAttachBC: NSLayoutConstraint!
    @IBOutlet weak var buttonAttachWC: NSLayoutConstraint!
    @IBOutlet weak var buttonAttachHC: NSLayoutConstraint!
    @IBOutlet weak var buttonAttachLoader: UIActivityIndicatorView!
    //Attach
    @IBOutlet weak var attachBackView: UIView!
    @IBOutlet weak var attachBlackView: UIView!
    @IBOutlet weak var attachCollectionView: UICollectionView!
    @IBOutlet weak var attachViewBC: NSLayoutConstraint!
    @IBOutlet weak var attachChangeView: UIView!
    @IBOutlet weak var attachSeparatorView: UIView!
    @IBOutlet weak var attachFirstButton: UIButton!
    @IBOutlet weak var attachFileButton: UIButton!
    @IBOutlet weak var attachCancelButton: UIButton! 
    // Send Button
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var buttonSendTC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendWC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendHC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendLoader: UIActivityIndicatorView!
    
    weak var usedesk: UseDeskSDK?
    
    public var draftMessages: [UDMessage] = []
    public var failMessages: [UDMessage] = []
    public var messagesWithSection: [[UDMessage]] = []
    public var messagesDidLoadFile: [UDMessage] = []
    public var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    public var safeAreaInsetsBottom: CGFloat = 0.0
    public var tableNode = ASTableNode()
    public var startDownloadFileIds: [Int] = []
    
    private let kLimitSizeFile: Double = 128
    
    private var isFirstOpen = true
    private var previousOrientation: Orientation = .portrait
    private var initialized = false
    private var isShowKeyboard = false
    private var isChangeOffsetTable = false
    private var isAttachFiles = false
    private var isViewInputResizeFromAttach = false
    private var changeOffsetTableHeight: CGFloat = 0.0
    private var centerPortait: CGPoint = CGPoint.zero
    private var centerPortaitWithKeyboard: CGPoint = CGPoint.zero
    private var centerLandscape: CGPoint = CGPoint.zero
    private var centerLandscapeWithKeyboard: CGPoint = CGPoint.zero
    private var keyboardHeightPortait: CGFloat = 0
    private var keyboardHeightLandscape: CGFloat = 0
    private var previousTextInputHeight: CGFloat = 0
    private var assetsGallery: [PHAsset] = []
    private var selectedAssets: [PHAsset] = []
    private var isAttachmentActive = false
    private var isSelectAttachment = false
    private var kHeightAttachView: CGFloat = 0
    private var imagePicker: ImagePicker!
    private var isShowAlertLimitSizeFile = false
    private var alertsLimitSizeFile: [Int : UDMessage] = [:]
    
    private var countDraftMessagesWithFile: Int {
        return draftMessages.filter({$0.type != UD_TYPE_TEXT && $0.type != UD_TYPE_EMOJI && $0.type != UD_TYPE_Feedback}).count
    }
    
    convenience init() {
        let nibName: String = "UDMessagesView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLayoutConstraint.activate([viewForTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)])
        
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        
        loader.alpha = 1
        loader.startAnimating()
        
        tableNode.backgroundColor = configurationStyle.chatStyle.backgroundColor
        self.view.backgroundColor = tableNode.backgroundColor
        tableNode.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        loadMessagesFromStorage()
        
        kHeightAttachView = 304
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom += view.safeAreaInsets.bottom
        }
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        attachCollectionMessageView.delegate = self
        attachCollectionMessageView.dataSource = self
        attachCollectionMessageView.register(UDAttachCollectionViewCell.self, forCellWithReuseIdentifier: "UDAttachCollectionViewCell")
        
        attachCollectionView.delegate = self
        attachCollectionView.dataSource = self
        attachCollectionView.register(UINib(nibName: "UDAttachSmallCollectionViewCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDAttachSmallCollectionViewCell")
        attachCollectionView.register(UINib(nibName: "UDAttachSmallCameraCollectionViewCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDAttachSmallCameraCollectionViewCell")
        
        attachBlackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeAttachView)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveMessagesDraftAndFail), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveMessagesDraftAndFail), name: UIApplication.didEnterBackgroundNotification, object: nil)

        inputPanelInit()
        
        configurationViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = view.safeAreaInsets.bottom
        }
        
        attachCollectionView.frame = CGRect(origin: attachCollectionView.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachCollectionView.frame.height))
        attachFirstButton.frame = CGRect(origin: attachFirstButton.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachFirstButton.frame.height))
        attachSeparatorView.frame = CGRect(origin: attachSeparatorView.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachSeparatorView.frame.height))
        attachFileButton.frame = CGRect(origin: attachFileButton.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachFileButton.frame.height))
        inputPanelUpdate()
        updateOrientation()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        updateOrientation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissKeyboard()
        if isFirstOpen {
            updateOrientation()
            tableNode.view.translatesAutoresizingMaskIntoConstraints = false
            viewForTable.addSubview(tableNode.view)
            let constraints = [
                tableNode.view.topAnchor.constraint(equalTo: viewForTable.topAnchor),
                tableNode.view.leftAnchor.constraint(equalTo: viewForTable.leftAnchor),
                tableNode.view.bottomAnchor.constraint(equalTo: viewForTable.bottomAnchor),
                tableNode.view.rightAnchor.constraint(equalTo: viewForTable.rightAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialized == false {
            initialized = true
        }
        if isFirstOpen {
            notSelectedAttachmentStatesViews()
            updateAttachCollectionViewLayout()
            attachCollectionView.contentOffset.x = 0
            isFirstOpen = false
            updateOrientation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    func configurationViews() {
        guard usedesk != nil else {return}
        tableNode.backgroundColor = configurationStyle.chatStyle.backgroundColor
        tableNode.view.separatorStyle = .none
        tableNode.view.scrollsToTop = true
        
        buttonAttach.setBackgroundImage(configurationStyle.attachButtonStyle.image, for: .normal)
        buttonAttachLC.constant = configurationStyle.attachButtonStyle.margin.left
        buttonAttachBC.constant = -configurationStyle.attachButtonStyle.margin.bottom
        buttonAttachWC.constant = configurationStyle.attachButtonStyle.size.width
        buttonAttachHC.constant = configurationStyle.attachButtonStyle.size.height
        
        buttonSend.setBackgroundImage(configurationStyle.sendButtonStyle.image, for: .normal)
        buttonSendTC.constant = configurationStyle.sendButtonStyle.margin.right
        buttonSendWC.constant = configurationStyle.sendButtonStyle.size.width
        buttonSendHC.constant = configurationStyle.sendButtonStyle.size.height
        
        textInput.delegate = self
        textInput.textColor = configurationStyle.inputViewStyle.placeholderTextColor
        if let messageText = draftMessages.filter({$0.type == UD_TYPE_TEXT}).first {
            if messageText.text.count > 0 {
                textInput.text = messageText.text
                textInput.textColor = configurationStyle.inputViewStyle.textColor
            } else {
                textInput.text = usedesk!.model.stringFor("Write") + "..."
                
            }
        } else {
            textInput.text = usedesk!.model.stringFor("Write") + "..."
        }
        
        textInput.isNeedCustomTextContainerInset = true
        textInput.customTextContainerInset = configurationStyle.inputViewStyle.textMargin
        
        attachFirstButton.setTitle(usedesk!.model.stringFor("Gallery"), for: .normal)
        attachFileButton.setTitle(usedesk!.model.stringFor("File").capitalized, for: .normal)
        attachCancelButton.setTitle(usedesk!.model.stringFor("Cancel"), for: .normal)
        
        attachFirstButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachFileButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        attachCollectionMessageViewTopC.constant = configurationStyle.inputViewStyle.topMarginAssetsCollection
        attachCollectionMessageViewHC.constant = configurationStyle.inputViewStyle.heightAssetsCollection
        
        if countDraftMessagesWithFile > 0 {
            showAttachCollection()
        }
        
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.contentInset.top = 4
        scrollButtonTC.constant = configurationStyle.chatStyle.scrollButtonMargin.right
        scrollButtonBC.constant = configurationStyle.chatStyle.scrollButtonMargin.bottom
        scrollButtonHC.constant = configurationStyle.chatStyle.scrollButtonSize.height
        scrollButtonWC.constant = configurationStyle.chatStyle.scrollButtonSize.width
        scrollButton.setBackgroundImage(configurationStyle.chatStyle.scrollButtonImage, for: .normal)
        scrollButton.alpha = 0
        
        buttonSend.isEnabled = false
        buttonAttach.isEnabled = false
        textInput.isUserInteractionEnabled = false
    }
    
    func loadMessagesFromStorage() {
        guard usedesk != nil else {return}
        if (usedesk!.storage as? UDStorageMessages) != nil {
            (usedesk!.storage! as! UDStorageMessages).token = usedesk!.model.token
        }
        if let messeges = usedesk!.storage?.getMessages() {
            draftMessages = messeges.filter({$0.statusSend == UD_STATUS_SEND_DRAFT})
            failMessages = messeges.filter({$0.statusSend == UD_STATUS_SEND_FAIL})
        }
    }
    
    func loadAssets() {
        assetsGallery = []
        let options = PHFetchOptions()
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.isAccessibilityElement = false
        options.sortDescriptors = sortDescriptor
        let assets = PHAsset.fetchAssets(with: options)
        assets.enumerateObjects({ (object, count, stop) in
            self.assetsGallery.append(object)
        })
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {[weak self] in
            guard let wSelf = self else {return}
            wSelf.loadAssets()
            wSelf.attachCollectionView.reloadData()
        }
    }
    
    func indexPathForMessage(at id: Int) -> IndexPath? {
        var section = 0
        var row = 0
        var flag = true
        while section < messagesWithSection.count && flag {
            while row < messagesWithSection[section].count && flag {
                if messagesWithSection[section][row].id == id {
                    flag = false
                    return IndexPath(row: row, section: section)
                }
                row += 1
            }
            row = 0
            section += 1
        }
        return nil
    }
    
    func updateOrientation() {
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
            if centerPortait == CGPoint.zero && !isFirstOpen {
                centerPortait = view.center
            }
            if keyboardHeightPortait != 0 && centerPortaitWithKeyboard == CGPoint.zero {
                centerPortaitWithKeyboard = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightPortait)
            }
            if previousOrientation != .portrait {
                self.textInputViewBC.constant =  isShowKeyboard ? keyboardHeightPortait : 0
                previousOrientation = .portrait
                attachCollectionView.reloadData()
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.view.setNeedsLayout()
                    wSelf.view.layoutIfNeeded()
                }
            }
        } else {
            if centerLandscape == CGPoint.zero && !isFirstOpen {
                centerLandscape = view.center
            }
            if keyboardHeightLandscape != 0 && centerLandscapeWithKeyboard == CGPoint.zero {
                centerLandscapeWithKeyboard = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightLandscape)
            }
            if #available(iOS 11.0, *) {
                if UIDevice.current.orientation == .landscapeLeft && previousOrientation != .landscape{
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.left
                } else if previousOrientation != .landscape {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.right
                }
            }
            if previousOrientation != .landscape {
                self.textInputViewBC.constant = isShowKeyboard ? keyboardHeightLandscape : 0
                previousOrientation = .landscape
                attachCollectionView.reloadData()
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.view.setNeedsLayout()
                    wSelf.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func saveMessagesDraftAndFail() {
        guard usedesk != nil else {return}
        var saveMessages = draftMessages + failMessages
        if !usedesk!.isCacheMessagesWithFile {
            var index = 0
            while index < saveMessages.count {
                if saveMessages[index].type == UD_TYPE_PICTURE {
                    deleteMeessage(from: &saveMessages, index: index)
                } else {
                    index += 1
                }
            }
        }
        if saveMessages.count > 0 {
            usedesk!.storage?.saveMessages(saveMessages)
        } else {
            if (usedesk!.storage as? UDStorageMessages) != nil {
                (usedesk!.storage! as! UDStorageMessages).remove()
            }
        }
    }
    
    // MARK: - Message methods
    func getMessage(_ indexPath: IndexPath?) -> UDMessage? {
        guard indexPath != nil else {return nil}
        guard indexPath!.section >= 0 else {return nil}
        guard indexPath!.row >= 0 else {return nil}
        guard messagesWithSection.count > indexPath!.section else {return nil}
        guard messagesWithSection[indexPath!.section].count > indexPath!.row else {return nil}
        return (messagesWithSection[indexPath!.section][indexPath!.row])
    }
    
    func addDraftMessage(with asset: Any, isEnabledButtonSend: Bool = true) {
        buttonSend.isEnabled = false
        let sort = countDraftMessagesWithFile + 1
        if let asset = asset as? PHAsset {
            let message = UDMessage()
            message.type = UD_TYPE_PICTURE
            message.file.sort = sort
            draftMessages.append(message)
            message.setAsset(asset: asset, isCacheFile: usedesk?.isCacheMessagesWithFile ?? false) {
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    var isShowAlertLimitSizeFile = false
                    if (message.file.data?.size ?? 0) > wSelf.kLimitSizeFile {
                        isShowAlertLimitSizeFile = true
                    }
                    var index = 0
                    var flag = true
                    while index < wSelf.draftMessages.count && flag {
                        if wSelf.draftMessages[index].file.sort == sort {
                            if isShowAlertLimitSizeFile {
                                wSelf.showAlertLimitSizeFile(with: message)
                                wSelf.updateAttachCollectionView()
                            } else {
                                wSelf.draftMessages[index] = message
                            }
                            flag = false
                        }
                        index += 1
                    }
                    guard !isShowAlertLimitSizeFile else {
                        if isEnabledButtonSend {
                            wSelf.buttonSend.isEnabled = true
                        }
                        return
                    }
                    let indexPath = IndexPath(row: wSelf.countDraftMessagesWithFile == wSelf.draftMessages.count ? index - 1 : index - 2, section: 0)
                    if let cell = wSelf.attachCollectionMessageView.cellForItem(at: indexPath) as? UDAttachCollectionViewCell {
                        if message.type == UD_TYPE_VIDEO {
                            if let previewImage = message.file.previewImage  {
                                cell.setingCell(image: previewImage, type: .video, videoDuration: message.file.duration, index: indexPath.row)
                            }
                        } else {
                            if let image = message.file.image {
                                cell.setingCell(image: image, type: .image, index: indexPath.row)
                            }
                        }
                    }
                    if isEnabledButtonSend {
                        wSelf.buttonSend.isEnabled = true
                    }
                }
            }
        } else if let image = asset as? UIImage {
            let message = UDMessage(image: image, isCacheFile: usedesk?.isCacheMessagesWithFile ?? false)
            draftMessages.append(message)
            if (message.file.data?.size ?? 0) > kLimitSizeFile {
                showAlertLimitSizeFile(with: message)
                deleteDraftMessage(with: message)
            } else if isEnabledButtonSend {
                buttonSend.isEnabled = true
            }
        } else if let urlFile = asset as? URL {
            let message = UDMessage(urlFile: urlFile, isCacheFile: usedesk?.isCacheMessagesWithFile ?? false)
            draftMessages.append(message)
            if (message.file.data?.size ?? 0) > kLimitSizeFile {
                showAlertLimitSizeFile(with: message)
                deleteDraftMessage(with: message)
            } else if isEnabledButtonSend {
                buttonSend.isEnabled = true
            }
        }
    }
    
    func deleteMeessage( from arrayMessages: inout [UDMessage], index: Int) {
        guard index < arrayMessages.count else {return}
        let file = arrayMessages[index].file
        if file.path.count > 0 {
            let url = URL(fileURLWithPath: file.path)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {}
        }
        if file.defaultPath.count > 0 {
            let url = URL(fileURLWithPath: file.defaultPath)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {}
        }
        if file.previewPath.count > 0 {
            let url = URL(fileURLWithPath: file.previewPath)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {}
        }
        arrayMessages.remove(at: index)
    }
    
    func deleteDraftMessage(with message: UDMessage) {
        if let index = draftMessages.firstIndex(of: message) {
            deleteMeessage(from: &draftMessages, index: index)
        }
    }
    
    // MARK: - Avatar methods
    
    func avatarImage(_ indexPath: IndexPath?) -> UIImage? {
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
        let info = notification.userInfo
        let keyboard: CGRect? = (info?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let duration = TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
        
        UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                self.keyboardHeightPortait = CGFloat(keyboard?.size.height ?? 0)
            } else {
                if self.view.center == self.centerLandscape {
                    self.keyboardHeightLandscape = CGFloat(keyboard?.size.height ?? 0)
                }
            }
            var keyboardHeight = self.previousOrientation == .portrait ? self.keyboardHeightPortait : self.keyboardHeightLandscape
            if CGFloat(keyboard?.size.height ?? 0) > keyboardHeight {
                keyboardHeight = CGFloat(keyboard?.size.height ?? 0)
            }
            self.textInputViewBC.constant = keyboardHeight
            self.tableNode.style.width = ASDimensionMake(self.viewForTable.frame.width)
            self.tableNode.style.height = ASDimensionMake(self.viewForTable.frame.height)
            self.view.layoutIfNeeded()
        })
        isShowKeyboard = true
        inputPanelUpdate()
    }
    
    @objc func keyboardHide(_ notification: Notification?) {
        if isShowKeyboard {
            let info = notification?.userInfo
            let duration = TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                self.textInputViewBC.constant = 0
                self.view.layoutIfNeeded()
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
        let configurationStyle: ConfigurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        viewInput.backgroundColor = configurationStyle.inputViewStyle.viewBackColor
        textInput.backgroundColor = configurationStyle.inputViewStyle.textBackColor
        textInput.isScrollEnabled = true
        
        textInput.font = configurationStyle.inputViewStyle.font
        
        textInput.layer.borderColor = configurationStyle.inputViewStyle.inputTextViewBorderColor
        textInput.layer.borderWidth = configurationStyle.inputViewStyle.inputTextViewBorderWidth
        
        textInput.layer.cornerRadius = configurationStyle.inputViewStyle.inputTextViewRadius
        textInput.clipsToBounds = true
    }

    func inputPanelUpdate() {
        guard usedesk != nil else {return}
        let inputViewStyle = configurationStyle.inputViewStyle
        var heightText: CGFloat
        heightText = textInput.contentSize.height
        var heightInput: CGFloat = 0
        if heightText > inputViewStyle.textHeightMax {
            heightInput = inputViewStyle.textHeightMax
        } else {
            heightInput = heightText < inputViewStyle.textHeightMin ? inputViewStyle.textHeightMin : heightText
            previousTextInputHeight = heightText
        }
        heightInput += inputViewStyle.textMargin.top + inputViewStyle.textMargin.bottom
        if safeAreaInsetsBottom != 0 {
            textInputBC.constant = isShowKeyboard ? inputViewStyle.inputTextViewMargin.bottom : safeAreaInsetsBottom + inputViewStyle.inputTextViewMargin.bottom
        }
        viewInputHC.constant = isShowKeyboard ? heightInput + (inputViewStyle.inputTextViewMargin.bottom + inputViewStyle.inputTextViewMargin.top) : heightInput + safeAreaInsetsBottom + (inputViewStyle.inputTextViewMargin.bottom + inputViewStyle.inputTextViewMargin.top)
        if isAttachFiles {
            viewInputHC.constant += isShowKeyboard ? configurationStyle.inputViewStyle.heightAssetsCollection + configurationStyle.inputViewStyle.topMarginAssetsCollection : configurationStyle.inputViewStyle.heightAssetsCollection + configurationStyle.inputViewStyle.topMarginAssetsCollection
            textInputBC.constant = isShowKeyboard ? inputViewStyle.inputTextViewMargin.bottom + configurationStyle.inputViewStyle.heightAssetsCollection + configurationStyle.inputViewStyle.topMarginAssetsCollection : inputViewStyle.inputTextViewMargin.bottom + configurationStyle.inputViewStyle.heightAssetsCollection + configurationStyle.inputViewStyle.topMarginAssetsCollection + safeAreaInsetsBottom
        }
        
        buttonAttachLC.constant = configurationStyle.attachButtonStyle.margin.left
        buttonSendTC.constant = configurationStyle.sendButtonStyle.margin.right
        textInputTC.constant = configurationStyle.sendButtonStyle.margin.right + configurationStyle.sendButtonStyle.size.width + configurationStyle.sendButtonStyle.margin.left
        textInputLC.constant = configurationStyle.attachButtonStyle.margin.right + configurationStyle.attachButtonStyle.size.width + configurationStyle.attachButtonStyle.margin.left
        
        if UIScreen.main.bounds.height <= UIScreen.main.bounds.width {
            buttonAttachLC.constant = buttonAttachLC.constant + safeAreaInsetsLeftOrRight
            buttonSendTC.constant = buttonSendTC.constant + safeAreaInsetsLeftOrRight
            textInputTC.constant = textInputTC.constant + safeAreaInsetsLeftOrRight
            textInputLC.constant = textInputLC.constant + safeAreaInsetsLeftOrRight
        }
        textInputHC.constant = heightInput
        
        // активировать ли кнопку отправки сообщения
        if countDraftMessagesWithFile > 0 { // если есть прикрепленные файлы
            if draftMessages.filter({$0.status == 0 && $0.type != 1}).count != 0 { // если есть не загруженные прикрепленные файлы кнопку не активна
                buttonSend.isEnabled = false
            } else if (textInput.text == usedesk!.model.stringFor("Write") + "..." && textInput.textColor == configurationStyle.inputViewStyle.placeholderTextColor) { // если текста сообщения нету
                buttonSend.isEnabled = true
            } else {
                if textInput.text.count == 0 {
                    buttonSend.isEnabled = true // если сообщение отсутствует кнопка активна
                } else {
                    buttonSend.isEnabled = textInput.text.udRemoveFirstSpaces().count != 0 // если сообщение не пустое то кнопка активна
                }
            }
        } else { // если нет прикрепленных файлов
            if (textInput.text == usedesk!.model.stringFor("Write") + "..." && textInput.textColor == configurationStyle.inputViewStyle.placeholderTextColor) { // если текста сообщения нету
                buttonSend.isEnabled = false //если файлов прикрепленных нет, то кнопка не активна
            } else {
                if textInput.text.count == 0 {
                    buttonSend.isEnabled = false // если сообщение отсутствует кнопка не активна
                } else {
                    buttonSend.isEnabled = textInput.text.udRemoveFirstSpaces().count != 0 // если сообщение не пустое то кнопка активна
                }
            }
        }
    }
    
    // MARK: - User actions (bubble tap)
    func actionTapBubble(_ indexPath: IndexPath?) {
    }

    // MARK: - User actions (input panel)
    @IBAction func actionInputAttach(_ sender: Any) {
        dismissKeyboard()
        actionAttachMessage()
    }
    
    @IBAction func actionInputSend(_ sender: Any) {
        guard usedesk != nil else {return}
        actionSendMessage()
        if !((textInput.text == usedesk!.model.stringFor("Write") + "..." && textInput.textColor == configurationStyle.inputViewStyle.placeholderTextColor)) {
            textInput.text = ""
        }
        inputPanelUpdate()
    }
    
    @IBAction func attachFirstButtonAction(_ sender: Any) {
        if selectedAssets.count > 0 {
            for index in 0..<selectedAssets.count {
                addDraftMessage(with: selectedAssets[index], isEnabledButtonSend: index == selectedAssets.count - 1)
            }
            closeAttachView()
            showAttachCollection()
        } else {
            selectPhoto()
        }
    }
    
    @IBAction func attachFileButtonAction(_ sender: Any) {
        var maxCountAssets = 10
        if usedesk != nil {
            maxCountAssets = usedesk!.maxCountAssets
        }
        if countDraftMessagesWithFile < maxCountAssets {
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            present(importMenu, animated: true, completion: nil)
        } else {
            showAlertMaxCountAttach()
        }
    }
    
    @IBAction func attachCancelAction(_ sender: Any) {
        selectedAssets = []
        closeAttachView()
    }
    
    @objc func buttonFromMessageAction() {
    }
    
    func actionAttachMessage() {
        guard usedesk != nil else {return}
        PHPhotoLibrary.shared().register(self)
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined || photos == .denied {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    if status == .notDetermined || status == .denied {
                        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                            AVCaptureDevice.requestAccess(for: .video) { success in
                                DispatchQueue.main.async { [weak self] in
                                    guard let wSelf = self else {return}
                                    wSelf.showAlertAllowMedia()
                                }
                            }
                        } else {
                            wSelf.showAlertAllowMedia()
                        }
                    } else {
                        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
                            AVCaptureDevice.requestAccess(for: .video) { success in
                                DispatchQueue.main.async { [weak self] in
                                    guard let wSelf = self else {return}
                                    wSelf.checkMaxCountAssetsAndShowAttachView()
                                }
                            }
                        } else {
                            wSelf.checkMaxCountAssetsAndShowAttachView()
                        }
                    }
                }
            }
        } else {
            checkMaxCountAssetsAndShowAttachView()
        }
    }
    
    func showAlertAllowMedia() {
        guard usedesk != nil else {return}
        let alert = UIAlertController(title:usedesk!.model.stringFor("AllowMedia"), message: usedesk!.model.stringFor("ToSendMedia"), preferredStyle: .alert)
        let goToSettingsAction = UIAlertAction(title: usedesk!.model.stringFor("GoToSettings"), style: .default) { (action) in
            DispatchQueue.main.async {
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options:convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]))
            }
        }
        let canselAction = UIAlertAction(title: usedesk!.model.stringFor("Cancel"), style: .cancel)
        alert.addAction(goToSettingsAction)
        alert.addAction(canselAction)
        self.present(alert, animated: true)
    }
    
    func actionSendMessage() {
    }
    
    @IBAction func scrollButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != textInput {
            dismissKeyboard()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != textInput {
            if tableNode.contentOffset.y > 30 && scrollButton.alpha == 0 {
                UIView.animate(withDuration: 0.1) {
                    self.scrollButton.alpha = 1
                }
            } else if tableNode.contentOffset.y <= 30 && scrollButton.alpha == 1 {
                UIView.animate(withDuration: 0.1) {
                    self.scrollButton.alpha = 0
                }
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let lastIndexSection = messagesWithSection.count - 1
        if lastIndexSection < messagesWithSection.count {
            let indexPath = IndexPath(row: self.messagesWithSection[lastIndexSection].count - 1, section: lastIndexSection)
            guard tableNode.nodeForRow(at: indexPath) != nil else {return false}
            UIView.animate(withDuration: 0.3) {
                self.tableNode.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        return false
    }
    
    // MARK: - Attach Methods
    func checkMaxCountAssetsAndShowAttachView() {
        if assetsGallery.count == 0 {
            loadAssets()
        }
        var maxCountAssets = 10
        if usedesk != nil {
            maxCountAssets = usedesk!.maxCountAssets
        }
        if countDraftMessagesWithFile < maxCountAssets {
            buttonAttach.alpha = 0
            buttonAttachLoader.alpha = 1
            buttonAttachLoader.startAnimating()
            showAttachView()
        } else {
            showAlertMaxCountAttach()
        }
    }
    
    func showAttachCollection() {
        guard countDraftMessagesWithFile > 0 else {return}
        attachCollectionMessageView.reloadData()
        isAttachFiles = true
        if !isViewInputResizeFromAttach {
            UIView.animate(withDuration: 0.3) {
                self.viewInputHC.constant += self.configurationStyle.inputViewStyle.heightAssetsCollection
                self.textInputBC.constant = 7 + self.configurationStyle.inputViewStyle.heightAssetsCollection
                self.attachCollectionMessageView.alpha = 1
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = true
            }
        }
    }
    
    func closeAttachCollection() {
        if isAttachFiles {
            isAttachFiles = false
            UIView.animate(withDuration: 0.3) {
                self.viewInputHC.constant -= self.configurationStyle.inputViewStyle.heightAssetsCollection
                self.textInputBC.constant = 7
                self.attachCollectionMessageView.alpha = 0
                self.view.layoutIfNeeded()
                self.isViewInputResizeFromAttach = false
            }
        }
    }
    
    func showAttachView() {
        guard usedesk != nil else {return}
        selectedAssets = []
        isAttachmentActive = true
        attachFirstButton.setTitle(usedesk!.model.stringFor("Gallery"), for: .normal)
        if assetsGallery.count > 0 {
            attachCollectionView.reloadData()
            attachCollectionView.contentOffset.x = 0
            UIView.animate(withDuration: 0.4) {
                self.attachBackView.alpha = 1
                self.attachViewBC.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            checkAccessCameraAndOpenCamera()
        }
        buttonAttach.alpha = 1
        buttonAttachLoader.alpha = 0
        buttonAttachLoader.stopAnimating()
    }
    
    @objc func closeAttachView() {
        guard usedesk != nil else {return}
        selectedAssets = []
        isAttachmentActive = false
        isSelectAttachment = false
        attachCollectionView.collectionViewLayout.invalidateLayout()
        notSelectedAttachmentStatesViews()
        UIView.animate(withDuration: 0.4, animations: {
            self.attachBackView.alpha = 0
            self.attachViewBC.constant = -self.kHeightAttachView
            self.view.layoutIfNeeded()
        }) { (_) in
            self.attachFirstButton.setTitle(self.usedesk!.model.stringFor("Gallery"), for: .normal)
            self.attachCollectionView.contentOffset.x = 0
            self.attachCollectionView.reloadData()
        }
    }
    
    func takePhotoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            present(picker, animated: true)
        }
    }
    
    func checkAccessCameraAndOpenCamera() {
        guard usedesk != nil else {return}
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            takePhotoCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video) {  [weak self] success in
                guard let wSelf = self else {return}
                if !success {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: wSelf.usedesk!.model.stringFor("AllowCamera"), message: wSelf.usedesk!.model.stringFor("ToSendMedia"), preferredStyle: .alert)
                        let goToSettingsAction = UIAlertAction(title: wSelf.usedesk!.model.stringFor("GoToSettings"), style: .default) { (action) in
                            DispatchQueue.main.async {
                                let url = URL(string: UIApplication.openSettingsURLString)
                                UIApplication.shared.open(url!, options:[:])
                            }
                        }
                        let canselAction = UIAlertAction(title: wSelf.usedesk!.model.stringFor("Cancel"), style: .cancel)
                        alert.addAction(goToSettingsAction)
                        alert.addAction(canselAction)
                        wSelf.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    func selectPhoto() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            let maxCountAssets = usedesk != nil ? usedesk!.maxCountAssets - countDraftMessagesWithFile : 10 - countDraftMessagesWithFile
            configuration.selectionLimit = maxCountAssets
            if usedesk!.isSupportedAttachmentOnlyPhoto {
                configuration.filter = .images
            } else if usedesk!.isSupportedAttachmentOnlyVideo {
                configuration.filter = .videos
            }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            imagePicker.present()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.originalImage] as? UIImage
        if chosenImage != nil {
            addDraftMessage(with: chosenImage!.udFixedOrientation())
            buttonSend.isHidden = false
            closeAttachView()
            showAttachCollection()
        }
        picker.dismiss(animated: true)
    }
    
    func updateAttachCollectionViewLayout() {
        let attachCollectionLayout = UDAttachSmallCollectionLayout()
        attachCollectionLayout.scrollDirection = .horizontal
        attachCollectionLayout.delegate = self
        attachCollectionView.isScrollEnabled = true
        attachCollectionView.setCollectionViewLayout(attachCollectionLayout, animated: true)
    }
    
    func updateAttachCollectionView() {
        attachCollectionMessageView.reloadData()
        if countDraftMessagesWithFile == 0 {
            buttonSend.isEnabled = textInput.text.udRemoveFirstSpaces().count != 0
            closeAttachCollection()
        }
    }
    
    func selectedAttachmentStatesViews() {
        UIView.animate(withDuration: 0.3) {
            self.attachSeparatorView.alpha = 0
            self.attachCollectionView.frame = CGRect(x: 0, y: 8, width: self.attachChangeView.frame.size.width, height: 146)
            self.attachFirstButton.frame = CGRect(x: 0, y: 8 + 146 + 6, width: self.attachChangeView.frame.size.width, height: 57)
            self.attachSeparatorView.frame = CGRect(x: 0, y: 8 + 146 + 6 + 57, width: self.attachChangeView.frame.size.width, height: 0.5)
            self.attachFileButton.frame = CGRect(x: 0, y: 8 + 146 + 6 + 57 + 0.5, width: self.attachChangeView.frame.size.width, height: 57)
        }
    }
    
    func notSelectedAttachmentStatesViews() {
        UIView.animate(withDuration: 0.3) {
            self.attachSeparatorView.alpha = 1
            self.attachCollectionView.frame = CGRect(x: 0, y: 8, width: self.attachChangeView.frame.size.width, height: 85)
            self.attachFirstButton.frame = CGRect(x: 0, y: 8 + 85 + 11, width: self.attachChangeView.frame.size.width, height: 57)
            self.attachSeparatorView.frame = CGRect(x: 0, y: 8 + 85 + 11 + 57, width: self.attachChangeView.frame.size.width, height: 0.5)
            self.attachFileButton.frame = CGRect(x: 0, y: 8 + 85 + 11 + 57 + 0.5, width: self.attachChangeView.frame.size.width, height: 57)
        }
    }
    
    func showAlertMaxCountAttach() {
        guard usedesk != nil else {return}
        let alertController = UIAlertController(title: usedesk!.model.stringFor("AttachmentLimit"), message: nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: usedesk!.model.stringFor("Ok"), style: .default) { (_) -> Void in }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertLimitSizeFile(with message: UDMessage) {
        guard usedesk != nil else {return}
        var indexAlert = 0
        indexAlert = alertsLimitSizeFile.count
        let sizeFile = message.file.size(mbString: usedesk!.model.stringFor("Mb"), gbString: usedesk!.model.stringFor("Gb"))
        let messageString = usedesk!.model.stringFor("ThisFileSize") + " " + sizeFile + " " + usedesk!.model.stringFor("ExceededMaximumSize") + " \(kLimitSizeFile) " + usedesk!.model.stringFor("Mb")
        let alertController = UIAlertController(title: usedesk!.model.stringFor("LimitIsExceeded"), message: messageString, preferredStyle: .alert)
        switch message.file.sourceType {
        case .PHAsset:
            if message.type == UD_TYPE_VIDEO {
                if let image = message.file.previewImage {
                    alertController.udAdd(image: image, isVideo: true)
                }
            } else {
                if let image = message.file.image {
                    alertController.udAdd(image: image)
                }
            }
        case .UIImage:
            if let image = message.file.image {
                alertController.udAdd(image: image)
            }
        case .URL:
            alertController.udAdd(image: previewFileForLimitSizeAlert(file: message.file).udImage())
        default:
            break
        }
        let understandAction = UIAlertAction(title: usedesk!.model.stringFor("Understand"), style: .default) { [weak self] (action) in
            guard let wSelf = self else {return}
            wSelf.isShowAlertLimitSizeFile = false
            if let alertLimitSizeFile = wSelf.alertsLimitSizeFile.first {
                wSelf.showAlertLimitSizeFile(with: alertLimitSizeFile.value)
                if let deleteIndex = wSelf.alertsLimitSizeFile.firstIndex(where: { $0.key == alertLimitSizeFile.key }) {
                    wSelf.alertsLimitSizeFile.remove(at: deleteIndex)
                }
            }
            wSelf.deleteDraftMessage(with: message)
            wSelf.updateAttachCollectionView()
        }
        alertController.addAction(understandAction)
        if isShowAlertLimitSizeFile {
            alertsLimitSizeFile[indexAlert] = message
        } else {
            isShowAlertLimitSizeFile = true
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func previewFileForLimitSizeAlert(file: UDFile) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        containerView.backgroundColor = .clear
        // icon
        let iconFileImageView = UIImageView(image: UIImage.named("udFileIcon"))
        iconFileImageView.frame = CGRect(x: 110, y: 10, width: 80, height: 80)
        containerView.addSubview(iconFileImageView)
        // name
        let label = UILabel(frame: CGRect(x: 5, y: 110, width: 290, height: 30))
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.text = file.name
        label.textAlignment = .center
        containerView.addSubview(label)
        return containerView
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        inputPanelUpdate()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        inputPanelUpdate()
        if textView.text.udRemoveFirstSpaces().count > 0 {
            if draftMessages.filter({$0.type == UD_TYPE_TEXT}).count > 0 {
                draftMessages.filter({$0.type == UD_TYPE_TEXT})[0].text = textView.text
            } else {
                draftMessages.insert(UDMessage(text: textView.text), at: 0)
            }
        } else {
            if let draftTextMessages = draftMessages.filter({$0.type == UD_TYPE_TEXT}).first {
                deleteDraftMessage(with: draftTextMessages)
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard usedesk != nil else {return}
        if textView == textInput {
            if (textView.text == usedesk!.model.stringFor("Write") + "..." && textView.textColor == configurationStyle.inputViewStyle.placeholderTextColor) {
                textInput.text = ""
                textInput.textColor = configurationStyle.inputViewStyle.textColor
            }
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard usedesk != nil else {return}
        if textView == textInput {
            if (textView.text == "") {
                textInput.text = usedesk!.model.stringFor("Write") + "..."
                textInput.textColor = configurationStyle.inputViewStyle.placeholderTextColor
            }
        }
    }
    
    // MARK: - ASTableDataSource
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return messagesWithSection.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return messagesWithSection[section].count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        if usedesk != nil {
            if usedesk?.model.operatorName != "" {
                if let message = getMessage(indexPath) {
                    message.operatorName = usedesk!.model.operatorName
                }
            }
        }
        let message: UDMessage? = getMessage(indexPath)
        var isNeedShowSender = true
        if let previousMessage = getMessage(IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
            if (message?.typeSenderMessage == previousMessage.typeSenderMessage) && message?.incoming ?? true && previousMessage.incoming {
                isNeedShowSender = false
                if previousMessage.typeSenderMessage == .operator_to_client {
                    isNeedShowSender = message?.operatorId == previousMessage.operatorId ? false : true
                }
            }
        }
        if message?.type == UD_TYPE_TEXT {
            let cell = UDTextMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.delegateText = self
            return cell
        } else if message?.type == UD_TYPE_Feedback {
            let cell = UDFeedbackMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.usedesk = usedesk
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else  if message?.type == UD_TYPE_PICTURE {
            let cell = UDPictureMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        } else if message?.type == UD_TYPE_VIDEO {
            let cell = UDVideoMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        } else { //message?.type == UD_TYPE_File
            let cell = UDFileMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.usedesk = usedesk
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard let cell = node as? UDMessageCellNode else { return }
        cell.updateAnimateLoader()
        guard let indexPath = cell.indexPath else { return }
        let countAnySizeFiles = 10
        let countSmallSizeFiles = 40
        for index in indexPath.row..<indexPath.row + countAnySizeFiles {
            if let cellDownload = tableNode.nodeForRow(at: IndexPath(row: index, section: indexPath.section)) as? UDMessageCellNode {
                if !startDownloadFileIds.contains(cellDownload.message.id) {
                    startDownloadFileIds.append(cellDownload.message.id)
                    downloadFile(node: cellDownload)
                }
            }
        }
        for index in indexPath.row + countAnySizeFiles..<indexPath.row + countAnySizeFiles + countSmallSizeFiles {
            if let cellDownload = tableNode.nodeForRow(at: IndexPath(row: index, section: indexPath.section)) as? UDMessageCellNode {
                if cellDownload.message.file.sizeValue < 524288 && !startDownloadFileIds.contains(cellDownload.message.id) {
                    startDownloadFileIds.append(cellDownload.message.id)
                    downloadFile(node: cellDownload)
                } 
            }
        }
    }
    
    func downloadFile(node: UDMessageCellNode) {
        let isFileNotDidLoad = messagesDidLoadFile.filter({$0.id == node.message.id}).count == 0
        if let pictureCell = node as? UDPictureMessageCellNode {
            if let indexPath = pictureCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == UD_STATUS_SUCCEED && pictureCell.message != message && isFileNotDidLoad {
                    pictureCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    pictureCell.setNeedsLayout()
                } else {
                    guard message.file.path == "" else { return }
                    // download image
                    DispatchQueue.global(qos: .userInitiated).async {
                        let session = URLSession.shared
                        autoreleasepool {
                            guard let url = URL(string: message.file.content) else { return }
                            (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                                guard let wSelf = self else {return}
                                if error == nil {
                                    let udMineType = UDMimeType()
                                    let mimeType = udMineType.typeString(for: data)
                                    DispatchQueue.main.async { [weak self] in
                                        guard let wSelf = self else {return}
                                        if let indexPathPicture = wSelf.indexPathForMessage(at: message.id) {
                                            wSelf.messagesDidLoadFile.append(message)
                                            message.status = UD_STATUS_SUCCEED
                                            if (mimeType == "image") {
                                                message.file.path = FileManager.default.udWriteDataToCacheDirectory(data: data!) ?? ""
                                                message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? "Image") : "Image"
                                                message.file.type = "image"
                                                wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                            } else {
                                                message.file.type = mimeType
                                                wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                            }
                                            wSelf.tableNode.reloadRows(at: [indexPathPicture], with: .none)
                                        }
                                    }
                                } else if let index = wSelf.startDownloadFileIds.firstIndex(of: message.id) {
                                        wSelf.startDownloadFileIds.remove(at: index)
                                }
                            })).resume()
                        }
                    }
                }
            }
        } else if let videoCell = node as? UDVideoMessageCellNode {
            if let indexPath = videoCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == UD_STATUS_SUCCEED && videoCell.message != message && isFileNotDidLoad {
                    videoCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    videoCell.setNeedsLayout()
                } else {
                    if message.file.path == "" && message.file.content != "" {
                        UDFileManager.downloadFile(indexPath: indexPath, urlPath: message.file.content, name: message.file.name, extansion: message.file.typeExtension) { [weak self] (indexPath, url) in
                            guard let wSelf = self else {return}
                            DispatchQueue.main.async {
                                if let indexPathVideo = wSelf.indexPathForMessage(at: message.id) {
                                    wSelf.messagesDidLoadFile.append(message)
                                    message.file.path = url.path
                                    message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                    message.status = UD_STATUS_SUCCEED
                                    wSelf.messagesWithSection[indexPathVideo.section][indexPathVideo.row] = message
                                    wSelf.tableNode.reloadRows(at: [indexPathVideo], with: .none)
                                }
                            }
                        } errorBlock: { [weak self] _ in
                            guard let wSelf = self else {return}
                            if let index = wSelf.startDownloadFileIds.firstIndex(of: message.id) {
                                wSelf.startDownloadFileIds.remove(at: index)
                            }
                        }
                    }
                }
            }
        } else if let fileCell = node as? UDFileMessageCellNode {
            if let indexPath = fileCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == UD_STATUS_SUCCEED && fileCell.message != message && isFileNotDidLoad {
                    fileCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    fileCell.setNeedsLayout()
                } else {
                    if message.file.path == "" {
                        let session = URLSession.shared
                        if let url = URL(string: message.file.content) {
                            DispatchQueue.global(qos: .userInitiated).async {
                                (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                                    guard let wSelf = self else {return}
                                    if error == nil && data != nil {
                                        DispatchQueue.main.async {
                                            wSelf.messagesDidLoadFile.append(message)
                                            var isFile = true
                                            message.status = UD_STATUS_SUCCEED
                                            guard let indexPathFile = wSelf.indexPathForMessage(at: message.id) else { return }
                                            if let mimeType = Swime.mimeType(data: data!) {
                                                if mimeType.mime.contains("video") {
                                                    message.type = UD_TYPE_VIDEO
                                                    message.file.path = NSURL(fileURLWithPath: FileManager.default.udWriteDataToCacheDirectory(data: data!) ?? "").path ?? ""
                                                    message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                                    message.file.type = "video"
                                                    isFile = false
                                                } else if mimeType.mime.contains("image") {
                                                    message.file.path = FileManager.default.udWriteDataToCacheDirectory(data: data!) ?? ""
                                                    message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? "Image") : "Image"
                                                    message.file.type = "image"
                                                    isFile = false
                                                }
                                                if !isFile {
                                                    wSelf.messagesWithSection[indexPathFile.section][indexPathFile.row] = message
                                                    wSelf.tableNode.reloadRows(at: [indexPathFile], with: .none)
                                                }
                                            }
                                            if isFile {
                                                message.file.path = NSURL(fileURLWithPath: FileManager.default.udWriteDataToCacheDirectory(data: data!) ?? "").path ?? ""
                                                message.file.type = "file"
                                                message.file.sizeInt = data!.count
                                                wSelf.messagesWithSection[indexPathFile.section][indexPathFile.row] = message
                                                if let cell = (wSelf.tableNode.nodeForRow(at: indexPathFile) as? UDFileMessageCellNode) {
                                                    cell.removeLoader()
                                                    cell.setNeedsLayout()
                                                    cell.layoutIfNeeded()
                                                } else {
                                                    wSelf.tableNode.reloadRows(at: [indexPathFile], with: .none)
                                                }
                                            }
                                        }
                                    } else if let index = wSelf.startDownloadFileIds.firstIndex(of: message.id) {
                                            wSelf.startDownloadFileIds.remove(at: index)
                                    }
                                })).resume()
                            }
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = UDSectionHeaderCell()
        cell.usedesk = usedesk
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        cell.bindData(IndexPath(row: 0, section: section), messagesView: self)
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return configurationStyle.sectionHeaderStyle.heightHeader
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if view is UDSectionHeaderCell {
            (view as! UDSectionHeaderCell).backView.alpha = 1
        }
    }
}

// MARK: - UICollectionViewDelegate
extension UDMessagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == attachCollectionView {
            return assetsGallery.count + 1
        } else {
            return countDraftMessagesWithFile
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == attachCollectionView {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDAttachSmallCameraCollectionViewCell", for: indexPath) as! UDAttachSmallCameraCollectionViewCell
                if isAttachmentActive {
                    DispatchQueue.main.async {
                        switch UIDevice.current.orientation {
                        case .portrait:
                            cell.orientation = .portrait
                        case .landscapeRight:
                            cell.orientation = .landscapeLeft
                        case .landscapeLeft:
                            cell.orientation = .landscapeRight
                        default:
                            cell.orientation = .portrait
                        }
                        cell.createSession()
                    }
                } else {
                    cell.stopSession()
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDAttachSmallCollectionViewCell", for: indexPath) as! UDAttachSmallCollectionViewCell
                let asset = assetsGallery[indexPath.row - 1]
                let manager = PHImageManager.default()
                let width = isSelectAttachment ? 100 : 85
                let height = isSelectAttachment ? 146 : 85

                manager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFill, options: nil) {  (result, _) in
                    cell.imageView?.image = result
                }
                
                if assetsGallery[indexPath.row - 1].mediaType == .video {
                    cell.videoView.alpha = 1
                    cell.videoTimeLabel.text = Int(assetsGallery[indexPath.row - 1].duration).timeString()
                } else {
                    cell.videoView.alpha = 0
                }
                if selectedAssets.contains(assetsGallery[indexPath.row - 1]) {
                    cell.setSelected(number: selectedAssets.firstIndex(of: assetsGallery[indexPath.row - 1])! + 1)
                } else {
                    cell.notSelected()
                }
                cell.indexPath = indexPath
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDAttachCollectionViewCell", for: indexPath) as! UDAttachCollectionViewCell
            cell.configurationStyle = configurationStyle
            cell.delegate = self
            guard indexPath.row < countDraftMessagesWithFile else { return cell }
            var index = indexPath.row
            if draftMessages.count != countDraftMessagesWithFile {
                index += 1
            }
            let file = draftMessages[index].file
            if file.sourceType == .UIImage || file.sourceType == .PHAsset {
                if draftMessages[index].type == UD_TYPE_VIDEO {
                    if let previewImage = file.previewImage  {
                        cell.setingCell(image: previewImage, type: .video, videoDuration: file.duration, index: indexPath.row)
                    }
                } else {
                    if let image = file.image {
                        cell.setingCell(image: image, type: .image, index: indexPath.row)
                    }
                }
            } else if file.sourceType == .URL {
                let path = file.path.count > 0 ? file.path : file.defaultPath
                cell.setingCell(type: .file, urlFile: URL(string: path), index: indexPath.row)
            } else {
                cell.setingCell(type: nil, index: indexPath.row)
                cell.showLoader()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: configurationStyle.inputViewStyle.heightAssetsCollection, height: configurationStyle.inputViewStyle.heightAssetsCollection)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard usedesk != nil else {return}
        if collectionView == attachCollectionView {
            var maxCountAssets = 10
            if usedesk != nil {
                maxCountAssets = usedesk!.maxCountAssets
            }
            if indexPath.row == 0 {
                if (countDraftMessagesWithFile + selectedAssets.count < maxCountAssets) {
                    checkAccessCameraAndOpenCamera()
                } else {
                    showAlertMaxCountAttach()
                }
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as! UDAttachSmallCollectionViewCell
                if (countDraftMessagesWithFile + selectedAssets.count < maxCountAssets) || cell.isActive {
                    if cell.isActive {
                        selectedAssets.remove(at: selectedAssets.firstIndex(of: assetsGallery[indexPath.row - 1])!)
                    } else {
                        selectedAssets.append(assetsGallery[indexPath.row - 1])
                    }
                    if selectedAssets.count > 0 {
                        isSelectAttachment = true
                        attachFirstButton.setTitle("\(usedesk!.model.stringFor("Attach")) \(selectedAssets.count.countFilesString(usedesk!))", for: .normal)
                        if let cell = attachCollectionView.cellForItem(at: indexPath) as? UDAttachSmallCollectionViewCell {
                            if selectedAssets.contains(assetsGallery[indexPath.row - 1]) {
                                cell.setSelected(number: selectedAssets.firstIndex(of: assetsGallery[indexPath.row - 1])! + 1)
                            } else {
                                cell.notSelected()
                            }
                        }
                        updateAttachCollectionViewLayout()
                        selectedAttachmentStatesViews()
                        for visibleCell in attachCollectionView.visibleCells {
                            if let cell = visibleCell as? UDAttachSmallCollectionViewCell {
                                if selectedAssets.contains(assetsGallery[cell.indexPath.row - 1]) {
                                    cell.setSelected(number: selectedAssets.firstIndex(of: assetsGallery[cell.indexPath.row - 1])! + 1)
                                } else {
                                    cell.notSelected()
                                }
                            }
                        }
                        if let cell = attachCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? UDAttachSmallCameraCollectionViewCell {
                            cell.createSession()
                        }
                    } else {
                        isSelectAttachment = false
                        attachFirstButton.setTitle(usedesk!.model.stringFor("Gallery"), for: .normal)
                        if let cell = attachCollectionView.cellForItem(at: indexPath) as? UDAttachSmallCollectionViewCell {
                            cell.notSelected()
                        }
                        updateAttachCollectionViewLayout()
                        notSelectedAttachmentStatesViews()
                        for visibleCell in attachCollectionView.visibleCells {
                            if let cell = visibleCell as? UDAttachSmallCollectionViewCell {
                                if selectedAssets.contains(assetsGallery[cell.indexPath.row - 1]) {
                                    cell.setSelected(number: selectedAssets.firstIndex(of: assetsGallery[cell.indexPath.row - 1])! + 1)
                                } else {
                                    cell.notSelected()
                                }
                            }
                        }
                    }
                    
                } else {
                    showAlertMaxCountAttach()
                }
            }
        }
    }
}
// MARK: - UIDocumentPickerDelegate
extension UDMessagesView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            addDraftMessage(with: urls[0])
        }
        closeAttachView()
        showAttachCollection()
    }
}

// MARK: - AttachCollectionLayoutDelegate
extension UDMessagesView: UDAttachSmallCollectionLayoutDelegate {
    func sizeCell() -> CGSize {
        return isSelectAttachment ? CGSize(width: 100, height: 146) : CGSize(width: 85, height: 85)
    }
}

// MARK: - UDAttachCVCellDelegate
extension UDMessagesView: UDAttachCVCellDelegate {
    func deleteFile(index: Int) {
        deleteMeessage(from: &draftMessages, index: draftMessages.filter({$0.type == UD_TYPE_TEXT}).count > 0 ? index + 1 : index)
        attachCollectionMessageView.reloadData()
        if countDraftMessagesWithFile == 0 {
            closeAttachCollection()
        }
    }
}

// MARK: - UDFeedbackMessageCellNodeDelegate
extension UDMessagesView: UDFeedbackMessageCellNodeDelegate {
    func feedbackAction(indexPath: IndexPath, feedback: Bool) {
        guard usedesk != nil else {return}
        if getMessage(indexPath) != nil {
            messagesWithSection[indexPath.section][indexPath.row].text = usedesk!.model.stringFor("ArticleReviewSendedTitle")
            messagesWithSection[indexPath.section][indexPath.row].attributedString = NSMutableAttributedString(string: usedesk!.model.stringFor("ArticleReviewSendedTitle"))
            var feedbackActionInt = -1
            switch feedback {
            case false:
                feedbackActionInt = 0
            case true:
                feedbackActionInt = 1
            }
            messagesWithSection[indexPath.section][indexPath.row].feedbackActionInt = feedbackActionInt
            tableNode.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
// MARK: - ImagePickerDelegate
extension UDMessagesView: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if image != nil {
            addDraftMessage(with: image!)
        }
        closeAttachView()
        showAttachCollection()
    }
}
// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension UDMessagesView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var filtredResults: [PHPickerResult] = []
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        var assetsSort: [PHAsset] = []
        for index in 0..<fetchResult.count {
            assetsSort.append(fetchResult.object(at: index))
        }
        for result in results {
            if assetsSort.contains(where: {$0.localIdentifier == result.assetIdentifier}) {
                filtredResults.append(result)
            }
        }
        for index in 0..<fetchResult.count {
            let asset = fetchResult.object(at: index)
            var newIndex = 0
            for indexSort in 0..<filtredResults.count {
                if asset.localIdentifier == filtredResults[indexSort].assetIdentifier {
                    newIndex = indexSort
                }
            }
            assetsSort.remove(at: newIndex)
            assetsSort.insert(asset, at: newIndex)
        }
        
        for index in 0..<assetsSort.count {
            addDraftMessage(with: assetsSort[index], isEnabledButtonSend: index == assetsSort.count - 1)
            if index == assetsSort.count - 1 {
                closeAttachView()
                showAttachCollection()
            }
        }
    }
}

// MARK: - TextMessageCellNodeDelegate
extension UDMessagesView: TextMessageCellNodeDelegate {
    
    func longPressText(text: String) {
        guard usedesk != nil else {return}
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)

        let copyAction = UIAlertAction(title: usedesk!.model.stringFor("Copy"), style: .default, handler: {(alert: UIAlertAction!) in
            UIPasteboard.general.string = text
        })

        let cancelAction = UIAlertAction(title: usedesk!.model.stringFor("Cancel"), style: .cancel, handler: {(alert: UIAlertAction!) in
        })

        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion:{})
        }
    }
}
// MARK: - ImagePicker
public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject, UINavigationControllerDelegate {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image"]
    }

    public func present() {
        pickerController.sourceType = .savedPhotosAlbum
        presentationController?.present(self.pickerController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}


