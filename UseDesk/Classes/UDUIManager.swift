//
//  UDUIManager.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import UIKit

class UDUIManager: UDUIProtocole {
    var navController = UDNavigationController()
    private var dialogflowVC: DialogflowView = DialogflowView()
    private var offlineVC: UDOfflineForm = UDOfflineForm()

    let RootView = UIApplication.shared.keyWindow?.rootViewController
    var configurationStyle: ConfigurationStyle {
        useDesk?.configurationStyle ?? ConfigurationStyle()
    }

    weak var useDesk: UseDeskSDK?

    func resetUI() {
        dialogflowVC = DialogflowView()
        offlineVC = UDOfflineForm()
    }

    func showBaseView(in parentController: UIViewController?, url: String?) {
        let parentController = parentController ?? RootView
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
    
    func startDialogFlow(in parentController: UIViewController?) {
        let parentController = parentController ?? RootView
        dialogflowVC.usedesk = useDesk
        if navController.presentingViewController == nil {
            navController = UDNavigationController(rootViewController: dialogflowVC)
            navController.configurationStyle = configurationStyle
            navController.setProperties()
            navController.setTitleTextAttributes()
            navController.modalPresentationStyle = .fullScreen
            parentController?.present(navController, animated: true)
        } else {
            dialogflowVC.reloadHistory()
        }
    }
    
    func reloadDialogFlow(success: Bool, error: String?, url: String, in parentController: UIViewController?) {
        let parentController = parentController ?? RootView
        if success {
            dialogflowVC.usedesk = useDesk
            dialogflowVC.reloadHistory()
        } else {
            if error == "feedback_form" || error == "feedback_form_and_chat" {
                if offlineVC.presentingViewController == nil {
                    dialogflowVC.actionDone()
                    offlineVC = UDOfflineForm()
                    offlineVC.url = url
                    offlineVC.usedesk = useDesk
                    navController = UDNavigationController(rootViewController: offlineVC)
                    navController.configurationStyle = configurationStyle
                    navController.setProperties()
                    navController.setTitleTextAttributes()
                    navController.modalPresentationStyle = .fullScreen
                    parentController?.present(navController, animated: true)
                }
            }
        }
    }

    func pushViewController(_ viewController: UIViewController) {
        navController.pushViewController(viewController, animated: true)
    }

    func dismiss() {
        navController.dismiss(animated: true, completion: nil)
    }
}

extension UseDeskSDK {
    func setupUI() {
        let uiManager = UDUIManager()
        self.uiManager = uiManager
        uiManager.useDesk = self
    }
}
