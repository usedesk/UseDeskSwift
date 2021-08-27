//
//  File.swift
//  
//
//  Created by Leonid Liadveikin on 27.08.2021.
//

import Foundation
import UIKit

class UDLoader: NSObject {
    var loader = UIActivityIndicatorView()
    var view: UIView!
    var backView = UIView()
    var alphaBackView: CGFloat!
    var colorBackView: UIColor!

    public init(view: UIView, colorBackView: UIColor, alphaBackView: CGFloat) {
        self.view = view
        self.alphaBackView = alphaBackView
        self.colorBackView = colorBackView
    }

    func show() {
        if #available(iOS 13.0, *) {
            loader.style = .large
        } else {
            loader.style = .whiteLarge
        }
        loader.startAnimating()
        loader.alpha = 7
        backView.backgroundColor = colorBackView
        backView.alpha = alphaBackView
        backView.clipsToBounds = true
        backView.frame.size = CGSize(width: 50, height: 50)
        backView.center = view.center
        backView.layer.cornerRadius = 25
        view.addSubview(backView)
        backView.addSubview(loader)
        loader.center = CGPoint(x: 26.5, y: 26.5)
    }

    func hide(animated: Bool = false) {
        loader.stopAnimating()
        loader.alpha = 0
        backView.removeFromSuperview()
        backView.alpha = 0
    }
}
