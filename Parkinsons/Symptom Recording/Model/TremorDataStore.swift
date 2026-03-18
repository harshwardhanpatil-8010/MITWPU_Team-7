import Foundation
import CoreData
struct TremorSample: Codable {
    let date: Date
    let frequencyHz: Double
    let isSteady: Bool
    init(date: Date, frequencyHz: Double) {
        self.date        = date
        self.frequencyHz = frequencyHz
        self.isSteady    = false
    }
    static func steady(date: Date) -> TremorSample {
        TremorSample(date: date, frequencyHz: 0.0, isSteady: true)
    }
    init(date: Date, frequencyHz: Double, isSteady: Bool) {
        self.date        = date
        self.frequencyHz = frequencyHz
        self.isSteady    = isSteady
    }
}
final class TremorDataStore {

    static let shared = TremorDataStore()
    private init() {}

    private var context: NSManagedObjectContext {
        PersistenceController.shared.viewContext
    }

    func save(result: TremorMotionManager.TremorResult, date: Date = Date()) {
        switch result {
        case .steady:
            saveInternal(TremorSample.steady(date: date), dedupInterval: 300)
        case .tremor(let hz):
            saveInternal(TremorSample(date: date, frequencyHz: hz), dedupInterval: 60)
        }
    }

    func save(_ sample: TremorSample) {
        saveInternal(sample, dedupInterval: 60)
    }

    private func saveInternal(_ sample: TremorSample, dedupInterval: TimeInterval) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Tremor")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1

        if let last = try? context.fetch(request).first,
           let lastDate = last.value(forKey: "date") as? Date,
           abs(lastDate.timeIntervalSince(sample.date)) < dedupInterval {
            return
        }

        let e = NSEntityDescription.insertNewObject(forEntityName: "Tremor", into: context)
        e.setValue(UUID(),             forKey: "id")
        e.setValue(sample.date,        forKey: "date")
        e.setValue(sample.frequencyHz, forKey: "frequencyHz")

        if e.entity.attributesByName["isSteady"] != nil {
            e.setValue(sample.isSteady, forKey: "isSteady")
        }

        PersistenceController.shared.save(context)
    }


    func fetchAll() -> [TremorSample] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "Tremor")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(req))?.compactMap { map($0) } ?? []
    }

    func fetchSamples(for date: Date) -> [TremorSample] {
        let cal   = Calendar.current
        let start = cal.startOfDay(for: date)
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        return fetchSamples(from: start, to: end)
    }


    func fetchSamples(for range: TremorRange, referenceDate: Date) -> [TremorSample] {
        let (start, end) = dateRange(for: range, referenceDate: referenceDate)
        return fetchSamples(from: start, to: end)
    }

    private func fetchSamples(from start: Date, to end: Date) -> [TremorSample] {
        let req = NSFetchRequest<NSManagedObject>(entityName: "Tremor")
        req.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as CVarArg, end as CVarArg)
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(req))?.compactMap { map($0) } ?? []
    }

    private func map(_ obj: NSManagedObject) -> TremorSample? {
        guard
            let date = obj.value(forKey: "date")        as? Date,
            let hz   = obj.value(forKey: "frequencyHz") as? Double
        else { return nil }

        let isSteady: Bool
        if obj.entity.attributesByName["isSteady"] != nil {
            isSteady = obj.value(forKey: "isSteady") as? Bool ?? false
        } else {
            isSteady = false
        }

        return TremorSample(date: date, frequencyHz: hz, isSteady: isSteady)
    }

    private func dateRange(for range: TremorRange, referenceDate: Date) -> (Date, Date) {
        let cal = Calendar.current
        switch range {
        case .day:
            let s = cal.startOfDay(for: referenceDate)
            return (s, cal.date(byAdding: .day, value: 1, to: s)!)
        case .week:
            let e = cal.date(byAdding: .day, value: 1, to: referenceDate)!
            return (cal.date(byAdding: .day, value: -6, to: e)!, e)
        case .month:
            let s = cal.date(from: cal.dateComponents([.year, .month], from: referenceDate))!
            return (s, cal.date(byAdding: .month, value: 1, to: s)!)
        case .sixMonth:
            let e = cal.date(byAdding: .day, value: 1, to: referenceDate)!
            return (cal.date(byAdding: .month, value: -6, to: e)!, e)
        case .year:
            let s = cal.date(from: cal.dateComponents([.year], from: referenceDate))!
            return (s, cal.date(byAdding: .year, value: 1, to: s)!)
        }
    }
}

extension TremorDataStore {
    func migrateFromUserDefaultsIfNeeded() {
        let key = "tremor_core_data_migrated"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        defer { UserDefaults.standard.set(true, forKey: key) }

        guard
            let data = UserDefaults.standard.data(forKey: "tremor_samples"),
            let old  = try? JSONDecoder().decode([TremorSample].self, from: data),
            !old.isEmpty
        else { return }

        let bg = PersistenceController.shared.newBackgroundContext()
        bg.perform {
            for s in old {
                let e = NSEntityDescription.insertNewObject(forEntityName: "Tremor", into: bg)
                e.setValue(UUID(),          forKey: "id")
                e.setValue(s.date,          forKey: "date")
                e.setValue(s.frequencyHz,   forKey: "frequencyHz")
                if e.entity.attributesByName["isSteady"] != nil {
                    e.setValue(s.isSteady,  forKey: "isSteady")
                }
            }
            PersistenceController.shared.save(bg)
            DispatchQueue.main.async {
                UserDefaults.standard.removeObject(forKey: "tremor_samples")
                print("✅ Migrated \(old.count) samples to Core Data")
            }
        }
    }
}
