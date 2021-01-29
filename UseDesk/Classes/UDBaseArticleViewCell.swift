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
    // Separator
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHC: NSLayoutConstraint!
    @IBOutlet weak var separatorViewLC: NSLayoutConstraint!
    
    var configurationStyle = ConfigurationStyle()
    
    func setCell(text: String) {
        let baseArticlesListStyle = configurationStyle.baseArticlesListStyle

        labelText.text = text
        labelText.font = baseArticlesListStyle.textFont
        labelText.textColor = baseArticlesListStyle.textColor
        labelTextLC.constant = baseArticlesListStyle.textMargin.left
        labelTextTC.constant = baseArticlesListStyle.textMargin.right
        labelTextTopC.constant = baseArticlesListStyle.textMargin.top
        labelTextBC.constant = baseArticlesListStyle.textMargin.bottom
        
        separatorView.backgroundColor = baseArticlesListStyle.separatorColor
        separatorViewHC.constant = baseArticlesListStyle.separatorHeight
        separatorViewLC.constant = baseArticlesListStyle.separatorLeftMargin
        
        self.layoutIfNeeded()
    }
}
