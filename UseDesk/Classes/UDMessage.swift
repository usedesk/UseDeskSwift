//
//  UDMessage.swift

import Foundation
import MapKit

public class UDFile: NSObject {
    @objc public var type = ""
    @objc public var name = ""
    @objc public var content = ""
    @objc public var size = ""
    @objc public var sizeInt: Int = 0
    @objc public var path = ""
    @objc public var typeExtension = ""
    @objc public var duration: Int = 0
    @objc public var picture: UIImage?
    
    var sizeString: String {
        guard self.size == "" else {
            return self.size
        }
        if self.sizeInt != 0 {
            if self.sizeInt >= 1024 {
                var sizeFloat: Float = Float(self.sizeInt)
                sizeFloat = sizeFloat / 1024
                if sizeFloat >= 1024 {
                    sizeFloat = sizeFloat / 1024
                    if sizeFloat >= 1024 {
                        sizeFloat = sizeFloat / 1024
                        return "\((rounded(sizeFloat, toPlaces:2))) ГБ"
                    } else {
                        return "\((rounded(sizeFloat, toPlaces: 2))) МБ"
                    }
                } else {
                    return "\((rounded(sizeFloat, toPlaces:2))) КБ"
                }
            } else {
                return "\(self.sizeInt) Б"
            }
        } else {
            return ""
        }
    }
    
    func rounded(_ value: Float, toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (value * divisor).rounded() / divisor
    }
}

enum TypeSenderMessage: Int {
    case operator_to_client = 1
    case client_to_operator = 2
    case client_to_bot = 3
    case bot_to_client = 4
    case service = 0
}

public class UDMessage: NSObject {
    // MARK: - Properties
    @objc public var type: Int = 0
    @objc public var typeSenderMessageString = ""
    @objc public var incoming = false
    @objc public var outgoing = false
    @objc public var feedbackActionInt: Int = -1
    @objc public var text = ""
    @objc public var buttons = [UDMessageButton]()
    @objc public var date: Date?
    @objc public var status: Int = 0
    @objc public var chat: Int = 0
    @objc public var messageId: Int = 0
    @objc public var ticket_id: Int = 0
    @objc public var createdAt = ""
    @objc public var name = ""
    @objc public var operatorId: Int = 0
    @objc public var operatorName = ""
    @objc public var avatar = ""
    @objc public var file = UDFile()
    
    var feedbackAction: Bool? {
        switch feedbackActionInt {
        case 0:
            return false
        case 1:
            return true
        default:
            return nil
        }
    }
    
    var typeSenderMessage: TypeSenderMessage {
        switch typeSenderMessageString {
        case "operator_to_client":
            return .operator_to_client
        case "client_to_operator":
            return .client_to_operator
        case "client_to_bot":
            return .client_to_bot
        case "bot_to_client":
            return .bot_to_client
        default:
            return .service
        }
    }
    
    
    // MARK: - Initialization methods
    
    init(text: String?, incoming: Bool) {
        super.init()
        
        type = RC_TYPE_TEXT
        
        self.incoming = incoming
        outgoing = !incoming
        
        self.text = text ?? ""
    }
}
