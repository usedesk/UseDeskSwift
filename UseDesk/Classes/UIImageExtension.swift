//
//  UIImageExtension.swift
//  Alamofire
//
//  Created by Сергей on 15.01.2020.
//

import Foundation
import UIKit

extension UIImage {
    
    static func named(_ imageNamed: String) -> UIImage {
        if let image = UIImage(named: imageNamed) {
            return image
        } else {
            let bundle: Bundle = BundleId().thisBundle()
            
            if let image = UIImage(named: imageNamed, in: bundle, compatibleWith: nil) {
                return image
            } else {
                return UIImage()
            }
        }
    }
}
