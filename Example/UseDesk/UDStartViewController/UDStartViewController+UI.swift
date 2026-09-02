//
//  UDStartViewController+UI.swift
//  UseDesk_Example
//

import UIKit
import IQKeyboardManagerSwift

extension UDStartViewController {

    override open func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(UDStartViewController.self)

        applyDefaultValues()

        NSLayoutConstraint.activate([
            footerBarView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        scrollView.contentInset.bottom = 74

        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.25
        startButton.layer.shadowRadius = 10
        startButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        startButton.layer.masksToBounds = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGestureRecognizer)

        var versionNumber = ""
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = "v. " + appVersion
        }
        if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionNumber += " (\(appBuild))"
        }
        versionLabel.text = versionNumber
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        keyboardHeightInView = view.convert(keyboardFrame, from: nil).height
        centerActiveField(keyboardHeight: keyboardHeightInView, animated: true, duration: duration)
    }

    fileprivate func centerActiveField(keyboardHeight: CGFloat, animated: Bool, duration: Double = 0.25) {
        guard let activeTextView else { return }
        let visibleHeight = scrollView.bounds.height - keyboardHeight
        guard visibleHeight > 0 else { return }

        let fieldFrameInScrollView = activeTextView.convert(activeTextView.bounds, to: scrollView)
        let desiredOffsetY = fieldFrameInScrollView.midY - visibleHeight / 2
        let maxOffsetY = max(0, scrollView.contentSize.height - visibleHeight)
        let clampedOffsetY = max(-scrollView.contentInset.top, min(desiredOffsetY, maxOffsetY))
        let apply = { self.scrollView.contentOffset = CGPoint(x: 0, y: clampedOffsetY) }

        if animated {
            UIView.animate(withDuration: duration, animations: apply)
        } else {
            apply()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardHeightInView = 0
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
        }
    }

    @objc func handleSingleTap(_ sender: UITapGestureRecognizer?) {
        view.endEditing(true)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setLoading(_ loading: Bool) {
        view.isUserInteractionEnabled = !loading
        startButton.isEnabled = !loading
        if loading {
            startButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            startButton.setTitle("Start chat", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
}

extension UDStartViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if activeTextView === textView {
            activeTextView = nil
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        guard textView === activeTextView, keyboardHeightInView > 0 else { return }
        DispatchQueue.main.async {
            self.centerActiveField(keyboardHeight: self.keyboardHeightInView, animated: false)
        }
    }
}

extension UDStartViewController: TabBarControllerDelegate {
    func close() {
        isCanStartSDK = true
    }
}
