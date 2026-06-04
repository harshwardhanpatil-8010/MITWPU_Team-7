
import Foundation

enum GamePersistenceService {

    static func saveGame(_ data: SavedGameData) {
        guard let encoded = try? JSONEncoder().encode(data) else {
            print("[GamePersistenceService] ⚠️ Failed to encode SavedGameData.")
            return
        }
        UserDefaults.standard.set(encoded, forKey: PuzzleConstants.savedGameKey)
    }

    static func loadGame() -> SavedGameData? {
        guard let data = UserDefaults.standard.data(forKey: PuzzleConstants.savedGameKey),
              let decoded = try? JSONDecoder().decode(SavedGameData.self, from: data)
        else { return nil }
        return decoded
    }

    static func clearSavedGame() {
        UserDefaults.standard.removeObject(forKey: PuzzleConstants.savedGameKey)
    }

    static var hasSavedGame: Bool {
        UserDefaults.standard.data(forKey: PuzzleConstants.savedGameKey) != nil
    }

    static func saveSoundEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: PuzzleConstants.soundEnabledKey)
    }

    static func loadSoundEnabled() -> Bool {
        guard UserDefaults.standard.object(forKey: PuzzleConstants.soundEnabledKey) != nil else {
            return true
        }
        return UserDefaults.standard.bool(forKey: PuzzleConstants.soundEnabledKey)
    }
}
