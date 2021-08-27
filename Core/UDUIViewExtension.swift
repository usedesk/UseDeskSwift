//
//  UDUIViewExtension.swift
//  UseDesk_SDK_Swift
//

import UIKit

extension UIView {
    
    func stretch(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    func cornerRadiusFromChatWithoutBottomLeft(cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners:[.topRight, .topLeft, .bottomRight],
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func cornerRadiusFromChatWithoutBottomRight(cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners:[.topRight, .topLeft, .bottomLeft],
                                cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
}
