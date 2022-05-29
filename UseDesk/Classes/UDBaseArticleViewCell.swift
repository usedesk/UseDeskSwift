//
//  UDBaseArticleViewCell.swift

import Foundation
import UIKit

class UDBaseArticleViewCell: UITableViewCell {
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
    
    func setCell(text: String) {
        let baseArticlesListStyle = configurationStyle.baseArticlesListStyle

        labelText.text = text
        labelText.font = baseArticlesListStyle.textFont
        labelText.textColor = baseArticlesListStyle.textColor
        labelTextLC.constant = baseArticlesListStyle.textMargin.left
        labelTextTC.constant = baseArticlesListStyle.textMargin.right
        labelTextTopC.constant = baseArticlesListStyle.textMargin.top
        labelTextBC.constant = baseArticlesListStyle.textMargin.bottom
        
        arrowImageView.image = baseArticlesListStyle.arrowImage
        arrowImageWC.constant = baseArticlesListStyle.arrowSize.width
        arrowImageHC.constant = baseArticlesListStyle.arrowSize.height
        arrowImageTC.constant = baseArticlesListStyle.arrowMarginRight
        
        selectionStyle = .none
        self.layoutIfNeeded()
    }
}
