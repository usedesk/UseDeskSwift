//
//  UDTextMessageCell.swift

import Foundation

class UDTextMessageCell: UDMessageCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let textView = UITextView()
    var collectionView: UICollectionView!
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    private weak var message: UDMessage?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        message = messagesView?.getMessage(indexPath)
        let messageStyle = configurationStyle.messageStyle
        
        super.bindData(indexPath, messagesView: messagesView)
        
        textView.font = messageStyle.font
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textColor = message?.incoming != false ? messageStyle.textIncomingColor : messageStyle.textOutgoingColor
        textView.text = message?.text
        if textView.superview == nil {
            viewBubble.addSubview(textView)
        }
        
        if message != nil {
            if message!.buttons.count > 0 {
                let layout = UICollectionViewFlowLayout()
                collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.register(UDMessageButtonCell.self, forCellWithReuseIdentifier: "UDMessageButtonCell")
                collectionView.backgroundColor = UIColor.clear
                if collectionView.superview == nil {
                    viewBubble.addSubview(collectionView)
                }
                collectionView.reloadData()
            }
        }
    }
    
    override func layoutSubviews() {
        let bubbleSize: CGSize = size(indexPath, messagesView: messagesView)
        var size = bubbleSize
        let messageStyle = configurationStyle.messageStyle
        let messageButtonStyle = configurationStyle.messageButtonStyle
        
        let labelTime = UILabel()
        labelTime.text = message?.date?.time ?? ""
        let widthTime: CGFloat = labelTime.text?.size(attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.timeFont]).width ?? 0
        
        if message != nil {
            if message!.buttons.count > 0 {
                let heightButtonsBlock = heightButtons(message: message!)
                let heightTextButton = "Tept".size(attributes: [NSAttributedString.Key.font : messageButtonStyle.textFont]).height
                let heightItem = heightTextButton + messageButtonStyle.padding.top + messageButtonStyle.padding.bottom
                size = CGSize(width: size.width, height: size.height)
                super.layoutSubviews(size)
                var collectionViewWidth = size.width - messageButtonStyle.margin.left - widthTime - messageButtonStyle.margin.right
                if message!.outgoing {
                    collectionViewWidth -= messageStyle.sendedStatusMargin.right - messageStyle.sendedStatusSize.width - messageStyle.timeMarginRightForStatus
                } else {
                    collectionViewWidth -= messageStyle.timeMargin.right
                }
                let yPosition = bubbleSize.height - (heightButtonsBlock - messageButtonStyle.margin.top)
                collectionView.frame = CGRect(x: messageButtonStyle.margin.left, y: yPosition, width: collectionViewWidth, height: heightButtonsBlock - messageButtonStyle.margin.top - messageButtonStyle.margin.bottom)
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSize(width: collectionViewWidth, height: heightItem)
                collectionView.collectionViewLayout = layout
            } else {
                super.layoutSubviews(size)
            }
        
        
            var widthText: CGFloat = message?.text.size(attributes: [NSAttributedString.Key.font : messageStyle.font]).width ?? 0
            var maxwidthText = size.width - messageStyle.textMargin.left - messageStyle.textMargin.right - widthTime - messageStyle.timeMargin.right
            if message!.outgoing {
                maxwidthText -= messageStyle.sendedStatusMargin.right - messageStyle.sendedStatusSize.width
            }
            widthText = widthText > maxwidthText ? maxwidthText : widthText
            let heightText: CGFloat = message?.text.size(availableWidth: widthText, attributes: [NSAttributedString.Key.font : messageStyle.font]).height ?? 0
            textView.frame = CGRect(x: messageStyle.textMargin.left, y: messageStyle.textMargin.top, width: widthText, height: heightText)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard collectionView != nil else {return}
        collectionView.removeFromSuperview()
    }
    
    // MARK: - Size methods
    func height(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGFloat {
        let bubbleSize: CGSize = size(indexPath, messagesView: messagesView)
        return bubbleSize.height
    }
    
    func size(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGSize {
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        guard message != nil else {return CGSize.zero}
        let messageStyle = configurationStyle.messageStyle

        let maxwidth: CGFloat = SCREEN_WIDTH - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - 40
        let widthText: CGFloat = message?.text.size(attributes: [NSAttributedString.Key.font : messageStyle.font]).width ?? 0
        let labelTime = UILabel()
        labelTime.text = message?.date?.time ?? ""
        let widthTime: CGFloat = labelTime.text?.size(attributes: [NSAttributedString.Key.font : messageStyle.timeFont]).width ?? 0
        var width: CGFloat = 0
        var isExistButtons = false
        if message!.buttons.count > 0 {
            width = maxwidth
            isExistButtons = true
        } else {
            width = widthText + messageStyle.textMargin.left + messageStyle.textMargin.right + widthTime + messageStyle.timeMargin.right
            if message!.outgoing {
                width += messageStyle.sendedStatusMargin.right + messageStyle.sendedStatusSize.width
            }
            width = width > maxwidth ? maxwidth : width
        }
        let heightText: CGFloat = message!.text.size(availableWidth: width - (messageStyle.textMargin.left + messageStyle.textMargin.right + widthTime + messageStyle.timeMargin.right), attributes: [NSAttributedString.Key.font : messageStyle.font], usesFontLeading: true).height
        var height: CGFloat = message!.text.count > 0 ? heightText + messageStyle.textMargin.top : 0
        let heightButtonsBlock = heightButtons(message: message!)
        height += isExistButtons ? heightButtonsBlock : (message!.text.count > 0 ? messageStyle.textMargin.bottom : 0)
        
        return CGSize(width: CGFloat(fmaxf(Float(width), Float(configurationStyle.bubbleStyle.bubbleWidthMin))), height: CGFloat(fmaxf(Float(height), Float(configurationStyle.bubbleStyle.bubbleHeightMin))))
    }
    
    func heightButtons(message: UDMessage) -> CGFloat {
        guard message.buttons.count > 0 else {return 0}
        var heightButtons: CGFloat = configurationStyle.messageButtonStyle.margin.top
        let heightTextButton = "Tept".size(attributes: [NSAttributedString.Key.font : configurationStyle.messageButtonStyle.textFont]).height
        let heightItem = heightTextButton + configurationStyle.messageButtonStyle.padding.top + configurationStyle.messageButtonStyle.padding.bottom
        for _ in message.buttons {
            heightButtons += heightItem + configurationStyle.messageButtonStyle.margin.bottom
        }
        return heightButtons
    }
    // MARK: - CollectionView methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return message?.buttons.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UDMessageButtonCell", for: indexPath) as! UDMessageButtonCell
        cell.setingCell(titleButton: message?.buttons[indexPath.row].title ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if message?.buttons[indexPath.row].url != "" {
            let urlDataDict:[String: String] = ["url": message!.buttons[indexPath.row].url]
            NotificationCenter.default.post(name: Notification.Name("messageButtonURLOpen"), object: nil, userInfo: urlDataDict)
        } else {
            let textDataDict:[String: String] = ["text": message?.buttons[indexPath.row].title ?? ""]
            NotificationCenter.default.post(name: Notification.Name("messageButtonSend"), object: nil, userInfo: textDataDict)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return configurationStyle.messageButtonStyle.margin.bottom
    }
}


