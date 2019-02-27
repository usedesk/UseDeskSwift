//
//  UDDir.swift


import Foundation

class UDDir: NSObject {

    class func application() -> String? {
        return Bundle.main.resourcePath
    }
    
    class func application(_ component: String?) -> String? {
        var path = self.application()
        if component != nil {
            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component!).absoluteString
        }
        return path
    }
    
    class func application(_ component1: String?, and component2: String?) -> String? {
        var path = self.application()
        if component1 != nil {
            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component1!).absoluteString
        }
        if component2 != nil {
            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component2!).absoluteString
        }
        return path
    }
    
    // MARK: -
    class func document() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    class func document(_ component: String?) -> String? {
        var path = self.document()
        if component != nil {
            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component!).absoluteString
        }
        self.createIntermediate(path)
        return path
    }

    // MARK: -
//    convenience override init() {
//        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//    }
    
//    class func document(_ component: String?) -> String? {
//        var path = self.init()
//        if component != nil {
//            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component).absoluteString
//        }
//        self.createIntermediate(path)
//        return path
//    }
    
    // MARK: -
//    convenience override init() {
//        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
//    }
//
//    class func cache(_ component: String?) -> String? {
//        var path = self.init()
//        if component != nil {
//            path = URL(fileURLWithPath: path ?? "").appendingPathComponent(component).absoluteString
//        }
//        self.createIntermediate(path)
//        return path
//    }
    
    // MARK: -
    class func createIntermediate(_ path: String?) {
        let directory = URL(fileURLWithPath: path ?? "").deletingLastPathComponent().absoluteString
        if self.exist(directory) == false {
            self.create(directory)
        }
    }
    
    class func create(_ directory: String?) {
        try? FileManager.default.createDirectory(atPath: directory ?? "", withIntermediateDirectories: true, attributes: nil)
    }
    
    class func exist(_ path: String?) -> Bool {
        return FileManager.default.fileExists(atPath: path ?? "")
    }

}
