// MedicationNotificationManager.swift
// Parkinsons
//

import Foundation
import UserNotifications
import CoreData

// MARK: - Shared keys

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

enum MedNotifCategory {
    static let onTime   = "MED_ON_TIME"
    static let followUp = "MED_FOLLOW_UP"
}

enum MedNotifAction {
    static let taken   = "MED_ACTION_TAKEN"
    static let skipped = "MED_ACTION_SKIPPED"
}

// MARK: - Manager

final class MedicationNotificationManager {

    static let shared = MedicationNotificationManager()
    private init() {}

    private let followUpDelay: TimeInterval = 15 * 60
    private let iso = ISO8601DateFormatter()

    private func groupID(for date: Date, isFollowUp: Bool) -> String {
        "group_" + iso.string(from: date) + (isFollowUp ? "_followup" : "")
    }

    private func perDoseFollowUpID(for doseID: UUID) -> String {
        doseID.uuidString + "_followup"
    }

    // MARK: - Register categories (call once at launch)

    func registerCategories() {
        let takenAction = UNNotificationAction(
            identifier: MedNotifAction.taken,
            title: "Taken",
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
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error { print("[MedNotif] Permission error: \(error)") }
            guard granted else { print("[MedNotif] Permission denied."); return }
            DispatchQueue.main.async { self.rescheduleAll() }
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

            var onTimeGroups: [Date: [(doseID: UUID, medID: UUID, med: Medication, dose: MedicationDose)]] = [:]
            var followUpGroups: [Date: [(doseID: UUID, medID: UUID, med: Medication, dose: MedicationDose)]] = [:]

            for med in medications {
                guard self.isMedicationDueToday(med) else { continue }

                let doseSet = med.doses as? Set<MedicationDose> ?? []
                for dose in doseSet {
                    guard
                        let doseTime = dose.doseTime,
                        let doseID   = dose.id,
                        let medID    = med.id
                    else { continue }

                    let comps = cal.dateComponents([.hour, .minute], from: doseTime)

                    guard let fireDate = cal.date(
                        bySettingHour: comps.hour ?? 0,
                        minute: comps.minute ?? 0,
                        second: 0,
                        of: now
                    ) else { continue }

                    let followDate = fireDate.addingTimeInterval(self.followUpDelay)
                    let status     = dose.doseStatus ?? "none"

                    if status == "none" && fireDate > now {
                        onTimeGroups[fireDate, default: []].append(
                            (doseID: doseID, medID: medID, med: med, dose: dose)
                        )
                    }

                    if status != "taken" && followDate > now {
                        followUpGroups[followDate, default: []].append(
                            (doseID: doseID, medID: medID, med: med, dose: dose)
                        )
                    }
                }
            }

            for (date, group) in onTimeGroups {
                self.scheduleGroupNotification(
                    group: group, fireDate: date, isFollowUp: false)
            }

            for (date, group) in followUpGroups {
                self.scheduleGroupNotification(
                    group: group, fireDate: date, isFollowUp: true)

            }
        }
    }

    // MARK: - Group notification builder

    private func scheduleGroupNotification(
        group: [(doseID: UUID, medID: UUID, med: Medication, dose: MedicationDose)],
        fireDate: Date,
        isFollowUp: Bool
    ) {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = isFollowUp ? MedNotifCategory.followUp : MedNotifCategory.onTime
        content.interruptionLevel  = isFollowUp ? .active : .timeSensitive
        content.sound              = isFollowUp ? .default : .defaultCritical

        let names    = group.prefix(3).compactMap { $0.med.medicationName }
        let joined   = names.joined(separator: ", ")
        let moreSufx = group.count > 3 ? " +\(group.count - 3) more" : ""

        var periodAndRangeStr = ""
        if let firstDose = group.first?.dose {
            let info = getPeriodAndRange(for: firstDose)
            let fmt = DateFormatter()
            fmt.timeStyle = .short
            periodAndRangeStr = " (\(info.period): \(fmt.string(from: info.rangeStart)) - \(fmt.string(from: info.rangeEnd)))"
        }

        if isFollowUp {
            content.title = (group.count == 1
                ? "Did you take \(joined)?"
                : "Did you take your medications?") + periodAndRangeStr
            content.body  = group.count == 1
                ? "\(group[0].med.medicationStrength)\(group[0].med.medicationUnit ?? "") · \(group[0].med.medicationForm ?? "")"
                : "\(joined)\(moreSufx) – not logged yet"
        } else {
            content.title = (group.count == 1
                ? "Time to take \(joined)"
                : "Time for your medications") + periodAndRangeStr
            content.body  = group.count == 1
                ? "\(group[0].med.medicationStrength)\(group[0].med.medicationUnit ?? "") · \(group[0].med.medicationForm ?? "")"
                : "\(joined)\(moreSufx)"
        }

        let payloadsArray: [[String: Any]] = group.map { item in
            [
                MedNotifKey.doseID: item.doseID.uuidString,
                MedNotifKey.medID: item.medID.uuidString,
                MedNotifKey.medName: item.med.medicationName ?? "",
                MedNotifKey.medForm: item.med.medicationForm ?? "",
                MedNotifKey.medStrength: Int(item.med.medicationStrength),
                MedNotifKey.medUnit: item.med.medicationUnit ?? "",
                MedNotifKey.iconName: item.med.medicationIconName ?? "tablet1",
                MedNotifKey.scheduledTime: iso.string(from: fireDate),
                MedNotifKey.isFollowUp: isFollowUp ? 1 : 0
            ]
        }
        content.userInfo = ["payloads": payloadsArray]

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second], from: fireDate),
            repeats: false
        )

        let identifier = groupID(for: fireDate, isFollowUp: isFollowUp)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        )
    }

    // MARK: - Precise cancel helpers

    func cancelNotifications(forDoseID doseID: UUID) {
        rebuildGroupsExcluding(doseID: doseID, cancelFollowUp: true)

        let perDoseID = perDoseFollowUpID(for: doseID)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [perDoseID])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [perDoseID])

    }

    func cancelOnTimeNotification(forDoseID doseID: UUID) {
        rebuildGroupsExcluding(doseID: doseID, cancelFollowUp: false)
    }

    func scheduleSkipFollowUp(payload: MedicationAlarmPayload) {
        let fireDate = Date().addingTimeInterval(followUpDelay)
        let content  = UNMutableNotificationContent()
        content.title              = "Did you take \(payload.medName)?"
        content.body               = "\(payload.medStrength)\(payload.medUnit) · \(payload.medForm) – you marked this as skipped."
        content.sound              = .default
        content.categoryIdentifier = MedNotifCategory.followUp
        content.interruptionLevel  = .active

        let payloadsArray: [[String: Any]] = [[
            MedNotifKey.doseID: payload.doseID.uuidString,
            MedNotifKey.medID: payload.medID.uuidString,
            MedNotifKey.medName: payload.medName,
            MedNotifKey.medForm: payload.medForm,
            MedNotifKey.medStrength: payload.medStrength,
            MedNotifKey.medUnit: payload.medUnit,
            MedNotifKey.iconName: payload.iconName,
            MedNotifKey.scheduledTime: iso.string(from: payload.scheduledTime),
            MedNotifKey.isFollowUp: 1
        ]]
        content.userInfo = ["payloads": payloadsArray]

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second], from: fireDate),
            repeats: false
        )

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: perDoseFollowUpID(for: payload.doseID),
                content: content, trigger: trigger)
        )
    }

    // MARK: - Group rebuild helper

    private func rebuildGroupsExcluding(doseID: UUID, cancelFollowUp: Bool) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let doseIDStr = doseID.uuidString

            for request in requests {
                guard let payloads = request.content.userInfo["payloads"] as? [[String: Any]]
                else { continue }

                let containsDose = payloads.contains { $0[MedNotifKey.doseID] as? String == doseIDStr }
                guard containsDose else { continue }

                let isFollowUpGroup = request.identifier.hasSuffix("_followup")

                if !cancelFollowUp && isFollowUpGroup { continue }

                UNUserNotificationCenter.current()
                    .removePendingNotificationRequests(withIdentifiers: [request.identifier])
                UNUserNotificationCenter.current()
                    .removeDeliveredNotifications(withIdentifiers: [request.identifier])

                let remaining = payloads.filter { $0[MedNotifKey.doseID] as? String != doseIDStr }
                guard !remaining.isEmpty else { continue }
                let newContent = (request.content.mutableCopy() as! UNMutableNotificationContent)
                newContent.userInfo = ["payloads": remaining]

                let names = remaining.prefix(3).compactMap { $0[MedNotifKey.medName] as? String }
                let joined = names.joined(separator: ", ")
                let more   = remaining.count > 3 ? " +\(remaining.count - 3) more" : ""

                if isFollowUpGroup {
                    newContent.title = remaining.count == 1
                        ? "Did you take \(joined)?"
                        : "Did you take your medications?"
                    newContent.body  = "\(joined)\(more) – not logged yet"
                } else {
                    newContent.title = remaining.count == 1
                        ? "Time to take \(joined)"
                        : "Time for your medications"
                    newContent.body  = "\(joined)\(more)"
                }

                UNUserNotificationCenter.current().add(
                    UNNotificationRequest(
                        identifier: request.identifier,
                        content: newContent,
                        trigger: request.trigger)
                )
            }
        }
    }

    // MARK: - Due-today check

    private func isMedicationDueToday(_ med: Medication) -> Bool {
        let type = med.medicationScheduleType ?? "none"
        let days = med.medicationScheduleDays as? [Int] ?? []
        switch type {
        case "everyday": return true
        case "weekly":
            return days.contains(Calendar.current.component(.weekday, from: Date()))
        default: return false
        }
    }

    private func getPeriodAndRange(for dose: MedicationDose) -> (period: String, rangeStart: Date, rangeEnd: Date) {
        if let period = dose.dosePeriod,
           let start = dose.rangeStartTime,
           let end = dose.rangeEndTime {
            return (period, start, end)
        }

        let date = dose.doseTime ?? Date()
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)

        let period: String
        let startHour: Int
        let endHour: Int
        let endMin: Int

        if hour >= 5 && hour < 12 {
            period = "Morning"
            startHour = 8
            endHour = 11
            endMin = 0
        } else if hour >= 12 && hour < 17 {
            period = "Afternoon"
            startHour = 12
            endHour = 15
            endMin = 0
        } else if hour >= 17 && hour < 21 {
            period = "Evening"
            startHour = 17
            endHour = 20
            endMin = 0
        } else {
            period = "Night"
            startHour = 21
            endHour = 23
            endMin = 59
        }

        let start = cal.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? date
        let end = cal.date(bySettingHour: endHour, minute: endMin, second: 0, of: date) ?? date
        return (period, start, end)
    }
}
