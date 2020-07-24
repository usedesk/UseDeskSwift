//
//  RCMessageCell.swift


import Foundation

class RCMessageCell: UITableViewCell {

    var viewBubble: UIView!
    var imageAvatar: UIImageView!
    var labelAvatar: UILabel!
    var label: UILabel!
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    
    let kHeightName: CGFloat = 15
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            if rcmessage!.incoming {
                if label == nil {
                    label = UILabel()
                    contentView.addSubview(label)
                }
            } else {
                if label != nil {
                    label.removeFromSuperview()
                    label = nil
                }
            }
        }
        backgroundColor = UIColor.clear
       
        if viewBubble == nil {
            viewBubble = UIView()
            viewBubble.layer.cornerRadius = RCMessages.bubbleRadius()
            contentView.addSubview(viewBubble)
            bubbleGestureRecognizer()
        }
        
        if imageAvatar == nil {
            imageAvatar = UIImageView()
            imageAvatar.layer.masksToBounds = true
            imageAvatar.layer.cornerRadius = RCMessages.avatarDiameter() / 2
            imageAvatar.backgroundColor = RCMessages.avatarBackColor()
            imageAvatar.isUserInteractionEnabled = true
            contentView.addSubview(imageAvatar)
            avatarGestureRecognizer()
        }
        
        imageAvatar.image = messagesView?.avatarImage(indexPath)
        
        if labelAvatar == nil {
            labelAvatar = UILabel()
            labelAvatar.font = RCMessages.avatarFont()
            labelAvatar.textColor = RCMessages.avatarTextColor()
            labelAvatar.textAlignment = .center
            contentView.addSubview(labelAvatar)
        }
        
        labelAvatar.text = (imageAvatar.image == nil) ? messagesView?.avatarInitials(indexPath) : nil
    }

    func layoutSubviews(_ size: CGSize) {
        super.layoutSubviews()
        
        guard let rcmessage: RCMessage = messagesView?.rcmessage(indexPath) else { return }
        
        let xBubble: CGFloat = rcmessage.incoming != false ? RCMessages.bubbleMarginLeft() : (SCREEN_WIDTH - RCMessages.bubbleMarginRight() - size.width)
        if rcmessage.incoming {
            let widthLabel: CGFloat = size.width < 200 ? 200 : size.width
            label.frame = CGRect(x: xBubble, y: 0, width: widthLabel, height: kHeightName)
            label.text = rcmessage.name
            label.textColor = UIColor(hexString: "828282")
            label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }
        viewBubble.frame = CGRect(x: xBubble, y: rcmessage.incoming ? 18 : 0, width: size.width, height: size.height)
        
        let diameter = RCMessages.avatarDiameter()
        var xAvatar: CGFloat?
        var yAvatar: CGFloat?
        if rcmessage.incoming {
            if !RCMessages.avatarIncomingHidden() {
                xAvatar = RCMessages.avatarMarginLeft()
                yAvatar = size.height - diameter + 18
            }
            imageAvatar.isHidden = RCMessages.avatarIncomingHidden()
            labelAvatar.isHidden = RCMessages.avatarIncomingHidden()
        } else {
            if !RCMessages.avatarOutgoingHidden() {
                xAvatar = SCREEN_WIDTH - RCMessages.avatarMarginRight() - diameter
                yAvatar = size.height - diameter
            }
            imageAvatar.isHidden = RCMessages.avatarOutgoingHidden()
            labelAvatar.isHidden = RCMessages.avatarOutgoingHidden()
        }
        if let x = xAvatar, let y = yAvatar {
            imageAvatar.frame = CGRect(x: x, y: y, width: diameter, height: diameter)
            labelAvatar.frame = CGRect(x: x, y: y, width: diameter, height: diameter)
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
    
    func avatarGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionTapAvatar))
        imageAvatar.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
    
    @objc func actionTapAvatar() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapAvatar(indexPath)
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
