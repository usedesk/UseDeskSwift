//
//  UDUIViewExtension.swift
//  UseDesk_SDK_Swift
//

import UIKit

extension UIView {
    
    func udImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func udSetShadowFor(style: BaseStyle) {
        layer.masksToBounds = false
        layer.cornerRadius = style.contentViewsCornerRadius
        layer.shadowColor = style.contentViewsShadowColor
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowOffset = style.contentViewsShadowOffset
        layer.shadowOpacity = style.contentViewsShadowOpacity
        layer.shadowRadius = style.contentViewsShadowRadius
    }
    
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: forState)
        }
    }
}
