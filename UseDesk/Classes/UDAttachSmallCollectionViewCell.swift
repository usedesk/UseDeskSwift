//
//  UDAttachSmallCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit

class UDAttachSmallCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewTC: NSLayoutConstraint!
    @IBOutlet weak var imageViewLC: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopC: NSLayoutConstraint!
    @IBOutlet weak var imageViewBC: NSLayoutConstraint!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoTimeLabel: UILabel!
    @IBOutlet weak var selectedIndicator: UIImageView!
    @IBOutlet weak var selectedNumberLabel: UILabel!
    
    var isActive: Bool = false
    var indexPath: IndexPath!
    
    func setSelected(number: Int) {
        self.isActive = true
        selectedNumberLabel.text = String(number)
        selectedIndicator.image = UIImage.named("udSelectedAsset")
        selectedNumberLabel.alpha = 1
    }
    
    func notSelected() {
        self.isActive = false
        selectedIndicator.image = UIImage.named("udSelectAsset")
        selectedNumberLabel.alpha = 0
    }
    
}

