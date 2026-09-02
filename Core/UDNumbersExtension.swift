//
//  UDNumbersExtension.swift

import UIKit

extension Double {
    
    func udTimeStringFor(seconds : Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        let output = formatter.string(from: TimeInterval(seconds))!
        return output
    }
    
    func udRounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Int {
    func countFilesString(_ usedesk: UseDeskSDK) -> String {
        var fileString: String = usedesk.model.stringFor("File").lowercased()

        if "1".contains("\(self % 10)") {
            fileString = usedesk.model.stringFor("File").lowercased()
        }
        if "234".contains("\(self % 10)") {
            fileString = usedesk.model.stringFor("File2").lowercased()
        }
        if "567890".contains("\(self % 10)") {
            fileString = usedesk.model.stringFor("File3").lowercased()
        }
        if 11...14 ~= self % 100 {
            fileString = usedesk.model.stringFor("File3").lowercased()
        }
        return "\(self) " + fileString
    }
    
    func timeString() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let seconds = (self % 3600) % 60
        var string = ""
        if hours != 0 {
            if hours > 9 {
                string += "\(hours):"
            } else {
                string += "0\(hours):"
            }
        }
        if minutes > 9 {
            string += "\(minutes)"
        } else {
            string += "0\(minutes)"
        }
        if hours == 0 {
            if seconds > 9 {
                string += ":\(seconds)"
            } else {
                string += ":0\(seconds)"
            }
        }
        return string
    }
}
