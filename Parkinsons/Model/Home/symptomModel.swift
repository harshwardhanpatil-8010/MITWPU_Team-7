//
//  symptomModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.
//

import Foundation

// MARK: - 1. Symptom Rating Model

struct SymptomRating: Codable {
    let name: String
    let iconName: String?
    // Change this line:
    var selectedIntensity: Intensity? = nil
    
    enum Intensity: Int, Codable, CaseIterable {
        case mild = 0
        case moderate = 1
        case severe = 2
        case notPresent = 3
    }
}

struct SymptomLogEntry: Codable {
    let date: Date
    let ratings: [SymptomRating]
}
