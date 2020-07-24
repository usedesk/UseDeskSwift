//
//  UDArticleView.swift

import Foundation
import UIKit

class UDArticleView: UIViewController, UIWebViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingView: UIView!
    
    var article: Article? = nil
    weak var usedesk: UseDeskSDK?
    var url: String?
    
    convenience init() {
        let nibName: String = "UDArticle"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))
        
        webView.delegate = self
        webView.loadHTMLString(article!.text, baseURL: nil)
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, isUseBase: usedesk!.isUseBase, account_id: usedesk!.account_id, api_token: usedesk!.api_token, email: usedesk!.email, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, nameChat: usedesk!.nameChat, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC : DialogflowView = DialogflowView()
                    dialogflowVC.usedesk = wSelf.usedesk
                    dialogflowVC.isFromBase = true
                    wSelf.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                })
            } else {
                if (error == "noOperators") {
                    let offlineVC = UDOfflineForm()
                    if wSelf.url != nil {
                        offlineVC.url = wSelf.url!
                    }
                    offlineVC.usedesk = wSelf.usedesk
                    wSelf.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
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
