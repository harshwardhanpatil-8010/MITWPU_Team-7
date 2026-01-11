//
//  TodayMedicationViewModel.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import Foundation
import UIKit

final class TodayMedicationViewModel {

    private(set) var todayDoses: [TodayDoseItem] = []

    func loadTodayMedications(from medications: [Medication]) {
        todayDoses.removeAll()

        for med in medications {
            guard isMedicationDueToday(med) else { continue }

            for dose in med.doses {
                let item = TodayDoseItem(
                    id: UUID(),
                    medicationID: med.id,
                    medicationName: med.name,
                    medicationForm: med.form,
                    iconName: med.iconName,
                    scheduledTime: normalizeDoseTime(dose.time),
                    logStatus: DoseLogStatus(from: dose.status)
                )
                todayDoses.append(item)
            }
        }

        todayDoses.sort { $0.scheduledTime < $1.scheduledTime }
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
