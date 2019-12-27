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
            dislikeButton!.setBackgroundImage(UIImage(named: "ic_dislike.png"), for: .normal)
            dislikeButton!.addTarget(self, action: #selector(self.dislikeButton_pressed(_:)), for: .touchUpInside)
            viewBubble.addSubview(dislikeButton!)
        }
        
        if likeButton == nil {
            
            likeButton = UIButton(type: .custom)
            likeButton!.setBackgroundImage(UIImage(named: "ic_like.png"), for: .normal)
            likeButton!.addTarget(self, action: #selector(self.likeButton_pressed(_:)), for: .touchUpInside)
            viewBubble.addSubview(likeButton!)
        }
        
        textView!.text = rcmessage?.text
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            let maxwidth: CGFloat = (0.6 * SCREEN_WIDTH) - RCMessages.emojiInsetLeft() - RCMessages.emojiInsetRight()
            let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: RCMessages.emojiFont() as Any], context: nil)
            let width: CGFloat = (rect?.size.width ?? 0.0) + RCMessages.emojiInsetLeft() + RCMessages.emojiInsetRight()
            var height: CGFloat = (rect?.size.height ?? 0.0) + RCMessages.emojiInsetTop() + RCMessages.emojiInsetBottom()     
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
        textView?.frame = CGRect(x: 0, y: size.height - 80, width: size.width, height: 80)
        dislikeButton?.frame = CGRect(x: size.width * 1 / 10, y: size.height / 4, width: size.width / 4, height: size.height / 4)
        likeButton?.frame = CGRect(x: size.width * 2 / 3, y: size.height / 4, width: size.width / 4, height: size.height / 4)        
    }
    
}
