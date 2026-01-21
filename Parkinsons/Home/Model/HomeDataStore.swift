//
//  DataStore.swift
//  TempApp
//
//  Created by SDC-USER on 27/11/25.
//

import Foundation

class HomeDataStore {

    static let shared = HomeDataStore()

    private(set) var dates: [DateModel] = []

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private init() {
        generate7DayCalendar()
    }

    private func generate7DayCalendar() {
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "EEEEE"

        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "d"

        var tempDates: [DateModel] = []
        let today = Date()

        for diff in (-7...7) {
            let day = Calendar.current.date(byAdding: .day, value: diff, to: today)!
            tempDates.append(
                DateModel(
                    date: day,
                    dayString: formatterDay.string(from: day),
                    dateString: formatterDate.string(from: day)
                )
            )
        }

        self.dates = tempDates
    }

  
    
    func getDates() -> [DateModel] {
        return dates
    }
    
}
