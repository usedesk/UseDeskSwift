//
//  UDBaseSearchCell.swift
//  UseDesk_SDK_Swift


import Foundation
import UIKit

class UDBaseSearchCell: UITableViewCell {
    // Title
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelHC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBC: NSLayoutConstraint!
    // Text
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelTextLC: NSLayoutConstraint!
    @IBOutlet weak var labelTextTC: NSLayoutConstraint!
    @IBOutlet weak var labelTextBC: NSLayoutConstraint!
    // Text
    @IBOutlet weak var pathLabel: UILabel!
    @IBOutlet weak var pathLabelLC: NSLayoutConstraint!
    @IBOutlet weak var pathLabelTC: NSLayoutConstraint!
    @IBOutlet weak var pathLabelBC: NSLayoutConstraint!
    //
    // Separator
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var separatorViewHC: NSLayoutConstraint!
    @IBOutlet weak var separatorViewLC: NSLayoutConstraint!
    
    weak var usedesk: UseDeskSDK?
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    var isDefaultImage = false
    
    func setCell(article: UDArticle?) {
        guard usedesk != nil else {return}
        let baseSearchStyle = configurationStyle.baseSearchStyle
        
        titleLabel.text = article?.title ?? usedesk!.model.stringFor("ErrorLoading")
        titleLabel.font = baseSearchStyle.titleFont
        titleLabel.textColor = baseSearchStyle.titleColor
        titleLabelLC.constant = baseSearchStyle.titleMargin.left
        titleLabelTC.constant = baseSearchStyle.titleMargin.right
        titleLabelTopC.constant = baseSearchStyle.titleMargin.top
        titleLabelBC.constant = baseSearchStyle.titleMargin.bottom
        self.layoutIfNeeded()
        let height = titleLabel.text!.size(availableWidth: labelText.frame.width, attributes: [NSAttributedString.Key.font : baseSearchStyle.titleFont], usesFontLeading: true).height + 2
        titleLabelHC.constant = height

        labelText.text = (article?.text ?? usedesk!.model.stringFor("ErrorLoading")).udRemoveSubstrings(with: ["<[^>]+>", "&nbsp;", "\r\n"])
        labelText.font = baseSearchStyle.textFont
        labelText.textColor = baseSearchStyle.textColor
        labelTextLC.constant = baseSearchStyle.textMargin.left
        labelTextTC.constant = baseSearchStyle.textMargin.right
        labelTextBC.constant = baseSearchStyle.textMargin.bottom
        
        pathLabel.text = "\(article?.section_title ?? usedesk!.model.stringFor("ErrorLoading")) > \(article?.category_title ?? usedesk!.model.stringFor("ErrorLoading"))"
        pathLabel.font = baseSearchStyle.pathFont
        pathLabel.textColor = baseSearchStyle.pathColor
        pathLabelLC.constant = baseSearchStyle.pathMargin.left
        pathLabelTC.constant = baseSearchStyle.pathMargin.right
        pathLabelBC.constant = baseSearchStyle.pathMargin.bottom
        
        separatorView.backgroundColor = baseSearchStyle.separatorColor
        separatorViewHC.constant = baseSearchStyle.separatorHeight
        separatorViewLC.constant = baseSearchStyle.separatorLeftMargin
        
        self.layoutIfNeeded()
        self.isUserInteractionEnabled = true
        self.selectionStyle = .none
    }
}
