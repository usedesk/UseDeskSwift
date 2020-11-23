//
//  RCMessageButtonCell.swift
//  UseDesk_SDK_Swift

import UIKit

class RCMessageButtonCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    
    func setingCell(titleButton: String) {
        titleLabel.text = titleButton
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        self.backgroundColor = RCMessages().textButtonColor
    }
    
    override func layoutSubviews() {
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
}
