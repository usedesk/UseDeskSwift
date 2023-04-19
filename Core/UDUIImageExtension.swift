//
//  UDUIImageExtension.swift
//

import Foundation
import UIKit

extension UIImage {
    
    static func named(_ imageNamed: String) -> UIImage {
        if let image = UIImage(named: imageNamed) {
            return image
        } else {
            let bundle: Bundle = BundleId.thisBundle
            
            if let image = UIImage(named: imageNamed, in: bundle, compatibleWith: nil) {
                return image
            } else {
                return UIImage()
            }
        }
    }
    
    func udResizeImage() -> UIImage? {
        var actualHeight: Float = Float(self.size.height)
        var actualWidth: Float = Float(self.size.width)
        let maxHeight: Float = 800.0
        let maxWidth: Float = 800.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        self.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)
    }
    
    func udImageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero

        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)

        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        self.draw(in: scaledImageRect)

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }
    
    func udToData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            return self.pngData()
        })
    }
    
    func udFixedOrientation() -> UIImage {
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        var transform:CGAffineTransform = CGAffineTransform.identity

        if (imageOrientation == UIImage.Orientation.down || imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }

        if (imageOrientation == UIImage.Orientation.left || imageOrientation == UIImage.Orientation.leftMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }

        if (imageOrientation == UIImage.Orientation.right || imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        }

        if (imageOrientation == UIImage.Orientation.upMirrored || imageOrientation == UIImage.Orientation.downMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        if (imageOrientation == UIImage.Orientation.leftMirrored || imageOrientation == UIImage.Orientation.rightMirrored) {
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }

        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!

        ctx.concatenate(transform)

        if (imageOrientation == UIImage.Orientation.left || imageOrientation == UIImage.Orientation.leftMirrored || imageOrientation == UIImage.Orientation.right || imageOrientation == UIImage.Orientation.rightMirrored) {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)

        return imgEnd
    }

}
