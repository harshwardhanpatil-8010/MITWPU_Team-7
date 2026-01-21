//
//  AddMedicationDataStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.
//


import Foundation

class AddMedicationDataStore {
    static let shared = AddMedicationDataStore()
    var unitText: String?
    var selectedType: String?
    var repeatOption: String?
    var selectedWeekdayNumbers: [Int] = []
    private init() {}
}

