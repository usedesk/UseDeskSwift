//
//  UDArticlesView.swift


import Foundation
import UIKit

class UDArticlesView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    var arrayArticles: [ArticleTitle] = []
    var searchArticles: SearchArticle? = nil
    var isSearch: Bool = false
    var collection_ids: Int = 0
    var category_ids: Int = 0
    var navigationView = UIView()
    var isViewDidLayout: Bool = false
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))
        navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        navigationItem.titleView = navigationView
        searchBar = UISearchBar()
        searchBar.placeholder = searchBarPlaceholderText
        searchBar.tintColor = searchBarTintColor
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = searchBarTextBackgroundColor
        textFieldInsideSearchBar?.textColor = searchBarTextColor
        navigationView.addSubview(searchBar)
        
        tableView.register(UINib(nibName: "UDArticleViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDArticleViewCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isViewDidLayout {
            searchBar.frame = navigationItem.titleView!.frame
            isViewDidLayout = true
        }
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, isUseBase: usedesk!.isUseBase, account_id: usedesk!.account_id, api_token: usedesk!.api_token, email: usedesk!.email, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, nameChat: usedesk!.nameChat, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC : DialogflowView = DialogflowView()
                    dialogflowVC.usedesk = wSelf.usedesk
                    dialogflowVC.isFromBase = true
                    wSelf.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                })
            } else {
                if (error == "noOperators") {
                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                    if wSelf.url != nil {
                        offlineVC.url = wSelf.url!
                    }
                    offlineVC.usedesk = wSelf.usedesk
                    wSelf.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.loadingView.alpha = 0
                    }
                }
            }
        })
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if searchArticles != nil {
                return (searchArticles?.articles.count)!
            } else {
                return 0
            }
        } else {
            return arrayArticles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UDArticleViewCell", for: indexPath) as! UDArticleViewCell
        if isSearch {
            if searchArticles != nil {
                cell.textView.text = searchArticles?.articles[indexPath.row].title
                cell.viewsLabel.text = "\(searchArticles?.articles[indexPath.row].views ?? 0) просмотров"
            } else {
                cell.textView.text = ""
            }
        } else {
            cell.textView.text = arrayArticles[indexPath.row].title
            cell.viewsLabel.text = "\(arrayArticles[indexPath.row].views) просмотров"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id: Int = 0
        if isSearch {
            id = (searchArticles?.articles[indexPath.row].id)!
        } else {
            id = arrayArticles[indexPath.row].id
        }
        usedesk?.addViewsArticle(articleID: id, count: 1, connectionStatus: { success, error in
            
        })
        
        usedesk?.getArticle(articleID: id, connectionStatus: { [weak self] success, article, error in
            guard let wSelf = self else {return}
            if success {
                let articleVC = UDArticleView()
                articleVC.usedesk = wSelf.usedesk
                articleVC.article = article
                articleVC.url = wSelf.url
                wSelf.navigationController?.pushViewController(articleVC, animated: true)
                if let cell = tableView.cellForRow(at: indexPath) as? UDArticleViewCell {
                    cell.isSelected = false
                    cell.selectionStyle = .none
                }
            }
        })
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
            usedesk?.getSearchArticles(collection_ids: [collection_ids], category_ids: [category_ids], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) {  [weak self] (success, searchArticle, error) in
                guard let wSelf = self else {return}
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
                if success {
                    wSelf.searchArticles = searchArticle
                    wSelf.isSearch = true
                    wSelf.tableView.reloadData()
                } else {
                    wSelf.isSearch = false
                    wSelf.tableView.reloadData()
                }
            }
        } else {
            isSearch = false
            tableView.reloadData()
        }
    }
}
