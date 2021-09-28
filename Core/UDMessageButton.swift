//
//  UDMessageButton.swift
//  UseDesk_SDK_Swift

import UIKit

public class UDMessageButton: NSObject, Codable {
    @objc public var title = ""
    @objc public var url = ""
    @objc public var visible = false
    
    override init() {
        super.init()
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
        try container.encode(visible, forKey: .visible)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
        visible = try container.decode(Bool.self, forKey: .visible)
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case url
        case visible
    }
}
