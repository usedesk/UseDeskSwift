//
//  RCEmojiMessage.swift


import UIKit

protocol UDFeedbackMessageCellDElegate: class {
    func feedbackAction(indexPath: IndexPath, feedback: Bool)
}

class UDFeedbackMessageCell: UDMessageCell {

    let textView = UITextView()
    let likeButton = UIButton(type: .custom)
    let dislikeButton = UIButton(type: .custom)
    
    var feedbackAction: Bool?
    
    weak var usedesk: UseDeskSDK?
    weak var delegate: UDFeedbackMessageCellDElegate?
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        let feedbackMessageStyle = configurationStyle.feedbackMessageStyle
        
        super.bindData(indexPath, messagesView: messagesView)
        
        textView.font = feedbackMessageStyle.font
        textView.textColor = feedbackMessageStyle.textColor
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        if textView.superview == nil {
            viewBubble.addSubview(textView)
        }
        
        if feedbackAction != nil {
            dislikeButton.setBackgroundImage(feedbackMessageStyle.dislikeOnImage, for: .normal)
        } else {
            dislikeButton.setBackgroundImage(feedbackMessageStyle.dislikeOffImage, for: .normal)
        }
        dislikeButton.addTarget(self, action: #selector(self.dislikeButton_pressed(_:)), for: .touchUpInside)
        dislikeButton.alpha = 0
        dislikeButton.isUserInteractionEnabled = true
        if dislikeButton.superview == nil {
            viewBubble.addSubview(dislikeButton)
        }
        
        if feedbackAction != nil {
            likeButton.setBackgroundImage(feedbackMessageStyle.likeOnImage, for: .normal)
        } else {
            likeButton.setBackgroundImage(feedbackMessageStyle.likeOffImage, for: .normal)
        }
        likeButton.addTarget(self, action: #selector(self.likeButton_pressed(_:)), for: .touchUpInside)
        likeButton.alpha = 0
        likeButton.isUserInteractionEnabled = true
        if likeButton.superview == nil {
            viewBubble.addSubview(likeButton)
        }
        
        if message != nil {
            if message!.feedbackAction != nil {
                likeButton.alpha = message!.feedbackAction! ? 1 : 0
                dislikeButton.alpha = message!.feedbackAction! ? 0 : 1
            } else {
                likeButton.alpha = 1
                dislikeButton.alpha = 1
            }
        }
        textView.text = message?.text
    }
    
    // MARK: - Size methods
    func height(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    func size(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGSize {
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        let messageStyle = configurationStyle.messageStyle
        let labelTime = UILabel()
        labelTime.text = message?.date?.time ?? ""
        let widthTime: CGFloat = labelTime.text?.size(attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.timeFont]).width ?? 0
        if message != nil {
            let feedbackMessageStyle = configurationStyle.feedbackMessageStyle
            let width: CGFloat = SCREEN_WIDTH - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - widthTime - messageStyle.timeMargin.right - messageStyle.sendedStatusMargin.right - messageStyle.sendedStatusSize.width
            let heightText: CGFloat = message?.text.size(availableWidth: width - feedbackMessageStyle.textMargin.left - feedbackMessageStyle.textMargin.right, attributes: [NSAttributedString.Key.font : feedbackMessageStyle.font]).height ?? 0
            let height: CGFloat = feedbackMessageStyle.buttonsMargin.top + feedbackMessageStyle.buttonSize.height + heightText + feedbackMessageStyle.textMargin.top + feedbackMessageStyle.textMargin.bottom
            
            return CGSize(width: CGFloat(fmaxf(Float(width), Float(configurationStyle.bubbleStyle.bubbleWidthMin))), height: CGFloat(fmaxf(Float(height), Float(configurationStyle.bubbleStyle.bubbleHeightMin))))
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    @objc func dislikeButton_pressed(_ sender: Any?) {
        feedbackAction = false
        likeButton.isUserInteractionEnabled = false
        var frame = dislikeButton.frame
        frame.origin.x += ((configurationStyle.feedbackMessageStyle.buttonSize.width / 2) + (configurationStyle.feedbackMessageStyle.buttonsMargin.right / 2))
        dislikeButton.setBackgroundImage(configurationStyle.feedbackMessageStyle.dislikeOnImage, for: .normal)
        UIView.animate(withDuration: 0.4) {
            self.dislikeButton.frame = frame
            self.likeButton.alpha = 0
        } completion: { (_) in
            if self.indexPath != nil {
                self.delegate?.feedbackAction(indexPath: self.indexPath!, feedback: false)
            }
            let message: UDMessage? = self.messagesView?.getMessage(self.indexPath)
            self.usedesk.self?.sendMessageFeedBack(false, message_id: message?.messageId ?? 0)
        }
    }
    
    @objc func likeButton_pressed(_ sender: Any?) {
        feedbackAction = true
        likeButton.isUserInteractionEnabled = false
        var frame = likeButton.frame
        frame.origin.x -= ((configurationStyle.feedbackMessageStyle.buttonSize.width / 2) + (configurationStyle.feedbackMessageStyle.buttonsMargin.left / 2))
        likeButton.setBackgroundImage(configurationStyle.feedbackMessageStyle.likeOnImage, for: .normal)
        UIView.animate(withDuration: 0.4) {
            self.likeButton.frame = frame
            self.dislikeButton.alpha = 0
        } completion: { (_) in
            if self.indexPath != nil {
                self.delegate?.feedbackAction(indexPath: self.indexPath!, feedback: true)
            }
            let message: UDMessage? = self.messagesView?.getMessage(self.indexPath)
            self.usedesk.self?.sendMessageFeedBack(true, message_id: message?.messageId ?? 0)
        }
    }
    
    override func layoutSubviews() {
        let sizeFeedback: CGSize = size(indexPath, messagesView: messagesView)
        let feedbackMessageStyle = configurationStyle.feedbackMessageStyle
        super.layoutSubviews(sizeFeedback)
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        let heightText: CGFloat = message?.text.size(availableWidth: sizeFeedback.width - feedbackMessageStyle.textMargin.left - feedbackMessageStyle.textMargin.right, attributes: [NSAttributedString.Key.font : feedbackMessageStyle.font]).height ?? 0
        textView.frame = CGRect(x: feedbackMessageStyle.textMargin.left, y: feedbackMessageStyle.buttonsMargin.top + feedbackMessageStyle.buttonSize.height + feedbackMessageStyle.textMargin.top, width: sizeFeedback.width - feedbackMessageStyle.textMargin.left - feedbackMessageStyle.textMargin.right, height: heightText)
        if feedbackAction != nil {
            dislikeButton.frame = CGRect(x: (sizeFeedback.width / 2) - (feedbackMessageStyle.buttonSize.width / 2), y: feedbackMessageStyle.buttonsMargin.top, width: feedbackMessageStyle.buttonSize.width, height: feedbackMessageStyle.buttonSize.height)
            likeButton.frame = CGRect(x: (sizeFeedback.width / 2) - (feedbackMessageStyle.buttonSize.width / 2), y: feedbackMessageStyle.buttonsMargin.top, width: feedbackMessageStyle.buttonSize.width, height: feedbackMessageStyle.buttonSize.height)
        } else {
            dislikeButton.frame = CGRect(x: (sizeFeedback.width / 2) - feedbackMessageStyle.buttonSize.width - (feedbackMessageStyle.buttonsMargin.right / 2), y: feedbackMessageStyle.buttonsMargin.top, width: feedbackMessageStyle.buttonSize.width, height: feedbackMessageStyle.buttonSize.height)
            likeButton.frame = CGRect(x: (sizeFeedback.width / 2) + (feedbackMessageStyle.buttonsMargin.left / 2), y: feedbackMessageStyle.buttonsMargin.top, width: feedbackMessageStyle.buttonSize.width, height: feedbackMessageStyle.buttonSize.height)
        }
    }
    
}
