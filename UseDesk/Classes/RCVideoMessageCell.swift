//
//  RCVideoMessageCell.swift

import Foundation

class RCVideoMessageCell: RCMessageCell {

    var viewImage: UIImageView?
    var imagePlay: UIImageView?
    var imageManual: UIImageView?
    var spinner: UIActivityIndicatorView?
    
    private var indexPath: IndexPath?
    private var messagesView: RCMessagesView?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        
        let rcmessage: RCMessage? = messagesView!.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.videoBubbleColorIncoming() : RCMessages.videoBubbleColorOutgoing()
        
        if viewImage == nil {
            viewImage = UIImageView()
            viewImage!.layer.masksToBounds = true
            viewImage!.layer.cornerRadius = RCMessages.bubbleRadius()
            viewBubble.addSubview(viewImage!)
        }
        
        if imagePlay == nil {
            imagePlay = UIImageView(image: RCMessages.videoImagePlay())
            viewBubble.addSubview(imagePlay!)
        }
        
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
            viewBubble.addSubview(spinner!)
        }
        
        if imageManual == nil {
            imageManual = UIImageView(image: RCMessages.videoImageManual())
            viewBubble.addSubview(imageManual!)
        }
        
        if rcmessage?.status == RC_STATUS_LOADING {
            viewImage!.image = nil
            imagePlay!.isHidden = true
            spinner!.startAnimating()
            imageManual!.isHidden = true
        }
        
        if rcmessage?.status == RC_STATUS_SUCCEED {
            viewImage!.image = rcmessage?.video_thumbnail
            imagePlay!.isHidden = false
            spinner!.stopAnimating()
            imageManual!.isHidden = true
        }
        
        if rcmessage?.status == RC_STATUS_MANUAL {
            viewImage!.image = nil
            imagePlay!.isHidden = true
            spinner!.stopAnimating()
            imageManual!.isHidden = false
        }
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        return CGSize(width: RCMessages.videoBubbleWidth(), height: RCMessages.videoBubbleHeight())
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCVideoMessageCell.size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(size)
        
        viewImage!.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let widthPlay = imagePlay!.image!.size.width
        let heightPlay = imagePlay!.image!.size.height
        let xPlay: CGFloat = (size.width - widthPlay) / 2
        let yPlay: CGFloat = (size.height - heightPlay) / 2
        imagePlay!.frame = CGRect(x: xPlay, y: yPlay, width: widthPlay, height: heightPlay)
        
        let widthSpinner = spinner!.frame.size.width
        let heightSpinner = spinner!.frame.size.height
        let xSpinner: CGFloat = (size.width - widthSpinner) / 2
        let ySpinner: CGFloat = (size.height - heightSpinner) / 2
        spinner!.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
        
        let widthManual = imageManual!.image!.size.width
        let heightManual = imageManual!.image!.size.height
        let xManual: CGFloat = (size.width - widthManual) / 2
        let yManual: CGFloat = (size.height - heightManual) / 2
        imageManual!.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
    }
}
