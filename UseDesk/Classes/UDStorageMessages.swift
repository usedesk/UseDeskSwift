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
            } catch _ {
            }
        }
        return []
    }
    
    public func saveMessages(_ messages: [UDMessage]) {
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
    
    public func remove() {
        if urlStorage != nil {
            do {
                try FileManager.default.removeItem(at: urlStorage!)
            } catch {}
        }
    }
}
