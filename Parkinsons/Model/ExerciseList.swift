//
//  ExerciseList.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation

class ExerciseStore {

    static let shared = ExerciseStore()
    private let key = "exercise_store"

    private init() { load() }

    private(set) var exercises: [ExerciseStoreItem] = []

    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ExerciseStoreItem].self, from: data) {
            exercises = decoded
        } else {
            exercises = defaultExercises()
            save()
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func replaceExercises(with items: [ExerciseStoreItem]) {
        self.exercises = items
    }

    private func defaultExercises() -> [ExerciseStoreItem] {
        return [
            ExerciseStoreItem(
                id: UUID(),
                name: "Neck Rolls",
                videoID: "jyOk-2DmVnU",
                category: "stretch",
                reps: 8,
                minReps: 5,
                maxReps: 10,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Shoulder Circles",
                videoID: "9MIFX0w7At8",
                category: "stretch",
                reps: 10,
                minReps: 8,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Squats",
                videoID: "uOljoOvycuo",
                category: "strength",
                reps: 15,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Lunges",
                videoID: "KNWqyKluZgg",
                category: "strength",
                reps: 12,
                minReps: 8,
                maxReps: 15,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
            ExerciseStoreItem(
                id: UUID(),
                name: "Tree Pose",
                videoID: "KNWqyKluZgg",
                category: "balance",
                reps: 10,
                minReps: 10,
                maxReps: 20,
                skipCount: 0,
                isSuppressed: false,
                suppressedUntil: .distantPast
            ),
        ]
    }
}
