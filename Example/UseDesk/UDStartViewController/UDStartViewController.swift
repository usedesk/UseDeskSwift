//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift
import IQKeyboardManagerSwift

class UDStartViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var companyIdTextField: UITextView!
    @IBOutlet weak var chanelIdTextField: UITextView!
    @IBOutlet var emailTextField: UITextView!
    @IBOutlet var urlTextField: UITextView!
    @IBOutlet var portTextField: UITextView!
    @IBOutlet weak var knowledgeBaseIDTextField: UITextView!
    @IBOutlet weak var urlBaseTextField: UITextView!
    @IBOutlet weak var apiTokenTextField: UITextView!
    @IBOutlet weak var nameTextField: UITextView!
    @IBOutlet weak var phoneTextField: UITextView!
    @IBOutlet weak var nameChatTextField: UITextView!
    @IBOutlet weak var avatarUrlDataTextField: UITextView!
    @IBOutlet weak var avatarUrlTextField: UITextView!
    @IBOutlet weak var firstMessageTextField: UITextView!
    @IBOutlet weak var countMessagesOnInitTextField: UITextView!
    @IBOutlet weak var operatorNameTextField: UITextView!
    @IBOutlet weak var urlToSendFileTextField: UITextView!
    @IBOutlet weak var noteTextField: UITextView!
    @IBOutlet weak var tokenTextField: UITextView!
    @IBOutlet weak var additionalIdTextField: UITextView!
    @IBOutlet weak var localeIdTextField: UITextView!
    @IBOutlet weak var sectionIdTextField: UITextView!
    @IBOutlet weak var categoryIdTextField: UITextView!
    @IBOutlet weak var articleIdTextField: UITextView!
    @IBOutlet weak var isOnlyKnowledgeBaseSwitch: UISwitch!
    @IBOutlet weak var isReturnParentSwitch: UISwitch!
    @IBOutlet weak var isTabBarSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var footerBarView: UIView!

    @IBOutlet weak var idField1: UITextView!
    @IBOutlet weak var value1: UITextView!
    @IBOutlet weak var idField2: UITextView!
    @IBOutlet weak var value2: UITextView!
    @IBOutlet weak var idField3: UITextView!
    @IBOutlet weak var value3: UITextView!

    @IBOutlet weak var idFieldNested1: UITextView!
    @IBOutlet weak var valueNested1: UITextView!
    @IBOutlet weak var idFieldNested2: UITextView!
    @IBOutlet weak var valueNested2: UITextView!
    @IBOutlet weak var idFieldNested3: UITextView!
    @IBOutlet weak var valueNested3: UITextView!

    var collection: UDBaseCollection? = nil
    var usedesk = UseDeskSDK()
    var isOpenVCWithTabBar = false
    var isCanStartSDK = true
    let tabBarVC = TabBarController()
    weak var activeTextView: UITextView?
    var keyboardHeightInView: CGFloat = 0

    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        startButton.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: startButton.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: startButton.centerYAnchor)
        ])
        return indicator
    }()
    
    func applyDefaultValues() {
        companyIdTextField.text = ""
        chanelIdTextField.text = ""
        urlTextField.text = ""
        portTextField.text = ""
        urlBaseTextField.text = ""
        apiTokenTextField.text = ""
        urlToSendFileTextField.text = ""
        knowledgeBaseIDTextField.text = ""
        sectionIdTextField.text = ""
        categoryIdTextField.text = ""
        articleIdTextField.text = ""
        isReturnParentSwitch.isOn = true
        nameTextField.text = ""
        emailTextField.text = ""
        phoneTextField.text = ""
        avatarUrlDataTextField.text = ""
        avatarUrlTextField.text = ""
        nameChatTextField.text = ""
        firstMessageTextField.text = ""
        countMessagesOnInitTextField.text = String(20)
        operatorNameTextField.text = ""
        noteTextField.text = ""
        tokenTextField.text = ""
        additionalIdTextField.text = ""
        localeIdTextField.text = ""
    }

    @IBAction func startChatButton(_ sender: Any) {
        guard isCanStartSDK else {
            return
        }
        IQKeyboardManager.shared.enable = false
        isCanStartSDK = false
        setLoading(true)
        if isTabBarSwitch.isOn {
            usedesk.configurationStyle = ConfigurationStyle(baseStyle: BaseStyle(windowBottomMargin: 48 + view.safeAreaInsets.bottom))
        }
        isOpenVCWithTabBar = false
        usedesk.connectBlock = { bool in
            print("Connect = ", bool)
        }
        usedesk.releaseChat()
        usedesk.newMessageWithGUIBlock = { message in
            print("New message")
        }

        if isOnlyKnowledgeBaseSwitch.isOn {
            startOnlyKnowledgeBase()
        } else {
            if let pathAvatar = avatarUrlDataTextField.text {
                if let urlAvatar = URL(string: pathAvatar) {
                    URLSession.shared.dataTask(with: urlAvatar, completionHandler: { [weak self] data, _, _ in
                        DispatchQueue.main.async {
                            self?.startSDK(dataAvatar: data)
                        }
                    }).resume()
                } else {
                    startSDK()
                }
            } else {
                startSDK()
            }
        }

        usedesk.presentationCompletionBlock = { [weak self] in
            print("close SDK")
            self?.isCanStartSDK = true
            self?.setLoading(false)
            IQKeyboardManager.shared.enable = true
        }
    }

    func startSDK(dataAvatar: Data? = nil, presentIn presentVC: UIViewController? = nil) {
        let targetVC = presentVC ?? self
        let isPresentDefault = presentVC == nil ? !isTabBarSwitch.isOn : true
        usedesk.start(
            withCompanyID: companyIdTextField.text ?? "",
            chanelId: chanelIdTextField.text ?? "",
            url: urlTextField.text ?? "",
            port: portTextField.text!,
            urlAPI:  urlBaseTextField.text,
            api_token: apiTokenTextField.text ?? "",
            urlToSendFile: urlToSendFileTextField.text ?? "",
            knowledgeBaseID: knowledgeBaseIDTextField.text ?? "",
            knowledgeBaseSectionId: NSNumber(value: Int(sectionIdTextField.text ?? "") ?? 0),
            knowledgeBaseCategoryId: NSNumber(value: Int(categoryIdTextField.text ?? "") ?? 0),
            knowledgeBaseArticleId: NSNumber(value: Int(articleIdTextField.text ?? "") ?? 0),
            isReturnToParentFromKnowledgeBase: isReturnParentSwitch.isOn,
            name: nameTextField.text,
            email: emailTextField.text ?? "",
            phone: phoneTextField.text,
            avatar: dataAvatar,
            avatarUrl: URL(string: avatarUrlTextField.text ?? ""),
            token: tokenTextField.text,
            additional_id: additionalIdTextField.text,
            note: noteTextField.text,
            additionalFields: additionalFields(),
            additionalNestedFields: additionalNestedFields(),
            nameOperator: operatorNameTextField.text,
            nameChat: nameChatTextField.text ?? "",
            firstMessage: firstMessageTextField.text,
            countMessagesOnInit: NSNumber(value: Int(countMessagesOnInitTextField.text ?? "") ?? 20),
            localeIdentifier: localeIdTextField.text,
            isPresentDefaultControllers: isPresentDefault,
            presentIn: targetVC,
            connectionStatus: { success, feedbackStatus, token in
            if self.isTabBarSwitch.isOn && success && presentVC == nil {
                let chatVC = self.usedesk.chatViewController() ?? UIViewController()
                let baseNС = self.usedesk.baseNavigationController() ?? UINavigationController()
                let secondVC = SecondViewController()
                secondVC.title = "Close"
                secondVC.tabBarItem.image = UIImage(systemName: "xmark.circle")
                chatVC.title = "Chat"
                chatVC.tabBarItem.image = UIImage(systemName: "message.fill")
                baseNС.title = "Base"
                baseNС.tabBarItem.image = UIImage(systemName: "book.fill")
                self.tabBarVC.viewControllers = nil
                self.tabBarVC.delegateClose = self
                self.tabBarVC.setViewControllers([(self.knowledgeBaseIDTextField.text ?? "").count > 0 ? baseNС : chatVC, secondVC], animated: true)
                if !self.isOpenVCWithTabBar {
                    self.isOpenVCWithTabBar = true
                    self.navigationController?.isNavigationBarHidden = true
                    self.navigationController?.pushViewController(self.tabBarVC, animated: true)
                }
            }
            self.isCanStartSDK = true
            self.setLoading(false)
            let key = "usedeskClientToken\(self.emailTextField.text ?? "")\(self.phoneTextField.text ?? "")\(self.nameTextField.text ?? "")\(self.chanelIdTextField.text ?? "")"
            if let token = UserDefaults.standard.string(forKey: key) {
                self.tokenTextField.text = token
            }
        }, errorStatus: { [weak self] _, error in
            IQKeyboardManager.shared.enable = true
            self?.showError(error: error)
            self?.isCanStartSDK = true
            self?.setLoading(false)
        })
    }

    func startOnlyKnowledgeBase() {
        usedesk.startKnowledgeBase(
            urlAPI: urlBaseTextField.text,
            api_token: apiTokenTextField.text ?? "",
            knowledgeBaseID: knowledgeBaseIDTextField.text ?? "",
            knowledgeBaseSectionId: NSNumber(value: Int(sectionIdTextField.text ?? "") ?? 0),
            knowledgeBaseCategoryId: NSNumber(value: Int(categoryIdTextField.text ?? "") ?? 0),
            knowledgeBaseArticleId: NSNumber(value: Int(articleIdTextField.text ?? "") ?? 0),
            isReturnToParentFromKnowledgeBase: isReturnParentSwitch.isOn,
            name: nameTextField.text ?? "",
            email: emailTextField.text ?? "",
            phone: phoneTextField.text,
            localeIdentifier: localeIdTextField.text,
            isPresentDefaultControllers: !isTabBarSwitch.isOn,
            presentIn: self,
            connectionStatus: { success in

            if self.isTabBarSwitch.isOn && success {
                let chatVC = self.usedesk.baseNavigationController() ?? UINavigationController()
                let secondVC = SecondViewController()
                secondVC.title = "Close"
                secondVC.tabBarItem.image = UIImage(systemName: "xmark.circle")
                chatVC.title = "Chat"
                chatVC.tabBarItem.image = UIImage(systemName: "book.fill")
                self.tabBarVC.viewControllers = nil
                self.tabBarVC.delegateClose = self
                self.tabBarVC.setViewControllers([chatVC, secondVC], animated: true)
                if !self.isOpenVCWithTabBar {
                    self.isOpenVCWithTabBar = true
                    self.navigationController?.isNavigationBarHidden = true
                    self.navigationController?.pushViewController(self.tabBarVC, animated: true)
                }
            }
            self.isCanStartSDK = true
            self.setLoading(false)
        }, errorStatus: { [weak self] _, error in
            IQKeyboardManager.shared.enable = true
            self?.showError(error: error)
            self?.isCanStartSDK = true
            self?.setLoading(false)
        })
    }

    func additionalFields() -> [Int : String] {
        var fields: [Int : String] = [:]
        if let id = idField1.text {
            if let id = Int(id) {
                if id > 0 {
                    fields[id] = value1.text ?? ""
                }
            }
        }
        if let id = idField2.text {
            if let id = Int(id) {
                if id > 0 {
                    if fields[id] == nil {
                        fields[id] = value2.text ?? ""
                    }
                }
            }
        }
        if let id = idField3.text {
            if let id = Int(id) {
                if id > 0 {
                    if fields[id] == nil {
                        fields[id] = value3.text ?? ""
                    }
                }
            }
        }
        return fields
    }

    func additionalNestedFields() -> [[Int : String]] {
        var fields: [Int : String] = [:]
        if let id = idFieldNested1.text {
            if let id = Int(id) {
                if id > 0 {
                    fields[id] = valueNested1.text ?? ""
                }
            }
        }
        if let id = idFieldNested2.text {
            if let id = Int(id) {
                if id > 0 {
                    if fields[id] == nil {
                        fields[id] = valueNested2.text ?? ""
                    }
                }
            }
        }
        if let id = idFieldNested3.text {
            if let id = Int(id) {
                if id > 0 {
                    if fields[id] == nil {
                        fields[id] = valueNested3.text ?? ""
                    }
                }
            }
        }
        return [fields]
    }

    func showError(error: String?) {
        let alert = UIAlertController(title: "Error", message: error ?? "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in}
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
}

protocol TabBarControllerDelegate: AnyObject {
    func close()
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    weak var delegateClose: TabBarControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Close TabBar"
        configuration.image = UIImage(systemName: "xmark.circle.fill")
        configuration.imagePadding = 6

        if #available(iOS 26.0, *) {
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        } else {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
            navigationController?.navigationBar.standardAppearance = navAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navAppearance

            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            tabBar.standardAppearance = tabAppearance
            tabBar.scrollEdgeAppearance = tabAppearance

            configuration.contentInsets = .zero
            configuration.baseForegroundColor = .systemRed
        }

        let closeButton = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
            self?.actionClose()
        })
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationController?.isNavigationBarHidden = item.title == "Close" ? false : true
    }

    @objc func actionClose() {
        delegateClose?.close()
        self.navigationController?.popViewController(animated: true)
    }
}
