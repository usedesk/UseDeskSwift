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
    public var udIsContainEmoji: Bool
    {
        for ucode in unicodeScalars
        {
            switch ucode.value
            {
            case 0x3030, 0x00AE, 0x00A9,
            0x1D000...0x1F77F,
            0x2100...0x27BF,
            0xFE00...0xFE0F,
            0x1F900...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }

    func size(availableWidth: CGFloat? = nil, attributes: [NSAttributedString.Key : Any]? = nil, usesFontLeading: Bool = true) -> CGSize {
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
        
        let size = CGSize(width: sizeWithAttributedString.width.rounded(.up),
                          height: sizeWithAttributedString.height.rounded(.up))
        
        return size
    }
    
    func udIsValidEmail() -> Bool {
        return udEmailPredicate.evaluate(with: self)
    }
    
    func udIsValidToken() -> Bool {
        if self.udIsContainEmoji || self.contains(" ") || self.count < 64 {
            return false
        }
        return true
    }
    
    func udGetLinksRange() -> [Range<String.Index>] {
        var links: [Range<String.Index>] = []
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))

        for match in matches {
            if let range = Range(match.range, in: self) {
                links.append(range/*.nsRange(in: self)*/)
            }
        }
        return links
    }
    
    mutating func udRemoveMarkdownUrlsAndReturnLinks() -> [String] {
        var links: [String] = []
        var count = 0
        var flag = true
        while count < 900 && flag {
            if let range = self.range(of: "![") {
                let startIndex = range.lowerBound
                var isFindEnd = false
                var index = 0
                while !isFindEnd {
                    if let searchStartIndex = self.index(startIndex, offsetBy: index, limitedBy: self.endIndex) {
                        if let searchEndIndex = self.index(searchStartIndex, offsetBy: 1, limitedBy: self.endIndex) {
                            if self[searchStartIndex...searchEndIndex] == "](" {
                                var indexSearchEndLink = 0
                                while !isFindEnd {
                                    if let searchIndex = self.index(searchEndIndex, offsetBy: indexSearchEndLink, limitedBy: self.endIndex) {
                                        if self[searchIndex] == ")" {
                                            // add link
                                            if let startLinkIndex = self.index(searchEndIndex, offsetBy: +1, limitedBy: self.endIndex) {
                                                if let endLinkIndex = self.index(searchIndex, offsetBy: -1, limitedBy: self.startIndex) {
                                                    links.append(String(self[startLinkIndex...endLinkIndex]))
                                                }
                                            }
                                            //remove link
                                            isFindEnd = true
                                            self = self.replacingOccurrences(of: self[startIndex...searchIndex], with: "")
                                            if let enterIndex = self.index(startIndex, offsetBy: -1, limitedBy: self.startIndex) {
                                                if self[enterIndex] == "\n" {
                                                    self.remove(at: enterIndex)
                                                }
                                            }
                                        }
                                    } else {
                                        isFindEnd = true
                                    }
                                    indexSearchEndLink += 1
                                }
                            }
                        } else {
                            isFindEnd = true
                        }
                    } else {
                        isFindEnd = true
                    }
                    index += 1
                }
            } else {
                flag = false
            }
            count += 1
        }
        return links
    }

    private func singleLineHeight(attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let attributedString = NSAttributedString(string: "0", attributes: attributes)
        
        return attributedString.size().height
    }
}

extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}
