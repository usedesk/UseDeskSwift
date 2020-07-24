//
//  UDOfflineForm.swift

import Foundation
import MBProgressHUD
import Alamofire

class UDOfflineForm: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var messageTextField: UITextField!
    
    var url = ""
    weak var usedesk: UseDeskSDK?
    
    convenience init() {
        let nibName: String = "UDOfflineForm"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
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
        view.endEditing(true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard usedesk != nil else {return}
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Sending Message..."
        usedesk!.sendOfflineForm(withMessage: messageTextField.text) { [weak self] (result, error) in
            guard let wSelf = self else {return}
            if result {
                DispatchQueue.main.async(execute: {
                    hud.hide(animated: true)
                    wSelf.dismiss(animated: true)
                })
            } else {
                wSelf.showAlert("Error", text: error)
                hud.hide(animated: true)
            }
        }
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
