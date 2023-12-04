//
//  UDMessagesView.swift

import AVFoundation
import Photos
import PhotosUI
import Alamofire
import MobileCoreServices
import AsyncDisplayKit
import MapKit
import UniformTypeIdentifiers
import QuickLook

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
    // Scroll Button
    @IBOutlet weak var scrollButton: UIButton!
    @IBOutlet weak var scrollButtonTC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonBC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonHC: NSLayoutConstraint!
    @IBOutlet weak var scrollButtonWC: NSLayoutConstraint!
    // New Messages Count View
    @IBOutlet weak var newMessagesCountView: UIView!
    @IBOutlet weak var newMessagesCountLabel: UILabel!
    @IBOutlet weak var newMessagesCountViewHC: NSLayoutConstraint!
    @IBOutlet weak var newMessagesCountViewWC: NSLayoutConstraint!
    @IBOutlet weak var newMessagesCountViewBC: NSLayoutConstraint!
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
    // Attach
    @IBOutlet weak var attachBackView: UIView!
    @IBOutlet weak var attachBlackView: UIView!
    @IBOutlet weak var attachCollectionView: UICollectionView!
    @IBOutlet weak var attachViewBC: NSLayoutConstraint!
    @IBOutlet weak var attachChangeView: UIView!
    @IBOutlet weak var attachSeparatorView: UIView!
    @IBOutlet weak var attachFirstButton: UIButton!
    @IBOutlet weak var attachFileButton: UIButton!
    @IBOutlet weak var attachCancelButton: UIButton!
    // Form Picker
    @IBOutlet weak var formPickerContainerView: UIView!
    @IBOutlet weak var formPickerContainerViewBC: NSLayoutConstraint!
    @IBOutlet weak var formPickerView: UIPickerView!
    @IBOutlet weak var formTopView: UIView!
    @IBOutlet weak var formDoneButton: UIButton!
    // Send Button
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var buttonSendTC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendWC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendHC: NSLayoutConstraint!
    @IBOutlet weak var buttonSendLoader: UIActivityIndicatorView!
    
    weak var usedesk: UseDeskSDK?
    
    public var draftMessages: [UDMessage] = []
    public var failMessages: [UDMessage] = []
    public var sendedFormsMessages: [UDMessage] = []
    public var queueOfSendMessages: [UDMessage] = []
    public var messagesWithSection: [[UDMessage]] = []
    public var messagesDidLoadFile: [UDMessage] = []
    public var messagesDidLoadForm: [UDMessage] = []
    public var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    public var safeAreaInsetsBottom: CGFloat = 0.0
    public var tableNode = ASTableNode()
    public var startDownloadFileIds: [Int] = []
    public var startDownloadFormsIds: [Int] = []
    public var startDownloadAvatarsIds: [Int] = []
    public var allMessages: [UDMessage] = []
    public var newMessagesIds: [Int] = []
    public var isScrollChatToBottom = true
    public var isFromBase = false
    public var isFromOfflineForm = false
    
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
    private var centerLandscape: CGPoint = CGPoint.zero
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
    private var selectedFile: UDFile!
    private var optionsForFormPicker: [FieldOption] = []
    private var selectedFormObjects: (UDMessage, Int, FieldOption?)? = nil
    private var isNeedLoadMoreHistoryMessages = true
    private var idSelectingMessage: Int? = nil
    
    private var currentOrientation: Orientation {
        return previousOrientation == .portrait ? .landscape : .portrait
    }
    
    private var keyboardHeight: CGFloat {
        return currentOrientation == .portrait ? keyboardHeightPortait : keyboardHeightLandscape
    }
    
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
        setNeedsStatusBarAppearanceUpdate()
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (navigationController as? UDNavigationController)?.statusBarStyle ?? .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        view.endEditing(true)
    }
    
    // MARK: - Methods
    func configurationViews() {
        guard usedesk != nil else {return}
        viewForTable.backgroundColor = configurationStyle.chatStyle.backgroundColor
        tableNode.backgroundColor = configurationStyle.chatStyle.backgroundColor
        tableNode.view.separatorStyle = .none
        tableNode.view.scrollsToTop = true
        tableNode.dataSource = self
        tableNode.delegate = self
        tableNode.leadingScreensForBatching = 10.0
        tableNode.inverted = true
        tableNode.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 4, right: 0.0)
        tableNode.view.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 4, right: 0.0)
        
        buttonAttach.setBackgroundImage(configurationStyle.attachButtonStyle.image, for: .normal)
        buttonAttachLC.constant = configurationStyle.attachButtonStyle.margin.left
        buttonAttachBC.constant = -configurationStyle.attachButtonStyle.margin.bottom
        buttonAttachWC.constant = configurationStyle.attachButtonStyle.size.width
        buttonAttachHC.constant = configurationStyle.attachButtonStyle.size.height
        
        attachChangeView.backgroundColor = configurationStyle.attachViewStyle.backgroundColor
        attachCancelButton.backgroundColor = configurationStyle.attachViewStyle.backgroundColor
        attachCancelButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        
        buttonSend.setBackgroundImage(configurationStyle.sendButtonStyle.image, for: .normal)
        buttonSendTC.constant = configurationStyle.sendButtonStyle.margin.right
        buttonSendWC.constant = configurationStyle.sendButtonStyle.size.width
        buttonSendHC.constant = configurationStyle.sendButtonStyle.size.height
        
        textInput.delegate = self
        textInput.textColor = configurationStyle.inputViewStyle.placeholderTextColor
        setFirstTextInTextInput()
        textInput.isNeedCustomTextContainerInset = true
        textInput.customTextContainerInset = configurationStyle.inputViewStyle.textMargin
        
        attachFirstButton.setTitle(usedesk!.model.stringFor("Gallery"), for: .normal)
        attachFileButton.setTitle(usedesk!.model.stringFor("File").capitalized, for: .normal)
        attachCancelButton.setTitle(usedesk!.model.stringFor("Cancel"), for: .normal)
        
        attachFirstButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachFileButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachCancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        attachFirstButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        attachFileButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        attachCancelButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        
        configureAttachCollection()
        
        formDoneButton.setTitle(usedesk!.model.stringFor("Done"), for: .normal)
        formDoneButton.setTitleColor(configurationStyle.messageFormStyle.pickerDoneButtonColor, for: .normal)
        formTopView.backgroundColor = configurationStyle.messageFormStyle.pickerTopViewColor
        formPickerView.delegate = self
        
        scrollButtonTC.constant = configurationStyle.scrollButtonStyle.scrollButtonMargin.right
        scrollButtonBC.constant = configurationStyle.scrollButtonStyle.scrollButtonMargin.bottom
        scrollButtonHC.constant = configurationStyle.scrollButtonStyle.scrollButtonSize.height
        scrollButtonWC.constant = configurationStyle.scrollButtonStyle.scrollButtonSize.width
        scrollButton.setBackgroundImage(configurationStyle.scrollButtonStyle.scrollButtonImage, for: .normal)
        scrollButton.alpha = 0
        
        newMessagesCountView.backgroundColor = configurationStyle.scrollButtonStyle.newMessagesViewColor
        newMessagesCountView.layer.cornerRadius = configurationStyle.scrollButtonStyle.newMessagesViewHeight / 2
        newMessagesCountViewHC.constant = configurationStyle.scrollButtonStyle.newMessagesViewHeight
        newMessagesCountViewBC.constant = configurationStyle.scrollButtonStyle.newMessagesViewMarginBottom
        updateCountNewMessagesView()
        newMessagesCountLabel.font = configurationStyle.scrollButtonStyle.newMessagesLabelFont
        newMessagesCountLabel.textColor = configurationStyle.scrollButtonStyle.newMessagesLabelColor
        
        buttonSend.isEnabled = false
        buttonAttach.isEnabled = false
        if !isFromOfflineForm {
            textInput.isUserInteractionEnabled = false
        }
    }
    
    func configureAttachCollection() {
        attachCollectionMessageViewTopC.constant = configurationStyle.inputViewStyle.topMarginAssetsCollection
        attachCollectionMessageViewHC.constant = configurationStyle.inputViewStyle.heightAssetsCollection
        
        if countDraftMessagesWithFile > 0 {
            showAttachCollection()
        }
    }
    
    func setFirstTextInTextInput() {
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
    }
    
    func loadMessagesFromStorage() {
        guard usedesk != nil else {return}
        if (usedesk!.storage as? UDStorageMessages) != nil {
            (usedesk!.storage! as! UDStorageMessages).token = usedesk!.model.token
        }
        if let messeges = usedesk!.storage?.getMessages() {
            draftMessages.removeAll()
            let allDraftMessages = messeges.filter({$0.statusSend == UD_STATUS_SEND_DRAFT})
            var messagesDelete = [UDMessage]()
            allDraftMessages.forEach { message in
                if message.type != UD_TYPE_TEXT && message.file.data == nil {
                    messagesDelete.append(message)
                } else {
                    draftMessages.append(message)
                }
            }
            usedesk!.storage?.removeMessage(messagesDelete)
            failMessages = messeges.filter({$0.statusSend == UD_STATUS_SEND_FAIL})
            failMessages = failMessages.sorted{$0.date < $1.date }
            sendedFormsMessages = messeges.filter({$0.statusForms == .sended})
        }
    }
    
    func loadAssets() {
        assetsGallery = []
        let options = PHFetchOptions()
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.isAccessibilityElement = false
        options.sortDescriptors = sortDescriptor
        if usedesk?.isSupportedAttachmentOnlyPhoto ?? false {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }
        if usedesk?.isSupportedAttachmentOnlyVideo ?? false {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        }
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
    
    func indexPathForMessage(at id: Int, isFile: Bool? = nil) -> IndexPath? {
        var section = 0
        var row = 0
        var flag = true
        while section < messagesWithSection.count && flag {
            while row < messagesWithSection[section].count && flag {
                let indexPath = IndexPath(row: row, section: section)
                let message = messagesWithSection[section][row]
                if message.id == id || Int(message.loadingMessageId) ?? 0 == id {
                    flag = false
                    return indexPath
                }
                row += 1
            }
            row = 0
            section += 1
        }
        return nil
    }
    
    func indexPathForMessage(at messageFind: UDMessage) -> IndexPath? {
        var section = 0
        var row = 0
        var flag = true
        while section < messagesWithSection.count && flag {
            while row < messagesWithSection[section].count && flag {
                let indexPath = IndexPath(row: row, section: section)
                let message = messagesWithSection[section][row]
                if message.id == messageFind.id || ((message.loadingMessageId == messageFind.loadingMessageId) && (!message.loadingMessageId.isEmpty)) {
                    let isFileCurrentMessage = message.type == UD_TYPE_PICTURE || message.type == UD_TYPE_VIDEO || message.type == UD_TYPE_File
                    if isFileCurrentMessage {
                        if message.file.id == messageFind.file.id {
                            flag = false
                            return indexPath
                        }
                    } else {
                        flag = false
                        return indexPath
                    }
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
                centerPortait = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightPortait)//view.center
            }
            if previousOrientation != .portrait {
                textInputViewBC.constant = 0
                previousOrientation = .portrait
                attachCollectionView.reloadData()
                updateOrientationValueInCellWith(.portrait)
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.view.setNeedsLayout()
                    wSelf.view.layoutIfNeeded()
                }
            }
        } else {
            if centerLandscape == CGPoint.zero && !isFirstOpen {
                centerLandscape = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightLandscape)//view.center
            }
            if #available(iOS 11.0, *) {
                if UIDevice.current.orientation == .landscapeLeft && previousOrientation != .landscape{
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.left
                } else if previousOrientation != .landscape {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.right
                }
            }
            if previousOrientation != .landscape {
                textInputViewBC.constant = 0
                previousOrientation = .landscape
                attachCollectionView.reloadData()
                updateOrientationValueInCellWith(.landscape)
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.view.setNeedsLayout()
                    wSelf.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func updateOrientationValueInCellWith(_ orientaion: Orientation) {
        for section in 0..<messagesWithSection.count {
            for index in 0..<messagesWithSection[section].count {
                if let cell = tableNode.nodeForRow(at: IndexPath(row: index, section: section)) as? UDMessageCellNode {
                    cell.orientaion = orientaion
                }
            }
        }
    }
    
    func updateCountNewMessagesView() {
        newMessagesCountView.alpha = newMessagesIds.count > 0 ? scrollButton.alpha : 0
        guard newMessagesIds.count > 0 else {return}
        let scrollButtonStyle = configurationStyle.scrollButtonStyle
        newMessagesCountLabel.text = newMessagesIds.count > 99 ? "99+" : String(newMessagesIds.count)
        let widthSingleSymbol = (newMessagesIds.count < 10 ? String(newMessagesIds.count) : "0").size(attributes: [NSAttributedString.Key.font : scrollButtonStyle.newMessagesLabelFont]).width
        let additionalWidth = scrollButtonStyle.newMessagesViewHeight - widthSingleSymbol
        let widthNewMessagesCountLabel = newMessagesCountLabel.text?.size(attributes: [NSAttributedString.Key.font : scrollButtonStyle.newMessagesLabelFont]).width ?? widthSingleSymbol
        newMessagesCountViewWC.constant = widthNewMessagesCountLabel + additionalWidth
        self.view.layoutIfNeeded()
    }
    
    func updateMessageAndNode(message: UDMessage, isReload: Bool = false) {
        // update message in model
        guard let indexPath = indexPathForMessage(at: message.id) else {
            tableNode.reloadData()
            return
        }
        messagesWithSection[indexPath.section][indexPath.row] = message
        // update node in tablenode
        guard let nodeMessage = tableNode.nodeForRow(at: indexPath) as? UDMessageCellNode else {
            tableNode.reloadData()
            return
        }
        tableNode.performBatch(animated: false) {
            if isReload {
                tableNode.reloadRows(at: [indexPath], with: .automatic)
            } else {
                nodeMessage.bindData(messagesView: self, message: message)
            }
        }
    }
    
    func updateMessage(message: UDMessage) {
        guard let indexPath = indexPathForMessage(at: message.id) else {return}
        messagesWithSection[indexPath.section][indexPath.row] = message
        guard let nodeMessage = tableNode.nodeForRow(at: indexPath) as? UDMessageCellNode else {return}
        nodeMessage.message = message
    }
    
    func scrollChatToNewMessage() {
        if newMessagesIds.count > 0 && isScrollChatToBottom {
            if let indexPath = indexPathForMessage(at: newMessagesIds[0]) {
                idSelectingMessage = newMessagesIds[0]
                var position: UITableView.ScrollPosition = .top
                if let node = tableNode.nodeForRow(at: indexPath) as? UDMessageCellNode{
                    position = node.frame.height > tableNode.frame.height - 20 ? .bottom : .top
                }
                isScrollChatToBottom = newMessagesIds.count == 1
                tableNode.scrollToRow(at: indexPath, at: position, animated: true)
            }
        } else {
            isScrollChatToBottom = true
            tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
        }
    }
    
    func scrollChatToStart() {
        isScrollChatToBottom = true
        tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
    }
    
    // MARK: - Message methods
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
    
    func downloadFile(node: UDMessageCellNode) {
        let isFileNotDidLoad = messagesDidLoadFile.filter({$0.id == node.message.id}).count == 0
        if let pictureCell = node as? UDPictureMessageCellNode {
            if let indexPath = pictureCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == UD_STATUS_SUCCEED && pictureCell.message != message && isFileNotDidLoad {
                    if let image = message.file.image {
                        pictureCell.setImage(image)
                    }
                } else {
                    guard message.file.path == "" else { return }
                    // download image
                    DispatchQueue.global(qos: .userInitiated).async {
                        let session = URLSession.shared
                        guard let url = URL(string: message.file.urlFile) else { return }
                        (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                            guard let wSelf = self else {return}
                            if error == nil {
                                var fileExtension = ".png"
                                if let pathExtension = NSString(utf8String: response?.suggestedFilename ?? ".png")?.pathExtension {
                                    fileExtension = pathExtension
                                }
                                guard let wSelf = self else {return}
                                if let indexPathPicture = wSelf.indexPathForMessage(at: message) {
                                    wSelf.messagesDidLoadFile.append(message)
                                    message.status = UD_STATUS_SUCCEED
                                    message.file.path = FileManager.default.udWriteDataToCacheDirectory(data: data!, fileExtension: fileExtension) ?? ""
                                    message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? response?.suggestedFilename ?? "Image") : "Image"
                                    message.file.type = .image
                                    wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                    pictureCell.imageNode.image = message.file.image
                                    if let image = message.file.image {
                                        pictureCell.setImage(image)
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
        else if let videoCell = node as? UDVideoMessageCellNode {
            if let indexPath = videoCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == UD_STATUS_SUCCEED && videoCell.message != message && isFileNotDidLoad {
                    if message.file.path.count > 0 {
                        videoCell.setPreviewImage(UDFileManager.videoPreview(fileURL: URL(fileURLWithPath: message.file.path)))
                    }
                } else {
                    if message.file.path == "" && message.file.urlFile != "" {
                        UDFileManager.downloadFile(indexPath: indexPath, urlPath: message.file.urlFile, name: message.file.name, extansion: message.file.typeExtension) { [weak self] (indexPath, url) in
                            guard let wSelf = self else {return}
                            if let indexPathVideo = wSelf.indexPathForMessage(at: message) {
                                wSelf.messagesDidLoadFile.append(message)
                                message.file.path = url.path
                                message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                message.status = UD_STATUS_SUCCEED
                                wSelf.messagesWithSection[indexPathVideo.section][indexPathVideo.row] = message
                                videoCell.setPreviewImage(UDFileManager.videoPreview(fileURL: URL(fileURLWithPath: message.file.path)))
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
                    fileCell.removeLoader()
                } else {
                    if message.file.path == "" {
                        let session = URLSession.shared
                        if let url = URL(string: message.file.urlFile) {
                            DispatchQueue.global(qos: .userInitiated).async {
                                (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                                    guard let wSelf = self else {return}
                                    if error == nil && data != nil {
                                        DispatchQueue.main.async {
                                            wSelf.messagesDidLoadFile.append(message)
                                            var isFile = true
                                            message.status = UD_STATUS_SUCCEED
                                            guard let indexPathFile = wSelf.indexPathForMessage(at: message) else {return}
                                            if let mimeType = response?.mimeType {
                                                var fileExtension = ""
                                                if mimeType.contains("video") {
                                                    if let pathExtension = NSString(utf8String: response?.suggestedFilename ?? ".mp4")?.pathExtension {
                                                        fileExtension = pathExtension
                                                    }
                                                    message.type = UD_TYPE_VIDEO
                                                    message.file.path = NSURL(fileURLWithPath: FileManager.default.udWriteDataToCacheDirectory(data: data!, fileExtension: fileExtension) ?? "").path ?? ""
                                                    message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                                    message.file.type = .video
                                                    isFile = false
                                                } else if mimeType.contains("image") {
                                                    if let pathExtension = NSString(utf8String: response?.suggestedFilename ?? ".png")?.pathExtension {
                                                        fileExtension = pathExtension
                                                    }
                                                    message.file.path = FileManager.default.udWriteDataToCacheDirectory(data: data!, fileExtension: fileExtension) ?? ""
                                                    message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? "Image") : "Image"
                                                    message.file.type = .image
                                                    isFile = false
                                                }
                                                if !isFile {
                                                    wSelf.messagesWithSection[indexPathFile.section][indexPathFile.row] = message
                                                    wSelf.tableNode.reloadRows(at: [indexPathFile], with: .none)
                                                }
                                            }
                                            if isFile {
                                                var fileExtension = ".txt"
                                                if let pathExtension = NSString(utf8String: response?.suggestedFilename ?? ".txt")?.pathExtension {
                                                    fileExtension = pathExtension
                                                }
                                                message.file.path = NSURL(fileURLWithPath: FileManager.default.udWriteDataToCacheDirectory(data: data!, fileExtension: fileExtension) ?? "").path ?? ""
                                                message.file.type = .file
                                                message.file.sizeInt = data!.count
                                                wSelf.messagesWithSection[indexPathFile.section][indexPathFile.row] = message
                                                if let cell = (wSelf.tableNode.nodeForRow(at: indexPathFile) as? UDFileMessageCellNode) {
                                                    cell.removeLoader()
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
    
    func downloadAdditionalFieldsForm(for message: UDMessage) {
        usedesk?.networkManager?.getAdditionalFields(for: message, successBlock: { [weak self] newMessage in
            DispatchQueue.main.async {
                guard let wSelf = self, newMessage != nil else {return}
                wSelf.updateMessageAndNode(message: newMessage!, isReload: true)
            }
        }, errorBlock: { error, _ in
            print(error)
        })
    }
    
    func downloadAvatar(for message: UDMessage) {
        DispatchQueue.global(qos: .background).async {
            let session = URLSession.shared
            guard let url = URL(string: message.avatar) else { return }
            (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                guard let wSelf = self else {return}
                DispatchQueue.main.async {
                    if error == nil, let avatarData = data {
                        let avatarImage = UIImage(data: avatarData) ?? wSelf.configurationStyle.avatarStyle.avatarImageDefault
                        for section in 0..<wSelf.messagesWithSection.count {
                            for index in 0..<wSelf.messagesWithSection[section].count {
                                if wSelf.messagesWithSection[section][index].id == message.id {
                                    wSelf.messagesWithSection[section][index].avatarImage = avatarImage
                                    let indexPath = IndexPath(row: index, section: section)
                                    if let nodeMessage = wSelf.tableNode.nodeForRow(at: indexPath) as? UDMessageCellNode {
                                        nodeMessage.message = wSelf.messagesWithSection[section][index]
                                        nodeMessage.setAvatarImage(avatarImage)
                                    }
                                }
                            }
                        }
                    } else if let index = wSelf.startDownloadAvatarsIds.firstIndex(of: message.id) {
                        wSelf.startDownloadAvatarsIds.remove(at: index)
                    }
                }
            })).resume()
        }
    }
    
    func getMessage(_ indexPath: IndexPath?) -> UDMessage? {
        guard indexPath != nil else {return nil}
        guard indexPath!.section >= 0 else {return nil}
        guard indexPath!.row >= 0 else {return nil}
        guard messagesWithSection.count > indexPath!.section else {return nil}
        guard messagesWithSection[indexPath!.section].count > indexPath!.row else {return nil}
        return (messagesWithSection[indexPath!.section][indexPath!.row])
    }
    
    func fetchNewBatchOfMessagesWithContext(_ context: ASBatchContext) {
        guard messagesWithSection.count > 0 else {
            context.completeBatchFetching(true)
            return
        }
        usedesk?.getMessages(idComment: self.messagesWithSection.last?.last?.id ?? 0, newMessagesBlock: { [weak self] newMessages in
            guard let wSelf = self else {return}
            if newMessages.count < (wSelf.usedesk?.model.countMessagesOnInit ?? UD_LIMIT_PAGINATION_DEFAULT) {
                wSelf.isNeedLoadMoreHistoryMessages = false
                guard !newMessages.isEmpty else {return}
            }
            var uniquiNewMessages: [UDMessage] = []
            for message in newMessages {
                if !wSelf.messagesWithSection.contains(where: {$0.contains(where: {$0.id == message.id})}) {
                    uniquiNewMessages.append(message)
                }
            }
            let sortedNewMessages = Array(uniquiNewMessages.sorted(by: { $0.date > $1.date }))
            var newMessagesWithSection = wSelf.generateSection(messagesForGenerate: sortedNewMessages)
            DispatchQueue.main.async {
                var indexesNewMessages: [IndexPath] = []
                if newMessagesWithSection.count > 0, newMessagesWithSection.first?[0].date.dateFormatString == wSelf.messagesWithSection.last?[0].date.dateFormatString {
                    let previousIndexPath = IndexPath(row: wSelf.messagesWithSection.last!.count - 1, section: wSelf.messagesWithSection.count - 1)
                    for index in 0..<newMessagesWithSection.first!.count {
                        let count = index
                            let indexPath = IndexPath(row: wSelf.messagesWithSection.last!.count, section: wSelf.messagesWithSection.count - 1)
                            indexesNewMessages.append(indexPath)
                            wSelf.messagesWithSection[wSelf.messagesWithSection.count - 1].append(newMessagesWithSection.first![count])
                    }
                    wSelf.tableNode.insertRows(at: indexesNewMessages, with: .none)
                    if let node = wSelf.tableNode.nodeForRow(at: previousIndexPath) as? UDMessageCellNode {
                        if node.nameNode.alpha == 1 {
                            node.isNeedShowSender = false
                            node.nameNode.alpha = 0
                            node.setNeedsLayout()
                        }
                    }
                    newMessagesWithSection.remove(at: 0)
                }
                var indexesNewSections: [Int] = []
                for sectionMessages in newMessagesWithSection {
                    indexesNewSections.append(wSelf.messagesWithSection.count)
                    wSelf.messagesWithSection.append(sectionMessages)
                }
                wSelf.tableNode.insertSections(IndexSet(indexesNewSections), with: .none)
                context.completeBatchFetching(true)
            }
        }, errorBlock: { _, _ in})
    }
    
    func addDraftMessage(with asset: Any, isEnabledButtonSend: Bool = true) {
        buttonSend.isEnabled = false
        let sort = countDraftMessagesWithFile + 1
        if let asset = asset as? PHAsset {
            let message = UDMessage()
            if let id = usedesk?.networkManager?.newIdLoadingMessages() {
                message.loadingMessageId = id
            }
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
                            if let previewImage = message.file.preview  {
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
            if let id = usedesk?.networkManager?.newIdLoadingMessages() {
                message.loadingMessageId = id
            }
            draftMessages.append(message)
            if (message.file.data?.size ?? 0) > kLimitSizeFile {
                showAlertLimitSizeFile(with: message)
                deleteDraftMessage(with: message)
            } else if isEnabledButtonSend {
                buttonSend.isEnabled = true
            }
        } else if let urlFile = asset as? URL {
            var message = UDMessage()
            if let id = usedesk?.networkManager?.newIdLoadingMessages() {
                message.loadingMessageId = id
            }
            if urlFile.pathExtension.lowercased() == "mov" {
                message = UDMessage(urlMovie: urlFile, isCacheFile: usedesk?.isCacheMessagesWithFile ?? false)
            } else {
                message = UDMessage(urlFile: urlFile, isCacheFile: usedesk?.isCacheMessagesWithFile ?? false)
            }
            draftMessages.append(message)
            if (message.file.data?.size ?? 0) > kLimitSizeFile {
                showAlertLimitSizeFile(with: message)
                deleteDraftMessage(with: message)
            } else if isEnabledButtonSend {
                buttonSend.isEnabled = true
            }
        }
    }
    
    func deleteMeessage(from arrayMessages: inout [UDMessage], index: Int) {
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
            usedesk?.storage?.removeMessage([message])
            deleteMeessage(from: &draftMessages, index: index)
        }
    }
    
    func generateSection(messagesForGenerate: [UDMessage]? = nil) -> [[UDMessage]] {
        var generetedMessagesWithSection: [[UDMessage]] = []
        if messagesForGenerate == nil {
            insertFailSendMessages()
        }
        var messages = messagesForGenerate ?? allMessages
        guard messages.count > 0 else {return []}
        messages = setStatusFormFor(messages: messages)
        generetedMessagesWithSection.append([messages[0]])
        var indexSection = 0
        for index in 1..<messages.count {
            var dateStringSection = ""
            var dateStringObject = ""
            // date section
            dateStringSection = generetedMessagesWithSection[indexSection][0].date.dateFormatString
            dateStringObject = messages[index].date.dateFormatString
            if dateStringSection.count > 0 && dateStringObject.count > 0 {
                if dateStringSection == dateStringObject {
                    generetedMessagesWithSection[indexSection].append(messages[index])
                } else {
                    generetedMessagesWithSection.append([messages[index]])
                    indexSection += 1
                }
            }
        }
        return generetedMessagesWithSection
    }
    
    func insertFailSendMessages() {
        guard usedesk != nil, failMessages.count > 0 else {return}
        var failMessagesInsert = failMessages
        // first item - location insert, seconds - index messages
        var insertArray: [[Int]] = []
        for index in 0..<allMessages.count {
            let invertedIndex = allMessages.count - index - 1
            var insertMessages: [UDMessage] = []
            for indexFail in 0..<failMessagesInsert.count {
                if failMessagesInsert[indexFail].date < allMessages[invertedIndex].date {
                    insertMessages.append(failMessagesInsert[indexFail])
                }
            }
            var insertMessagesIndexes: [Int] = [invertedIndex + 1]
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
        // insert messages
        for SectionInsertArray in 0..<insertArray.count {
            for indexInsertFailMess in 1..<insertArray[SectionInsertArray].count {
                allMessages.insert(failMessages[insertArray[SectionInsertArray][indexInsertFailMess]], at: insertArray[SectionInsertArray][0])
            }
        }
    }
    
    func downloadsForMessages(currentIndexPath indexPath: IndexPath) {
        let rangeDownloadsAnySizeFiles = NSRange(location: 0, length: 10)
        let rangeDownloadsSmallSizeFiles = NSRange(location: 10, length: 30)
        let rangeDownloadsAdditionalFields = NSRange(location: 0, length: 20)
        let rangeDownloadsAvatars = NSRange(location: 0, length: 40)
        let countNextCells = 40
        
        var row = indexPath.row
        var section = indexPath.section
        for index in 0..<countNextCells {
            var indexPathMessage = IndexPath(row: row, section: section)
            if getMessage(indexPathMessage) == nil {
                section += 1
                row = 0
                indexPathMessage = IndexPath(row: row, section: section)
                if getMessage(indexPathMessage) == nil {
                    break
                }
            }
            
            if tableNode.nodeForRow(at: indexPathMessage) is UDPictureMessageCellNode || tableNode.nodeForRow(at: indexPathMessage) is UDVideoMessageCellNode || tableNode.nodeForRow(at: indexPathMessage) is UDFileMessageCellNode {
                if let cellDownload = tableNode.nodeForRow(at: indexPathMessage) as? UDMessageCellNode {
                    if rangeDownloadsAnySizeFiles.contains(index) {
                        if !startDownloadFileIds.contains(cellDownload.message.file.id) {
                            startDownloadFileIds.append(cellDownload.message.file.id)
                            downloadFile(node: cellDownload)
                        }
                    }
                    if rangeDownloadsSmallSizeFiles.contains(index) {
                        if cellDownload.message.file.sizeValue < 524288 && !startDownloadFileIds.contains(cellDownload.message.file.id) {
                            startDownloadFileIds.append(cellDownload.message.file.id)
                            downloadFile(node: cellDownload)
                        }
                    }
                }
            }
            
            if rangeDownloadsAdditionalFields.contains(index) {
                if tableNode.nodeForRow(at: indexPathMessage) is UDTextMessageCellNode,
                   let message = getMessage(indexPathMessage),
                   message.forms.count > 0 {
                    let isExistFormsWithAdditionalField = message.forms.filter({$0.type == .additionalField}).count > 0
                    if isExistFormsWithAdditionalField && message.statusForms != .sended && !startDownloadFormsIds.contains(message.id) {
                        startDownloadFormsIds.append(message.id)
                        downloadAdditionalFieldsForm(for: message)
                    }
                }
            }
            
            if rangeDownloadsAvatars.contains(index) {
                if tableNode.nodeForRow(at: indexPathMessage) is UDMessageCellNode,
                   let message = getMessage(indexPathMessage),
                   message.incoming,
                   message.avatarImage == nil {
                    startDownloadAvatarsIds.append(message.id)
                    downloadAvatar(for: message)
                }
            }
            
            row += 1
        }
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
                    buttonSend.isEnabled = textInput.text.udRemoveFirstAndLastLineBreaksAndSpaces().count != 0 // если сообщение не пустое то кнопка активна
                }
            }
        }
    }
    
    // MARK: - User actions (bubble tap)
    func actionTapBubble(_ indexPath: IndexPath?) {
        guard usedesk != nil else {return}
        let message = messagesWithSection[indexPath!.section][indexPath!.row]
        let file: UDFile = message.file
        if (file.type == .image || message.type == UD_TYPE_PICTURE || file.type == .video || message.type == UD_TYPE_VIDEO || file.type == .file || message.type == UD_TYPE_File) && message.status == UD_STATUS_SUCCEED {
            selectedFile = file
            self.view.endEditing(true)
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let filePreviewController = QLPreviewController()
                filePreviewController.delegate = self
                filePreviewController.dataSource = self
                filePreviewController.currentPreviewItemIndex = 0
                self.present(filePreviewController, animated: true)
            }
        }
    }

    // MARK: - User actions (input panel)
    @IBAction func actionInputAttach(_ sender: Any) {
        dismissKeyboard()
        actionAttachMessage()
    }
    
    @IBAction func actionInputSend(_ sender: Any) {
        guard usedesk != nil else {return}
        DispatchQueue.main.async {
            self.actionSendMessage()
            if !((self.textInput.text == self.usedesk!.model.stringFor("Write") + "..." && self.textInput.textColor == self.configurationStyle.inputViewStyle.placeholderTextColor)) {
                self.textInput.text = ""
            }
            self.inputPanelUpdate()
        }
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
            if #available(iOS 13.0, *) {
                importMenu.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            }
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
        scrollChatToNewMessage()
    }
    
    @IBAction func formDoneAction(_ sender: Any) {
        updateSelectedFormValues()
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
                    self.newMessagesCountView.alpha = 0
                }
            }
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let lastIndexSection = messagesWithSection.count - 1
        if lastIndexSection < messagesWithSection.count {
            let lastindex = self.messagesWithSection[lastIndexSection].count - 1
            let indexPath = IndexPath(row: lastindex, section: lastIndexSection)
            guard tableNode.nodeForRow(at: indexPath) != nil else {return false}
            UIView.animate(withDuration: 0.3) {
                self.tableNode.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        return false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let id = idSelectingMessage else {return}
        if let indexPath = indexPathForMessage(at: id) {
            if let node = tableNode.nodeForRow(at: indexPath) as? UDMessageCellNode {
                node.startSelectionAnimate()
            }
        }
        if newMessagesIds.count > 0 {
            if let index = newMessagesIds.firstIndex(of: id) {
                newMessagesIds.remove(at: index)
                updateCountNewMessagesView()
            }
        }
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
        self.tabBarController?.tabBar.isHidden = true
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
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func takePhotoCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.videoQuality = .typeHigh
            if usedesk?.isSupportedAttachmentOnlyPhoto ?? false {
                picker.mediaTypes = ["public.image"]
            } else if usedesk?.isSupportedAttachmentOnlyVideo ?? false {
                picker.mediaTypes = ["public.movie"]
            } else {
                picker.mediaTypes = ["public.image", "public.movie"]
            }
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
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == (kUTTypeImage as String), let chosenImage = info[.originalImage] as? UIImage {
                addDraftMessage(with: chosenImage.udFixedOrientation())
            } else if mediaType == (kUTTypeMovie as String), let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                addDraftMessage(with: url)
            }
        }
        buttonSend.isHidden = false
        closeAttachView()
        showAttachCollection()
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
                if let image = message.file.preview {
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
    
    // MARK: - Form
    func updateSelectedFormValues() {
        if selectedFormObjects != nil {
            guard let indexPathMessage = indexPathForMessage(at: selectedFormObjects!.0.id) else {
                closeFormPickerContainerView()
                return
            }
            let message = messagesWithSection[indexPathMessage.section][indexPathMessage.row]
            let indexSelectedOption = formPickerView.selectedRow(inComponent: 0)
            guard indexSelectedOption < optionsForFormPicker.count else {
                closeFormPickerContainerView()
                return
            }
            let newSelectedOption:FieldOption? = indexSelectedOption == 0 ? nil : optionsForFormPicker[indexSelectedOption]
            let indexForm = selectedFormObjects!.1
            // new selected option
            messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexForm].field?.selectedOption = newSelectedOption
            messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexForm].isErrorState = false
            // clear selected option in nested field
            let forms = message.forms
            var idParentForClearSelectedOptions = forms[indexForm].field?.id ?? 0
            var indexFindForm = 0
            while indexFindForm < forms.count {
                if forms[indexFindForm].field?.idParentField == idParentForClearSelectedOptions {
                    messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexFindForm].field?.selectedOption = nil
                    idParentForClearSelectedOptions = forms[indexFindForm].field?.id ?? 0
                    indexFindForm = 0
                } else {
                    indexFindForm += 1
                }
            }
            // update nodeCell
            updateMessageAndNode(message: messagesWithSection[indexPathMessage.section][indexPathMessage.row])
            selectedFormObjects = nil
            closeFormPickerContainerView()
        }
    }
    
    func showErrorForm(in message: UDMessage) {
        guard let indexPath = indexPathForMessage(at: message.id) else {return}
        guard let textMessageNode = tableNode.nodeForRow(at: indexPath) as? UDTextMessageCellNode else {return}
        textMessageNode.showErrorForm()
    }
    
    func openFormPickerContainerView() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.4) {
            self.formPickerContainerViewBC.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func closeFormPickerContainerView() {
        UIView.animate(withDuration: 0.4) {
            self.formPickerContainerViewBC.constant = -260
            self.view.layoutIfNeeded()
        }
    }
    
    func checkValidAndSendForm(message: UDMessage) {
        if let indexPathMessage = indexPathForMessage(at: message.id) {
            var isValidForms = true
            var isEmptyForms = true
            for indexForm in 0..<message.forms.count {
                let form = message.forms[indexForm]
                switch form.type {
                case .phone:
                    if UDValidationManager.isValidPhone(phone: form.value) || (!form.isRequired && form.value.count == 0) {
                        form.isErrorState = false
                        if !form.value.isEmpty {
                            isEmptyForms = false
                        }
                    } else {
                        form.isErrorState = true
                        isValidForms = false
                    }
                case .email:
                    if form.value.udIsValidEmail() || (!form.isRequired && form.value.count == 0) {
                        form.isErrorState = false
                        if !form.value.isEmpty {
                            isEmptyForms = false
                        }
                    } else {
                        form.isErrorState = true
                        isValidForms = false
                    }
                case .additionalField:
                    switch form.field?.type {
                    case .list:
                        if form.field?.selectedOption != nil {
                            isEmptyForms = false
                            form.isErrorState = false
                        } else if form.isRequired {
                            isValidForms = false
                            form.isErrorState = true
                        } else if form.field?.idParentField ?? 0 > 0 {
                            let superParentForm = getSuperParentForm(for: form, message: message)
                            if superParentForm?.field?.selectedOption != nil {
                                isValidForms = false
                                form.isErrorState = true
                            } else {
                                form.isErrorState = false
                            }
                        } else {
                            form.isErrorState = false
                        }
                    case .checkbox:
                        if form.value == "1" {
                            isEmptyForms = false
                            form.isErrorState = false
                        } else if form.isRequired {
                            isValidForms = false
                            form.isErrorState = true
                        } else {
                            form.isErrorState = false
                        }
                    case .text, .none:
                        if !form.value.isEmpty {
                            isEmptyForms = false
                            form.isErrorState = false
                        } else if form.isRequired {
                            isValidForms = false
                            form.isErrorState = true
                        } else {
                            form.isErrorState = false
                        }
                    }
                default:
                    if form.isRequired {
                        if form.value.count > 0 {
                            form.isErrorState = false
                            isEmptyForms = false
                        } else {
                            form.isErrorState = true
                            isValidForms = false
                        }
                    } else if !form.value.isEmpty {
                        isEmptyForms = false
                    }
                }
                messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexForm] = form
            }
            let message = messagesWithSection[indexPathMessage.section][indexPathMessage.row]
            if isValidForms && !isEmptyForms {
                message.statusForms = .loading
                updateMessageAndNode(message: message)
                usedesk?.networkManager?.sendAdditionalFields(for: message, successBlock: { [weak self] in
                    guard let wSelf = self else {return}
                    message.statusForms = .sended
                    wSelf.saveSendedForm(for: message)
                    wSelf.updateMessageAndNode(message: message)
                }, errorBlock: { [weak self] _, _ in
                    guard let wSelf = self else {return}
                    message.statusForms = .inputable
                    wSelf.updateMessage(message: message)
                    wSelf.showErrorForm(in: message)
                })
            } else {
                updateMessageAndNode(message: message)
            }
        }
    }
    
    func tapForm(form: UDFormMessage, indexPathMessage: IndexPath, offsetYFormInBubbleMessage: CGFloat) {
        let rectMessageNode = tableNode.rectForRow(at: indexPathMessage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let visibleTableHeight = form.field?.type == .list ? (self.view.frame.height - self.formPickerContainerView.frame.height) : self.tableNode.frame.height
            let offsetYForm = self.tableNode.frame.height - (rectMessageNode.origin.y - (self.tableNode.contentOffset.y) + rectMessageNode.height - offsetYFormInBubbleMessage)
            let kTopOffsetForForm: CGFloat = 40
            let kBottomOffsetForForm: CGFloat = 60
            if self.tableNode.contentOffset.y == 0 {
                self.tableNode.contentOffset.y = -1
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            UIView.animate(withDuration: 0.3) {
                if offsetYForm > visibleTableHeight - kBottomOffsetForForm {
                    self.tableNode.contentOffset.y -= offsetYForm - (visibleTableHeight - kBottomOffsetForForm)
                } else if offsetYForm < 0 {
                    self.tableNode.contentOffset.y += -offsetYForm + kTopOffsetForForm
                }
            }
        }
    }
    
    func saveSendedForm(for message: UDMessage) {
        guard usedesk != nil else {return}
        message.statusForms = .sended
        message.statusSend = 0
        usedesk!.storage?.saveMessages([message])
    }
    
    func setStatusFormFor(messages: [UDMessage]) -> [UDMessage] {
        let updateMessages = messages
        for sendedFormsMessage in sendedFormsMessages {
            if let index = updateMessages.firstIndex(where: {$0.id == sendedFormsMessage.id}) {
                updateMessages[index].statusForms = .sended
                updateMessages[index].forms = sendedFormsMessage.forms
            }
        }
        return updateMessages
    }
    
    func getSuperParentForm(for form: UDFormMessage, message: UDMessage) -> UDFormMessage? {
        var superParentForm: UDFormMessage? = nil
        guard let idParentCurrentField = form.field?.idParentField else {return nil}
        var idParentField = idParentCurrentField
        var countRepeat = 0
        let maxCountRepeat = 100
        var isFindSuperParent = false
        while countRepeat < maxCountRepeat && !isFindSuperParent {
            if let parentForm = message.forms.filter({$0.field?.id == idParentField}).first {
                if let idParentFieldCheck = parentForm.field?.idParentField {
                    if idParentFieldCheck == 0 {
                        isFindSuperParent = true
                        superParentForm = parentForm
                    } else {
                        idParentField = idParentFieldCheck
                        countRepeat += 1
                    }
                } else {
                    countRepeat = maxCountRepeat
                }
            } else {
                countRepeat = maxCountRepeat
            }
        }
        return superParentForm
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        inputPanelUpdate()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        inputPanelUpdate()
        if textView.text.udRemoveFirstAndLastLineBreaksAndSpaces().count > 0 {
            let text = textView.text.udRemoveFirstAndLastLineBreaksAndSpaces()
            if draftMessages.filter({$0.type == UD_TYPE_TEXT}).count > 0 {
                draftMessages.filter({$0.type == UD_TYPE_TEXT})[0].text = text
            } else {
                draftMessages.insert(UDMessage(text: text), at: 0)
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
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let nodeBlock: ASCellNodeBlock = { [weak self] in
            guard let wSelf = self else {return ASCellNode()}
            guard wSelf.usedesk != nil else {return ASCellNode()}
            let message: UDMessage? = wSelf.getMessage(indexPath)
            if wSelf.usedesk?.model.nameOperator != "" {
                message?.operatorName = wSelf.usedesk!.model.nameOperator
            }
            var isNeedShowSender = true
            if let previousMessage = wSelf.getMessage(IndexPath(row: indexPath.row + 1, section: indexPath.section)) {
                if (message?.typeSenderMessage == previousMessage.typeSenderMessage),
                   message?.avatar == previousMessage.avatar,
                   message?.name == previousMessage.name,
                   message?.incoming ?? true,
                   previousMessage.incoming
                {
                    isNeedShowSender = false
                    if previousMessage.typeSenderMessage == .operator_to_client {
                        isNeedShowSender = message?.operatorId == previousMessage.operatorId ? false : true
                    }
                }
            }
            if message?.type == UD_TYPE_TEXT {
                let cell = UDTextMessageCellNode()
                cell.isNeedShowSender = isNeedShowSender
                cell.bindData(messagesView: wSelf, message: message ?? UDMessage())
                cell.selectionStyle = .none
                cell.delegateText = wSelf
                cell.delegateForm = wSelf
                return cell
            } else if message?.type == UD_TYPE_Feedback {
                let cell = UDFeedbackMessageCellNode()
                cell.isNeedShowSender = isNeedShowSender
                cell.usedesk = wSelf.usedesk
                cell.bindData(messagesView: wSelf, message: message ?? UDMessage())
                cell.selectionStyle = .none
                cell.delegate = wSelf
                return cell
            } else if message?.type == UD_TYPE_PICTURE {
                let cell = UDPictureMessageCellNode()
                cell.isNeedShowSender = isNeedShowSender
                cell.selectionStyle = .none
                cell.bindData(messagesView: wSelf, message: message ?? UDMessage())
                return cell
            } else if message?.type == UD_TYPE_VIDEO {
                let cell = UDVideoMessageCellNode()
                cell.isNeedShowSender = isNeedShowSender
                cell.selectionStyle = .none
                cell.bindData(messagesView: wSelf, message: message ?? UDMessage())
                return cell
            } else { //message?.type == UD_TYPE_File
                let cell = UDFileMessageCellNode()
                cell.isNeedShowSender = isNeedShowSender
                cell.usedesk = wSelf.usedesk
                cell.selectionStyle = .none
                cell.bindData(messagesView: wSelf, message: message ?? UDMessage())
                return cell
            }
        }
        return nodeBlock
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        guard let cell = node as? UDMessageCellNode else { return }
        cell.updateAnimateLoader()
        if let textMessageCell = cell as? UDTextMessageCellNode, textMessageCell.view.gestureRecognizers?.count ?? 0 == 0 {
            textMessageCell.view.addGestureRecognizer(UILongPressGestureRecognizer(target: textMessageCell, action: #selector(textMessageCell.longPressTextAction)))
        }
        guard let indexPath = cell.indexPath else { return }
        downloadsForMessages(currentIndexPath: indexPath)
        if newMessagesIds.count > 0 {
            if let index = newMessagesIds.firstIndex(of: messagesWithSection[indexPath.section][indexPath.row].id) {
                newMessagesIds.remove(at: index)
                updateCountNewMessagesView()
            }
        }
    }
    
    func shouldBatchFetchForTableNode(tableNode: ASTableNode) -> Bool {
        return isNeedLoadMoreHistoryMessages
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        guard isNeedLoadMoreHistoryMessages else {return}
        fetchNewBatchOfMessagesWithContext(context)
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
                    if let previewImage = file.preview  {
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

// MARK: - UIPickerViewDelegate
extension UDMessagesView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return optionsForFormPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return optionsForFormPicker[row].value
    }
}

// MARK: - UDFeedbackMessageCellNodeDelegate
extension UDMessagesView: UDFeedbackMessageCellNodeDelegate {
    func feedbackAction(indexPath: IndexPath, feedback: Bool) {
        guard usedesk != nil else {return}
        if getMessage(indexPath) != nil {
            messagesWithSection[indexPath.section][indexPath.row].text = usedesk!.model.stringFor("ArticleReviewSendedTitle")
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
    
    func formListAction(message: UDMessage, indexForm: Int, selectedOption: FieldOption?) {
        let defaultCleanOption = FieldOption(id: -1, value: usedesk?.model.stringFor("NotSelected") ?? "Not Selected")
        optionsForFormPicker = [defaultCleanOption]
        var indexSelectedOption = 0
        if let field = message.forms[indexForm].field {
            if field.idParentField > 0 {
                if let parentForm = message.forms.filter({$0.field?.id == field.idParentField}).first {
                    optionsForFormPicker += field.options.filter({$0.idsParentOption.contains(parentForm.field?.selectedOption?.id ?? 0)})
                }
            } else {
                optionsForFormPicker += field.options
            }
            if let selectedOption = field.selectedOption {
                if let index = optionsForFormPicker.firstIndex(where: {$0.id == selectedOption.id}) {
                    indexSelectedOption = index
                }
            }
        }
        formPickerView.reloadAllComponents()
        formPickerView.selectRow(indexSelectedOption, inComponent: 0, animated: false)
        selectedFormObjects = (message, indexForm, selectedOption)
        openFormPickerContainerView()
    }
    
    func newFormValue(value: String, message: UDMessage, indexForm: Int) {
        if let indexPathMessage = indexPathForMessage(at: message.id) {
            messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexForm].value = value
            messagesWithSection[indexPathMessage.section][indexPathMessage.row].forms[indexForm].field?.value = value
        }
    }
    
    func sendFormAction(message: UDMessage) {
        checkValidAndSendForm(message: message)
    }
}

// MARK: - FormDelegate
extension UDMessagesView: FormDelegate {
    func tapForm(message: UDMessage, form: UDFormMessage, offsetY: CGFloat) {
        if let indexPathMessage = indexPathForMessage(at: message.id) {
            tapForm(form: form, indexPathMessage: indexPathMessage, offsetYFormInBubbleMessage: offsetY)
        }
    }
}

// MARK: - QLPreviewController
extension UDMessagesView: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return selectedFile
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        setNeedsStatusBarAppearanceUpdate()
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


