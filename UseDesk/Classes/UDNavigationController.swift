//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    var barTintColor: UIColor?
    var tintColor: UIColor?
    var titleTextColor: UIColor?
    var titleTextFont: UIFont?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        
        tintColor = (tintColor != nil) ? tintColor : navBarTextColor
        
        titleTextColor = titleTextColor ?? navBarTextColor
        titleTextFont = titleTextFont ?? navBarTextFont
        
        barTintColor = (barTintColor != nil) ? barTintColor : navBarBackgroundColor
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
