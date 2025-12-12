import Foundation
import Combine
class MedicationDataStore: ObservableObject {

    static let shared = MedicationDataStore()
    private let storageKey = "saved_medications"

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
}

