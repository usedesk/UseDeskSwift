//
//  UseDeskSDKHelp.swift

import Foundation
import SocketIO

class UseDeskSDKHelp {
    class func config_CompanyID(_ companyID: String, chanelId: String, email: String, phone: String?, name: String?, url: String?, countMessagesOnInit: Int, token: String?) -> [SocketData]? {
        
        let payload: [String : Any] = [
            "sdk" : "iOS",
            "type" : "sdk",
            "version" : "3.4.10",
            "message_limit" : countMessagesOnInit,
            "userData" : getUserParameters()
        ] 
        var dic = [
            "type" : "@@server/chat/INIT",
            "payload" : payload,
            "company_id" : chanelId != "" ? "\(companyID)_\(chanelId)" : companyID,
            "url" : url ?? ""
            ] as [String : Any]
        if token != nil {
            if token != "" {
                dic["token"] = token
            }
        }
        
        return [dic]
    }
    
    class func dataClient(_ email: String = "", phone: String = "", name: String = "", note: String = "", token: String = "", additional_id: String? = nil) -> [SocketData]? {
        var dic: [String : Any] = [
            "type"  : "@@server/chat/SET_CLIENT"
        ]
        var payload: [String : Any] = [
            "email"    : email,
            "phone"    : phone,
            "note"     : note
        ]
        if name.count > 0 {
            payload["username"] = name
        }
        if token != "" {
            payload["token"] = token
        }
        if additional_id != nil {
            if additional_id != "" {
                payload["additional_id"] = additional_id
            }
        }
        dic["payload"] = payload
        return [dic]
    }
    
    class func messageText(_ text: String, messageId: String? = nil) -> [SocketData]? {
        
        var message: [String : Any] = [
            "text" : text
        ]
        
        if messageId != nil {
            let payload = [
                "message_id" : messageId!
            ]
            message["payload"] = payload
        }
        
        let dic = [
            "type" : "@@server/chat/SEND_MESSAGE",
            "message" : message
            ] as [String : Any]
        return [dic]
    }
    
    class func feedback(_ fb: Bool, message_id: Int) -> [SocketData]? {
        var data: String
        
        if fb {
            data = "LIKE"
        } else {
            data = "DISLIKE"
        }

        var payload: [String : Any] = [
            "data" : data,
            "type" : "action"
        ]
        if message_id != 0 {
            payload["messageId"] = String(message_id)
        }
        
        let dic = [
            "type" : "@@server/chat/CALLBACK",
            "payload" : payload
            ] as [String : Any]
        return [dic]
    }
    
    class func message(_ text: String?, withFileName fileName: String?, fileType: String?, contentBase64: String?) -> [SocketData]? {
        let file = [
            "name" : fileName ?? "",
            "type" : fileType ?? "",
            "content" : contentBase64 ?? ""
        ]
        
        let message: [String : Any] = [
            "text" : text ?? "",
            "file" : file
            ]
        
        let dic: [String : Any] = [
            "type" : "@@server/chat/SEND_MESSAGE",
            "message" : message
            ]
        
        return [dic]
    }
    
    class func dict(toJson dict: [AnyHashable : Any]?) -> String? {
        var jsonData: Data? = nil
        if let aDict = dict {
            jsonData = try? JSONSerialization.data(withJSONObject: aDict, options: [])
        }
        if jsonData == nil {
            return "{}"
        } else {
            if let aData = jsonData {
                return String(data: aData, encoding: .utf8)
            }
            return nil
        }
    }
    
    private class func getUserParameters() -> [String : Any] {
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.udModelName
        let idDevice = UIDevice.current.identifierForVendor?.uuidString
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

        var userData: [String : Any] = [
            "app_name" : appName,
            "app_version" : appVersion,
            "device" : model,
            "os" : "iOS " + systemVersion
        ]
        
        if let id = idDevice {
            userData["device_id"] = id
        }
        
        return userData
    }
}

public extension UIDevice {
    static let udModelName: String = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }

            func udMapToDevice(identifier: String) -> String {
                switch identifier {
                case "iPod5,1":                                       return "iPod touch (5th generation)"
                case "iPod7,1":                                       return "iPod touch (6th generation)"
                case "iPod9,1":                                       return "iPod touch (7th generation)"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
                case "iPhone4,1":                                     return "iPhone 4s"
                case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
                case "iPhone7,2":                                     return "iPhone 6"
                case "iPhone7,1":                                     return "iPhone 6 Plus"
                case "iPhone8,1":                                     return "iPhone 6s"
                case "iPhone8,2":                                     return "iPhone 6s Plus"
                case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
                case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
                case "iPhone11,2":                                    return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
                case "iPhone11,8":                                    return "iPhone XR"
                case "iPhone12,1":                                    return "iPhone 11"
                case "iPhone12,3":                                    return "iPhone 11 Pro"
                case "iPhone12,5":                                    return "iPhone 11 Pro Max"
                case "iPhone13,1":                                    return "iPhone 12 mini"
                case "iPhone13,2":                                    return "iPhone 12"
                case "iPhone13,3":                                    return "iPhone 12 Pro"
                case "iPhone13,4":                                    return "iPhone 12 Pro Max"
                case "iPhone14,4":                                    return "iPhone 13 mini"
                case "iPhone14,5":                                    return "iPhone 13"
                case "iPhone14,2":                                    return "iPhone 13 Pro"
                case "iPhone14,3":                                    return "iPhone 13 Pro Max"
                case "iPhone14,7":                                    return "iPhone 14"
                case "iPhone14,8":                                    return "iPhone 14 Plus"
                case "iPhone15,2":                                    return "iPhone 14 Pro"
                case "iPhone15,3":                                    return "iPhone 14 Pro Max"
                case "iPhone15,4":                                    return "iPhone 15"
                case "iPhone15,5":                                    return "iPhone 15 Plus"
                case "iPhone16,1":                                    return "iPhone 15 Pro"
                case "iPhone16,2":                                    return "iPhone 15 Pro Max"
                case "iPhone8,4":                                     return "iPhone SE"
                case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
                case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
                case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
                case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
                case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
                case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
                case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
                case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
                case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
                case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
                case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
                case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
                case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
                case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
                case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
                case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
                case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
                case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
                case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
                case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
                case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
                case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
                case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
                case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
                case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
                case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
                case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
                case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
                case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
                case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
                case "AppleTV5,3":                                    return "Apple TV"
                case "AppleTV6,2":                                    return "Apple TV 4K"
                case "AudioAccessory1,1":                             return "HomePod"
                case "AudioAccessory5,1":                             return "HomePod mini"
                case "i386", "x86_64", "arm64":                       return "Simulator \(udMapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                              return identifier
                }
            }

            return udMapToDevice(identifier: identifier)
        }()
}
