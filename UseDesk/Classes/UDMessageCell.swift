//
//  UDMessageCell.swift


import Foundation

class UDMessageCell: UITableViewCell {

    let viewBubble = UIView()
    let imageAvatar = UIImageView()
    let labelSender = UILabel()
    let timeLabel = UILabel()
    
    var isNeedShowSender = true
    var configurationStyle = ConfigurationStyle()
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        guard message != nil else { return }
        backgroundColor = UIColor.clear
        
        viewBubble.backgroundColor = message?.incoming != false ? configurationStyle.bubbleStyle.bubbleColorIncoming : configurationStyle.bubbleStyle.bubbleColorOutgoing
        if viewBubble.superview == nil {
            contentView.addSubview(viewBubble)
        }
        bubbleGestureRecognizer()
        
        timeLabel.textColor = message?.incoming != false ? configurationStyle.messageStyle.timeIncomingColor : configurationStyle.messageStyle.timeOutgoingColor
        timeLabel.font = configurationStyle.messageStyle.timeFont
        timeLabel.text = message?.date?.time ?? ""
        if timeLabel.superview == nil {
            viewBubble.addSubview(timeLabel)
        }
        
        if message!.incoming {
            if isNeedShowSender {
                if labelSender.superview == nil {
                    contentView.addSubview(labelSender)
                }
            } else {
                labelSender.removeFromSuperview()
            }
            imageAvatar.layer.masksToBounds = true
            imageAvatar.layer.cornerRadius = configurationStyle.avatarStyle.avatarDiameter / 2
            imageAvatar.backgroundColor = configurationStyle.avatarStyle.avatarBackColor
            imageAvatar.isUserInteractionEnabled = true
            contentView.addSubview(imageAvatar)
            imageAvatar.image = messagesView?.avatarImage(indexPath)
        } else {
            labelSender.removeFromSuperview()
            imageAvatar.removeFromSuperview()
        }
    }

    func layoutSubviews(_ size: CGSize) {
        super.layoutSubviews()
        
        guard let message: UDMessage = messagesView?.getMessage(indexPath) else { return }
        
        var xBubble: CGFloat = 0
        if message.incoming {
            xBubble = configurationStyle.avatarStyle.avatarIncomingHidden ? configurationStyle.bubbleStyle.bubbleMarginLeft : (configurationStyle.avatarStyle.avatarDiameter + configurationStyle.avatarStyle.margin.left + configurationStyle.avatarStyle.margin.right)
        } else {
            xBubble = (SCREEN_WIDTH - configurationStyle.bubbleStyle.bubbleMarginRight - size.width) 
        } 
        if message.incoming {
            let maxwidth: CGFloat = SCREEN_WIDTH - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - 40
            let heightLabelSender = "Tept".size(availableWidth: size.width, attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.senderTextFont]).height
            labelSender.frame = CGRect(x: xBubble, y: 0, width: maxwidth, height: heightLabelSender)
            labelSender.text = message.operatorName != "" ? message.operatorName : message.name
            labelSender.textColor = configurationStyle.messageStyle.senderTextColor
            labelSender.font = configurationStyle.messageStyle.senderTextFont
        }
        
        let heightSenderText = "Tept".size(attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.senderTextFont]).height
        viewBubble.frame = CGRect(x: xBubble, y: message.incoming && isNeedShowSender ? configurationStyle.messageStyle.senderTextMarginBottom + heightSenderText : 0, width: size.width, height: size.height)
        
        let diameter = configurationStyle.avatarStyle.avatarDiameter
        var xAvatar: CGFloat?
        var yAvatar: CGFloat?
        if !configurationStyle.avatarStyle.avatarIncomingHidden {
            xAvatar = configurationStyle.avatarStyle.margin.left
            yAvatar = size.height + (message.incoming && isNeedShowSender ? heightSenderText : 0) - diameter
        }
        imageAvatar.isHidden = configurationStyle.avatarStyle.avatarIncomingHidden
        if let x = xAvatar, let y = yAvatar {
            imageAvatar.frame = CGRect(x: x, y: y, width: diameter, height: diameter)
        }
        let sizeTime: CGSize = timeLabel.text?.size(attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.timeFont]) ?? CGSize.zero
        timeLabel.frame = CGRect(x: viewBubble.frame.width - sizeTime.width - configurationStyle.messageStyle.timeMargin.right, y: viewBubble.frame.height - sizeTime.height - configurationStyle.messageStyle.timeMargin.bottom, width: sizeTime.width, height: sizeTime.height)
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            if message.outgoing {
                if contentView.frame.origin.x > 0 {
                    viewBubble.frame.origin.x -= 44
                    imageAvatar.frame.origin.x -= 44
                    labelSender.frame.origin.x -= 44
                }
            } 
        }
        if message.incoming {
            viewBubble.cornerRadiusFromChatWithoutBottomLeft(cornerRadius: configurationStyle.bubbleStyle.bubbleRadius)
        } else {
            viewBubble.cornerRadiusFromChatWithoutBottomRight(cornerRadius: configurationStyle.bubbleStyle.bubbleRadius)
        }
    }
    
    // MARK: - Gesture recognizer methods
    func bubbleGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapBubble))
        viewBubble.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.actionLongBubble(_:)))
        viewBubble.addGestureRecognizer(longGesture)
    }
    
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
    
    @objc func actionLongBubble(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        switch gestureRecognizer?.state {
        case .began?:
            actionMenu()
        case .changed?:
            break
        case .ended?:
            break
        case .possible?:
            break
        case .cancelled?:
            break
        case .failed?:
            break
        default:
            break
        }
    }
    
    func actionMenu() {
        if messagesView?.textInput.isFirstResponder == false {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView?.menuItems(indexPath) as? [UIMenuItem]
            menuController.setTargetRect(viewBubble.frame, in: contentView)
            menuController.setMenuVisible(true, animated: true)
        } else {
            messagesView?.textInput.resignFirstResponder()
        }
    }
}
