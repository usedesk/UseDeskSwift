//
//  UDOfflineForm.swift

import Foundation
import MBProgressHUD


class UDOfflineForm: UIViewController, UITextFieldDelegate {
    var url = ""
    
    @IBOutlet var companyIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Offline form"
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //********** VIEW TAPPED **********
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        print("Touched and hide keyboard")
        view.endEditing(true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Sending Message..."
        let body = getPostData()
        DispatchQueue.global(qos: .default).async(execute: {
//            let manager = AFHTTPSessionManager()
//            manager.requestSerializer.timeoutInterval = 15.0
//            
//            //manager.securityPolicy.allowInvalidCertificates = YES;
//            
//            manager.responseSerializer.acceptableContentTypes = Set<AnyHashable>(["application/json"]) as? Set<String>
//            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
//            let urlStr = "\(self.url)/widget.js/post"
//            manager.post(urlStr, parameters: body, progress: { uploadProgress in
//                
//            }, success: { task, responseObject in
//                if let anObject = responseObject {
//                    print("autorization JSON: \(anObject)")
//                }
//                DispatchQueue.main.async(execute: {
//                    hud.hide(animated: true)
//                    self.dismiss(animated: true)
//                    // }];
//                })
//                
//                
//            }, failure: { task, error in
//                self.showAlert("Error", text: error.localizedDescription)
//                hud.hide(animated: true)
//                
//            })
            
            
        })
    }
    
    func getPostData() -> [AnyHashable : Any]? {
        let dic = [
            "company_id" : companyIdTextField.text,
            "name" : nameTextField.text,
            "email" : emailTextField.text,
            "message" : messageTextField.text
        ]
        return dic as [AnyHashable : Any]
        
    }
    
    @IBAction func cancelMessage(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     #pragma mark - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    func showAlert(_ title: String?, text: String?) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            //BUTTON OK CLICK EVENT
        })
        // UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        // [alert addAction:cancel];
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
