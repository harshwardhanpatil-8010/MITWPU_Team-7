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
    let doseID: UUID
    let scheduledTime: Date
    let loggedAt: Date
    var status: DoseStatus
    let day: Date
}

