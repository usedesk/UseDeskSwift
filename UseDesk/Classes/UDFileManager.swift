//
//  UDFileManager.swift
//  UseDesk_SDK_Swift
//

import UIKit
import Foundation
import Alamofire
import Photos
import Swime
import CommonCrypto

class UDFileManager: NSObject {
    var cacheDataPath: String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""
        let finalPath = cachePath
        
        if (!FileManager.default.fileExists(atPath: finalPath)) {
            try? FileManager.default.createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        return finalPath
    }
    
    class func downloadFile(indexPath: IndexPath, urlPath: String, name: String, extansion: String, successBlock: @escaping (IndexPath, URL)->(), errorBlock: (_ error: String) -> Void) {
        if let url = URL(string: urlPath) {
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
                var fileURL = documentsURL.appendingPathComponent("\(name).\(extansion)")
                var flag = true
                var index = 0
                while flag {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        index += 1
                        fileURL = documentsURL.appendingPathComponent("\(index)\(name).\(extansion)")
                    } else {
                        flag = false
                    }
                }
             return (fileURL, [.removePreviousFile,.createIntermediateDirectories])
            }
            AF.download(url, to: destination).responseData { response in
                if let destinationUrl = response.fileURL {
                    successBlock(indexPath, destinationUrl)
                }
            }
        }
    }
    
    class func videoPreview(filePath:String) -> UIImage {
        let vidURL = NSURL(fileURLWithPath:filePath)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let timestamp = CMTime(seconds: 0, preferredTimescale: 1)

        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch _ as NSError
        {
            return UIImage()
        }
    }
    
    func timeStringFor(seconds : Int) -> String
    {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.second, .minute, .hour]
      formatter.zeroFormattingBehavior = .pad
      let output = formatter.string(from: TimeInterval(seconds))!
        return output
     // return self < 3600 ? output.substring(from: output.range(of: ":")!.upperBound) : output
    }

}

extension FileManager {
    
    var cacheDataPath: String {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last ?? ""
        let finalPath = cachePath
        
        if (!fileExists(atPath: finalPath)) {
            try? createDirectory(atPath: finalPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        return finalPath
    }
    
    func writeDataToCacheDirectory(data: Data) -> String? {
        var fileName = data.sha1(uppercased: true) ?? "\(data.hashValue)"
        let subData = data.prefix(10240)
        if let `extension` = Swime.mimeType(data: subData)?.ext {
            fileName += "." + `extension`
        } else {
            fileName += ".itmp"
        }

        let dataPath = "file://" + cacheDataPath + "/"

        var url = URL(fileURLWithPath: fileName, relativeTo: URL(string: dataPath))
        var filePath = cacheDataPath + "/" + fileName
        var count = 0
        while (fileExists(atPath: filePath)) && count < 10000 {
            url = URL(fileURLWithPath: "\(count)" + fileName, relativeTo: URL(string: dataPath))
            filePath = cacheDataPath + "/" + "\(count)" + fileName
            count += 1
        }
        do {
            try data.write(to: url, options: .atomicWrite)
            return url.path
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
}

public extension Data {
    
    func sha1(uppercased: Bool) -> String? {
        let hash = withUnsafeBytes { (bytes) -> [UInt8] in
            var hash: [UInt8] = Array(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1(bytes.baseAddress, CC_LONG(count), &hash)
            
            return hash
        }
        
        let hashString: String
        if (uppercased) {
            hashString = hash.map { String(format: "%02X", $0) }.joined()
        } else {
            hashString = hash.map { String(format: "%02x", $0) }.joined()
        }
        
        return hashString
    }
    
}

extension URL {
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
