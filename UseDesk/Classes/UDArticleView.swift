//
//  UDArticleView.swift

import Foundation
import UIKit

class UDArticleView: UIViewController, UIWebViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: UIView!
    
    var article: Article? = nil
    var usedesk: Any?
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Чат", style: .done, target: self, action: #selector(self.actionChat))
        
        webView.delegate = self
        webView.loadHTMLString(article!.text, baseURL: nil)
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        let use = usedesk as! UseDeskSDK
        use.startWithoutGUICompanyID(companyID: use.companyID, account_id: use.account_id, api_token: use.api_token, email: use.email, url: use.urlWithoutPort, port: use.port, connectionStatus: { success, error in
            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC : DialogflowView = DialogflowView()
                    dialogflowVC.usedesk = self.usedesk
                    self.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        self.loadingView.alpha = 0
                    }
                })
            } else {
                if (error == "noOperators") {
                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                    if self.url != nil {
                        offlineVC.url = self.url!
                    }
                    self.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        self.loadingView.alpha = 0
                    }
                }
            }
        })
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        }
    }
}
