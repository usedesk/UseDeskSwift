//
//  UDOfflineForm.swift

import MobileCoreServices
import Alamofire
import Photos
import PhotosUI

@objc public enum UDFeedbackStatus: Int {
    case null
    case never
    case feedbackForm
    case feedbackFormAndChat
    
    var isNotOpenFeedbackForm: Bool {
        return self == .null || self == .never
    }
    
    var isOpenFeedbackForm: Bool {
        return self == .feedbackForm || self == .feedbackFormAndChat
    }
}

class UDOfflineForm: UIViewController, UITextFieldDelegate, PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHC: NSLayoutConstraint!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var sendMessageButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var sendLoader: UIActivityIndicatorView!
    @IBOutlet weak var sendedView: UIView!
    @IBOutlet weak var sendedViewBC: NSLayoutConstraint!
    @IBOutlet weak var sendedCornerRadiusView: UIView!
    @IBOutlet weak var sendedImage: UIImageView!
    @IBOutlet weak var sendedLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var keyboardTopView: UIView!
    @IBOutlet weak var keyboardTopViewBC: NSLayoutConstraint!
    @IBOutlet weak var attachButton: UIButton!
  
    @IBOutlet weak var attachedView: UIView!
    @IBOutlet weak var attachedCollectionView: UICollectionView!
    @IBOutlet weak var attachedCollectionViewHC: NSLayoutConstraint!
    
    @IBOutlet weak var attachBackView: UIView!
    @IBOutlet weak var attachBlackView: UIView!
    @IBOutlet weak var attachCollectionView: UICollectionView!
    @IBOutlet weak var attachViewBC: NSLayoutConstraint!
    @IBOutlet weak var attachChangeView: UIView!
    @IBOutlet weak var attachSeparatorView: UIView!
    @IBOutlet weak var attachFirstButton: UIButton!
    @IBOutlet weak var attachFileButton: UIButton!
    @IBOutlet weak var attachCancelButton: UIButton!
    
    var isFromBase = false
    weak var usedesk: UseDeskSDK?
    
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var selectedIndexPath: IndexPath? = nil
    private var fields: [UDInfoItem] = []
    private var textViewYPositionCursor: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 336
    private var isShowKeyboard = false
    private var isFirstOpen = true
    private var previousOrientation: Orientation = .portrait
    private var selectedTopicIndex: Int? = nil
    private var dialogflowVC : DialogflowView = DialogflowView()
    private var kOffsetScrollViewForKeyboard: CGFloat = 20
    private var heightNavigationBar : CGFloat {
        return navigationController?.navigationBar.frame.height ?? 44
    }
    private var bottomOffset: CGFloat {
        var offset = view.frame.height - heightNavigationBar - keyboardHeight - kOffsetScrollViewForKeyboard
        if keyboardTopView.alpha == 1 {
            offset -= keyboardTopView.frame.height
        }
        return offset
    }
    
    private var assetsGallery: [PHAsset] = []
    private var selectedAssets: [PHAsset] = []
    private var selectedFile: UDFile? = nil
    private var imagePicker: ImagePicker!
    private var kHeightAttachView: CGFloat = 304
    private var isAttachmentActive = false
    private var isSelectAttachment = false
    private var isAttachFiles = false
    
    private let kLimitSizeFile: Double = 128
    
    convenience init() {
        let nibName: String = "UDOfflineForm"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstOpen {
            notSelectedAttachmentStatesViews()
            isFirstOpen = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isFirstOpen else {
            updateAttachCollectionViewLayout()
            attachCollectionView.contentOffset.x = 0
            
            return
        }
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if previousOrientation != .portrait {
                previousOrientation = .portrait
                self.view.endEditing(true)
            }
        } else {
            if previousOrientation != .landscape {
                previousOrientation = .landscape
                self.view.endEditing(true)
            }
        }
    }
    
    // MARK: - Private
    func firstState() {
        guard usedesk != nil else {return}
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        self.view.backgroundColor = configurationStyle.chatStyle.backgroundColor
        scrollView.delegate = self
        scrollView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        contentView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        sendLoader.alpha = 0
        title = usedesk?.callbackSettings.title ?? usedesk!.model.stringFor("Chat")
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
        navigationController?.navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        if (usedesk?.model.isPresentDefaultControllers ?? true) || isFromBase {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        }
        let feedbackFormStyle = configurationStyle.feedbackFormStyle
        tableView.register(UINib(nibName: "UDTextAnimateTableViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDTextAnimateTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        textLabel.textColor = feedbackFormStyle.textColor
        textLabel.font = feedbackFormStyle.textFont
        textLabel.text = usedesk?.callbackSettings.greeting ?? usedesk!.model.stringFor("FeedbackText")
        sendMessageButton.backgroundColor = feedbackFormStyle.buttonColorDisabled
        sendMessageButton.tintColor = feedbackFormStyle.buttonTextColor
        sendMessageButton.titleLabel?.font = feedbackFormStyle.buttonFont
        sendMessageButton.isEnabled = false
        sendMessageButton.layer.masksToBounds = true
        sendMessageButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        sendMessageButton.setTitle(usedesk!.model.stringFor("Send"), for: .normal)
        
        setAttachViews()
        
        sendedViewBC.constant = -400
        sendedCornerRadiusView.layer.cornerRadius = 13
        sendedCornerRadiusView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        sendedView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        sendedView.layer.masksToBounds = false
        sendedView.layer.shadowColor = UIColor.black.cgColor
        sendedView.layer.shadowOpacity = 0.6
        sendedView.layer.shadowOffset = CGSize.zero
        sendedView.layer.shadowRadius = 20.0

        sendedImage.image = feedbackFormStyle.sendedImage
        sendedLabel.text = usedesk!.model.stringFor("FeedbackSendedMessage")
        sendedLabel.textColor = feedbackFormStyle.textColor
        closeButton.backgroundColor = feedbackFormStyle.buttonColor
        closeButton.tintColor = feedbackFormStyle.buttonTextColor
        closeButton.titleLabel?.font = feedbackFormStyle.buttonFont
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        closeButton.setTitle(usedesk!.model.stringFor("Close"), for: .normal)
        
        if usedesk != nil {
            fields = [UDInfoItem(type: .name, value: UDTextItem(text: usedesk!.model.name)), UDInfoItem(type: .email, value: UDContactItem(contact: usedesk?.model.email ?? "")), UDInfoItem(type: .selectTopic, value: UDTextItem(text: ""))]
            for custom_field in usedesk!.callbackSettings.checkedCustomFields {
                fields.append(UDInfoItem(type: .custom, value: UDCustomFieldItem(field: custom_field)))
            }
            fields.append(UDInfoItem(type: .message, value: UDTextItem(text: "")))
        }
        selectedIndexPath = IndexPath(row: 2, section: 0)
        tableView.reloadData()
        setHeightTables()
    }
    
    func setAttachViews() {
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.title = usedesk!.model.stringFor("AttachFile")
            configuration.image = configurationStyle.attachButtonStyle.image
            configuration.background = .clear()
            configuration.imagePlacement = .leading
            configuration.imagePadding = 5
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            configuration.attributedTitle = AttributedString(usedesk!.model.stringFor("AttachFile"), attributes: AttributeContainer([.font : configurationStyle.feedbackFormStyle.attachButtonTitleFont, .foregroundColor : configurationStyle.feedbackFormStyle.attachButtonTitleColor]))
            attachButton.configuration = configuration
        } else {
            attachButton.setImage(configurationStyle.attachButtonStyle.image, for: .normal)
            attachButton.setTitle(usedesk!.model.stringFor("AttachFile"), for: .normal)
            attachButton.setAttributedTitle(NSAttributedString(string: usedesk!.model.stringFor("AttachFile"), attributes: [.font : configurationStyle.feedbackFormStyle.attachButtonTitleFont, .foregroundColor : configurationStyle.feedbackFormStyle.attachButtonTitleColor]), for: .normal)
            attachButton.setTitleColor(configurationStyle.feedbackFormStyle.attachButtonTitleColor, for: .normal)
            attachButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            attachButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            attachButton.tintColor = configurationStyle.feedbackFormStyle.attachButtonTitleColor
        }
        attachedCollectionView.delegate = self
        attachedCollectionView.dataSource = self
        attachedCollectionView.register(UDAttachCollectionViewCell.self, forCellWithReuseIdentifier: "UDAttachCollectionViewCell")
        
        attachCollectionView.delegate = self
        attachCollectionView.dataSource = self
        attachCollectionView.register(UINib(nibName: "UDAttachSmallCollectionViewCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDAttachSmallCollectionViewCell")
        attachCollectionView.register(UINib(nibName: "UDAttachSmallCameraCollectionViewCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDAttachSmallCameraCollectionViewCell")
        
        attachFirstButton.setTitle(usedesk!.model.stringFor("Gallery"), for: .normal)
        attachFileButton.setTitle(usedesk!.model.stringFor("File").capitalized, for: .normal)
        attachCancelButton.setTitle(usedesk!.model.stringFor("Cancel"), for: .normal)
        
        attachFirstButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachFileButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        attachCancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        attachFirstButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        attachFileButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
        attachCancelButton.tintColor = configurationStyle.attachViewStyle.textButtonColor
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            isShowKeyboard = true
            keyboardHeight = keyboardSize.height
            var bottomOffsetScrollView = keyboardHeight
            if selectedIndexPath != nil {
                if fields[selectedIndexPath!.row].type == .message {
                    bottomOffsetScrollView += keyboardTopView.frame.height
                }
                if fields[selectedIndexPath!.row].type == .message {
                    keyboardTopView.alpha = 1
                }
            }
            UIView.animate(withDuration: 0.4) {
                self.scrollViewBC.constant = bottomOffsetScrollView
                var offsetPlus: CGFloat = 0
                if self.selectedIndexPath != nil {
                    if let cell = self.tableView.cellForRow(at: self.selectedIndexPath!) as? UDTextAnimateTableViewCell {
                        offsetPlus = cell.frame.origin.y + cell.frame.height + self.tableView.frame.origin.y - self.scrollView.contentOffset.y
                    }
                    if self.fields[self.selectedIndexPath!.row].type == .message {
                        self.keyboardTopViewBC.constant = self.keyboardHeight
                    }
                }
                self.view.layoutSubviews()
                self.view.layoutIfNeeded()
                if offsetPlus > (self.view.frame.height - self.keyboardHeight) {
                    self.scrollView.contentOffset.y += offsetPlus - (self.view.frame.height - (bottomOffsetScrollView + self.kOffsetScrollViewForKeyboard))
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isShowKeyboard {
            UIView.animate(withDuration: 0.4) {
                self.scrollViewBC.constant = 0
                self.keyboardTopView.alpha = 0
                self.keyboardTopViewBC.constant = 0
                if self.scrollView.contentSize.height <= self.scrollView.frame.height {
                    UIView.animate(withDuration: 0.4) {
                        self.scrollView.contentOffset.y = 0
                    }
                } else {
                    let offset = self.keyboardHeight - 138
                    UIView.animate(withDuration: 0.4) {
                        if offset > self.scrollView.contentOffset.y {
                            self.scrollView.contentOffset.y = 0
                        } else {
                            self.scrollView.contentOffset.y -= offset
                        }
                    }
                }
                self.view.layoutIfNeeded()
            }
            isShowKeyboard = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking && selectedIndexPath != nil {
            selectedIndexPath = nil
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func indexFieldsForType(_ type: UDNameFields) -> Int {
        var flag = true
        var index = 0
        while flag && index < fields.count {
            if fields[index].type == type {
                flag = false
            } else {
                index += 1
            }
        }
        return flag ? 0 : index
    }
    
    func showAlert(_ title: String?, text: String?) {
        guard usedesk != nil else {return}
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: usedesk!.model.stringFor("Understand"), style: .default, handler: {_ in
        })
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func activateSendMessageButton() {
        if let messageItem = fields[indexFieldsForType(.message)].value as? UDTextItem, messageItem.text.count > 0 {
            UIView.animate(withDuration: 0.3) {
                self.sendMessageButton.isEnabled = true
                self.sendMessageButton.backgroundColor = self.configurationStyle.feedbackFormStyle.buttonColor
            }
        }
    }
    
    func deactivateSendMessageButton() {
        UIView.animate(withDuration: 0.3) {
            self.sendMessageButton.isEnabled = false
            self.sendMessageButton.backgroundColor = self.configurationStyle.feedbackFormStyle.buttonColorDisabled
        }
    }
    
    func setHeightTables() {
        var height: CGFloat = 0
        var selectedCellPositionY: CGFloat = tableView.frame.origin.y
        for index in 0..<fields.count {
            var text = ""
            if fields[index].type == .email {
                if let contactItem = fields[index].value as? UDContactItem {
                    text = contactItem.contact
                }
            } else if let textItem = fields[index].value as? UDTextItem {
                text = textItem.text
            } else if let fieldItem = fields[index].value as? UDCustomFieldItem {
                text = fieldItem.field.text
            }
            if index == selectedIndexPath?.row {
                selectedCellPositionY += height
            }
            let minimumHeightText = "t".size(availableWidth: tableView.frame.width - 30, attributes: [NSAttributedString.Key.font : configurationStyle.feedbackFormStyle.valueFont], usesFontLeading: true).height
            var heightText = text.size(availableWidth: tableView.frame.width - 30, attributes: [NSAttributedString.Key.font : configurationStyle.feedbackFormStyle.valueFont], usesFontLeading: true).height
            heightText = heightText < minimumHeightText ? minimumHeightText : heightText
            height += heightText + 47
        }
        UIView.animate(withDuration: 0.3) {
            self.tableViewHC.constant = height
            self.view.layoutIfNeeded()
        }
        let yPositionCursor = (textViewYPositionCursor + (selectedCellPositionY - scrollView.contentOffset.y))
        if yPositionCursor > bottomOffset {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.y = (yPositionCursor + self.scrollView.contentOffset.y) - self.bottomOffset
            }
        }
    }
    
    func showSendedView() {
        scrollView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.6) {
            self.sendedViewBC.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func startChat(text: String, file: UDFile?) {
        guard usedesk != nil else {
            showSendedView()
            return
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.model.companyID, chanelId: usedesk!.model.chanelId, url: usedesk!.model.urlWithoutPort, port: usedesk!.model.port, api_token: usedesk!.model.api_token, knowledgeBaseID: usedesk!.model.knowledgeBaseID, name: usedesk!.model.name, email: usedesk!.model.email, phone: usedesk!.model.phone, token: usedesk!.model.token, connectionStatus: { [weak self] success, feedbackStatus, token in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureStartBlock != nil {
                wSelf.usedesk!.closureStartBlock!(success, feedbackStatus, token)
            }
            if !success && feedbackStatus == .feedbackForm {
                wSelf.showSendedView()
            } else {
                if wSelf.usedesk?.uiManager?.visibleViewController() != wSelf.dialogflowVC {
                    DispatchQueue.main.async(execute: {
                        wSelf.dialogflowVC.usedesk = wSelf.usedesk
                        wSelf.dialogflowVC.isFromBase = wSelf.isFromBase
                        wSelf.dialogflowVC.isFromOfflineForm = true
                        wSelf.dialogflowVC.delegate = self
                        wSelf.usedesk?.uiManager?.pushViewController(wSelf.dialogflowVC)
                        if let index = wSelf.navigationController?.viewControllers.firstIndex(of: wSelf) {
                            wSelf.navigationController?.viewControllers.remove(at: index)
                        }
                        wSelf.usedesk?.sendMessage(text, completionBlock: {
                            if let sendFile = file, let fileData = sendFile.dataLocal {
                                wSelf.usedesk?.sendFile(fileName: sendFile.name, data: fileData)
                            }
                        })
                        wSelf.selectedFile = nil
                    })
                }
            }
        }, errorStatus: {  [weak self] error, description  in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureErrorBlock != nil {
                wSelf.usedesk!.closureErrorBlock!(error, description)
            }
            wSelf.close()
        })
    }
    
    @objc func backAction() {
        if isFromBase {
            usedesk?.closeChat()
            navigationController?.popViewController(animated: true)
        } else {
            usedesk?.releaseChat()
            dismiss(animated: true)
        }
    }
    
    // MARK: - Attach Methods
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
    
    func showAlertAllowMedia() {
        guard usedesk != nil else {return}
        let alert = UIAlertController(title:usedesk!.model.stringFor("AllowMedia"), message: usedesk!.model.stringFor("ToSendMedia"), preferredStyle: .alert)
        let goToSettingsAction = UIAlertAction(title: usedesk!.model.stringFor("GoToSettings"), style: .default) { (action) in
            DispatchQueue.main.async {
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]))
            }
        }
        let canselAction = UIAlertAction(title: usedesk!.model.stringFor("Cancel"), style: .cancel)
        alert.addAction(goToSettingsAction)
        alert.addAction(canselAction)
        self.present(alert, animated: true)
    }
    
    func checkMaxCountAssetsAndShowAttachView() {
        if assetsGallery.count == 0 {
            loadAssets()
        }
        if selectedFile == nil {
            showAttachView()
        } else {
            showAlertMaxCountAttach()
        }
    }
    
    func showAlertMaxCountAttach() {
        guard usedesk != nil else {return}
        let alertController = UIAlertController(title: usedesk!.model.stringFor("AttachmentLimit"), message: nil, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: usedesk!.model.stringFor("Ok"), style: .default) { (_) -> Void in }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    func showAttachedCollection() {
        guard selectedFile != nil else {return}
        attachedCollectionView.reloadData()
        isAttachFiles = true
        UIView.animate(withDuration: 0.3) {
            self.sendMessageButtonTopC.constant = 30 + self.attachedView.frame.height
            self.attachedCollectionView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func closeAttachedCollection() {
        if isAttachFiles {
            isAttachFiles = false
            UIView.animate(withDuration: 0.3) {
                self.sendMessageButtonTopC.constant = 30
                self.attachedCollectionView.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func selectPhoto() {
        if #available(iOS 14, *) {
            var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            configuration.selectionLimit = 1
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == (kUTTypeImage as String), let chosenImage = info[.originalImage] as? UIImage {
                setSelectedFile(with: chosenImage.udFixedOrientation())
            } else if mediaType == (kUTTypeMovie as String), let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                setSelectedFile(with: url)
            }
        }
        closeAttachView()
        showAttachedCollection()
        picker.dismiss(animated: true)
    }
    
    func setSelectedFile(with asset: Any) {
        deactivateSendMessageButton()
        let file = UDFile()
        selectedFile = file
        if let asset = asset as? PHAsset {
            file.setAsset(asset: asset) {
                DispatchQueue.main.async { [weak self] in
                    guard let wSelf = self else {return}
                    if file.sizeFile > wSelf.kLimitSizeFile {
                        wSelf.selectedFile = nil
                        wSelf.showAlertLimitSizeFile(with: file)
                        wSelf.updateAttachCollectionView()
                        wSelf.deactivateSendMessageButton()
                        return
                    } else {
                        wSelf.selectedFile = file
                    }
                    let indexPath = IndexPath(row: 0, section: 0)
                    if let cell = wSelf.attachedCollectionView.cellForItem(at: indexPath) as? UDAttachCollectionViewCell {
                        if file.type == .video {
                            if let previewImage = file.preview  {
                                cell.setingCell(image: previewImage, type: .video, videoDuration: file.duration, index: indexPath.row)
                            }
                        } else {
                            if let image = file.preview {
                                cell.setingCell(image: image, type: .image, index: indexPath.row)
                            }
                        }
                    }
                    wSelf.activateSendMessageButton()
                }
            }
        } else if let image = asset as? UIImage {
            autoreleasepool {
                if let imageData = image.udToData() {
                    file.type = .image
                    file.sizeInt = imageData.count
                    if (image.pngData()?.size ?? 0) > kLimitSizeFile {
                        selectedFile = nil
                        showAlertLimitSizeFile(with: file)
                        deactivateSendMessageButton()
                    } else {
                        file.previewImage = image
                        let content = "data:image/png;base64,\(imageData.base64EncodedString())"
                        file.dataLocal = imageData
                        var fileName = String(format: "%ld", content.hash)
                        fileName += ".png"
                        file.mimeType = "image/png"
                        file.name = fileName
                        file.sourceTypeString = UDTypeSourceFile.UIImage.rawValue
                        selectedFile = file
                        activateSendMessageButton()
                    }
                }
            }
        } else if let urlFile = asset as? URL {
            if urlFile.pathExtension.lowercased() == "mov" {
                autoreleasepool {
                    if let videoData = try? Data(contentsOf: urlFile) {
                        file.type = .video
                        file.sizeInt = videoData.count
                        if videoData.size > kLimitSizeFile {
                            selectedFile = nil
                            showAlertLimitSizeFile(with: file)
                            deactivateSendMessageButton()
                        } else {
                            let content = "data:video/mp4;base64,\(videoData.base64EncodedString())"
                            file.dataLocal = videoData
                            var fileName = String(format: "%ld", content.hash)
                            fileName += ".mp4"
                            file.mimeType = "video/mp4"
                            file.previewImage = UDFileManager.videoPreview(fileURL: urlFile)
                            let asset = AVURLAsset(url: urlFile)
                            file.duration = Double(CMTimeGetSeconds(asset.duration))
                            file.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                            selectedFile = file
                            activateSendMessageButton()
                        }
                    }
                }
            } else {
                if let dataFile = try? Data(contentsOf: urlFile) {
                    let fileName = urlFile.lastPathComponent
                    file.name = fileName
                    file.sizeInt = dataFile.count
                    if dataFile.size > kLimitSizeFile {
                        selectedFile = nil
                        showAlertLimitSizeFile(with: file)
                        deactivateSendMessageButton()
                    } else {
                        file.sourceTypeString = UDTypeSourceFile.URL.rawValue
                        if #available(iOS 14.0, *) {
                            if let type = UTType(filenameExtension: urlFile.pathExtension), let mimeType = type.preferredMIMEType {
                                file.mimeType = mimeType
                            } else {
                                file.mimeType = "application/pdf"
                            }
                        } else {
                            file.mimeType = "application/pdf"
                            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, NSString(string: urlFile.pathExtension), nil)?.takeRetainedValue() {
                                if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                                    file.mimeType = mimetype as String
                                }
                            }
                        }
                        file.content = "data:\(file.mimeType);base64,\(dataFile.base64EncodedString())"
                        file.dataLocal = dataFile
                        selectedFile = file
                        activateSendMessageButton()
                    }
                }
            }
        }
    }
    
    
    
    func showAlertLimitSizeFile(with file: UDFile) {
        guard usedesk != nil else {return}
        let sizeFile = file.size(mbString: usedesk!.model.stringFor("Mb"), gbString: usedesk!.model.stringFor("Gb"))
        let messageString = usedesk!.model.stringFor("ThisFileSize") + " " + sizeFile + " " + usedesk!.model.stringFor("ExceededMaximumSize") + " \(kLimitSizeFile) " + usedesk!.model.stringFor("Mb")
        let alertController = UIAlertController(title: usedesk!.model.stringFor("LimitIsExceeded"), message: messageString, preferredStyle: .alert)
        if let previewImage = file.previewImage {
            alertController.udAdd(image: previewImage, isVideo: file.type == .video)
        } else {
            alertController.udAdd(image: previewFileForLimitSizeAlert(file: file).udImage())
        }
        let understandAction = UIAlertAction(title: usedesk!.model.stringFor("Understand"), style: .default) { [weak self] (action) in
            guard let wSelf = self else {return}
            wSelf.selectedFile = nil
            wSelf.updateAttachCollectionView()
        }
        alertController.addAction(understandAction)
        present(alertController, animated: true, completion: nil)
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
    
    func updateAttachCollectionViewLayout() {
        let attachCollectionLayout = UDAttachSmallCollectionLayout()
        attachCollectionLayout.scrollDirection = .horizontal
        attachCollectionLayout.delegate = self
        attachCollectionView.isScrollEnabled = true
        attachCollectionView.setCollectionViewLayout(attachCollectionLayout, animated: true)
    }
    
    func updateAttachCollectionView() {
        attachCollectionView.reloadData()
        if selectedFile == nil {
            closeAttachedCollection()
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
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
// MARK: - Actions
    @IBAction func attachButtonAction(_ sender: Any) {
        if let indexPath = selectedIndexPath, fields[indexPath.row].type == .message, let cellMessage = tableView.cellForRow(at: indexPath) as? UDTextAnimateTableViewCell {
            selectedIndexPath = nil
            cellMessage.setNotSelectedAnimate()
        }
        guard usedesk != nil else {return}
        self.view.endEditing(true)
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
    
    @IBAction func attachFirstButtonAction(_ sender: Any) {
        if selectedAssets.count > 0 {
            for index in 0..<selectedAssets.count {
                setSelectedFile(with: selectedAssets[index])
            }
            closeAttachView()
            showAttachedCollection()
        } else {
            selectPhoto()
        }
    }
    
    @IBAction func attachFileButtonAction(_ sender: Any) {
        if selectedFile == nil {
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
        selectedAssets.removeAll()
        closeAttachView()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard sendLoader.alpha == 0 else {return}
        guard usedesk != nil else {return}
        sendLoader.alpha = 1
        sendLoader.startAnimating()
        sendMessageButton.setTitle("", for: .normal)
        let email = (fields[indexFieldsForType(.email)].value as? UDContactItem)?.contact ?? ""
        let name = (fields[indexFieldsForType(.name)].value as? UDTextItem)?.text ?? (usedesk?.model.name ?? "")
        let topic = (fields[indexFieldsForType(.selectTopic)].value as? UDTextItem)?.text ?? ""
        var isValidTopic = true
        if usedesk!.callbackSettings.isRequiredTopic {
            if topic == "" {
                isValidTopic = false
            }
        }
        var customFields: [UDCallbackCustomField] = []
        var isValidFields = true
        var indexErrorFields: [Int] = []
        for index in 3..<fields.count {
            if let fieldItem = fields[index].value as? UDCustomFieldItem {
                let value = index == indexFieldsForType(.message) ? fieldItem.field.text.udRemoveFirstAndLastLineBreaksAndSpaces() : fieldItem.field.text
                if value.count > 0 {
                    customFields.append(fieldItem.field)
                } else if fieldItem.field.isRequired || index == indexFieldsForType(.message) {
                    isValidFields = false
                    fieldItem.field.isValid = false
                    fields[index].value = fieldItem
                    indexErrorFields.append(index)
                }
            }
        }
        if email.udIsValidEmail() && name != "" && isValidTopic && isValidFields {
            self.view.endEditing(true)
            if let message = fields[indexFieldsForType(.message)].value as? UDTextItem {
                if usedesk!.callbackSettings.type == .always_and_chat {
                    var text = name + "\n" + email
                    if topic != "" {
                        text += "\n" + topic
                    }
                    for field in customFields {
                        text += "\n" + field.text
                    }
                    text += "\n" + message.text
                    startChat(text: text, file: selectedFile)
                } else {
                    usedesk!.sendOfflineForm(name: name, email: email, message: message.text, file: selectedFile, topic: topic, fields: customFields) { [weak self] (result) in
                        guard let wSelf = self else {return}
                        if result {
                            wSelf.sendLoader.alpha = 0
                            wSelf.sendLoader.stopAnimating()
                            wSelf.showSendedView()
                        }
                    } errorStatus: { [weak self] (_, _) in
                        guard let wSelf = self else {return}
                        wSelf.sendLoader.alpha = 0
                        wSelf.sendLoader.stopAnimating()
                        wSelf.showAlert(wSelf.usedesk!.model.stringFor("Error"), text: wSelf.usedesk!.model.stringFor("ServerError"))
                    }
                }
            }
        } else {
            selectedIndexPath = nil
            if !email.udIsValidEmail() {
                fields[indexFieldsForType(.email)].value = UDContactItem(contact: email, isValid: false)
                selectedIndexPath = IndexPath(row: 1, section: 0)
            }
            if !isValidTopic {
                if let topic = fields[indexFieldsForType(.selectTopic)].value as? UDTextItem {
                    fields[indexFieldsForType(.selectTopic)].value = UDTextItem(text: topic.text, isValid: false)
                }
            }
            if !isValidFields {
                selectedIndexPath = IndexPath(row: indexErrorFields[0], section: 0)
            }
            tableView.reloadData()
            sendLoader.alpha = 0
            sendLoader.stopAnimating()
            sendMessageButton.setTitle(usedesk!.model.stringFor("Send"), for: .normal)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        backAction()
    }
    
    // MARK: - Methods Cells
    func createNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if let nameClient = fields[indexPath.row].value as? UDTextItem {
            if usedesk != nil {
                let isValid = nameClient.text == "" && indexPath != selectedIndexPath ? false : true
                var title = usedesk!.model.stringFor("Name")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = nameClient.text
                var attributedTextString: NSMutableAttributedString? = nil
       
                attributedTitleString = NSMutableAttributedString()
                attributedTitleString!.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                
                if !isValid {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.model.stringFor("MandatoryField")
                    attributedTitleString = nil
                }
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
            }
        }
        cell.delegate = self
        if indexPath == selectedIndexPath {
            cell.setSelectedAnimate()
        } else {
            cell.setNotSelectedAnimate()
        }
        return cell
    }
    
    func createEmailCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if let emailClient = fields[indexPath.row].value as? UDContactItem {
            if usedesk != nil {
                var isValid = emailClient.isValid
                var title = usedesk!.model.stringFor("Email")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = emailClient.contact
                var attributedTextString: NSMutableAttributedString? = nil
                
                if !isValid {
                    title = usedesk!.model.stringFor("ErrorEmail")
                }
                attributedTitleString = NSMutableAttributedString()
                attributedTitleString!.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))

                if emailClient.contact == "" && indexPath != selectedIndexPath {
                    attributedTextString = attributedTitleString
                    text = usedesk!.model.stringFor("Email")
                    title = usedesk!.model.stringFor("MandatoryField")
                    attributedTitleString = nil
                    isValid = false
                }
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
            }
        }
        cell.delegate = self
        if indexPath == selectedIndexPath {
            cell.setSelectedAnimate()
        } else {
            cell.setNotSelectedAnimate()
        }
        return cell
    }
    
    func createSelectTopicCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if let titleTopics = fields[indexPath.row].value as? UDTextItem {
            if usedesk != nil {
                var title = usedesk!.model.stringFor("TopicTitle")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = titleTopics.text
                var attributedTextString: NSMutableAttributedString? = nil
                if usedesk!.callbackSettings.isRequiredTopic {
                    attributedTitleString = NSMutableAttributedString()
                    attributedTitleString!.append(NSAttributedString(string: usedesk!.callbackSettings.titleTopics, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                    attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                } else {
                    title = usedesk!.callbackSettings.titleTopics
                }
                if !titleTopics.isValid {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.model.stringFor("MandatoryField")
                    attributedTitleString = nil
                }
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: titleTopics.isValid, isNeedSelectImage: true, isUserInteractionEnabled: false, isLimitLengthText: false)
            }
        }
        return cell
    }
    
    func createCustomFieldCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if var fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
            if usedesk != nil {
                var isValid = true
                if fieldItem.field.isRequired {
                    isValid = fieldItem.field.text != ""
                }
                if !fieldItem.isChanged {
                    isValid = true
                }
                var title = usedesk!.model.stringFor("CustomField")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = fieldItem.field.text
                var attributedTextString: NSMutableAttributedString? = nil
       
                if fieldItem.field.isRequired {
                    attributedTitleString = NSMutableAttributedString()
                    attributedTitleString!.append(NSAttributedString(string: fieldItem.field.title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                    attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                    title = ""
                } else {
                    title = fieldItem.field.title
                }
                
                if indexPath == selectedIndexPath {
                    fieldItem.isChanged = true
                    fields[indexPath.row].value = fieldItem
                } else {
                    if !isValid {
                        attributedTextString = attributedTitleString
                        text = title
                        title = usedesk!.model.stringFor("MandatoryField")
                        attributedTitleString = nil
                    }
                }
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: isValid, isLimitLengthText: false)
            }
        }
        cell.delegate = self
        if indexPath == selectedIndexPath {
            cell.setSelectedAnimate()
        } else {
            cell.setNotSelectedAnimate()
        }
        return cell
    }
    
    func createMessageCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if let message = fields[indexPath.row].value as? UDTextItem {
            if usedesk != nil {
                let isValid = message.isValid// message.text == "" && indexPath != selectedIndexPath ? false : true
                var title = usedesk!.model.stringFor("Message")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = message.text
                var attributedTextString: NSMutableAttributedString? = nil
       
                attributedTitleString = NSMutableAttributedString()
                attributedTitleString!.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                
                if !isValid {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.model.stringFor("MandatoryField")
                    attributedTitleString = nil
                }
                
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: isValid, isLimitLengthText: false)
            }
        }
        cell.delegate = self
        if indexPath == selectedIndexPath {
            cell.setSelectedAnimate()
        } else {
            cell.setNotSelectedAnimate()
        }
        return cell
    }
    
    func setSelectedCell(indexPath: IndexPath, isNeedFocusedTextView: Bool = true) {
        if fields[selectedIndexPath!.row].type == .message {
            keyboardTopView.alpha = 1
            UIView.animate(withDuration: 0.4) {
                self.keyboardTopViewBC.constant = self.keyboardHeight
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.4) {
                self.keyboardTopViewBC.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.keyboardTopView.alpha = 0
            }
        }
        if let cell = tableView.cellForRow(at: indexPath) as? UDTextAnimateTableViewCell {
            if !cell.isValid && cell.textAttributed != nil {
                cell.isValid = true
                cell.titleAttributed = cell.textAttributed
                cell.defaultAttributedTitle = cell.textAttributed
                if var contactItem = fields[indexPath.row].value as? UDContactItem {
                    contactItem.isValid = true
                    fields[indexPath.row].value = contactItem
                } else if var textItem = fields[indexPath.row].value as? UDTextItem {
                    textItem.isValid = true
                    cell.isValid = true
                    fields[indexPath.row].value = textItem
                } else if let fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
                    fieldItem.field.isValid = true
                    fields[indexPath.row].value = fieldItem
                }
            }
            if fields[indexPath.row].type == .custom {
                if var fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
                    fieldItem.isChanged = true
                    fields[indexPath.row].value = fieldItem
                }
            }
            cell.setSelectedAnimate(isNeedFocusedTextView: isNeedFocusedTextView)
        }
    }
}

// MARK: - UITableViewDelegate
extension UDOfflineForm: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fields.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch fields[indexPath.row].type {
        case .name:
            return createNameCell(indexPath: indexPath)
        case .email:
            return createEmailCell(indexPath: indexPath)
        case .selectTopic:
            return createSelectTopicCell(indexPath: indexPath)
        case .custom:
            return createCustomFieldCell(indexPath: indexPath)
        case .message:
            return createMessageCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if fields[indexPath.row].type == .selectTopic {
            let offlineFormTopicsSelectVC = UDOfflineFormTopicsSelect()
            offlineFormTopicsSelectVC.usedesk = usedesk
            offlineFormTopicsSelectVC.topics = usedesk?.callbackSettings.checkedTopics ?? []
            if selectedTopicIndex != nil {
                offlineFormTopicsSelectVC.selectedIndexPath = IndexPath(row: selectedTopicIndex!, section: 0)
            }
            offlineFormTopicsSelectVC.delegate = self
            selectedIndexPath = nil
            self.navigationController?.pushViewController(offlineFormTopicsSelectVC, animated: true)
            tableView.reloadData()
        } else if selectedIndexPath != indexPath {
            if selectedIndexPath != nil {
                if let cellDidNotSelect = tableView.cellForRow(at: selectedIndexPath!) as? UDTextAnimateTableViewCell {
                    cellDidNotSelect.setNotSelectedAnimate()
                }
            }
            selectedIndexPath = indexPath
            setSelectedCell(indexPath: selectedIndexPath!)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension UDOfflineForm: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == attachCollectionView {
            return assetsGallery.count + 1
        } else {
            return 1
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
            if let file = selectedFile {
                if file.content.isEmpty {
                    cell.setingCell(type: nil, index: indexPath.row)
                    cell.showLoader()
                } else {
                    if file.sourceType == .UIImage || file.sourceType == .PHAsset {
                        if file.type == .video {
                            if let previewImage = file.preview  {
                                cell.setingCell(image: previewImage, type: .video, videoDuration: file.duration, index: indexPath.row)
                            }
                        } else {
                            if let image = file.image {
                                cell.setingCell(image: image, type: .image, index: indexPath.row)
                            }
                        }
                    } else if file.sourceType == .URL {
                        cell.setingCell(type: .file, nameFile: file.name, index: indexPath.row)
                    }
                }
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
            let countAttachedFile = selectedFile != nil ? 1 : 0
            if indexPath.row == 0 {
                if (countAttachedFile + selectedAssets.count < 1) {
                    checkAccessCameraAndOpenCamera()
                } else {
                    showAlertMaxCountAttach()
                }
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as! UDAttachSmallCollectionViewCell
                if (countAttachedFile + selectedAssets.count < 1) || cell.isActive {
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

// MARK: - UDOfflineFormTopicsSelectDelegate
extension UDOfflineForm: UDOfflineFormTopicsSelectDelegate {
    func selectedTopic(indexTopic: Int?) {
        if var textItemTopic = fields[indexFieldsForType(.selectTopic)].value as? UDTextItem {
            if usedesk != nil && indexTopic != nil {
                if usedesk!.callbackSettings.checkedTopics.count > indexTopic! {
                    textItemTopic.text = usedesk!.callbackSettings.checkedTopics[indexTopic!].text
                }
            } else {
                textItemTopic.text = ""
            }
            textItemTopic.isValid = true
            fields[indexFieldsForType(.selectTopic)].value = textItemTopic
            tableView.reloadData()
        }
        selectedTopicIndex = indexTopic
    }
}

// MARK: - ChangeabelTextCellDelegate
extension UDOfflineForm: ChangeabelTextCellDelegate {
    func newValue(indexPath: IndexPath, value: String, isValid: Bool, positionCursorY: CGFloat) {
        textViewYPositionCursor = positionCursorY
        switch fields[indexPath.row].type {
        case .name, .message:
            if fields[indexPath.row].value is UDTextItem {
                if fields[indexPath.row].type == .message {
                    fields[indexPath.row].value = UDTextItem(text: value, isValid: !value.isEmpty)
                } else {
                    fields[indexPath.row].value = UDTextItem(text: value, isValid: isValid)
                }
            }
            if fields[indexPath.row].type == .message {
                value.count > 0 ? activateSendMessageButton() : deactivateSendMessageButton()
            }
        case .custom:
            if let fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
                fieldItem.field.text = value
                fieldItem.field.isValid = fieldItem.field.isRequired && fieldItem.field.text == "" ? false : true
                fields[indexPath.row].value = fieldItem
            }
        case .email:
            if fields[indexPath.row].value is UDContactItem {
                fields[indexPath.row].value = UDContactItem(contact: value, isValid: isValid)
            }
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        setHeightTables()
    }
    
    func tapingTextView(indexPath: IndexPath, position: CGFloat) {
        guard selectedIndexPath != indexPath else {return}
        if let cell = tableView.cellForRow(at: indexPath) as? UDTextAnimateTableViewCell {
            if selectedIndexPath != nil {
                if let cellDidNotSelect = tableView.cellForRow(at: selectedIndexPath!) as? UDTextAnimateTableViewCell {
                    if let textItem = fields[selectedIndexPath!.row].value as? UDTextItem {
                        cellDidNotSelect.isValid = textItem.isValid
                    }
                    cellDidNotSelect.setNotSelectedAnimate()
                }
            }
            selectedIndexPath = indexPath
            setSelectedCell(indexPath: selectedIndexPath!, isNeedFocusedTextView: false)
            let textFieldRealYPosition = position + cell.frame.origin.y + tableView.frame.origin.y - scrollView.contentOffset.y
            if textFieldRealYPosition > bottomOffset {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y = (textFieldRealYPosition + self.scrollView.contentOffset.y) - self.bottomOffset
                }
            }
        }
    }

    func endWrite(indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            if let cellDidNotSelect = tableView.cellForRow(at: selectedIndexPath!) as? UDTextAnimateTableViewCell {
                cellDidNotSelect.setNotSelectedAnimate()
            }
            selectedIndexPath = nil
        }
    }
}

// MARK: - DialogflowVCDelegate
extension UDOfflineForm: DialogflowVCDelegate {
    func close() {
        if isFromBase {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
@available(iOS 14, *)
extension UDOfflineForm: PHPickerViewControllerDelegate {
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
            setSelectedFile(with: assetsSort[index])
            if index == assetsSort.count - 1 {
                closeAttachView()
                showAttachedCollection()
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension UDOfflineForm: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            setSelectedFile(with: urls[0])
        }
        closeAttachView()
        showAttachedCollection()
    }
}

// MARK: - AttachCollectionLayoutDelegate
extension UDOfflineForm: UDAttachSmallCollectionLayoutDelegate {
    func sizeCell() -> CGSize {
        return isSelectAttachment ? CGSize(width: 100, height: 146) : CGSize(width: 85, height: 85)
    }
}

// MARK: - UDAttachCVCellDelegate
extension UDOfflineForm: UDAttachCVCellDelegate {
    func deleteFile(index: Int) {
        selectedFile = nil
        attachedCollectionView.reloadData()
        closeAttachedCollection()
    }
}

// MARK: - Structures
enum UDNameFields {
    case name
    case email
    case selectTopic
    case custom
    case message
}
struct UDInfoItem {
    var type: UDNameFields = .name
    var value: Any!
    
    init(type: UDNameFields, value: Any) {
        self.type = type
        self.value = value
    }
}
struct UDTextItem {
    var isValid = true
    var text = ""
    
    init(text: String, isValid: Bool = true) {
        self.text = text
        self.isValid = isValid
    }
}
struct UDContactItem {
    var isValid = true
    var contact = ""
    
    init(contact: String, isValid: Bool = true) {
        self.contact = contact
        self.isValid = isValid
    }
}
struct UDCustomFieldItem {
    var isValid = true
    var isChanged = false
    var field: UDCallbackCustomField!
    
    init(field: UDCallbackCustomField, isValid: Bool = true) {
        self.field = field
        self.isValid = isValid
    }
}
