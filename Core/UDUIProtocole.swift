//
//  UDUIProtocole.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import UIKit

public protocol UDUIProtocole {
    func resetUI()

    func showBaseView(in parentController: UIViewController?, url: String?)
    func startDialogFlow(in parentController: UIViewController?)
    func reloadDialogFlow(success: Bool, error: String?, url: String, in parentController: UIViewController?)
    func pushViewController(_ viewController: UIViewController)
    func dismiss()
}
