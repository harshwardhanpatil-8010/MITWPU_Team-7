// BreakTheBrickManager.swift
// Parkinsons

import Foundation

final class BreakTheBrickManager {
    static let shared = BreakTheBrickManager()

    private let completionKey = "BreakTheBrick_CompletedDates"
    private let sessionsKey   = "BreakTheBrick_Sessions"

    private init() {}

    // MARK: - Daily Completion

    func isCompleted(date: Date) -> Bool {
        let dateString = formatDate(date)
        let completedDates = UserDefaults.standard.stringArray(forKey: completionKey) ?? []
        return completedDates.contains(dateString)
    }

    func markAsCompleted(date: Date) {
        let dateString = formatDate(date)
        var completedDates = UserDefaults.standard.stringArray(forKey: completionKey) ?? []
        if !completedDates.contains(dateString) {
            completedDates.append(dateString)
            UserDefaults.standard.set(completedDates, forKey: completionKey)
        }

        NotificationCenter.default.post(name: NSNotification.Name("didUpdateGameCompletion"), object: nil)
    }

    // MARK: - Persistence

    func saveSession(date: Date, score: Int, duration: Double, level: String) {
        var sessions = allSessionsRaw()
        let key = formatDate(date)
        sessions[key] = ["score": score, "duration": duration, "level": level] as [String: Any]
        UserDefaults.standard.set(sessions, forKey: sessionsKey)
        markAsCompleted(date: date)
    }

    // MARK: - Session Summaries

    func getSessionSummaries(from startDate: Date, to endDate: Date) -> [(date: Date, score: Int)] {
        let raw = allSessionsRaw()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return raw.compactMap { key, value -> (date: Date, score: Int)? in
            guard let date = formatter.date(from: key),
                  date >= startDate && date <= endDate,
                  let dict = value as? [String: Any],
                  let score = dict["score"] as? Int
            else { return nil }
            return (date: date, score: score)
        }
    }

    // MARK: - Helpers

    private func allSessionsRaw() -> [String: Any] {
        return (UserDefaults.standard.dictionary(forKey: sessionsKey)) ?? [:]
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
