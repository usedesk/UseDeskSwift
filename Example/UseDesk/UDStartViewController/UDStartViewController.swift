//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift


class UDStartViewController: UIViewController, UITextFieldDelegate {
    
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
    @IBOutlet weak var firstMessageTextField: UITextField!
    @IBOutlet weak var operatorNameTextField: UITextField!
    @IBOutlet weak var urlToSendFileTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var localeIdTextField: UITextField!
    @IBOutlet weak var lastViewBC: NSLayoutConstraint!
    @IBOutlet weak var isNeedChatSwitch: UISwitch!
    @IBOutlet weak var isNeedReviewSwitch: UISwitch!
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationController?.navigationBar.barStyle = .black
        
        title = "UseDesk SDK"
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.4) {
                self.lastViewBC.constant = keyboardSize.height + 70
                self.loadViewIfNeeded()
            }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.lastViewBC.constant = 70
            self.loadViewIfNeeded()
        }
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
        var knowledgeBaseID = ""
        var nameChat = ""
        if knowledgeBaseIDTextField.text != nil {
            if knowledgeBaseIDTextField.text! != "" {
                knowledgeBaseID = knowledgeBaseIDTextField.text!
            }
        }
        if nameChatTextField.text != nil {
            if nameChatTextField.text! != "" {
                nameChat = nameChatTextField.text!
            }
        }
        
        usedesk.configurationStyle = ConfigurationStyle(baseStyle: BaseStyle(isNeedChat: isNeedChatSwitch.isOn), baseArticleStyle: BaseArticleStyle(isNeedReview: isNeedReviewSwitch.isOn))

        usedesk.start(withCompanyID: companyIdTextField.text!, chanelId: chanelIdTextField.text != nil ? chanelIdTextField.text! : "", urlAPI: urlBaseTextField.text != nil ? urlBaseTextField.text! : nil, knowledgeBaseID: knowledgeBaseID, api_token: apiTokenTextField.text!, email: emailTextField.text!, phone: phoneTextField.text != nil ? phoneTextField.text! : nil, url: urlTextField.text!, urlToSendFile: urlToSendFileTextField.text!, port: portTextField.text!, name: nameTextField.text != nil ? nameTextField.text! : nil, operatorName: operatorNameTextField.text != nil ? operatorNameTextField.text! : nil, nameChat: nameChat, firstMessage: firstMessageTextField.text != nil ? firstMessageTextField.text : nil, note: noteTextField.text != nil ? noteTextField.text : nil, additionalFields: additionalFields(), additionalNestedFields: additionalNestedFields(), token: tokenTextField.text != nil ? tokenTextField.text : nil, localeIdentifier: localeIdTextField.text != nil ? localeIdTextField.text : nil, presentIn: self, connectionStatus: { success, feedbackStatus, token in
            
        }, errorStatus: {  _, _ in})
    }
}
