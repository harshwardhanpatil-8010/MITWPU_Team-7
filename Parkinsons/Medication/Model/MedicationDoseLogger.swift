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
    @discardableResult
    func log(
        dose: TodayDoseItem,
        status: DoseStatus,
        medications: [Medication],
        context: NSManagedObjectContext
    ) -> MedicationDoseLog? {

        guard
            let medication = medications.first(where: { $0.id == dose.medicationID }),
            let doseSet = medication.doses as? Set<MedicationDose>,
            let coreDose = doseSet.first(where: { $0.id == dose.id })
        else {
            return nil
        }

        coreDose.doseStatus = status.rawValue

        let existingLog = fetchExistingLog(for: coreDose, on: Date(), context: context)

        let log: MedicationDoseLog
        if let existing = existingLog {
            log = existing

        } else {
            log = MedicationDoseLog(context: context)
            log.id = UUID()
            log.doseScheduledTime = dose.scheduledTime
            log.doseDay = Calendar.current.startOfDay(for: Date())
            log.dose = coreDose
            log.medication = medication

        }

        log.doseLoggedAt = Date()
        log.doseLogStatus = status.rawValue

        PersistenceController.shared.save()
        return log
    }

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
