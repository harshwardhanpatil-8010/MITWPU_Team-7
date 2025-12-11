//
//  symptomModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 11/12/25.
//

import Foundation

// MARK: - 1. Symptom Rating Model

struct SymptomRating {
    let name: String
    let iconName: String? // For the line icons (Tremor, Slowed Movement, etc.)
    var selectedIntensity: Intensity = .notPresent
    
    enum Intensity: Int, CaseIterable {
        case mild = 0
        case moderate = 1
        case severe = 2
        case notPresent = 3
    }
}

// MARK: - 2. Daily Log Entry Model (MOVED OUTSIDE)

struct SymptomLogEntry {
    let date: Date
    let ratings: [SymptomRating] // The array of symptoms and their intensity
}
