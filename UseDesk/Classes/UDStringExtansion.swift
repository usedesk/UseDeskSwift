//
//  UDStringExtansion.swift
//  UseDesk_SDK_Swift
//
import UIKit
let udEmailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
    "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
    "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
    "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
    "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
    "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
let udEmailPredicate = NSPredicate(format: "SELF MATCHES %@", udEmailRegex)

extension String {

    func size(availableWidth: CGFloat? = nil, attributes: [NSAttributedString.Key : Any]? = nil, usesFontLeading: Bool = false) -> CGSize {
        var attributes = attributes
        let systemFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let font: UIFont = (attributes?[.font] as? UIFont) ?? systemFont
        
        if (attributes == nil) {
            attributes = [.font : font]
        }
        
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let singleSymbolHeight = self.singleLineHeight(attributes: attributes!)
        let availableSize = CGSize(width: availableWidth ?? .greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        
        var sizeWithAttributedString: CGSize
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin]
        let drawingRect = attributedString.boundingRect(with: availableSize, options: options, context: nil)
        sizeWithAttributedString = drawingRect.size
        
        if (!usesFontLeading) {
            return sizeWithAttributedString
        }
        
        // Leading causes incorrect calculation for text layer
        if (usesFontLeading) {
            let linesCount = ceil(sizeWithAttributedString.height / singleSymbolHeight)
            let totalHeight = ceil(sizeWithAttributedString.height + abs(font.leading) * linesCount)
            sizeWithAttributedString.height = totalHeight
        }
        
        // Emojis corner case
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        let frameSetterSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: 0), nil, availableSize, nil)
        
        let size = CGSize(width: max(sizeWithAttributedString.width, frameSetterSize.width),
                          height: max(sizeWithAttributedString.height, frameSetterSize.height))
        
        return size
    }
    
    func isValidEmail() -> Bool {
        return udEmailPredicate.evaluate(with: self)
    }

    private func singleLineHeight(attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let attributedString = NSAttributedString(string: "0", attributes: attributes)
        
        return attributedString.size().height
    }
}
