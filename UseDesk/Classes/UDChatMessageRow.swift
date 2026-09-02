//
//  UDChatMessageRow.swift
//  UseDesk_SDK_Swift

import SwiftUI

struct UDChatMessageRow: View {
    let item: UDChatItem
    @ObservedObject var viewModel: UDChatMessagesViewModel

    private var message: UDMessage { item.message }

    var body: some View {
        Group {
            switch message.type {
            case UD_TYPE_TEXT:
                UDTextMessageView(item: item, viewModel: viewModel)
            case UD_TYPE_Feedback:
                UDFeedbackMessageView(item: item, viewModel: viewModel)
            case UD_TYPE_PICTURE:
                UDPictureMessageView(item: item, viewModel: viewModel)
            case UD_TYPE_VIDEO:
                UDVideoMessageView(item: item, viewModel: viewModel)
            default: // UD_TYPE_File
                UDFileMessageView(item: item, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.outgoing ? .trailing : .leading)
    }
}
