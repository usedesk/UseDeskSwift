//
//  UDSimpleSelectCell.swift
//  UseDesk_SDK_Swift
//

import Foundation

class UDSimpleSelectCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelLC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTopC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBC: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTC: NSLayoutConstraint!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var selectImageWC: NSLayoutConstraint!
    @IBOutlet weak var selectImageHC: NSLayoutConstraint!
    @IBOutlet weak var selectImageTC: NSLayoutConstraint!
    
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func setCell(title: String) {
        let selectTopicFeedbackFormStyle = configurationStyle.selectTopicFeedbackFormStyle
        backgroundColor = configurationStyle.chatStyle.backgroundColor
        titleLabel.text = title
        titleLabel.font = selectTopicFeedbackFormStyle.titleTopicFont
        titleLabel.textColor = selectTopicFeedbackFormStyle.titleTopicColor
        titleLabelLC.constant = selectTopicFeedbackFormStyle.titleTopicMargin.left
        titleLabelTopC.constant = selectTopicFeedbackFormStyle.titleTopicMargin.top
        titleLabelBC.constant = selectTopicFeedbackFormStyle.titleTopicMargin.bottom
        titleLabelTC.constant = selectTopicFeedbackFormStyle.titleTopicMargin.right
        
        selectImageWC.constant = selectTopicFeedbackFormStyle.selectImageSize.width
        selectImageHC.constant = selectTopicFeedbackFormStyle.selectImageSize.height
        selectImageTC.constant = selectTopicFeedbackFormStyle.selectImageMarginRight
        
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setSelected() {
        selectImage.image = configurationStyle.selectTopicFeedbackFormStyle.selectedImage
    }
    
    func setNotSelected() {
        selectImage.image = configurationStyle.selectTopicFeedbackFormStyle.selectImage
    }
}
