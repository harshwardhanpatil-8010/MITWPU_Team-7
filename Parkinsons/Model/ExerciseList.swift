//
//  ExerciseList.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
struct ExerciseList{
    var exerciseName: String
    var exerciseType: String
    var exerciseTime: String
    var exerciseImage: String
    var exerciseStatus: Bool = false
}

var exerciselist: [ExerciseList] = [
    ExerciseList(exerciseName: "March Steps", exerciseType: "Warmup", exerciseTime: "00:60",exerciseImage: ""),
    ExerciseList(exerciseName: "Seated Marching", exerciseType: "Warmup", exerciseTime: "00:60",exerciseImage: ""),
    ExerciseList(exerciseName: "Toe Tap", exerciseType: "Warmup", exerciseTime: "00:60",exerciseImage: ""),
    ExerciseList(exerciseName: "Arm Raise", exerciseType: "Warmup", exerciseTime: "00:60",exerciseImage: ""),
    ExerciseList(exerciseName: "Chin Tuck", exerciseType: "Warmup", exerciseTime: "00:60",exerciseImage: "")
    ]
