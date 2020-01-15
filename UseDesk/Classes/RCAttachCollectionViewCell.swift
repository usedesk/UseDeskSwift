//
//  RCAttachCollectionViewCell.swift
//  UseDesk_SDK_Swift
//

import UIKit

protocol RCAttachCVCellDelegate: class {
    func deleteFile(index: Int)
}

class RCAttachCollectionViewCell: UICollectionViewCell {
    
    //@IBOutlet weak var imageAttachView: UIImageView!
    
    weak var delegate: RCAttachCVCellDelegate?
    
    var index: Int = 0
    
    func setingCell(image: UIImage, index: Int) {
        let imageAttachView = UIImageView()
        imageAttachView.image = image
        imageAttachView.frame = CGRect(x: 4, y: 4, width: 50, height: 50)
        imageAttachView.layer.masksToBounds = true
        imageAttachView.layer.cornerRadius = 4
        self.addSubview(imageAttachView)
        
        let button = UIButton(frame: CGRect(x: self.frame.width - 24, y: 0, width: 24, height: 24))
        button.setTitle("", for: .normal)
        button.setBackgroundImage(UIImage.named("attachClose"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.addSubview(button)
        
        self.layoutIfNeeded()
        self.index = index
    }
    
    override func layoutSubviews() {
    }
    
    @objc func deleteAction(sender: UIButton!) {
        delegate?.deleteFile(index: index)
    }
}
