
import Foundation

final class DailyGameManager {

    static let shared = DailyGameManager()

    private let calendar = Calendar.current

    private init() {}

    func level(for date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    func isCompleted(date: Date) -> Bool {
        UserDefaults.standard.bool(forKey: completionKey(for: date))
    }

    func markCompleted(date: Date) {
        UserDefaults.standard.set(true, forKey: completionKey(for: date))
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

    func saveCompletion(date: Date, time: Int) {
        UserDefaults.standard.set(time, forKey: timeKey(for: date))
    }

    func getCompletionTime(for date: Date) -> Int? {
        let time = UserDefaults.standard.integer(forKey: timeKey(for: date))
        return time > 0 ? time : nil
    }

    private func completionKey(for date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "game_\(c.year!)_\(c.month!)_\(c.day!)_completed"
    }

    private func timeKey(for date: Date) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return "game_\(c.year!)_\(c.month!)_\(c.day!)_time"
    }
}
