//
//  UDMineType.swift

import Foundation

class UDMimeType: NSObject {

    func typeString(for data: Data?) -> String {
        let c = [UInt8](data!)

        guard c.count > 0 else {return "image"}
        switch c[0] {
            case 58/*0xff*/:
                return "image"
            case 0x89:
                return "image"
            case 0x47:
                return "image/gif"
            case 0x49:
                return ""
            case 0x4d:
                return "image"
            case 0x25:
                return "application/pdf"
            case 0xd0:
                return "application/vnd"
            case 0x46:
                return "text/plain"
            default:
                return "image"//"application/octet-stream"
        }
    }
}
