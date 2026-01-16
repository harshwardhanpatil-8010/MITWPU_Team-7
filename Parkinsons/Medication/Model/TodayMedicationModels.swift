//
//  TodayMedicationModels.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 11/01/26.
//

import Foundation

struct TodayDoseItem {
    let id: UUID
    let medicationID: UUID
    let medicationName: String
    let medicationForm: String
    let iconName: String
    let scheduledTime: Date
    var logStatus: DoseLogStatus

    var isDue: Bool {
        let now = Date()

        guard Calendar.current.isDateInToday(scheduledTime) else {
            return false
        }

        return scheduledTime <= now && logStatus == .none
    }
}
extension TodayDoseItem {

    var dueState: DueState {
    
        guard logStatus == .none else { return .none }

        let now = Date()
        let diff = now.timeIntervalSince(scheduledTime) // seconds

    
        if diff < 0 {
            return .none
        }

        let hoursLate = diff / 3600

        if hoursLate < 2 {
            return .dueNow
        } else if hoursLate < 6 {
            return .late
        } else {
            return .veryLate
        }
    }
}


struct TodayTimeSection {
    let time: Date
    var doses: [TodayDoseItem]
}

struct LoggedDoseItem: Identifiable {
    let id: UUID
    let medicationName: String
    let medicationForm: String
    let loggedTime: Date
    var status: DoseLogStatus
    let iconName: String
}

