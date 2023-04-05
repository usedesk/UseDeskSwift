//
//  UDMarkdownParser.swift
//  UseDesk_SDK_Swift

import MarkdownKit

class UDMarkdownParser {
    
    class func mutableAttributedString(for text: String, font: UIFont, color: UIColor, linkColor: UIColor? = nil) -> NSMutableAttributedString {
        let markdownParser = MarkdownParser(font: font, color: color)
        if linkColor != nil {
            markdownParser.link.color = linkColor!
        }
        var convertedText = text.replacingOccurrences(of: "-", with: "\\-") 
        var parsedAttributedString = markdownParser.parse(convertedText)
        return NSMutableAttributedString(attributedString: parsedAttributedString)
    }
    
}
