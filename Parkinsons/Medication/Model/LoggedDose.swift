//
//  LoggedDose.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import Foundation

struct DoseLog: Codable, Identifiable {
    let id: UUID 
    let medicationID: UUID //foreign key
    let doseID: UUID //foreign key
    let scheduledTime: Date
    let loggedAt: Date
    var status: DoseStatus
    var day: Date
}

