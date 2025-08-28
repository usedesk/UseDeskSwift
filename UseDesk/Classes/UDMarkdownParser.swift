//
//  UDMarkdownParser.swift
//  UseDesk_SDK_Swift

import MarkdownKit

class UDMarkdownParser {
    
    class func mutableAttributedString(
        for text: String,
        font: UIFont,
        color: UIColor,
        linkColor: UIColor? = nil
    ) -> NSMutableAttributedString {
        let markdownParser = MarkdownParser(font: font, color: color)
        if let linkColor {
            markdownParser.link.color = linkColor
        }

        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let linkRanges = detector?.matches(in: text, options: [], range: fullRange).map { $0.range } ?? []
        let pattern = #"(?m)^( *)(-)(?=\s)"#
        let regex = try? NSRegularExpression(pattern: pattern)

        var convertedText = text
        if let regex {
            var out = convertedText
            let matches = regex.matches(in: convertedText, range: NSRange(convertedText.startIndex..., in: convertedText)).reversed()
            for m in matches {
                let dashRange = m.range(at: 2)
                let intersectsLink = linkRanges.contains { NSIntersectionRange($0, dashRange).length > 0 }
                if !intersectsLink, let r = Range(dashRange, in: out) {
                    out.replaceSubrange(r, with: "\\-")
                }
            }
            convertedText = out
        }

        let parsed = markdownParser.parse(convertedText)
        return NSMutableAttributedString(attributedString: parsed)
    }
    
}
