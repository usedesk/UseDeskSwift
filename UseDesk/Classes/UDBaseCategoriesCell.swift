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
    // Count Articles
    @IBOutlet weak var countArticlesLabel: UILabel!
    @IBOutlet weak var countArticlesLabelWC: NSLayoutConstraint!
    @IBOutlet weak var countArticlesLabelTC: NSLayoutConstraint!
    // Description Category
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionLabelLC: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelTC: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelBC: NSLayoutConstraint!
    // Arrow Image
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var arrowImageWC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageHC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTC: NSLayoutConstraint!
    @IBOutlet weak var arrowImageTopC: NSLayoutConstraint!
    // Separator
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHC: NSLayoutConstraint!
    @IBOutlet weak var separatorViewLC: NSLayoutConstraint!
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setCell(category: UDBaseCategory) {
        let baseCategoriesStyle = configurationStyle.baseCategoriesStyle

        labelText.text = category.title
        labelText.font = baseCategoriesStyle.textFont
        labelText.textColor = baseCategoriesStyle.textColor
        labelTextLC.constant = baseCategoriesStyle.textMargin.left
        labelTextTC.constant = baseCategoriesStyle.textMargin.right
        labelTextTopC.constant = baseCategoriesStyle.textMargin.top
        labelTextBC.constant = baseCategoriesStyle.textMargin.bottom
        self.layoutIfNeeded()
        let height = category.title.size(availableWidth: labelText.frame.width, attributes: [NSAttributedString.Key.font : baseCategoriesStyle.textFont], usesFontLeading: true).height + 2
        labelTextHC.constant = height

        countArticlesLabel.text = "\(category.articlesTitles.count)"
        countArticlesLabel.font = baseCategoriesStyle.countArticlesFont
        countArticlesLabel.textColor = baseCategoriesStyle.countArticlesColor
        let width = countArticlesLabel.text!.size(attributes: [NSAttributedString.Key.font : baseCategoriesStyle.countArticlesFont], usesFontLeading: true).width + 2
        countArticlesLabelWC.constant = width
        countArticlesLabelTC.constant = baseCategoriesStyle.countArticlesMargin.right

        descriptionLabel.text = category.descriptionCategory.udRemoveSubstrings(with: ["<[^>]+>", "&nbsp;"])
        descriptionLabel.font = baseCategoriesStyle.descriptionFont
        descriptionLabel.textColor = baseCategoriesStyle.descriptionColor
        descriptionLabelLC.constant = baseCategoriesStyle.descriptionMargin.left
        descriptionLabelTC.constant = baseCategoriesStyle.descriptionMargin.right
        descriptionLabelBC.constant = baseCategoriesStyle.descriptionMargin.bottom        
        
        arrowImageView.image = baseCategoriesStyle.arrowImage
        arrowImageWC.constant = baseCategoriesStyle.arrowSize.width
        arrowImageHC.constant = baseCategoriesStyle.arrowSize.height
        arrowImageTC.constant = baseCategoriesStyle.arrowMargin.right
        arrowImageTopC.constant = baseCategoriesStyle.arrowMargin.top
        
        separatorView.backgroundColor = baseCategoriesStyle.separatorColor
        separatorViewHC.constant = baseCategoriesStyle.separatorHeight
        separatorViewLC.constant = baseCategoriesStyle.separatorLeftMargin
        
        self.layoutIfNeeded()
    }
}
