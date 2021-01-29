//
//  UDVideoMessageCell.swift

import Foundation

protocol UDVideoMessageCellDelegate: class {
    func updateCell(indexPath: IndexPath)
}

class UDVideoMessageCell: UDMessageCell {

    var videoImage = UIImageView()
    var imagePlay = UIImageView()
    var imageDefault = UIImageView()
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let timeBackView = UIView()
    
    weak var delegate: UDVideoMessageCellDelegate?
    
    private var indexPath: IndexPath?
    private weak var messagesView: UDMessagesView?
    
    func setData(_ indexPath_: IndexPath?, messagesView messagesView_: UDMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        imageDefault.image = configurationStyle.videoStyle.imageDefault
        viewBubble.addSubview(imageDefault)
        
        videoImage.layer.masksToBounds = true
        videoImage.layer.cornerRadius = configurationStyle.bubbleStyle.bubbleRadius
        viewBubble.addSubview(videoImage)
        
        viewBubble.addSubview(spinner)
                
        imagePlay.image = UIImage.named("videoPlay")
        imagePlay.alpha = 0
        viewBubble.addSubview(imagePlay)
        
        timeLabel.textColor = message!.incoming ? configurationStyle.messageStyle.timeIncomingPictureColor : configurationStyle.messageStyle.timeOutgoingPictureColor
        timeBackView.backgroundColor = message!.incoming ? configurationStyle.messageStyle.timeBackViewIncomingColor : configurationStyle.messageStyle.timeBackViewOutgoingColor
        timeBackView.layer.masksToBounds = true
        timeBackView.layer.cornerRadius = configurationStyle.messageStyle.timeBackViewCornerRadius
        timeBackView.alpha = configurationStyle.messageStyle.timeBackViewOpacity
        if timeBackView.superview == nil {
            viewBubble.addSubview(timeBackView)
            timeLabel.removeFromSuperview()
            viewBubble.addSubview(timeLabel)
        }
        
        if message?.status == RC_STATUS_LOADING {
            videoImage.alpha = 0
            spinner.startAnimating()
        }
        
        if message?.status == RC_STATUS_SUCCEED {
            spinner.stopAnimating()
            videoImage.alpha = 1
        }
    }
    
    func addVideo(previewImage: UIImage) {
        videoImage.image = previewImage//UIImageView(image: previewImage)
        videoImage.alpha = 1
        imagePlay.alpha = 1
        self.layoutSubviews()
        if indexPath != nil {
            delegate?.updateCell(indexPath: indexPath!)
        }
    }
    
    // MARK: - Size methods
    override func layoutSubviews() {
        let sizeVideo: CGSize = size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(sizeVideo)
        let videoStyle = configurationStyle.videoStyle
        
        videoImage.frame = CGRect(x: videoStyle.margin.left, y: videoStyle.margin.top, width: sizeVideo.width - videoStyle.margin.left - videoStyle.margin.right, height: sizeVideo.height - videoStyle.margin.top - videoStyle.margin.bottom)
        let widthSpinner = spinner.frame.size.width
        let heightSpinner = spinner.frame.size.height
        let xSpinner: CGFloat = (sizeVideo.width - widthSpinner) / 2
        let ySpinner: CGFloat = (sizeVideo.height - heightSpinner) / 2
        spinner.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
        
        let xImagePlay: CGFloat = (sizeVideo.width - 48) / 2
        let yImagePlay: CGFloat = (sizeVideo.height - 48) / 2
        imagePlay.frame = CGRect(x: xImagePlay, y: yImagePlay, width: 48, height: 48)

        imageDefault.frame = CGRect(x: videoStyle.margin.left, y: videoStyle.margin.top, width: sizeVideo.width - videoStyle.margin.left - videoStyle.margin.right, height: sizeVideo.height - videoStyle.margin.top - videoStyle.margin.bottom)
        
        let messageStyle = configurationStyle.messageStyle
        let widthTimeBackView = timeLabel.frame.size.width + messageStyle.timeBackViewPadding.left + messageStyle.timeBackViewPadding.right
        let heightTimeBackView = timeLabel.frame.size.height + messageStyle.timeBackViewPadding.top + messageStyle.timeBackViewPadding.bottom
        let xTimeBackView: CGFloat = timeLabel.frame.origin.x - messageStyle.timeBackViewPadding.left
        let yTimeBackView: CGFloat = timeLabel.frame.origin.y - messageStyle.timeBackViewPadding.top
        timeBackView.frame = CGRect(x: xTimeBackView, y: yTimeBackView, width: widthTimeBackView, height: heightTimeBackView)
    }
    
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
        let message: UDMessage? = messagesView?.getMessage(indexPath)
        if message != nil {
            let sizeVideo = sizeVideoMessage(message: message!)
            return CGSize(width: sizeVideo.width, height: sizeVideo.height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func sizeVideoMessage(message: UDMessage) -> CGSize {
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
            return CGSize(width: configurationStyle.videoStyle.sizeDefault.width, height: configurationStyle.videoStyle.sizeDefault.height)
        }
    }
}
