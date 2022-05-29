//
//  UDBaseCategoriesCell.swift
//  UseDesk_SDK_Swift

import Foundation
import UIKit

class UDBaseCategoriesCell: UITableViewCell {
    // Text
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelTextLC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTopC: NSLayoutConstraint!
    @IBOutlet weak var labelTextBC: NSLayoutConstraint!
    @IBOutlet weak var labelTextHC: NSLayoutConstraint!
    // Description Category
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelLC: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelBC: NSLayoutConstraint!
    // Arrow Image
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var arrowImageWC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageHC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTC: NSLayoutConstraint!
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setCell(category: UDBaseCategory) {
        let baseCategoriesStyle = configurationStyle.baseCategoriesStyle
        let baseStyle = configurationStyle.baseStyle

        labelText.text = category.title
        labelText.font = baseCategoriesStyle.textFont
        labelText.textColor = baseCategoriesStyle.textColor
        labelTextLC.constant = baseCategoriesStyle.textMargin.left
        labelTextTC.constant = baseCategoriesStyle.textMargin.right
        labelTextTopC.constant = baseCategoriesStyle.textMargin.top
        labelTextBC.constant = baseCategoriesStyle.textMargin.bottom
        
        let widthLabelText = UIScreen.main.bounds.width - baseStyle.contentMarginLeft - baseStyle.contentMarginLeft - baseCategoriesStyle.textMargin.left - baseCategoriesStyle.textMargin.right - baseCategoriesStyle.arrowSize.width - baseCategoriesStyle.arrowMarginRight
        let height = category.title.size(availableWidth: widthLabelText, attributes: [NSAttributedString.Key.font : baseCategoriesStyle.textFont], usesFontLeading: true).height
        labelTextHC.constant = height

        descriptionLabel.text = category.descriptionCategory.udRemoveSubstrings(with: ["<[^>]+>", "&nbsp;"])
        descriptionLabel.font = baseCategoriesStyle.descriptionFont
        descriptionLabel.textColor = baseCategoriesStyle.descriptionColor
        descriptionLabelLC.constant = baseCategoriesStyle.descriptionMargin.left
        descriptionLabelBC.constant = baseCategoriesStyle.descriptionMargin.bottom        
        
        arrowImageView.image = baseCategoriesStyle.arrowImage
        arrowImageWC.constant = baseCategoriesStyle.arrowSize.width
        arrowImageHC.constant = baseCategoriesStyle.arrowSize.height
        arrowImageTC.constant = baseCategoriesStyle.arrowMarginRight
        
        selectionStyle = .none
        self.layoutIfNeeded()
    }
}
