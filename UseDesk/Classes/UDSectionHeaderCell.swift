//
//  UDSectionHeaderCell.swift

import Foundation

class UDSectionHeaderCell: UIView {
    let labelSectionHeader = UILabel()
    let backView = UIView()
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    weak var usedesk: UseDeskSDK?
    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        backView.backgroundColor = configurationStyle.sectionHeaderStyle.backViewColor
        self.addSubview(backView)
        labelSectionHeader.font = configurationStyle.sectionHeaderStyle.font
        labelSectionHeader.textColor = configurationStyle.sectionHeaderStyle.textColor
        self.addSubview(labelSectionHeader)
        labelSectionHeader.textAlignment = .center
        isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let sectionHeaderStyle = configurationStyle.sectionHeaderStyle
        //Text
        var widthText: CGFloat = SCREEN_WIDTH - sectionHeaderStyle.margin.left - sectionHeaderStyle.margin.right
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        if message != nil {
            if usedesk != nil {
                labelSectionHeader.text = message!.date.dateFromHeaderChat(usedesk!)
            }
            widthText = labelSectionHeader.text?.size(attributes: [NSAttributedString.Key.font : sectionHeaderStyle.font]).width  ?? widthText
        }
        let heightText: CGFloat = labelSectionHeader.text != nil ? sectionHeaderStyle.textHeight : 0
        labelSectionHeader.frame = CGRect(x: self.center.x - (widthText / 2), y: sectionHeaderStyle.backViewPadding.top + sectionHeaderStyle.margin.top, width: widthText, height: heightText)
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            if self.frame.origin.x > 0 {
                labelSectionHeader.frame.origin.x -= 22
            }
        }
        //BackView
        backView.layer.cornerRadius = sectionHeaderStyle.backViewCornerRadius
        backView.alpha = sectionHeaderStyle.backViewOpacity
        let width: CGFloat = widthText + sectionHeaderStyle.backViewPadding.left + sectionHeaderStyle.backViewPadding.right
        let height: CGFloat = heightText != 0 ? heightText + sectionHeaderStyle.backViewPadding.top + sectionHeaderStyle.backViewPadding.bottom : 0
        backView.frame = CGRect(x: labelSectionHeader.frame.origin.x - sectionHeaderStyle.backViewPadding.left, y: sectionHeaderStyle.margin.top, width: width, height: height)
    }
}
