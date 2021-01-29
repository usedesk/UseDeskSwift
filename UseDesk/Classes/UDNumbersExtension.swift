//
//  UDNumbersExtension.swift
//  Alamofire
//

import UIKit

extension Double {
    
    func timeStringFor(seconds : Int) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.second, .minute, .hour]
      formatter.zeroFormattingBehavior = .pad
      let output = formatter.string(from: TimeInterval(seconds))!
        return output
    }
}

extension Int {
     func countFilesString() -> String {
        var fileString: String = "файл".lowercased()
        if "1".contains("\(self % 10)") {
            fileString = "файл".lowercased()
        }
        if "234".contains("\(self % 10)") {
            fileString = "файла".lowercased()
        }
        if "567890".contains("\(self % 10)") {
            fileString = "файлов".lowercased()
        }
        if 11...14 ~= self % 100 {
            fileString = "файлов".lowercased()
        }
        return "\(self) " + fileString
    }
    
    func timeString() -> String {
        let h = self / 3600
        let m = (self % 3600) / 60
        let s = (self % 3600) % 60
        var string = ""
        if h != 0 {
            if h > 9 {
                string += "\(h):"
            } else {
                string += "0\(h):"
            }
        }
        if m > 9 {
            string += "\(m)"
        } else {
            string += "0\(m)"
        }
        if h == 0 {
            if s > 9 {
                string += ":\(s)"
            } else {
                string += ":0\(s)"
            }
        }
        return string
    }
}
