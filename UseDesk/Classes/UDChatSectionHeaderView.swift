//
//  UDChatSectionHeaderView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDChatSectionHeaderView: View {
    let message: UDMessage
    let style: SectionHeaderStyle
    weak var usedesk: UseDeskSDK?

    private var dateText: String {
        guard let usedesk = usedesk else { return "" }
        return message.date.dateFromHeaderChat(usedesk)
    }

    var body: some View {
        Text(dateText)
            .font(Font(style.font))
            .foregroundColor(Color(style.textColor))
            .padding(style.backViewPadding.udSwiftUIInsets)
            .background(
                RoundedRectangle(cornerRadius: style.backViewCornerRadius)
                    .fill(Color(style.backViewColor))
                    .opacity(style.backViewOpacity)
            )
            .padding(style.margin.udSwiftUIInsets)
            .frame(maxWidth: .infinity)
    }
}
