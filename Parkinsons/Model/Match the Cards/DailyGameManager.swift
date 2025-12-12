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
    private let completedKey = "completedDays"
    private let attemptedkey = "attemptedDays"
    
    private init() {}
    
    func levelForToday() -> Int {
        let day = calendar.component(.day, from: Date())
        return day
    }
    func level(for date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    func isCompleted(date: Date) -> Bool {
        let key = storageKey(for: date)
        UserDefaults.standard.bool(forKey: key + "_completed")
    }
    func markCompleted(date: Date) {
        let key = storageKey(for: date)
        UserDefaults.standard.set(true, forKey: key + "_completed")
    }
    func isAttempted(date: Date) -> Bool {
        let key = storageKey(for: date)
        UserDefaults.standard.bool(forKey: key + "_attempted")
    }
    func markAttempted(date: Date) {
        let key = storageKey(for: date)
        UserDefaults.standard.set(true, forKey: key + "_attempted")
    }
    func isFuture(date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        return date > today
    }
    func storageKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "game_\(components.year!)_\(components.month!)_\(components.day!)"
    }
}
