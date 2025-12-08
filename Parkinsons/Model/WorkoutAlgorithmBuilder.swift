//
//  WorkoutAlgorithmBuilder.swift
//  Parkinsons
//
//  Created by SDC-USER on 07/12/25.
//

import Foundation

class WorkoutAlgorithmBuilder {
    static func generateDailyWorkout(from exercises: [Exercise]) -> [WorkoutStep] {

           // 1. Shuffle and pick 10 unique exercises
           let unique = Array(exercises.shuffled().prefix(10))

           // 2. Build workout steps + rest periods
           var steps: [WorkoutStep] = []

           for (i, e) in unique.enumerated() {
               // Exercise step
               steps.append(
                   WorkoutStep(
                       title: e.name,
                       youtubeURL: e.videoID,
                       duration: 0,
                       isRest: false
                   )
               )

               // Rest step after each exercise except last
               if i < unique.count - 1 {
                   steps.append(
                       WorkoutStep(
                           title: "Rest",
                           youtubeURL: nil,
                           duration: 30,
                           isRest: true
                       )
                   )
               }
           }

           return steps
       }
}
