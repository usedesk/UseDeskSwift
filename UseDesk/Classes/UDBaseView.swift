//
//  UDBaseView.swift

import Foundation
import UIKit
import SDWebImage

class UDBaseView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    var usedesk: Any?
    var url: String?
    var arrayCollections: [BaseCollection] = []
    var navigationView = UIView()
    var isViewDidLayout: Bool = false
    var searchBar = UISearchBar()
    var searchArticles: SearchArticle? = nil
    var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Чат", style: .done, target: self, action: #selector(self.actionChat))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionExit))
        navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        navigationItem.titleView = navigationView
        searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.tintColor = .blue
        searchBar.delegate = self
        navigationView.addSubview(searchBar)     
      
        tableView.register(UINib(nibName: "UDBaseViewCell", bundle: nil), forCellReuseIdentifier: "UDBaseViewCell")
        tableView.register(UINib(nibName: "UDArticleViewCell", bundle: nil), forCellReuseIdentifier: "UDArticleViewCell")
        tableView.register(UINib(nibName: "UDHeaderBaseViewCell", bundle: nil), forCellReuseIdentifier: "UDHeaderBaseViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let use = usedesk as! UseDeskSDK
        use.getCollections(connectionStatus: {success, collections, error in
            if success {
                self.arrayCollections = collections!
                UIView.animate(withDuration: 0.3) {
                    self.loadingView.alpha = 0
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isViewDidLayout {
            searchBar.frame = CGRect(origin: .zero, size: CGSize(width: navigationView.frame.width - 30, height: navigationView.frame.height)) 
            isViewDidLayout = true
        }
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        let use = usedesk as! UseDeskSDK
        use.startWithoutGUICompanyID(companyID: use.companyID, account_id: use.account_id, api_token: use.api_token, email: use.email, url: use.urlWithoutPort, port: use.port, name: use.name, connectionStatus: { success, error in
            let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
            if self.url != nil {
                offlineVC.url = self.url!
            }
            offlineVC.usedesk = self.usedesk
            self.navigationController?.pushViewController(offlineVC, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 0
            }
//            if success {
//                DispatchQueue.main.async(execute: {
//                    let dialogflowVC : DialogflowView = DialogflowView()
//                    dialogflowVC.usedesk = self.usedesk
//                    self.navigationController?.pushViewController(dialogflowVC, animated: true)
//                    UIView.animate(withDuration: 0.3) {
//                        self.loadingView.alpha = 0
//                    }
//                })
//            } else {
//                if (error == "noOperators") {
//                    let offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
//                    if self.url != nil {
//                        offlineVC.url = self.url!
//                    }
//                    self.navigationController?.pushViewController(offlineVC, animated: true)
//                    UIView.animate(withDuration: 0.3) {
//                        self.loadingView.alpha = 0
//                    }
//                }
//            }
            
        })
    }
    
    @objc func actionExit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearch {
            return 1
        } else {
            return arrayCollections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            if searchArticles != nil {
                return (searchArticles?.articles.count)!
            } else {
                return 0
            }
        } else {
            return arrayCollections[section].сategories.count + 1
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = Bundle(for: UDBaseView.self).loadNibNamed("UDHeaderBaseViewCell", owner: self, options: nil)?.first as! UDHeaderBaseViewCell
//        header.viewImage.sd_setImage(with: URL(string: arrayCollections[section].image), completed: nil)
//        header.textView.text = arrayCollections[section].title
//        return header
//    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return  arrayCollections[section].title
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UDArticleViewCell", for: indexPath) as! UDArticleViewCell
            if searchArticles != nil {
                cell.textView.text = searchArticles?.articles[indexPath.row].title
                cell.viewsLabel.text = "\(searchArticles!.articles[indexPath.row].views) просмотров"
            } else {
                cell.textView.text = ""
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UDHeaderBaseViewCell", for: indexPath) as! UDHeaderBaseViewCell
                cell.viewImage.sd_setImage(with: URL(string: arrayCollections[indexPath.section].image), completed: nil)
                cell.labelTitle.text = arrayCollections[indexPath.section].title
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseViewCell", for: indexPath) as! UDBaseViewCell
                cell.textView.text = arrayCollections[indexPath.section].сategories[indexPath.row - 1].title
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearch {
            let use = usedesk as! UseDeskSDK
            use.addViewsArticle(articleID: searchArticles!.articles[indexPath.row].id, count: 1, connectionStatus: { success, error in
                
            })
            use.getArticle(articleID: searchArticles!.articles[indexPath.row].id, connectionStatus: { success, article, error in
                if success {
                    let articleVC = UDArticleView(nibName: "UDArticle", bundle: nil)
                    articleVC.usedesk = self.usedesk
                    articleVC.article = article
                    articleVC.url = self.url
                    self.navigationController?.pushViewController(articleVC, animated: true)
                }
            })
        } else {
            let articlesVC : UDArticlesView = UDArticlesView()
            articlesVC.usedesk = self.usedesk
            articlesVC.arrayArticles = arrayCollections[indexPath.section].сategories[indexPath.row - 1].articlesTitles
            articlesVC.collection_ids = arrayCollections[indexPath.section].id
            articlesVC.category_ids = arrayCollections[indexPath.section].сategories[indexPath.row - 1].id
            self.navigationController?.pushViewController(articlesVC, animated: true)
        }
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
            use.getSearchArticles(collection_ids: [], category_ids: [], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { (success, searchArticle, error) in
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

