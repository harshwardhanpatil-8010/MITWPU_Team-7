// MedicationAlarmScheduler.swift
// Parkinsons


import Foundation
import CoreData

final class MedicationAlarmScheduler {

    static let shared = MedicationAlarmScheduler()
    private init() {}

    private var timer: Timer?


    private var presentedDoseIDs: Set<UUID> = []

    // MARK: - Start / Stop


    func start() {
        stop()


    }



    func stop() {
        timer?.invalidate()
        timer = nil
    }


    func markAsPresented(doseID: UUID) {
        presentedDoseIDs.insert(doseID)
    }


    func resetPresentedDoses() {
        presentedDoseIDs.removeAll()
    }

    // MARK: - Core Logic

    private func checkAndPresentAlarms() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.checkAndPresentAlarms() }
            return
        }

        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        guard let medications = try? context.fetch(request) else { return }

        let now = Date()
        let cal = Calendar.current
        var payloadsToPresent: [MedicationAlarmPayload] = []

        for med in medications {
            guard isMedicationDueToday(med) else { continue }

            let doseSet = med.doses as? Set<MedicationDose> ?? []
            for dose in doseSet {
                guard
                    let doseTime = dose.doseTime,
                    let doseID   = dose.id,
                    let medID    = med.id
                else { continue }


                guard !presentedDoseIDs.contains(doseID) else { continue }


                let status = dose.doseStatus ?? "none"
                guard status != "taken" && status != "skipped" else { continue }


                let comps = cal.dateComponents([.hour, .minute], from: doseTime)
                guard let fireDate = cal.date(
                    bySettingHour:  comps.hour   ?? 0,
                    minute:         comps.minute ?? 0,
                    second:         0,
                    of:             now
                ) else { continue }

                let diff = now.timeIntervalSince(fireDate)
                if diff >= 0 && diff < 90 {
                    let iso = ISO8601DateFormatter()
                    let userInfo: [AnyHashable: Any] = [
                        MedNotifKey.doseID:        doseID.uuidString,
                        MedNotifKey.medID:         medID.uuidString,
                        MedNotifKey.medName:       med.medicationName ?? "Medication",
                        MedNotifKey.medForm:       med.medicationForm ?? "",
                        MedNotifKey.medStrength:   Int(med.medicationStrength),
                        MedNotifKey.medUnit:       med.medicationUnit ?? "",
                        MedNotifKey.iconName:      med.medicationIconName ?? "tablet1",
                        MedNotifKey.scheduledTime: iso.string(from: fireDate)
                    ]

                    if let payload = MedicationAlarmPayload(userInfo: userInfo) {
                        payloadsToPresent.append(payload)
                        presentedDoseIDs.insert(doseID)
                    }
                }
            }
        }

        if !payloadsToPresent.isEmpty {
   
            for payload in payloadsToPresent {
                MedicationNotificationManager.shared.cancelOnTimeNotification(
                    forDoseID: payload.doseID
                )
            }
            MedicationAlarmViewController.present(payloads: payloadsToPresent)
        }
    }

    // MARK: - Schedule Helpers

    private func isMedicationDueToday(_ med: Medication) -> Bool {
        let type = med.medicationScheduleType ?? "none"
        let days = med.medicationScheduleDays as? [Int] ?? []
        switch type {
        case "everyday":
            return true
        case "weekly":
            let weekday = Calendar.current.component(.weekday, from: Date())
            return days.contains(weekday)
        default:
            return false
        }
    }
}
