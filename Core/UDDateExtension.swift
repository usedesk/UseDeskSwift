//
//  UDDateExtension.swift
//  UseDesk_SDK_Swift
//
//

import Foundation

extension Date {
    var isToday: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        let date1 = dateFormatter.string(from: self)
        let date2 = dateFormatter.string(from: Date())
        if date1 == date2 {
            return true
        } else {
            return false
        }
    }
    
    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    var timeAndDayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
    
    func dateFromHeaderChat(_ usedesk : UseDeskSDK) -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        var locale = Locale.current
        if usedesk.model.locale == UDLocalizeManager().getLocaleFor(localeId: "ru") {
            locale = Locale(identifier: "RU_RU")
        }
        dateFormatter.locale = locale
        dateFormatter.timeZone = TimeZone.current
        var dayString = ""
        if calendar.isDateInYesterday(self) {
            dayString = usedesk.model.stringFor("Yesterday")
        } else if calendar.isDateInToday(self) {
            dayString = usedesk.model.stringFor("Today")
        } else {
            dateFormatter.dateFormat = "d MMMM"
            dayString = dateFormatter.string(from: self)
        }
        return dayString
    }
    
    var dateFormatString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}
