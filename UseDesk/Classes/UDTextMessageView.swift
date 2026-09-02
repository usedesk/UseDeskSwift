//
//  UDTextMessageView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDTextMessageView: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage { item.message }
    private var style: ConfigurationStyle { viewModel.configurationStyle }

    private var textColor: UIColor {
        message.outgoing ? style.messageStyle.textOutgoingColor : style.messageStyle.textIncomingColor
    }
    private var linkColor: UIColor {
        message.outgoing ? style.messageStyle.linkOutgoingColor : style.messageStyle.linkIncomingColor
    }

    private var displayText: String {
        var text = message.text
        if !message.forms.isEmpty || !message.buttons.isEmpty {
            text = text.udRemoveLastSymbol(with: "\n")
        }
        return text
    }

    private var textMaxWidth: CGFloat {
        let textMargin = style.messageStyle.textMargin
        return UDSizeMessagesManager.maxBubbleWidth(message: message, style: style) - textMargin.left - textMargin.right
    }

    private var contentWidth: CGFloat {
        if !message.buttons.isEmpty || !message.forms.isEmpty {
            return UDSizeMessagesManager.maxBubbleWidth(message: message, style: style)
        }
        let textSize = UDMarkdownText.size(
            text: displayText,
            font: style.messageStyle.font,
            color: textColor,
            linkColor: linkColor,
            maxWidth: textMaxWidth
        )
        let timeWidth = UDSizeMessagesManager.timeStatusWidth(message: message, style: style)
        return min(max(textSize.width, timeWidth), textMaxWidth)
    }

    var body: some View {
        UDMessageBubbleView(
            message: message,
            viewModel: viewModel,
            isNeedShowSender: item.isNeedShowSender,
            style: style,
            onTapFailed: {
                viewModel.onTapFailedMessage?(message)
            }) {
                
            if let layout = item.textLayout {
                UDMarkdownText(
                    attributed: layout.attributed,
                    linkColor: linkColor,
                    maxWidth: layout.contentWidth,
                    preferredSize: CGSize(width: layout.contentWidth, height: layout.textHeight)
                )
                .frame(width: layout.contentWidth, height: layout.height, alignment: .topLeading)
                .padding(style.messageStyle.textMargin.udSwiftUIInsets)
                .overlay(alignment: .bottomTrailing) {
                    UDMessageTimeStatusView(message: message, style: style.messageStyle)
                        .padding(.trailing, style.messageStyle.timeMargin.right)
                        .padding(.bottom, style.messageStyle.timeMargin.bottom)
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    UDMarkdownText(
                        text: displayText,
                        font: style.messageStyle.font,
                        color: textColor,
                        linkColor: linkColor,
                        maxWidth: textMaxWidth
                    )
                    .padding(style.messageStyle.textMargin.udSwiftUIInsets)

                    if !message.buttons.isEmpty {
                        UDMessageButtonsView(message: message, style: style) { button in
                            viewModel.onTapButton?(message, button)
                        }
                    }

                    if !message.forms.isEmpty {
                        UDMessageFormView(message: message, viewModel: viewModel)
                    }

                    HStack {
                        Spacer(minLength: 0)
                        UDMessageTimeStatusView(message: message, style: style.messageStyle)
                            .padding(.trailing, style.messageStyle.timeMargin.right)
                            .padding(.bottom, style.messageStyle.timeMargin.bottom)
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
            }
        }
    }
}
