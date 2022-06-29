//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    var titleTextColor: UIColor?
    var titleTextFont: UIFont?
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var statusBarStyle: UIStatusBarStyle = .default
    var isFileVC = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isFileVC ? .lightContent : statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setProperties() {
        statusBarStyle = configurationStyle.navigationBarStyle.statusBarStyle
        
        titleTextColor = configurationStyle.navigationBarStyle.textColor
        titleTextFont = configurationStyle.navigationBarStyle.font
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = configurationStyle.navigationBarStyle.backgroundColor
            appearance.titleTextAttributes = [.font: titleTextFont!,
                                              .foregroundColor: titleTextColor!]
            
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
            navigationBar.tintColor =  configurationStyle.navigationBarStyle.backButtonColor
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = configurationStyle.navigationBarStyle.backgroundColor
            navigationBar.tintColor = configurationStyle.navigationBarStyle.textColor
        }
    }
    
    func setTitleTextAttributes() {
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let textColor = titleTextColor {
            attributes[.foregroundColor] = textColor
        }
        if let textFont = titleTextFont {
            attributes[.font] = textFont
        }
        navigationBar.titleTextAttributes = attributes
    }
}
