//
//  ExerciseModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import Foundation

struct ExerciseModel {
    let title: String
    let detail: String
    let progressPercentage: Int
   
    let progressColorHex: String
}
var exerciseData: [ExerciseModel] = [
    ExerciseModel(
        title: "10-Min Workout",
        detail: "Repeat everyday",
        progressPercentage: 67,
        progressColorHex: "0088FF" // Updated
    ),
    ExerciseModel(
        title: "Rhythmic Walking",
        detail: "2-3 times a week",
        progressPercentage: 25,
        progressColorHex: "908FA1" // Updated
    )
]
