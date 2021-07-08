//
//  UDPictureMessageCellNode.swift
//
import UIKit
import Foundation
import AsyncDisplayKit 

class UDPictureMessageCellNode: UDMessageCellNode {
    private var imageNode = ASImageNode()
    private var loaderNode = ASDisplayNode()
    private var loaderBackNode = ASDisplayNode()
    private var activityIndicator = UIActivityIndicatorView()
    
    var messageTextParagraphStyle = NSMutableParagraphStyle()
    
    weak var usedesk: UseDeskSDK?
    
    override init() {
        super.init()
        imageNode.addTarget(self, action: #selector(self.actionTapBubble), forControlEvents: .touchUpInside)
    }
    
    override func bindData(messagesView messagesView_: UDMessagesView?, message : UDMessage, avatarImage: UIImage?) {
        messagesView = messagesView_
        self.message = messagesView?.getMessage(indexPath) ?? self.message
        let pictureStyle = configurationStyle.pictureStyle
        isPictureOrVideoType = true
        
        let widthLoaderView: CGFloat = 48
        loaderBackNode.removeFromSupernode()
        loaderBackNode = ASDisplayNode(viewBlock: { () -> UIView in
            let activityBackView = UIView()
            let backView = UIView()
            activityBackView.backgroundColor = .clear
            activityBackView.layer.masksToBounds = true
            activityBackView.layer.cornerRadius = widthLoaderView / 2
            backView.backgroundColor = UIColor(hexString: "454D63")
            backView.alpha = 0.4
            backView.frame = CGRect(x: 0, y: 0, width: widthLoaderView, height: widthLoaderView)
            activityBackView.addSubview(backView)
            return activityBackView
        })
        loaderBackNode.style.width = ASDimensionMakeWithPoints(widthLoaderView)
        loaderBackNode.style.height = ASDimensionMakeWithPoints(widthLoaderView)
        
        loaderNode.removeFromSupernode()
        loaderNode = ASDisplayNode(viewBlock: { [weak self] () -> UIView in
            guard let wSelf = self else {return UIView()}
            wSelf.activityIndicator = UIActivityIndicatorView(style: .white)
            wSelf.activityIndicator.hidesWhenStopped = false
            if message.status == RC_STATUS_OPENIMAGE {
                print("RC_STATUS_OPENIMAGE")
                wSelf.activityIndicator.startAnimating()
                wSelf.activityIndicator.alpha = 1
                wSelf.loaderBackNode.alpha = 1
            } else {
                if message.status == RC_STATUS_SUCCEED {
                    print("RC_STATUS_SUCCEED")
                    wSelf.activityIndicator.stopAnimating()
                    wSelf.activityIndicator.alpha = 0
                    wSelf.loaderBackNode.alpha = 0
                } else {
                    print("status = \(message.status)")
                    wSelf.activityIndicator.startAnimating()
                    wSelf.activityIndicator.alpha = 1
                    wSelf.loaderBackNode.alpha = 1
                }
            }
            return wSelf.activityIndicator
        })
        print("message.file.picture = \(message.file.picture != nil ? "есть" : "nil")")
        imageNode.image = message.file.picture != nil ? message.file.picture : pictureStyle.imageDefault
        imageNode.contentMode = .scaleAspectFit
        imageNode.cornerRadius = pictureStyle.cornerRadius
        
        if imageNode.supernode == nil {
            addSubnode(imageNode)
            addSubnode(loaderBackNode)
            addSubnode(loaderNode)
        }
        
        super.bindData(messagesView: messagesView, message: message, avatarImage: avatarImage)
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let messageStyle = configurationStyle.messageStyle
        let pictureStyle = configurationStyle.pictureStyle
        
        let loaderBackOverlaySpec = ASOverlayLayoutSpec()
        let centerLoaderSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: loaderNode)
        loaderBackOverlaySpec.overlay = centerLoaderSpec
        loaderBackOverlaySpec.child = loaderBackNode
        
        let sizeMessagesManager = UDSizeMessagesManager(messagesView: messagesView, message: message, indexPath: indexPath, configurationStyle: configurationStyle)
        let sizeImageNode = sizeMessagesManager.sizeImageMessageFrom(size: CGSize(width: message.file.picture?.size.width ?? 0, height: message.file.picture?.size.height ?? 0))
        imageNode.style.width = ASDimensionMakeWithPoints(sizeImageNode.width)
        imageNode.style.height = ASDimensionMakeWithPoints(sizeImageNode.height)
        
        let imageWithLoaderStack = ASOverlayLayoutSpec()
        let centerLoaderBackSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: loaderBackOverlaySpec)
        imageWithLoaderStack.overlay = centerLoaderBackSpec
        imageWithLoaderStack.child = imageNode

        var timeEndSendedLayoutElements: [ASLayoutElement] = [timeNode]
        if message.outgoing {
            timeEndSendedLayoutElements.append(sendedImageNode)
        }
        let horizonTimeAndSendedSpec = ASStackLayoutSpec(direction: .horizontal, spacing: message.outgoing ? messageStyle.sendedStatusMargin.left : messageStyle.timeMargin.right, justifyContent: .start, alignItems: ASStackLayoutAlignItems.start, children: timeEndSendedLayoutElements)
        let timeBackSpec = ASBackgroundLayoutSpec()
        timeBackSpec.background = timeBackNode
        timeBackSpec.child = ASInsetLayoutSpec(insets: UIEdgeInsets(top: messageStyle.timeBackViewPadding.top, left: messageStyle.timeBackViewPadding.left, bottom: messageStyle.timeBackViewPadding.bottom, right: messageStyle.timeBackViewPadding.right), child: horizonTimeAndSendedSpec)
        
        let timeFromImageOverlaySpec = ASOverlayLayoutSpec()
        let timeCenterSpec = ASCenterLayoutSpec(horizontalPosition: .end, verticalPosition: .end, sizingOption: .minimumWidth, child: timeBackSpec)
        timeFromImageOverlaySpec.overlay = timeCenterSpec
        timeFromImageOverlaySpec.child = imageWithLoaderStack
        
        let vMessageStack = ASStackLayoutSpec()
        vMessageStack.direction = .vertical
        vMessageStack.spacing = 0
        vMessageStack.alignItems = .end
        vMessageStack.setChild(timeFromImageOverlaySpec, at: 0)
        
        contentMessageInsetSpec = ASInsetLayoutSpec(insets: pictureStyle.margin, child: timeFromImageOverlaySpec)
        let messageLayoutSpec = super.layoutSpecThatFits(constrainedSize)
        return messageLayoutSpec
    }
    
    // MARK: - User actions
    @objc func actionTapBubble() {
        messagesView?.view.endEditing(true)
        messagesView?.actionTapBubble(indexPath)
    }
}
