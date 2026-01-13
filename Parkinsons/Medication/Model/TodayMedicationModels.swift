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

//// MARK: - Dose Log Status
//enum DoseLogStatus {
//    case none        // Not logged yet
//    case taken
//    case skipped
//}

// MARK: - Today Dose Item (single dose instance)


// MARK: - Time Section (e.g. 9 AM, 10 AM)
struct TodayTimeSection {
    let time: Date                  // Used for sorting & display
    var doses: [TodayDoseItem]
}

// MARK: - Logged Section (bottom section)


struct LoggedDoseItem: Identifiable {
    let id: UUID
    let medicationName: String
    let medicationForm: String   // ✅ ADD
    let loggedTime: Date
    let status: DoseLogStatus
    let iconName: String
}




//extension DoseLogStatus {
//    init(from status: DoseStatus) {
//        switch status {
//        case .none:
//            self = .none
//        case .taken:
//            self = .taken
//        case .skipped:
//            self = .skipped
//        }
//    }
//}
