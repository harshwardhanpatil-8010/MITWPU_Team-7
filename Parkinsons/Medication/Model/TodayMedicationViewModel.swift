import Foundation
import UIKit

final class TodayMedicationViewModel {

    private(set) var todayDoses: [TodayDoseItem] = []

    func loadTodayMedications(from medications: [Medication]) {
        todayDoses.removeAll()

        let todayLogs = DoseLogDataStore.shared.logs
            .filter { $0.day == Date().startOfDay }

        for med in medications {
            guard isMedicationDueToday(med) else { continue }

            for dose in med.doses {

                let alreadyLogged = todayLogs.contains {
                    $0.medicationID == med.id &&
                    Calendar.current.isDate(
                        $0.scheduledTime,
                        equalTo: dose.time,
                        toGranularity: .minute
                    )
                }

                guard !alreadyLogged else { continue }

                let item = TodayDoseItem(
                    id: UUID(),
                    medicationID: med.id,
                    medicationName: med.name,
                    medicationForm: med.form,
                    iconName: med.iconName,
                    scheduledTime: normalizeDoseTime(dose.time),
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
        logs: [DoseLog],
        for day: Date
    ) {
        loggedDoses.removeAll()

        let todayLogs = logs.filter { $0.day == day.startOfDay }

        for log in todayLogs {
            guard let med = medications.first(where: { $0.id == log.medicationID }) else {
                continue
            }

            let item = LoggedDoseItem(
                id: log.id,
                medicationName: med.name,
                medicationForm: med.form,
                loggedTime: log.loggedAt,
                status: log.status,
                iconName: med.iconName
            )

            loggedDoses.append(item)
        }

        loggedDoses.sort { lhs, rhs in
            lhs.loggedTime > rhs.loggedTime
        }
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
        switch med.schedule {
        case .everyday:
            return true
        case .weekly(let days):
            let weekday = Calendar.current.component(.weekday, from: Date())
            return days.contains(weekday)
        case .none:
            return false
        }
    }
}

