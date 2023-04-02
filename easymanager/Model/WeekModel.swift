//
//  WeekModel.swift
//  copiaristorante
//
//  Created by Samuele Segrini on 21/12/22.
//

import Foundation

class WeekModel: ObservableObject {
    
    @Published var currentWeek: [Date] = []
    @Published var currentDay: Date = Date()
    
    init() {
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek(){
        let today = Date()
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekday = week?.start else {
            return
        }
        
        (0...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekday) {
                currentWeek.append(weekday)
            }
        }
    }
    func extractDate(date: Date, format: String)->String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    func isToday(date: Date)-> Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
}
