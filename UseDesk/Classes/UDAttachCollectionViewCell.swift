//
//  UDAttachCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit
import Photos

protocol UDAttachCVCellDelegate: AnyObject {
    func deleteFile(index: Int)
}

class UDAttachCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: UDAttachCVCellDelegate?
    
    var index: Int = 0
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var button: UIButton? = nil
    var backView = UIView()
    var videoView = UIView()
    var durationLabel = UILabel()
    var videoIndicatorView = UIImageView()
    var imageAttachView = UIImageView()
    var imageIconFileView = UIImageView()
    var fileTitleLabel = UILabel()
    var loader: UIActivityIndicatorView? = nil
    
    private let kIndentImage: CGFloat = 4
    private let kVideoViewHeight: CGFloat = 16
    
    func setingCell(image: UIImage? = nil, type: UDFileType?, videoDuration: Double? = nil, urlFile: URL? = nil, nameFile: String? = nil, index: Int) {
        loader?.removeFromSuperview()
        loader = nil
        imageAttachView.image = image
        imageAttachView.backgroundColor = UIColor(hexString: "F0F0F0")
        imageAttachView.frame = CGRect(x: kIndentImage, y: kIndentImage, width: configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage * 2, height: configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage * 2)
        imageAttachView.layer.masksToBounds = true
        imageAttachView.layer.cornerRadius = 4
        imageAttachView.contentMode = .scaleAspectFill
        if imageAttachView.superview == nil {
            self.addSubview(imageAttachView)
        }
        if button == nil {
            button = UIButton(frame: CGRect(x: self.frame.width - 24, y: 0, width: 24, height: 24))
        }
        button!.setTitle("", for: .normal)
        button!.setBackgroundImage(UIImage.named("udAttachClose"), for: .normal)
        button!.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        if button!.superview == nil {
            self.addSubview(button!)
        }
        if type == .video {
            // 13 = heigt videoView
            videoView.frame = CGRect(x: 0, y: (configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage) - kVideoViewHeight, width: configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage * 2, height: kVideoViewHeight)
            backView.frame = CGRect(x: 0, y: 0, width: configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage * 2, height: kVideoViewHeight)
            backView.alpha = 0.8
            backView.backgroundColor = .black
            if backView.superview == nil {
                videoView.addSubview(backView)
            }
            
            if videoDuration != nil {
                durationLabel.frame = CGRect(x: 14, y: 0, width: (configurationStyle.inputViewStyle.heightAssetsCollection - kIndentImage * 2) - 14 - 2, height: 12)
                durationLabel.font = durationLabel.font.withSize(9)
                durationLabel.textColor = .white
                durationLabel.textAlignment = .right
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.second, .minute, .hour]
                formatter.zeroFormattingBehavior = .pad
                if var formattedString = formatter.string(from: TimeInterval(videoDuration!)) {
                    if videoDuration! < 3600 {
                        formattedString.removeSubrange(formattedString.startIndex..<String.Index(encodedOffset: 3))
                    }
                    durationLabel.text = formattedString
                    if durationLabel.superview == nil {
                        videoView.addSubview(durationLabel)
                    }
                }
                
                videoIndicatorView.image = UIImage.named("udVideoIndicator")
                videoIndicatorView.frame = CGRect(x: 2, y: 0, width: 12, height: 12)
                if videoIndicatorView.superview == nil {
                    videoView.addSubview(videoIndicatorView)
                }
            }
            if videoView.superview == nil {
                imageAttachView.addSubview(videoView)
            }
        } else {
            videoView.removeFromSuperview()
        }
        if type == .file {
            imageIconFileView.image = UIImage.named("udFileIconCircle")
            imageIconFileView.frame = CGRect(x: imageAttachView.frame.origin.x + 6, y: imageAttachView.frame.origin.y + 6, width: self.frame.width * 0.47, height: self.frame.height * 0.47)
            if imageIconFileView.superview == nil {
                self.addSubview(imageIconFileView)
            }
            if urlFile != nil || nameFile != nil {
                fileTitleLabel.text = urlFile != nil ? urlFile!.lastPathComponent : nameFile ?? ""
                fileTitleLabel.frame = CGRect(x: imageAttachView.frame.origin.x + 4, y: imageAttachView.frame.origin.y + imageAttachView.frame.height - 4 - 16, width: imageAttachView.frame.width - (4 * 2), height: 16)
                fileTitleLabel.font = UIFont.systemFont(ofSize: 12)
                fileTitleLabel.textColor = UIColor(hexString: "454D63")
                fileTitleLabel.lineBreakMode = .byTruncatingMiddle
                if fileTitleLabel.superview == nil {
                    self.addSubview(fileTitleLabel)
                }
            }
        } else {
            imageIconFileView.removeFromSuperview()
            fileTitleLabel.removeFromSuperview()
        }
        self.layoutIfNeeded()
        self.index = index
    }
    
    func showLoader() {
        if loader == nil {
            loader = UIActivityIndicatorView(style: .gray)
            loader!.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(loader!)
            let horizontalConstraint = NSLayoutConstraint(item: loader!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: loader!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
            loader?.startAnimating()
        }
    }
    
    @objc func deleteAction(sender: UIButton!) {
        delegate?.deleteFile(index: index)
    }
}
