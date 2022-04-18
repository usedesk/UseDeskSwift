//
//  UDBaseArticleView.swift

import Foundation
import UIKit
import WebKit

protocol UDBaseArticleViewDelegate: AnyObject {
    func openChat()
    func openOfflineForm()
}

class UDBaseArticleView: UIViewController, WKUIDelegate, UISearchBarDelegate, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHC: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonHC: NSLayoutConstraint!
    @IBOutlet weak var closeButtonWC: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTC: NSLayoutConstraint!
    
    var url: String?
    var articles: [UDArticleTitle] = []
    var selectedArticle: UDArticle? = nil
    var indexSelectedArticle: Int = 0
    weak var usedesk: UseDeskSDK?
    weak var delegate: UDBaseArticleViewDelegate?

    private var webView: WKWebView!
    // Title View
    private var titleView = UIView()
    private var titleBigLabel = UILabel()
    // Review View
    private var reviewView = UIView()
    private var reviewTitleLabel = UILabel()
    private var reviewPositivButton = UIButton(type: .system)
    private var reviewNegativButton = UIButton(type: .system)
    private var reviewSendButton = UIButton(type: .system)
    private var reviewTextView = UITextView()
    private var reviewLineSendBottomView = UIView()
    // Transitions View
    private var transitionsView = UIView()
    private var transitionsLineView = UIView()
    private var transitionsLeftImageView = UIImageView()
    private var transitionsLeftLabel = UILabel()
    private var transitionsLeftButton = UIButton()
    private var transitionsRightImageView = UIImageView()
    private var transitionsRightLabel = UILabel()
    private var transitionsRightButton = UIButton()
    // Chat Button
    private var chatButton = UIButton()
    private var loaderChatButton = UIActivityIndicatorView(style: .white)
    
    private var gestureCommentTable: UIGestureRecognizer!
    private var keyboardHeight: CGFloat = 336
    private var keyboardAnimateDuration: CGFloat = 0.4
    private var isShowKeyboard = false
    private var heightWebView: CGFloat = 0
    private var offsetScrollView: CGFloat = 0
    private var isFirstLoaded = true
    private var isSendReviewState = false
    private var safeAreaInsetsBottom: CGFloat = 0.0
    private var previousOrientation: Orientation = .portrait
    private var landscapeOrientation: LandscapeOrientation? = nil
    
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    convenience init() {
        let nibName: String = "UDBaseArticle"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        // Gesture
        reviewPositivButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewPositivButtonDidTap)))
        reviewNegativButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewNegativButtonDidTap)))
        reviewSendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.reviewNegativSendMessageButtonDidTap)))
        transitionsRightButton.addTarget(self, action: #selector(openNextArticle), for: .touchUpInside)
        transitionsLeftButton.addTarget(self, action: #selector(openPreviusArticle), for: .touchUpInside)
        
        gestureCommentTable = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoaded {
            if #available(iOS 11.0, *) {
                safeAreaInsetsBottom = view.safeAreaInsets.bottom
            }
            setViews()
            isFirstLoaded = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dismissKeyboard()
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if previousOrientation != .portrait {
                safeAreaInsetsLeftOrRight = 0
                previousOrientation = .portrait
                if !isFirstLoaded {
                    setViews()
                }
                if scrollView.contentOffset.y < titleView.frame.height {
                    scrollView.contentOffset.y = 0
                }
            }
        } else {
            if previousOrientation != .landscape {
                if #available(iOS 11.0, *) {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.left > view.safeAreaInsets.right ? view.safeAreaInsets.left : view.safeAreaInsets.right
                    if UIDevice.current.orientation == .landscapeLeft {
                        landscapeOrientation = .left
                    } else if UIDevice.current.orientation == .landscapeRight {
                        landscapeOrientation = .right
                    } else {
                        landscapeOrientation = nil
                    }
                }
                previousOrientation = .landscape
                if !isFirstLoaded {
                    setViews()
                }
                if scrollView.contentOffset.y < titleView.frame.height {
                    scrollView.contentOffset.y = titleView.frame.height
                }
            }
        }
    }
    // MARK: - Private
    @objc func keyboardShow(_ notification: NSNotification) {
        if !isShowKeyboard {
            let info = notification.userInfo
            let keyboard: CGRect? = (info?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            keyboardHeight = keyboard?.size.height ?? 336
            keyboardAnimateDuration = CGFloat(TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0))
            scrollView.addGestureRecognizer(gestureCommentTable)
            let yPointMax = reviewView.frame.origin.y - scrollView.contentOffset.y + reviewSendButton.frame.origin.y + configurationStyle.baseArticleStyle.reviewSendButtonMargin.bottom
            UIView.animate(withDuration: TimeInterval(keyboardAnimateDuration), animations: {
                if yPointMax > self.scrollView.frame.height - self.keyboardHeight {
                    self.offsetScrollView = yPointMax - (self.scrollView.frame.height - self.keyboardHeight)
                    self.scrollView.contentOffset.y += self.offsetScrollView
                }
            }) { (_) in
                self.view.layoutIfNeeded()
                self.isShowKeyboard = true
            }
        }
    }
    
    @objc func keyboardHide(_ notification: NSNotification) {
        if isShowKeyboard {
            scrollView.removeGestureRecognizer(gestureCommentTable)
            isShowKeyboard = false
            contentViewHC.constant = titleView.frame.height + heightWebView + reviewView.frame.height + transitionsView.frame.height
            if contentViewHC.constant < scrollView.frame.height {
                contentViewHC.constant = scrollView.frame.height
            }
            titleView.frame.origin = CGPoint(x: 0, y: 0)
            webView.frame.origin = CGPoint(x: 8, y: titleView.frame.height)
            reviewView.frame.origin = CGPoint(x: 0, y: titleView.frame.height + heightWebView)
            transitionsView.frame.origin = CGPoint(x: 0, y: contentViewHC.constant - transitionsView.frame.height)
            updatePositionChatButton()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.scrollViewBC.constant = 0
                    self.scrollView.contentOffset.y -= self.offsetScrollView
            })
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            if isShowKeyboard {
                dismissKeyboard()
            }
        }
        updatePositionChatButton()
        updateVisibleSmallTitleLabel()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func firstState() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        self.modalPresentationStyle = .formSheet
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        let baseArticleStyle = configurationStyle.baseArticleStyle
        scrollView.delegate = self
        titleLabel.text = selectedArticle?.title
        titleLabel.textColor = baseArticleStyle.titleColor
        titleLabel.font = baseArticleStyle.titleFont
        titleLabelTopC.constant = baseArticleStyle.titleMargin.top
        titleLabelLC.constant = baseArticleStyle.titleMargin.left
        titleLabelTC.constant = baseArticleStyle.titleMargin.right
        titleLabel.alpha = 0
        
        closeButton.setBackgroundImage(baseArticleStyle.closeButtonImage, for: .normal)
        closeButtonHC.constant = baseArticleStyle.closeButtonSize.height
        closeButtonWC.constant = baseArticleStyle.closeButtonSize.width
        closeButtonTopC.constant = baseArticleStyle.closeButtonMargin.top
        closeButtonTC.constant = baseArticleStyle.closeButtonMargin.right
        
        topSeparatorView.backgroundColor = baseArticleStyle.topSeparatorViewColor
        topSeparatorView.alpha = 0
    }
    
    func setViews() {
        isSendReviewState = false
        setTitleView()
        setTransitionsView()
        setWebView()
        setReviewView()
        setChatButton()
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        }
    }
    
    func setTitleView() {
        let baseArticleStyle = configurationStyle.baseArticleStyle
        titleBigLabel.numberOfLines = 0
        titleBigLabel.textColor = baseArticleStyle.titleBigColor
        titleBigLabel.font = baseArticleStyle.titleBigFont
        titleBigLabel.text = selectedArticle?.title
        let widthBigTitle = self.view.frame.width - (baseArticleStyle.titleBigMargin.left + baseArticleStyle.titleBigMargin.right)
        let heightBigTitleText = titleBigLabel.text!.size(availableWidth: widthBigTitle, attributes: [NSAttributedString.Key.font : baseArticleStyle.titleBigFont]).height
        titleBigLabel.frame = CGRect(x: baseArticleStyle.titleBigMargin.left, y: baseArticleStyle.titleBigMargin.top, width: widthBigTitle, height: heightBigTitleText)
        if titleBigLabel.superview == nil {
            titleView.addSubview(titleBigLabel)
        }
        titleView.frame.size = CGSize(width: self.view.frame.width, height: heightBigTitleText + baseArticleStyle.titleBigMargin.top + baseArticleStyle.titleBigMargin.bottom)
    }
    
    func setTransitionsView() {
        guard articles.count > 0 else {return}
        let baseArticleStyle = configurationStyle.baseArticleStyle
        
        transitionsLineView.backgroundColor = baseArticleStyle.separatorViewColor
        transitionsLineView.frame.size = CGSize(width: self.view.frame.width - (baseArticleStyle.separatorViewMargin.left + baseArticleStyle.separatorViewMargin.right), height: baseArticleStyle.separatorViewHeight)
        transitionsLineView.frame.origin = CGPoint(x: baseArticleStyle.separatorViewMargin.left, y: 0)
        if transitionsLineView.superview == nil {
            transitionsView.addSubview(transitionsLineView)
        }
        let maxWidthLabels = (self.view.frame.width - baseArticleStyle.previousArticleImageMargin.left - baseArticleStyle.previousArticleImageSize.width - baseArticleStyle.articlePreviousMargin.left - 15 - baseArticleStyle.previousArticleImageMargin.left - baseArticleStyle.nextArticleImageSize.width - baseArticleStyle.nextArticleImageMargin.right) / 2
        let maxHeightPrevius = "Tp \nTp".size(availableWidth: maxWidthLabels, attributes: [NSAttributedString.Key.font : baseArticleStyle.articlePreviousFont]).height
        let maxHeightNext = "Tp \nTp".size(availableWidth: maxWidthLabels, attributes: [NSAttributedString.Key.font : baseArticleStyle.articleNextFont]).height
                
        // Left Button
        transitionsLeftImageView.image = baseArticleStyle.previousArticleImage
        transitionsLeftImageView.frame.size = CGSize(width: baseArticleStyle.previousArticleImageSize.width, height: baseArticleStyle.previousArticleImageSize.height)
        transitionsLeftImageView.frame.origin = CGPoint(x: baseArticleStyle.previousArticleImageMargin.left, y: baseArticleStyle.previousArticleImageMargin.top)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                transitionsLeftImageView.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        if transitionsLeftImageView.superview == nil {
            transitionsView.addSubview(transitionsLeftImageView)
        }
        var heightNext: CGFloat = 0
        if indexSelectedArticle > 0 {
            let indexPrevious = indexSelectedArticle - 1
            transitionsLeftLabel.text = articles[indexPrevious].title
            heightNext = articles[indexPrevious].title.size(availableWidth: maxWidthLabels, attributes: [NSAttributedString.Key.font : baseArticleStyle.articleNextFont]).height
            transitionsLeftImageView.alpha = 1
            transitionsLeftLabel.alpha = 1
            transitionsLeftButton.alpha = 1
        } else {
            transitionsLeftImageView.alpha = 0
            transitionsLeftLabel.alpha = 0
            transitionsLeftButton.alpha = 0
        }
        transitionsLeftLabel.textColor = baseArticleStyle.articlePreviousColor
        transitionsLeftLabel.font = baseArticleStyle.articlePreviousFont
        transitionsLeftLabel.numberOfLines = 0
        let widthPrevious = transitionsLeftLabel.text?.size(attributes: [NSAttributedString.Key.font : baseArticleStyle.articlePreviousFont]).width ?? 0
        transitionsLeftLabel.frame.size = CGSize(width: widthPrevious < maxWidthLabels ? widthPrevious : maxWidthLabels, height: heightNext < maxHeightPrevius ? heightNext : maxHeightPrevius)
        transitionsLeftLabel.frame.origin = CGPoint(x: baseArticleStyle.previousArticleImageMargin.left + baseArticleStyle.previousArticleImageSize.width + baseArticleStyle.previousArticleImageMargin.right, y: baseArticleStyle.articlePreviousMargin.top)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                transitionsLeftLabel.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        if transitionsLeftLabel.superview == nil {
            transitionsView.addSubview(transitionsLeftLabel)
        }
        transitionsLeftButton.setTitle("", for: .normal)
        transitionsLeftButton.backgroundColor = .clear
        transitionsLeftButton.frame.size = CGSize(width: baseArticleStyle.previousArticleImageMargin.left + baseArticleStyle.previousArticleImageSize.width + baseArticleStyle.articlePreviousMargin.right + transitionsLeftLabel.frame.width, height: maxHeightPrevius)
        transitionsLeftButton.frame.origin = CGPoint(x: 0, y: baseArticleStyle.previousArticleImageMargin.top)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                transitionsLeftButton.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        if transitionsLeftButton.superview == nil {
            transitionsView.addSubview(transitionsLeftButton)
        }
        // Right Button
        transitionsRightImageView.image = baseArticleStyle.nextArticleImage
        transitionsRightImageView.frame.size = CGSize(width: baseArticleStyle.nextArticleImageSize.width, height: baseArticleStyle.nextArticleImageSize.height)
        transitionsRightImageView.frame.origin = CGPoint(x: self.view.frame.width - baseArticleStyle.nextArticleImageMargin.right - baseArticleStyle.nextArticleImageSize.width, y: baseArticleStyle.nextArticleImageMargin.top)
        if previousOrientation == .landscape {
            if landscapeOrientation != .left {
                transitionsRightImageView.frame.origin.x -= safeAreaInsetsLeftOrRight
            }
        }
        if transitionsRightImageView.superview == nil {
            transitionsView.addSubview(transitionsRightImageView)
        }
        var heightPrevius: CGFloat = 0
        if articles.count > indexSelectedArticle + 1 {
            let indexPrevius = indexSelectedArticle + 1
            transitionsRightLabel.text = articles[indexPrevius].title
            heightPrevius = articles[indexPrevius].title.size(availableWidth: maxWidthLabels, attributes: [NSAttributedString.Key.font : baseArticleStyle.articlePreviousFont]).height
            transitionsRightImageView.alpha = 1
            transitionsRightLabel.alpha = 1
            transitionsRightButton.alpha = 1
        } else {
            transitionsRightImageView.alpha = 0
            transitionsRightLabel.alpha = 0
            transitionsRightButton.alpha = 0
        }
        transitionsRightLabel.textColor = baseArticleStyle.articleNextColor
        transitionsRightLabel.font = baseArticleStyle.articleNextFont
        transitionsRightLabel.numberOfLines = 0
        transitionsRightLabel.textAlignment = .right
        let widthNext = transitionsRightLabel.text?.size(attributes: [NSAttributedString.Key.font : baseArticleStyle.articleNextFont]).width ?? 0
        transitionsRightLabel.frame.size = CGSize(width: widthNext < maxWidthLabels ? widthNext : maxWidthLabels, height: heightPrevius < maxHeightPrevius ? heightPrevius : maxHeightPrevius)
        transitionsRightLabel.frame.origin = CGPoint(x: transitionsRightImageView.frame.origin.x - baseArticleStyle.nextArticleImageMargin.left - transitionsRightLabel.frame.width, y: baseArticleStyle.articleNextMargin.top)
        if transitionsRightLabel.superview == nil {
            transitionsView.addSubview(transitionsRightLabel)
        }
        transitionsRightButton.setTitle("", for: .normal)
        transitionsRightButton.backgroundColor = .clear
        transitionsRightButton.frame.size = CGSize(width: baseArticleStyle.nextArticleImageMargin.right + baseArticleStyle.nextArticleImageSize.width + baseArticleStyle.articleNextMargin.right + transitionsRightLabel.frame.width, height: maxHeightPrevius)
        transitionsRightButton.frame.origin = CGPoint(x: self.view.frame.width - transitionsRightButton.frame.width, y: baseArticleStyle.nextArticleImageMargin.top)
        if previousOrientation == .landscape {
            if landscapeOrientation != .left {
                transitionsRightButton.frame.origin.x -= safeAreaInsetsLeftOrRight
            }
        }
        if transitionsRightButton.superview == nil {
            transitionsView.addSubview(transitionsRightButton)
        }
        reviewTextView.alpha = 1
        reviewLineSendBottomView.alpha = 1
        reviewSendButton.alpha = 1
        //transitionsView
        var heightTransitionsView = baseArticleStyle.nextArticleImageMargin.top > baseArticleStyle.previousArticleImageMargin.top ? baseArticleStyle.nextArticleImageMargin.top : baseArticleStyle.previousArticleImageMargin.top
        heightTransitionsView += maxHeightNext > maxHeightPrevius ? maxHeightNext : maxHeightPrevius
        if safeAreaInsetsBottom != 0 {
            heightTransitionsView += safeAreaInsetsBottom
        }
        heightTransitionsView += baseArticleStyle.articleNextMargin.bottom > baseArticleStyle.articlePreviousMargin.bottom ? baseArticleStyle.articleNextMargin.bottom : baseArticleStyle.articlePreviousMargin.bottom
        transitionsView.frame.size = CGSize(width: self.view.frame.width, height: heightTransitionsView)
    }
    
    func setWebView() {
        let baseArticleStyle = configurationStyle.baseArticleStyle
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
        webView = WKWebView(frame: CGRect(origin: CGPoint(x: baseArticleStyle.titleBigMargin.left, y: titleView.frame.height), size: CGSize(width: self.view.frame.width - (baseArticleStyle.titleBigMargin.left + baseArticleStyle.titleBigMargin.right), height: 1)), configuration: conf)
        contentView.addSubview(webView)
        webView.navigationDelegate = self
        webView.contentMode = .left
        webView.uiDelegate = self
        let correctoredHtml = HTMLImageCorrector(HTMLString:selectedArticle?.text ?? "")
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
    
    private func setChatButton() {
        guard configurationStyle.baseStyle.isNeedChat else {
            chatButton.alpha = 0
            loaderChatButton.alpha = 0
            return
        }
        let baseStyle = configurationStyle.baseStyle
        let xPointChatButton = self.view.frame.width - baseStyle.chatButtonSize.width - baseStyle.chatButtonMargin.right
        let yPointChatButton = self.view.frame.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom
        chatButton.frame = CGRect(x: xPointChatButton, y: yPointChatButton, width: baseStyle.chatButtonSize.width, height: baseStyle.chatButtonSize.height)
        if previousOrientation == .landscape {
            if landscapeOrientation != .left {
                chatButton.frame.origin.x -= safeAreaInsetsLeftOrRight
            }
        }
        chatButton.addTarget(self, action: #selector(actionChat), for: .touchUpInside)
        chatButton.setImage(baseStyle.chatIconImage, for: .normal)
        chatButton.backgroundColor = baseStyle.chatButtonBackColor
        chatButton.layer.masksToBounds = false
        chatButton.layer.cornerRadius = baseStyle.chatButtonCornerRadius
        chatButton.layer.shadowColor = baseStyle.shadowColor
        chatButton.layer.shadowPath = UIBezierPath(roundedRect: chatButton.bounds, cornerRadius: chatButton.layer.cornerRadius).cgPath
        chatButton.layer.shadowOffset = baseStyle.shadowOffset
        chatButton.layer.shadowOpacity = baseStyle.shadowOpacity
        chatButton.layer.shadowRadius = baseStyle.shadowRadius
        if chatButton.superview == nil {
            self.view.addSubview(chatButton)
        }
        let widthLoader = loaderChatButton.frame.size.width
        let heightLoader = loaderChatButton.frame.size.height
        let xLoader: CGFloat = chatButton.frame.origin.x + (chatButton.frame.width / 2) - (widthLoader / 2)
        let yLoader: CGFloat = chatButton.frame.origin.y + (chatButton.frame.height / 2) - (heightLoader / 2)
        loaderChatButton.frame = CGRect(x: xLoader, y: yLoader, width: widthLoader, height: heightLoader)
        loaderChatButton.alpha = 0
        if loaderChatButton.superview == nil {
            self.view.addSubview(loaderChatButton)
        }
        updatePositionChatButton()
    }
    
    func setReviewView() {
        guard usedesk != nil else {return}
        guard configurationStyle.baseArticleStyle.isNeedReview else {
            reviewView.frame.size = CGSize(width: 0, height: 0)
            reviewView.alpha = 0
            return
        }
        if reviewTextView.text.count > 0 || isSendReviewState {
            if !isSendReviewState {
                showSendedReviewState()
            } else {
                showSendReviewState()
            }
        } else {
            let baseArticleStyle = configurationStyle.baseArticleStyle
            var heightReviewView: CGFloat = 0
            // ReviewTitleLabel
            reviewTitleLabel.numberOfLines = 0
            reviewTitleLabel.textColor = baseArticleStyle.reviewColor
            reviewTitleLabel.font = baseArticleStyle.reviewFont
            reviewTitleLabel.text = usedesk!.model.stringFor("ArticleReviewFirstTitle")
            let widthReviewTitle = self.view.frame.width - (baseArticleStyle.reviewMargin.left + baseArticleStyle.reviewMargin.right)
            let heightReviewTitleText = reviewTitleLabel.text!.size(availableWidth: widthReviewTitle, attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewFont]).height
            reviewTitleLabel.frame = CGRect(x: baseArticleStyle.reviewMargin.left, y: baseArticleStyle.reviewMargin.top, width: widthReviewTitle, height: heightReviewTitleText)
            if previousOrientation == .landscape {
                if landscapeOrientation != .right {
                    reviewTitleLabel.frame.origin.x += safeAreaInsetsLeftOrRight
                }
            }
            if reviewTitleLabel.superview == nil {
                reviewView.addSubview(reviewTitleLabel)
            }
            heightReviewView += reviewTitleLabel.frame.origin.y + reviewTitleLabel.frame.height + baseArticleStyle.reviewYesButtonMargin.top
            // Review Yes No Buttons
            reviewPositivButton.layer.masksToBounds = true
            reviewPositivButton.layer.cornerRadius = baseArticleStyle.reviewYesButtonCornerRadius
            let reviewPositivButtonSize = usedesk!.model.stringFor("Yes").size(attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewYesFont])
            reviewPositivButton.frame = CGRect(x: baseArticleStyle.reviewYesButtonMargin.left, y: heightReviewView, width: reviewPositivButtonSize.width + baseArticleStyle.reviewYesButtonTextMargin.left + baseArticleStyle.reviewYesButtonTextMargin.right, height: reviewPositivButtonSize.height + baseArticleStyle.reviewYesButtonTextMargin.top + baseArticleStyle.reviewYesButtonTextMargin.bottom)
            reviewPositivButton.setTitle(usedesk!.model.stringFor("Yes").uppercased(), for: .normal)
            reviewPositivButton.setTitleColor(baseArticleStyle.reviewYesColor, for: .normal)
            reviewPositivButton.backgroundColor = baseArticleStyle.reviewYesButtonColor
            reviewPositivButton.titleLabel?.font = baseArticleStyle.reviewYesFont
            if previousOrientation == .landscape {
                if landscapeOrientation != .right {
                    reviewPositivButton.frame.origin.x += safeAreaInsetsLeftOrRight
                }
            }
            if reviewPositivButton.superview == nil {
                reviewView.addSubview(reviewPositivButton)
            }
            reviewNegativButton.layer.masksToBounds = true
            reviewNegativButton.layer.cornerRadius = baseArticleStyle.reviewNoButtonCornerRadius
            let reviewNegativButtonSize = usedesk!.model.stringFor("No").size(attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewNoFont])
            var widthReviewNegativButton = reviewNegativButtonSize.width + baseArticleStyle.reviewNoButtonTextMargin.left + baseArticleStyle.reviewNoButtonTextMargin.right
            let maxWidthReviewNegativButton = self.view.frame.width - baseArticleStyle.reviewYesButtonMargin.left - reviewPositivButton.frame.width - baseArticleStyle.reviewNoButtonMargin.left - baseArticleStyle.reviewNoButtonMargin.right
            if widthReviewNegativButton > maxWidthReviewNegativButton {
                widthReviewNegativButton = maxWidthReviewNegativButton
            }
            reviewNegativButton.frame = CGRect(x: baseArticleStyle.reviewYesButtonMargin.left + reviewPositivButton.frame.width + baseArticleStyle.reviewNoButtonMargin.left, y: heightReviewView, width: widthReviewNegativButton, height: reviewNegativButtonSize.height + baseArticleStyle.reviewNoButtonTextMargin.top + baseArticleStyle.reviewNoButtonTextMargin.bottom)
            reviewNegativButton.setTitle(usedesk!.model.stringFor("No").uppercased(), for: .normal)
            reviewNegativButton.setTitleColor(baseArticleStyle.reviewNoColor, for: .normal)
            reviewNegativButton.backgroundColor = baseArticleStyle.reviewNoButtonColor
            reviewNegativButton.titleLabel?.font = baseArticleStyle.reviewNoFont
            if previousOrientation == .landscape {
                if landscapeOrientation != .right {
                    reviewNegativButton.frame.origin.x += safeAreaInsetsLeftOrRight
                }
            }
            if reviewNegativButton.superview == nil {
                reviewView.addSubview(reviewNegativButton)
            }
            reviewPositivButton.alpha = 1
            reviewNegativButton.alpha = 1
            reviewTextView.alpha = 0
            reviewLineSendBottomView.alpha = 0
            reviewSendButton.alpha = 0
            let maxHeightButtons = reviewNegativButton.frame.height > reviewPositivButton.frame.height ? reviewNegativButton.frame.height : reviewPositivButton.frame.height
            heightReviewView += maxHeightButtons + baseArticleStyle.reviewYesButtonMargin.bottom
            reviewView.frame.size = CGSize(width: self.view.frame.width, height: heightReviewView)

            if webView != nil {
                contentViewHC.constant = titleView.frame.height + webView.frame.height + reviewView.frame.height +  transitionsView.frame.height
                if contentViewHC.constant < scrollView.frame.height {
                    contentViewHC.constant = scrollView.frame.height
                }
                transitionsView.frame.origin = CGPoint(x: 0, y: contentViewHC.constant - transitionsView.frame.height)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func showSendReviewState() {
        guard usedesk != nil else {return}
        isSendReviewState = true
        reviewNegativButton.removeFromSuperview()
        reviewPositivButton.removeFromSuperview()
        // Title
        reviewTitleLabel.text = usedesk!.model.stringFor("ArticleReviewSendTitle")
        let baseArticleStyle = configurationStyle.baseArticleStyle
        let widthReviewTitle = self.view.frame.width - (baseArticleStyle.reviewMargin.left + baseArticleStyle.reviewMargin.right)
        let heightReviewTitleText = reviewTitleLabel.text!.size(availableWidth: widthReviewTitle, attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewFont]).height
        reviewTitleLabel.frame = CGRect(x: baseArticleStyle.reviewMargin.left, y: baseArticleStyle.reviewMargin.top, width: widthReviewTitle, height: heightReviewTitleText)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                reviewTitleLabel.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        var heightReviewView = reviewTitleLabel.frame.origin.y + reviewTitleLabel.frame.height + baseArticleStyle.reviewSendTextMargin.top
        // Text View
        reviewTextView.delegate = self
        reviewTextView.layer.borderWidth = 0
        reviewTextView.font = baseArticleStyle.reviewSendTextFont
        reviewTextView.textColor = baseArticleStyle.reviewSendTextColor
        var heightReviewTextView: CGFloat = 0
        if reviewTextView.text.count == 0 {
            reviewTextView.text = "Tept"
            if reviewTextView.superview == nil {
                reviewView.addSubview(reviewTextView)
            }
            self.view.layoutIfNeeded()
            heightReviewTextView = reviewTextView.contentSize.height
            reviewTextView.text = ""
        } else {
            heightReviewTextView = reviewTextView.contentSize.height
        }
        let widthReviewTextView = self.view.frame.width - (baseArticleStyle.reviewSendTextMargin.left + baseArticleStyle.reviewSendTextMargin.right)
        reviewTextView.frame = CGRect(x: baseArticleStyle.reviewSendTextMargin.left, y: heightReviewView, width: widthReviewTextView, height: heightReviewTextView)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                reviewTextView.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        heightReviewView += reviewTextView.frame.height + baseArticleStyle.reviewLineMarginTop
        // Line
        reviewLineSendBottomView.frame = CGRect(x: baseArticleStyle.reviewSendTextMargin.left, y: heightReviewView, width: widthReviewTextView, height: baseArticleStyle.reviewLineHeight)
        reviewLineSendBottomView.backgroundColor = baseArticleStyle.reviewLineBottomColor
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                reviewLineSendBottomView.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        if reviewLineSendBottomView.superview == nil {
            reviewView.addSubview(reviewLineSendBottomView)
        }
        heightReviewView += baseArticleStyle.reviewLineHeight + baseArticleStyle.reviewSendButtonMargin.top
        // Send button
        let reviewSendButtonSize = usedesk!.model.stringFor("Send").size(attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewSendFont])
        var widthReviewSendButtonSize = reviewSendButtonSize.width + baseArticleStyle.reviewSendButtonTextMargin.left + baseArticleStyle.reviewSendButtonTextMargin.right
        let maxWidthReviewSendButton = self.view.frame.width - baseArticleStyle.reviewSendButtonMargin.left - baseArticleStyle.reviewSendButtonMargin.right
        if widthReviewSendButtonSize > maxWidthReviewSendButton {
            widthReviewSendButtonSize = maxWidthReviewSendButton
        }
        reviewSendButton.frame = CGRect(x: baseArticleStyle.reviewSendButtonMargin.left, y: heightReviewView, width: widthReviewSendButtonSize, height: reviewSendButtonSize.height + baseArticleStyle.reviewSendButtonTextMargin.top + baseArticleStyle.reviewSendButtonTextMargin.bottom)
        reviewSendButton.setTitle(usedesk!.model.stringFor("Send").uppercased(), for: .normal)
        reviewSendButton.setTitleColor(baseArticleStyle.reviewSendTextColor, for: .normal)
        reviewSendButton.backgroundColor = baseArticleStyle.reviewSendButtonColor
        reviewSendButton.titleLabel?.font = baseArticleStyle.reviewSendFont
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                reviewSendButton.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        if reviewSendButton.superview == nil {
            reviewView.addSubview(reviewSendButton)
        }
        reviewTextView.alpha = 1
        reviewLineSendBottomView.alpha = 1
        reviewSendButton.alpha = 1
        heightReviewView += reviewSendButton.frame.height + baseArticleStyle.reviewSendButtonMargin.bottom
        reviewView.frame.origin = CGPoint(x: reviewView.frame.origin.x, y: reviewView.frame.origin.y)
        reviewView.frame.size = CGSize(width: reviewView.frame.width, height: heightReviewView)
        contentViewHC.constant = titleView.frame.height + heightWebView + heightReviewView + transitionsView.frame.height
        transitionsView.frame.origin = CGPoint(x: 0, y: contentViewHC.constant - transitionsView.frame.height)
        self.view.layoutIfNeeded()
    }
    
    func showSendedReviewState() {
        guard usedesk != nil else {return}
        reviewPositivButton.removeFromSuperview()
        reviewNegativButton.removeFromSuperview()
        isSendReviewState = false
        reviewTitleLabel.text = usedesk!.model.stringFor("ArticleReviewSendedTitle")
        let baseArticleStyle = configurationStyle.baseArticleStyle
        let widthReviewTitle = view.frame.width - (baseArticleStyle.reviewMargin.left + baseArticleStyle.reviewMargin.right)
        let heightReviewTitleText = reviewTitleLabel.text!.size(availableWidth: widthReviewTitle, attributes: [NSAttributedString.Key.font : baseArticleStyle.reviewFont]).height
        reviewTitleLabel.frame = CGRect(x: baseArticleStyle.reviewMargin.left, y: baseArticleStyle.reviewMargin.top, width: widthReviewTitle, height: heightReviewTitleText)
        if previousOrientation == .landscape {
            if landscapeOrientation != .right {
                reviewTitleLabel.frame.origin.x += safeAreaInsetsLeftOrRight
            }
        }
        reviewTextView.alpha = 0
        reviewLineSendBottomView.alpha = 0
        reviewSendButton.alpha = 0
    }
    
    private func updatePositionChatButton() {
        guard configurationStyle.baseStyle.isNeedChat else { return }
        let baseStyle = configurationStyle.baseStyle
        if scrollView.frame.height >= scrollView.contentSize.height {
            chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: self.view.frame.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom - transitionsView.frame.height)
            loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
        } else {
            let differentHeight = scrollView.contentSize.height - scrollView.frame.height
            if scrollView.contentOffset.y > differentHeight - transitionsView.frame.height {
                chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: self.view.frame.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom - (scrollView.contentOffset.y - (differentHeight - transitionsView.frame.height)))
                loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
            } else {
                chatButton.frame.origin = CGPoint(x: chatButton.frame.origin.x, y: self.view.frame.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom)
                loaderChatButton.frame.origin = CGPoint(x: loaderChatButton.frame.origin.x, y: chatButton.frame.origin.y + (chatButton.frame.height / 2) - (loaderChatButton.frame.height / 2))
            }
        }
    }
    
    func updateVisibleSmallTitleLabel() {
        let coefficient = 100 / titleView.frame.height
        var procent = coefficient * scrollView.contentOffset.y
        if procent > 100 {
            procent = 100
        }
        titleLabel.alpha = procent / 100
        topSeparatorView.alpha = procent / 100
    }
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let baseArticleStyle = configurationStyle.baseArticleStyle
        var heightContentBeforeLine = reviewTitleLabel.frame.origin.y + reviewTitleLabel.frame.height + baseArticleStyle.reviewSendTextMargin.top
        heightContentBeforeLine += reviewTextView.contentSize.height + baseArticleStyle.reviewLineMarginTop
        let heightContent = heightContentBeforeLine + baseArticleStyle.reviewLineHeight + baseArticleStyle.reviewSendButtonMargin.top + reviewSendButton.frame.height + baseArticleStyle.reviewSendButtonMargin.bottom
        reviewTextView.frame.size = CGSize(width: reviewTextView.frame.width, height: reviewTextView.contentSize.height)
        reviewLineSendBottomView.frame.origin = CGPoint(x: reviewLineSendBottomView.frame.origin.x, y: heightContentBeforeLine)
        reviewSendButton.frame.origin = CGPoint(x: reviewSendButton.frame.origin.x, y: heightContentBeforeLine + baseArticleStyle.reviewLineHeight + baseArticleStyle.reviewSendButtonMargin.top)
        if heightContent > reviewView.frame.height {
            webView.frame.origin = CGPoint(x: webView.frame.origin.x, y: webView.frame.origin.y - (heightContent - reviewView.frame.height))
            titleView.frame.origin = CGPoint(x: 0, y: titleView.frame.origin.y - (heightContent - reviewView.frame.height))
            reviewView.frame.origin = CGPoint(x: reviewView.frame.origin.x, y: reviewView.frame.origin.y - (heightContent - reviewView.frame.height))
            reviewView.frame.size = CGSize(width: reviewView.frame.width, height: heightContent)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
    // MARK: - User actions
    @objc func reviewPositivButtonDidTap() {
        guard selectedArticle != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: selectedArticle!.id, countPositiv: 1, countNegativ: 0) { [weak self] (success) in
            guard let wSelf = self else {return}
            if success {
                wSelf.showSendedReviewState()
                wSelf.reviewTextView.becomeFirstResponder()
            }
        } errorStatus: { error, des in
        }
    }
    
    @objc func reviewNegativButtonDidTap() {
        guard selectedArticle != nil && usedesk != nil else {return}
        usedesk!.addReviewArticle(articleID: selectedArticle!.id, countPositiv: 0, countNegativ: 1) { [weak self] (success) in
            guard let wSelf = self else {return}
            if success {
                wSelf.showSendReviewState()
                wSelf.reviewTextView.becomeFirstResponder()
            }
        } errorStatus: { _, _ in}
    }
    
    @objc func reviewNegativSendMessageButtonDidTap() {
        if reviewTextView.text.count > 0 {
            dismissKeyboard()
            guard selectedArticle != nil && usedesk != nil && reviewTextView.text?.count ?? -1 > 0 else {return}
            usedesk!.sendReviewArticleMesssage(articleID: selectedArticle!.id, message: reviewTextView.text!) { [weak self] (success) in
                guard let wSelf = self else {return}
                if success {
                    wSelf.showSendedReviewState()
                }
            } errorStatus: { _, _ in}
        }
    }
    
    @objc func openPreviusArticle() {
        if indexSelectedArticle > 0 && articles.count > (indexSelectedArticle - 1) {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
            usedesk?.getArticle(articleID: articles[indexSelectedArticle - 1].id, connectionStatus: { [weak self] success, article in
                guard let wSelf = self else {return}
                if success {
                    wSelf.selectedArticle = article
                    wSelf.indexSelectedArticle = wSelf.indexSelectedArticle - 1
                    wSelf.titleLabel.text = article?.title
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let wSelf = self else {return}
                        wSelf.reviewTextView.text = ""
                        wSelf.setViews()
                        wSelf.scrollView.contentOffset.y = UIScreen.main.bounds.height < UIScreen.main.bounds.width ? wSelf.titleView.frame.height : 0
                    })
                } else {
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                }
            }, errorStatus: { [weak self] _, _ in
                guard let wSelf = self else {return}
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
            })
        }
    }
    
    @objc func openNextArticle() {
        if articles.count > indexSelectedArticle + 1 {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
            usedesk?.getArticle(articleID: articles[indexSelectedArticle + 1].id, connectionStatus: { [weak self] success, article in
                guard let wSelf = self else {return}
                if success {
                    wSelf.selectedArticle = article
                    wSelf.indexSelectedArticle = wSelf.indexSelectedArticle + 1
                    wSelf.titleLabel.text = article?.title
                    DispatchQueue.main.async(execute: { [weak self] in
                        guard let wSelf = self else {return}
                        wSelf.reviewTextView.text = ""
                        wSelf.setViews()
                        wSelf.scrollView.contentOffset.y = UIScreen.main.bounds.height < UIScreen.main.bounds.width ? wSelf.titleView.frame.height : 0
                    })
                } else {
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                }
            }, errorStatus: { [weak self] _, _ in
                guard let wSelf = self else {return}
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
            })
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
        self.removeFromParent()
    }
    
    @objc func actionChat() {
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.chatButton.setImage(nil, for: .normal)
            self.loaderChatButton.alpha = 1
            self.loaderChatButton.startAnimating()
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.model.companyID, chanelId: usedesk!.model.chanelId, knowledgeBaseID: usedesk!.model.knowledgeBaseID, api_token: usedesk!.model.api_token, email: usedesk!.model.email, url: usedesk!.model.urlWithoutPort, port: usedesk!.model.port, name: usedesk!.model.name, operatorName: usedesk!.model.operatorName, nameChat: usedesk!.model.nameChat, token: usedesk!.model.token, connectionStatus: { [weak self] success, feedbackStatus, token in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureStartBlock != nil {
                wSelf.usedesk!.closureStartBlock!(success, feedbackStatus, token)
            }
            if success && feedbackStatus.isNotOpenFeedbackForm {
                DispatchQueue.main.async(execute: {
                    wSelf.delegate?.openChat()
                    wSelf.dismiss(animated: true)
                })
            } else if feedbackStatus.isOpenFeedbackForm {
                wSelf.delegate?.openOfflineForm()
                wSelf.dismiss(animated: true)
            }
            UIView.animate(withDuration: 0.3) {
                wSelf.chatButton.setImage(wSelf.configurationStyle.baseStyle.chatIconImage, for: .normal)
                wSelf.loaderChatButton.alpha = 0
                wSelf.loaderChatButton.stopAnimating()
            }
        }, errorStatus: {  [weak self] error, description  in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureErrorBlock != nil {
                wSelf.usedesk!.closureErrorBlock!(error, description)
            }
        })
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
        let baseArticleStyle = configurationStyle.baseArticleStyle
        webView.evaluateJavaScript("document.readyState", completionHandler: { result, error in
         if result == nil || error != nil {
             return
         }
         webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { [weak self] result, error in
            guard let wSelf = self else {return}
            if let height = result as? CGFloat {
                wSelf.heightWebView = height + 24
                wSelf.webView.frame.size = CGSize(width: wSelf.webView.frame.width, height: wSelf.heightWebView)
                
                wSelf.contentViewHC.constant = wSelf.titleView.frame.height + wSelf.webView.frame.height + wSelf.reviewView.frame.height + wSelf.transitionsView.frame.height
                if wSelf.contentViewHC.constant > wSelf.view.frame.height - wSelf.topView.frame.height {
                    wSelf.webView.scrollView.isScrollEnabled = true
                } else {
                    wSelf.webView.scrollView.isScrollEnabled = false
                    wSelf.contentViewHC.constant = wSelf.view.frame.height - wSelf.topView.frame.height
                }
                wSelf.titleView.frame.origin = CGPoint(x: 0, y: 0)
                wSelf.webView.frame.origin = CGPoint(x: baseArticleStyle.titleBigMargin.left, y: wSelf.titleView.frame.height)
                wSelf.reviewView.frame.origin = CGPoint(x: 0, y: wSelf.titleView.frame.height + wSelf.webView.frame.height)
                wSelf.transitionsView.frame.origin = CGPoint(x: 0, y: wSelf.contentViewHC.constant - wSelf.transitionsView.frame.height)
                if wSelf.reviewView.superview == nil {
                    wSelf.contentView.addSubview(wSelf.titleView)
                    wSelf.contentView.addSubview(wSelf.reviewView)
                    wSelf.contentView.addSubview(wSelf.transitionsView)
                }
                wSelf.view.layoutIfNeeded()
                wSelf.updatePositionChatButton()
            }
         })
        })
    }
}
