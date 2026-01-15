//
//  DailyGameManager.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation

class DailyGameManager {
    static let shared = DailyGameManager()
    private let calendar = Calendar.current
    private init() {}

    func level(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    func isCompleted(date: Date) -> Bool {
        UserDefaults.standard.bool(forKey: key(date) + "_completed")
    }

    func markCompleted(date: Date) {
        UserDefaults.standard.set(true, forKey: key(date) + "_completed")
    }

    func isFuture(date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    func isOutsideCurrentMonth(date: Date) -> Bool {
        let now = Date()
        let a = calendar.dateComponents([.year, .month], from: date)
        let b = calendar.dateComponents([.year, .month], from: now)
        return a.year != b.year || a.month != b.month
    }
        // You should use UserDefaults to make this persist after closing the app
    func saveCompletion(date: Date, time: Int) {
        let key = "completionTime_\(date.description)"
        UserDefaults.standard.set(time, forKey: key)
    }
        
    func getCompletionTime(for date: Date) -> Int? {
        let key = "completionTime_\(date.description)"
        let time = UserDefaults.standard.integer(forKey: key)
        return time > 0 ? time : nil
    }

    private func key(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "game_\(c.year!)_\(c.month!)_\(c.day!)"
    }
}
