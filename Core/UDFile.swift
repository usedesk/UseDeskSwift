//
//  UDFile.swift
//  UseDesk_SDK_Swift
//

import Foundation
import QuickLook
import Photos

enum UDTypeSourceFile: String {
    case UIImage = "UIImage"
    case PHAsset = "PHAsset"
    case URL = "URL"
}

@objc public enum UDTypeFyle: Int {
    case image = 0
    case video = 1
    case file = 2
}

public class UDFile: NSObject, Codable {
    @objc public var id: Int = 0
    @objc public var type: UDTypeFyle = .file
    @objc public var typeString = ""
    @objc public var mimeType = ""
    @objc public var name = ""
    @objc public var urlFile = ""
    @objc public var content = ""
    @objc public var dataLocal: Data? = nil
    @objc public var size = ""
    @objc public var sizeInt: Int = 0
    @objc public var path = ""
    @objc public var defaultPath = ""
    @objc public var typeExtension = ""
    @objc public var duration: Double = 0
    @objc public var previewPath = ""
    @objc public var previewImage: UIImage? = nil
    @objc public var sourceTypeString = ""
    @objc public var sort: Int = 0
    
    override init() {
        super.init()
    }
    
    // count bytes
    var sizeValue: Int {
        if sizeInt > 0 {
            return sizeInt
        }
        // разбор страка формата - "123 KB"
        if size.contains(" ") {
            if let number = Int(size.components(separatedBy: " ")[0]) {
                let sizeTypeString = size.components(separatedBy: " ")[1]
                var countBytes = number
                switch sizeTypeString {
                case "KB":
                    countBytes = number * 1024
                case "MB":
                    countBytes = number * 1048576
                case "GB":
                    countBytes = number * 1073741824
                default:
                    break
                }
                return countBytes
            }
        }
        return sizeInt
    }
    
    var sizeFile: Double {
        return sizeInt > 0 ? (Double(self.sizeInt) / Double(1048576)) : 0
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
    
    var preview: UIImage? {
        if let image = previewImage {
            return image
        } else if previewPath.count > 0 {
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
    
    func sizeString(model: UseDeskModel) -> String {
        if size.contains(" ") {
            let numberString = size.components(separatedBy: " ")[0]
            let sizeTypeString = size.components(separatedBy: " ")[1]
            var sizeStringLocalized = numberString
            switch sizeTypeString {
            case "B":
                sizeStringLocalized += " " + model.stringFor("B")
            case "KB":
                sizeStringLocalized += " " + model.stringFor("KB")
            case "MB":
                sizeStringLocalized += " " + model.stringFor("MB")
            case "GB":
                sizeStringLocalized += " " + model.stringFor("GB")
            default:
                break
            }
            return sizeStringLocalized
        }
        if sizeInt != 0 {
            if sizeInt >= 1024 {
                var sizeFloat: Float = Float(self.sizeInt)
                sizeFloat = sizeFloat / 1024
                if sizeFloat >= 1024 {
                    sizeFloat = sizeFloat / 1024
                    if sizeFloat >= 1024 {
                        sizeFloat = sizeFloat / 1024
                        return "\((rounded(sizeFloat, toPlaces:2))) " + model.stringFor("GB")
                    } else {
                        return "\((rounded(sizeFloat, toPlaces: 2))) " + model.stringFor("MB")
                    }
                } else {
                    return "\((rounded(sizeFloat, toPlaces:2))) " + model.stringFor("KB")
                }
            } else {
                return "\(sizeInt) " + model.stringFor("B")
            }
        } else {
            return ""
        }
    }
    
    func rounded(_ value: Float, toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (value * divisor).rounded() / divisor
    }
    
    func size(mbString: String, gbString: String) -> String {
        var countByte = 0
        if let countData = data?.count {
            countByte = countData
        } else if sizeInt > 0 {
            countByte = sizeInt
        } else {
            return ""
        }
        let megabyte = Double(countByte) / Double(1048576)
        if megabyte > 1023 {
            let gigabyte = megabyte / 1024
            return "\(gigabyte.udRounded(toPlaces: 1)) \(gbString)"
        } else {
            return "\(megabyte.udRounded(toPlaces: 1)) \(mbString)"
        }
    }

    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    func setAsset(asset: PHAsset, successBlock: @escaping () -> Void) {
        if asset.mediaType == .video {
            DispatchQueue.global(qos: .background).async {
                let options = PHVideoRequestOptions()
                options.version = .current
                options.isNetworkAccessAllowed = true
                PHCachingImageManager.default().requestAVAsset(forVideo: asset, options: options){ [weak self] avasset, _, _ in
                    guard let wSelf = self else {return}
                    if let avassetURL = avasset as? AVURLAsset {
                        if let videoData = try? Data(contentsOf: avassetURL.url) {
                            wSelf.content = "data:video/mp4;base64,\(videoData.base64EncodedString())"
                            wSelf.dataLocal = videoData
                            var fileName = String(format: "%ld", wSelf.content.hash)
                            fileName += ".mp4"
                            wSelf.mimeType = "video/mp4"
                            wSelf.name = fileName
                            wSelf.sizeInt = videoData.count
                            wSelf.type = .video
                            wSelf.previewImage = UDFileManager.videoPreview(fileURL: avassetURL.url)
                            wSelf.duration = asset.duration
                            wSelf.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                            successBlock()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                PHCachingImageManager.default().requestImageData(for: asset, options: options, resultHandler: { [weak self] data, dataUTI, d, info in
                    guard let wSelf = self else {return}
                    if data != nil {
                        let indexPoint = dataUTI!.firstIndex(of: ".")
                        var fileExtension = dataUTI![dataUTI!.index(after: indexPoint!)...]
                        fileExtension = ["heic", "heif", "webp"].filter({fileExtension.lowercased().contains($0)}).count > 0 ? "png" : fileExtension
                        if let imageData = UIImage(data: data!)?.udResizeImage()?.udToData() {
                            wSelf.content = "data:image/\(fileExtension);base64,\(imageData.base64EncodedString())"
                            wSelf.dataLocal = imageData
                        } else {
                            wSelf.content = "data:image/\(fileExtension);base64,\(data!.base64EncodedString())"
                            wSelf.dataLocal = data!
                        }
                        wSelf.name = asset.getFileName(withExtention: String(fileExtension)) ?? ""
                        wSelf.mimeType = "image/\(fileExtension)"
                        wSelf.sizeInt = data!.count
                        if let image = UIImage(data: data!) {
                            wSelf.previewImage = image
                            wSelf.type = .image
                        } else {
                            wSelf.type = .file
                        }
                        wSelf.sourceTypeString = UDTypeSourceFile.PHAsset.rawValue
                        successBlock()
                    }
                })
            }
        }
    }
    
    // MARK: - Codable methods
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(typeString, forKey: .typeString)
        try container.encode(name, forKey: .name)
        try container.encode(urlFile, forKey: .urlFile)
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
        type = UDTypeFyle(rawValue: try container.decode(Int.self, forKey: .type)) ?? .file
        typeString = try container.decode(String.self, forKey: .typeString)
        name = try container.decode(String.self, forKey: .name)
        urlFile = try container.decode(String.self, forKey: .urlFile)
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
        case typeString
        case name
        case urlFile
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

extension UDFile: QLPreviewItem {
    public var previewItemURL: URL? {
    return URL(fileURLWithPath: path)
  }
}

enum TypeSenderMessage: Int {
    case operator_to_client = 1
    case client_to_operator = 2
    case client_to_bot = 3
    case bot_to_client = 4
    case service = 0
}

extension PHAsset {
    func getFileName(withExtention extention: String? = nil) -> String? {
        var name = self.value(forKey: "filename") as? String
        if let extention = extention, let newName = name?.split(separator: ".").dropLast().joined(separator: ".") {
            name = newName + "." + extention
        }
        return name
    }

    func getExtension() -> String? {
        guard let fileName = self.getFileName() else {
            return nil
        }
        return URL(fileURLWithPath: fileName).pathExtension
    }
}
