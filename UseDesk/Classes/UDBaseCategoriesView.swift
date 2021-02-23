//
//  UDBaseCategoriesView.swift
//  UseDesk_SDK_Swift


import Foundation
import UIKit

class UDBaseCategoriesView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    var baseCollection: UDBaseCollection?
    var arrayCollections: [UDBaseCollection] = []
    
    private var сategories: [UDBaseCategory] = []
    private var navigationView = UIView()
    private var searchBar = UISearchBar()
    private var searchArticles: UDSearchArticle? = nil
    private var isSearch: Bool = false
    private var chatButton = UIButton()
    private var loaderChatButton = UIActivityIndicatorView(activityIndicatorStyle: .white)
    private var isFirstLoaded = true
    private var isOpenOther = false
    private var openedArticle: UDArticle?
    private var indexOpenedArticle: Int = 0
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var previousOrientation: Orientation = .portrait
    private var landscapeOrientation: LandscapeOrientation? = nil
    
    private var dialogflowVC : DialogflowView = DialogflowView()
    private var offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
    
    convenience init() {
        let nibName: String = "UDBaseCategoriesView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoaded {
            setChatButton()
            isFirstLoaded = false
        }
        if isOpenOther {
            isOpenOther = false
            if openedArticle != nil {
                let articleVC = UDBaseArticleView()
                articleVC.usedesk = usedesk
                articleVC.selectedArticle = openedArticle
                articleVC.url = url
                articleVC.delegate = self
                if isSearch {
                    if let collection = arrayCollections.filter({ $0.id == openedArticle?.collection_id}).first {
                        if let category = collection.сategories.filter({ $0.id == openedArticle?.category_id}).first {
                            if let selectedArticle = category.articlesTitles.filter({ $0.id == openedArticle?.id}).first {
                                if let selectedIndex =  category.articlesTitles.index(of: selectedArticle) {
                                    articleVC.indexSelectedArticle = selectedIndex
                                    articleVC.articles = category.articlesTitles
                                }
                            }
                        }
                    }
                } 
                self.present(articleVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(origin: .zero, size: CGSize(width: navigationView.frame.width - 30, height: navigationView.frame.height))
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if previousOrientation != .portrait {
                safeAreaInsetsLeftOrRight = 0
                previousOrientation = .portrait
                if !isFirstLoaded {
                    setChatButton()
                }
            }
        } else {
            if previousOrientation != .landscape {
                if #available(iOS 11.0, *) {
                    safeAreaInsetsLeftOrRight = view.safeAreaInsets.left > view.safeAreaInsets.right ? view.safeAreaInsets.left : view.safeAreaInsets.right
                    if UIDevice.current.orientation == .landscapeLeft {
                        landscapeOrientation = .left
                    } else if UIDevice.current.orientation == .landscapeRight {
                        landscapeOrientation = .right
                    } else {
                        landscapeOrientation = nil
                    }
                }
                previousOrientation = .landscape
                if !isFirstLoaded {
                    setChatButton()
                }
            }
        }
    }
    
    // MARK: - Private
    private func firstState() {
        guard usedesk != nil else {return}
        self.modalPresentationStyle = .fullScreen
        сategories = baseCollection?.сategories ?? []
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        
        tableView.backgroundColor = configurationStyle.baseStyle.backColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56
        navigationItem.leftBarButtonItems = nil
        if let backButtonImage = configurationStyle.navigationBarStyle.backButtonImage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        }
        navigationItem.rightBarButtonItems = nil
        if let searchButtonImage = configurationStyle.navigationBarStyle.searchButtonImage {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.searchAction))
        }
        navigationItem.title = baseCollection?.title ?? usedesk!.stringFor("Category")
      
        tableView.register(UINib(nibName: "UDBaseSearchCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseSearchCell")
        tableView.register(UINib(nibName: "UDBaseCategoriesCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseCategoriesCell")
        tableView.reloadData()
    }
    
    private func setChatButton() {
        let baseStyle = configurationStyle.baseStyle
        let xPointChatButton = self.view.frame.width - baseStyle.chatButtonSize.width - baseStyle.chatButtonMargin.right
        let yPointChatButton = self.view.frame.height - baseStyle.chatButtonSize.height - baseStyle.chatButtonMargin.bottom
        chatButton.frame = CGRect(x: xPointChatButton, y: yPointChatButton, width: baseStyle.chatButtonSize.width, height: baseStyle.chatButtonSize.height)
        chatButton.addTarget(self, action: #selector(actionChat), for: .touchUpInside)
        chatButton.setImage(baseStyle.chatIconImage, for: .normal)
        chatButton.backgroundColor = baseStyle.chatButtonBackColor
        chatButton.layer.masksToBounds = false
        chatButton.layer.cornerRadius = baseStyle.chatButtonCornerRadius
        chatButton.layer.shadowColor = baseStyle.shadowColor
        chatButton.layer.shadowPath = UIBezierPath(roundedRect: chatButton.bounds, cornerRadius: chatButton.layer.cornerRadius).cgPath
        chatButton.layer.shadowOffset = baseStyle.shadowOffset
        chatButton.layer.shadowOpacity = baseStyle.shadowOpacity
        chatButton.layer.shadowRadius = baseStyle.shadowRadius
        self.view.addSubview(chatButton)
        let widthLoader = loaderChatButton.frame.size.width
        let heightLoader = loaderChatButton.frame.size.height
        let xLoader: CGFloat = chatButton.frame.origin.x + (chatButton.frame.width / 2) - (widthLoader / 2)
        let yLoader: CGFloat = chatButton.frame.origin.y + (chatButton.frame.height / 2) - (heightLoader / 2)
        loaderChatButton.frame = CGRect(x: xLoader, y: yLoader, width: widthLoader, height: heightLoader)
        loaderChatButton.alpha = 0
        if loaderChatButton.superview == nil {
            self.view.addSubview(loaderChatButton)
        }
    }
    
    // MARK: - User actions
    @objc func actionChat() {
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.chatButton.setImage(nil, for: .normal)
            self.loaderChatButton.alpha = 1
            self.loaderChatButton.startAnimating()
        }
        usedesk!.startWithoutGUICompanyID(companyID: usedesk!.companyID, knowledgeBaseID: usedesk!.knowledgeBaseID, api_token: usedesk!.api_token, email: usedesk!.email, phone: usedesk!.phone, url: usedesk!.urlWithoutPort, port: usedesk!.port, name: usedesk!.name, operatorName: usedesk!.operatorName, nameChat: usedesk!.nameChat, signature: usedesk!.signature, connectionStatus: { [weak self] success, error in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if success {
                if wSelf.navigationController?.visibleViewController != wSelf.dialogflowVC {
                    DispatchQueue.main.async(execute: {
                        wSelf.dialogflowVC.usedesk = wSelf.usedesk
                        wSelf.dialogflowVC.isFromBase = true
                        wSelf.usedesk?.navController.pushViewController(wSelf.dialogflowVC, animated: true)
                        UIView.animate(withDuration: 0.3) {
                            wSelf.chatButton.setImage(wSelf.configurationStyle.baseStyle.chatIconImage, for: .normal)
                            wSelf.loaderChatButton.alpha = 0
                            wSelf.loaderChatButton.stopAnimating()
                        }
                    })
                }
            } else {
                if error == "feedback_form" || error == "feedback_form_and_chat" {
                    if wSelf.navigationController?.visibleViewController != wSelf.offlineVC {
                        wSelf.offlineVC = UDOfflineForm()
                        if wSelf.url != nil {
                            wSelf.offlineVC.url = wSelf.url!
                        }
                        wSelf.offlineVC.usedesk = wSelf.usedesk
                        wSelf.offlineVC.isFromBase = true
                        wSelf.usedesk?.navController.pushViewController(wSelf.offlineVC, animated: true)
                        UIView.animate(withDuration: 0.3) {
                            wSelf.chatButton.setImage(wSelf.configurationStyle.baseStyle.chatIconImage, for: .normal)
                            wSelf.loaderChatButton.alpha = 0
                            wSelf.loaderChatButton.stopAnimating()
                        }
                    }
                }
            }
            
        })
    }
    
    @objc func searchAction() {
        guard usedesk != nil else {return}
        navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        navigationItem.titleView = navigationView
        searchBar = UISearchBar()
        searchBar.placeholder = usedesk!.stringFor("Search")
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = configurationStyle.baseStyle.searchBarTextBackgroundColor
        textFieldInsideSearchBar?.textColor = configurationStyle.baseStyle.searchBarTextColor
        navigationItem.leftBarButtonItems = nil
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: usedesk!.stringFor("Cancel"), style: .plain, target: self, action: #selector(self.cancelSearchAction))
        navigationItem.rightBarButtonItem?.tintColor = configurationStyle.baseStyle.searchCancelButtonColor
        let widthCancel = usedesk!.stringFor("Cancel").size(attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], usesFontLeading: true).width + 2
        searchBar.frame = CGRect(x: 8, y: 0, width: navigationView.frame.width - 38 - widthCancel, height: navigationView.frame.height)
        navigationView.addSubview(searchBar)
        searchBar.becomeFirstResponder()
    }
    
    @objc func cancelSearchAction() {
        isSearch = false
        searchBar.removeFromSuperview()
        if let backButtonImage = configurationStyle.navigationBarStyle.backButtonImage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        }
        if let searchButtonImage = configurationStyle.navigationBarStyle.searchButtonImage {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.searchAction))
        }
        navigationItem.titleView = nil
        navigationItem.title = "База знаний"
        tableView.reloadData()
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return searchArticles?.articles.count ?? 0
        } else {
            return сategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseSearchCell", for: indexPath) as! UDBaseSearchCell
            cell.usedesk = usedesk
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.setCell(article: searchArticles?.articles[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseCategoriesCell", for: indexPath) as! UDBaseCategoriesCell
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.setCell(category: сategories[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard usedesk != nil else {return}
        if isSearch {
            usedesk!.addViewsArticle(articleID: searchArticles?.articles[indexPath.row].id ?? 0, count: searchArticles?.articles[indexPath.row].id != nil ? 1 : 0, connectionStatus: { success, error in

            })
            indexOpenedArticle = indexPath.row
            usedesk!.getArticle(articleID: searchArticles!.articles[indexPath.row].id, connectionStatus: { [weak self] success, article, error in
                guard let wSelf = self else {return}
                if success {
                    wSelf.openedArticle = article
                    let articleVC = UDBaseArticleView()
                    articleVC.usedesk = wSelf.usedesk
                    articleVC.selectedArticle = article
                    articleVC.url = wSelf.url
                    articleVC.delegate = self
                    if let collection = wSelf.arrayCollections.filter({ $0.id == article?.collection_id}).first {
                        if let category = collection.сategories.filter({ $0.id == article?.category_id}).first {
                            if let selectedArticle = category.articlesTitles.filter({ $0.id == article?.id}).first {
                                if let selectedIndex =  category.articlesTitles.index(of: selectedArticle) {
                                    articleVC.indexSelectedArticle = selectedIndex
                                    articleVC.articles = category.articlesTitles
                                }
                            }
                        }
                    }
                    wSelf.present(articleVC, animated: true, completion: nil)
                    if let cell = tableView.cellForRow(at: indexPath) as? UDBaseSearchCell {
                        cell.isSelected = false
                        cell.selectionStyle = .none
                    }
                }
            })
        } else {
            let articlesVC : UDBaseArticlesView = UDBaseArticlesView()
            articlesVC.usedesk = usedesk!
            articlesVC.сategory = сategories[indexPath.row]
            articlesVC.arrayCollections = arrayCollections
            usedesk!.navController.pushViewController(articlesVC, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? UDBaseCategoriesCell {
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
// MARK: - SearchBar
extension UDBaseCategoriesView: UDBaseArticleViewDelegate {
    func openChat() {
        if navigationController?.visibleViewController != dialogflowVC {
            isOpenOther = true
            dialogflowVC.usedesk = usedesk
            dialogflowVC.isFromBase = true
            navigationController?.pushViewController(dialogflowVC, animated: true)
        }
    }
    
    func openOfflineForm() {
        if navigationController?.visibleViewController != offlineVC {
            isOpenOther = true
            offlineVC = UDOfflineForm()
            if url != nil {
                offlineVC.url = url!
            }
            offlineVC.usedesk = usedesk
            navigationController?.pushViewController(offlineVC, animated: true)
        }
    }
}
