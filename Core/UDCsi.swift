//
//  UDCsi.swift
//  UseDesk_SDK_Swift

import Foundation

public enum UDCsiNpsType {
    case twoPoint
    case fivePoint
    case unknown
}

public class UDCsiButton: NSObject, Codable {
    @objc public var label = ""
    @objc public var id = ""
    
    override init() {
        super.init()
    }
    
    convenience init?(dic: [AnyHashable : Any]) {
        self.init()
        label = dic["label"] as? String ?? ""
        
        if let idString = dic["id"] as? String {
            id = idString
        } else if let idInt = dic["id"] as? Int {
            id = String(idInt)
        }
        
        if id.isEmpty {
            return nil
        }
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(id, forKey: .id)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case label
        case id
    }
}

public class UDCsi: NSObject, Codable {
    @objc public var buttonType = ""
    @objc public var npsTypeString = ""
    @objc public var iconTypeString = ""
    @objc public var buttons = [UDCsiButton]()
    
    var npsType: UDCsiNpsType {
        switch npsTypeString {
        case "two_point":
            return .twoPoint
        case "five_point":
            return .fivePoint
        default:
            return .unknown
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init?(dic: [AnyHashable : Any]) {
        self.init()
        buttonType = dic["button_type"] as? String ?? ""
        npsTypeString = dic["nps_type"] as? String ?? ""
        iconTypeString = dic["icon_type"] as? String ?? ""

        if let dataButtons = dic["data"] as? [[AnyHashable : Any]] {
            for dicButton in dataButtons {
                if let button = UDCsiButton(dic: dicButton) {
                    buttons.append(button)
                }
            }
        }
        
        if buttons.isEmpty {
            return nil
        }
    }
    
    func button(withId id: String) -> UDCsiButton? {
        return buttons.first(where: {$0.id == id})
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(buttonType, forKey: .buttonType)
        try container.encode(npsTypeString, forKey: .npsTypeString)
        try container.encode(iconTypeString, forKey: .iconTypeString)
        try container.encode(buttons, forKey: .buttons)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        buttonType = try container.decodeIfPresent(String.self, forKey: .buttonType) ?? ""
        npsTypeString = try container.decodeIfPresent(String.self, forKey: .npsTypeString) ?? ""
        iconTypeString = try container.decodeIfPresent(String.self, forKey: .iconTypeString) ?? ""
        buttons = try container.decodeIfPresent([UDCsiButton].self, forKey: .buttons) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case buttonType
        case npsTypeString
        case iconTypeString
        case buttons
    }
}
