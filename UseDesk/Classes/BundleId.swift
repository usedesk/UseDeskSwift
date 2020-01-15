//
//  BundleId.swift
//  Alamofire
//
//  Created by Andrew on 13/01/2020.
//

import Foundation

public class BundleId {
    
    public init() { }
    
    public func thisBundle() -> Bundle {
        var bundle: Bundle
        let podBundle = Bundle(for: type(of: self))
        if let bundleURL = podBundle.url(forResource: "UseDesk_SDK_Swift", withExtension: "bundle") {
            bundle = Bundle(url: bundleURL) ?? .main
        } else {
            bundle = podBundle
        }
        
        return bundle
    }
}
