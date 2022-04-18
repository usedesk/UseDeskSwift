//
//  UDBaseSectionsView.swift

import Foundation
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

class UDBaseSectionsView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    
    weak var usedesk: UseDeskSDK?
    var url: String?
    
    private var arrayCollections: [UDBaseCollection] = []
    private var navigationView = UIView()
    private var searchBar = UISearchBar()
    private var searchArticles: UDSearchArticle? = nil
    private var chatButton = UIButton()
    private var loaderChatButton = UIActivityIndicatorView(style: .white)
    private var isSearch: Bool = false
    private var isOpenOther = false
    private var openedArticle: UDArticle?
    private var indexOpenedArticle: Int = 0
    private var isFirstLoaded = true
    private var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    private var previousOrientation: Orientation = .portrait
    private var landscapeOrientation: LandscapeOrientation? = nil
    
    private var dialogflowVC : DialogflowView = DialogflowView()
    private var noInternetVC: UDNoInternetVC!
    private var offlineVC = UDOfflineForm(nibName: "UDOfflineForm", bundle: nil)
    private var isCanShowNoInternet = true
    private var isShownNoInternet = false
    
    convenience init() {
        let nibName: String = "UDBaseSectionsView"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
        navigationController?.navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        navigationController?.navigationBar.titleTextAttributes?[.foregroundColor] = configurationStyle.navigationBarStyle.textColor
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
                                if let selectedIndex =  category.articlesTitles.firstIndex(of: selectedArticle) {
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
    public func isLoaded() -> Bool {
        return !isFirstLoaded
    }
    
    
    // MARK: - Private
    private func firstState() {
        guard usedesk != nil else {return}
        self.modalPresentationStyle = .fullScreen
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
        usedesk?.getCollections(connectionStatus: { [weak self] success, collections in
            guard let wSelf = self else {return}
            if success {
                wSelf.arrayCollections = collections!
                wSelf.downloadImagesSection()
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
                wSelf.tableView.reloadData()
            }
        }, errorStatus: { [weak self] _, _ in
            guard let wSelf = self else {return}
            if !wSelf.isCanShowNoInternet {
                wSelf.showAlert(wSelf.usedesk!.model.stringFor("Error"), text: wSelf.usedesk!.model.stringFor("ServerError"))
            }
        })
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        let baseStyle = configurationStyle.baseStyle
        
        loadingView.backgroundColor = baseStyle.backColor
        
        tableView.backgroundColor = baseStyle.backColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        if let backButtonImage = configurationStyle.navigationBarStyle.backButtonImage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        }
        if let searchButtonImage = configurationStyle.navigationBarStyle.searchButtonImage {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.searchAction))
        }
        navigationItem.title = usedesk!.model.stringFor("KnowlengeBase")
      
        tableView.register(UINib(nibName: "UDBaseSearchCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseSearchCell")
        tableView.register(UINib(nibName: "UDBaseSectionViewCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseSectionViewCell")        
    }
    
    private func setChatButton() {
        guard configurationStyle.baseStyle.isNeedChat else {
            chatButton.alpha = 0
            loaderChatButton.alpha = 0
            return
        }
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
        if chatButton.superview == nil {
            self.view.addSubview(chatButton)
        }
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
    
    private func getData(from url: URL, index: Int, completion: @escaping (Data?, URLResponse?, Int, Error?) -> ()) {
        (URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            completion(data, response, index, error)
        })).resume()
    }
    
    private func downloadImagesSection() {
        var urlsDictionary:[Int : URL] = [:]
        for index in 0..<arrayCollections.count {
            if let url = URL(string: arrayCollections[index].imageUrl) {
                urlsDictionary[index] = url
            }
        }
        var countResponse = 0
        for urlDictionary in urlsDictionary {
            getData(from: urlDictionary.value, index: urlDictionary.key) { data, response, index, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                    countResponse += 1
                    self?.arrayCollections[urlDictionary.key].image = UIImage(data: data)
                    if countResponse == urlsDictionary.count {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func showAlert(_ title: String?, text: String?) {
        guard usedesk != nil else {return}
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: usedesk!.model.stringFor("Understand"), style: .default, handler: { [weak self] _ in
            self?.backAction()
        })
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    
    // MARK: - User actions
    @objc func actionChat() {
        guard usedesk != nil else {return}
        UIView.animate(withDuration: 0.3) {
            self.chatButton.setImage(nil, for: .normal)
            self.loaderChatButton.alpha = 1
            self.loaderChatButton.startAnimating()
        }
        usedesk?.startWithoutGUICompanyID(companyID: usedesk!.model.companyID, chanelId: usedesk!.model.chanelId, knowledgeBaseID: usedesk!.model.knowledgeBaseID, api_token: usedesk!.model.api_token, email: usedesk!.model.email, phone: usedesk!.model.phone, url: usedesk!.model.urlWithoutPort, port: usedesk!.model.port, name: usedesk!.model.name, operatorName: usedesk!.model.operatorName, nameChat: usedesk!.model.nameChat, token: usedesk!.model.token, connectionStatus: { [weak self] success, feedbackStatus, token in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureStartBlock != nil {
                wSelf.usedesk!.closureStartBlock!(success, feedbackStatus, token)
            }
            if success && feedbackStatus.isNotOpenFeedbackForm {
                if wSelf.navigationController?.visibleViewController != wSelf.dialogflowVC {
                    wSelf.usedesk?.uiManager?.pushViewController(wSelf.dialogflowVC)
                    wSelf.dialogflowVC.usedesk = wSelf.usedesk
                    wSelf.dialogflowVC.isFromBase = true
                    UIView.animate(withDuration: 0.3) {
                        wSelf.chatButton.setImage(wSelf.configurationStyle.baseStyle.chatIconImage, for: .normal)
                        wSelf.loaderChatButton.alpha = 0
                        wSelf.loaderChatButton.stopAnimating()
                    }
                }
            } else if feedbackStatus.isOpenFeedbackForm {
                if wSelf.navigationController?.visibleViewController != wSelf.offlineVC {
                    wSelf.offlineVC = UDOfflineForm()
                    if wSelf.url != nil {
                        wSelf.offlineVC.url = wSelf.url!
                    }
                    wSelf.offlineVC.usedesk = wSelf.usedesk
                    wSelf.offlineVC.isFromBase = true
                    wSelf.usedesk?.uiManager?.pushViewController(wSelf.offlineVC)
                    UIView.animate(withDuration: 0.3) {
                        wSelf.chatButton.setImage(wSelf.configurationStyle.baseStyle.chatIconImage, for: .normal)
                        wSelf.loaderChatButton.alpha = 0
                        wSelf.loaderChatButton.stopAnimating()
                    }
                }
            }
        }, errorStatus: {  [weak self] error, description  in
            guard let wSelf = self else {return}
            guard wSelf.usedesk != nil else {return}
            if wSelf.usedesk!.closureErrorBlock != nil {
                wSelf.usedesk!.closureErrorBlock!(error, description)
            }
        })
    }
    
    @objc func searchAction() {
        guard usedesk != nil, !isShownNoInternet else {return}
        navigationView = UIView(frame: navigationController?.navigationBar.bounds ?? .zero)
        navigationItem.titleView = navigationView
        searchBar = UISearchBar()
        searchBar.placeholder = usedesk!.model.stringFor("Search")
        searchBar.delegate = self
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = configurationStyle.baseStyle.searchBarTextBackgroundColor
        textFieldInsideSearchBar?.textColor = configurationStyle.baseStyle.searchBarTextColor
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: usedesk!.model.stringFor("Cancel"), style: .plain, target: self, action: #selector(self.cancelSearchAction))
        navigationItem.rightBarButtonItem?.tintColor = configurationStyle.baseStyle.searchCancelButtonColor
        let widthCancel = usedesk!.model.stringFor("Cancel").size(attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], usesFontLeading: true).width + 8
        searchBar.frame = CGRect(x: 8, y: 0, width: navigationView.frame.width - 38 - widthCancel, height: navigationView.frame.height)
        navigationView.addSubview(searchBar)
        searchBar.becomeFirstResponder()
    }
    
    @objc func cancelSearchAction() {
        isSearch = false
        searchBar.removeFromSuperview()
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        }
        if let backButtonImage = configurationStyle.navigationBarStyle.backButtonImage {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(self.backAction))
        }
        if let searchButtonImage = configurationStyle.navigationBarStyle.searchButtonImage {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: searchButtonImage, style: .plain, target: self, action: #selector(self.searchAction))
        }
        navigationItem.titleView = nil
        navigationItem.title = usedesk?.model.stringFor("KnowlengeBase") ?? ""
        tableView.reloadData()
    }
    
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
        usedesk?.isOpenSDKUI = false
    }
    
    // MARK: - TableNode
    func showNoInternet() {
        guard isCanShowNoInternet else {return}
        isShownNoInternet = true
        noInternetVC = UDNoInternetVC()
        noInternetVC.usedesk = usedesk
        if usedesk?.model.isPresentDefaultControllers ?? true {
            self.addChild(self.noInternetVC)
            self.view.addSubview(self.noInternetVC.view)
        } else {
            noInternetVC.modalPresentationStyle = .fullScreen
            self.present(noInternetVC, animated: false, completion: nil)
        }
        var width: CGFloat = self.view.frame.width
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            width += safeAreaInsetsLeftOrRight * 2
        }
        noInternetVC.view.frame = CGRect(x:0, y:0, width: width, height: self.view.frame.height)
        noInternetVC.setViews()
        chatButton.alpha = 0
        navigationItem.rightBarButtonItem?.customView?.alpha = 0
    }
    
    func closeNoInternet() {
        guard isCanShowNoInternet else {return}
        isShownNoInternet = false
        firstState()
        chatButton.alpha = 1
        if usedesk?.model.isPresentDefaultControllers ?? true {
            noInternetVC.removeFromParent()
            noInternetVC.view.removeFromSuperview()
        } else {
            noInternetVC.dismiss(animated: false, completion: nil)
        }
        isCanShowNoInternet = false
    }
    
    // MARK: - TableView    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return searchArticles?.articles.count ?? 0
        } else {
            return arrayCollections.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseSectionViewCell", for: indexPath) as! UDBaseSectionViewCell
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.setCell(text: arrayCollections[indexPath.row].title, image: arrayCollections[indexPath.row].image)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard usedesk != nil else {return}
        if isSearch {
            usedesk!.addViewsArticle(articleID: searchArticles?.articles[indexPath.row].id ?? 0, count: searchArticles?.articles[indexPath.row].id != nil ? 1 : 0, connectionStatus: { _ in
            }, errorStatus: { _, _ in})
            indexOpenedArticle = indexPath.row
            usedesk!.getArticle(articleID: searchArticles!.articles[indexPath.row].id, connectionStatus: { [weak self] success, article in
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
                                if let selectedIndex =  category.articlesTitles.firstIndex(of: selectedArticle) {
                                    articleVC.indexSelectedArticle = selectedIndex
                                    articleVC.articles = category.articlesTitles
                                }
                            }
                        }
                    }
                    wSelf.present(articleVC, animated: true, completion: nil)
                    if let cell = tableView.cellForRow(at: indexPath) as? UDBaseSectionViewCell {
                        cell.isSelected = false
                        cell.selectionStyle = .none
                    }
                }
            }, errorStatus: { _, _ in})
        } else {
            let baseCategoriesVC : UDBaseCategoriesView = UDBaseCategoriesView()
            baseCategoriesVC.usedesk = usedesk!
            baseCategoriesVC.baseCollection = arrayCollections[indexPath.row]
            baseCategoriesVC.arrayCollections = arrayCollections
            usedesk?.uiManager?.pushViewController(baseCategoriesVC)
            if let cell = tableView.cellForRow(at: indexPath) as? UDBaseSectionViewCell {
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
            usedesk!.getSearchArticles(collection_ids: [], category_ids: [], article_ids: [], query: searchText, type: .all, sort: .title, order: .asc) { [weak self] (success, searchArticle) in
                guard let wSelf = self else {return}
                UIView.animate(withDuration: 0.3) {
                    wSelf.loadingView.alpha = 0
                }
                if success {
                    wSelf.searchArticles = searchArticle
                    wSelf.isSearch = true
                    wSelf.tableView.reloadData()
                } 
            } errorStatus: { [weak self] (_, _) in
                guard let wSelf = self else {return}
                wSelf.isSearch = false
                wSelf.tableView.reloadData()
            }
        } else {
            isSearch = false
            tableView.reloadData()
        }
    }
}
// MARK: - UDBaseArticleViewDelegate
extension UDBaseSectionsView: UDBaseArticleViewDelegate {
    func openChat() {
        if navigationController?.visibleViewController != dialogflowVC {
            isOpenOther = true
            dialogflowVC.usedesk = usedesk
            dialogflowVC.isFromBase = true
            navigationController?.pushViewController(dialogflowVC, animated: true)
        }
    }
    
    func openOfflineForm() {
        if navigationController?.visibleViewController != dialogflowVC {
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
