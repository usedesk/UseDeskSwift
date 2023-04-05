//
//  UDUIProtocole.swift
//  UseDesk_SDK_Swift
//
//

import Foundation
import UIKit

public protocol UDUIProtocole {
    func resetUI()
    func showNoInternet()
    func closeNoInternet()
    func startBaseFlow(in parentController: UIViewController?)
    func reloadBaseFlow(success: Bool)
    func startDialogFlow(in parentController: UIViewController?, isFromBase: Bool)
    func reloadDialogFlow(success: Bool, feedBackStatus: UDFeedbackStatus?)
    func pushViewController(_ viewController: UIViewController)
    func dismiss()
    func chatViewController() -> UIViewController?
    func baseNavigationController() -> UINavigationController?
    func visibleViewController() -> UIViewController?
}
