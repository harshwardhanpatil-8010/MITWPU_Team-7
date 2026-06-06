import Foundation

final class TodayMedicationViewModel {

    private(set) var todayDoses: [TodayDoseItem] = []

    func loadTodayMedications(from medications: [Medication], logs: [MedicationDoseLog]) {

        todayDoses.removeAll()

        let todayLogs = logs.filter {
            Calendar.current.isDate($0.doseDay ?? Date(), inSameDayAs: Date())
        }

        for med in medications {

            guard isMedicationDueToday(med) else { continue }

            let doseSet = med.doses as? Set<MedicationDose> ?? []

            for dose in doseSet {

                guard let time = dose.doseTime else { continue }

                // ✅ Check if already logged
                let isLogged = todayLogs.contains { log in
                    log.dose?.id == dose.id
                }

                if isLogged {
                    continue // ❗ THIS is what removes it from Today
                }

                let strength = med.medicationStrength
                var unit = med.medicationUnit ?? ""

                if let dotIndex = unit.firstIndex(of: "•") {
                    unit = String(unit[..<dotIndex]).trimmingCharacters(in: .whitespaces)
                }

                let detailString = strength > 0 ? "\(strength)\(unit)" : unit

                let info = getPeriodAndRange(for: dose)

                let item = TodayDoseItem(
                    id: dose.id ?? UUID(),
                    medicationID: med.id ?? UUID(),
                    medicationName: med.medicationName ?? "",
                    medicationForm: detailString,
                    iconName: med.medicationIconName ?? "tablet",
                    scheduledTime: normalizeDoseTime(info.rangeStart),
                    logStatus: .none,
                    dosePeriod: info.period,
                    rangeStartTime: info.rangeStart,
                    rangeEndTime: info.rangeEnd
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

    func getPeriodAndRange(for dose: MedicationDose) -> (period: String, rangeStart: Date, rangeEnd: Date) {
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
