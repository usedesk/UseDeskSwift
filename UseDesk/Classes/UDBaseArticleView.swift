//
//  UDBaseArticleView.swift

import Foundation
import UIKit
import WebKit

class UDBaseArticleView: UDBaseKnowledgeVC, WKUIDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var topNavigateBackgroundView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var titleSmallLabel: UILabel!
    @IBOutlet weak var titleSmallLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleSmallLabelTC: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonHC: NSLayoutConstraint!
    @IBOutlet weak var backButtonWC: NSLayoutConstraint!
    @IBOutlet weak var backButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var backButtonLC: NSLayoutConstraint!
    
    @IBOutlet weak var titleBigLabel: UILabel!
    @IBOutlet weak var titleBigLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTopC: NSLayoutConstraint!
    
    @IBOutlet weak var articleView: UIView!
    @IBOutlet weak var articleViewHC: NSLayoutConstraint!
    @IBOutlet weak var articleViewTopC: NSLayoutConstraint!
    @IBOutlet weak var loaderArticle: UIActivityIndicatorView!
    
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewViewHC: NSLayoutConstraint!
    @IBOutlet weak var reviewViewTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTitleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var reviewTitleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var reviewTitleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveButton: UIButton!
    @IBOutlet weak var reviewPositiveButtonLC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveButtonTC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewNegativeButton: UIButton!
    @IBOutlet weak var reviewNegativeButtonTC: NSLayoutConstraint!
    @IBOutlet weak var reviewNegativeButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveTitleLabel: UILabel!
    @IBOutlet weak var reviewPositiveTitleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveTitleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var reviewPositiveTitleLabelTopC: NSLayoutConstraint!
    
    var article: UDArticle? = nil
    
    private var webView: WKWebView!
    
    private var heightArticleView: CGFloat = 0
    private var offsetScrollView: CGFloat = 0
    private var isSendedReview = false
    private var baseArticleStyle: BaseArticleStyle = BaseArticleStyle()
    
    convenience init() {
        let nibName: String = "UDBaseArticle"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        getArticle()
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFirstLoaded = false
    }
    
    // MARK: - Private
    override func firstState() {
        self.modalPresentationStyle = .formSheet
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        baseStyle = configurationStyle.baseStyle
        baseArticleStyle = configurationStyle.baseArticleStyle
        
        scrollViewBC.constant = baseStyle.windowBottomMargin
        
        view.backgroundColor = baseStyle.backgroundColor
        
        safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        scrollView.delegate = self
        
        topNavigateBackgroundView.backgroundColor = baseStyle.backgroundColor
        
        loader.alpha = 1
        loader.startAnimating()
        
        titleSmallLabel.text = article?.title
        titleSmallLabel.textColor = baseStyle.titleSmallColor
        titleSmallLabel.font = baseStyle.titleSmallFont
        titleSmallLabelLC.constant = baseStyle.titleSmallMargin.left
        titleSmallLabelTC.constant = baseStyle.titleSmallMargin.right
        titleSmallLabel.alpha = 0
        
        backButton.setImage(baseStyle.backButtonImage, for: .normal)
        backButton.setTitle("", for: .normal)
        backButtonHC.constant = baseStyle.backButtonSize.height
        backButtonWC.constant = baseStyle.backButtonSize.width
        backButtonTopC.constant = safeAreaInsets.top + baseStyle.backButtonMargin.top
        backButtonLC.constant = baseStyle.backButtonMargin.left
        
        loaderArticle.alpha = 1
        loaderArticle.startAnimating()
        
        setViews()
        
        super.firstState()
    }
    
    func getArticle() {
        guard article != nil else {return}
        usedesk?.getArticle(articleID: article!.id, connectionStatus: { [weak self] success, article in
            guard let wSelf = self else {return}
            if success {
                wSelf.hideErrorLoadView()
                wSelf.usedesk?.addViewsArticle(articleID: wSelf.article!.id, count: 1, connectionStatus: { _ in
                }, errorStatus: { _, _ in})
                wSelf.article = article
                wSelf.titleBigLabel.text = article?.title
                wSelf.titleSmallLabel.text = article?.title
                wSelf.loader.alpha = 0
                wSelf.loader.stopAnimating()
                wSelf.setReviewView()
                wSelf.setArticleView()
            }
        }, errorStatus: { [weak self] _, _ in
            guard let wSelf = self else {return}
            wSelf.showErrorLoadView(withAnimate: true)
        })
    }
    
    func setViews() {
        setTitleBigLabel()
        setArticleView()
        setReviewView()
        setChatButton()
        view.layoutIfNeeded()
    }
    
    func setTitleBigLabel() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        titleBigLabel.numberOfLines = 0
        titleBigLabel.textColor = baseStyle.titleBigColor
        titleBigLabel.font = baseStyle.titleBigFont
        titleBigLabel.text = article?.title
        
        titleBigLabelTopC.constant = baseStyle.titleBigMarginTop + topNavigateView.frame.height
        titleBigLabelLC.constant = baseStyle.contentMarginLeft
        titleBigLabelTC.constant = baseStyle.contentMarginRight
    }
    
    func setArticleView() {
        let baseStyle = configurationStyle.baseStyle
        articleView.clipsToBounds = true
        articleView.backgroundColor = baseStyle.contentViewsBackgroundColor
        articleView.udSetShadowFor(style: baseStyle)
        articleView.alpha = (article?.text ?? "").count > 0 ? 1 : 0
        guard (article?.created_at.count ?? 0) != 0 else {return}
        
        let source: String = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes';" +
        "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        let conf = WKWebViewConfiguration()
        conf.userContentController = userContentController
        userContentController.addUserScript(script)
        if webView != nil {
            webView.removeFromSuperview()
        }
        webView = WKWebView(frame: CGRect(origin: CGPoint(x: 13, y: 17), size: CGSize(width: UIScreen.main.bounds.width - safeAreaInsets.left - baseStyle.contentMarginLeft - safeAreaInsets.right - baseStyle.contentMarginRight - 26, height: 1)), configuration: conf)
        articleView.addSubview(webView)
        webView.navigationDelegate = self
        webView.contentMode = .left
        webView.uiDelegate = self
        let correctoredHtml = HTMLImageCorrector(HTMLString:article?.text ?? "")
        let styleContent = "<html><head><style>img{max-width:100%;height: auto;};</style></head>"
            + "<body style='margin:0; padding:0;'>" + correctoredHtml + "</body></html>"
        webView.loadHTMLString(styleContent, baseURL: nil)
    }
    
    func HTMLImageCorrector(HTMLString: String) -> String {
        var HTMLToBeReturned = HTMLString
        while HTMLToBeReturned.range(of: "(?<=width=\")[^\" height]+", options: .regularExpression) != nil {
            if let match = HTMLToBeReturned.range(of:"(?<=width=\")[^\" height]+", options: .regularExpression) {
                HTMLToBeReturned.removeSubrange(match)
                if let match2 = HTMLToBeReturned.range(of:"(?<=height=\")[^\"]+", options: .regularExpression) {
                    HTMLToBeReturned.removeSubrange(match2)
                    let string2del = "width=\"\" height=\"\""
                    HTMLToBeReturned = HTMLToBeReturned.replacingOccurrences(of:string2del, with: "")
                }
            }
        }
        return HTMLToBeReturned
    }
    
    func setReviewView() {
        guard usedesk != nil,
              configurationStyle.baseArticleStyle.isNeedReview,
              (article?.created_at.count ?? 0) != 0 else {
            reviewView.alpha = 0
            return
        }
        // ReviewTitleLabel
        reviewTitleLabel.numberOfLines = 0
        reviewTitleLabel.textColor = baseArticleStyle.reviewTitleColor
        reviewTitleLabel.font = baseArticleStyle.reviewTitleFont
        reviewTitleLabel.text = usedesk!.model.stringFor("ArticleReviewFirstTitle")
        reviewTitleLabelTopC.constant = baseArticleStyle.reviewTitleMargin.top
        reviewTitleLabelLC.constant = baseArticleStyle.reviewTitleMargin.left
        reviewTitleLabelTC.constant = baseArticleStyle.reviewTitleMargin.right
        // Review Yes No Buttons
        reviewPositiveButtonLC.constant = baseArticleStyle.reviewYesButtonMargin.left
        reviewPositiveButtonTC.constant = baseArticleStyle.reviewYesButtonMargin.right
        reviewPositiveButtonTopC.constant = baseArticleStyle.reviewYesButtonMargin.top
        reviewPositiveButton.layer.masksToBounds = true
        reviewPositiveButton.layer.cornerRadius = baseArticleStyle.reviewButtonCornerRadius
        reviewPositiveButton.backgroundColor = baseArticleStyle.reviewYesButtonColor
        reviewPositiveButton.titleLabel?.font = baseArticleStyle.reviewButtonFont
        if baseArticleStyle.isNeedImageForReviewButton {
            reviewPositiveButton.setImage(baseArticleStyle.reviewYesImage, for: .normal)
        }
        reviewPositiveButton.setTitleColor(baseArticleStyle.reviewYesTextColor, for: .normal)
        reviewPositiveButton.setTitle(usedesk!.model.stringFor("PositiveReviewButton"), for: .normal)
        if #available(iOS 15.0, *) {
            reviewPositiveButton.configurationUpdateHandler = { [weak self] button in
                guard let wSelf = self else {return}
                button.configuration?.imagePadding = wSelf.baseArticleStyle.reviewButtonImagePadding
                button.configuration?.contentInsets = NSDirectionalEdgeInsets(from: wSelf.baseArticleStyle.reviewButtonContentInsets)
            }
        } else {
            if baseArticleStyle.isNeedImageForReviewButton {
                reviewPositiveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: baseArticleStyle.reviewButtonImagePadding, bottom: 0, right: -(baseArticleStyle.reviewButtonImagePadding))
                reviewPositiveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: baseArticleStyle.reviewButtonImagePadding)
                reviewPositiveButton.contentEdgeInsets = UIEdgeInsets(top: baseArticleStyle.reviewButtonContentInsets.top, left: baseArticleStyle.reviewButtonContentInsets.left, bottom: baseArticleStyle.reviewButtonContentInsets.bottom, right: 2 * baseArticleStyle.reviewButtonContentInsets.right)
            } else {
                reviewPositiveButton.contentEdgeInsets = UIEdgeInsets(top: baseArticleStyle.reviewButtonContentInsets.top, left: baseArticleStyle.reviewButtonContentInsets.left, bottom: baseArticleStyle.reviewButtonContentInsets.bottom, right: baseArticleStyle.reviewButtonContentInsets.right)
            }
        }
        
        reviewNegativeButtonTC.constant = baseArticleStyle.reviewNoButtonMargin.right
        reviewNegativeButtonTC.isActive = false
        reviewNegativeButtonTopC.constant = baseArticleStyle.reviewNoButtonMargin.top
        reviewNegativeButton.layer.masksToBounds = true
        reviewNegativeButton.layer.cornerRadius = baseArticleStyle.reviewButtonCornerRadius
        reviewNegativeButton.backgroundColor = baseArticleStyle.reviewNoButtonColor
        reviewNegativeButton.titleLabel?.font = baseArticleStyle.reviewButtonFont
        if baseArticleStyle.isNeedImageForReviewButton {
            reviewNegativeButton.setImage(baseArticleStyle.reviewNoImage, for: .normal)
        }
        reviewNegativeButton.setTitleColor(baseArticleStyle.reviewNoTextColor, for: .normal)
        reviewNegativeButton.setTitle(usedesk!.model.stringFor("NegativeReviewButton"), for: .normal)
        if #available(iOS 15.0, *) {
            reviewNegativeButton.configurationUpdateHandler = { [weak self] button in
                guard let wSelf = self else {return}
                button.configuration?.imagePadding = wSelf.baseArticleStyle.reviewButtonImagePadding
                button.configuration?.contentInsets = NSDirectionalEdgeInsets(from: wSelf.baseArticleStyle.reviewButtonContentInsets)
            }
        } else {
            if baseArticleStyle.isNeedImageForReviewButton {
                reviewNegativeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: baseArticleStyle.reviewButtonImagePadding, bottom: 0, right: -(baseArticleStyle.reviewButtonImagePadding))
                reviewNegativeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: baseArticleStyle.reviewButtonImagePadding)
                reviewNegativeButton.contentEdgeInsets = UIEdgeInsets(top: baseArticleStyle.reviewButtonContentInsets.top, left: baseArticleStyle.reviewButtonContentInsets.left, bottom: baseArticleStyle.reviewButtonContentInsets.bottom, right: 2 * baseArticleStyle.reviewButtonContentInsets.right)
            } else {
                reviewNegativeButton.contentEdgeInsets = UIEdgeInsets(top: baseArticleStyle.reviewButtonContentInsets.top, left: baseArticleStyle.reviewButtonContentInsets.left, bottom: baseArticleStyle.reviewButtonContentInsets.bottom, right: baseArticleStyle.reviewButtonContentInsets.right)
            }
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        reviewPositiveButtonTopC.isActive = reviewPositiveButton.frame.height > reviewNegativeButton.frame.height ? true : false
        reviewNegativeButtonTopC.isActive = reviewPositiveButton.frame.height > reviewNegativeButton.frame.height ? false : true
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let maxWidthReviewNegativeButton = reviewView.frame.width - reviewNegativeButton.frame.origin.x - baseArticleStyle.reviewNoButtonMargin.right
        reviewNegativeButtonTC.isActive = reviewNegativeButton.frame.width > maxWidthReviewNegativeButton || reviewPositiveButton.frame.width > maxWidthReviewNegativeButton ? true : false
        
        reviewPositiveTitleLabel.text = usedesk?.model.stringFor("ArticleReviewSendedTitle") ?? ""
        reviewPositiveTitleLabel.textColor = baseArticleStyle.reviewPositiveTextColor
        reviewPositiveTitleLabel.font = baseArticleStyle.reviewPositiveTextFont
        reviewPositiveTitleLabelLC.constant = baseArticleStyle.reviewPositiveTextMargin.left
        reviewPositiveTitleLabelTC.constant = baseArticleStyle.reviewPositiveTextMargin.right
        reviewPositiveTitleLabelTopC.constant = baseArticleStyle.reviewPositiveTextMargin.top

        view.setNeedsLayout()
        view.layoutIfNeeded()
        var heightReviewView = baseArticleStyle.reviewTitleMargin.top + reviewTitleLabel.frame.height
        if isSendedReview {
            heightReviewView += baseArticleStyle.reviewPositiveTextMargin.top + reviewPositiveTitleLabel.frame.height + baseArticleStyle.reviewPositiveTextMargin.bottom
            UIView.animate(withDuration: 0.15) {
                self.reviewPositiveButton.alpha = 0
                self.reviewNegativeButton.alpha = 0
                self.reviewPositiveTitleLabel.alpha = 1
            }
        } else {
            var titlePositiveButton = "T"
            var titleNegativeButton = "T"
            if #available(iOS 15.0, *) {
                titlePositiveButton = reviewPositiveButton.titleLabel?.text ?? ""
                titleNegativeButton = reviewNegativeButton.titleLabel?.text ?? ""
            }
            let heightPositiveButton = titlePositiveButton.size(availableWidth: reviewPositiveButton.frame.width, attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewButtonFont]).height + baseArticleStyle.reviewButtonContentInsets.top + baseArticleStyle.reviewButtonContentInsets.bottom
            let heightNegativeButton = titleNegativeButton.size(availableWidth: reviewNegativeButton.frame.width, attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewButtonFont]).height + baseArticleStyle.reviewButtonContentInsets.top + baseArticleStyle.reviewButtonContentInsets.bottom
            let maxHeightButtons = heightNegativeButton > heightPositiveButton ? heightNegativeButton : heightPositiveButton
            heightReviewView += maxHeightButtons + baseArticleStyle.reviewYesButtonMargin.bottom
            UIView.animate(withDuration: 0.3) {
                self.reviewPositiveButton.alpha = 1
                self.reviewNegativeButton.alpha = 1
                self.reviewPositiveTitleLabel.alpha = 0
            }
            reviewPositiveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewPositiveButtonDidTap)))
            reviewNegativeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewNegativeButtonDidTap)))
        }
        self.view.layoutIfNeeded()
        if reviewViewHC.constant == 0 {
            reviewViewHC.constant = heightReviewView
        } else {
            UIView.animate(withDuration: 0.3) {
                self.reviewViewHC.constant = heightReviewView
                
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.reviewView.alpha = 1
        }
    }

    override func setChatButton() {
        super.setChatButton()
        updatePositionChatButton()
    }
    
    override func updateViewsBeforeChangeOrientationWindow() {
        if !isFirstLoaded {
            DispatchQueue.main.async {
                self.safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
                self.setChatButton()
                self.backButtonTopC.constant = self.safeAreaInsets.top + self.baseStyle.backButtonMargin.top
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.setArticleView()
                self.titleBigLabelTopC.constant = self.baseStyle.titleBigMarginTop + self.topNavigateView.frame.height
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.updateVisibleBlurView()
            }
        }
    }
    
    private func updatePositionChatButton() {
        let baseStyle = configurationStyle.baseStyle
        if scrollView.frame.height >= scrollView.contentSize.height {
            chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: UIScreen.main.bounds.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom)
            loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
        } else {
            let differentHeight = scrollView.contentSize.height - scrollView.frame.height
            if scrollView.contentOffset.y > differentHeight {
                chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: UIScreen.main.bounds.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom - (scrollView.contentOffset.y - (differentHeight)))
                loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
            } else {
                chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: UIScreen.main.bounds.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom)
                loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
            }
        }
    }
    
    func updateVisibleSmallTitleLabel() {
        if scrollView.contentOffset.y > (titleBigLabel.frame.height + baseStyle.titleBigMarginTop - 5) && titleSmallLabel.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.titleSmallLabel.alpha = 1
            }
        } else if scrollView.contentOffset.y < (titleBigLabel.frame.height + baseStyle.titleBigMarginTop - 5) && titleSmallLabel.alpha == 1 {
            UIView.animate(withDuration: 0.2) {
                self.titleSmallLabel.alpha = 0
            }
        }
    }
    
    func updateVisibleBlurView() {
        if scrollView.contentOffset.y > titleBigLabel.frame.height + baseStyle.titleBigMarginTop {
            blurView.alpha = 1
            let coefficient: CGFloat = 100 / 50
            var procent = coefficient * (scrollView.contentOffset.y - (titleBigLabel.frame.height + baseStyle.titleBigMarginTop))
            if procent > 100 {
                procent = 100
            }
            let alphaValue = procent / 100
            topNavigateBackgroundView.alpha = 1 - alphaValue + baseStyle.topBlurСoefficient
        } else {
            blurView.alpha = 0
            topNavigateBackgroundView.alpha = 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.layoutIfNeeded()
        updatePositionChatButton()
        updateVisibleSmallTitleLabel()
        updateVisibleBlurView()
    }
    
    // MARK: - User actions
    @objc func reviewPositiveButtonDidTap() {
        guard usedesk?.reachability != nil else {return}
        guard usedesk?.reachability?.connection != .unavailable else {
            showAlertNoInternet()
            return
        }
        isSendedReview = true
        setReviewView()
        guard article != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: article!.id, countPositive: 1, countNegative: 0) { _ in} errorStatus: { _, _ in}
    }
    
    @objc func reviewNegativeButtonDidTap() {
        guard article != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: article!.id, countPositive: 0, countNegative: 1) { _ in} errorStatus: { _, _ in}
        let articleReviewVC: UDBaseArticleReviewVC = UDBaseArticleReviewVC()
        articleReviewVC.usedesk = usedesk!
        articleReviewVC.delegate = self
        articleReviewVC.article = article
        usedesk?.uiManager?.pushViewController(articleReviewVC)
        isSendedReview = true
        setReviewView()
    }
    
    @IBAction func backAction(_ sender: Any) {
        if isShownNoInternet || (self.navigationController?.viewControllers.count ?? 0 < 2) {
            super.backAction()
        } else {
            self.navigationController?.popViewController(animated: true)
            self.removeFromParent()
        }
    }
}
// MARK: - WKNavigationDelegate
extension UDBaseArticleView: WKNavigationDelegate {
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
            webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { [weak self] result, error in
                guard let wSelf = self else {return}
                if let height = result as? CGFloat {
                    wSelf.heightArticleView = height + 56
                    wSelf.articleViewHC.constant = wSelf.heightArticleView
                    wSelf.webView.frame.size = CGSize(width: wSelf.webView.frame.width, height: wSelf.articleViewHC.constant - 34)
                    wSelf.view.setNeedsLayout()
                    wSelf.view.layoutIfNeeded()
                    if wSelf.contentView.frame.height > wSelf.view.frame.height - wSelf.topNavigateView.frame.height {
                        wSelf.webView.scrollView.isScrollEnabled = true
                    } else {
                        wSelf.webView.scrollView.isScrollEnabled = false
                    }
                    wSelf.articleView.udSetShadowFor(style: wSelf.baseStyle)
                    wSelf.reviewView.udSetShadowFor(style: wSelf.baseStyle)
                    wSelf.updatePositionChatButton()
                    wSelf.loaderArticle.alpha = 0
                    wSelf.loaderArticle.stopAnimating()
                }
            })
        })
    }
}

extension UDBaseArticleView: UDBaseArticleReviewVCDelegate {
    func sendedReview() {
        isSendedReview = true
        setReviewView()
    }
}

extension NSDirectionalEdgeInsets {
    init(from edgeInsets: UIEdgeInsets) {
        self = NSDirectionalEdgeInsets(top: edgeInsets.top, leading: edgeInsets.left, bottom: edgeInsets.bottom, trailing: edgeInsets.right)
    }
}
