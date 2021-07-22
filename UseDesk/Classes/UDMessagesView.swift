//
//  UDMessagesView.swift

import AVFoundation
import Photos
import PhotosUI
import Alamofire
import Swime
import MobileCoreServices
import AsyncDisplayKit

enum Orientation {
    case portrait
    case landscape
}

enum LandscapeOrientation {
    case left
    case right
}

class UDMessagesView: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASTableDataSource, ASTableDelegate {

    @IBOutlet weak var viewForTable: UIView!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var viewInputHC: NSLayoutConstraint!
    // TextView input
    @IBOutlet weak var textInput: UDTextView!
    @IBOutlet weak var textInputHC: NSLayoutConstraint!
    @IBOutlet weak var textInputBC: NSLayoutConstraint!
    @IBOutlet weak var textInputLC: NSLayoutConstraint!
    @IBOutlet weak var textInputTC: NSLayoutConstraint!
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
    
    public var sendAssets: [Any] = []
    public var messagesWithSection: [[UDMessage]] = []
    public var messagesDidLoadFile: [UDMessage] = []
    public var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    public var safeAreaInsetsBottom: CGFloat = 0.0
    public var tableNode = ASTableNode()
    
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
    
    convenience init() {
        let nibName: String = "UDMessagesView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        
        tableNode.backgroundColor = configurationStyle.chatStyle.backgroundColor
        self.view.backgroundColor = tableNode.backgroundColor
        tableNode.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        loadAssets()
        
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
        
        usedesk?.loader?.hide(animated: true)

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
        updateOrientation()
        attachCollectionView.frame = CGRect(origin: attachCollectionView.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachCollectionView.frame.height))
        attachFirstButton.frame = CGRect(origin: attachFirstButton.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachFirstButton.frame.height))
        attachSeparatorView.frame = CGRect(origin: attachSeparatorView.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachSeparatorView.frame.height))
        attachFileButton.frame = CGRect(origin: attachFileButton.frame.origin, size: CGSize(width: attachChangeView.frame.width, height: attachFileButton.frame.height))
        inputPanelUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissKeyboard()
        if isFirstOpen {
            tableNode.view.translatesAutoresizingMaskIntoConstraints = false
            viewForTable.addSubview(tableNode.view)
            let constraints = [
                tableNode.view.topAnchor.constraint(equalTo: viewForTable.topAnchor),
                tableNode.view.leftAnchor.constraint(equalTo: viewForTable.leftAnchor),
                tableNode.view.bottomAnchor.constraint(equalTo: viewForTable.bottomAnchor),
                tableNode.view.rightAnchor.constraint(equalTo: viewForTable.rightAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
            tableNode.reloadData()
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
        textInput.text = usedesk!.stringFor("Write") + "..."
        textInput.textColor = configurationStyle.inputViewStyle.placeholderTextColor
        
        textInput.isNeedCustomTextContainerInset = true
        textInput.customTextContainerInset = configurationStyle.inputViewStyle.textMargin
        
        attachFirstButton.setTitle(usedesk!.stringFor("Gallery"), for: .normal)
        attachFileButton.setTitle(usedesk!.stringFor("File").capitalized, for: .normal)
        attachCancelButton.setTitle(usedesk!.stringFor("Cancel"), for: .normal)
        
        attachFirstButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachFileButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        attachCollectionMessageViewTopC.constant = configurationStyle.inputViewStyle.topMarginAssetsCollection
        attachCollectionMessageViewHC.constant = configurationStyle.inputViewStyle.heightAssetsCollection
        
        tableNode.dataSource = self
        tableNode.delegate = self
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
    
    func indexPathForMessage(at messageId: Int) -> IndexPath? {
        var section = 0
        var row = 0
        var flag = true
        while section < messagesWithSection.count && flag {
            while row < messagesWithSection[section].count && flag {
                if messagesWithSection[section][row].messageId == messageId {
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
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if centerPortait == CGPoint.zero && !isFirstOpen {
                centerPortait = view.center
            }
            if keyboardHeightPortait != 0 && centerPortaitWithKeyboard == CGPoint.zero {
                centerPortaitWithKeyboard = CGPoint(x: centerPortait.x, y: centerPortait.y - keyboardHeightPortait)
            }
            tableNode.frame = CGRect(x: viewForTable.frame.origin.x, y: viewForTable.frame.origin.y, width: viewForTable.frame.width, height: viewForTable.frame.height)
            if previousOrientation != .portrait {
                self.view.center = isShowKeyboard ? centerPortaitWithKeyboard : centerPortait
                previousOrientation = .portrait
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableNode.reloadData()
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
                    tableNode.frame = CGRect(x: viewForTable.frame.origin.x + safeAreaInsetsLeftOrRight, y: viewForTable.frame.origin.y, width: viewForTable.frame.width - safeAreaInsetsLeftOrRight, height: viewForTable.frame.height)
                } else if previousOrientation != .landscape {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.right
                    tableNode.frame = CGRect(x: viewForTable.frame.origin.x, y: viewForTable.frame.origin.y, width: viewForTable.frame.width - safeAreaInsetsLeftOrRight, height: viewForTable.frame.height)
                }
            }
            if previousOrientation != .landscape {
                self.view.center = isShowKeyboard ? centerLandscapeWithKeyboard : centerLandscape
                previousOrientation = .landscape
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    wSelf.tableNode.reloadData()
                }
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
        if !isShowKeyboard {
            let info = notification.userInfo
            let keyboard: CGRect? = (info?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let duration = TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                    if self.keyboardHeightPortait == 0 {
                        self.keyboardHeightPortait = CGFloat(keyboard?.size.height ?? 0)
                    }
                    self.view.center = CGPoint(x: self.centerPortait.x, y: self.centerPortait.y - self.keyboardHeightPortait)
                } else {
                    if self.view.center == self.centerLandscape {
                        if self.keyboardHeightLandscape == 0 {
                            self.keyboardHeightLandscape = CGFloat(keyboard?.size.height ?? 0)
                        }
                        self.view.center = CGPoint(x: self.centerLandscape.x, y: self.centerLandscape.y - self.keyboardHeightLandscape)
                    }
                }
                self.tableNode.style.width = ASDimensionMake(self.viewForTable.frame.width)
                self.tableNode.style.height = ASDimensionMake(self.viewForTable.frame.height)
            })
            isShowKeyboard = true
            UIMenuController.shared.menuItems = nil
            inputPanelUpdate()
        }
    }
    
    @objc func keyboardHide(_ notification: Notification?) {
        if isShowKeyboard {
            updateTextInputComment()
            let info = notification?.userInfo
            let duration = TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
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
        let configurationStyle: ConfigurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        viewInput.backgroundColor = configurationStyle.inputViewStyle.viewBackColor
        textInput.backgroundColor = configurationStyle.inputViewStyle.textBackColor
        textInput.isScrollEnabled = true
        
        textInput.font = configurationStyle.inputViewStyle.font
        textInput.textColor = configurationStyle.inputViewStyle.textColor
        
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
        if !((textInput.text == usedesk!.stringFor("Write") + "..." && textInput.textColor == configurationStyle.inputViewStyle.placeholderTextColor)) {
            buttonSend.isEnabled = textInput.text.count != 0 || sendAssets.count > 0
        } else {
            buttonSend.isEnabled = sendAssets.count > 0 ? true : false
        }
    }
    
    func updateTextInputComment() {
        guard usedesk != nil else {return}
        if textInput.text.count == 0 {
            textInput.text = usedesk!.stringFor("Write") + "..."
            textInput.textColor = configurationStyle.inputViewStyle.placeholderTextColor
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
        if ((textInput.text == usedesk!.stringFor("Write") + "..." && textInput.textColor == configurationStyle.inputViewStyle.placeholderTextColor)) {
            actionSendMessage()
        } else {
            actionSendMessage(textInput.text)
            textInput.text = ""
        }
        inputPanelUpdate()
    }
    
    @IBAction func attachFirstButtonAction(_ sender: Any) {
        if selectedAssets.count > 0 {
            for selectedAsset in selectedAssets {
                sendAssets.append(selectedAsset)
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
        if sendAssets.count < maxCountAssets {
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "public.image", "public.data", "public.content", "public.movie", "public.audio", "public.archive", ], in: .import)
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
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined || photos == .denied {
            let alert = UIAlertController(title: usedesk!.stringFor("AllowMedia"), message: usedesk!.stringFor("ToSendMedia"), preferredStyle: .alert)
            let goToSettingsAction = UIAlertAction(title: usedesk!.stringFor("GoToSettings"), style: .default) { (action) in
                DispatchQueue.main.async {
                    let url = URL(string: UIApplication.openSettingsURLString)
                    UIApplication.shared.open(url!, options:convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]))
                }
            }
            let canselAction = UIAlertAction(title: usedesk!.stringFor("Cancel"), style: .cancel)
            alert.addAction(goToSettingsAction)
            alert.addAction(canselAction)
            self.present(alert, animated: true)
        } else {
            if assetsGallery.count == 0 {
                loadAssets()
            }
            var maxCountAssets = 10
            if usedesk != nil {
                maxCountAssets = usedesk!.maxCountAssets
            }
            if sendAssets.count < maxCountAssets {
                buttonAttach.alpha = 0
                buttonAttachLoader.alpha = 1
                buttonAttachLoader.startAnimating()
                showAttachView()
            } else {
                showAlertMaxCountAttach()
            }
        }
    }
    
    func actionSendMessage(_ text: String? = nil) {
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != textInput {
            dismissKeyboard()
        }
    }
    
    // MARK: - Attach Methods
    func showAttachCollection() { 
        attachCollectionMessageView.reloadData()
        isAttachFiles = true
        if !isViewInputResizeFromAttach {
            UIView.animate(withDuration: 0.3) {
                self.viewInput.frame.size.height += self.configurationStyle.inputViewStyle.heightAssetsCollection
                self.viewInput.frame.origin.y -= self.configurationStyle.inputViewStyle.heightAssetsCollection
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
                self.viewInput.frame.size.height -= self.configurationStyle.inputViewStyle.heightAssetsCollection
                self.viewInput.frame.origin.y += self.configurationStyle.inputViewStyle.heightAssetsCollection
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
        attachFirstButton.setTitle(usedesk!.stringFor("Gallery"), for: .normal)
        if assetsGallery.count > 0 {
            attachCollectionView.reloadData()
            attachCollectionView.contentOffset.x = 0
            UIView.animate(withDuration: 0.4) {
                self.attachBackView.alpha = 1
                self.attachViewBC.constant = 0
                self.view.layoutIfNeeded()
            }
        } else {
            takePhotoCamera()
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
            self.attachFirstButton.setTitle(self.usedesk!.stringFor("Gallery"), for: .normal)
            self.attachCollectionView.contentOffset.x = 0
            self.attachCollectionView.reloadData()
        }
    }
    
    func takePhotoCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func selectPhoto() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            let maxCountAssets = usedesk != nil ? usedesk!.maxCountAssets - sendAssets.count : 10 - sendAssets.count
            configuration.selectionLimit = maxCountAssets
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            imagePicker.present()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let chosenImage = info[.editedImage] as? UIImage
        if chosenImage != nil {
            sendAssets.append(chosenImage!)
            
            buttonSend.isHidden = false
            
            closeAttachView()
            showAttachCollection()
        }
        buttonSend.isEnabled = true
        picker.dismiss(animated: true)
    }
    
    func updateAttachCollectionViewLayout() {
        let attachCollectionLayout = UDAttachSmallCollectionLayout()
        attachCollectionLayout.scrollDirection = .horizontal
        attachCollectionLayout.delegate = self
        attachCollectionView.isScrollEnabled = true
        attachCollectionView.setCollectionViewLayout(attachCollectionLayout, animated: true)
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
        let alertController = UIAlertController(title: usedesk!.stringFor("AttachmentLimit"), message: nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: usedesk!.stringFor("Ok"), style: .default) { (_) -> Void in }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        inputPanelUpdate()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        inputPanelUpdate()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard usedesk != nil else {return}
        if textView == textInput {
            if (textView.text == usedesk!.stringFor("Write") + "..." && textView.textColor == configurationStyle.inputViewStyle.placeholderTextColor) {
                textInput.text = ""
                textInput.textColor = configurationStyle.inputViewStyle.textColor
            }
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard usedesk != nil else {return}
        if textView == textInput {
            if (textView.text == "") {
                textInput.text = usedesk!.stringFor("Write") + "..."
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
            if usedesk?.operatorName != "" {
                if let message = getMessage(indexPath) {
                    message.operatorName = usedesk!.operatorName
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
        if message?.type == RC_TYPE_TEXT {
            let cell = UDTextMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            return cell
        } else if message?.type == RC_TYPE_Feedback {
            let cell = UDFeedbackMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.usedesk = usedesk
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        } else  if message?.type == RC_TYPE_PICTURE {
            let cell = UDPictureMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        } else if message?.type == RC_TYPE_VIDEO {
            let cell = UDVideoMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        } else { //message?.type == RC_TYPE_File
            let cell = UDFileMessageCellNode()
            cell.isNeedShowSender = isNeedShowSender
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.view.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            cell.bindData(messagesView: self, message: message ?? UDMessage(), avatarImage: avatarImage(indexPath))
            return cell
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, willDisplayRowWith node: ASCellNode) {
        if let pictureCell = node as? UDPictureMessageCellNode {
            if let indexPath = pictureCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == RC_STATUS_SUCCEED {
                    pictureCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    pictureCell.setNeedsLayout()
                } else {
                    if message.file.path == "" && messagesDidLoadFile.filter({$0.messageId == message.messageId}).count == 0 {
                        // download image
                        messagesDidLoadFile.append(message)
                        DispatchQueue.global(qos: .userInitiated).async {
                        let session = URLSession.shared
                            autoreleasepool {
                        if let url = URL(string: message.file.content) {
                            (session.dataTask(with: url, completionHandler: { data, response, error in
                                if error == nil {
                                    let udMineType = UDMimeType()
                                    let mimeType = udMineType.typeString(for: data)
                                    DispatchQueue.main.async(execute: { [weak self] in
                                        guard let wSelf = self else {return}
                                        if let indexPathPicture = wSelf.indexPathForMessage(at: message.messageId) {
                                            if (mimeType == "image") {
                                                message.file.picture = UIImage(data: data!)?.resizeImage()
                                                message.file.path = FileManager.default.writeDataToCacheDirectory(data: data!) ?? ""
                                                message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? "Image") : "Image"
                                                message.status = RC_STATUS_SUCCEED
                                                message.file.type = "image"
                                                wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                                wSelf.tableNode.reloadRows(at: [indexPathPicture], with: .none)
                                            } else {
                                                message.file.picture = UIImage.named( "icon_file.png")
                                                message.status = RC_STATUS_SUCCEED
                                                message.file.type = mimeType
                                                wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                                wSelf.tableNode.reloadRows(at: [indexPathPicture], with: .none)
                                            }
                                        }
                                    })
                                }
                            })).resume()
                        }
                            }
                        }
                    }
                }
            }
        } else if let videoCell = node as? UDVideoMessageCellNode {
            if let indexPath = videoCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == RC_STATUS_SUCCEED {
                    videoCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    videoCell.setNeedsLayout()
                } else {
                    if message.file.path == "" && message.file.content != "" && messagesDidLoadFile.filter({$0.messageId == message.messageId}).count == 0 {
                        messagesDidLoadFile.append(message)
                        UDFileManager.downloadFile(indexPath: indexPath, urlPath: message.file.content, name: message.file.name, extansion: message.file.typeExtension) { [weak self] (indexPath, url) in
                            guard let wSelf = self else {return}
                            DispatchQueue.main.async(execute: {
                                if let indexPathVideo = wSelf.indexPathForMessage(at: message.messageId) {
                                    message.file.path = url.path
                                    message.file.picture = UDFileManager.videoPreview(filePath: message.file.path)
                                    message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                    message.status = RC_STATUS_SUCCEED
                                    wSelf.messagesWithSection[indexPathVideo.section][indexPathVideo.row] = message
                                    wSelf.tableNode.reloadRows(at: [indexPathVideo], with: .none)
                                }
                            })
                        } errorBlock: { _ in}
                    }
                }
            }
        } else if let fileCell = node as? UDFileMessageCellNode {
            if let indexPath = fileCell.indexPath {
                guard let message = getMessage(indexPath) else {return}
                if message.status == RC_STATUS_SUCCEED {
                    fileCell.bindData(messagesView: self, message: message, avatarImage: avatarImage(indexPath))
                    fileCell.setNeedsLayout()
                } else {
                    if message.file.path == "" && messagesDidLoadFile.filter({$0.messageId == message.messageId}).count == 0 {
                        messagesDidLoadFile.append(message)
                        let session = URLSession.shared
                        if let url = URL(string: message.file.content) {
                            (session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                                guard let wSelf = self else {return}
                                if error == nil && data != nil {
                                    DispatchQueue.main.async(execute: {
                                        var isFile = true
                                        message.status = RC_STATUS_SUCCEED
                                        if let mimeType = Swime.mimeType(data: data!) {
                                            if mimeType.mime.contains("video") {
                                                if let indexPathVideo = wSelf.indexPathForMessage(at: message.messageId) {
                                                    message.type = RC_TYPE_VIDEO
                                                    message.file.path = NSURL(fileURLWithPath: FileManager.default.writeDataToCacheDirectory(data: data!) ?? "").path ?? ""
                                                    message.file.picture = UDFileManager.videoPreview(filePath: message.file.path)
                                                    message.file.name = URL(fileURLWithPath: message.file.path).localizedName ?? "Video"
                                                    message.file.type = "video"
                                                    wSelf.messagesWithSection[indexPathVideo.section][indexPathVideo.row] = message
                                                    isFile = false
                                                    wSelf.tableNode.reloadRows(at: [indexPathVideo], with: .none)
                                                }
                                            } else if mimeType.mime.contains("image") {
                                                if let indexPathPicture = wSelf.indexPathForMessage(at: message.messageId) {
                                                    message.file.picture = UIImage(data: data!)?.resizeImage()
                                                    message.file.path = FileManager.default.writeDataToCacheDirectory(data: data!) ?? ""
                                                    message.file.name = message.file.path != "" ? (URL(fileURLWithPath: message.file.path).localizedName ?? "Image") : "Image"
                                                    message.file.type = "image"
                                                    wSelf.messagesWithSection[indexPathPicture.section][indexPathPicture.row] = message
                                                    isFile = false
                                                    wSelf.tableNode.reloadRows(at: [indexPathPicture], with: .none)
                                                }
                                            }
                                        }
                                        if isFile {
                                            if let indexPathFile = wSelf.indexPathForMessage(at: message.messageId) {
                                                message.file.picture = UIImage(data: data!)
                                                message.file.path = NSURL(fileURLWithPath: FileManager.default.writeDataToCacheDirectory(data: data!) ?? "").path ?? ""
                                                message.file.type = "file"
                                                message.file.sizeInt = data!.count
                                                wSelf.messagesWithSection[indexPathFile.section][indexPathFile.row] = message
                                                if let cell = (wSelf.tableNode.nodeForRow(at: indexPathFile) as? UDFileMessageCellNode) {
                                                    cell.setLoadedFileStatus()
                                                    cell.setNeedsLayout()
                                                } else {
                                                    wSelf.tableNode.reloadRows(at: [indexPathFile], with: .none)
                                                }
                                            }
                                        }
                                    })
                                }
                            })).resume()
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
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return configurationStyle.sectionHeaderStyle.heightHeader
    }
}

// MARK: - UICollectionViewDelegate
extension UDMessagesView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == attachCollectionView {
            return assetsGallery.count + 1
        } else {
            return sendAssets.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == attachCollectionView {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDAttachSmallCameraCollectionViewCell", for: indexPath) as! UDAttachSmallCameraCollectionViewCell
                if isAttachmentActive {
                    DispatchQueue.main.async {
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
            guard indexPath.row < sendAssets.count else { return cell }
            if (sendAssets[indexPath.row] as? UIImage) != nil {
                let image = sendAssets[indexPath.row] as! UIImage
                cell.setingCell(image: image, type: .image, index: indexPath.row)
            } else if (sendAssets[indexPath.row] as? PHAsset) != nil {
                let asset = sendAssets[indexPath.row] as! PHAsset
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)), contentMode: .aspectFit, options: options, resultHandler: {[weak self] result, info in
                    if result != nil {
                        guard let wSelf = self else {return}
                        cell.setingCell(image: result!, type: asset.mediaType == .video ? .video : .image, videoDuration: asset.duration, index: indexPath.row)
                    }
                })
            } else if (sendAssets[indexPath.row] as? URL) != nil {
                cell.setingCell(type: .file, urlFile: (sendAssets[indexPath.row] as! URL), index: indexPath.row)
            } else if let data = sendAssets[indexPath.row] as? Data {
                if let image = UIImage(data: data) {
                    cell.setingCell(image: image, type: .image, index: indexPath.row)
                }
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
                if (sendAssets.count + selectedAssets.count < maxCountAssets) {
                    takePhotoCamera()
                } else {
                    showAlertMaxCountAttach()
                }
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as! UDAttachSmallCollectionViewCell
                if (sendAssets.count + selectedAssets.count < maxCountAssets) || cell.isActive {
                    if cell.isActive {
                        selectedAssets.remove(at: selectedAssets.firstIndex(of: assetsGallery[indexPath.row - 1])!)
                    } else {
                        selectedAssets.append(assetsGallery[indexPath.row - 1])
                    }
                    if selectedAssets.count > 0 {
                        isSelectAttachment = true
                        attachFirstButton.setTitle("\(usedesk!.stringFor("Attach")) \(selectedAssets.count.countFilesString(usedesk!))", for: .normal)
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
                        attachFirstButton.setTitle(usedesk!.stringFor("Gallery"), for: .normal)
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
            sendAssets.append(urls[0])
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
        sendAssets.remove(at: index)
        attachCollectionMessageView.reloadData()
        if sendAssets.count == 0 {
            sendAssets = []
            buttonSend.isEnabled = textInput.text.count != 0
            closeAttachCollection()
        }
    }
}

// MARK: - UDFeedbackMessageCellNodeDelegate
extension UDMessagesView: UDFeedbackMessageCellNodeDelegate {
    func feedbackAction(indexPath: IndexPath, feedback: Bool) {
        guard usedesk != nil else {return}
        if getMessage(indexPath) != nil {
            messagesWithSection[indexPath.section][indexPath.row].text = usedesk!.stringFor("ArticleReviewSendedTitle")
            messagesWithSection[indexPath.section][indexPath.row].attributedString = NSMutableAttributedString(string: usedesk!.stringFor("ArticleReviewSendedTitle"))
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
            sendAssets.append(image!)
        }
        closeAttachView()
        showAttachCollection()
        buttonSend.isEnabled = true
    }
}
// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension UDMessagesView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        fetchResult.enumerateObjects { [weak self] (asset, index, stop) -> Void in
            guard let wSelf = self else {return}
            wSelf.sendAssets.append(asset)
            if index == fetchResult.count - 1 {
                wSelf.closeAttachView()
                wSelf.showAttachCollection()
                wSelf.buttonSend.isEnabled = true
            }
        }
    }
}
// MARK: - ImagePicker
public protocol ImagePickerDelegate: class {
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
