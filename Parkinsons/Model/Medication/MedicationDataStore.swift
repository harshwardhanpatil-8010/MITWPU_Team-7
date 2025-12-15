import Foundation
import Combine

// MARK: - Central Storage for All Medications
// This class manages adding, editing, deleting, and persisting medication data.
class MedicationDataStore: ObservableObject {

    // Shared singleton instance used across the entire app
    static let shared = MedicationDataStore()

    // Key used when saving medication array to UserDefaults
    private let storageKey = "saved_medications"

    // MARK: - Resolve icon name based on medication form
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

    // MARK: - Published Medications List
    // Whenever medications change → data saves & notification is fired.
    @Published var medications: [Medication] = [] {
        didSet {
            saveToStorage()
            NotificationCenter.default.post(
                name: Notification.Name("MedicationUpdated"),
                object: nil
            )
        }
    }

    // MARK: - Init (loads data from storage)
    private init() {
        loadFromStorage()
    }

    // MARK: - Add Medication
    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }

    // MARK: - Update Medication (replace the whole object)
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
        }
    }

    // MARK: - Delete Medication by ID
    func deleteMedication(_ id: UUID) {
        medications.removeAll { $0.id == id }
    }

    // MARK: - Save to UserDefaults
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(medications) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    // MARK: - Load from UserDefaults
    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Medication].self, from: data) {
            medications = decoded
        }
    }

    // MARK: - Update Medication (property-by-property update)
    // Called when editing an existing medication
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

            // Update main fields
            medications[index].name = newName
            medications[index].form = newForm
            medications[index].schedule = newSchedule
            medications[index].doses = newDoses
            medications[index].unit = newUnit
            medications[index].strength = newStrength

            // Automatically update its icon based on form
            medications[index].iconName = MedicationDataStore.iconForType(newForm)

            saveToStorage()
        }
    }
}
