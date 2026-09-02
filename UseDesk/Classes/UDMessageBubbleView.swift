//
//  UDMessageBubbleView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDMessageBubbleView<Content: View>: View {
    let message: UDMessage
    @ObservedObject var viewModel: UDChatMessagesViewModel
    let isNeedShowSender: Bool
    var isNeedShowBubbleBackground: Bool = true
    let style: ConfigurationStyle
    var onTapFailed: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    @State private var flashOpacity: Double = 0

    private var bubbleImage: UIImage {
        message.outgoing ? style.bubbleStyle.backgroundImageOutgoing : style.bubbleStyle.backgroundImageIncoming
    }
    private var bubbleTint: UIColor {
        message.incoming ? style.bubbleStyle.bubbleColorIncoming : style.bubbleStyle.bubbleColorOutgoing
    }

    private var isNeedShowFailIcon: Bool {
        !message.incoming && message.statusSend == UD_STATUS_SEND_FAIL
    }

    private var outgoingLeadingMargin: CGFloat {
        isNeedShowFailIcon ? style.bubbleStyle.marginBefore : style.bubbleStyle.marginAfter
    }

    var body: some View {
        HStack(alignment: isNeedShowFailIcon ? .center : .bottom, spacing: 0) {
            if message.incoming {
                avatarView
            } else if isNeedShowFailIcon {
                failIcon
            }

            VStack(alignment: message.outgoing ? .trailing : .leading, spacing: 0) {
                if message.incoming && isNeedShowSender {
                    Text(message.operatorName != "" ? message.operatorName : message.name)
                        .font(Font(style.messageStyle.senderTextFont))
                        .foregroundColor(Color(style.messageStyle.senderTextColor))
                        .padding(style.messageStyle.senderTextMargin.udSwiftUIInsets)
                }
                content()
                    .background(bubbleBackground)
                    .overlay(flashOverlay)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onChange(of: viewModel.flashMessageId) { newValue in
            guard let newValue = newValue, newValue == message.id else { return }
            triggerFlash()
        }
        .onAppear {
            guard let flashId = viewModel.flashMessageId, flashId == message.id else { return }
            triggerFlash()
        }
        .padding(.leading, message.incoming ? (style.avatarStyle.avatarIncomingHidden ? style.bubbleStyle.marginBefore : 0) : outgoingLeadingMargin)
        .padding(.trailing, message.incoming ? style.bubbleStyle.marginAfter : style.bubbleStyle.marginBefore)
    }

    private var failIcon: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            Image(uiImage: style.messageStyle.notSentImage)
                .resizable()
                .scaledToFit()
                .frame(width: style.messageStyle.notSentImageSize.width, height: style.messageStyle.notSentImageSize.height)
                .padding(.trailing, style.messageStyle.notSentImageMarginToBubble)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture_udFailed(onTapFailed)
    }

    private var senderInitials: String {
        let senderName = message.operatorName != "" ? message.operatorName : message.name
        return senderName.udInitials
    }

    @ViewBuilder
    private var avatarView: some View {
        if style.avatarStyle.avatarIncomingHidden {
            EmptyView()
        } else {
            avatarContent
                .frame(width: style.avatarStyle.avatarDiameter, height: style.avatarStyle.avatarDiameter)
                .clipShape(Circle())
                .padding(style.avatarStyle.margin.udSwiftUIInsets)
        }
    }

    @ViewBuilder
    private var avatarContent: some View {
        if let avatarImage = message.avatarImage {
            Image(uiImage: avatarImage)
                .resizable()
                .scaledToFill()
        } else {
            switch style.avatarStyle.avatarFallbackPriority {
            case .initials:
                if senderInitials.isEmpty {
                    defaultAvatarImage
                } else {
                    initialsAvatar
                }
            case .defaultImage:
                defaultAvatarImage
            }
        }
    }

    private var defaultAvatarImage: some View {
        Image(uiImage: style.avatarStyle.avatarImageDefault).resizable().scaledToFill()
    }

    private var initialsAvatar: some View {
        ZStack {
            Color(style.avatarStyle.avatarBackColor)
            Text(senderInitials)
                .font(Font(style.avatarStyle.avatarFont))
                .foregroundColor(Color(style.avatarStyle.avatarTextColor))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding(style.avatarStyle.avatarDiameter * 0.12)
        }
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if isNeedShowBubbleBackground {
            UDBubbleBackground(image: bubbleImage, tintColor: bubbleTint)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var flashOverlay: some View {
        if isNeedShowBubbleBackground {
            UDBubbleBackground(image: bubbleImage, tintColor: style.bubbleStyle.bubbleSelectColor)
                .opacity(flashOpacity)
                .allowsHitTesting(false)
        }
    }

    private func triggerFlash() {
        if viewModel.flashMessageId == message.id {
            viewModel.flashMessageId = nil
        }
        flashOpacity = 1
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.7)) {
                flashOpacity = 0
            }
        }
    }
}
