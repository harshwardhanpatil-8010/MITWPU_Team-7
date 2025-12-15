import Foundation
import Combine
class MedicationDataStore: ObservableObject {

    static let shared = MedicationDataStore()
    private let storageKey = "saved_medications"
    static func iconForType(_ type: String) -> String {
            switch type.lowercased() {
            case "capsule": return "capsule"
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
        didSet { saveToStorage()
            NotificationCenter.default.post(name: Notification.Name("MedicationUpdated"), object: nil)
        }
    }

    private init() {
        loadFromStorage()
    }

    // MARK: - Add
    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }

    // MARK: - Update
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
        }
    }

    // MARK: - Remove
    func deleteMedication(_ id: UUID) {
        medications.removeAll { $0.id == id }
    }

    // MARK: - Persistence
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


}

