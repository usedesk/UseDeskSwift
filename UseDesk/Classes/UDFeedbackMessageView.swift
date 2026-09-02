//
//  UDFeedbackMessageView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDFeedbackMessageView: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage {
        item.message
    }
    private var style: ConfigurationStyle {
        viewModel.configurationStyle
    }
    private var feedbackStyle: FeedbackMessageStyle {
        style.feedbackMessageStyle
    }
    private var npsType: UDCsiNpsType {
        message.csi?.npsType ?? .unknown
    }

    private var buttons: [UDCsiButton] {
        message.csi?.buttons ?? []
    }
    private var selectedIndex: Int? {
        guard !message.feedbackRatingId.isEmpty else { return nil }
        return buttons.firstIndex(where: {$0.id == message.feedbackRatingId})
    }
    private var isInteractive: Bool {
        selectedIndex == nil
    }

    private var isOnlySelectedShown: Bool {
        npsType == .twoPoint && !isInteractive
    }
    private var visibleButtonsCount: Int {
        guard !buttons.isEmpty else { return 0 }
        return isOnlySelectedShown ? 1 : buttons.count
    }
    
    private var maxContentWidth: CGFloat {
        UDSizeMessagesManager.maxBubbleWidth(message: message, style: style)
    }

    private var buttonSize: CGSize {
        let styleSize = feedbackStyle.buttonSize
        let count = CGFloat(max(visibleButtonsCount, 1))
        guard styleSize.width > 0 else {
            return styleSize
        }
        let available = maxContentWidth - feedbackStyle.buttonsSpacing * (count + 1)
        let side = min(styleSize.width, max(available / count, 0))
        let scale = side / styleSize.width
        
        return CGSize(width: side, height: styleSize.height * scale)
    }
    
    private var buttonsBlockWidth: CGFloat {
        guard visibleButtonsCount > 0 else {
            return 0
        }
        let count = CGFloat(visibleButtonsCount)
        return buttonSize.width * count + feedbackStyle.buttonsSpacing * (count - 1)
    }

    private var buttonsWidth: CGFloat {
        guard visibleButtonsCount > 0 else {
            return 0
        }
        return buttonsBlockWidth + feedbackStyle.buttonsSpacing * 2
    }

    private var textSize: CGSize {
        guard !message.text.isEmpty else {
            return .zero
        }
        let textMargin = feedbackStyle.textMargin
        let maxTextWidth = maxContentWidth - textMargin.left - textMargin.right
        return UDMarkdownText.size(
            text: message.text,
            font: feedbackStyle.font,
            color: feedbackStyle.textColor,
            linkColor: feedbackStyle.linkColor,
            maxWidth: maxTextWidth
        )
    }

    private var textWidth: CGFloat {
        guard !message.text.isEmpty else {
            return 0
        }
        let textMargin = feedbackStyle.textMargin
        return textSize.width + textMargin.left + textMargin.right
    }

    private var timeWidth: CGFloat {
        UDSizeMessagesManager.timeStatusWidth(message: message, style: style)
    }

    private var contentWidth: CGFloat {
        min(max(buttonsWidth, textWidth, timeWidth), maxContentWidth)
    }

    private var timeBottomReserve: CGFloat {
        let messageStyle = style.messageStyle
        guard !message.text.isEmpty else {
            let statusHeight = messageStyle.sendedStatusSize.height + messageStyle.sendedStatusMargin.bottom
            let timeHeight = max(messageStyle.timeFont.lineHeight, statusHeight)
            return ceil(timeHeight + messageStyle.timeMargin.bottom + 6)
        }
        guard textSize.width + 2 * timeWidth > contentWidth else {
            return 0
        }
        return ceil(feedbackStyle.font.lineHeight / 2)
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

            VStack(spacing: 0) {
                buttonsView
                    .padding(.top, feedbackStyle.buttonsMarginTop)

                if !message.text.isEmpty {
                    Text(message.text)
                        .font(Font(feedbackStyle.font))
                        .foregroundColor(Color(feedbackStyle.textColor))
                        .multilineTextAlignment(.center)
                        .padding(feedbackStyle.textMargin.udSwiftUIInsets)
                }
            }
            .frame(width: contentWidth)
            .padding(.bottom, timeBottomReserve)
            .overlay(alignment: .bottomTrailing) {
                UDMessageTimeStatusView(message: message, style: style.messageStyle)
                    .padding(.trailing, style.messageStyle.timeMargin.right)
                    .padding(.bottom, style.messageStyle.timeMargin.bottom)
            }
        }
    }

    @ViewBuilder
    private var buttonsView: some View {
        if buttons.isEmpty {
            EmptyView()
        } else if isOnlySelectedShown, let selectedIndex {
            iconView(at: selectedIndex)
        } else {
            HStack(spacing: feedbackStyle.buttonsSpacing) {
                ForEach(Array(buttons.enumerated()), id: \.offset) { index, button in
                    if isInteractive {
                        Button {
                            viewModel.onFeedback?(message, button)
                        } label: {
                            iconView(at: index)
                        }
                    } else {
                        iconView(at: index)
                    }
                }
            }
        }
    }
    
    private func iconView(at index: Int) -> some View {
        Image(uiImage: icon(at: index))
            .resizable()
            .scaledToFit()
            .frame(width: buttonSize.width, height: buttonSize.height)
    }
    
    private func icon(at index: Int) -> UIImage {
        switch npsType {
        case .twoPoint:
            return feedbackStyle.reactionImage(label: buttons[index].label, isSelected: selectedIndex == index)
        case .fivePoint, .unknown:
            let isFilled = index <= (selectedIndex ?? -1)
            return isFilled ? feedbackStyle.ratingOnImage : feedbackStyle.ratingOffImage
        }
    }
}
