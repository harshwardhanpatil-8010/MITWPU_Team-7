import Foundation

final class TodayMedicationViewModel {

    private(set) var todayDoses: [TodayDoseItem] = []
    

    func loadTodayMedications(from medications: [Medication], logs: [MedicationDoseLog]) {

        todayDoses.removeAll()

        let today = Calendar.current.startOfDay(for: Date())

        for med in medications {

            guard isMedicationDueToday(med) else { continue }

            let doseSet = med.doses as? Set<MedicationDose> ?? []

            for dose in doseSet {

                guard let time = dose.doseTime else { continue }

                // ✅ Check if this dose is already logged TODAY
                let isLoggedToday = logs.contains {
                    guard let logDay = $0.doseDay,
                          let scheduled = $0.doseScheduledTime else { return false }

                    return Calendar.current.isDate(logDay, inSameDayAs: today) &&
                           scheduled == time &&
                           $0.medication?.id == med.id
                }

                // ❌ Skip if already taken/skipped today
                if isLoggedToday { continue }

                // --- Your existing logic (unchanged) ---
                let strength = med.medicationStrength
                var unit = med.medicationUnit ?? ""

                if let dotIndex = unit.firstIndex(of: "•") {
                    unit = String(unit[..<dotIndex]).trimmingCharacters(in: .whitespaces)
                }

                let detailString = strength > 0 ? "\(strength)\(unit)" : unit

                let item = TodayDoseItem(
                    id: dose.id ?? UUID(),
                    medicationID: med.id ?? UUID(),
                    medicationName: med.medicationName ?? "",
                    medicationForm: detailString,
                    iconName: med.medicationIconName ?? "tablet",
                    scheduledTime: normalizeDoseTime(time),
                    logStatus: .none
                )

                todayDoses.append(item)
            }
        }

        todayDoses.sort { $0.scheduledTime < $1.scheduledTime }
    }

    private(set) var loggedDoses: [LoggedDoseItem] = []

    func loadLoggedDoses(
        medications: [Medication],
        logs: [MedicationDoseLog],
        for day: Date
    ) {
        loggedDoses.removeAll()

        let todayLogs = logs.filter {
            Calendar.current.isDate($0.doseDay ?? Date(), inSameDayAs: day)
        }

        for log in todayLogs {

            guard let med = log.medication else { continue }

            let strength = med.medicationStrength
            var unit = med.medicationUnit ?? ""
            
            if let dotIndex = unit.firstIndex(of: "•") {
                unit = String(unit[..<dotIndex]).trimmingCharacters(in: .whitespaces)
            }

            let detailString = strength > 0 ? "\(strength)\(unit)" : unit

            let item = LoggedDoseItem(
                id: log.id ?? UUID(),
                medicationName: med.medicationName ?? "",
                medicationForm: detailString,
                loggedTime: log.doseLoggedAt ?? Date(),
                status: DoseStatus(rawValue: log.doseLogStatus ?? "") ?? .none,
                iconName: med.medicationIconName ?? "pill"
            )

            loggedDoses.append(item)
        }

        loggedDoses.sort { $0.loggedTime > $1.loggedTime }
    }


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
