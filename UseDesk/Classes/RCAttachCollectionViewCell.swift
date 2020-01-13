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
        //imageAttachView.frame.size = CGSize(width: 50, height: 50)
        imageAttachView.frame = CGRect(x: 4, y: 4, width: 50, height: 50)
        imageAttachView.layer.masksToBounds = true
        imageAttachView.layer.cornerRadius = 4
        
        self.addSubview(imageAttachView)
        
        let button = UIButton(frame: CGRect(x: self.frame.width - 24, y: 0, width: 24, height: 24))
        button.setTitle("", for: .normal)
        var image = UIImage(named: "attachClose", in: thisBundle(), compatibleWith: nil)
        button.setImage(UIImage(named: "attachClose"), for: .normal)
        button.setBackgroundImage(UIImage(named: "attachClose"), for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.addSubview(button)
        self.layoutIfNeeded()
        self.index = index
    }
    
    func thisBundle() -> Bundle {
        var bundle: Bundle
        let podBundle = Bundle(for: type(of: self))
        if let bundleURL = podBundle.url(forResource: "UseDesk_SDK_Swift", withExtension: "bundle") {
            bundle = Bundle(url: bundleURL) ?? .main
        } else {
            bundle = podBundle
        }
        return bundle
    }
    
    override func layoutSubviews() {
    }
    
    @objc func deleteAction(sender: UIButton!) {
        delegate?.deleteFile(index: index)
    }
}
