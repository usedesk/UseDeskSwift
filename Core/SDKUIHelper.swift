//
//  File.swift
//  
//
//  Created by Leonid Liadveikin on 27.08.2021.
//

import Foundation
import UIKit

public protocol SDKUIHelper {
    func resetUI()
    func showLoader()
    func hideLoader()

    func showBaseView(in parentController: UIViewController?, url: String?)
    func startDialogFlow(success: Bool, error: String?, url: String, in parentController: UIViewController?)
    func pushViewController(_ viewController: UIViewController)
    func dismiss()
}
