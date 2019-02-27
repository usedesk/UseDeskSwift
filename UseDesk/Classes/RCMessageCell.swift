//
//  RCMessageCell.swift


import Foundation

class RCMessageCell: UITableViewCell {

    var viewBubble: UIView!
    var imageAvatar: UIImageView!
    var labelAvatar: UILabel!
    
    private var indexPath: IndexPath?
    private var messagesView: RCMessagesView?
    
    func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        
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
        
        imageAvatar.image = messagesView!.avatarImage(indexPath)
        
        if labelAvatar == nil {
            labelAvatar = UILabel()
            labelAvatar.font = RCMessages.avatarFont()
            labelAvatar.textColor = RCMessages.avatarTextColor()
            labelAvatar.textAlignment = .center
            contentView.addSubview(labelAvatar)
        }
        
        labelAvatar.text = (imageAvatar.image == nil) ? messagesView!.avatarInitials(indexPath) : nil
    }

    func layoutSubviews(_ size: CGSize) {
        super.layoutSubviews()
        
        let rcmessage: RCMessage? = messagesView!.rcmessage(indexPath)
        
        let xBubble: CGFloat = rcmessage?.incoming != false ? RCMessages.bubbleMarginLeft() : (SCREEN_WIDTH - RCMessages.bubbleMarginRight() - size.width)
        viewBubble.frame = CGRect(x: xBubble, y: 0, width: size.width, height: size.height)
        
        let diameter = RCMessages.avatarDiameter()
        let xAvatar: CGFloat = rcmessage?.incoming != false ? RCMessages.avatarMarginLeft() : (SCREEN_WIDTH - RCMessages.avatarMarginRight() - diameter)
        imageAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
        labelAvatar.frame = CGRect(x: xAvatar, y: size.height - diameter, width: diameter, height: diameter)
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
        messagesView!.view.endEditing(true)
        messagesView!.actionTapBubble(indexPath)
    }
    
    @objc func actionTapAvatar() {
        messagesView!.view.endEditing(true)
        messagesView!.actionTapAvatar(indexPath)
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
        if messagesView!.textInput.isFirstResponder == false {
            let menuController = UIMenuController.shared
            menuController.menuItems = messagesView!.menuItems(indexPath) as? [UIMenuItem]
            menuController.setTargetRect(viewBubble.frame, in: contentView)
            menuController.setMenuVisible(true, animated: true)
        } else {
            messagesView!.textInput.resignFirstResponder()
        }
    }
}
