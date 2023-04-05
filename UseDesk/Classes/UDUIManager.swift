//
//  UDUIManager.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import UIKit

class UDUIManager: UDUIProtocole {
    private var navController: UDNavigationController?
    private var dialogflowVC: DialogflowView? = nil
    private var offlineVC: UDOfflineForm = UDOfflineForm()
    private var baseSectionsVC: UDBaseSectionsView? = nil
    private var baseCategoriesVC: UDBaseCategoriesView? = nil
    private var baseArticlesVC: UDBaseArticlesView? = nil
    private var baseArticleVC: UDBaseArticleView? = nil
    private var networkVC = UDNoInternetVC()
    
    let RootView = UIApplication.shared.keyWindow?.rootViewController
    var configurationStyle: ConfigurationStyle {
        usedesk?.configurationStyle ?? ConfigurationStyle()
    }

    weak var usedesk: UseDeskSDK?

    func resetUI() {
        dialogflowVC = nil
        baseSectionsVC = nil
        baseCategoriesVC = nil
        baseArticlesVC = nil
        baseArticleVC = nil
        offlineVC = UDOfflineForm()
    }
    
    func showNoInternet() {
        if let dialogVC = navController?.visibleViewController as? DialogflowView {
            dialogVC.showNoInternet()
        } else if let baseKnowledgeVC = navController?.visibleViewController as? UDBaseKnowledgeVC {
            baseKnowledgeVC.showNoInternet()
        }
    }
    
    func closeNoInternet() {
        if let dialogVC = navController?.visibleViewController as? DialogflowView {
            dialogVC.closeNoInternet()
        } else if let baseKnowledgeVC = navController?.visibleViewController as? UDBaseKnowledgeVC {
            if baseKnowledgeVC.isLoaded() {
                baseKnowledgeVC.closeNoInternet()
            }
        }
    }

    func startBaseFlow(in parentControllerOptional: UIViewController?) {
        guard usedesk != nil else {return}
        let model = usedesk?.model ?? UseDeskModel()
        let parentController = parentControllerOptional ?? RootView
        baseSectionsVC = UDBaseSectionsView()
        baseSectionsVC?.usedesk = usedesk
        var openVC: UIViewController? = nil
        if model.isReturnToParentFromKnowledgeBase {
            if model.knowledgeBaseArticleId > 0 {
                baseArticleVC = UDBaseArticleView()
                baseArticleVC?.usedesk = usedesk
                let article = UDArticle(id: model.knowledgeBaseArticleId, title: "")
                baseArticleVC?.article = article
                navController = UDNavigationController(rootViewController: baseArticleVC ?? UIViewController())
            } else if model.knowledgeBaseCategoryId > 0 {
                baseArticlesVC = UDBaseArticlesView()
                baseArticlesVC?.usedesk = usedesk
                navController = UDNavigationController(rootViewController: baseArticlesVC ?? UIViewController())
            } else if model.knowledgeBaseSectionId > 0 {
                baseCategoriesVC = UDBaseCategoriesView()
                baseCategoriesVC?.usedesk = usedesk
                baseCategoriesVC?.view.layoutIfNeeded()
                navController = UDNavigationController(rootViewController: baseCategoriesVC ?? UIViewController())
            } else {
                navController = UDNavigationController(rootViewController: baseSectionsVC ?? UIViewController())
            }
        } else {
            navController = UDNavigationController(rootViewController: baseSectionsVC ?? UIViewController())
            if model.knowledgeBaseSectionId > 0 || model.knowledgeBaseCategoryId > 0 || model.knowledgeBaseArticleId > 0 {
                baseCategoriesVC = UDBaseCategoriesView()
                baseCategoriesVC?.usedesk = usedesk
                baseCategoriesVC?.view.layoutIfNeeded()
                navController!.viewControllers.append(baseCategoriesVC ?? UIViewController())
                openVC = baseCategoriesVC
            }
            if model.knowledgeBaseCategoryId > 0 || model.knowledgeBaseArticleId > 0 {
                baseArticlesVC = UDBaseArticlesView()
                baseArticlesVC?.usedesk = usedesk
                navController!.viewControllers.append(baseArticlesVC ?? UIViewController())
                openVC = baseArticlesVC
            }
            if model.knowledgeBaseArticleId > 0 {
                baseArticleVC = UDBaseArticleView()
                baseArticleVC?.usedesk = usedesk
                let article = UDArticle(id: model.knowledgeBaseArticleId, title: "")
                baseArticleVC?.article = article
                navController!.viewControllers.append(baseArticleVC ?? UIViewController())
                openVC = baseArticleVC
            }
        }
        if openVC != nil {
            navController!.popToViewController(openVC!, animated: false)
        }
        navController!.configurationStyle = configurationStyle
        navController!.setProperties()
        navController!.setTitleTextAttributes()
        navController!.modalPresentationStyle = .fullScreen
        navController!.isNavigationBarHidden = true
        parentController?.present(navController!, animated: true)
    }
    
    func reloadBaseFlow(success: Bool) {
        if success {
            guard usedesk != nil else {return}
            baseSectionsVC?.usedesk = usedesk
            baseCategoriesVC?.usedesk = usedesk
            baseArticlesVC?.usedesk = usedesk
            baseArticleVC?.usedesk = usedesk
            baseSectionsVC?.updateValues()
            baseCategoriesVC?.updateValues()
            baseArticlesVC?.updateValues()
            if baseArticleVC?.isLoaded() ?? false {
                baseArticleVC?.hideErrorLoadView()
            }
            if baseArticlesVC?.isLoaded() ?? false {
                baseArticlesVC?.updateViews()
                baseArticlesVC?.hideErrorLoadView()
            }
            if baseCategoriesVC?.isLoaded() ?? false {
                baseCategoriesVC?.updateViews()
                baseCategoriesVC?.hideErrorLoadView()
            }
            if baseSectionsVC?.isLoaded() ?? false {
                baseSectionsVC?.updateViews()
                baseSectionsVC?.hideErrorLoadView()
            }
        } else {
            if baseArticleVC?.isLoaded() ?? false {
                baseArticlesVC?.showErrorLoadView(withAnimate: true)
            }
            if baseArticlesVC?.isLoaded() ?? false {
                baseArticlesVC?.showErrorLoadView(withAnimate: true)
            }
            if baseCategoriesVC?.isLoaded() ?? false {
                baseCategoriesVC?.showErrorLoadView(withAnimate: true)
            }
            if baseSectionsVC?.isLoaded() ?? false {
                baseSectionsVC?.showErrorLoadView(withAnimate: true)
            }
        }
    }
    
    func startDialogFlow(in parentControllerOptional: UIViewController?, isFromBase: Bool) {
        let parentController = parentControllerOptional ?? RootView
        guard !(navController?.visibleViewController is DialogflowView) else {return}
        dialogflowVC = DialogflowView()
        dialogflowVC!.usedesk = usedesk
        dialogflowVC!.isFromBase = isFromBase
        if navController == nil {
            navController = UDNavigationController(rootViewController: dialogflowVC!)
            navController!.configurationStyle = configurationStyle
            navController!.setProperties()
            navController!.setTitleTextAttributes()
            navController!.modalPresentationStyle = .fullScreen
            parentController?.present(navController!, animated: true)
        } else if navController?.visibleViewController != dialogflowVC {
            navController?.isNavigationBarHidden = false
            pushViewController(dialogflowVC!)
        } else {
            dialogflowVC!.updateChat()
        }
    }
    
    func reloadDialogFlow(success: Bool, feedBackStatus: UDFeedbackStatus?) {
        if success {
            dialogflowVC?.usedesk = usedesk
            dialogflowVC?.reloadHistory()
        } else {
            if feedBackStatus == .feedbackForm || feedBackStatus == .feedbackFormAndChat {
                if offlineVC.presentingViewController == nil {
                    offlineVC = UDOfflineForm()
                    offlineVC.usedesk = usedesk
                    pushViewController(offlineVC)
                    dialogflowVC?.closeVC()
                    dialogflowVC = DialogflowView()
                }
            }
        }
    }

    func pushViewController(_ viewController: UIViewController) {
        if navController?.visibleViewController != viewController {
            navController?.pushViewController(viewController, animated: true)
        }
    }

    func dismiss() {
        navController?.dismiss(animated: true, completion: nil)
    }
    
    func baseNavigationController() -> UINavigationController? {
        let baseView = UDBaseSectionsView()
        baseView.usedesk = usedesk
        baseView.titleVC = usedesk!.model.stringFor("KnowlengeBase")
        navController = UDNavigationController(rootViewController: baseView)
        navController!.configurationStyle = configurationStyle
        navController!.setProperties()
        navController!.setTitleTextAttributes()
        navController!.modalPresentationStyle = .fullScreen
        navController!.isNavigationBarHidden = true
        return navController
    }
    
    func chatViewController() -> UIViewController? {
        guard usedesk != nil else {return nil}
        if dialogflowVC == nil {
            dialogflowVC = DialogflowView()
            dialogflowVC?.usedesk = usedesk
        }
        dialogflowVC?.view.layoutSubviews()
        return dialogflowVC
    }
    
    func visibleViewController() -> UIViewController? {
        return navController?.visibleViewController
    }
}
