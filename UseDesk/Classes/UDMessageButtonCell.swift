//
//  UDMessageButtonCell.swift
//  UseDesk_SDK_Swift

import UIKit

class UDMessageButtonCell: UICollectionViewCell {
    
    var titleLabel = UILabel()
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setingCell(titleButton: String) {
        titleLabel.text = titleButton
        titleLabel.textAlignment = .center
        titleLabel.textColor = configurationStyle.messageButtonStyle.textColor
        self.addSubview(titleLabel)
        self.layer.cornerRadius = configurationStyle.messageButtonStyle.cornerRadius
        self.backgroundColor = configurationStyle.messageButtonStyle.color
    }
    
    override func layoutSubviews() {
        let messageButtonStyle = configurationStyle.messageButtonStyle
        titleLabel.frame = CGRect(x: messageButtonStyle.padding.left, y: (self.frame.height / 2) - ((self.frame.height - 18) / 2), width: self.frame.width - messageButtonStyle.padding.left - messageButtonStyle.padding.right, height: self.frame.height - 18)
    }
}
