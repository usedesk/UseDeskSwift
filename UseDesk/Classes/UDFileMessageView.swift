//
//  UDFileMessageView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDFileMessageView: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage {
        item.message
    }
    private var style: ConfigurationStyle {
        viewModel.configurationStyle
    }
    private var fileStyle: FileStyle {
        style.fileStyle
    }

    private var nameColor: UIColor {
        message.outgoing ? fileStyle.nameOutgoingColor : fileStyle.nameIncomingColor
    }
    private var sizeColor: UIColor {
        message.outgoing ? fileStyle.sizeOutgoingColor : fileStyle.sizeIncomingColor
    }
    private var sizeText: String {
        guard let model = viewModel.usedesk?.model else {
            return message.file.size
        }
        return message.file.sizeString(model: model)
    }

    private var maxContentWidth: CGFloat {
        let iconMargin = fileStyle.iconMargin
        let nameMargin = fileStyle.nameMargin
        let fixedWidth = fileStyle.iconSize.width + iconMargin.left + iconMargin.right + nameMargin.left + nameMargin.right
        return UDSizeMessagesManager.maxBubbleWidth(message: message, style: style) - fixedWidth
    }

    private var nameAndSizeStackWidth: CGFloat {
        let nameWidth = message.file.name.size(attributes: [.font: fileStyle.fontName]).width
        let timeWidth = UDSizeMessagesManager.timeStatusWidth(message: message, style: style) + style.messageStyle.timeMargin.right
        let sizeWidth = sizeText.isEmpty ? 0 : sizeText.size(attributes: [.font: fileStyle.fontSize]).width
        let sizeTimeRowWidth = sizeWidth + timeWidth
        return min(max(nameWidth, sizeTimeRowWidth), maxContentWidth)
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
                
            HStack(alignment: .top, spacing: 0) {
                Image(uiImage: fileStyle.imageIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: fileStyle.iconSize.width, height: fileStyle.iconSize.height)
                    .padding(fileStyle.iconMargin.udSwiftUIInsets)

                VStack(alignment: .leading, spacing: fileStyle.sizeMarginTop) {
                    Text(message.file.name)
                        .font(Font(fileStyle.fontName))
                        .foregroundColor(Color(nameColor))
                        .lineLimit(1)
                        .truncationMode(.middle)

                    if !sizeText.isEmpty {
                        Text(sizeText)
                            .font(Font(fileStyle.fontSize))
                            .foregroundColor(Color(sizeColor))
                            .lineLimit(1)
                    }
                }
                .frame(width: nameAndSizeStackWidth, alignment: .leading)
                .padding(.top, fileStyle.nameMargin.top)
                .padding(.trailing, fileStyle.nameMargin.right)
                
            }
            .overlay(alignment: .bottomTrailing) {
                UDMessageTimeStatusView(message: message, style: style.messageStyle)
                    .padding(.trailing, style.messageStyle.timeMargin.right)
                    .padding(.bottom, style.messageStyle.timeMargin.bottom)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onTapFile?(message)
            }
        }
    }
}
