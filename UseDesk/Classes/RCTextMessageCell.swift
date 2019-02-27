//
//  RCTextMessageCell.swift

import Foundation

class RCTextMessageCell: RCMessageCell {

    var textView: UITextView?
    
    private var indexPath: IndexPath?
    private var messagesView: RCMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.textBubbleColorIncoming() : RCMessages.textBubbleColorOutgoing()
        
        if textView == nil {
            textView = UITextView()
            textView!.font = RCMessages.textFont()
            textView!.isEditable = false
            textView!.isSelectable = false
            textView!.isScrollEnabled = false
            textView!.isUserInteractionEnabled = false
            textView!.backgroundColor = UIColor.clear
            textView!.textContainer.lineFragmentPadding = 0
            textView!.textContainerInset = RCMessages.textInset()
            viewBubble!.addSubview(textView!)
        }
        
        textView!.textColor = rcmessage?.incoming != false ? RCMessages.textTextColorIncoming() : RCMessages.textTextColorOutgoing()
        
        textView!.text = rcmessage?.text
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCTextMessageCell.size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(size)
        
        textView!.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        let maxwidth: CGFloat = (0.6 * SCREEN_WIDTH) - RCMessages.textInsetLeft() - RCMessages.textInsetRight()
        
        let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: RCMessages.textFont() as Any
            ], context: nil)
        
        let width: CGFloat = (rect?.size.width ?? 0.0) + RCMessages.textInsetLeft() + RCMessages.textInsetRight()
        let height: CGFloat = (rect?.size.height ?? 0.0) + RCMessages.textInsetTop() + RCMessages.textInsetBottom()
        
        return CGSize(width: CGFloat(fmaxf(Float(width), Float(RCMessages.textBubbleWidthMin()))), height: CGFloat(fmaxf(Float(height), Float(RCMessages.textBubbleHeightMin()))))
    }
}
