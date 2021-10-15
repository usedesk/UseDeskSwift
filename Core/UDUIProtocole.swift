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
    func reloadDialogFlow(success: Bool, feedBackStatus: UDFeedbackStatus, url: String)
    func pushViewController(_ viewController: UIViewController)
    func dismiss()
    func chatViewController() -> UIViewController?
}
