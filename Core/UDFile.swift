//
//  UDFile.swift
//  UseDesk_SDK_Swift
//

import UIKit

enum UDTypeSourceFile: String {
    case UIImage = "UIImage"
    case PHAsset = "PHAsset"
    case URL = "URL"
}

public class UDFile: NSObject, Codable {
    @objc public var type = ""
    @objc public var name = ""
    @objc public var content = ""
    @objc public var size = ""
    @objc public var sizeInt: Int = 0
    @objc public var path = ""
    @objc public var defaultPath = ""
    @objc public var typeExtension = ""
    @objc public var duration: Double = 0
    @objc public var previewPath = ""
    @objc public var sourceTypeString = ""
    @objc public var sort: Int = 0
    
    override init() {
        super.init()
    }
    
    var sizeString: String {
        guard self.size == "" else {
            return self.size
        }
        if self.sizeInt != 0 {
            if self.sizeInt >= 1024 {
                var sizeFloat: Float = Float(self.sizeInt)
                sizeFloat = sizeFloat / 1024
                if sizeFloat >= 1024 {
                    sizeFloat = sizeFloat / 1024
                    if sizeFloat >= 1024 {
                        sizeFloat = sizeFloat / 1024
                        return "\((rounded(sizeFloat, toPlaces:2))) ГБ"
                    } else {
                        return "\((rounded(sizeFloat, toPlaces: 2))) МБ"
                    }
                } else {
                    return "\((rounded(sizeFloat, toPlaces:2))) КБ"
                }
            } else {
                return "\(self.sizeInt) Б"
            }
        } else {
            return ""
        }
    }
    
    var data: Data? {
        var pathForURL = ""
        if path.count > 0 {
            pathForURL = path
        } else if defaultPath.count > 0 {
            pathForURL = defaultPath
        } else {
            return nil
        }
        let url = URL(fileURLWithPath: pathForURL)
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }
    
    var image: UIImage? {
        if let dataFile = data {
            return UIImage(data: dataFile)?.udResizeImage()
        }
        return nil
    }
    
    var previewImage: UIImage? {
        if previewPath.count > 0 {
            return UIImage(contentsOfFile: previewPath)?.udResizeImage()
        }
        return nil
    }
    
    var sourceType: UDTypeSourceFile? {
        switch sourceTypeString {
        case UDTypeSourceFile.UIImage.rawValue:
            return .UIImage
        case UDTypeSourceFile.PHAsset.rawValue:
            return .PHAsset
        case UDTypeSourceFile.URL.rawValue:
            return .URL
        default:
            return nil
        }
    }
    
    func rounded(_ value: Float, toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (value * divisor).rounded() / divisor
    }
    
    func size(mbString: String, gbString: String) -> String {
        if let countByte = data?.count {
            let megabyte = Double(countByte) / Double(1048576)
            if megabyte > 1023 {
                let gigabyte = megabyte / 1024
                return "\(gigabyte.udRounded(toPlaces: 1)) \(gbString)"
            } else {
                return "\(megabyte.udRounded(toPlaces: 1)) \(mbString)"
            }
        }
        return ""
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
        try container.encode(size, forKey: .size)
        try container.encode(sizeInt, forKey: .sizeInt)
        try container.encode(path, forKey: .path)
        try container.encode(defaultPath, forKey: .defaultPath)
        try container.encode(typeExtension, forKey: .typeExtension)
        try container.encode(duration, forKey: .duration)
        try container.encode(previewPath, forKey: .previewPath)
        try container.encode(sourceTypeString, forKey: .sourceTypeString)
        try container.encode(sort, forKey: .sort)
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        size = try container.decode(String.self, forKey: .size)
        sizeInt = try container.decode(Int.self, forKey: .sizeInt)
        path = try container.decode(String.self, forKey: .path)
        defaultPath = try container.decode(String.self, forKey: .defaultPath)
        typeExtension = try container.decode(String.self, forKey: .typeExtension)
        duration = try container.decode(Double.self, forKey: .duration)
        previewPath = try container.decode(String.self, forKey: .previewPath)
        sourceTypeString = try container.decode(String.self, forKey: .sourceTypeString)
        sort = try container.decode(Int.self, forKey: .sort)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case content
        case size
        case sizeInt
        case path
        case defaultPath
        case typeExtension
        case duration
        case previewPath
        case sourceTypeString
        case sort
    }
}

enum TypeSenderMessage: Int {
    case operator_to_client = 1
    case client_to_operator = 2
    case client_to_bot = 3
    case bot_to_client = 4
    case service = 0
}
