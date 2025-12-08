import Foundation
enum DoseStatus { case none, taken, skipped }

struct MedicationDose {
    let id: UUID
    var time: Date
    var status: DoseStatus

    var medication: Medication
}

struct Medication {
    let id: UUID
    var name: String
    var form: String
    var iconName: String?
    var schedule: String        // e.g., "Everyday"
    var doses: [MedicationDose]
}

