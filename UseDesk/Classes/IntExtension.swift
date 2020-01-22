//
//  IntExtension.swift
//  Alamofire
//

import UIKit

extension Double {
    
    func timeStringFor(seconds : Int) -> String
    {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.second, .minute, .hour]
      formatter.zeroFormattingBehavior = .pad
      let output = formatter.string(from: TimeInterval(seconds))!
        return output
     // return self < 3600 ? output.substring(from: output.range(of: ":")!.upperBound) : output
    }
    
//    static func secondsToTimeString() -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
//        formatter.unitsStyle = .positional
//        guard let formattedString = formatter.string(from: self) else { return "" }
//        return formattedString
//    }
    
}
