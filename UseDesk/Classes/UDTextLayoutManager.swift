//
//  UDTextLayoutManager.swift
//  UseDesk_SDK_Swift

import UIKit

struct UDTextLayout {
    let attributed: NSAttributedString
    let contentWidth: CGFloat
    let height: CGFloat
    let textHeight: CGFloat
}

enum UDTextLayoutManager {
    static func makeLayout(for message: UDMessage, style: ConfigurationStyle, screenWidth: CGFloat) -> UDTextLayout {
        let messageStyle = style.messageStyle
        let textColor = message.outgoing ? messageStyle.textOutgoingColor : messageStyle.textIncomingColor
        let linkColor = message.outgoing ? messageStyle.linkOutgoingColor : messageStyle.linkIncomingColor
        let font = messageStyle.font

        let textMargin = messageStyle.textMargin
        let maxWidth = UDSizeMessagesManager.maxBubbleWidth(message: message, style: style, screenWidth: screenWidth)
            - textMargin.left - textMargin.right

        let timeWidth = UDSizeMessagesManager.timeStatusWidth(message: message, style: style)

        let reserve = timeWidth + (messageStyle.timeMargin.right - textMargin.right)

        let attributed = UDMarkdownParser.mutableAttributedString(
            for: message.text,
            font: font,
            color: textColor,
            linkColor: linkColor
        )

        let measureResult = measure(attributed: attributed, maxWidth: maxWidth, fallbackLineHeight: font.lineHeight)

        let neededLastLine = measureResult.lastLineWidth + reserve
        var contentWidth: CGFloat
        var height = measureResult.totalHeight
        if neededLastLine <= maxWidth {
            contentWidth = max(measureResult.maxLineWidth, neededLastLine)
        } else {
            contentWidth = max(measureResult.maxLineWidth, reserve)
            height = measureResult.totalHeight + measureResult.lineHeight
        }
        contentWidth = min(contentWidth, maxWidth)

        return UDTextLayout(
            attributed: attributed,
            contentWidth: contentWidth,
            height: height,
            textHeight: measureResult.totalHeight
        )
    }

    private static func measure(attributed: NSAttributedString, maxWidth: CGFloat, fallbackLineHeight: CGFloat)
        -> (maxLineWidth: CGFloat, lastLineWidth: CGFloat, lineHeight: CGFloat, totalHeight: CGFloat) {
        let textStorage = NSTextStorage(attributedString: attributed)
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        container.lineBreakMode = .byWordWrapping
        container.maximumNumberOfLines = 0
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.ensureLayout(for: container)

        var maxLineWidth: CGFloat = 0
        var lastLineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        let glyphRange = layoutManager.glyphRange(for: container)
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { rect, usedRect, _, _, _ in
            maxLineWidth = max(maxLineWidth, ceil(usedRect.width))
            lastLineWidth = ceil(usedRect.width)
            lineHeight = ceil(rect.height)
            totalHeight = max(totalHeight, ceil(rect.maxY))
        }

        if lineHeight == 0 { lineHeight = ceil(fallbackLineHeight) }
        if totalHeight == 0 { totalHeight = lineHeight }
        maxLineWidth = min(maxLineWidth, maxWidth)
        lastLineWidth = min(lastLineWidth, maxWidth)

        return (maxLineWidth, lastLineWidth, lineHeight, totalHeight)
    }
}
