//
//  UDPictureMessageView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDPictureMessageView: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage {
        item.message
    }
    
    private var style: ConfigurationStyle {
        viewModel.configurationStyle
    }
    
    private var pictureStyle: PictureStyle {
        style.pictureStyle
    }

    private var loadedImage: UIImage? {
        message.file.image ?? message.file.preview
    }

    private var image: UIImage {
        loadedImage ?? pictureStyle.imageDefault
    }

    private var isLoading: Bool {
        loadedImage == nil
    }

    private var sideMediaSize: CGFloat {
        var mediaSideSize = UDSizeMessagesManager.mediaSideSize(message: message, style: style)
        if pictureStyle.isNeedBubble {
            mediaSideSize -= pictureStyle.margin.left + pictureStyle.margin.right
        }
        return mediaSideSize
    }
    
    private var paddingMediaView: EdgeInsets {
        pictureStyle.isNeedBubble ? pictureStyle.margin.udSwiftUIInsets : EdgeInsets()
    }

    var body: some View {
        UDMessageBubbleView(
            message: message,
            viewModel: viewModel,
            isNeedShowSender: item.isNeedShowSender,
            isNeedShowBubbleBackground: pictureStyle.isNeedBubble,
            style: style,
            onTapFailed: {
                viewModel.onTapFailedMessage?(message)
            }) {
                
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: sideMediaSize, height: sideMediaSize)
                    .clipped()
                    .cornerRadius(pictureStyle.cornerRadius)

                timeView
                    .padding(style.messageStyle.timeBackViewMargin.udSwiftUIInsets)

                if isLoading {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 44, height: 44)

                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .frame(width: sideMediaSize, height: sideMediaSize, alignment: .center)
                }
            }
            .padding(paddingMediaView)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onTapImage?(message)
            }
        }
    }

    private var timeView: some View {
        UDMessageTimeStatusView(message: message, style: style.messageStyle, isPictureOrVideo: true)
            .padding(style.messageStyle.timeBackViewPadding.udSwiftUIInsets)
            .background(
                RoundedRectangle(cornerRadius: style.messageStyle.timeBackViewCornerRadius)
                    .fill(Color(message.outgoing ? style.messageStyle.timeBackViewOutgoingColor : style.messageStyle.timeBackViewIncomingColor))
                    .opacity(style.messageStyle.timeBackViewOpacity)
            )
    }
}
