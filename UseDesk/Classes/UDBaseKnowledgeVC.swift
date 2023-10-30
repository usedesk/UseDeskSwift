//
//  UDBaseKnowledgeVC.swift

import Foundation
import UIKit

class UDBaseKnowledgeVC: UIViewController {
    @IBOutlet weak var topNavigateView: UIView!
    
    @IBOutlet weak var errorLoadView: UIView!
    @IBOutlet weak var errorLoadImageView: UIImageView!
    @IBOutlet weak var errorLoadImageViewAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var errorLoadImageViewCenterYC: NSLayoutConstraint!
    @IBOutlet weak var errorLoadImageViewTC: NSLayoutConstraint!
    @IBOutlet weak var errorLoadImageViewLC: NSLayoutConstraint!
    @IBOutlet weak var errorLoadLabel: UILabel!
    
    weak var usedesk: UseDeskSDK?
    
    var isFirstLoaded = true
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var baseStyle: BaseStyle = BaseStyle()
    var previousOrientation: Orientation = .portrait
    var landscapeOrientation: LandscapeOrientation? = nil
    var safeAreaInsets: UIEdgeInsets = .zero
    
    var isCanShowNoInternet = true
    var isShownNoInternet = false
    var isEnabledInternet = true
    
    var chatButton = UIButton()
    var loaderChatButton = UIActivityIndicatorView(style: .white)
    
    var noInternetVC: UDNoInternetVC? = nil
    var offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        setChatButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoaded {
            setChatButton()
            isFirstLoaded = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width  {
            safeAreaInsetsLeftOrRight = 0
            if previousOrientation != .portrait {
                previousOrientation = .portrait
                updateViewsBeforeChangeOrientationWindow()
            }
        } else {
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
            if previousOrientation != .landscape {
                previousOrientation = .landscape
                updateViewsBeforeChangeOrientationWindow()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    func firstState() {
        guard errorLoadImageView != nil else {return}
        let baseStyle = configurationStyle.baseStyle
        errorLoadImageView.image = baseStyle.errorLoadImage
        errorLoadLabel.text = usedesk?.model.stringFor("ErrorLoading")
        errorLoadView.backgroundColor = configurationStyle.baseStyle.backgroundColor
        errorLoadImageViewCenterYC = errorLoadImageViewCenterYC.constraintWithMultiplier(baseStyle.errorLoadImageCenterYMultiplier)
        errorLoadImageViewAspectRatio = errorLoadImageViewAspectRatio.constraintWithMultiplier(baseStyle.errorLoadImageAspectRatioMultiplier)
        errorLoadImageViewTC.constant = baseStyle.errorLoadImageMargin.right
        errorLoadImageViewLC.constant = baseStyle.errorLoadImageMargin.left
        errorLoadLabel.font = baseStyle.errorLoadTextFont
        errorLoadLabel.textColor = baseStyle.errorLoadTextColor
        self.view.layoutIfNeeded()
    }
    
    func updateViewsBeforeChangeOrientationWindow() {
    }
    
    func setChatButton() {
        guard configurationStyle.baseStyle.isNeedChat && !(usedesk?.model.isOnlyKnowledgeBase ?? false) && (usedesk?.model.isPresentDefaultControllers ?? false) else {
            chatButton.alpha = 0
            loaderChatButton.alpha = 0
            return
        }
        let xPointChatButton = UIScreen.main.bounds.width - baseStyle.chatButtonSize.width - baseStyle.chatButtonMargin.right
        let yPointChatButton = UIScreen.main.bounds.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom
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
        chatButton.layer.shadowColor = baseStyle.chatButtonShadowColor
        chatButton.layer.shadowPath = UIBezierPath(roundedRect: chatButton.bounds, cornerRadius: chatButton.layer.cornerRadius).cgPath
        chatButton.layer.shadowOffset = baseStyle.chatButtonShadowOffset
        chatButton.layer.shadowOpacity = baseStyle.chatButtonShadowOpacity
        chatButton.layer.shadowRadius = baseStyle.chatButtonShadowRadius
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
    }
    
    @objc func actionChat() {
        guard usedesk?.reachability != nil else {return}
        guard usedesk?.reachability?.connection != .unavailable else {
            showAlertNoInternet()
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.chatButton.setImage(nil, for: .normal)
            self.loaderChatButton.alpha = 1
            self.loaderChatButton.startAnimating()
        }
        usedesk?.startWithoutGUICompanyID(companyID: usedesk!.model.companyID, chanelId: usedesk!.model.chanelId, url: usedesk!.model.urlWithoutPort, port: usedesk!.model.port, api_token: usedesk!.model.api_token, knowledgeBaseID: usedesk!.model.knowledgeBaseID, name: usedesk!.model.name, email: usedesk!.model.email, phone: usedesk!.model.phone, token: usedesk!.model.token, connectionStatus: { [weak self] success, feedbackStatus, token in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            wSelf.usedesk?.storage = wSelf.usedesk?.storage != nil ? wSelf.usedesk?.storage : UDStorageMessages(token: token)
            if wSelf.usedesk!.closureStartBlock != nil {
                wSelf.usedesk!.closureStartBlock!(success, feedbackStatus, token)
            }
            if success && feedbackStatus.isNotOpenFeedbackForm {
                DispatchQueue.main.async(execute: {
                    wSelf.usedesk?.uiManager?.startDialogFlow(in: self, isFromBase: true)
                })
            } else if feedbackStatus.isOpenFeedbackForm {
                if wSelf.navigationController?.visibleViewController != wSelf.offlineVC {
                    wSelf.offlineVC = UDOfflineForm()
                    wSelf.offlineVC.usedesk = wSelf.usedesk
                    wSelf.offlineVC.isFromBase = true
                    wSelf.usedesk?.uiManager?.pushViewController(wSelf.offlineVC)
                }
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
    
    func backAction() {
        self.dismiss(animated: true, completion: nil)
        usedesk?.isOpenSDKUI = false
    }
    
    public func isLoaded() -> Bool {
        return !isFirstLoaded
    }
    
    // MARK: - No Internet
    func showNoInternet() {
        isEnabledInternet = false
        guard isCanShowNoInternet && !(usedesk?.model.isLoadedKnowledgeBase ?? false) else {return}
        isShownNoInternet = true
        noInternetVC = UDNoInternetVC()
        noInternetVC!.usedesk = usedesk
        if usedesk?.model.isPresentDefaultControllers ?? true {
            self.addChild(self.noInternetVC!)
            self.view.addSubview(self.noInternetVC!.view)
        } else {
            noInternetVC!.modalPresentationStyle = .fullScreen
            self.present(noInternetVC!, animated: false, completion: nil)
        }
        var width: CGFloat = self.view.frame.width
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            width += safeAreaInsetsLeftOrRight * 2
        }
        noInternetVC!.view.frame = CGRect(x:0, y: topNavigateView.frame.height, width: width, height: self.view.frame.height - topNavigateView.frame.height)
        noInternetVC!.setViews()
        chatButton.alpha = 0
    }
    
    func closeNoInternet() {
        isEnabledInternet = true
        guard isCanShowNoInternet, noInternetVC != nil else {return}
        isShownNoInternet = false
        firstState()
        chatButton.alpha = 1
        if usedesk?.model.isPresentDefaultControllers ?? true {
            noInternetVC!.removeFromParent()
            noInternetVC!.view.removeFromSuperview()
        } else {
            noInternetVC!.dismiss(animated: false, completion: nil)
        }
        isCanShowNoInternet = false
    }
    
    func showAlertNoInternet() {
        let alert = UIAlertController(title: usedesk?.model.stringFor("NotInternet") ?? "Error", message: usedesk?.model.stringFor("NotInternetCheck") ?? "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: usedesk?.model.stringFor("Ok") ?? "OK", style: .default) { _ in}
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK: - No Internet
    func showErrorLoadView(withAnimate: Bool = false) {
        guard errorLoadView.alpha != 1 else {return}
        if withAnimate {
            UIView.animate(withDuration: 0.3) {
                self.errorLoadView.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            errorLoadView.alpha = 1
        }
    }
    
    func hideErrorLoadView(withAnimate: Bool = false) {
        guard errorLoadView.alpha != 0 else {return}
        if withAnimate {
            UIView.animate(withDuration: 0.3) {
                self.errorLoadView.alpha = 0
                self.view.layoutIfNeeded()
            }
        } else {
            errorLoadView.alpha = 0
        }
    }
}
