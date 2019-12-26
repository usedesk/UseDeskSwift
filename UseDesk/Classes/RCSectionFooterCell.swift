//
//  RCSectionFooterCell.swift

import Foundation

class RCSectionFooterCell: UITableViewCell {

    var labelSectionFooter: UILabel?

    func bindData(_ indexPath: IndexPath?, messagesView: RCMessagesView?) {
        backgroundColor = UIColor.clear
        
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        if labelSectionFooter == nil {
            labelSectionFooter = UILabel()
            labelSectionFooter!.font = RCMessages.sectionFooterFont()
            labelSectionFooter!.textColor = RCMessages.sectionFooterColor()
            contentView.addSubview(labelSectionFooter!)
            labelSectionFooter!.textAlignment = rcmessage?.incoming != false ? .left : .right
            labelSectionFooter!.text = messagesView?.textSectionFooter(indexPath)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = SCREEN_WIDTH - RCMessages.sectionFooterLeft() - RCMessages.sectionFooterRight()
        let height: CGFloat = (labelSectionFooter!.text != nil) ? RCMessages.sectionFooterHeight : 0
        labelSectionFooter?.frame = CGRect(x: RCMessages.sectionFooterLeft(), y: 0, width: width, height: height)
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        return (messagesView?.textSectionFooter(indexPath) != nil) ? RCMessages.sectionFooterHeight : 0
    }
}
