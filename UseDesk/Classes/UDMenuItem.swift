//
//  UDMenuItem.swift


import Foundation

class UDMenuItem: UIMenuItem {

    var indexPath: IndexPath?
    
    class func indexPath(_ menuController: UIMenuController?) -> IndexPath? {
        let menuItem = menuController?.menuItems?.first as? UDMenuItem
        return menuItem?.indexPath
    }
}
