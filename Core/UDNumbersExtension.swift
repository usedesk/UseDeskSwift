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
