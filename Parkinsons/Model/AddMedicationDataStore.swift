//
//  AddMedicationDataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.
//


import Foundation

class AddMedicationDataStore {
    static let shared = AddMedicationDataStore()

    // Already existing:
    var unitText: String?
    var selectedType: String?

    // New for REPEAT:
    var repeatOption: String?

    private init() {}
}
