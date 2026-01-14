import Foundation
import Combine

class MedicationDataStore: ObservableObject {

    static let shared = MedicationDataStore()
    private let storageKey = "saved_medications"

    static func iconForType(_ type: String) -> String {
        switch type.lowercased() {
        case "capsule": return "capsuleM"
        case "tablet": return "tablet"
        case "liquid": return "liquid"
        case "cream": return "cream"
        case "device": return "device"
        case "drops": return "drops"
        case "foam": return "foam"
        case "gel": return "gel"
        case "powder": return "powder"
        case "spray": return "spray"
        default: return "tablet"
        }
    }

    @Published var medications: [Medication] = [] {
        didSet {
            saveToStorage()
        }
    }

    private init() {
        loadFromStorage()
    }

    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }

    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
        }
    }

    func deleteMedication(_ id: UUID) {
        medications.removeAll { $0.id == id }
    }

    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
    }

    func updateMedication(
        originalID: UUID,
        newName: String,
        newForm: String,
        newSchedule: RepeatRule,
        newDoses: [MedicationDose],
        newUnit: String,
        newStrength: Int?
    ) {
        if let index = medications.firstIndex(where: { $0.id == originalID }) {
            medications[index].name = newName
            medications[index].form = newForm
            medications[index].schedule = newSchedule
            medications[index].doses = newDoses
            medications[index].unit = newUnit
            medications[index].strength = newStrength
            medications[index].iconName = MedicationDataStore.iconForType(newForm)
            saveToStorage()
        }
    }

    func updateDoseStatus(
        medicationID: UUID,
        scheduledTime: Date,
        status: DoseStatus
    ) {
        guard let medIndex = medications.firstIndex(where: { $0.id == medicationID }) else {
            return
        }

        if let doseIndex = medications[medIndex].doses.firstIndex(where: {
            Calendar.current.isDate($0.time, equalTo: scheduledTime, toGranularity: .minute)
        }) {
            medications[medIndex].doses[doseIndex].status = status
            saveToStorage()
        }
    }
}

extension MedicationDataStore {

    func updateDoseStatus(
        medicationID: UUID,
        scheduledTime: Date,
        status: DoseLogStatus
    ) {
        guard let medIndex = medications.firstIndex(where: { $0.id == medicationID }) else {
            return
        }

        let doseStatus = DoseStatus(from: status)

        for i in medications[medIndex].doses.indices {
            let doseTime = medications[medIndex].doses[i].time

            if Calendar.current.isDate(doseTime, equalTo: scheduledTime, toGranularity: .minute) {
                medications[medIndex].doses[i].status = doseStatus
                break
            }
        }

        saveToStorage()
    }
}
