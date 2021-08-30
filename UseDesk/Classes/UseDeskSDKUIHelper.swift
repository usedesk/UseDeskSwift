//
//  File.swift
//  
//
//  Created by Leonid Liadveikin on 27.08.2021.
//

import Foundation
import UIKit

class UseDeskSDKUIHelper: SDKUIHelper {
    var loader: UDLoader?
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

    func showLoader() {
        loader?.show()
    }

    func hideLoader() {
        loader?.hide(animated: true)
    }

    func showBaseView(in parentController: UIViewController?, url: String?) {
        let parentController = parentController ?? RootView
        loader = UDLoader(view: parentController?.view ?? UIView(), colorBackView: configurationStyle.chatStyle.backgroundColorLoaderView, alphaBackView: configurationStyle.chatStyle.alphaLoaderView)
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

    func startDialogFlow(success: Bool, error: String?, url: String, in parentController: UIViewController?) {
        let parentController = parentController ?? RootView
        loader = UDLoader(view: parentController?.view ?? UIView(), colorBackView: configurationStyle.chatStyle.backgroundColorLoaderView, alphaBackView: configurationStyle.chatStyle.alphaLoaderView)
        if success {
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
        } else {
            if error == "feedback_form" || error == "feedback_form_and_chat" {
                if offlineVC.presentingViewController == nil {
                    dialogflowVC.dismiss(animated: true)
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
                hideLoader()
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
        let uiHelper = UseDeskSDKUIHelper()
        self.uiHelper = uiHelper
        uiHelper.useDesk = self
    }
}
