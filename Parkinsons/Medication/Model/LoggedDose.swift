//
//  LoggedDose.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import Foundation
struct DoseLog: Codable, Identifiable {
    let id: UUID
    let medicationID: UUID
    let doseID: UUID        // VERY important
    let scheduledTime: Date // original dose time
    let loggedAt: Date      // when user tapped Taken/Skipped
    let status: DoseStatus  // taken / skipped
    let day: Date           // normalized day (midnight)
}
