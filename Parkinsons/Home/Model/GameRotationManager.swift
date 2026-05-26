//
//  GameRotationManager.swift
//  Parkinsons
//

import Foundation

class GameRotationManager {
    static let shared = GameRotationManager()
    
    private let selectionDateKey = "gameForTodaySelectionDate"
    private let selectedIndexKey = "gameForTodaySelectedIndex"
    private let historyKey = "gameSelectionHistory"
    
    /// Returns the selected game index for today
    func getGameForToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have a selection for today
        if let savedDate = UserDefaults.standard.object(forKey: selectionDateKey) as? Date,
           calendar.isDate(savedDate, inSameDayAs: today),
           let savedIndex = UserDefaults.standard.value(forKey: selectedIndexKey) as? Int {
            return savedIndex
        }
        
        // Otherwise, select a new game for today
        return selectNewGame(for: today)
    }
    
    private func selectNewGame(for today: Date) -> Int {
        // Retrieve history (up to last 6 entries)
        var history = UserDefaults.standard.array(forKey: historyKey) as? [Int] ?? []
        
        let yesterdayIndex = history.first ?? -1
        let candidates = [0, 1, 2].filter { $0 != yesterdayIndex }
        
        var selectedIndex: Int
        
        // We look for candidates that satisfy the rolling 7-day frequency rule.
        // The rule is: in the 7-day window ([candidate] + history), each game (0, 1, 2) must appear at least 2 times.
        // This is only checkable if we have a history of at least 6 days.
        let validCandidates = candidates.filter { candidate in
            let window = [candidate] + history
            if window.count < 7 {
                return true // Always valid if we don't have enough history yet
            }
            // Count occurrences of 0, 1, 2 in the 7-day window
            let counts = [0, 1, 2].map { idx in window.prefix(7).filter { $0 == idx }.count }
            return counts.allSatisfy { $0 >= 2 }
        }
        
        if !validCandidates.isEmpty {
            selectedIndex = validCandidates.randomElement() ?? 0
        } else {
            // Fallback: pick any non-consecutive candidate
            if !candidates.isEmpty {
                selectedIndex = candidates.randomElement() ?? 0
            } else {
                // Absolute fallback if everything is empty or corrupted
                selectedIndex = Int.random(in: 0...2)
            }
        }
        
        // Save today's selection
        UserDefaults.standard.set(today, forKey: selectionDateKey)
        UserDefaults.standard.set(selectedIndex, forKey: selectedIndexKey)
        
        // Update history: insert today's index at the beginning and keep last 6 entries
        history.insert(selectedIndex, at: 0)
        if history.count > 6 {
            history = Array(history.prefix(6))
        }
        UserDefaults.standard.set(history, forKey: historyKey)
        
        return selectedIndex
    }
}
