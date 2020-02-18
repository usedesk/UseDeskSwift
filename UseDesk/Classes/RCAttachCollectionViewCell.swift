//
//  RCAttachCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit
import Photos

protocol RCAttachCVCellDelegate: class {
    func deleteFile(index: Int)
}

class RCAttachCollectionViewCell: UICollectionViewCell {
    
    //@IBOutlet weak var imageAttachView: UIImageView!
    
    weak var delegate: RCAttachCVCellDelegate?
    
    var index: Int = 0
    
    private let kIndentImage: CGFloat = 4
    private let kVideoViewHeight: CGFloat = 16
    
    func setingCell(image: UIImage, type: PHAssetMediaType, videoDuration: Double? = nil, index: Int) {
        let imageAttachView = UIImageView()
        imageAttachView.image = image
        imageAttachView.frame = CGRect(x: kIndentImage, y: kIndentImage, width: Constants.heightAssetsCollection - kIndentImage * 2, height: Constants.heightAssetsCollection - kIndentImage * 2)
        imageAttachView.layer.masksToBounds = true
        imageAttachView.layer.cornerRadius = 4
        self.addSubview(imageAttachView)
        
        let button = UIButton(frame: CGRect(x: self.frame.width - 24, y: 0, width: 24, height: 24))
        button.setTitle("", for: .normal)
        button.setBackgroundImage(UIImage.named("attachClose"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.addSubview(button)
        
        if type == .video {
            // 13 = heigt videoView
            let videoView = UIView(frame: CGRect(x: 0, y: (Constants.heightAssetsCollection - kIndentImage) - kVideoViewHeight, width: Constants.heightAssetsCollection - kIndentImage * 2, height: kVideoViewHeight))
            let backView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.heightAssetsCollection - kIndentImage * 2, height: kVideoViewHeight))
            backView.alpha = 0.8
            backView.backgroundColor = .black
            videoView.addSubview(backView)
            
            if videoDuration != nil {
                let durationLabel = UILabel(frame: CGRect(x: 14, y: 0, width: (Constants.heightAssetsCollection - kIndentImage * 2) - 14 - 2, height: 12))
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
                    videoView.addSubview(durationLabel)
                }
                
                let videoIndicatorView = UIImageView(image: UIImage.named("videoIndicator"))
                videoIndicatorView.frame = CGRect(x: 2, y: 0, width: 12, height: 12)
                videoView.addSubview(videoIndicatorView)
                
            }
            imageAttachView.addSubview(videoView)
        }
        
        self.layoutIfNeeded()
        self.index = index
    }
    
    override func layoutSubviews() {
    }
    
    @objc func deleteAction(sender: UIButton!) {
        delegate?.deleteFile(index: index)
    }
}
