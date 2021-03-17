//
//  UDOfflineForm.swift

import Foundation
import MBProgressHUD
import Alamofire

class UDOfflineForm: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHC: NSLayoutConstraint!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var sendLoader: UIActivityIndicatorView!
    @IBOutlet weak var sendedView: UIView!
    @IBOutlet weak var sendedViewBC: NSLayoutConstraint!
    @IBOutlet weak var sendedCornerRadiusView: UIView!
    @IBOutlet weak var sendedImage: UIImageView!
    @IBOutlet weak var sendedLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var url = ""
    var isFromBase = false
    weak var usedesk: UseDeskSDK?
    
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var selectedIndexPath: IndexPath? = nil
    private var fields: [UDInfoItem] = []
    private var textViewYPositionCursor: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 336
    private var isShowKeyboard = false
    private var isSelectingCell = false
    private var isFirstOpen = true
    private var previousOrientation: Orientation = .portrait
    private var selectedTopicIndex: Int? = nil
    private var dialogflowVC : DialogflowView = DialogflowView()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !isFirstOpen else {
            isFirstOpen = false
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
        scrollView.delegate = self
        scrollView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        contentView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        sendLoader.alpha = 0
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        title = usedesk?.callbackSettings.title ?? usedesk!.stringFor("Chat")

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        let feedbackFormStyle = configurationStyle.feedbackFormStyle
        tableView.register(UINib(nibName: "UDTextAnimateTableViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDTextAnimateTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = configurationStyle.chatStyle.backgroundColor
        textLabel.textColor = feedbackFormStyle.textColor
        textLabel.font = feedbackFormStyle.textFont
        textLabel.text = usedesk?.callbackSettings.greeting ?? usedesk!.stringFor("FeedbackText")
        sendMessageButton.backgroundColor = feedbackFormStyle.buttonColorDisabled
        sendMessageButton.tintColor = feedbackFormStyle.buttonTextColor
        sendMessageButton.titleLabel?.font = feedbackFormStyle.buttonFont
        sendMessageButton.isEnabled = false
        sendMessageButton.layer.masksToBounds = true
        sendMessageButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        sendMessageButton.setTitle(usedesk!.stringFor("Send"), for: .normal)
        
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
        sendedLabel.text = usedesk!.stringFor("FeedbackSendedMessage")
        closeButton.backgroundColor = feedbackFormStyle.buttonColor
        closeButton.tintColor = feedbackFormStyle.buttonTextColor
        closeButton.titleLabel?.font = feedbackFormStyle.buttonFont
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        closeButton.setTitle(usedesk!.stringFor("Close"), for: .normal)
        
        if usedesk != nil {
            fields = [UDInfoItem(type: .name, value: UDTextItem(text: usedesk!.name)), UDInfoItem(type: .email, value: UDContactItem(contact: usedesk?.email ?? "")), UDInfoItem(type: .selectTopic, value: UDTextItem(text: ""))]
            for custom_field in usedesk!.callbackSettings.checkedCustomFields {
                fields.append(UDInfoItem(type: .custom, value: UDCustomFieldItem(field: custom_field)))
            }
            fields.append(UDInfoItem(type: .message, value: UDTextItem(text: "")))
        }
        selectedIndexPath = IndexPath(row: 2, section: 0)
        tableView.reloadData()
        setHeightTables()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isShowKeyboard {
                isShowKeyboard = true
                keyboardHeight = keyboardSize.height
                UIView.animate(withDuration: 0.4) {
                    self.scrollViewBC.constant = self.keyboardHeight
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isShowKeyboard {
            UIView.animate(withDuration: 0.4) {
                self.scrollViewBC.constant = 0
            }
            if scrollView.contentSize.height <= scrollView.frame.height {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y = 0
                }
            } else {
                let offset = keyboardHeight - 138
                UIView.animate(withDuration: 0.4) {
                    if offset > self.scrollView.contentOffset.y {
                        self.scrollView.contentOffset.y = 0
                    } else {
                        self.scrollView.contentOffset.y -= offset
                    }
                }
            }
            isShowKeyboard = false
            if !isSelectingCell {
                selectedIndexPath = nil
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            isSelectingCell = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
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
        
        let ok = UIAlertAction(title: usedesk!.stringFor("Understand"), style: .default, handler: {_ in
        })
        alert.addAction(ok)
        present(alert, animated: true)
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
        let heightNavigationBar = navigationController?.navigationBar.frame.height ?? 44
        let yPositionCursor = (textViewYPositionCursor + (selectedCellPositionY - scrollView.contentOffset.y))
        if yPositionCursor > self.view.frame.height - heightNavigationBar - keyboardHeight - 30 {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.contentOffset.y = (yPositionCursor + self.scrollView.contentOffset.y) - (self.view.frame.height - heightNavigationBar - self.keyboardHeight - 30)
            }
        }
    }
    
    func showSendedView() {
        UIView.animate(withDuration: 0.6) {
            self.sendedViewBC.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func startChat(text: String) {
        guard usedesk != nil else {
            showSendedView()
            return
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, knowledgeBaseID: usedesk!.knowledgeBaseID, api_token: usedesk!.api_token, email: usedesk!.email, phone: usedesk!.phone, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, operatorName: usedesk!.operatorName, nameChat: usedesk!.nameChat, signature: usedesk!.signature, isBeforeFeedbackForm: true, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if !success && error == "feedback_form" {
                wSelf.showSendedView()
            } else {
                if wSelf.navigationController?.visibleViewController != wSelf.dialogflowVC {
                    DispatchQueue.main.async(execute: {
                        wSelf.dialogflowVC.usedesk = wSelf.usedesk
                        wSelf.dialogflowVC.isFromBase = wSelf.isFromBase
                        wSelf.dialogflowVC.delegate = self
                        wSelf.usedesk?.navController.pushViewController(wSelf.dialogflowVC, animated: true)
                        wSelf.usedesk?.sendMessage(text)
                    })
                }
            }
        })

    }
    
    @objc func backAction() {
        if isFromBase {
            usedesk?.closeChat()
        } else {
            usedesk?.releaseChat()
        }
        dismiss(animated: true)
    }
// MARK: - IB Actions
    @IBAction func sendMessage(_ sender: Any) {
        guard usedesk != nil else {return}
        sendLoader.alpha = 1
        sendLoader.startAnimating()
        sendMessageButton.setTitle("", for: .normal)
        let email = (fields[indexFieldsForType(.email)].value as? UDContactItem)?.contact ?? ""
        let name = (fields[indexFieldsForType(.name)].value as? UDTextItem)?.text ?? (usedesk?.name ?? "")
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
            if var fieldItem = fields[index].value as? UDCustomFieldItem {
                if fieldItem.field.text != "" {
                    customFields.append(fieldItem.field)
                } else {
                    if fieldItem.field.isRequired {
                        isValidFields = false
                        fieldItem.field.isValid = false
                        fields[index].value = fieldItem
                        indexErrorFields.append(index)
                    }
                }
            }
        }
        if email.udIsValidEmail() && name != "" && isValidTopic && isValidFields {
            self.view.endEditing(true)
            if let message = fields[indexFieldsForType(.message)].value as? UDTextItem {
                usedesk!.sendOfflineForm(name: name, email: email, message: message.text, topic: topic, fields: customFields) { [weak self] (result, error) in
                    guard let wSelf = self else {return}
                    if result {
                        if wSelf.usedesk != nil {
                            if wSelf.usedesk!.callbackSettings.type == .always_and_chat {
                                var text = name + "\n" + email
                                if topic != "" {
                                    text += "\n" + topic
                                }
                                for field in customFields {
                                    print("\n" + field.title + "\n" + field.text)
                                    text += "\n" + field.title + "\n" + field.text
                                }
                                text += "\n" + message.text
                                wSelf.startChat(text: text)
                            } else {
                                wSelf.sendLoader.alpha = 0
                                wSelf.sendLoader.stopAnimating()
                                wSelf.sendMessageButton.setTitle(wSelf.usedesk!.stringFor("Close"), for: .normal)
                                wSelf.showSendedView()
                            }
                        }
                    } else {
                        wSelf.sendLoader.alpha = 0
                        wSelf.sendLoader.stopAnimating()
                        wSelf.sendMessageButton.setTitle(wSelf.usedesk!.stringFor("Close"), for: .normal)
                        wSelf.showAlert(wSelf.usedesk!.stringFor("Error"), text: wSelf.usedesk!.stringFor("ServerError"))
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
            isSelectingCell = true
            tableView.reloadData()
            sendLoader.alpha = 0
            sendLoader.stopAnimating()
            sendMessageButton.setTitle(usedesk!.stringFor("Send"), for: .normal)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        if isFromBase {
            usedesk?.closeChat()
        } else {
            usedesk?.releaseChat()
        }
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods Cells
    
//    func setNotSelectedCellFirstTable(indexPath: IndexPath) {
//        guard usedesk != nil else {return}
//        if let cell = tableView.cellForRow(at:indexPath) as? UDTextAnimateTableViewCell {
//            if indexFieldsForType(.name) == indexPath.row {
//                if let nameClient = fields[indexPath.row].value as? TextItem {
//                    var title = usedesk!.stringFor("Name")
//                    var isValid = nameClient.isValid
//                    if nameClient.text == "" {
//                        title = usedesk!.stringFor("Name") + " - " + usedesk!.stringFor("MandatoryField")
//                        fields[indexPath.row].value = TextItem(text: nameClient.text, isValid: false)
//                        isValid = false
//                    }
//                    cell.setCell(title: title, text: nameClient.text, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
//                }
//            }
//            if indexFieldsForType(.email) == indexPath.row {
//                if let emailClient = fields[indexPath.row].value as? ContactItem {
//                    var title = usedesk!.stringFor("Email")
//                    var isValid = emailClient.isValid
//                    if !isValid {
//                        title = usedesk!.stringFor("ErrorEmail")
//                    }
//                    if emailClient.contact == "" {
//                        title = usedesk!.stringFor("Email") + " - " + usedesk!.stringFor("MandatoryField")
//                        fields[indexPath.row].value = ContactItem(contact: emailClient.contact, isValid: false)
//                        isValid = false
//                    }
//                    cell.setCell(title: title, text: emailClient.contact, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
//                }
//            }
//            cell.setNotSelectedAnimate()
//        }
//    }
    
    func createNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if let nameClient = fields[indexPath.row].value as? UDTextItem {
            if usedesk != nil {
                let isValid = nameClient.text == "" && indexPath != selectedIndexPath ? false : true
                var title = usedesk!.stringFor("Name")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = nameClient.text
                var attributedTextString: NSMutableAttributedString? = nil
       
                attributedTitleString = NSMutableAttributedString()
                attributedTitleString!.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                
                if !isValid {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.stringFor("MandatoryField")
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
                var title = usedesk!.stringFor("Email")
                var attributedTitleString: NSMutableAttributedString? = nil
                var text = emailClient.contact
                var attributedTextString: NSMutableAttributedString? = nil
                
                if !isValid {
                    title = usedesk!.stringFor("ErrorEmail")
                } else {
                    attributedTitleString = NSMutableAttributedString()
                    attributedTitleString!.append(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerColor]))
                    attributedTitleString!.append(NSAttributedString(string: " *", attributes: [NSAttributedString.Key.font : usedesk!.configurationStyle.feedbackFormStyle.headerFont, NSAttributedString.Key.foregroundColor : usedesk!.configurationStyle.feedbackFormStyle.headerSelectedColor]))
                }
                if emailClient.contact == "" && indexPath != selectedIndexPath {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.stringFor("MandatoryField")
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
                var title = usedesk!.stringFor("TopicTitle")
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
                    title = usedesk!.stringFor("MandatoryField")
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
                var title = usedesk!.stringFor("CustomField")
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
                if !isValid {
                    attributedTextString = attributedTitleString
                    text = title
                    title = usedesk!.stringFor("MandatoryField")
                    attributedTitleString = nil
                }
                cell.setCell(title: title, titleAttributed: attributedTitleString, text: text, textAttributed: attributedTextString, indexPath: indexPath, isValid: isValid, isLimitLengthText: false)
                if indexPath == selectedIndexPath {
                    fieldItem.isChanged = true
                    fields[indexPath.row].value = fieldItem
                }
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
                let title = usedesk!.stringFor("Message")
                cell.setCell(title: title, text: message.text, indexPath: indexPath, isLimitLengthText: false)
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
            self.navigationController?.pushViewController(offlineFormTopicsSelectVC, animated: true)
        } else if selectedIndexPath != indexPath {
            isSelectingCell = true
            selectedIndexPath = indexPath
            tableView.reloadData()
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
                fields[indexPath.row].value = UDTextItem(text: value, isValid: isValid)
            }
            if fields[indexPath.row].type == .message {
                sendMessageButton.isEnabled = value.count > 0 ? true : false
                sendMessageButton.backgroundColor = value.count > 0 ? configurationStyle.feedbackFormStyle.buttonColor : configurationStyle.feedbackFormStyle.buttonColorDisabled
            }
        case .custom:
            if var fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
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
        if let cell = tableView.cellForRow(at:indexPath) as? UDTextAnimateTableViewCell {
            selectedIndexPath = indexPath
            if !cell.isValid && cell.teextAttributed != nil {
                cell.isValid = true
                cell.titleAttributed = cell.teextAttributed
                cell.defaultAttributedTitle = cell.teextAttributed
                if var contactItem = fields[indexPath.row].value as? UDContactItem {
                    contactItem.isValid = true
                    fields[indexPath.row].value = contactItem
                } else if var textItem = fields[indexPath.row].value as? UDTextItem {
                    textItem.isValid = true
                    fields[indexPath.row].value = textItem
                } else if var fieldItem = fields[indexPath.row].value as? UDCustomFieldItem {
                    fieldItem.field.isValid = true
                    fields[indexPath.row].value = fieldItem
                }
            }
            cell.setSelectedAnimate(isNeedFocusedTextView: false)
            let textFieldRealYPosition = position + cell.frame.origin.y + tableView.frame.origin.y - scrollView.contentOffset.y
            let heightNavigationBar = navigationController?.navigationBar.frame.height ?? 44
            if  textFieldRealYPosition > (self.view.frame.height - heightNavigationBar - keyboardHeight - 30) {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y = (textFieldRealYPosition + self.scrollView.contentOffset.y) - (self.view.frame.height - heightNavigationBar - self.keyboardHeight - 30)
                }
            }
        }
    }
    
    func endWrite() {
        selectedIndexPath = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
