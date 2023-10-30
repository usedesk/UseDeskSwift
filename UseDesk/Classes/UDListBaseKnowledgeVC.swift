//
//  UDBaseKnowledgeVC.swift
//  UseDesk_SDK_Swift

import Foundation
import UIKit

class UDListBaseKnowledgeVC: UDBaseKnowledgeVC, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    // Loader
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // Blur View
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    // Top Navigate View
    @IBOutlet weak var topNavigateBackgroundView: UIView!
    //   Back Button
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonWC: NSLayoutConstraint!
    @IBOutlet weak var backButtonHC: NSLayoutConstraint!
    @IBOutlet weak var backButtonLC: NSLayoutConstraint!
    @IBOutlet weak var backButtonTopC: NSLayoutConstraint!
    //   Title Label
    @IBOutlet weak var titleSmallLabel: UILabel!
    @IBOutlet weak var titleSmallLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleSmallLabelTC: NSLayoutConstraint!
    
    // Search View
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewTopC: NSLayoutConstraint!
    @IBOutlet weak var searchViewTopCForSafeArea: NSLayoutConstraint!
    @IBOutlet weak var searchBackgroundView: UIView!
    @IBOutlet weak var searchSeparatorView: UIView!
    //   Search Bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    //   Search Not Found Label
    @IBOutlet weak var searchNotFoundLabel: UILabel!
    @IBOutlet weak var searchNotFoundLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var searchNotFoundLabelLC: NSLayoutConstraint!
    @IBOutlet weak var searchNotFoundLabelTC: NSLayoutConstraint!
    
    // Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    //   Title Big
    @IBOutlet weak var titleBigLabel: UILabel!
    @IBOutlet weak var titleBigLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTopC: NSLayoutConstraint!
    //   Table
    @IBOutlet weak var viewForTable: UIView!
    @IBOutlet weak var viewForTableTopC: NSLayoutConstraint!
    @IBOutlet weak var viewForTableTopCForSuperView: NSLayoutConstraint!
    @IBOutlet weak var tableViewHC: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    var titleVC: String = ""
    var arrayCollections: [UDBaseCollection] = []
    var isUpdatedValues = false
    
    private var searchArticles: UDSearchArticle? = nil
    private var isSearchState: Bool = false
    private var isSearch: Bool = false
    private var isOpenOther = false
    private var openedArticle: UDArticle?
    private var topSearchViewTopCZeroPosition: CGFloat = 0
    private var timer: Timer?
    private var tapGestureCloseSearch = UITapGestureRecognizer()

    convenience init() {
        let nibName: String = "UDListBaseKnowledgeVC"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstState()
        setChatButton()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newvalue = change?[.newKey] {
                configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
                let newsize = newvalue as! CGSize
                tableViewHC.constant = newsize.height
                viewForTable.backgroundColor = baseStyle.contentViewsBackgroundColor
                viewForTable.udSetShadowFor(style: baseStyle)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewDidAppear(animated)
        updateViews()
    }
    
    // MARK: - Configure
    override func firstState() {
        guard usedesk != nil else {return}
        modalPresentationStyle = .fullScreen
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        baseStyle = configurationStyle.baseStyle
        
        scrollViewBC.constant = baseStyle.windowBottomMargin
        
        view.backgroundColor = baseStyle.backgroundColor
        
        loader.style = baseStyle.loaderStyle
        loader.alpha = 1
        loader.startAnimating()
        
        safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        scrollView.delegate = self
        scrollView.bounds.origin.y = 0
        tapGestureCloseSearch = UITapGestureRecognizer(target: self, action: #selector(self.closeSearchState))
        
        backButton.alpha = 1
        backButton.setTitle("", for: .normal)
        backButton.setImage(baseStyle.backButtonImage, for: .normal)
        backButtonTopC.constant = safeAreaInsets.top + baseStyle.backButtonMargin.top
        backButtonLC.constant = baseStyle.backButtonMargin.left
        backButtonHC.constant = baseStyle.backButtonSize.height
        backButtonWC.constant = baseStyle.backButtonSize.width
        
        topNavigateBackgroundView.backgroundColor = baseStyle.backgroundColor
        
        searchBackgroundView.backgroundColor = baseStyle.backgroundColor
        let titleBigHeight = titleVC.size(availableWidth: UIScreen.main.bounds.width - baseStyle.contentMarginLeft - baseStyle.contentMarginRight, attributes: [.font : baseStyle.titleBigFont]).height
        topSearchViewTopCZeroPosition = titleBigHeight + baseStyle.titleBigMarginTop
        searchViewTopC.constant = topSearchViewTopCZeroPosition        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        titleSmallLabel.alpha = 0
        titleSmallLabel.text = titleVC
        titleSmallLabel.textColor = baseStyle.titleSmallColor
        titleSmallLabel.font = baseStyle.titleSmallFont
        titleSmallLabelLC.constant = baseStyle.contentMarginLeft
        titleSmallLabelTC.constant = baseStyle.contentMarginRight
        
        titleBigLabel.text = titleVC
        titleBigLabel.textColor = baseStyle.titleBigColor
        titleBigLabel.font = baseStyle.titleBigFont
        titleBigLabelLC.constant = baseStyle.contentMarginLeft
        titleBigLabelTC.constant = baseStyle.contentMarginRight
        titleBigLabelTopC.constant = baseStyle.titleBigMarginTop + topNavigateView.frame.height
        
        viewForTableTopC.constant = baseStyle.tableMarginTop + searchBar.frame.height
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = baseStyle.contentViewsCornerRadius
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        tableView.register(UINib(nibName: "UDBaseSearchCell", bundle: BundleId.thisBundle), forCellReuseIdentifier: "UDBaseSearchCell")
        
        searchBar.alpha = 0
        searchBar.placeholder = usedesk!.model.stringFor("Search")
        searchBar.delegate = self
        searchBar.tintColor = baseStyle.searchBarTintColor
        searchBar.frame.size.width = UIScreen.main.bounds.width - baseStyle.contentMarginLeft - baseStyle.contentMarginRight
        searchBar.directionalLayoutMargins = .zero
        searchBar.setValue(usedesk?.model.stringFor("Cancel") ?? "Cancel", forKey: "cancelButtonText")
        let textFieldTopSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldTopSearchBar?.backgroundColor = .clear
        textFieldTopSearchBar?.textColor = baseStyle.searchBarTextColor
        searchSeparatorView.backgroundColor = baseStyle.searchSeparatorColor
        searchSeparatorView.alpha = 0
        searchNotFoundLabel.text = usedesk?.model.stringFor("SearchFail") ?? ""
        searchNotFoundLabel.textColor = baseStyle.searchNotFoundLabelColor
        searchNotFoundLabelTopC.constant = baseStyle.searchNotFoundLabelMarginTop
        searchNotFoundLabelLC.constant = baseStyle.contentMarginLeft
        searchNotFoundLabelTC.constant = baseStyle.contentMarginRight
        if loader.alpha == 1 {
            updateViews()
        }
        
        super.firstState()
    }
    
    func updateValues() {
    }
    
    func updateViews() {
        isUpdatedValues = true
        if usedesk?.model.isLoadedKnowledgeBase ?? false {
            titleSmallLabel.text = titleVC
            titleBigLabel.text = titleVC
            let titleBigHeight = titleVC.size(availableWidth: UIScreen.main.bounds.width - baseStyle.contentMarginLeft - baseStyle.contentMarginRight, attributes: [.font : baseStyle.titleBigFont]).height
            topSearchViewTopCZeroPosition = titleBigHeight + baseStyle.titleBigMarginTop
            updatePositionSearchView()
            loader.alpha = 0
            loader.stopAnimating()
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.searchBar.alpha = 1
                self.viewForTable.alpha = 1
                self.view.layoutIfNeeded()
            }
            tableView.reloadData()
        } else {
            if !isCanShowNoInternet {
                loader.alpha = 0
                loader.stopAnimating()
                showAlert(usedesk!.model.stringFor("Error"), text: usedesk!.model.stringFor("ServerError"))
            }
        }
    }
    
    func showArticle(articleTitle: UDArticleTitle? = nil, article: UDArticle? = nil, indexPath: IndexPath) {
        let articleVC = UDBaseArticleView()
        articleVC.usedesk = usedesk
        if article == nil && articleTitle != nil {
            articleVC.article = UDArticle(id: articleTitle!.id, title: articleTitle!.title)
        } else {
            articleVC.article = article
        }
        usedesk?.uiManager?.pushViewController(articleVC)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
            cell.selectionStyle = .none
        }
    }
    
    func showAlert(_ title: String?, text: String?) {
        guard usedesk != nil else {return}
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: usedesk!.model.stringFor("Understand"), style: .default, handler: { [weak self] _ in
            self?.backAction()
        })
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    func showSearchState() {
        guard !isSearchState else {return}
        isSearchState = true
        scrollView.addGestureRecognizer(tapGestureCloseSearch)
        searchViewTopCForSafeArea.constant = searchViewTopC.constant
        searchViewTopCForSafeArea.isActive = true
        searchViewTopC.isActive = false
        viewForTableTopCForSuperView.constant = viewForTableTopC.constant
        viewForTableTopCForSuperView.isActive = true
        viewForTableTopC.isActive = false
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.4) {
            self.searchViewTopCForSafeArea.constant = 0
            self.viewForTableTopCForSuperView.constant = self.baseStyle.tableMarginTop + self.searchView.frame.height + self.safeAreaInsets.top
            self.backButton.alpha = 0
            self.titleSmallLabel.alpha = 0
            self.viewForTable.alpha = 0
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.15) {
            self.titleBigLabel.alpha = 0
        }
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc func closeSearchState() {
        guard isSearchState else {return}
        isSearchState = false
        isSearch = false
        scrollView.removeGestureRecognizer(tapGestureCloseSearch)
        tableView.reloadData()
        searchBar.setShowsCancelButton(false, animated: true)
        view.endEditing(true)
        scrollView.contentOffset.y = 0
        loader.alpha = 0
        loader.stopAnimating()
        UIView.animate(withDuration: 0.4) {
            self.searchViewTopCForSafeArea.isActive = false
            self.searchViewTopC.isActive = true
            self.viewForTableTopCForSuperView.isActive = false
            self.viewForTableTopC.isActive = true
            self.backButton.alpha = 1
            self.viewForTable.alpha = 1
            self.searchSeparatorView.alpha = 0
            self.searchNotFoundLabel.alpha = 0
            self.searchBar.text = ""
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.1, delay: 0.2) {
            self.titleBigLabel.alpha = 1
        }
    }
    
    override func updateViewsBeforeChangeOrientationWindow() {
        if !isFirstLoaded {
            DispatchQueue.main.async {
                self.searchViewTopC.isActive = !self.isSearchState
                self.searchViewTopCForSafeArea.isActive = self.isSearchState
                self.viewForTableTopC.isActive = !self.isSearchState
                self.viewForTableTopCForSuperView.isActive = self.isSearchState
                self.safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
                self.setChatButton()
                self.backButtonTopC.constant = self.safeAreaInsets.top + self.baseStyle.backButtonMargin.top
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.viewForTableTopCForSuperView.constant = self.baseStyle.tableMarginTop + self.searchView.frame.height + self.safeAreaInsets.top
                self.titleBigLabelTopC.constant = self.baseStyle.titleBigMarginTop + self.topNavigateView.frame.height
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func updateVisibleSmallTitleLabel() {
        guard !isSearchState else {return}
        if scrollView.contentOffset.y > (titleBigLabel.frame.height + baseStyle.titleBigMarginTop - 5) && titleSmallLabel.alpha == 0 {
            UIView.animate(withDuration: 0.2) {
                self.titleSmallLabel.alpha = 1
            }
        } else if scrollView.contentOffset.y < (titleBigLabel.frame.height + baseStyle.titleBigMarginTop - 5) && titleSmallLabel.alpha == 1 {
            UIView.animate(withDuration: 0.2) {
                self.titleSmallLabel.alpha = 0
            }
        }
    }
    
    func updatePositionSearchView() {
        if scrollView.contentOffset.y < titleBigLabel.frame.height + baseStyle.titleBigMarginTop {
            searchViewTopC.constant = topSearchViewTopCZeroPosition - scrollView.contentOffset.y
        } else {
            searchViewTopC.constant =  0
        }
    }
    
    func updateVisibleBlurView() {
        if scrollView.contentOffset.y > titleBigLabel.frame.height + baseStyle.titleBigMarginTop {
            blurView.alpha = 1
            let coefficient: CGFloat = 100 / 50
            var procent = coefficient * (scrollView.contentOffset.y - (titleBigLabel.frame.height + baseStyle.titleBigMarginTop))
            if procent > 100 {
                procent = 100
            }
            let alphaValue = procent / 100
            searchBackgroundView.alpha = 1 - alphaValue + baseStyle.topBlurСoefficient
            topNavigateBackgroundView.alpha = 1 - alphaValue + baseStyle.topBlurСoefficient
            searchSeparatorView.alpha = alphaValue
        } else {
            blurView.alpha = 0
            searchSeparatorView.alpha = 0
            topNavigateBackgroundView.alpha = 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.layoutIfNeeded()
        updatePositionSearchView()
        updateVisibleSmallTitleLabel()
        updateVisibleBlurView()
        if isSearchState && searchBar.isFirstResponder {
            view.endEditing(true)
            if let cancelButton : UIButton = self.searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
    }
    
    // MARK: - User actions
    @IBAction func backAction(_ sender: Any) {
        backAction()
    }
    
    // MARK: - TableView
    func countCell() -> Int {
        return 0
    }
    
    func getCell(indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func selectRowAt(_ indexPath: IndexPath) {
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch {
            return searchArticles?.articles.count ?? 0
        } else {
            return countCell()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UDBaseSearchCell", for: indexPath) as! UDBaseSearchCell
            cell.configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
            cell.usedesk = usedesk
            cell.setCell(article: searchArticles?.articles[indexPath.row])
            return cell
        } else {
            return getCell(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearch {
            guard searchArticles != nil else {return}
            showArticle(article: searchArticles!.articles[indexPath.row], indexPath: indexPath)
        } else {
            selectRowAt(indexPath)
        }
    }
    
    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            guard usedesk != nil else {return}
            UIView.animate(withDuration: 0.15) {
                self.loader.alpha = 1
                self.loader.startAnimating()
                self.viewForTable.alpha = 0
            }
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(getSearchArticles), userInfo: nil, repeats: false)
        } else {
            timer?.invalidate()
            scrollView.addGestureRecognizer(tapGestureCloseSearch)
            isSearch = false
            UIView.animate(withDuration: 0.15) {
                self.viewForTable.alpha = 0
                self.loader.alpha = 0
                self.loader.stopAnimating()
                self.searchNotFoundLabel.alpha = 0
            } completion: { _ in
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func getSearchArticles() {
        guard isSearchState, usedesk != nil, let guery = searchBar.text else {return}
        usedesk!.getSearchArticles(collection_ids: [], category_ids: [], article_ids: [], query: guery, type: .all, sort: .title, order: .asc) { [weak self] (success, searchArticle) in
            guard let wSelf = self else {return}
            UIView.animate(withDuration: 0.15) {
                wSelf.loader.alpha = 0
                wSelf.loader.stopAnimating()
            }
            guard wSelf.isSearchState else {
                wSelf.closeSearchState()
                return
            }
            if success {
                wSelf.isSearch = true
                if (searchArticle?.total_count ?? 0) > 0 {
                    wSelf.scrollView.removeGestureRecognizer(wSelf.tapGestureCloseSearch)
                    wSelf.searchArticles = searchArticle
                    wSelf.tableView.reloadData()
                    UIView.animate(withDuration: 0.15) {
                        wSelf.searchNotFoundLabel.alpha = 0
                        wSelf.viewForTable.alpha = 1
                    }
                } else {
                    UIView.animate(withDuration: 0.15) {
                        wSelf.searchNotFoundLabel.alpha = 1
                        wSelf.viewForTable.alpha = 0
                    }
                }
            }
        } errorStatus: { [weak self] (_, _) in
            guard let wSelf = self else {return}
            wSelf.isSearch = false
            wSelf.scrollView.addGestureRecognizer(wSelf.tapGestureCloseSearch)
            wSelf.tableView.reloadData()
            UIView.animate(withDuration: 0.15) {
                wSelf.searchNotFoundLabel.alpha = 1
                wSelf.viewForTable.alpha = 0
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        showSearchState()
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSearchState()
    }
    
}

extension UDListBaseKnowledgeVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
            navigationController?.popViewController(animated: true)
        }
        return false
    }
}
