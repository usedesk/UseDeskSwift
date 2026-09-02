//
//  BundleId.swift
//  Alamofire

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
