//
//  UDUIManager.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import UIKit

class UDUIManager: UDUIProtocole {
    private var navController = UDNavigationController()
    private var dialogflowVC: DialogflowView? = nil
    private var offlineVC: UDOfflineForm = UDOfflineForm()
    private var networkVC = UDNoInternetVC()
    
    let RootView = UIApplication.shared.keyWindow?.rootViewController
    var configurationStyle: ConfigurationStyle {
        useDesk?.configurationStyle ?? ConfigurationStyle()
    }

    weak var useDesk: UseDeskSDK?

    func resetUI() {
        dialogflowVC = nil
        offlineVC = UDOfflineForm()
    }
    
    func showNoInternet() {
        if let dialogVC = navController.visibleViewController as? DialogflowView {
            dialogVC.showNoInternet()
        } else if let baseSectionsVC = navController.visibleViewController as? UDBaseSectionsView {
            baseSectionsVC.showNoInternet()
        }
    }
    
    func closeNoInternet() {
        if let dialogVC = navController.visibleViewController as? DialogflowView {
            dialogVC.closeNoInternet()
        } else if let baseSectionsVC = navController.visibleViewController as? UDBaseSectionsView {
            if baseSectionsVC.isLoaded() {
                baseSectionsVC.closeNoInternet()
            }
        }
    }

    func showBaseView(in parentControllerOptional: UIViewController?, url: String?) {
        let parentController = parentControllerOptional ?? RootView
        let baseView = UDBaseSectionsView()
        baseView.usedesk = useDesk
        baseView.url = url
        navController = UDNavigationController(rootViewController: baseView)
        navController.configurationStyle = configurationStyle
        navController.setProperties()
        navController.setTitleTextAttributes()
        navController.modalPresentationStyle = .fullScreen
        parentController?.present(navController, animated: true) 
    }
    
    func startDialogFlow(in parentControllerOptional: UIViewController?) {
        let parentController = parentControllerOptional ?? RootView
        dialogflowVC = DialogflowView()
        dialogflowVC!.usedesk = useDesk
        if navController.presentingViewController == nil {
            navController = UDNavigationController(rootViewController: dialogflowVC!)
            navController.configurationStyle = configurationStyle
            navController.setProperties()
            navController.setTitleTextAttributes()
            navController.modalPresentationStyle = .fullScreen
            parentController?.present(navController, animated: true)
        } else {
            dialogflowVC!.updateChat()
        }
    }
    
    func reloadDialogFlow(success: Bool, feedBackStatus: UDFeedbackStatus, url: String) { 
        if success {
            dialogflowVC?.usedesk = useDesk
            dialogflowVC?.reloadHistory()
        } else {
            if feedBackStatus == .feedbackForm || feedBackStatus == .feedbackFormAndChat {
                if offlineVC.presentingViewController == nil {
                    offlineVC = UDOfflineForm()
                    offlineVC.url = url
                    offlineVC.usedesk = useDesk
                    pushViewController(offlineVC)
                    dialogflowVC?.closeVC()
                    dialogflowVC = DialogflowView()
                }
            }
        }
    }

    func pushViewController(_ viewController: UIViewController) {
        if navController.visibleViewController != viewController {
            navController.pushViewController(viewController, animated: true)
        }
    }

    func dismiss() {
        navController.dismiss(animated: true, completion: nil)
    }
    
    func chatViewController() -> UIViewController? {
        guard useDesk != nil else {return nil}
        if dialogflowVC == nil {
            dialogflowVC = DialogflowView()
            dialogflowVC?.usedesk = useDesk
        }
        dialogflowVC?.view.layoutSubviews()
        return dialogflowVC
    }
    
    func visibleViewController() -> UIViewController? {
        return navController.visibleViewController
    }
}

extension UseDeskSDK {
    func setupUI() {
        let uiManager = UDUIManager()
        self.uiManager = uiManager
        uiManager.useDesk = self
    }
}
