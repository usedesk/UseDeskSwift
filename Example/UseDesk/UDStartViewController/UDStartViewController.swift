//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift
import IQKeyboardManagerSwift

class UDStartViewController: UIViewController, UITextFieldDelegate, TabBarControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var companyIdTextField: UITextField!
    @IBOutlet weak var chanelIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var portTextField: UITextField!
    @IBOutlet weak var knowledgeBaseIDTextField: UITextField!
    @IBOutlet weak var urlBaseTextField: UITextField!
    @IBOutlet weak var apiTokenTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameChatTextField: UITextField!
    @IBOutlet weak var avatarUrlDataTextField: UITextField!
    @IBOutlet weak var avatarUrlTextField: UITextField!
    @IBOutlet weak var firstMessageTextField: UITextField!
    @IBOutlet weak var countMessagesOnInitTextField: UITextField!
    @IBOutlet weak var operatorNameTextField: UITextField!
    @IBOutlet weak var urlToSendFileTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var additionalIdTextField: UITextField!
    @IBOutlet weak var localeIdTextField: UITextField!
    @IBOutlet weak var sectionIdTextField: UITextField!
    @IBOutlet weak var categoryIdTextField: UITextField!
    @IBOutlet weak var articleIdTextField: UITextField!
    @IBOutlet weak var isOnlyKnowledgeBaseSwitch: UISwitch!
    @IBOutlet weak var isReturnParentSwitch: UISwitch!
    @IBOutlet weak var isTabBarSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var idField1: UITextField!
    @IBOutlet weak var value1: UITextField!
    @IBOutlet weak var idField2: UITextField!
    @IBOutlet weak var value2: UITextField!
    @IBOutlet weak var idField3: UITextField!
    @IBOutlet weak var value3: UITextField!
    
    @IBOutlet weak var idFieldNested1: UITextField!
    @IBOutlet weak var valueNested1: UITextField!
    @IBOutlet weak var idFieldNested2: UITextField!
    @IBOutlet weak var valueNested2: UITextField!
    @IBOutlet weak var idFieldNested3: UITextField!
    @IBOutlet weak var valueNested3: UITextField!
    
    var collection: UDBaseCollection? = nil
    var usedesk = UseDeskSDK()
    var isOpenVCWithTabBar = false
    var isCanStartSDK = true
    let tabBarVC = TabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = true
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.barStyle = .black

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()

            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .red
            appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18.0),
                                              .foregroundColor: UIColor.white]

            // Customizing our navigation bar
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.barTintColor = .red
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.barTintColor = .red
        }
        
        title = "UseDesk SDK"
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
        
        var versionNumber = ""
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = "v. " + appVersion
        }
        if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionNumber += " (\(appBuild))"
        }
        versionLabel.text = versionNumber
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startChatButton(_ sender: Any) {
        guard isCanStartSDK else {
            return
            
        }
        isCanStartSDK = false
        usedesk.presentationCompletionBlock = { [weak self] in
            self?.isCanStartSDK = true
        }
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

        usedesk.presentationCompletionBlock = {
            print("close SDK")
        }
    }
    
    func startSDK(dataAvatar: Data? = nil) {
        usedesk.start(withCompanyID: companyIdTextField.text ?? "", chanelId: chanelIdTextField.text ?? "", url: urlTextField.text ?? "", port: portTextField.text!, urlAPI: urlBaseTextField.text, api_token: apiTokenTextField.text ?? "", urlToSendFile: urlToSendFileTextField.text ?? "", knowledgeBaseID: knowledgeBaseIDTextField.text ?? "", knowledgeBaseSectionId: NSNumber(value: Int(sectionIdTextField.text ?? "") ?? 0), knowledgeBaseCategoryId: NSNumber(value: Int(categoryIdTextField.text ?? "") ?? 0), knowledgeBaseArticleId: NSNumber(value: Int(articleIdTextField.text ?? "") ?? 0), isReturnToParentFromKnowledgeBase: isReturnParentSwitch.isOn, name: nameTextField.text, email: emailTextField.text ?? "", phone: phoneTextField.text, avatar: dataAvatar, avatarUrl: URL(string: avatarUrlTextField.text ?? ""), token: tokenTextField.text, additional_id: additionalIdTextField.text, note: noteTextField.text, additionalFields: additionalFields(), additionalNestedFields: additionalNestedFields(), nameOperator: operatorNameTextField.text, nameChat: nameChatTextField.text ?? "", firstMessage: firstMessageTextField.text, countMessagesOnInit: NSNumber(value: Int(countMessagesOnInitTextField.text ?? "") ?? 20), localeIdentifier: localeIdTextField.text, isPresentDefaultControllers: !isTabBarSwitch.isOn, presentIn: self, connectionStatus: { success, feedbackStatus, token in
            if self.isTabBarSwitch.isOn && success {
                let chatVC = self.usedesk.chatViewController() ?? UIViewController()
                let baseNС = self.usedesk.baseNavigationController() ?? UINavigationController()
                let secondVC = SecondViewController()
                secondVC.title = "Second"
                chatVC.title = "Chat"
                baseNС.title = "Base"
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
        }, errorStatus: { [weak self] _, error in
            self?.showError(error: error)
            self?.isCanStartSDK = true
        })
    }
    
    func startOnlyKnowledgeBase() {
        usedesk.startKnowledgeBase(urlAPI: urlBaseTextField.text, api_token: apiTokenTextField.text ?? "", knowledgeBaseID: knowledgeBaseIDTextField.text ?? "", knowledgeBaseSectionId: NSNumber(value: Int(sectionIdTextField.text ?? "") ?? 0), knowledgeBaseCategoryId: NSNumber(value: Int(categoryIdTextField.text ?? "") ?? 0), knowledgeBaseArticleId: NSNumber(value: Int(articleIdTextField.text ?? "") ?? 0), isReturnToParentFromKnowledgeBase: isReturnParentSwitch.isOn, name: nameTextField.text ?? "", email: emailTextField.text ?? "", phone: phoneTextField.text, localeIdentifier: localeIdTextField.text, isPresentDefaultControllers: !isTabBarSwitch.isOn, presentIn: self, connectionStatus: { success in
            if self.isTabBarSwitch.isOn && success {
                let chatVC = self.usedesk.baseNavigationController() ?? UINavigationController()
                let secondVC = SecondViewController()
                secondVC.title = "Second"
                chatVC.title = "Chat"
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
        }, errorStatus: { [weak self] _, error in
            self?.showError(error: error)
            self?.isCanStartSDK = true
        })
    }
    
    func showError(error: String?) {
        let alert = UIAlertController(title: "Error", message: error ?? "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in}
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func close() {
        isCanStartSDK = true
    }
}

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
}

protocol TabBarControllerDelegate: AnyObject {
    func close()
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    weak var delegateClose: TabBarControllerDelegate?
    
    override func viewDidLoad() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close TabBar", style: .plain, target: self, action: #selector(self.actionClose))
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationController?.isNavigationBarHidden = item.title == "Second" ? false : true
    }
    
    @objc func actionClose() {
        delegateClose?.close()
        self.navigationController?.popViewController(animated: true)
    }
}
