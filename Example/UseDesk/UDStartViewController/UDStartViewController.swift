//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift


class UDStartViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var companyIdTextField: UITextField!
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
    @IBOutlet weak var signatureTextField: UITextField!
    @IBOutlet weak var localeIdTextField: UITextField!
    @IBOutlet weak var lastViewBC: NSLayoutConstraint!
    @IBOutlet weak var isNeedChatSwitch: UISwitch!
    @IBOutlet weak var isNeedReviewSwitch: UISwitch!
    
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
                self.lastViewBC.constant = keyboardSize.height + 40
                self.loadViewIfNeeded()
            }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.lastViewBC.constant = 40
            self.loadViewIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        usedesk.start(withCompanyID: companyIdTextField.text!, urlAPI: urlBaseTextField.text != nil ? urlBaseTextField.text! : nil, knowledgeBaseID: knowledgeBaseID, api_token: apiTokenTextField.text!, email: emailTextField.text!, phone: phoneTextField.text != nil ? phoneTextField.text! : nil, url: urlTextField.text!, urlToSendFile: urlToSendFileTextField.text!, port: portTextField.text!, name: nameTextField.text != nil ? nameTextField.text! : nil, operatorName: operatorNameTextField.text != nil ? operatorNameTextField.text! : nil, nameChat: nameChat, firstMessage: firstMessageTextField.text != nil ? firstMessageTextField.text : nil, note: noteTextField.text != nil ? noteTextField.text : nil, signature: signatureTextField.text != nil ? signatureTextField.text : nil, localeIdentifier: localeIdTextField.text != nil ? localeIdTextField.text : nil, presentIn: self, connectionStatus: { success, error in

        })
        }
}
