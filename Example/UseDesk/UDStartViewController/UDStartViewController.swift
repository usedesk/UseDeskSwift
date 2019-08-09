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
    @IBOutlet weak var apiTokenTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    var collection: BaseCollection? = nil
    
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
        let usedesk: UseDeskSDK? = UseDeskSDK()
        usedesk!.start(withCompanyID: companyIdTextField.text!, account_id: accountIdTextField.text!, api_token: apiTokenTextField.text!, email: emailTextField.text!, url: urlTextField.text!, port: portTextField.text!, name: nameTextField.text!, connectionStatus: { success, error in
            
        })
    }
}
