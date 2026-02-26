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

    func isCompleted(date: Date) -> Bool {
        let completedDates = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        let dateString = formatDate(date)
        return completedDates.contains(dateString)
    }

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
