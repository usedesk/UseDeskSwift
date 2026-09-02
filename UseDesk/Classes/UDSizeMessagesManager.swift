//
//  UDBubbleSizing.swift
//  UseDesk_SDK_Swift

import UIKit

enum UDSizeMessagesManager {

    static func timeStatusWidth(message: UDMessage, style: ConfigurationStyle) -> CGFloat {
        let messageStyle = style.messageStyle
        let avatarStyle = style.avatarStyle
        let timeColor = message.outgoing ? messageStyle.timeOutgoingColor : messageStyle.timeIncomingColor
        var width = "99:99".size(attributes: [.foregroundColor: timeColor, .font: messageStyle.timeFont]).width
        if message.outgoing || (message.incoming && avatarStyle.avatarIncomingHidden) {
            width += messageStyle.sendedStatusSize.width + messageStyle.sendedStatusMargin.left + messageStyle.timeMargin.right
        } else {
            width += messageStyle.timeMargin.right
        }
        return width
    }

    static func maxBubbleWidth(message: UDMessage, style: ConfigurationStyle, screenWidth: CGFloat = SCREEN_WIDTH,     includesTimeSize: Bool = false) -> CGFloat {
        let avatarStyle = style.avatarStyle
        let bubbleStyle = style.bubbleStyle
        var maxWidth: CGFloat
        if message.outgoing || (message.incoming && avatarStyle.avatarIncomingHidden) {
            maxWidth = screenWidth - bubbleStyle.marginBefore - bubbleStyle.marginAfter
        } else {
            maxWidth = screenWidth - avatarStyle.avatarDiameter - avatarStyle.margin.left - avatarStyle.margin.right - bubbleStyle.marginAfter
        }
        return maxWidth
    }

    static func topSpacing(message: UDMessage, nextMessage: UDMessage?, style: ConfigurationStyle) -> CGFloat {
        let bubbleStyle = style.bubbleStyle
        guard let nextMessage = nextMessage else { return bubbleStyle.spacingOneSender }
        if message.typeSenderMessage == nextMessage.typeSenderMessage {
            if nextMessage.typeSenderMessage == .operator_to_client {
                return message.operatorId == nextMessage.operatorId ? bubbleStyle.spacingOneSender : bubbleStyle.spacingDifferentSender
            }
            return bubbleStyle.spacingOneSender
        }
        return bubbleStyle.spacingDifferentSender
    }

    static func mediaSideSize(message: UDMessage,
                          style: ConfigurationStyle,
                          isLandscape: Bool = UIScreen.main.bounds.width > UIScreen.main.bounds.height) -> CGFloat {
        let percentWidth: CGFloat = isLandscape ? 0.4 : 0
        return maxBubbleWidth(message: message, style: style, screenWidth: SCREEN_WIDTH) * (1 - percentWidth)
    }
}
