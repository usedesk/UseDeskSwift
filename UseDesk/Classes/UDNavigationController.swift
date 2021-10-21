//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    var tintColor: UIColor?
    var titleTextColor: UIColor?
    var titleTextFont: UIFont?
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var isDark = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isDark ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setProperties() {
        isDark = configurationStyle.navigationBarStyle.statusBarStyle == .default ? false : true
        
        navigationBar.isTranslucent = false
        
        tintColor = configurationStyle.navigationBarStyle.textColor
        
        titleTextColor = configurationStyle.navigationBarStyle.textColor
        titleTextFont = configurationStyle.navigationBarStyle.font

        if #available(iOS 13.0, *) {
            let navBar = self.navigationBar

            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [
                .foregroundColor: configurationStyle.navigationBarStyle.textColor,
                .font: configurationStyle.navigationBarStyle.font,
            ]
            appearance.backgroundColor = configurationStyle.navigationBarStyle.backgroundColor

            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = navBar.standardAppearance
        } else {
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
