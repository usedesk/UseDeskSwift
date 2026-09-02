//
//  UDMarkdownText.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDMarkdownText: UIViewRepresentable {
    var text: String = ""
    var attributed: NSAttributedString? = nil
    var font: UIFont = .systemFont(ofSize: UIFont.systemFontSize)
    var color: UIColor = .label
    let linkColor: UIColor
    let maxWidth: CGFloat
    var preferredSize: CGSize? = nil

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.widthTracksTextView = true
        textView.dataDetectorTypes = [.link]
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
        return textView
    }

    static func size(text: String, font: UIFont, color: UIColor, linkColor: UIColor, maxWidth: CGFloat) -> CGSize {
        let attributed = UDMarkdownParser.mutableAttributedString(
            for: text,
            font: font,
            color: color,
            linkColor: linkColor
        )
        let bounding = attributed.boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return CGSize(width: min(ceil(bounding.width), maxWidth), height: ceil(bounding.height))
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        let attributedToRender: NSAttributedString = attributed ?? UDMarkdownParser.mutableAttributedString(
            for: text,
            font: font,
            color: color,
            linkColor: linkColor
        )
        textView.linkTextAttributes = [
            .foregroundColor: linkColor,
            .underlineColor: linkColor
        ]
        if textView.attributedText != attributedToRender {
            textView.attributedText = attributedToRender
            textView.invalidateIntrinsicContentSize()
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        if let preferredSize {
            return preferredSize
        }
        uiView.textContainer.size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        return uiView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
    }
}
