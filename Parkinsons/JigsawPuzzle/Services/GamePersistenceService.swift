// MARK: - GamePersistenceService.swift
// Handles saving and loading an in-progress game session via UserDefaults.
// Uses JSON-encoded SavedGameData for reliability and forward compatibility.

import Foundation

enum GamePersistenceService {

    // MARK: - Save

    /// Encodes and stores `data` in UserDefaults under `PuzzleConstants.savedGameKey`.
    static func saveGame(_ data: SavedGameData) {
        guard let encoded = try? JSONEncoder().encode(data) else {
            print("[GamePersistenceService] ⚠️ Failed to encode SavedGameData.")
            return
        }
        UserDefaults.standard.set(encoded, forKey: PuzzleConstants.savedGameKey)
    }

    // MARK: - Load

    /// Decodes and returns a previously saved game, or `nil` if none exists.
    static func loadGame() -> SavedGameData? {
        guard let data = UserDefaults.standard.data(forKey: PuzzleConstants.savedGameKey),
              let decoded = try? JSONDecoder().decode(SavedGameData.self, from: data)
        else { return nil }
        return decoded
    }

    // MARK: - Clear

    /// Removes any saved game from UserDefaults.
    static func clearSavedGame() {
        UserDefaults.standard.removeObject(forKey: PuzzleConstants.savedGameKey)
    }

    // MARK: - Existence check

    /// Returns `true` if a saved game exists in UserDefaults.
    static var hasSavedGame: Bool {
        UserDefaults.standard.data(forKey: PuzzleConstants.savedGameKey) != nil
    }

    // MARK: - Sound preference

    /// Persists sound-enabled toggle.
    static func saveSoundEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: PuzzleConstants.soundEnabledKey)
    }

    /// Loads sound-enabled preference (defaults to `true`).
    static func loadSoundEnabled() -> Bool {
        // If key doesn't exist, `.bool(forKey:)` returns false — default to true.
        guard UserDefaults.standard.object(forKey: PuzzleConstants.soundEnabledKey) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: PuzzleConstants.soundEnabledKey)
    }
}
