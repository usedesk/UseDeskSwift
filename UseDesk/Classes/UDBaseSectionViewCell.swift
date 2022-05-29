//
//  UDBaseSectionViewCell.swift

import Foundation
import UIKit

class UDBaseSectionViewCell: UITableViewCell {
    // Icon Image
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageWC: NSLayoutConstraint!
    @IBOutlet weak var iconImageHC: NSLayoutConstraint!
    @IBOutlet weak var iconImageLC: NSLayoutConstraint!
    // Icon Label
    @IBOutlet weak var iconLabel: UILabel!
    // Text
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelTextLC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTopC: NSLayoutConstraint!
    @IBOutlet weak var labelTextBC: NSLayoutConstraint!
    // Arrow Image
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var arrowImageWC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageHC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTC: NSLayoutConstraint!
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var isDefaultImage = false
    
    func setCell(text: String, image: UIImage? = nil) {
        let baseSectionsStyle = configurationStyle.baseSectionsStyle
        
        iconImageView.image = image != nil ? image! : baseSectionsStyle.iconDefaultImage
        iconImageWC.constant = baseSectionsStyle.iconSize.width
        iconImageHC.constant = baseSectionsStyle.iconSize.height
        iconImageLC.constant = baseSectionsStyle.iconMargin.left
        iconLabel.alpha = image == nil ? 1 : 0
        iconLabel.text = image == nil ? "\(text.capitalized[text.capitalized.startIndex])" : ""
        iconLabel.font = baseSectionsStyle.iconFont
        iconLabel.textColor = baseSectionsStyle.iconTextColor

        labelText.text = text
        labelText.font = baseSectionsStyle.textFont
        labelText.textColor = baseSectionsStyle.textColor
        labelTextLC.constant = baseSectionsStyle.textMargin.left
        labelTextTC.constant = baseSectionsStyle.textMargin.right
        labelTextTopC.constant = baseSectionsStyle.textMargin.top
        labelTextBC.constant = baseSectionsStyle.textMargin.bottom
        
        arrowImageView.image = baseSectionsStyle.arrowImage
        arrowImageWC.constant = baseSectionsStyle.arrowSize.width
        arrowImageHC.constant = baseSectionsStyle.arrowSize.height
        arrowImageTC.constant = baseSectionsStyle.arrowMarginRight
        
        selectionStyle = .none
        self.layoutIfNeeded()
    }
}
