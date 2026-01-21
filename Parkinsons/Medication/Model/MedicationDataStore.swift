import Foundation
import Combine

class MedicationDataStore: ObservableObject {

    static let shared = MedicationDataStore()
    private let storageKey = "saved_medications"

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
            medications[index].iconName = UnitAndType.icon(for: newForm)
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

