//
//  BundleId.swift
//  Alamofire
//
//  Created by Andrew on 13/01/2020.
//

import Foundation

public class BundleId {
    
    public init() { }
    
    public static let thisBundle: Bundle = {
        let bundle: Bundle
        let podBundle: Bundle = Bundle(for: BundleId.self)
        if let bundleURL: URL = podBundle.url(forResource: "UseDesk", withExtension: "bundle") {
            bundle = Bundle(url: bundleURL) ?? .main
        } else {
            bundle = podBundle
        }
        
        return bundle
    }()
    
    /// Method searches for xib in bundle of application, which added UseDesk as pod, and then falls back for xib's in this bundle. This allows users to provide custom xib designs without making classes, inited from xibs, public.
    static func bundle(for nibName: String) -> Bundle {
        let bundle: Bundle
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            bundle = Bundle.main
        } else {
            bundle = thisBundle
        }
        return bundle
    }
}
