//
//  onboardingFeatureData.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit
struct Feature {
    let name: String
    let description: String
    let image: UIImage
}
var features: [Feature] = [
    Feature(name: "Guided Exercises", description: "Follow simple exercises to improve movement, balance, and flexibility—at your own pace.", image: UIImage(named: "feature1")!),
    Feature(name: "Therapeutic Games", description: "Engage your mind and body with fun, interactive games designed to improve coordination, focus, and reaction time.", image: UIImage(named: "feature2")!),
    Feature(name: "Symptom Log", description: "Easily track your daily symptoms, monitoring your progress ", image: UIImage(named: "feature3")!),
    Feature(name: "Medication Reminders", description: "Medication Reminders help you take your medicines on time, every time.", image: UIImage(named: "feature4")!)
]

