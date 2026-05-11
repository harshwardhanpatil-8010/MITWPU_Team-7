// MedicationNotificationManager.swift
// Parkinsons
//


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
    static let scheduledTime = "scheduledTime"
    static let isFollowUp    = "isFollowUp"
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


    private let followUpSuffix = "_followup"

    private let followUpDelay: TimeInterval = 15 * 60

    // MARK: - Public API


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


    func requestPermissionAndScheduleAll() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("[MedNotif] Permission error: \(error.localizedDescription)")
            }
            if granted {
                DispatchQueue.main.async {
                    self.rescheduleAll()
                }
            } else {
                print("[MedNotif] Permission denied.")
            }
        }
    }


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


            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            let now = Date()
            let cal = Calendar.current
            

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


                    let comps    = cal.dateComponents([.hour, .minute], from: doseTime)
                    guard let fireDate = cal.date(
                        bySettingHour:   comps.hour ?? 0,
                        minute:          comps.minute ?? 0,
                        second:          0,
                        of:              now
                    ) else { continue }

                    let followDate = fireDate.addingTimeInterval(self.followUpDelay)
                    let status = dose.doseStatus ?? "none"


                    if status == "none" && fireDate > now {
                        groupedDoses[fireDate, default: []].append(PendingDose(
                            doseID: doseID, medID: medID, med: med, dose: dose, fireDate: fireDate, isFollowUp: false
                        ))
                    }
                    

                    if status != "taken" && followDate > now {

                        groupedDoses[followDate, default: []].append(PendingDose(
                            doseID: doseID, medID: medID, med: med, dose: dose, fireDate: followDate, isFollowUp: true
                        ))
                    }
                }
            }
            

            let iso = ISO8601DateFormatter()
            
            for (date, pendingGroup) in groupedDoses {
                let isFollowUpGroup = pendingGroup.first?.isFollowUp ?? false
                
                let content = UNMutableNotificationContent()
                content.categoryIdentifier = isFollowUpGroup ? MedNotifCategory.followUp : MedNotifCategory.onTime
                content.interruptionLevel  = isFollowUpGroup ? .active : .timeSensitive
                content.sound = .default
                

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
                

                let groupIdentifier = iso.string(from: date) + (isFollowUpGroup ? "_followup" : "")
                let request = UNNotificationRequest(identifier: groupIdentifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }

    // MARK: - Cancel a specific dose's notifications (call after logging)


    func cancelNotifications(forDoseID doseID: UUID) {

        rescheduleAll()
    }

    func cancelOnTimeNotification(forDoseID doseID: UUID) {
        rescheduleAll()
    }

    
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
