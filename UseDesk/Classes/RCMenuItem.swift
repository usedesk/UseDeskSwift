//
//  RCMenuItem.swift


import Foundation

class RCMenuItem: UIMenuItem {

    var indexPath: IndexPath?
    
    class func indexPath(_ menuController: UIMenuController?) -> IndexPath? {
        let menuItem = menuController?.menuItems?.first as? RCMenuItem
        return menuItem?.indexPath
    }
}
