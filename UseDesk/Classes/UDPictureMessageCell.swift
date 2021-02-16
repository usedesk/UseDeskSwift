//
//  UDPictureMessageCell.swift

import Foundation

class UDPictureMessageCell: UDMessageCell {

    let pictureImage = UIImageView()
    let imageDefault = UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let timeBackView = UIView()
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        guard let message: UDMessage = messagesView!.getMessage(indexPath) else { return }
        if message.status == RC_STATUS_OPENIMAGE {
            spinner.startAnimating()
        } else {
            super.bindData(indexPath, messagesView: messagesView)
            imageDefault.image = configurationStyle.pictureStyle.imageDefault
            if imageDefault.superview == nil {
                viewBubble.addSubview(imageDefault)
            }
            imageDefault.alpha = 1
            
            pictureImage.layer.masksToBounds = true
            pictureImage.layer.cornerRadius = configurationStyle.bubbleStyle.bubbleRadius
            if pictureImage.superview == nil {
                viewBubble.addSubview(pictureImage)
            }
            if spinner.superview == nil {
                viewBubble.addSubview(spinner)
            }
            
            timeLabel.textColor = message.incoming ? configurationStyle.messageStyle.timeIncomingPictureColor : configurationStyle.messageStyle.timeOutgoingPictureColor
            timeBackView.backgroundColor = message.incoming ? configurationStyle.messageStyle.timeBackViewIncomingColor : configurationStyle.messageStyle.timeBackViewOutgoingColor
            timeBackView.layer.masksToBounds = true
            timeBackView.layer.cornerRadius = configurationStyle.messageStyle.timeBackViewCornerRadius
            timeBackView.alpha = configurationStyle.messageStyle.timeBackViewOpacity
            if timeBackView.superview == nil {
                viewBubble.addSubview(timeBackView)
                timeLabel.removeFromSuperview()
                viewBubble.addSubview(timeLabel)
            }
            
            if message.file.picture == nil {
                pictureImage.image = nil
                pictureImage.alpha = 0
                spinner.startAnimating()
                imageDefault.alpha = 1
            }
            
            if message.status == RC_STATUS_SUCCEED {
                pictureImage.image = message.file.picture
                pictureImage.alpha = 1
                spinner.stopAnimating()
            }
        }
    }
    
    override func layoutSubviews() {
        let sizePicture: CGSize = size(indexPath, messagesView: messagesView)
        super.layoutSubviews(sizePicture)
        let pictureStyle = configurationStyle.pictureStyle
        pictureImage.frame = CGRect(x: pictureStyle.margin.left, y: pictureStyle.margin.top, width: sizePicture.width - pictureStyle.margin.left - pictureStyle.margin.right, height: sizePicture.height - pictureStyle.margin.top - pictureStyle.margin.bottom)

        let widthSpinner = spinner.frame.size.width
        let heightSpinner = spinner.frame.size.height
        let xSpinner: CGFloat = (sizePicture.width - widthSpinner) / 2
        let ySpinner: CGFloat = (sizePicture.height - heightSpinner) / 2
        spinner.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)

        imageDefault.frame = CGRect(x: pictureStyle.margin.left, y: pictureStyle.margin.top, width: sizePicture.width - pictureStyle.margin.left - pictureStyle.margin.right, height: sizePicture.height - pictureStyle.margin.top - pictureStyle.margin.bottom)
        
        let messageStyle = configurationStyle.messageStyle
        let widthTimeBackView = timeLabel.frame.size.width + messageStyle.timeBackViewPadding.left + messageStyle.timeBackViewPadding.right
        let heightTimeBackView = timeLabel.frame.size.height + messageStyle.timeBackViewPadding.top + messageStyle.timeBackViewPadding.bottom
        let xTimeBackView: CGFloat = timeLabel.frame.origin.x - messageStyle.timeBackViewPadding.left
        let yTimeBackView: CGFloat = timeLabel.frame.origin.y - messageStyle.timeBackViewPadding.top
        timeBackView.frame = CGRect(x: xTimeBackView, y: yTimeBackView, width: widthTimeBackView, height: heightTimeBackView)
    }
    
    // MARK: - Size methods
    func height(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    func size(_ indexPath: IndexPath?, messagesView: UDMessagesView?) -> CGSize {
        let messageOptional: UDMessage? = messagesView?.getMessage(indexPath)
        if let message = messageOptional {
            var heightPicture = message.file.picture?.size.height ?? 0
            var widthPicture = message.file.picture?.size.width ?? 0
            if heightPicture > 0 && widthPicture > 0 {
                let maxWidth = MAX_WIDTH_MESSAGE - configurationStyle.avatarStyle.margin.left - configurationStyle.avatarStyle.margin.right - configurationStyle.avatarStyle.avatarDiameter - 50
                if widthPicture > maxWidth {
                    while widthPicture > maxWidth {
                        widthPicture = widthPicture * 0.95
                        if heightPicture > configurationStyle.bubbleStyle.bubbleHeightMin {
                            heightPicture = heightPicture * 0.95
                        }
                    }
                } else if widthPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                    while widthPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                        widthPicture = widthPicture * 1.05
                        if heightPicture < configurationStyle.bubbleStyle.bubbleWidthMin {
                            heightPicture = heightPicture * 1.05
                        }
                    }
                }
                return CGSize(width: widthPicture, height: heightPicture)
            } else {
                return CGSize(width: configurationStyle.pictureStyle.sizeDefault.width, height: configurationStyle.pictureStyle.sizeDefault.height)
            }
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
