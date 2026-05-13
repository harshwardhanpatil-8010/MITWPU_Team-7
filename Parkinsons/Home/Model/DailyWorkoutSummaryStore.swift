//
//  DailyWorkoutSummaryStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//

import CoreData

class DailyWorkoutSummaryStore {
    static let shared = DailyWorkoutSummaryStore()
    private init() {}
    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }

    private func dayBounds(for date: Date) -> (start: Date, end: Date) {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }

    private func fetchSummaries(for date: Date) -> [DailyWorkoutSummary] {
        let request: NSFetchRequest<DailyWorkoutSummary> = DailyWorkoutSummary.fetchRequest()
        let bounds = dayBounds(for: date)
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            bounds.start as NSDate,
            bounds.end as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        return (try? context.fetch(request)) ?? []
    }

    func saveWorkoutSummary(for date: Date = Date()) {
        let existingSummaries = fetchSummaries(for: date)
        let summary = existingSummaries.first ?? DailyWorkoutSummary(context: context)
        let manager = WorkoutManager.shared
        let startOfDay = Calendar.current.startOfDay(for: date)
        let allExercises = manager.exercises
        let completedIDs = manager.completedToday
        let skippedIDs = manager.skippedToday

        if existingSummaries.count > 1 {
            for duplicate in existingSummaries.dropFirst() {
                context.delete(duplicate)
            }
        }

        let nameByID = Dictionary(uniqueKeysWithValues: allExercises.map { ($0.id, $0.name) })
        let completedNames = completedIDs.compactMap { nameByID[$0] }
        let skippedNames = skippedIDs.compactMap { nameByID[$0] }

        summary.date = startOfDay
        summary.setValue(Int16(allExercises.count), forKey: "totalExercises")
        summary.completedCount = Int16(completedIDs.count)
        summary.skippedCount = Int16(skippedIDs.count)
        summary.setValue(completedIDs.map(\.uuidString) as NSArray, forKey: "completedExerciseIDs")
        summary.setValue(skippedIDs.map(\.uuidString) as NSArray, forKey: "skippedExerciseIDs")
        summary.setValue(completedNames as NSArray, forKey: "completedExerciseNames")
        summary.setValue(skippedNames as NSArray, forKey: "skippedExerciseNames")
        PersistenceController.shared.save()
    }

    func fetchSummary(for date: Date) -> DailyWorkoutSummary? {
        fetchSummaries(for: date).first
    }

    func completedExerciseNames(for date: Date) -> [String] {
        guard let summary = fetchSummary(for: date) else { return [] }
        return summary.value(forKey: "completedExerciseNames") as? [String] ?? []
    }

    func skippedExerciseNames(for date: Date) -> [String] {
        guard let summary = fetchSummary(for: date) else { return [] }
        return summary.value(forKey: "skippedExerciseNames") as? [String] ?? []
    }

    func totalExercises(for date: Date) -> Int {
        guard let summary = fetchSummary(for: date) else { return 0 }
        if let value = summary.value(forKey: "totalExercises") as? Int16 {
            return Int(value)
        }
        if let number = summary.value(forKey: "totalExercises") as? NSNumber {
            return number.intValue
        }
        return 0
    }
}
