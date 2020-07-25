//
//  Settings.swift

import Foundation
// MARK: - Navigation Bar
public var navBarBackgroundColor = UIColor(hexString: "d0585d")
public var navBarTextColor: UIColor = .white
public var navBarTextFont: UIFont?
public var statusBarStyle: UIStatusBarStyle?
public var backButtonImage: UIImage?
// MARK: - Base
// Base Search Bar
public var searchBarTextBackgroundColor = UIColor.white
public var searchBarTextColor = UIColor.black
public var searchBarTintColor = UIColor.blue
public var searchBarPlaceholderText = "Поиск"
// Base chat button
public var chatButtonText = "Чат"
// Image picker
public enum SupportedAttachmentType {
    case any, onlyPhoto, onlyVideo
}
public var supportedAttachmentTypes: SupportedAttachmentType = .any

struct Constants {
    static let maxCountAssets: Int = 10
    static let heightAssetsCollection: CGFloat = 68
}
