//
//  UDArticleView.swift

import Foundation
import UIKit
import WebKit

class UDArticleView: UIViewController, WKUIDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    
    var article: Article? = nil
    var webView: WKWebView!
    
    var reviewView = UIView()
    var reviewTitleLabel = UILabel()
    var reviewPositivButton = UIButton(type: .system)
    var reviewNegativButton = UIButton(type: .system)
    var reviewNegativView = UIView()
    var reviewNegativSendMessageButton = UIButton(type: .system)
    var reviewNegativTitleLabel = UILabel()
    var reviewNegativTextView = UITextView()
    var reviewFinishView = UIView()
    var reviewFinishTitleLabel = UILabel()
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    var gestureCommentTable: UIGestureRecognizer!
    var keyboardHeight: CGFloat? = 0
    var isShowKeyboard = false
    
    convenience init() {
        let nibName: String = "UDArticle"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        // Gesture
        reviewPositivButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewPositivButtonDidTap)))
        reviewNegativButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewNegativButtonDidTap)))
        reviewNegativSendMessageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewNegativSendMessageButtonDidTap)))
        gestureCommentTable = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardShow(_ notification: NSNotification) {
        if !isShowKeyboard {
            
            let info = notification.userInfo
            let keyboard: CGRect? = (info?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let duration = TimeInterval((info?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0)
            
            keyboardHeight = keyboard?.size.height
            if keyboardHeight != nil {
                scrollView.addGestureRecognizer(gestureCommentTable)
                UIView.animate(withDuration: duration, animations: {
                    self.scrollView.contentOffset.y += self.keyboardHeight!
                    self.view.layoutIfNeeded()
                }) { (_) in
                    self.isShowKeyboard = true
                }
            }
            
        }
    }
    
    @objc func keyboardHide(_ notification: NSNotification) {
        if isShowKeyboard {
            scrollView.removeGestureRecognizer(gestureCommentTable)
            isShowKeyboard = false
            if keyboardHeight != nil {
                UIView.animate(withDuration: 0.3, animations: {
                    self.scrollViewBC.constant = 0
                    self.scrollView.contentOffset.y -= self.keyboardHeight!
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isShowKeyboard {
            dismissKeyboard()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func firstState() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))
        scrollView.delegate = self
        setWebView()
        setReviewView()
    }
    
    func setWebView() {
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=yes';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        let conf = WKWebViewConfiguration()
        conf.userContentController = userContentController
        userContentController.addUserScript(script)
        webView = WKWebView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: 1)), configuration: conf)
        contentView.addSubview(webView)
        webView.navigationDelegate = self
        webView.contentMode = .left
        webView.uiDelegate = self
        webView.loadHTMLString(article!.text, baseURL: nil)
    }
    
    func setReviewView() {
        reviewView.frame.size = CGSize(width: self.view.frame.width, height: 170)
        reviewTitleLabel.text = "Была ли статья полезна?"
        reviewTitleLabel.frame = CGRect(x: 16, y: 16, width: self.view.frame.width - (16 * 2), height: 22)
        reviewView.addSubview(reviewTitleLabel)
        reviewPositivButton.frame = CGRect(x: 16, y: 58, width: 120, height: 40)
        reviewPositivButton.setTitle("Да", for: .normal)
        setStndartButton(button: reviewPositivButton)
        reviewView.addSubview(reviewPositivButton)
        reviewNegativButton.frame = CGRect(x: 152, y: 58, width: 120, height: 40)
        reviewNegativButton.setTitle("Нет", for: .normal)
        setStndartButton(button: reviewNegativButton)
        reviewView.addSubview(reviewNegativButton)
        //Review Finish
        reviewFinishView.frame = CGRect(x: 0, y: 0, width: reviewView.frame.width, height: reviewView.frame.height)
        reviewFinishView.alpha = 0
        reviewFinishView.backgroundColor = .white
        reviewView.addSubview(reviewFinishView)
        reviewFinishTitleLabel.text = "Спасибо за отзыв!"
        reviewFinishTitleLabel.frame = CGRect(x: 16, y: 58, width: self.view.frame.width - (16 * 2), height: 22)
        reviewFinishView.addSubview(reviewFinishTitleLabel)
        //Review Negativ
        reviewNegativView.frame = CGRect(x: 0, y: 0, width: reviewView.frame.width, height: reviewView.frame.height)
        reviewNegativView.alpha = 0
        reviewNegativView.backgroundColor = .white
        reviewNegativTitleLabel.text = "Посоветуйте, как нам улучшить статью"
        reviewNegativTitleLabel.frame = CGRect(x: 16, y: 16, width: self.view.frame.width - (16 * 2), height: 22)
        reviewNegativView.addSubview(reviewNegativTitleLabel)
        reviewNegativSendMessageButton.frame = CGRect(x: 16, y: 150, width: 120, height: 30)
        reviewNegativSendMessageButton.setTitle("Отправить", for: .normal)
        setStndartButton(button: reviewNegativSendMessageButton)
        reviewNegativView.addSubview(reviewNegativSendMessageButton)
        reviewNegativTextView.frame = CGRect(x: 16, y: 46, width: self.view.frame.width - (16 * 2), height: 94)
        reviewNegativTextView.layer.borderWidth = 1
        reviewNegativTextView.layer.borderColor = UIColor.black.cgColor
        reviewNegativView.addSubview(reviewNegativTextView)
    }
    
    func setStndartButton(button: UIButton) {
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    
    @objc func reviewPositivButtonDidTap() {
        guard article != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: article!.id, countPositiv: 1, countNegativ: 0) { [weak self] (success, _) in
            guard let wSelf = self else {return}
            if success {
                wSelf.reviewFinishView.alpha = 1
            }
        }
    }
    
    @objc func reviewNegativButtonDidTap() {
        guard article != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: article!.id, countPositiv: 0, countNegativ: 1) { [weak self] (success, _) in
            guard let wSelf = self else {return}
            if success {
                wSelf.reviewView.addSubview(wSelf.reviewNegativView)
                wSelf.reviewNegativView.alpha = 1
                wSelf.reviewNegativTextView.becomeFirstResponder()
            }
        }
    }
    
    @objc func reviewNegativSendMessageButtonDidTap() {
        guard article != nil && usedesk != nil && reviewNegativTextView.text?.count ?? -1 > 0 else {return}
        usedesk!.sendReviewArticleMesssage(articleID: article!.id, message: reviewNegativTextView.text!) { [weak self] (success, _) in
            guard let wSelf = self else {return}
            if success {
                wSelf.reviewNegativView.removeFromSuperview()
                wSelf.reviewFinishView.alpha = 1
            }
        }
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        guard usedesk != nil else {return}
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, account_id: usedesk!.account_id, api_token: usedesk!.api_token, email: usedesk!.email, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, operatorName: usedesk!.operatorName, nameChat: usedesk!.nameChat, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC : DialogflowView = DialogflowView()
                    dialogflowVC.usedesk = wSelf.usedesk
                    dialogflowVC.isFromBase = true
                    wSelf.navigationController?.pushViewController(dialogflowVC, animated: true)
                })
            } else {
                if (error == "noOperators") {
                    let offlineVC = UDOfflineForm()
                    if wSelf.url != nil {
                        offlineVC.url = wSelf.url!
                    }
                    offlineVC.usedesk = wSelf.usedesk
                    wSelf.navigationController?.pushViewController(offlineVC, animated: true)
                }
            }
        })
    }
}

extension UDArticleView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if components?.scheme == "http" || components?.scheme == "https"
            {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_  webView: WKWebView, didFinish navigation: WKNavigation!) {
     webView.evaluateJavaScript("document.readyState", completionHandler: { result, error in

         if result == nil || error != nil {
             return
         }

         webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { result, error in
             if let height = result as? CGFloat {
                self.webView.frame.size = CGSize(width: self.webView.frame.width, height: height + 24)
                self.contentViewHC.constant = height + 24 + 200
                if self.contentViewHC.constant > self.view.frame.height {
                    self.webView.scrollView.isScrollEnabled = true
                } else {
                    self.webView.scrollView.isScrollEnabled = false
                }
                self.reviewView.frame.origin = CGPoint(x: 0, y: height + 24)
                self.contentView.addSubview(self.reviewView)
             }
         })
     })
    }
}
