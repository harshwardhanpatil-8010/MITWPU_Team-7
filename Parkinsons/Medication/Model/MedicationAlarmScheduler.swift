// MedicationAlarmScheduler.swift
// Parkinsons
//
// Runs an in-app timer while the app is in the foreground.
// When a medication dose time arrives, it automatically presents
// the full-screen alarm VC — no notification tap required.
// This gives the native "alarm clock" experience.

import Foundation
import CoreData

final class MedicationAlarmScheduler {

    static let shared = MedicationAlarmScheduler()
    private init() {}

    private var timer: Timer?

    /// Dose IDs we've already shown the alarm for this session,
    /// so we don't re-present after the user has already acted.
    private var presentedDoseIDs: Set<UUID> = []

    // MARK: - Start / Stop

    /// Call when app becomes active (sceneDidBecomeActive).
    /// Checks immediately, then every 15 seconds.
    func start() {
        stop()
        // Fire after a short delay to ensure the app's UI is fully loaded.
        // Presenting a VC immediately upon app launch can cause a black screen.
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.checkAndPresentAlarms()
        }
        timer = Timer.scheduledTimer(
            withTimeInterval: 15,
            repeats: true
        ) { [weak self] _ in
            self?.checkAndPresentAlarms()
        }
        */
    }


    /// Call when app resigns active (sceneWillResignActive).
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Mark a dose as already presented so the timer won't re-show it.
    func markAsPresented(doseID: UUID) {
        presentedDoseIDs.insert(doseID)
    }

    /// Reset at start of day or when medications change.
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

                // Already shown this alarm in this session?
                guard !presentedDoseIDs.contains(doseID) else { continue }

                // Already logged?
                let status = dose.doseStatus ?? "none"
                guard status != "taken" && status != "skipped" else { continue }

                // Normalise the stored hour/minute to today's date
                let comps = cal.dateComponents([.hour, .minute], from: doseTime)
                guard let fireDate = cal.date(
                    bySettingHour:  comps.hour   ?? 0,
                    minute:         comps.minute ?? 0,
                    second:         0,
                    of:             now
                ) else { continue }

                // Is it time? (0 to 90 seconds after scheduled time)
                // The 90-second window ensures we catch it even if the
                // 15-second timer tick lands slightly after the minute mark.
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
            // Cancel the on-time system notifications for these doses
            // (we're showing the alarm ourselves)
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
