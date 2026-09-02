//
//  UDUIAlertControllerExtension.swift
//  UseDesk_SDK_Swift

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
            previewImageView.frame = CGRect(origin: .zero, size: resizedImage.size)
            let videoViewContainer = UIView(frame: CGRect(origin: .zero, size: resizedImage.size))
            videoViewContainer.addSubview(previewImageView)
            let backView = UIView(frame: CGRect(x: (resizedImage.size.width / 2) - 20, y: (resizedImage.size.height / 2) - 20, width: 40, height: 40))
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

        let imageView = UIImageView(image: resizedImage.withRenderingMode(.alwaysOriginal))
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let contentVC = UIViewController()
        contentVC.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentVC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentVC.view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: resizedImage.size.width),
            imageView.heightAnchor.constraint(equalToConstant: resizedImage.size.height)
        ])
        contentVC.preferredContentSize = resizedImage.size

        self.setValue(contentVC, forKey: "contentViewController")
    }
}
