//
//  RCStatusCell.swift

import Foundation

class RCStatusCell: UITableViewCell {

    var viewBubble: UIView?
    var textView: UITextView?

    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        
        backgroundColor = UIColor.clear
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        if viewBubble == nil {
            viewBubble = UIView()
            viewBubble!.backgroundColor = RCMessages.statusBubbleColor()
            viewBubble!.layer.cornerRadius = RCMessages.statusBubbleRadius()
            contentView.addSubview(viewBubble!)
            bubbleGestureRecognizer()
        }
        if textView == nil {
            textView = UITextView()
            textView!.font = RCMessages.statusFont()
            textView!.textColor = RCMessages.statusTextColor()
            textView!.isEditable = false
            textView!.isSelectable = false
            textView!.isScrollEnabled = false
            textView!.isUserInteractionEnabled = false
            textView!.backgroundColor = UIColor.clear
            textView!.textContainer.lineFragmentPadding = 0
            textView!.textContainerInset = RCMessages.statusInset()
            viewBubble!.addSubview(textView!)
        }
        textView?.text = rcmessage?.text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGSize = RCStatusCell.size(indexPath, messagesView: messagesView)
        
        let yBubble = RCMessages.sectionHeaderMargin()
        let xBubble: CGFloat = (SCREEN_WIDTH - size.width) / 2
        viewBubble?.frame = CGRect(x: xBubble, y: yBubble, width: size.width, height: size.height)
        
        textView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        let maxwidth: CGFloat = (0.95 * SCREEN_WIDTH) - RCMessages.statusInsetLeft() - RCMessages.statusInsetRight()
        let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: RCMessages.statusFont() as Any
            ], context: nil)
        
        let width: CGFloat = (rect?.size.width ?? 0.0) + RCMessages.statusInsetLeft() + RCMessages.statusInsetRight()
        let height: CGFloat = (rect?.size.height ?? 0.0) + RCMessages.statusInsetTop() + RCMessages.statusInsetBottom()
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Gesture recognizer methods
    func bubbleGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapBubble))
        viewBubble?.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
}
