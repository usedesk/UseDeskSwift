//
//  RCTextMessageCell.swift

import Foundation

class RCTextMessageCell: RCMessageCell, UICollectionViewDelegate, UICollectionViewDataSource {
    

    var textView: UITextView?
    var collectionView: UICollectionView? = nil
    
    private var indexPath: IndexPath?
    private weak var messagesView: RCMessagesView?
    private weak var rcmessage: RCMessage?
    
    override func bindData(_ indexPath_: IndexPath?, messagesView messagesView_: RCMessagesView?) {
        indexPath = indexPath_
        messagesView = messagesView_
        rcmessage = messagesView?.rcmessage(indexPath)
        
        super.bindData(indexPath, messagesView: messagesView)
        
        viewBubble.backgroundColor = rcmessage?.incoming != false ? RCMessages.textBubbleColorIncoming() : RCMessages.textBubbleColorOutgoing()
        
        if textView == nil {
            textView = UITextView()
            textView!.font = RCMessages.textFont()
            textView!.isEditable = false
            textView!.isSelectable = false
            textView!.isScrollEnabled = false
            textView!.isUserInteractionEnabled = false
            textView!.backgroundColor = UIColor.clear
            textView!.textContainer.lineFragmentPadding = 0
            textView!.textContainerInset = RCMessages.textInset()
            viewBubble?.addSubview(textView!)
        }
        
        textView?.textColor = rcmessage?.incoming != false ? RCMessages.textTextColorIncoming() : RCMessages.textTextColorOutgoing()
        
        textView?.text = rcmessage?.text

        var size = CGSize(width: 100, height: 0)
        if rcmessage != nil {
            if rcmessage!.rcButtons.count > 0 {
                for _ in rcmessage!.rcButtons {
                    size = CGSize(width: size.width, height: size.height + 30)
                }
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSize(width: size.width, height: 30)
                collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
                collectionView!.dataSource = self
                collectionView!.delegate = self
                collectionView!.register(RCMessageButtonCell.self, forCellWithReuseIdentifier: "RCMessageButtonCell")
                collectionView!.backgroundColor = UIColor.clear
                viewBubble!.addSubview(collectionView!)
                collectionView!.reloadData()
            }
        }
    }
    
    override func layoutSubviews() {
        let textSize: CGSize = RCTextMessageCell.size(indexPath, messagesView: messagesView)
        var size = textSize
        if rcmessage != nil {
            if rcmessage!.rcButtons.count > 0 {
                for _ in rcmessage!.rcButtons {
                    size = CGSize(width: size.width, height: size.height + 40)
                }
                size = CGSize(width: size.width, height: size.height + 2)
                super.layoutSubviews(size)
                collectionView?.frame = CGRect(x: 0, y: textSize.height, width: size.width, height: size.height - textSize.height - 10)
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSize(width: size.width, height: 30)
                collectionView?.collectionViewLayout = layout
            } else {
                super.layoutSubviews(size)
            }
        }
        textView?.frame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView?.removeFromSuperview()
    }
    
    // MARK: - Size methods
    class func height(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGFloat {
        let size: CGSize = self.size(indexPath, messagesView: messagesView)
        return size.height
    }
    
    class func size(_ indexPath: IndexPath?, messagesView: RCMessagesView?) -> CGSize {
        let rcmessage: RCMessage? = messagesView?.rcmessage(indexPath)
        
        let maxwidth: CGFloat = (0.6 * SCREEN_WIDTH) - RCMessages.textInsetLeft() - RCMessages.textInsetRight()
        
        let rect: CGRect? = rcmessage?.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [
            NSAttributedString.Key.font: RCMessages.textFont() as Any
            ], context: nil)
        
        let width: CGFloat = (rect?.size.width ?? 0.0) + RCMessages.textInsetLeft() + RCMessages.textInsetRight()
        let height: CGFloat = (rect?.size.height ?? 0.0) + RCMessages.textInsetTop() + RCMessages.textInsetBottom()
        
        return CGSize(width: CGFloat(fmaxf(Float(width), Float(RCMessages.textBubbleWidthMin()))), height: CGFloat(fmaxf(Float(height), Float(RCMessages.textBubbleHeightMin()))))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rcmessage?.rcButtons.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RCMessageButtonCell", for: indexPath) as! RCMessageButtonCell
        cell.setingCell(titleButton: rcmessage?.rcButtons[indexPath.row].title ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if rcmessage?.rcButtons[indexPath.row].url != "" {
            let urlDataDict:[String: String] = ["url": rcmessage!.rcButtons[indexPath.row].url]
            NotificationCenter.default.post(name: Notification.Name("messageButtonURLOpen"), object: nil, userInfo: urlDataDict)
        } else {
            let textDataDict:[String: String] = ["text": rcmessage?.rcButtons[indexPath.row].title ?? ""]
            NotificationCenter.default.post(name: Notification.Name("messageButtonSend"), object: nil, userInfo: textDataDict)
        }
    }
}

