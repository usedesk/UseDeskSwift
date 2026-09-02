//
//  UDVideoMessageView.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDVideoMessageView: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage {
        item.message
    }
    private var style: ConfigurationStyle {
        viewModel.configurationStyle
    }
    private var videoStyle: VideoStyle {
        style.videoStyle
    }

    private var preview: UIImage {
        if let preview = message.file.preview {
            return preview
        }
        if !message.file.path.isEmpty {
            return UDFileManager.videoPreview(fileURL: URL(fileURLWithPath: message.file.path))
        }
        if !message.file.defaultPath.isEmpty {
            return UDFileManager.videoPreview(fileURL: URL(fileURLWithPath: message.file.defaultPath))
        }
        return videoStyle.imageDefault
    }

    private var isLoading: Bool {
        message.file.preview == nil && message.file.path.isEmpty && message.file.defaultPath.isEmpty
    }

    private var sideMediaSize: CGFloat {
        var mediaSideSize = UDSizeMessagesManager.mediaSideSize(message: message, style: style)
        if videoStyle.isNeedBubble {
            mediaSideSize -= videoStyle.margin.left + videoStyle.margin.right
        }
        return mediaSideSize
    }
    
    private var paddingMediaView: EdgeInsets {
        videoStyle.isNeedBubble ? videoStyle.margin.udSwiftUIInsets : EdgeInsets()
    }

    var body: some View {
        UDMessageBubbleView(
            message: message,
            viewModel: viewModel,
            isNeedShowSender: item.isNeedShowSender,
            isNeedShowBubbleBackground: videoStyle.isNeedBubble,
            style: style,
            onTapFailed: {
                viewModel.onTapFailedMessage?(message)
            }) {
                
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .center) {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFill()
                        .frame(width: sideMediaSize, height: sideMediaSize)
                        .clipped()
                        .cornerRadius(videoStyle.cornerRadius)

                    if isLoading {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 44, height: 44)

                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    } else {
                        Image(uiImage: .named("udVideoPlay"))
                            .resizable()
                            .frame(width: 48, height: 48)
                    }
                }

                timeView
                    .padding(style.messageStyle.timeBackViewMargin.udSwiftUIInsets)
            }
            .padding(paddingMediaView)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.onTapVideo?(message)
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
