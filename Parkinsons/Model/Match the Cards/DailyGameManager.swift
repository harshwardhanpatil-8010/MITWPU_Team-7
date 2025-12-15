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
    
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        //Remove the below function when in production this is only for testing
    
    //Also remove this function calling from sceneDelegate
    
    func clearAllGameData() {
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("game_") {
            defaults.removeObject(forKey: key)
        }
    }
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    func level(for date: Date) -> Int {
        let day = calendar.component(.day, from: date)
        return min(max(day, 1), 30)
    }
    func isCompleted(date: Date) -> Bool {
        UserDefaults.standard.bool(forKey: key(date) + "_completed")
    }
    func markCompleted(date: Date) {
        UserDefaults.standard.set(true, forKey: key(date) + "_completed")
    }
    func isAttempted(date: Date) -> Bool {
        UserDefaults.standard.bool(forKey: key(date) + "_attempted")
    }
    func markAttempted(date: Date) {
        UserDefaults.standard.set(true, forKey: key(date) + "_attempted")
        
    }
    func isFuture(date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }
    func isOutsideCurrentMonth(date: Date) -> Bool {
        let now = Date()
        let c1 = calendar.dateComponents([.year, .month], from: date)
        let c2 = calendar.dateComponents([.year, .month], from: now)
        
        return c1.year != c2.year || c1.month != c2.month
        
    }
   private func key(_ date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
       return "game_\(c.year!)_\(c.month!)_\(c.day!)"
    }
}
