//
//  RCVideoMessageCell.swift

import Foundation

class RCVideoMessageCell: RCMessageCell {

    var viewImage: UIImageView?
    var imagePreview: UIImageView?
    var imagePlay: UIImageView?
    var imageManual: UIImageView?
    var spinner: UIActivityIndicatorView?
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    private var isDownloadVideo = false
    
    func setData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        isDownloadVideo = false
        
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.videoBubbleColorIncoming() : RCMessages.videoBubbleColorOutgoing()
        
        if viewImage == nil {
            viewImage = UIImageView()
            viewImage!.layer.masksToBounds = true
            viewImage!.layer.cornerRadius = RCMessages.bubbleRadius()
            viewBubble.addSubview(viewImage!)
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
            viewImage?.image = nil
            imagePreview?.isHidden = true
            spinner?.startAnimating()
            imageManual?.isHidden = true
        }
        
        if rcmessage?.status == RC_STATUS_SUCCEED {
            viewImage?.image = rcmessage?.video_thumbnail
            imagePreview?.isHidden = false
            spinner?.stopAnimating()
            imageManual?.isHidden = true
        }
        
        if rcmessage?.status == RC_STATUS_MANUAL {
            viewImage?.image = nil
            imagePreview?.isHidden = true
            spinner?.stopAnimating()
            imageManual?.isHidden = false
        }
    }
    
    func addVideo(previewImage: UIImage) {
        let image = previewImage.resizeImage(targetSize: CGSize(width: viewBubble.frame.width, height: viewBubble.frame.height))
        imagePreview?.removeFromSuperview()
        imagePreview = UIImageView(image: image)
        imagePreview?.layer.masksToBounds = true
        imagePreview?.layer.cornerRadius = RCMessages.bubbleRadius()
        imagePreview?.layoutIfNeeded()
        viewBubble.addSubview(imagePreview!)
        imagePlay?.removeFromSuperview()
        imagePlay = UIImageView(image: UIImage.named("videoPlay"))
        imagePlay?.alpha = 0
        viewBubble.addSubview(imagePlay!)
        isDownloadVideo = true
        self.layoutSubviews()
    }
    
    
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        if rcmessage != nil {
            let width = fminf(Float(RCMessages.videoBubbleWidth()), Float((rcmessage!.picture_width)))
            return CGSize(width: CGFloat(width), height: CGFloat(Float(rcmessage!.picture_height) * width / Float(rcmessage!.picture_width)))
        } else {
            return CGSize(width: 0, height: 0)
        }
        
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCVideoMessageCell.size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(size)
        
        viewImage?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if imagePreview?.image != nil {
            let widthPlay = imagePreview!.image!.size.width
            let heightPlay = imagePreview!.image!.size.height
            let xPlay: CGFloat = (size.width - widthPlay) / 2
            let yPlay: CGFloat = (size.height - heightPlay) / 2
            imagePreview!.frame = CGRect(x: xPlay, y: yPlay, width: widthPlay, height: heightPlay)
        }
        
        if spinner != nil {
            let widthSpinner = spinner!.frame.size.width
            let heightSpinner = spinner!.frame.size.height
            let xSpinner: CGFloat = (size.width - widthSpinner) / 2
            let ySpinner: CGFloat = (size.height - heightSpinner) / 2
            spinner!.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
        }
        
        if imageManual?.image != nil {
            let widthManual = imageManual!.image!.size.width
            let heightManual = imageManual!.image!.size.height
            let xManual: CGFloat = (size.width - widthManual) / 2
            let yManual: CGFloat = (size.height - heightManual) / 2
            imageManual!.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
        }
        
        if imagePlay?.image != nil {
            let widthManual = size.width / 4
            let heightManual = widthManual
            let xManual: CGFloat = (size.width - widthManual) / 2
            let yManual: CGFloat = (size.height - heightManual) / 2
            imagePlay!.frame = CGRect(x: xManual, y: yManual, width: widthManual, height: heightManual)
            imagePlay!.alpha = isDownloadVideo ? 1 : 0
            print("IMAGE PLAY ALPHA= ", imagePlay!.alpha)
        }
    }
}
