//
//  UDBaseArticleReviewTagCell.swift


import Foundation
import UIKit

class UDBaseArticleReviewTagCell: UICollectionViewCell {
    // Back view
    @IBOutlet weak var backView: UIView!
    // Text
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelTextLC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTopC: NSLayoutConstraint!
    @IBOutlet weak var labelTextBC: NSLayoutConstraint!
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setCell(text: String, isSelected: Bool) {
        let baseArticleReviewStyle = configurationStyle.baseArticleReviewStyle

        backView.backgroundColor = isSelected ? baseArticleReviewStyle.tagBackActiveColor : baseArticleReviewStyle.tagBackNoActiveColor
        backView.layer.cornerRadius = baseArticleReviewStyle.tagCornerRadius
        backView.layer.masksToBounds = true
        
        labelText.text = text
        labelText.font = baseArticleReviewStyle.tagTextFont
        labelText.textColor = isSelected ? baseArticleReviewStyle.tagTextActiveColor : baseArticleReviewStyle.tagTextNoActiveColor
        labelTextLC.constant = baseArticleReviewStyle.tagTextMargin.left
        labelTextTC.constant = baseArticleReviewStyle.tagTextMargin.right
        labelTextTopC.constant = baseArticleReviewStyle.tagTextMargin.top
        labelTextBC.constant = baseArticleReviewStyle.tagTextMargin.bottom
        
        self.layoutIfNeeded()
    }
    
    func setSelected() {
        let baseArticleReviewStyle = configurationStyle.baseArticleReviewStyle
        UIView.animate(withDuration: 0.1) {
            self.backView.backgroundColor = baseArticleReviewStyle.tagBackActiveColor
            self.labelText.textColor = baseArticleReviewStyle.tagTextActiveColor
            self.layoutIfNeeded()
        }
    }
    
    func setNotSelected() {
        let baseArticleReviewStyle = configurationStyle.baseArticleReviewStyle
        UIView.animate(withDuration: 0.1) {
            self.backView.backgroundColor = baseArticleReviewStyle.tagBackNoActiveColor
            self.labelText.textColor = baseArticleReviewStyle.tagTextNoActiveColor
            self.layoutIfNeeded()
        }
    }
}
