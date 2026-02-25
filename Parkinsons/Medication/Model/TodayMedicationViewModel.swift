import Foundation

final class TodayMedicationViewModel {

    private(set) var todayDoses: [TodayDoseItem] = []
    

    // MARK: - Load Today Doses

    func loadTodayMedications(from medications: [Medication]) {

        todayDoses.removeAll()

        for med in medications {

            guard isMedicationDueToday(med) else { continue }

            let doseSet = med.doses as? Set<MedicationDose> ?? []

            for dose in doseSet {

                guard let time = dose.doseTime else { continue }

                // Only show if not already taken
                if dose.doseStatus == "taken" || dose.doseStatus == "skipped" {
                    continue
                }


                let item = TodayDoseItem(
                    id: dose.id ?? UUID(),
                    medicationID: med.id ?? UUID(),
                    medicationName: med.medicationName ?? "",
                    medicationForm: med.medicationForm ?? "",
                    iconName: med.medicationIconName ?? "tablet",
                    scheduledTime: normalizeDoseTime(time),
                    logStatus: .none
                )

                todayDoses.append(item)
            }
        }

        todayDoses.sort { $0.scheduledTime < $1.scheduledTime }
    }

    // MARK: - Load Logged Doses (Core Data Based)

    private(set) var loggedDoses: [LoggedDoseItem] = []

    func loadLoggedDoses(
        medications: [Medication],
        logs: [MedicationDoseLog],
        for day: Date
    ) {
        loggedDoses.removeAll()

        let todayLogs = logs.filter { $0.doseDay == day.startOfDay }

        for log in todayLogs {

            guard let med = log.medication else { continue }

            let item = LoggedDoseItem(
                id: log.id ?? UUID(),
                medicationName: med.medicationName ?? "",
                medicationForm: med.medicationForm ?? "",
                loggedTime: log.doseLoggedAt ?? Date(),
                status: DoseStatus(rawValue: log.doseLogStatus ?? "") ?? .none,
                iconName: med.medicationIconName ?? "pill"
            )

            loggedDoses.append(item)
        }

        loggedDoses.sort { $0.loggedTime > $1.loggedTime }
    }


    // MARK: - Helpers

    private func normalizeDoseTime(_ date: Date) -> Date {
        let cal = Calendar.current
        let comp = cal.dateComponents([.hour, .minute], from: date)

        return cal.date(
            bySettingHour: comp.hour ?? 0,
            minute: comp.minute ?? 0,
            second: 0,
            of: Date()
        )!
    }

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
