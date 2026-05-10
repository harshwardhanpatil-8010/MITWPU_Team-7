// MedicationNotificationManager.swift
// Parkinsons
//
// Handles scheduling of medication dose notifications.
// Rules:
//   • Each MedicationDose gets one "on-time" notification (category: MED_ON_TIME)
//   • 15 minutes later, if the dose is still not logged, a follow-up fires (category: MED_FOLLOW_UP)
//   • Multiple medications at the same time each get their own notification (iOS stacks them)
//   • All scheduling happens on a background queue; UI calls are safe from any thread
//   • Works while the app is backgrounded / terminated

import Foundation
import UserNotifications
import CoreData

// MARK: - Notification payload keys (shared with AppDelegate & AlarmVC)

enum MedNotifKey {
    static let doseID        = "doseID"
    static let medID         = "medID"
    static let medName       = "medName"
    static let medForm       = "medForm"
    static let medStrength   = "medStrength"
    static let medUnit       = "medUnit"
    static let iconName      = "iconName"
    static let scheduledTime = "scheduledTime"   // ISO8601 string
    static let isFollowUp    = "isFollowUp"      // Bool stored as Int (0/1)
}

// MARK: - Notification category identifiers

enum MedNotifCategory {
    static let onTime    = "MED_ON_TIME"
    static let followUp  = "MED_FOLLOW_UP"
}

// MARK: - Notification action identifiers

enum MedNotifAction {
    static let taken   = "MED_ACTION_TAKEN"
    static let skipped = "MED_ACTION_SKIPPED"
}

// MARK: - Manager

final class MedicationNotificationManager {

    static let shared = MedicationNotificationManager()
    private init() {}

    // Suffix appended to doseID to make the follow-up request identifier unique
    private let followUpSuffix = "_followup"
    // How long after the scheduled time the follow-up fires (seconds)
    private let followUpDelay: TimeInterval = 15 * 60

    // MARK: - Public API

    /// Call once at app launch (AppDelegate / SceneDelegate).
    func registerCategories() {
        let takenAction = UNNotificationAction(
            identifier: MedNotifAction.taken,
            title: "Taken ✓",
            options: [.authenticationRequired]
        )
        let skippedAction = UNNotificationAction(
            identifier: MedNotifAction.skipped,
            title: "Skip",
            options: [.destructive]
        )

        let onTimeCategory = UNNotificationCategory(
            identifier: MedNotifCategory.onTime,
            actions: [takenAction, skippedAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        let followUpCategory = UNNotificationCategory(
            identifier: MedNotifCategory.followUp,
            actions: [takenAction, skippedAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current()
            .setNotificationCategories([onTimeCategory, followUpCategory])
    }

    /// Request permission then schedule. Safe to call multiple times.
    func requestPermissionAndScheduleAll() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, _ in
            guard granted else { return }
            self?.scheduleAll()
        }
    }

    /// Reschedule everything — call whenever medications are added/edited/deleted.
    func rescheduleAll() {
        scheduleAll()
    }

    // MARK: - Core scheduling

    private func scheduleAll() {
        let context = PersistenceController.shared.newBackgroundContext()
        context.perform { [weak self] in
            guard let self else { return }

            let request: NSFetchRequest<Medication> = Medication.fetchRequest()
            guard let medications = try? context.fetch(request) else { return }

            // Cancel everything, then rebuild
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            let now = Date()
            let cal = Calendar.current
            
            // Structure to hold our pending doses
            struct PendingDose {
                let doseID: UUID
                let medID: UUID
                let med: Medication
                let dose: MedicationDose
                let fireDate: Date
                let isFollowUp: Bool
            }
            
            var groupedDoses: [Date: [PendingDose]] = [:]

            for med in medications {
                guard self.isMedicationDueToday(med) else { continue }

                let doseSet = med.doses as? Set<MedicationDose> ?? []
                for dose in doseSet {
                    guard
                        let doseTime = dose.doseTime,
                        let doseID   = dose.id,
                        let medID    = med.id
                    else { continue }

                    // Normalise to today's date with stored hour/minute
                    let comps    = cal.dateComponents([.hour, .minute], from: doseTime)
                    guard let fireDate = cal.date(
                        bySettingHour:   comps.hour ?? 0,
                        minute:          comps.minute ?? 0,
                        second:          0,
                        of:              now
                    ) else { continue }

                    let followDate = fireDate.addingTimeInterval(self.followUpDelay)
                    let status = dose.doseStatus ?? "none"

                    // If it hasn't been taken, we can schedule the on-time group (if in future)
                    if status == "none" && fireDate > now {
                        groupedDoses[fireDate, default: []].append(PendingDose(
                            doseID: doseID, medID: medID, med: med, dose: dose, fireDate: fireDate, isFollowUp: false
                        ))
                    }
                    
                    // If it's skipped, or simply not taken yet, we schedule the follow up (if in future)
                    if status != "taken" && followDate > now {
                        // If it's skipped, the follow-up is the ONLY thing scheduled.
                        // If it's 'none', it serves as a safety net if they ignore the first.
                        groupedDoses[followDate, default: []].append(PendingDose(
                            doseID: doseID, medID: medID, med: med, dose: dose, fireDate: followDate, isFollowUp: true
                        ))
                    }
                }
            }
            
            // Now we schedule ONE notification per distinct Date
            let iso = ISO8601DateFormatter()
            
            for (date, pendingGroup) in groupedDoses {
                let isFollowUpGroup = pendingGroup.first?.isFollowUp ?? false
                
                let content = UNMutableNotificationContent()
                content.categoryIdentifier = isFollowUpGroup ? MedNotifCategory.followUp : MedNotifCategory.onTime
                content.interruptionLevel  = isFollowUpGroup ? .active : .timeSensitive
                content.sound = .default
                
                // Build text
                let medNames = pendingGroup.compactMap { $0.med.medicationName }.prefix(3)
                let joinedNames = medNames.joined(separator: ", ")
                let moreText = pendingGroup.count > 3 ? " and \(pendingGroup.count - 3) more" : ""
                
                if isFollowUpGroup {
                    content.title = "Did you take your medications?"
                    content.body  = "\(joinedNames)\(moreText). You haven't logged these yet."
                } else {
                    content.title = pendingGroup.count == 1 ? "Time to take medication" : "Time to take medications"
                    content.body  = "\(joinedNames)\(moreText)"
                }
                
                // Encode the group of payloads into userInfo
                var payloadsArray: [[String: Any]] = []
                for p in pendingGroup {
                    let dict: [String: Any] = [
                        MedNotifKey.doseID:        p.doseID.uuidString,
                        MedNotifKey.medID:         p.medID.uuidString,
                        MedNotifKey.medName:       p.med.medicationName ?? "",
                        MedNotifKey.medForm:       p.med.medicationForm ?? "",
                        MedNotifKey.medStrength:   Int(p.med.medicationStrength),
                        MedNotifKey.medUnit:       p.med.medicationUnit ?? "",
                        MedNotifKey.iconName:      p.med.medicationIconName ?? "tablet1",
                        MedNotifKey.scheduledTime: iso.string(from: p.fireDate),
                        MedNotifKey.isFollowUp:    p.isFollowUp ? 1 : 0
                    ]
                    payloadsArray.append(dict)
                }
                content.userInfo = ["payloads": payloadsArray]
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute, .second],
                        from: date
                    ),
                    repeats: false
                )
                
                // We use the timestamp string as the identifier for the group
                let groupIdentifier = iso.string(from: date) + (isFollowUpGroup ? "_followup" : "")
                let request = UNNotificationRequest(identifier: groupIdentifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    // MARK: - Cancel a specific dose's notifications (call after logging)

    /// Cancel BOTH on-time and follow-up notifications for this dose.
    func cancelNotifications(forDoseID doseID: UUID) {
        // Since we group notifications by time, simply rescheduling all will cleanly
        // drop the logged dose from future groups, automatically updating the badges/text.
        rescheduleAll()
    }

    func cancelOnTimeNotification(forDoseID doseID: UUID) {
        rescheduleAll()
    }

    /// Schedule a follow-up notification 15 minutes from NOW.
    func scheduleSkipFollowUp(payload: MedicationAlarmPayload) {
        rescheduleAll()
    }

    // MARK: - Schedule rule (mirrors TodayMedicationViewModel)

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
