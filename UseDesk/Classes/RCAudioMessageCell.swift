//
//  RCAudioMessageCell.swift

import Foundation

class RCAudioMessageCell: RCMessageCell {

    var imageStatus: UIImageView!
    var labelDuration: UILabel!
    var imageManual: UIImageView!
    var spinner: UIActivityIndicatorView!

    private var indexPath: IndexPath!
    private var messagesView: RCMessagesView!
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        let rcmessage: RCMessage? = messagesView!.rcmessage(indexPath)
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.audioBubbleColorIncoming() : RCMessages.audioBubbleColorOutgoing()
        if imageStatus == nil {
            imageStatus = UIImageView()
            viewBubble.addSubview(imageStatus)
        }
        if labelDuration == nil {
            labelDuration = UILabel()
            labelDuration.font = RCMessages.audioFont()
            labelDuration.textAlignment = .right
            viewBubble.addSubview(labelDuration)
        }
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
            viewBubble.addSubview(spinner)
        }
        if imageManual == nil {
            imageManual = UIImageView(image: RCMessages.audioImageManual())
            viewBubble.addSubview(imageManual)
        }
        if rcmessage?.audio_status == RC_AUDIOSTATUS_STOPPED {
            imageStatus.image = RCMessages.audioImagePlay()
        }
        if rcmessage?.audio_status == RC_AUDIOSTATUS_PLAYING {
            imageStatus.image = RCMessages.audioImagePause()
        }
        labelDuration.textColor = rcmessage?.incoming != false ? RCMessages.audioTextColorIncoming() : RCMessages.audioTextColorOutgoing()
        if rcmessage?.audio_duration ?? 0 < 60 {
            labelDuration.text = String(format: "0:%02ld", Int(rcmessage?.audio_duration ?? 0))
        } else {
            labelDuration.text = String(format: "%ld:%02ld", Int(rcmessage?.audio_duration ?? 0) / 60, Int(rcmessage?.audio_duration ?? 0) % 60)
        }
        
        if rcmessage?.status == RC_STATUS_LOADING {
            imageStatus?.isHidden = true
            labelDuration.isHidden = true
            spinner.startAnimating()
            imageManual.isHidden = true
        }
        if rcmessage?.status == RC_STATUS_SUCCEED {
            imageStatus.isHidden = false
            labelDuration.isHidden = false
            spinner.stopAnimating()
            imageManual.isHidden = true
        }
        if rcmessage?.status == RC_STATUS_MANUAL {
            imageStatus.isHidden = true
            labelDuration.isHidden = true
            spinner.stopAnimating()
            imageManual.isHidden = false
        }
    }
    
    override func layoutSubviews() {
        let size: CGSize = RCAudioMessageCell.size(indexPath, messagesView: messagesView)
        
        super.layoutSubviews(size)
        
        let widthStatus = imageStatus.image?.size.width
        let heightStatus = imageStatus.image?.size.height
        let yStatus: CGFloat = (size.height - heightStatus!) / 2
        imageStatus.frame = CGRect(x: 10, y: yStatus, width: widthStatus!, height: heightStatus!)
        
        labelDuration.frame = CGRect(x: size.width - 100, y: 0, width: 90, height: size.height)
        
        let widthSpinner = spinner.frame.size.width
        let heightSpinner = spinner.frame.size.height
        let xSpinner: CGFloat = (size.width - widthSpinner) / 2
        let ySpinner: CGFloat = (size.height - heightSpinner) / 2
        spinner.frame = CGRect(x: xSpinner, y: ySpinner, width: widthSpinner, height: heightSpinner)
        let widthManual = imageManual.image?.size.width
        let heightManual = imageManual.image?.size.height
        let xManual: CGFloat = (size.width - widthManual!) / 2
        let yManual: CGFloat = (size.height - heightManual!) / 2
        imageManual.frame = CGRect(x: xManual, y: yManual, width: widthManual!, height: heightManual!)
    }
    
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        return CGSize(width: RCMessages.audioBubbleWidht(), height: RCMessages.audioBubbleHeight())
    }
}
