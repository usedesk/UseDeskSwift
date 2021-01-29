//
//  UDOfflineForm.swift

import Foundation
import MBProgressHUD
import Alamofire

class UDOfflineForm: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
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
    weak var usedesk: UseDeskSDK?
    
    private var configurationStyle = ConfigurationStyle()
    private var selectedIndexPath: IndexPath? = nil
    private var fields: [InfoItem] = []
    private var textViewYPositionCursor: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 336
    private var isShowKeyboard = false
    private var isSelectingCell = false
    private var isFirstOpen = true
    private var previousOrientation: Orientation = .portrait
    
    convenience init() {
        let nibName: String = "UDOfflineForm"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        scrollView.delegate = self
        sendLoader.alpha = 0
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        title = usedesk?.nameChat ?? "Чат"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: configurationStyle.navigationBarStyle.backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        let feedbackFormStyle = configurationStyle.feedbackFormStyle
        tableView.register(UINib(nibName: "UDTextAnimateTableViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDTextAnimateTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        textLabel.textColor = feedbackFormStyle.textColor
        textLabel.font = feedbackFormStyle.textFont
        textLabel.text = "Все операторы заняты. Оставьте сообщение, мы ответим вам на почту в течение 1 рабочего дня."
        sendMessageButton.backgroundColor = feedbackFormStyle.buttonColorDisabled
        sendMessageButton.tintColor = feedbackFormStyle.buttonTextColor
        sendMessageButton.titleLabel?.font = feedbackFormStyle.buttonFont
        sendMessageButton.isEnabled = false
        sendMessageButton.layer.masksToBounds = true
        sendMessageButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        sendMessageButton.setTitle("Отправить", for: .normal)
        
        sendedViewBC.constant = -400
        sendedCornerRadiusView.layer.cornerRadius = 13
        sendedView.backgroundColor = .clear
        sendedView.layer.masksToBounds = false
        sendedView.layer.shadowColor = UIColor.black.cgColor
        sendedView.layer.shadowOpacity = 0.6
        sendedView.layer.shadowOffset = CGSize.zero
        sendedView.layer.shadowRadius = 20.0

        sendedImage.image = feedbackFormStyle.sendedImage
        sendedLabel.text = "Сообщение отправлено! \n Ответим вам в течение 1 рабочего дня."
        closeButton.backgroundColor = feedbackFormStyle.buttonColor
        closeButton.tintColor = feedbackFormStyle.buttonTextColor
        closeButton.titleLabel?.font = feedbackFormStyle.buttonFont
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = feedbackFormStyle.buttonCornerRadius
        closeButton.setTitle("Закрыть", for: .normal)
        
        fields = [InfoItem(type: .name, values: [TextItem(text: usedesk?.name ?? "")]), InfoItem(type: .email, values: [ContactItem(contact: usedesk?.email ?? "")]), InfoItem(type: .message, values: [TextItem(text: "")])]
        selectedIndexPath = IndexPath(row: 2, section: 0)
        tableView.reloadData()
        setHeightTables()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isShowKeyboard {
                isShowKeyboard = true
                keyboardHeight = keyboardSize.height
                UIView.animate(withDuration: 0.4) {
                    self.scrollViewBC.constant = self.keyboardHeight
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
    
    func indexFieldsForType(_ type: NameFields) -> Int {
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
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Понятно", style: .default, handler: {_ in
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
                if let contactItem = fields[index].values[0] as? ContactItem {
                    text = contactItem.contact
                }
            } else {
                if let textItem = fields[index].values[0] as? TextItem {
                    text = textItem.text
                }
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
    
    @objc func backAction() {
        usedesk?.releaseChat()
        dismiss(animated: true)
    }
// MARK: - IB Actions
    @IBAction func sendMessage(_ sender: Any) {
        guard usedesk != nil else {return}
        sendLoader.alpha = 1
        sendLoader.startAnimating()
        sendMessageButton.setTitle("", for: .normal)
        let email = (fields[indexFieldsForType(.email)].values[0] as? ContactItem)?.contact ?? ""
        let name = (fields[indexFieldsForType(.name)].values[0] as? TextItem)?.text ?? ""
        if email.isValidEmail() && name != "" {
            self.view.endEditing(true)
            let name = (fields[indexFieldsForType(.name)].values[0] as? TextItem)?.text ?? (usedesk?.name ?? "")
            
            if let message = fields[indexFieldsForType(.message)].values[0] as? TextItem {
                usedesk!.sendOfflineForm(name: name, email: email, message: message.text) { [weak self] (result, error) in
                    guard let wSelf = self else {return}
                    if result {
                        wSelf.usedesk?.releaseChat()
                        wSelf.sendLoader.alpha = 0
                        wSelf.sendLoader.stopAnimating()
                        wSelf.sendMessageButton.setTitle("Закрыть", for: .normal)
                        wSelf.showSendedView()
                    } else {
                        wSelf.sendLoader.alpha = 0
                        wSelf.sendLoader.stopAnimating()
                        wSelf.sendMessageButton.setTitle("Закрыть", for: .normal)
                        wSelf.showAlert("Ошибка", text: "Сервер не отвечает. Проверьте соединение и попробуйте еще раз.")
                    }
                }
            }
        } else {
            selectedIndexPath = IndexPath(row: 0, section: 0)
            if !email.isValidEmail() {
                fields[indexFieldsForType(.email)].values[0] = ContactItem(contact: email, isValid: false)
                selectedIndexPath = IndexPath(row: 1, section: 0)
            }
            isSelectingCell = true
            tableView.reloadData()
            sendLoader.alpha = 0
            sendLoader.stopAnimating()
            sendMessageButton.setTitle("Отправить", for: .normal)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods Cells
    
    func setNotSelectedCellFirstTable(indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at:indexPath) as? UDTextAnimateTableViewCell {
            if indexFieldsForType(.name) == indexPath.row {
                if let nameClient = fields[indexPath.row].values[0] as? TextItem {
                    var title = "Имя"
                    var isValid = nameClient.isValid
                    if nameClient.text == "" {
                        title = "Имя - Обязательное поле"
                        fields[indexPath.row].values[0] = TextItem(text: nameClient.text, isValid: false)
                        isValid = false
                    }
                    cell.setCell(title: title, text: nameClient.text, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
                }
            }
            if indexFieldsForType(.email) == indexPath.row {
                if let emailClient = fields[indexPath.row].values[0] as? ContactItem {
                    var title = "Почта"
                    var isValid = emailClient.isValid
                    if !isValid {
                        title = "Неправильно введена почта"
                    }
                    if emailClient.contact == "" {
                        title = "Почта - Обязательное поле"
                        fields[indexPath.row].values[0] = ContactItem(contact: emailClient.contact, isValid: false)
                        isValid = false
                    }
                    cell.setCell(title: title, text: emailClient.contact, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
                }
            }
            cell.setNotSelectedAnimate()
        }
    }
    
    func createNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDTextAnimateTableViewCell", for: indexPath) as! UDTextAnimateTableViewCell
        if let nameClient = fields[indexPath.row].values[0] as? TextItem {
            var title = "Имя"
            var isValid = nameClient.isValid
            if nameClient.text == "" {
                title = "Имя - Обязательное поле"
                fields[indexPath.row].values[0] = TextItem(text: nameClient.text, isValid: false)
                isValid = false
            }
            cell.setCell(title: title, text: nameClient.text, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
        }
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
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
        if let emailClient = fields[indexPath.row].values[0] as? ContactItem {
            var title = "Почта"
            var isValid = emailClient.isValid
            if !isValid {
                title = "Неправильно введена почта"
            }
            if emailClient.contact == "" {
                title = "Почта - Обязательное поле"
                fields[indexPath.row].values[0] = ContactItem(contact: emailClient.contact, isValid: false)
                isValid = false
            }
            cell.setCell(title: title, text: emailClient.contact, indexPath: indexPath, isValid: isValid, isTitleErrorState: !isValid, isLimitLengthText: false)
        }
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
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
        if let message = fields[indexPath.row].values[0] as? TextItem {
            let title = "Сообщение"
            cell.setCell(title: title, text: message.text, indexPath: indexPath, isLimitLengthText: false)
        }
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
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
        case .message:
            return createMessageCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath != indexPath {
            isSelectingCell = true
            selectedIndexPath = indexPath
            tableView.reloadData()
        }
    }
}

// MARK: - ChangeabelTextCellDelegate
extension UDOfflineForm: ChangeabelTextCellDelegate {
    func newValue(indexPath: IndexPath, value: String, isValid: Bool, positionCursorY: CGFloat) {
        textViewYPositionCursor = positionCursorY
        switch fields[indexPath.row].type {
        case .name, .message:
            if fields[indexPath.row].values[0] is TextItem {
                fields[indexPath.row].values[0] = TextItem(text: value, isValid: isValid)
            }
            if fields[indexPath.row].type == .message {
                sendMessageButton.isEnabled = value.count > 0 ? true : false
                sendMessageButton.backgroundColor = value.count > 0 ? configurationStyle.feedbackFormStyle.buttonColor : configurationStyle.feedbackFormStyle.buttonColorDisabled
            }
        case .email:
            if fields[indexPath.row].values[0] is ContactItem {
                fields[indexPath.row].values[0] = ContactItem(contact: value, isValid: isValid)
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        setHeightTables()
    }
    
    func tapingTextView(indexPath: IndexPath, position: CGFloat) {
        if selectedIndexPath != nil {
            if selectedIndexPath != indexPath {
                setNotSelectedCellFirstTable(indexPath: selectedIndexPath!)
            }
        }
        if let cell = tableView.cellForRow(at:indexPath) as? UDTextAnimateTableViewCell {
            selectedIndexPath = indexPath
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
}
// MARK: - Structures
enum NameFields {
    case name
    case email
    case message
}
struct InfoItem {
    var type: NameFields = .name
    var values: [Any] = []
    
    init(type: NameFields, values: [Any]) {
        self.type = type
        self.values = values
    }
}
struct TextItem {
    var isValid = true
    var text = ""
    
    init(text: String, isValid: Bool = true) {
        self.text = text
        self.isValid = isValid
    }
}

struct ContactItem {
    var isValid = true
    var contact = ""
    
    init(contact: String, isValid: Bool = true) {
        self.contact = contact
        self.isValid = isValid
    }
}
