//
//  UDChatStyleHelpers.swift
//  UseDesk_SDK_Swift

import SwiftUI

extension View {
    @ViewBuilder
    func udFlippedUpsideDown() -> some View {
        self.rotationEffect(.degrees(180)).scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    @ViewBuilder
    func onTapGesture_udFailed(_ action: (() -> Void)?) -> some View {
        if let action = action {
            self.contentShape(Rectangle()).onTapGesture { action() }
        } else {
            self
        }
    }
}

extension Color {
    init(ud uiColor: UIColor) {
        self = Color(uiColor)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let int = UInt64(hex, radix: 16) ?? 0
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIEdgeInsets {
    var udSwiftUIInsets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

struct UDActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = false
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.style = style
    }
}

struct UDBubbleBackground: View {
    let image: UIImage
    let tintColor: UIColor

    var body: some View {
        Image(uiImage: image)
            .resizable(
                capInsets: EdgeInsets(top: 16, leading: 23, bottom: 16, trailing: 23),
                resizingMode: .stretch
            )
            .renderingMode(.template)
            .foregroundColor(Color(tintColor))
    }
}
