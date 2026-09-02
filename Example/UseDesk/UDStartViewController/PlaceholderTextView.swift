//
//  PlaceholderTextView.swift
//  UseDesk_Example

import UIKit

@objc(PlaceholderTextView)
final class PlaceholderTextView: UITextView {

    private static let caretReserve: CGFloat = 3
    private static let verticalInset: CGFloat = 8

    private var desiredAlignment: NSTextAlignment?

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()

    @IBInspectable var placeholder: String? {
        get { placeholderLabel.text }
        set {
            placeholderLabel.text = newValue
            updatePlaceholderVisibility()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets(top: Self.verticalInset, left: 0, bottom: Self.verticalInset, right: Self.caretReserve)

        addSubview(placeholderLabel)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: self)
        updatePlaceholderVisibility()
    }

    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
            adjustAlignment()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        captureDesiredAlignmentIfNeeded()
        adjustAlignment()
        layoutPlaceholder()
    }

    @objc private func handleTextDidChange() {
        updatePlaceholderVisibility()
        adjustAlignment()
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }

    private func captureDesiredAlignmentIfNeeded() {
        guard desiredAlignment == nil else { return }
        desiredAlignment = xibAlignment
    }

    private func layoutPlaceholder() {
        placeholderLabel.textAlignment = desiredAlignment ?? textAlignment
        placeholderLabel.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY + Self.verticalInset,
            width: max(0, bounds.width - Self.caretReserve),
            height: ceil(placeholderLabel.font.lineHeight)
        )
    }

    private var xibAlignment: NSTextAlignment {
        if let style = typingAttributes[.paragraphStyle] as? NSParagraphStyle, style.alignment != .natural {
            return style.alignment
        }
        return textAlignment
    }

    private func adjustAlignment() {
        guard desiredAlignment == .right, bounds.width > 0 else { return }

        let available = bounds.width - Self.caretReserve
        let width = ceil(singleLineWidth())
        let isFits = width + 1 <= available
        let targetAlignment: NSTextAlignment = isFits ? .left : .right
        let targetLeftInset = isFits ? max(0, available - width - 1) : 0

        if textAlignment != targetAlignment {
            textAlignment = targetAlignment
        }
        if abs(textContainerInset.left - targetLeftInset) > 0.5 {
            textContainerInset.left = targetLeftInset
        }
    }

    private func singleLineWidth() -> CGFloat {
        let attributes: [NSAttributedString.Key : Any] = [.font: font ?? UIFont.systemFont(ofSize: 15)]
        return ((text ?? "") as NSString).size(withAttributes: attributes).width
    }
}
