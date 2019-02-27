//
//  UDArticlesView.swift


import Foundation
import UIKit

class UDArticlesView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    var usedesk: Any?
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Чат", style: .done, target: self, action: #selector(self.actionChat))
        navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        navigationItem.titleView = navigationView
        searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.tintColor = .white
        searchBar.delegate = self
        navigationView.addSubview(searchBar)
        
        tableView.register(UINib(nibName: "UDArticleViewCell", bundle: nil), forCellReuseIdentifier: "UDArticleViewCell")
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
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        let use = usedesk as! UseDeskSDK
        use.startWithoutGUICompanyID(companyID: use.companyID, account_id: use.account_id, api_token: use.api_token, email: use.email, url: use.urlWithoutPort, port: use.port, connectionStatus: { success, error in
            if success {
                DispatchQueue.main.async(execute: {
                    let dialogflowVC : DialogflowView = DialogflowView()
                    dialogflowVC.usedesk = self.usedesk
                    self.navigationController?.pushViewController(dialogflowVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        self.loadingView.alpha = 0
                    }
                })
            } else {
                if (error == "noOperators") {
                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
                    if self.url != nil {
                        offlineVC.url = self.url!
                    }
                    self.navigationController?.pushViewController(offlineVC, animated: true)
                    UIView.animate(withDuration: 0.3) {
                        self.loadingView.alpha = 0
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
                cell.viewsLabel.text = "\(searchArticles?.articles[indexPath.row].views) просмотров"
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
        let use = usedesk as! UseDeskSDK
        use.addViewsArticle(articleID: id, count: 1, connectionStatus: { success, error in
            
        })
        use.getArticle(articleID: id, connectionStatus: { success, article, error in
            if success {
                let articleVC = UDArticleView(nibName: "UDArticle", bundle: nil)
                articleVC.usedesk = self.usedesk
                articleVC.article = article
                articleVC.url = self.url
                self.navigationController?.pushViewController(articleVC, animated: true)
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
            let use = usedesk as! UseDeskSDK
            use.getSearchArticles(collection_ids: [collection_ids], category_ids: [category_ids], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { (success, searchArticle, error) in
                UIView.animate(withDuration: 0.3) {
                    self.loadingView.alpha = 0
                }
                if success {
                    self.searchArticles = searchArticle
                    self.isSearch = true
                    self.tableView.reloadData()
                } else {
                    self.isSearch = false
                    self.tableView.reloadData()
                }
            }
        } else {
            isSearch = false
            tableView.reloadData()
        }
    }
}
