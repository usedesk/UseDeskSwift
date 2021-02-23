//
//  UDFileMessageCell.swift
//  UseDesk_SDK_Swift


import Foundation

class UDFileMessageCell: UDMessageCell {

    let iconImage = UIImageView()
    let nameFileLabel = UILabel()
    let sizeFileLabel = UILabel()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        guard let message: UDMessage = messagesView!.getMessage(indexPath) else { return }
        super.bindData(indexPath, messagesView: messagesView)
        let fileStyle = configurationStyle.fileStyle
        nameFileLabel.text = message.file.name != "" ? message.file.name : "file"
        nameFileLabel.font = fileStyle.fontName
        nameFileLabel.textColor = fileStyle.nameColor
        nameFileLabel.lineBreakMode = .byTruncatingMiddle
        if nameFileLabel.superview == nil {
            viewBubble.addSubview(nameFileLabel)
        }
        sizeFileLabel.text = message.file.sizeString
        sizeFileLabel.font = fileStyle.fontSize
        sizeFileLabel.textColor = fileStyle.sizeColor
        if sizeFileLabel.superview == nil {
            viewBubble.addSubview(sizeFileLabel)
        }
        if spinner.superview == nil {
            viewBubble.addSubview(spinner)
        }
        if message.file.path == "" {
            iconImage.alpha = 0
            spinner.startAnimating()
        } else {
            iconImage.image = fileStyle.imageIcon
            if iconImage.superview == nil {
                viewBubble.addSubview(iconImage)
            }
            if message.status == RC_STATUS_SUCCEED {
                iconImage.alpha = 1
                spinner.stopAnimating()
            }
        }
    }
    
    override func layoutSubviews() {
        let sizeFile: CGSize = size(indexPath, messagesView: messagesView)
        super.layoutSubviews(sizeFile)
        let fileStyle = configurationStyle.fileStyle
        iconImage.frame = CGRect(x: fileStyle.iconMargin.left, y: (sizeFile.height / 2) - (fileStyle.iconSize.height / 2), width: fileStyle.iconSize.width, height: fileStyle.iconSize.height)
        
        let heightNameFile = "Tept".size(attributes: [NSAttributedString.Key.font : fileStyle.fontName]).height
        nameFileLabel.frame = CGRect(x: iconImage.frame.origin.x + iconImage.frame.width + fileStyle.iconMargin.right, y: fileStyle.nameMargin.top, width: sizeFile.width - (iconImage.frame.origin.x + iconImage.frame.width + fileStyle.iconMargin.right + fileStyle.nameMargin.right), height: heightNameFile)
        
        let heightSizeFile = "Tept".size(attributes: [NSAttributedString.Key.font : fileStyle.fontSize]).height
        sizeFileLabel.frame = CGRect(x: nameFileLabel.frame.origin.x, y: fileStyle.nameMargin.top + nameFileLabel.frame.height + fileStyle.sizeMargin.top, width: sizeFile.width - (iconImage.frame.origin.x + iconImage.frame.width + fileStyle.iconMargin.right + fileStyle.sizeMargin.right), height: heightSizeFile)

        let widthSpinner = spinner.frame.size.width
        let heightSpinner = spinner.frame.size.height
        let xSpinner: CGFloat = iconImage.frame.origin.x + (iconImage.frame.width / 2) - (widthSpinner / 2)
        let ySpinner: CGFloat = iconImage.frame.origin.y + (iconImage.frame.height / 2) - (heightSpinner / 2)
        spinner.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
    }
    
    // MARK: - Size methods
    func height(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        var height = size.height
        if let message = messagesView?.getMessage(indexPath) {
            let heightSenderText = "Tept".size(availableWidth: size.width, attributes: [NSAttributedString.Key.font : configurationStyle.messageStyle.senderTextFont]).height
            height += message.incoming && isNeedShowSender ? configurationStyle.messageStyle.senderTextMarginBottom + heightSenderText : 0
        }
        return height
    }
    
    func size(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGSize {
        let messageOptional: UDMessage? = messagesView?.getMessage(indexPath)
        if let message = messageOptional {
            let fileStyle = configurationStyle.fileStyle
            let sizeText: CGSize = message.file.name.size(attributes: [NSAttributedString.Key.font : fileStyle.fontName])
            
            let maxwidth: CGFloat = SCREEN_WIDTH - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - 40
            var width = sizeText.width + fileStyle.iconMargin.left + fileStyle.iconSize.width + fileStyle.iconMargin.right + fileStyle.nameMargin.right
            width = width > maxwidth ? maxwidth : width
            
            let height = fileStyle.iconSize.height + fileStyle.iconMargin.top + fileStyle.iconMargin.bottom
            
            return CGSize(width: CGFloat(fmaxf(Float(width), Float(configurationStyle.bubbleStyle.bubbleWidthMin))), height: CGFloat(fmaxf(Float(height), Float(configurationStyle.bubbleStyle.bubbleHeightMin))))
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
