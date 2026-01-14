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
    let status: DoseLogStatus
    let iconName: String
}
