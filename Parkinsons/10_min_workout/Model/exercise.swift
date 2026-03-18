
import Foundation

enum ExerciseCategory: String, CaseIterable, Codable {
    case warmup
    case balance
    case aerobic
    case strength
    case cooldown
}

enum ExercisePosition: String, Codable {
    case seated
    case standing
}

enum MedicationEffect {
    case optimal
    case wearingOff
    case offPeriod
}

struct WorkoutExercise: Codable, Identifiable {
    let id: UUID
    let name: String
    var reps: Int
    var duration: Int?
    let videoID: String?
    let category: ExerciseCategory
    let position: ExercisePosition
    let targetJoints: [String]
    let voiceInstruction: String?
 

  
    var timerSeconds: Int {
        switch category {
        case .warmup, .cooldown:
            return duration ?? 40
        default:
            return reps
        }
    }
    
    var thumbnailName: String? {
            guard let videoID else { return nil }
            return "\(videoID)_thumb"
        }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case reps
        case duration
        case videoID
        case category
        case position
        case targetJoints
        case voiceInstruction   
    }
}
