//
//  UDFileManager.swift
//  UseDesk_SDK_Swift
//

import UIKit
import Alamofire
import Photos

class UDFileManager: NSObject {
    
    class func downloadFile(indexPath: IndexPath, urlPath: String, successBlock: @escaping (IndexPath, URL)->(), errorBlock: (_ error: String) -> Void) {
        if let url = URL(string: urlPath) {
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
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

        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)

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

