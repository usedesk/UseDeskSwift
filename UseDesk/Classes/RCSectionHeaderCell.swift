//
//  RCSectionHeaderCell.swift

import Foundation

class RCSectionHeaderCell: UITableViewCell {
    var labelSectionHeader: UILabel?
    
    func bindData(_ indexPath: IndexPath?, messagesView: RCMessagesView?) {
        backgroundColor = UIColor.clear
        
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        if labelSectionHeader == nil {
            labelSectionHeader = UILabel()
            labelSectionHeader!.font = RCMessages.sectionHeaderFont()
            labelSectionHeader!.textColor = RCMessages.sectionHeaderColor()
            contentView.addSubview(labelSectionHeader!)
            labelSectionHeader!.textAlignment = rcmessage?.incoming != false ? .center : .center
            labelSectionHeader!.text = messagesView?.textSectionHeader(indexPath)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: CGFloat = SCREEN_WIDTH - RCMessages.sectionHeaderLeft() - RCMessages.sectionHeaderRight()
        let height: CGFloat = (labelSectionHeader?.text != nil) ? RCMessages.sectionHeaderHeight : 0
        labelSectionHeader?.frame = CGRect(x: RCMessages.sectionHeaderLeft(), y: 0, width: width, height: height)
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        return (messagesView?.textSectionHeader(indexPath) != nil) ? RCMessages.sectionHeaderHeight : 0
    }
}
