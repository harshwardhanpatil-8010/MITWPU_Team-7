//
//  SymptomLog.swift
//  Parkinsons
//
//  Core Data–Optimized (Structure Names Preserved)
//  Acts as the Symptom Data Store
//

import Foundation
import CoreData

// MARK: - Symptom Type

/// Stored as Int16 in Core Data
enum SymptomType: Int16, CaseIterable, Codable {
    case slowedMovement = 0
    case gaitDisturbance
    case tremors
    case facialStiffness
    case bodyStiffness
    case lossOfBalance
    case insomnia

    /// UI-only display name
    var displayName: String {
        switch self {
        case .slowedMovement: return "Slowed Movement"
        case .gaitDisturbance: return "Gait Disturbance"
        case .tremors: return "Tremors"
        case .facialStiffness: return "Facial Stiffness"
        case .bodyStiffness: return "Body Stiffness"
        case .lossOfBalance: return "Loss of Balance"
        case .insomnia: return "Insomnia"
        }
    }
}

// MARK: - Symptom Severity

/// Stored as Int16 in Core Data
enum SymptomSeverity: Int16, Codable, CaseIterable {
    case mild = 0
    case moderate
    case severe
    case notPresent

    var displayName: String {
        switch self {
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        case .notPresent: return "Not Present"
        }
    }
}

// MARK: - Symptom Rating (UI Layer)

struct SymptomRating: Codable, Identifiable {
    let id: UUID
    let name: String
    let iconName: String?
    var selectedIntensity: Intensity?

    enum Intensity: Int16, Codable, CaseIterable {
        case mild = 0
        case moderate
        case severe
        case notPresent

        var severity: SymptomSeverity {
            SymptomSeverity(rawValue: rawValue)!
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String? = nil,
        selectedIntensity: Intensity? = nil
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.selectedIntensity = selectedIntensity
    }
}

// MARK: - Symptom Log Entry (Daily Grouping)

struct SymptomLogEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let ratings: [SymptomRating]

    init(
        id: UUID = UUID(),
        date: Date,
        ratings: [SymptomRating]
    ) {
        self.id = id
        self.date = date
        self.ratings = ratings
    }
}

// MARK: - Symptom Log (Persistence Model)

struct SymptomLog: Codable, Identifiable {
    let id: UUID
    let date: Date
    let symptom: SymptomType
    var severity: SymptomSeverity?
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date,
        symptom: SymptomType,
        severity: SymptomSeverity? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.symptom = symptom
        self.severity = severity
        self.notes = notes
    }
}

// MARK: - Core Data Mapping Helpers

extension SymptomLog {

    /// Core Data → Swift
    init?(managedObject: CDSymptomLog) {
        guard
            let id = managedObject.id,
            let date = managedObject.date,
            let symptom = SymptomType(rawValue: managedObject.symptom),
            let severity = SymptomSeverity(rawValue: managedObject.severity)
        else { return nil }

        self.id = id
        self.date = date
        self.symptom = symptom
        self.severity = severity
        //self.notes = managedObject.notes
    }
}

extension CDSymptomLog {

    /// Swift → Core Data
    func populate(from log: SymptomLog) {
        id = log.id
        date = log.date
        symptom = log.symptom.rawValue
        severity = log.severity?.rawValue ?? SymptomSeverity.notPresent.rawValue
       // notes = log.notes
    }
}

// MARK: - Symptom Log Store (Data Store)

struct SymptomLogStore {

    // MARK: Save

    static func save(
        _ entry: SymptomLogEntry,
        context: NSManagedObjectContext
    ) throws {

        for rating in entry.ratings {

            guard
                let intensity = rating.selectedIntensity,
                let symptom = SymptomType.allCases.first(
                    where: { $0.displayName == rating.name }
                )
            else { continue }

            let log = SymptomLog(
                date: entry.date,
                symptom: symptom,
                severity: intensity.severity,
                notes: nil
            )

            let entity = CDSymptomLog(context: context)
            entity.populate(from: log)
        }

        try context.save()
    }

    // MARK: Fetch

    static func fetchAll(
        context: NSManagedObjectContext
    ) throws -> [SymptomLog] {

        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]

        return try context.fetch(request).compactMap {
            SymptomLog(managedObject: $0)
        }
    }

    static func fetch(
        symptom: SymptomType,
        context: NSManagedObjectContext
    ) throws -> [SymptomLog] {

        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "symptom == %d",
            symptom.rawValue
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]

        return try context.fetch(request).compactMap {
            SymptomLog(managedObject: $0)
        }
    }

    // MARK: Rebuild Daily Entry

    static func buildDailyEntry(
        for date: Date,
        context: NSManagedObjectContext
    ) throws -> SymptomLogEntry {

        let request: NSFetchRequest<CDSymptomLog> = CDSymptomLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date == %@",
            date as NSDate
        )

        let entities = try context.fetch(request)

        let ratings = entities.map {
            SymptomRating(
                name: SymptomType(rawValue: $0.symptom)!.displayName,
                selectedIntensity: SymptomRating.Intensity(
                    rawValue: $0.severity
                )
            )
        }

        return SymptomLogEntry(
            date: date,
            ratings: ratings
        )
    }

    // MARK: Delete

    static func deleteAll(
        context: NSManagedObjectContext
    ) throws {

        let request: NSFetchRequest<NSFetchRequestResult> = CDSymptomLog.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        try context.execute(deleteRequest)
        try context.save()
    }
}
