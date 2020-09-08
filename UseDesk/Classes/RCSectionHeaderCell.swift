//
//  RCSectionHeaderCell.swift

import Foundation

class RCSectionHeaderCell: UITableViewCell {
    var labelSectionHeader: UILabel?
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        backgroundColor = UIColor.clear
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if labelSectionHeader == nil {
                labelSectionHeader = UILabel()
                labelSectionHeader!.font = RCMessages.sectionHeaderFont()
                labelSectionHeader!.textColor = RCMessages.sectionHeaderColor()
                contentView.addSubview(labelSectionHeader!)
                labelSectionHeader!.textAlignment = .center
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if rcmessage!.date != nil {
                labelSectionHeader!.text = rcmessage!.date!.dateFromHeaderComments
            }
        }
        let width: CGFloat = SCREEN_WIDTH - RCMessages.sectionHeaderLeft() - RCMessages.sectionHeaderRight()
        let height: CGFloat = (labelSectionHeader?.text != nil) ? RCMessages.sectionHeaderHeight : 0
        labelSectionHeader?.frame = CGRect(x: RCMessages.sectionHeaderLeft(), y: 0, width: width, height: height)
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            if contentView.frame.origin.x > 0 {
                labelSectionHeader?.frame.origin.x -= 22
            }
        }
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            return RCMessages.sectionHeaderHeight
        } else {
            return 0
        }
    }
}
