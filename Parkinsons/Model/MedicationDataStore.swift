import Foundation

class MedicationDataStore {

    static let shared = MedicationDataStore()

    private init() {}   // prevents creating multiple DataStores

    // This is your saved medication list
    var medications: [Medication] = []

    // Save a new medication
    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }

    // Update an existing medication
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
        }
    }

    // Remove a medication
    func deleteMedication(_ id: UUID) {
        medications.removeAll { $0.id == id }
    }
}

