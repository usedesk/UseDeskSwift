//
//  UDBaseArticlesView.swift


import Foundation
import UIKit

class UDBaseArticlesView: UDListBaseKnowledgeVC {
    var articles: [UDArticleTitle]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        articles == nil && !isUpdatedValues ? showErrorLoadView() : hideErrorLoadView()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func firstState() {
        super.firstState()
        
        if articles != nil {
            articles = articles!
        }
        
        tableView.register(UINib(nibName: "UDBaseArticleViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseArticleViewCell")
        tableView.reloadData()
        
        articles == nil && !isUpdatedValues ? showErrorLoadView() : hideErrorLoadView()
    }
    
    override func updateValues() {
        isUpdatedValues = true
        if usedesk?.model.isLoadedKnowledgeBase ?? false && articles == nil {
            articles = usedesk?.model.selectedKnowledgeBaseCategory?.articlesTitles
            titleVC = usedesk?.model.selectedKnowledgeBaseCategory?.title ?? ""
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
        return articles?.count ?? 0
    }
    
    override func getCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseArticleViewCell", for: indexPath) as! UDBaseArticleViewCell
        cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        if articles != nil {
            cell.setCell(text: articles![indexPath.row].title)
        }
        return cell
    }

    override func selectRowAt(_ indexPath: IndexPath) {
        guard usedesk?.reachability != nil else {return}
        guard usedesk?.reachability?.connection != .unavailable else {
            showAlertNoInternet()
            return
        }
        guard usedesk != nil, articles != nil else {return}
        showArticle(articleTitle: articles![indexPath.row], indexPath: indexPath)
        if let cell = tableView.cellForRow(at: indexPath) as? UDBaseCategoriesCell {
            cell.isSelected = false
            cell.selectionStyle = .none
        }
    }
}
