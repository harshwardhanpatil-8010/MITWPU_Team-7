//
//  RhythmicSessionBuilder.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/02/26.
//
import Foundation

struct RhythmicSessionBuilder {

    let startDate: Date
    let endDate: Date

    var steps: Int = 0
    var distanceMeters: Double = 0
    var stepLengthMeters: Double = 0
    var walkingAsymmetry: Double = 0
    var walkingSteadiness: Double = 0
}
