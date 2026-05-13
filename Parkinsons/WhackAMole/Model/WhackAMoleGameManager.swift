import Foundation

final class WhackAMoleGameManager {

    static let shared = WhackAMoleGameManager()

    private let calendar = Calendar.current
    private let storageKey = "CompletedWhackAMoleDates"


    private let dailyDurations = [
        60, 45, 30, 45, 60, 30, 45, 60, 30, 45,
        60, 30, 45, 60, 45, 30, 60, 45, 30, 60,
        45, 30, 60, 45, 30, 60, 45, 30, 45, 60, 45
    ]

    private init() {}

    // MARK: - Daily Challenge Duration

    func gameDuration(for date: Date) -> Int {
        let day = calendar.component(.day, from: date)
        return dailyDurations[(day - 1) % dailyDurations.count]
    }

    func difficultyLabel(for date: Date) -> String {
        switch gameDuration(for: date) {
        case ...30:  return "Hard"
        case ...45:  return "Medium"
        default:     return "Easy"
        }
    }

    // MARK: - Bomb chance scales with difficulty

    func bombChance(for date: Date) -> Double {
        switch gameDuration(for: date) {
        case ...30:  return 0.28
        case ...45:  return 0.22
        default:     return 0.15
        }
    }

    func moleInterval(for date: Date) -> Double {
        switch gameDuration(for: date) {
        case ...30:  return 1.2
        case ...45:  return 1.5
        default:     return 1.8
        }
    }

    // MARK: - Hole count scales with difficulty

    func holeCount(for date: Date) -> Int {
        let day = calendar.component(.day, from: date)
        switch gameDuration(for: date) {
        case ...30:  return 8 + (day % 3)
        case ...45:  return 6 + (day % 3)
        default:     return 5 + (day % 3)      
        }
    }

    // MARK: - Completion Tracking

    func isCompleted(date: Date) -> Bool {
        let dates = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        return dates.contains(formatDate(date))
    }

    func markCompleted(date: Date) {
        var dates = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        let key = formatDate(date)
        if !dates.contains(key) {
            dates.append(key)
            UserDefaults.standard.set(dates, forKey: storageKey)
        }
    }

    func saveScore(date: Date, score: Int) {
        UserDefaults.standard.set(score, forKey: scoreKey(for: date))
    }

    func getScore(for date: Date) -> Int? {
        let s = UserDefaults.standard.integer(forKey: scoreKey(for: date))
        return s > 0 ? s : nil
    }

    func isFuture(date: Date) -> Bool {
        calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    // MARK: - Monthly Stats

    func completedCountThisMonth() -> (completed: Int, total: Int) {
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        guard let first = calendar.date(from: comps) else { return (0, 0) }
        let days = calendar.range(of: .day, in: .month, for: first)!.count

        let count = (0..<days).filter { offset in
            guard let d = calendar.date(byAdding: .day, value: offset, to: first) else { return false }
            return isCompleted(date: calendar.startOfDay(for: d))
        }.count

        return (count, days)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func scoreKey(for date: Date) -> String {
        "whackamole_score_\(formatDate(date))"
    }
}
