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
        guard !token.isEmpty else {
            print("Token is empty — cannot load messages")
            return []
        }

        // Create the storage file path if not already set
        if urlStorage == nil {
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                urlStorage = documentDirectory.appendingPathComponent(token + "UDStorage.json")
            } else {
                print("Failed to retrieve document directory path")
                return []
            }
        }

        guard let storageURL = urlStorage else {
            print("Storage URL is not defined")
            return []
        }
        
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            print("Message history file does not exist at path: \(storageURL.path)")
            return []
        }

        do {
            let jsonString = try String(contentsOf: storageURL, encoding: .utf8)
            guard let jsonData = jsonString.data(using: .utf8) else {
                print("Failed to convert string to data")
                return []
            }

            let messages = try JSONDecoder().decode([UDMessage].self, from: jsonData)
            return messages
        } catch {
            print("Error reading or decoding messages: \(error)")
            return []
        }
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

        let filteredMessages = allMessages.filter { existingMessage in
            !messages.contains(where: { removingMessage in
                (removingMessage.id >= 0 && existingMessage.id == removingMessage.id) ||
                existingMessage.loadingMessageId == removingMessage.loadingMessageId
            })
        }

        saveMessagesWithotRemoving(filteredMessages)
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
            // Encode messages to JSON data
            let jsonData = try encoder.encode(messages)
            
            // Convert JSON data to UTF-8 string
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to convert encoded messages to UTF-8 string")
                return
            }
            
            // Ensure urlStorage is set
            if urlStorage == nil {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    urlStorage = documentDirectory.appendingPathComponent(token + "UDStorage.json")
                } else {
                    print("Failed to get document directory for saving messages")
                    return
                }
            }
            
            guard let storageURL = urlStorage else {
                print("Storage URL is not defined — cannot save messages")
                return
            }
            
            // Write JSON string to file
            try jsonString.write(to: storageURL, atomically: true, encoding: .utf8)
            
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
}
