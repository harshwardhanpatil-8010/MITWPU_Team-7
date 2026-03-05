//
//  MedicationDoseLogger.swift
//  Parkinsons
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation
import CoreData

final class MedicationDoseLogger {

    static let shared = MedicationDoseLogger()
    private init() {}

    // MARK: - Public API


    @discardableResult
    func log(
        dose: TodayDoseItem,
        status: DoseStatus,
        medications: [Medication],
        context: NSManagedObjectContext
    ) -> MedicationDoseLog? {

        // 1. Find the Core Data MedicationDose for this item
        guard
            let medication = medications.first(where: { $0.id == dose.medicationID }),
            let doseSet = medication.doses as? Set<MedicationDose>,
            let coreDose = doseSet.first(where: { $0.id == dose.id })
        else {
            return nil
        }

        // 2. Update the original dose status
        coreDose.doseStatus = status.rawValue

        // 3. Check for an existing log for this dose today (duplicate guard)
        let existingLog = fetchExistingLog(for: coreDose, on: Date(), context: context)

        let log: MedicationDoseLog
        if let existing = existingLog {
            // Update existing — no duplicate created
            log = existing
     
        } else {
            // Create new log entry
            log = MedicationDoseLog(context: context)
            log.id = UUID()
            log.doseScheduledTime = dose.scheduledTime
            log.doseDay = Calendar.current.startOfDay(for: Date())
            log.dose = coreDose         // relationship to MedicationDose
            log.medication = medication // relationship to Medication
         
        }

        log.doseLoggedAt = Date()
        log.doseLogStatus = status.rawValue

        PersistenceController.shared.save()
        return log
    }

    // MARK: - Private Helpers

    /// Returns an existing `MedicationDoseLog` for a given `MedicationDose` on a given day, if one exists.
    private func fetchExistingLog(
        for coreDose: MedicationDose,
        on date: Date,
        context: NSManagedObjectContext
    ) -> MedicationDoseLog? {

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let request: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "dose == %@ AND doseDay >= %@ AND doseDay < %@",
            coreDose,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }
}
