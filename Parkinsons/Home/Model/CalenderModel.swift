//
//  CalenderModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//



import Foundation

struct DateModel {
    let date: Date
    let dayString: String
    let dateString: String
}


struct DayModel {
    let date: Date
    var isSelected: Bool = false
    var isDummy: Bool = false
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
}

struct MonthSection {
    let monthName: String
    var days: [DayModel]
}
