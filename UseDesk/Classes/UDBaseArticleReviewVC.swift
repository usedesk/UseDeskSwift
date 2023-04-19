//
//  UDBaseArticleReviewVC.swift

import Foundation
import UIKit

protocol UDBaseArticleReviewVCDelegate: AnyObject {
    func sendedReview()
}

class UDBaseArticleReviewVC: UDBaseKnowledgeVC, UIScrollViewDelegate, UITextViewDelegate {

    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var topNavigateBackgroundView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBC: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleSmallLabel: UILabel!
    @IBOutlet weak var titleSmallLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleSmallLabelTC: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonHC: NSLayoutConstraint!
    @IBOutlet weak var backButtonWC: NSLayoutConstraint!
    @IBOutlet weak var backButtonTopC: NSLayoutConstraint!
    @IBOutlet weak var backButtonLC: NSLayoutConstraint!
    
    @IBOutlet weak var titleBigLabel: UILabel!
    @IBOutlet weak var titleBigLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleBigLabelTopC: NSLayoutConstraint!
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var tagsCollectionViewHC: NSLayoutConstraint!
    @IBOutlet weak var tagsCollectionViewTopC: NSLayoutConstraint!
    
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet weak var reviewViewHC: NSLayoutConstraint!
    @IBOutlet weak var reviewViewTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewTextViewTopC: NSLayoutConstraint!
    @IBOutlet weak var reviewTextViewLC: NSLayoutConstraint!
    @IBOutlet weak var reviewTextViewTC: NSLayoutConstraint!
    @IBOutlet weak var reviewTextViewBC: NSLayoutConstraint!
    @IBOutlet weak var reviewViewBC: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UDNextBottomButton!
    @IBOutlet weak var sendButtonLC: NSLayoutConstraint!
    @IBOutlet weak var sendButtonTC: NSLayoutConstraint!
    @IBOutlet weak var sendButtonBC: NSLayoutConstraint!
    @IBOutlet weak var sendButtonHC: NSLayoutConstraint!
    
    var tags: [String] = []
    var selectedIndexTags: [Int] = []
    var article: UDArticle? = nil
    weak var delegate: UDBaseArticleReviewVCDelegate?

    private var gestureCommentTable: UIGestureRecognizer!
    private var keyboardHeight: CGFloat = 336
    private var keyboardAnimateDuration: CGFloat = 0.4
    private var isShowKeyboard = false
    private var heightWebView: CGFloat = 0
    private var offsetScrollView: CGFloat = 0
    private var lastTextViewStartPositionCursor: CGFloat = 0
    private var lastTextViewEndPositionCursor: CGFloat = 0
    private var isMovedStartPositionCursor = false
    
    private var baseArticleReviewStyle: BaseArticleReviewStyle = BaseArticleReviewStyle()

    convenience init() {
        let nibName: String = "UDBaseArticleReviewVC"
        self.init(nibName: nibName, bundle: BundleId.bundle(for: nibName))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gestureCommentTable = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        if isFirstLoaded {
            setSendButton()
        }
        super.viewDidAppear(animated)
        isFirstLoaded = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            if previousOrientation != .portrait {
                safeAreaInsetsLeftOrRight = 0
                previousOrientation = .portrait
                updateViewsBeforeChangeOrientationWindow()
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
                updateViewsBeforeChangeOrientationWindow()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard baseArticleReviewStyle.isNeedTags else {return}
        if keyPath == #keyPath(UICollectionView.contentSize) {
            if let newvalue = change?[.newKey] {
                let newsize  = newvalue as! CGSize
                tagsCollectionViewHC.constant = newsize.height
            }
        }
    }
    
    deinit {
        tagsCollectionView.removeObserver(self, forKeyPath: "contentSize")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Configure
    @objc func keyboardShow(_ notification: NSNotification) {
        if !isShowKeyboard {
            let info = notification.userInfo
            let keyboard: CGRect? = (info?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            keyboardHeight = keyboard?.size.height ?? 336
            keyboardAnimateDuration = CGFloat(TimeInterval((info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0))
            scrollView.addGestureRecognizer(gestureCommentTable)
            self.isShowKeyboard = true
        }
    }

    @objc func keyboardHide(_ notification: NSNotification) {
        if isShowKeyboard {
            scrollView.removeGestureRecognizer(gestureCommentTable)
            isShowKeyboard = false
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func firstState() {
        tagsCollectionView.register(UINib(nibName: "UDBaseArticleReviewTagCell", bundle: BundleId.thisBundle), forCellWithReuseIdentifier: "UDBaseArticleReviewTagCell")
        tagsCollectionView.addObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize), options: .new, context: nil)
        
        safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        scrollView.delegate = self
        
        topNavigateBackgroundView.backgroundColor = baseStyle.backgroundColor
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        self.modalPresentationStyle = .formSheet
        configurationStyle = usedesk?.configurationStyle ?? ConfigurationStyle()
        baseArticleReviewStyle = configurationStyle.baseArticleReviewStyle
        baseStyle = configurationStyle.baseStyle
        
        scrollViewBC.constant = baseStyle.windowBottomMargin
        self.view.backgroundColor = baseStyle.backgroundColor
        scrollView.delegate = self
        titleSmallLabel.text = usedesk?.model.stringFor("ArticleReviewTitle")
        titleSmallLabel.textColor = baseStyle.titleSmallColor
        titleSmallLabel.font = baseStyle.titleSmallFont
        titleSmallLabelLC.constant = baseStyle.titleSmallMargin.left
        titleSmallLabelTC.constant = baseStyle.titleSmallMargin.right
        titleSmallLabel.alpha = 0

        backButton.setImage(baseStyle.backButtonImage, for: .normal)
        backButton.setTitle("", for: .normal)
        backButtonHC.constant = baseStyle.backButtonSize.height
        backButtonWC.constant = baseStyle.backButtonSize.width
        backButtonTopC.constant = safeAreaInsets.top + baseStyle.backButtonMargin.top
        backButtonLC.constant = baseStyle.backButtonMargin.left
        
        setSendButton()
        
        setViews()
        
        super.firstState()
    }

    func setViews() {
        setTitleBigLabel()
        setTags()
        setReviewView()
    }
    
    func setTitleBigLabel() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        titleBigLabel.numberOfLines = 0
        titleBigLabel.textColor = baseStyle.titleBigColor
        titleBigLabel.font = baseStyle.titleBigFont
        titleBigLabel.text = usedesk?.model.stringFor("ArticleReviewTitle")
        
        titleBigLabelTopC.constant = baseStyle.titleBigMarginTop + topNavigateView.frame.height
        titleBigLabelLC.constant = baseStyle.contentMarginLeft
        titleBigLabelTC.constant = baseStyle.contentMarginRight
    }
    
    func setTags() {
        if baseArticleReviewStyle.isNeedTags {
            tags = baseArticleReviewStyle.tags.count > 0 ? baseArticleReviewStyle.tags : baseArticleReviewStyle.tags(locale: usedesk?.model.localeIdentifier ?? "")
            tagsCollectionViewTopC.constant = baseArticleReviewStyle.tagsViewMarginTop
            tagsCollectionView.reloadData()
        } else {
            tags = []
            tagsCollectionViewHC.constant = 0
        }
    }

    func setReviewView() {
        reviewView.backgroundColor = baseArticleReviewStyle.reviewViewBackground
        reviewViewTopC.constant = baseArticleReviewStyle.reviewViewMarginTop
        // Text View
        reviewTextView.delegate = self
        reviewTextView.layer.borderWidth = 0
        reviewTextView.font = baseArticleReviewStyle.reviewTextFont
        reviewTextView.textColor = baseArticleReviewStyle.reviewTextColor
        reviewTextView.textContainerInset = .zero
        reviewTextView.contentInset = .zero
        reviewTextViewTopC.constant = baseArticleReviewStyle.reviewTextMargin.top
        reviewTextViewBC.constant = baseArticleReviewStyle.reviewTextMargin.bottom
        reviewTextViewLC.constant = baseArticleReviewStyle.reviewTextMargin.left
        reviewTextViewTC.constant = baseArticleReviewStyle.reviewTextMargin.right
        if reviewTextView.text.count == 0 {
            reviewTextView.text = usedesk?.model.stringFor("ArticleReviewPlaceholder") ?? ""
            reviewTextView.textColor = baseArticleReviewStyle.reviewPlaceholderColor
        }
        let heightReviewTextView = reviewTextView.text.size(availableWidth: reviewTextView.frame.width, attributes: [.font : baseArticleReviewStyle.reviewTextFont]).height
        reviewViewHC.constant = heightReviewTextView + baseArticleReviewStyle.reviewTextMargin.top + baseArticleReviewStyle.reviewTextMargin.bottom
        reviewViewBC.constant = baseArticleReviewStyle.reviewSendButtonMargin.bottom + safeAreaInsets.bottom + baseArticleReviewStyle.reviewSendButtonHeight + 40
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        reviewView.udSetShadowFor(style: configurationStyle.baseStyle)
        reviewView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapReviewView)))
    }
    
    func setSendButton() {
        sendButton.configure(title: usedesk?.model.stringFor("Send") ?? "", superview: self.view, safeAres: self.view.safeAreaInsets, backgroundColor: baseArticleReviewStyle.reviewSendButtonColor, cornerRadius: baseArticleReviewStyle.reviewSendButtonCornerRadius, titleFont: baseArticleReviewStyle.reviewSendButtonTitleFont, titleColorNormal: baseArticleReviewStyle.reviewSendButtonTitleColorNormal, titleColorHighlighted: baseArticleReviewStyle.reviewSendButtonTitleColorHighlighted)
        sendButtonLC.constant = baseArticleReviewStyle.reviewSendButtonMargin.left
        sendButtonTC.constant = baseArticleReviewStyle.reviewSendButtonMargin.right
        sendButtonBC.constant = baseArticleReviewStyle.reviewSendButtonMargin.bottom
        sendButtonHC.constant = baseArticleReviewStyle.reviewSendButtonHeight
    }
    
    override func setChatButton() {
        chatButton.alpha = 0
    }
    
    override func updateViewsBeforeChangeOrientationWindow() {
        if !isFirstLoaded {
            DispatchQueue.main.async {
                self.safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
                self.backButtonTopC.constant = self.safeAreaInsets.top + self.baseStyle.backButtonMargin.top
                self.sendButtonBC.constant = self.baseArticleReviewStyle.reviewSendButtonMargin.bottom
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.titleBigLabelTopC.constant = self.baseStyle.titleBigMarginTop + self.topNavigateView.frame.height
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                self.updateVisibleBlurView()
            }
        }
    }
    
    func updateContentOffsetScrollView() {
        let textViewStartPositionCursor = (reviewTextView.caretRect(for: reviewTextView.selectedTextRange!.start).origin.y)
        let textViewEndPositionCursor = (reviewTextView.caretRect(for: reviewTextView.selectedTextRange!.end).origin.y)
        var isChangeStartPositionCursor = false
        var isChangeEndPositionCursor = false
        if textViewStartPositionCursor != lastTextViewStartPositionCursor {
            lastTextViewStartPositionCursor = textViewStartPositionCursor
            isChangeStartPositionCursor = true
        }
        if textViewEndPositionCursor != lastTextViewEndPositionCursor {
            lastTextViewEndPositionCursor = textViewEndPositionCursor
            isChangeEndPositionCursor = true
        }
        guard !isFirstLoaded else {return}
        if isChangeStartPositionCursor {
            if textViewStartPositionCursor <= 0 {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y = self.reviewView.frame.origin.y - self.topNavigateView.frame.height - 40
                }
            } else {
                let textViewStartPositionCursorFromWindow = textViewStartPositionCursor + reviewTextView.frame.origin.y + reviewView.frame.origin.y - scrollView.contentOffset.y - topNavigateView.frame.height
                if textViewStartPositionCursorFromWindow < 0 {
                    UIView.animate(withDuration: 0.4) {
                        self.scrollView.contentOffset.y += textViewStartPositionCursorFromWindow
                    }
                } else if textViewStartPositionCursorFromWindow > (scrollView.frame.height - topNavigateView.frame.height - keyboardHeight - 60) {
                    UIView.animate(withDuration: 0.4) {
                        self.scrollView.contentOffset.y += textViewStartPositionCursorFromWindow - (self.scrollView.frame.height - self.topNavigateView.frame.height - self.keyboardHeight - 60)
                    }
                }
            }
        } else if isChangeEndPositionCursor && !textViewEndPositionCursor.isInfinite {
            let textViewEndPositionCursorFromWindow = textViewEndPositionCursor + reviewTextView.frame.origin.y + reviewView.frame.origin.y - scrollView.contentOffset.y - topNavigateView.frame.height
            if textViewEndPositionCursorFromWindow > (scrollView.frame.height - topNavigateView.frame.height - keyboardHeight - 60) {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y += textViewEndPositionCursorFromWindow - (self.scrollView.frame.height - self.topNavigateView.frame.height - self.keyboardHeight - 60)
                }
            } else if textViewEndPositionCursor <= 0 {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y = self.reviewView.frame.origin.y - self.topNavigateView.frame.height - 40
                }
            } else if textViewEndPositionCursorFromWindow < 0 {
                UIView.animate(withDuration: 0.4) {
                    self.scrollView.contentOffset.y += textViewEndPositionCursorFromWindow
                }
            }
        }
    }
    
    func updateHeightReviewAndContentViews(with newText: String? = nil) {
        var text: String = ""
        if newText != nil {
            text = newText!
        } else {
            text = reviewTextView.text
        }
        text = text.count > 0 ? text : "T"
        let heightReviewView = text.size(availableWidth: reviewTextView.frame.width - 10, attributes: [.font : baseArticleReviewStyle.reviewTextFont]).height + baseArticleReviewStyle.reviewTextMargin.top + baseArticleReviewStyle.reviewTextMargin.bottom
        guard heightReviewView != reviewViewHC.constant else {return}
        reviewViewHC.constant = heightReviewView
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        reviewView.udSetShadowFor(style: configurationStyle.baseStyle)
        updateContentOffsetScrollView()
    }
    
    func updateVisibleSmallTitleLabel() {
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
    
    func updateVisibleBlurView() {
        if scrollView.contentOffset.y > titleBigLabel.frame.height + baseStyle.titleBigMarginTop {
            blurView.alpha = 1
            let coefficient: CGFloat = 100 / 50
            var procent = coefficient * (scrollView.contentOffset.y - (titleBigLabel.frame.height + baseStyle.titleBigMarginTop))
            if procent > 100 {
                procent = 100
            }
            let alphaValue = procent / 100
            topNavigateBackgroundView.alpha = 1 - alphaValue + baseStyle.topBlurСoefficient
        } else {
            blurView.alpha = 0
            topNavigateBackgroundView.alpha = 1
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.layoutIfNeeded()
        updateVisibleSmallTitleLabel()
        updateVisibleBlurView()
    }
    
    override func backAction() {
        self.navigationController?.popViewController(animated: true)
        self.removeFromParent()
    }

    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var newText: String = textView.text
        if range.length > 0 {
            let startIndex = newText.index(newText.startIndex, offsetBy: range.location)
            let endIndex = newText.index(newText.startIndex, offsetBy: range.location + range.length)
            newText.removeSubrange(startIndex..<endIndex)
        }
        if text.count > 0 {
            let insertIndex = newText.index(textView.text.startIndex, offsetBy: range.location)
            newText.insert(contentsOf:text, at: insertIndex)
        }
        updateHeightReviewAndContentViews(with: newText)
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        updateContentOffsetScrollView()
        if reviewTextView.textColor != baseArticleReviewStyle.reviewTextColor {
            UIView.animate(withDuration: 0.2) {
                self.reviewTextView.textColor = self.baseArticleReviewStyle.reviewTextColor
                self.reviewTextView.text = ""
            }
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if reviewTextView.text.count == 0 {
            UIView.animate(withDuration: 0.2) {
                self.reviewTextView.text = self.usedesk?.model.stringFor("ArticleReviewPlaceholder") ?? ""
                self.reviewTextView.textColor = self.baseArticleReviewStyle.reviewPlaceholderColor
            }
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        updateContentOffsetScrollView()
    }

    // MARK: - User actions
    @objc func tapReviewView() {
        if !reviewTextView.isFirstResponder {
            reviewTextView.becomeFirstResponder()
        }
    }

    @IBAction func sendReviewAction(_ sender: Any) {
        guard usedesk?.reachability != nil else {return}
        guard usedesk?.reachability?.connection != .unavailable else {
            showAlertNoInternet()
            return
        }
        if reviewTextView.text.count > 0 {
            sendButton.showLoader()
            dismissKeyboard()
            guard article != nil && usedesk != nil else {return}
            var message = ""
            if selectedIndexTags.count > 0 {
                message = (usedesk?.model.stringFor("ReviewTagsTitle") ?? "") + " "
                selectedIndexTags = selectedIndexTags.sorted()
                message += "\(tags[selectedIndexTags[0]])"
                for index in 1..<selectedIndexTags.count {
                    if selectedIndexTags[index] < tags.count {
                        message += ", \(tags[selectedIndexTags[index]])"
                    }
                }
                message += "\n"
            }
            message += (usedesk?.model.stringFor("Comment") ?? "") + " " + reviewTextView.text
            usedesk?.sendReviewArticleMesssage(articleID: article!.id, message: message) { [weak self] (success) in
                guard let wSelf = self else {return}
                wSelf.sendButton.closeLoader()
                wSelf.delegate?.sendedReview()
                wSelf.backAction()
            } errorStatus: { [weak self] _, _ in
                guard let wSelf = self else {return}
                wSelf.sendButton.closeLoader()
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Collection
extension UDBaseArticleReviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDBaseArticleReviewTagCell", for: indexPath) as! UDBaseArticleReviewTagCell
        cell.configurationStyle = configurationStyle
        cell.setCell(text: tags[indexPath.row], isSelected: selectedIndexTags.contains(indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width = tags[indexPath.row].size( attributes: [.font : baseArticleReviewStyle.tagTextFont]).width
        width += baseArticleReviewStyle.tagTextMargin.left + baseArticleReviewStyle.tagTextMargin.right
        var height = "Tp".size( attributes: [.font : baseArticleReviewStyle.tagTextFont]).height
        height += baseArticleReviewStyle.tagTextMargin.top + baseArticleReviewStyle.tagTextMargin.bottom
        if width > tagsCollectionView.frame.width {
            width = tagsCollectionView.frame.width
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = tagsCollectionView.cellForItem(at: indexPath) as? UDBaseArticleReviewTagCell {
            if selectedIndexTags.contains(indexPath.row) {
                if let index = selectedIndexTags.firstIndex(of: indexPath.row) {
                    selectedIndexTags.remove(at: index)
                    cell.setNotSelected()
                }
            } else {
                selectedIndexTags.append(indexPath.row)
                cell.setSelected()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return configurationStyle.baseArticleReviewStyle.tagLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return configurationStyle.baseArticleReviewStyle.tagInteritemSpacing
    }
}

// MARK: - UDNextBottomButton
class UDNextBottomButton: UIButton {
    private let loader = UIActivityIndicatorView()
    private var titleBeforeShowLoader = ""
    
    func configure(title: String = "", superview: UIView, safeAres: UIEdgeInsets, backgroundColor: UIColor, cornerRadius: CGFloat, titleFont: UIFont, titleColorNormal: UIColor, titleColorHighlighted: UIColor) {
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        setTitleColor(titleColorNormal, for: .normal)
        setTitleColor(titleColorHighlighted, for: .highlighted)
        titleLabel?.font = titleFont
        setTitle(title, for: .normal)
        loader.style = .white
        loader.frame = CGRect(x: ((self.frame.width / 2) - 10), y: ((self.frame.height / 2) - 10), width: 20, height: 20)
        self.addSubview(loader)
    }
    
    func showLoader(isDelete: Bool = false) {
        guard self.isEnabled else {return}
        self.isEnabled = false
        titleBeforeShowLoader = self.titleLabel?.text ?? ""
        UIView.animate(withDuration: 0.3) {
            self.setTitle("", for: .normal)
            self.loader.alpha = 1
            self.loader.startAnimating()
        }
    }

    func closeLoader() {
        guard !self.isEnabled else {return}
        self.isEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.setTitle(self.titleBeforeShowLoader, for: .normal)
            self.loader.alpha = 0
            self.loader.stopAnimating()
        }
    }

}

// MARK: - LeftAlignedCollectionViewFlowLayout
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
