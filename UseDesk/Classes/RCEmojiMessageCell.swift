//
//  RCEmojiMessage.swift


import Foundation

class RCEmojiMessageCell: RCMessageCell {

    var textView: UITextView?
    var likeButton: UIButton?
    var dislikeButton: UIButton?
    weak var usedesk: UseDeskSDK?
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.emojiBubbleColorIncoming() : RCMessages.emojiBubbleColorOutgoing()
        
        if textView == nil {
            textView = UITextView()
            textView!.font = RCMessages.textFont()
            textView!.isEditable = false
            textView!.isSelectable = false
            textView!.textAlignment = .center
            textView!.isScrollEnabled = false
            textView!.isUserInteractionEnabled = false
            textView!.backgroundColor = UIColor.clear
            textView!.textContainer.lineFragmentPadding = 0
            textView!.textContainerInset = RCMessages.emojiInset()
            viewBubble.addSubview(textView!)
        }
        
        if dislikeButton == nil {
            dislikeButton = UIButton(type: .custom)
            dislikeButton!.setBackgroundImage(UIImage.named("dislike"), for: .normal)
            dislikeButton!.addTarget(self, action: #selector(self.dislikeButton_pressed(_:)), for: .touchUpInside)
            viewBubble.addSubview(dislikeButton!)
        }
        
        if likeButton == nil {
            likeButton = UIButton(type: .custom)
            likeButton!.setBackgroundImage(UIImage.named("like"), for: .normal)
            likeButton!.addTarget(self, action: #selector(self.likeButton_pressed(_:)), for: .touchUpInside)
            viewBubble.addSubview(likeButton!)
        }
        
        textView!.text = rcmessage?.text
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        var size: CGSize = self.size(indexPath, messagesView: messagesView)
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if rcmessage!.incoming {
                size = CGSize(width: size.width, height: size.height + 18)
            }
        }
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            let maxwidth: CGFloat = (0.6 * SCREEN_WIDTH) - RCMessages.emojiInsetLeft() - RCMessages.emojiInsetRight()
            let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: RCMessages.textFont() as Any], context: nil)
            let widthText = (rect?.size.width ?? 0.0) + RCMessages.emojiInsetLeft() + RCMessages.emojiInsetRight()
            let width: CGFloat = CGFloat(fmaxf(Float(widthText), Float((RCMessages.emojiButtonWidth() * 2) + (RCMessages.emojiButtonInsetOfCenter() * 2))))
            var height: CGFloat = (rect?.size.height ?? 0.0) + RCMessages.emojiInsetTop() + RCMessages.emojiInsetBottom() + RCMessages.emojiButtonHeight()
            return CGSize(width: CGFloat(fmaxf(Float(width), Float(RCMessages.emojiBubbleWidthMin()))), height: CGFloat(fmaxf(Float(height), Float(RCMessages.emojiBubbleHeightMin()))))
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    @objc func dislikeButton_pressed(_ sender: Any?) {
        usedesk.self?.sendMessageFeedBack(false)
    }
    
    @objc func likeButton_pressed(_ sender: Any?) {
        usedesk.self?.sendMessageFeedBack(true)
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCEmojiMessageCell.size(indexPath, messagesView: messagesView)
        super.layoutSubviews(size)
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if rcmessage!.incoming {
                imageAvatar.frame = CGRect(x: imageAvatar.frame.origin.x, y: imageAvatar.frame.origin.y + 18, width: imageAvatar.frame.size.width, height: imageAvatar.frame.size.height)
            }
        }
        if textView != nil {
            textView!.frame = CGRect(x: 0, y: RCMessages.emojiButtonHeight(), width: size.width, height: size.height - RCMessages.emojiInsetTop() + RCMessages.emojiInsetBottom() + RCMessages.emojiButtonHeight())
        }
        dislikeButton?.frame = CGRect(x: (size.width / 2) - RCMessages.emojiButtonWidth() - RCMessages.emojiButtonInsetOfCenter(), y: RCMessages.emojiButtonInsetTop(), width: RCMessages.emojiButtonWidth(), height: RCMessages.emojiButtonHeight() - RCMessages.emojiButtonInsetTop() - RCMessages.emojiButtonInsetBottom())
        likeButton?.frame = CGRect(x: (size.width / 2) + RCMessages.emojiButtonInsetOfCenter(), y: RCMessages.emojiButtonInsetTop(), width: RCMessages.emojiButtonWidth(), height: RCMessages.emojiButtonHeight() - RCMessages.emojiButtonInsetTop() - RCMessages.emojiButtonInsetBottom())
    }
    
}
