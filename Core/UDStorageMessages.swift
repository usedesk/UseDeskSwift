//
//  UDStorage.swift
//  UseDesk_SDK_Swift
//

import Foundation

public class UDStorageMessages: NSObject, UDStorage {
    
    public var token = ""
    
    var urlStorage: URL? = nil
    
    init(token: String) {
        super.init()
        self.token = token
    }
    
    public func getMessages() -> [UDMessage] {
        guard token.count > 0 else {return []}
        if urlStorage == nil {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                urlStorage = documentDirectory.appendingPathComponent(token + "UDStorage.json")
            }
        }
        if urlStorage != nil {
            do {
                let jsonString = try String(contentsOf: urlStorage!, encoding: .utf8)
                let messages = try JSONDecoder().decode([UDMessage].self, from: jsonString.data(using: .utf8)!)
                return messages
            } catch let error {
                print(error)
            }
        }
        return []
    }
    
    public func saveMessages(_ messages: [UDMessage]) {
        let allMessages = getMessages()
        var messagesDelete = [UDMessage]()
        var messagesSave = [UDMessage]()
        for message in messages {
            if let index = allMessages.firstIndex(where: {($0.id == message.id && message.id > 0) || (!message.loadingMessageId.isEmpty && $0.loadingMessageId == message.loadingMessageId)}) {
                allMessages[index].statusSend = message.statusSend
                messagesDelete.append(message)
            } else {
                messagesSave.append(message)
            }
        }
        if messagesDelete.count > 0 {
            removeMessage(messagesDelete)
        }
        saveMessagesWithotRemoving(messagesSave + allMessages)
    }
    
    public func removeMessage(_ messages: [UDMessage]) {
        guard token.count > 0, messages.count > 0 else {return}
        var allMessages = getMessages()
        for message in messages {
            if let index = allMessages.firstIndex(where: {($0.id == message.id && message.id > 0) || $0.loadingMessageId == message.loadingMessageId}) {
                allMessages.remove(at: index)
            }
        }
        saveMessagesWithotRemoving(allMessages)
    }
    
    public func remove() {
        let allMessages = getMessages()
        if allMessages.isEmpty {
            if urlStorage != nil {
                do {
                    try FileManager.default.removeItem(at: urlStorage!)
                } catch {}
            }
            return
        }
        var messagesDelete = [UDMessage]()
        for message in allMessages {
            if message.statusForms != .sended {
                messagesDelete.append(message)
            }
        }
        if messagesDelete.count > 0 {
            removeMessage(messagesDelete)
        }
    }
    
    private func saveMessagesWithotRemoving(_ messages: [UDMessage]) {
        let encoder = JSONEncoder()
        do {
            if let jsonString = try? String(data: encoder.encode(messages), encoding: .utf8) {
                if urlStorage != nil {
                    try jsonString.write(to: urlStorage!, atomically: true, encoding: .utf8)
                } else if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    urlStorage = documentDirectory.appendingPathComponent(token + "UDStorage.json")
                    try jsonString.write(to: urlStorage!, atomically: true, encoding: .utf8)
                }
            }
        } catch _ {
        }
    }
}
