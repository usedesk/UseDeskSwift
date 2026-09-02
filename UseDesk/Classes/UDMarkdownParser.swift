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
            var workingText = convertedText
            let matches = regex.matches(in: convertedText, range: NSRange(convertedText.startIndex..., in: convertedText)).reversed()
            for match in matches {
                let dashRange = match.range(at: 2)
                let intersectsLink = linkRanges.contains { NSIntersectionRange($0, dashRange).length > 0 }
                if !intersectsLink, let dashStringRange = Range(dashRange, in: workingText) {
                    workingText.replaceSubrange(dashStringRange, with: "\\-")
                }
            }
            convertedText = workingText
        }

        let parsed = markdownParser.parse(convertedText)
        return NSMutableAttributedString(attributedString: parsed)
    }
    
}
