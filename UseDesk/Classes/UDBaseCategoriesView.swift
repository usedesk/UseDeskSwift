//
//  UDBaseCategoriesView.swift
//  UseDesk_SDK_Swift


import Foundation
import UIKit

class UDBaseCategoriesView: UDListBaseKnowledgeVC {
    
    var сategories: [UDBaseCategory]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        сategories == nil && !isUpdatedValues ? showErrorLoadView() : hideErrorLoadView()
    }
    
    override func firstState() {
        super.firstState()
        if сategories != nil {
            сategories = сategories!
        } else {
            loader.alpha = 1
            loader.startAnimating()
            viewForTable.alpha = 0
        }
        
        tableView.register(UINib(nibName: "UDBaseCategoriesCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseCategoriesCell")
        tableView.reloadData()
        
        сategories == nil && !isUpdatedValues ? showErrorLoadView() : hideErrorLoadView()
    }
    
    override func updateValues() {
        isUpdatedValues = true
        if usedesk?.model.isLoadedKnowledgeBase ?? false && сategories == nil {
            сategories = usedesk?.model.selectedKnowledgeBaseSection?.categories
            titleVC = usedesk?.model.selectedKnowledgeBaseSection?.title ?? ""
        }
    }
    
    override func backAction() {
        if isShownNoInternet || (self.navigationController?.viewControllers.count ?? 0 < 2) {
            super.backAction()
        } else {
            self.navigationController?.popViewController(animated: true)
            self.removeFromParent()
        }
    }
    
    // MARK: - TableView
    override func countCell() -> Int {
        return сategories?.count ?? 0
    }
    
    override func getCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseCategoriesCell", for: indexPath) as! UDBaseCategoriesCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if сategories != nil {
            cell.setCell(category: сategories![indexPath.row])
        }
        return cell
    }

    override func selectRowAt(_ indexPath: IndexPath) {
        guard usedesk != nil, сategories != nil else {return}
        let articlesVC: UDBaseArticlesView = UDBaseArticlesView()
        articlesVC.usedesk = usedesk!
        articlesVC.titleVC = сategories![indexPath.row].title
        articlesVC.articles = сategories![indexPath.row].articlesTitles
        usedesk?.uiManager?.pushViewController(articlesVC)
        if let cell = tableView.cellForRow(at: indexPath) as? UDBaseCategoriesCell {
            cell.isSelected = false
            cell.selectionStyle = .none
        }
    }
    
}

