//
//  UDStartViewController.swift
//  UseDesk_Example

import Foundation
import UIKit
import UseDesk_SDK_Swift


class UDStartViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var companyIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var portTextField: UITextField!
    @IBOutlet weak var accountIdTextField: UITextField!
    @IBOutlet weak var urlBaseTextField: UITextField!
    @IBOutlet weak var apiTokenTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameChatTextField: UITextField!
    @IBOutlet weak var firstMessageTextField: UITextField!
    @IBOutlet weak var operatorNameTextField: UITextField!
    @IBOutlet weak var lastViewBC: NSLayoutConstraint!
    
    var collection: BaseCollection? = nil
    var usedesk = UseDeskSDK()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: navBarTextColor
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
                self.lastViewBC.constant = keyboardSize.height
                self.loadViewIfNeeded()
            }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.lastViewBC.constant = 0
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
        var accountId = ""
        var nameChat = ""
        if accountIdTextField.text != nil {
            if accountIdTextField.text! != "" {
                accountId = accountIdTextField.text!
            }
        }
        if nameChatTextField.text != nil {
            if nameChatTextField.text! != "" {
                nameChat = nameChatTextField.text!
            }
        }
        usedesk.start(withCompanyID: companyIdTextField.text!, urlAPI: urlBaseTextField.text != nil ? urlBaseTextField.text! : nil, account_id: accountId, api_token: apiTokenTextField.text!, email: emailTextField.text!, phone: phoneTextField.text != nil ? phoneTextField.text! : nil, url: urlTextField.text!, port: portTextField.text!, name: nameTextField.text != nil ? nameTextField.text! : nil, operatorName: operatorNameTextField.text != nil ? operatorNameTextField.text! : nil, nameChat: nameChat, firstMessage: firstMessageTextField.text != nil ? firstMessageTextField.text : nil, presentIn: self, connectionStatus: { success, error in
        })
    }
}
