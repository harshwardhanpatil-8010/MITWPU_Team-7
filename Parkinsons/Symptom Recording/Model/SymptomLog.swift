//
//  SymptomLog.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 27/12/25.
//

import Foundation

enum SymptomType: String, CaseIterable, Codable {
    case slowedMovement = "Slowed Movement"
    case gaitDisturbance = "Gait Disturbance"
    case tremors = "Tremors"
    case facialStiffness = "Facial Stiffness"
    case bodyStiffness = "Body Stiffness"
    case lossOfBalance = "Loss of Balance"
    case insomnia = "Insomnia"
}

enum SymptomSeverity: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    case notPresent = "Not Present"
}

struct SymptomLog: Codable, Identifiable {
    let id: UUID
    let date: Date
    let symptom: SymptomType

    var severity: SymptomSeverity?
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date,
        symptom: SymptomType,
        severity: SymptomSeverity? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.symptom = symptom
        self.severity = severity
        self.notes = notes
    }
}
