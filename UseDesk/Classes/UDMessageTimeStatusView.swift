// UDMessageTimeStatusView.swift
// UseDesk_SDK_Swift

import SwiftUI

struct UDMessageTimeStatusView: View {
    let message: UDMessage
    let style: MessageStyle
    var isPictureOrVideo: Bool = false

    private var timeColor: UIColor {
        if isPictureOrVideo {
            return message.outgoing ? style.timeOutgoingPictureColor : style.timeIncomingPictureColor
        }
        return message.outgoing ? style.timeOutgoingColor : style.timeIncomingColor
    }

    private var statusImage: UIImage? {
        guard message.outgoing else { return nil }
        if isPictureOrVideo {
            return message.statusSend == UD_STATUS_SEND_SUCCEED ? style.sendedStatusImageForImageMessage : style.sendStatusImageForImageMessage
        }
        return message.statusSend == UD_STATUS_SEND_SUCCEED ? style.sendedStatusImage : style.sendStatusImage
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: style.sendedStatusMargin.left) {
            Text(message.date.time)
                .font(Font(style.timeFont))
                .foregroundColor(Color(timeColor))
            if let statusImage = statusImage {
                Image(uiImage: statusImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: style.sendedStatusSize.width, height: style.sendedStatusSize.height)
                    .padding(.bottom, style.sendedStatusMargin.bottom)
            }
        }
    }
}
