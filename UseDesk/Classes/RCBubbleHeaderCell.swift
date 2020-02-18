//
//  RCBubbleHeaderCell.swift

import Foundation

class RCBubbleHeaderCell: UITableViewCell {

    var labelBubbleHeader: UILabel?

    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        return (messagesView?.textBubbleHeader(indexPath) != nil) ? RCMessages.bubbleHeaderHeight() : 0
    }
    
    func bindData(_ indexPath: IndexPath?, messagesView: RCMessagesView?) {
        backgroundColor = UIColor.clear
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if labelBubbleHeader == nil {
            labelBubbleHeader = UILabel()
            labelBubbleHeader!.font = RCMessages.bubbleHeaderFont()
            labelBubbleHeader!.textColor = RCMessages.bubbleHeaderColor()
            contentView.addSubview(labelBubbleHeader!)
        }
        labelBubbleHeader!.textAlignment = rcmessage?.incoming != false ? .left : .right
        labelBubbleHeader!.text = messagesView?.textBubbleHeader(indexPath)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width: CGFloat = SCREEN_WIDTH - RCMessages.bubbleHeaderLeft() - RCMessages.bubbleHeaderRight()
        let height: CGFloat = (labelBubbleHeader!.text != nil) ? RCMessages.bubbleHeaderHeight() : 0
        labelBubbleHeader!.frame = CGRect(x: RCMessages.bubbleHeaderLeft(), y: 0, width: width, height: height)
    }

}
