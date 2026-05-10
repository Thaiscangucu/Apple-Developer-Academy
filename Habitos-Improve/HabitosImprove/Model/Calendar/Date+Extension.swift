//
//  Date+Extension.swift
//  teste
//
//  Created by Thais Cangucu on 23/07/25.
//

import SwiftUI

extension Date {
    func color(count: Int16) -> Color {
        count > 0 ? .verde : .cinza
    }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var statrtOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }
    
    var numbersOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    var sundayBeforeStart: Date {
        let startOfMonthWeekDay = Calendar.current.component(.weekday, from: startOfMonth)
        let numberFromPreviousMonth = startOfMonthWeekDay - 1
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth)!
    }
    
    var calendarDisplayDays: [Date] {
        var days: [Date] = []
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: startOfMonth)
        
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let daysBefore = weekday - 1
        
        guard let startPoint = calendar.date(byAdding: .day, value: -daysBefore, to: firstDayOfMonth) else { return [] }
        
        for dayOffset in 0..<42 {
            if let newDay = calendar.date(byAdding: .day, value: dayOffset, to: startPoint) {
                days.append(newDay)
            }
        }
        return days
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var dayInt: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
