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
    
}
