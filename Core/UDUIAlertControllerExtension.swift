//
//  UDUIAlertControllerExtension.swift
//  UseDesk_SDK_Swift
//

import UIKit

extension UIAlertController {
    func udAdd(image: UIImage, isVideo: Bool = false) {
        let maxSize = CGSize(width: 240, height: 244)
        let imgSize = image.size
        var ratio:CGFloat!
        if (imgSize.width > imgSize.height){
            ratio = maxSize.width / imgSize.width
        }else {
            ratio = maxSize.height / imgSize.height
        }
        let scaleSize = CGSize(width: imgSize.width*ratio, height: imgSize.height*ratio)
        var resizedImage = image.udImageWithSize(scaleSize)
        
        if isVideo {
            let previewImageView = UIImageView(image: resizedImage)
            let videoViewContainer = UIView(frame: CGRect(x: (self.view.frame.width - previewImageView.frame.width) / 2, y: 0, width: previewImageView.frame.width, height: previewImageView.frame.height))
            videoViewContainer.addSubview(previewImageView)
            let backView = UIView(frame: CGRect(x: (previewImageView.frame.width / 2) - 20, y: (previewImageView.frame.height / 2) - 20, width: 40, height: 40))
            backView.layer.masksToBounds = true
            backView.layer.cornerRadius = 40 / 2
            backView.backgroundColor = UIColor(hexString: "454D63")
            backView.alpha = 0.4
            let iconPlay = UIImageView(image: UIImage.named("udVideoPlay"))
            iconPlay.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
            backView.addSubview(iconPlay)
            videoViewContainer.addSubview(backView)
            resizedImage = videoViewContainer.udImage()
        }

        if (imgSize.height > imgSize.width) {
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
        }
        
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")

        self.addAction(imgAction)
    }
}
