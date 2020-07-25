//
//  UDBaseView.swift

import Foundation
import UIKit
import SDWebImage

class UDBaseView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    var arrayCollections: [BaseCollection] = []
    var navigationView = UIView()
    var isViewDidLayout: Bool = false
    var searchBar = UISearchBar()
    var searchArticles: SearchArticle? = nil
    var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: chatButtonText, style: .done, target: self, action: #selector(self.actionChat))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(self.actionExit))
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
      
        tableView.register(UINib(nibName: "UDBaseViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseViewCell")
        tableView.register(UINib(nibName: "UDArticleViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDArticleViewCell")
        tableView.register(UINib(nibName: "UDHeaderBaseViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDHeaderBaseViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        usedesk?.getCollections(connectionStatus: { [weak self] success, collections, error in
            guard let wSelf = self else {return}
            if success {
                wSelf.arrayCollections = collections!
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
                wSelf.tableView.reloadData()
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
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, isUseBase: usedesk!.isUseBase, account_id: usedesk!.account_id, api_token: usedesk!.api_token, email: usedesk!.email, phone: usedesk!.phone, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, nameChat: usedesk!.nameChat, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
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
                    let offlineVC = UDOfflineForm()
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
//        let headerNibName: String = "UDHeaderBaseViewCell"
//        let header = BundleId.bundle(for: headerNibName).loadNibNamed(headerNibName, owner: self, options: nil)?.first as! UDHeaderBaseViewCell
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
        guard usedesk != nil else {return}
        if isSearch {
            usedesk!.addViewsArticle(articleID: searchArticles?.articles[indexPath.row].id ?? 0, count: searchArticles?.articles[indexPath.row].id != nil ? 1 : 0, connectionStatus: { success, error in
                
            })
            usedesk!.getArticle(articleID: searchArticles!.articles[indexPath.row].id, connectionStatus: { [weak self] success, article, error in
                guard let wSelf = self else {return}
                if success {
                    let articleVC = UDArticleView()
                    articleVC.usedesk = wSelf.usedesk
                    articleVC.article = article
                    articleVC.url = wSelf.url
                    wSelf.navigationController?.pushViewController(articleVC, animated: true)
                    if let cell = tableView.cellForRow(at: indexPath) as? UDBaseViewCell {
                        cell.isSelected = false
                        cell.selectionStyle = .none
                    }
                }
            })
        } else {
            let articlesVC : UDArticlesView = UDArticlesView()
            articlesVC.usedesk = usedesk!
            articlesVC.arrayArticles = arrayCollections[indexPath.section].сategories[indexPath.row - 1].articlesTitles
            articlesVC.collection_ids = arrayCollections[indexPath.section].id
            articlesVC.category_ids = arrayCollections[indexPath.section].сategories[indexPath.row - 1].id
            self.navigationController?.pushViewController(articlesVC, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? UDBaseViewCell {
                cell.isSelected = false
                cell.selectionStyle = .none
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            guard usedesk != nil else {return}
            UIView.animate(withDuration: 0.3) {
                self.loadingView.alpha = 1
            }
            usedesk!.getSearchArticles(collection_ids: [], category_ids: [], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { [weak self] (success, searchArticle, error) in
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

