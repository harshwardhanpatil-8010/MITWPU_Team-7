//
//  EmojiGameManager.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/01/26.
//

import Foundation

class EmojiGameManager {
    static let shared = EmojiGameManager()
    private let storageKey = "CompletedEmojiDates"

    // Checks if a date is in the list of completed dates
    func isCompleted(date: Date) -> Bool {
        let completedDates = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        let dateString = formatDate(date)
        return completedDates.contains(dateString)
    }

    // Adds a date to the completion list
    func markAsCompleted(date: Date) {
        var completedDates = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        let dateString = formatDate(date)
        if !completedDates.contains(dateString) {
            completedDates.append(dateString)
            UserDefaults.standard.set(completedDates, forKey: storageKey)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
