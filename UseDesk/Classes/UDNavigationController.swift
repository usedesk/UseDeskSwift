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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    override var tintColor: UIColor? {
//        get {
//            return super.tintColor
//        }
//        set(__tintColor) {
//            tintColor = __tintColor
//            navigationBar.tintColor = tintColor
//        }
//    }
//    
//    override var barTintColor: UIColor? {
//        get {
//            return super.barTintColor
//        }
//        set(__barTintColor) {
//            barTintColor = __barTintColor
//            navigationBar.barTintColor = barTintColor
//        }
//    }
    
    func setTitleTextAttributes(_ __titleTextAttributes: UIColor?) {
        titleTextAttributes = __titleTextAttributes
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleTextAttributes!]
    }
}
