//
//  WorkoutAlgorithmBuilder.swift
//  Parkinsons
//
//  Created by SDC-USER on 07/12/25.
//

import Foundation

class WorkoutAlgorithmBuilder {
    static func generateDailyWorkout(from exercises: [Exercise]) -> [Exercise] {
        let unique = Array(exercises.shuffled().prefix(10))
        return unique
    }
}
