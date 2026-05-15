import Foundation
import CoreData

final class SymptomLogManager {

    static let shared = SymptomLogManager()

    private let context: NSManagedObjectContext

    private init() {
        self.context = PersistenceController.shared.container.viewContext
    }


    func saveLogEntry(_ entry: SymptomLogEntry) {

        deleteLogs(for: entry.date)

        for rating in entry.ratings {

            guard let intensity = rating.selectedIntensity,
                  let symptomType = SymptomType.allCases.first(where: {
                      $0.displayName == rating.name
                  }) else { continue }

            let cdLog = CDSymptomLog(context: context)
            cdLog.id = UUID()
            cdLog.date = entry.date
            cdLog.symptom = symptomType.rawValue
            cdLog.severity = intensity.rawValue
            cdLog.notes = nil
        }

        saveContext()
    }

    func getLogEntry(for date: Date) -> SymptomLogEntry? {

        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay(date) as NSDate,
            startOfNextDay(date) as NSDate
        )

        do {
            let results = try context.fetch(request)
            guard !results.isEmpty else { return nil }

            let ratings = results.compactMap { cd -> SymptomRating? in
                guard let symptom = SymptomType(rawValue: cd.symptom),
                      let severity = SymptomSeverity(rawValue: cd.severity)
                else { return nil }

                return SymptomRating(
                    name: symptom.displayName,
                    iconName: symptom.iconName,
                    selectedIntensity: SymptomRating.Intensity(rawValue: severity.rawValue)
                )
            }

            return SymptomLogEntry(date: date, ratings: ratings)

        } catch {
            print(" Fetch error:", error)
            return nil
        }
    }


    private func deleteLogs(for date: Date) {
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay(date) as NSDate,
            startOfNextDay(date) as NSDate
        )

        if let results = try? context.fetch(request) {
            results.forEach { context.delete($0) }
        }
    }


    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("❌ Core Data save failed:", error)
        }
    }

    func fetchLogs(from startDate: Date, to endDate: Date) -> [SymptomLogEntry] {
        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            startOfDay(startDate) as NSDate,
            endDate as NSDate
        )
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            let results = try context.fetch(request)
            
            // Group by date
            let grouped = Dictionary(grouping: results) { cd -> Date in
                return startOfDay(cd.date ?? Date())
            }
            
            return grouped.map { (date, logs) in
                let ratings = logs.compactMap { cd -> SymptomRating? in
                    guard let symptom = SymptomType(rawValue: cd.symptom),
                          let severity = SymptomSeverity(rawValue: cd.severity)
                    else { return nil }

                    return SymptomRating(
                        name: symptom.displayName,
                        iconName: symptom.iconName,
                        selectedIntensity: SymptomRating.Intensity(rawValue: severity.rawValue)
                    )
                }
                return SymptomLogEntry(date: date, ratings: ratings)
            }.sorted { $0.date < $1.date }

        } catch {
            print("Fetch error:", error)
            return []
        }
    }

    private func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func startOfNextDay(_ date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(date))!
    }
}
