//
//  UDMessageButtonsView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDMessageButtonsView: View {
    let message: UDMessage
    let style: ConfigurationStyle
    let onTap: (UDMessageButton) -> Void

    private var buttonStyle: MessageButtonStyle {
        style.messageButtonStyle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: buttonStyle.spacing) {
            ForEach(Array(message.buttons.enumerated()), id: \.offset) { _, button in
                Button {
                    onTap(button)
                } label: {
                    Text(button.title)
                        .font(Font(buttonStyle.textFont))
                        .foregroundColor(Color(buttonStyle.textColor))
                        .lineLimit(buttonStyle.maximumLine)
                        .padding( 8)
                        .frame(maxWidth: .infinity, minHeight: buttonStyle.minHeight)
                        .background(
                            RoundedRectangle(cornerRadius: buttonStyle.cornerRadius)
                                .fill(Color(buttonStyle.color))
                        )
                }
            }
        }
        .padding(buttonStyle.margin.udSwiftUIInsets)
    }
}
