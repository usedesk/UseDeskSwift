//
//  UDChatMessagesViewModel.swift
//  UseDesk_SDK_Swift

import Foundation
import Combine

struct UDChatItem: Identifiable {
    var id: String
    let message: UDMessage
    let isNeedShowSender: Bool
    let topSpacing: CGFloat
    let textLayout: UDTextLayout?

    init(message: UDMessage, isNeedShowSender: Bool, topSpacing: CGFloat, textLayout: UDTextLayout? = nil) {
        self.message = message
        self.isNeedShowSender = isNeedShowSender
        self.topSpacing = topSpacing
        self.textLayout = textLayout
        self.id = UDChatItem.baseId(for: message)
    }

    static func baseId(for message: UDMessage) -> String {
        if message.id != 0 {
            return UDChatItem.itemId(forMessageId: message.id, fileId: message.file.id)
        }
        if !message.loadingMessageId.isEmpty {
            return "draft_\(message.loadingMessageId)_f\(message.file.id)_s\(message.file.sort)"
        }
        return "obj_\(ObjectIdentifier(message).hashValue)"
    }

    static func itemId(forMessageId messageId: Int, fileId: Int = 0) -> String {
        fileId != 0 ? "msg_\(messageId)_f\(fileId)" : "msg_\(messageId)"
    }
}

struct UDChatSection: Identifiable {
    let id: Int
    let items: [UDChatItem]
}

final class UDChatMessagesViewModel: ObservableObject {

    @Published var sections: [UDChatSection] = []
    @Published var scrollToBottomToken: Int = 0
    @Published var preserveOffsetToken: Int = 0
    @Published var appliedToken: Int = 0
    @Published var isLoadingHistory: Bool = false
    @Published var focusedFormFieldId: String?
    @Published var flashMessageId: Int?
    @Published var pendingScrollMessageId: Int?

    var configurationStyle: ConfigurationStyle = ConfigurationStyle()
    weak var usedesk: UseDeskSDK?

    var onDismissKeyboard: (() -> Void)?
    var onReachTopForPagination: (() -> Void)?
    var onWillDisplay: ((_ message: UDMessage) -> Void)?
    var onTapFile: ((_ message: UDMessage) -> Void)?
    var onTapImage: ((_ message: UDMessage) -> Void)?
    var onTapVideo: ((_ message: UDMessage) -> Void)?
    var onTapButton: ((_ message: UDMessage, _ button: UDMessageButton) -> Void)?
    var onSelectFormField: ((_ message: UDMessage, _ formIndex: Int) -> Void)?
    var onChangeFormText: ((_ message: UDMessage, _ formIndex: Int, _ text: String) -> Void)?
    var onToggleFormCheckbox: ((_ message: UDMessage, _ formIndex: Int) -> Void)?
    var onSendForm: ((_ message: UDMessage) -> Void)?
    var onFeedback: ((_ message: UDMessage, _ button: UDCsiButton) -> Void)?
    var onTapFailedMessage: ((_ message: UDMessage) -> Void)?
    var onScrollOffsetChanged: ((_ offset: CGFloat) -> Void)?
    var onUserScrolled: (() -> Void)?
    var onVisibleMessages: ((_ ids: [Int]) -> Void)?

    private var applyGeneration: Int = 0
    private let applyQueue = DispatchQueue(label: "com.usedesk.UDChatMessagesViewModel.apply", qos: .userInitiated)

    func apply(messagesWithSection: [[UDMessage]], senderFlags: [[Bool]], topSpacings: [[CGFloat]]) {
        let style = configurationStyle
        let screenWidth = SCREEN_WIDTH

        applyGeneration &+= 1
        let generation = applyGeneration

        applyQueue.async {
            var newSections: [UDChatSection] = []
            for (sectionIndex, rows) in messagesWithSection.enumerated() {
                var items: [UDChatItem] = []
                for (rowIndex, message) in rows.enumerated() {
                    let showSender = senderFlags.indices.contains(sectionIndex)
                        && senderFlags[sectionIndex].indices.contains(rowIndex)
                        ? senderFlags[sectionIndex][rowIndex]
                        : true
                    let topSpacing = topSpacings.indices.contains(sectionIndex)
                        && topSpacings[sectionIndex].indices.contains(rowIndex)
                        ? topSpacings[sectionIndex][rowIndex]
                        : 0
                    var textLayout: UDTextLayout? = nil
                    if message.type == UD_TYPE_TEXT, message.buttons.isEmpty, message.forms.isEmpty {
                        textLayout = UDTextLayoutManager.makeLayout(for: message, style: style, screenWidth: screenWidth)
                    }

                    items.append(UDChatItem(message: message, isNeedShowSender: showSender, topSpacing: topSpacing, textLayout: textLayout))
                }
                newSections.append(UDChatSection(id: sectionIndex, items: items))
            }
            UDChatMessagesViewModel.makeItemIdsUnique(in: &newSections)
            DispatchQueue.main.async {
                guard generation == self.applyGeneration else {
                    return
                }
                self.sections = newSections
                self.appliedToken &+= 1
            }
        }
    }

    private static func makeItemIdsUnique(in sections: inout [UDChatSection]) {
        var usedIds: Set<String> = []
        for sectionIndex in sections.indices {
            var items = sections[sectionIndex].items
            var isChanged = false
            for itemIndex in items.indices {
                var id = items[itemIndex].id
                var duplicateIndex = 1
                while usedIds.contains(id) {
                    id = "\(items[itemIndex].id)_d\(duplicateIndex)"
                    duplicateIndex += 1
                }
                usedIds.insert(id)
                if id != items[itemIndex].id {
                    items[itemIndex].id = id
                    isChanged = true
                }
            }
            if isChanged {
                sections[sectionIndex] = UDChatSection(id: sections[sectionIndex].id, items: items)
            }
        }
    }

    func itemId(forMessageId messageId: Int) -> String? {
        for section in sections {
            for item in section.items where item.message.id == messageId {
                return item.id
            }
        }
        return nil
    }

     func scrollToBottom() {
        scrollToBottomToken &+= 1
    }

    func flash(messageId: Int) {
        flashMessageId = messageId
    }

    func scrollToMessage(id: Int) {
        pendingScrollMessageId = id
    }

    func preserveOffsetOnNextGrowth() {
        preserveOffsetToken &+= 1
    }
}
