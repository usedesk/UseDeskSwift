//
//  UDNavigationController.swift

import Foundation

class UDNavigationController: UINavigationController {

    var barTintColor: UIColor?
    var tintColor: UIColor?
    var titleTextAttributes: UIColor?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        
        tintColor = (tintColor != nil) ? tintColor : navBarTextColor
        
        titleTextAttributes = (titleTextAttributes != nil) ? titleTextAttributes : navBarTextColor
        
        barTintColor = (barTintColor != nil) ? barTintColor : navBarBackgroundColor
    }
    
    func setTitleTextAttributes() {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleTextAttributes!]
    }
}
