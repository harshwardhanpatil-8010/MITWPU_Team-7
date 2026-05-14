

import SwiftUI
import Combine

final class PuzzleViewModel: ObservableObject {

    @Published private(set) var allPieces:      [PuzzlePiece] = []
    @Published private(set) var trayPieces:     [PuzzlePiece] = []
    @Published private(set) var boardSlots:     [Int: Int]    = [:]
    @Published          var placedPositions:    [Int: CGPoint] = [:]
    @Published private(set) var gameState:      GameState     = .notStarted
    @Published private(set) var memorizeProgress: Double      = 1.0
    @Published private(set) var difficulty:     GameDifficulty = .medium
    @Published private(set) var elapsedTime:    TimeInterval  = 0
    @Published private(set) var moveCount:      Int           = 0
    @Published private(set) var sourceImage:    UIImage?      = nil
    @Published private(set) var showCelebration = false
    @Published          var showPreview          = false
    @Published          var soundEnabled         = true
    @Published private(set) var isMemorizing    = false
    @Published private(set) var memorizeLabel   = ""
    @Published private(set) var hasSavedGame    = false

    private(set) var gameDate: Date = Date()

    var onGameFinished: ((Int) -> Void)?

    private var timerCancellable: AnyCancellable?

    init() {
        soundEnabled = GamePersistenceService.loadSoundEnabled()
        refreshSavedGameStatus()
        HapticService.shared.warmUp()
    }


    func startNewGame(difficulty: GameDifficulty, date: Date = Date()) {
        stopTimer()
        GamePersistenceService.clearSavedGame()
        self.difficulty = difficulty
        self.gameDate   = Calendar.current.startOfDay(for: date)   // ← store the game's date
        elapsedTime = 0; moveCount = 0; boardSlots = [:]; placedPositions = [:]
        showCelebration = false; showPreview = false

        let src    = PuzzleGeneratorService.generateSourceImage(difficulty: difficulty, date: date)
        let pieces = PuzzleGeneratorService.generatePieces(difficulty: difficulty, image: src)
        allPieces  = pieces
        trayPieces = []
        sourceImage = src

        isMemorizing     = true
        memorizeProgress = 1.0
        memorizeLabel    = "Memorize the puzzle!"
        gameState        = .paused
        hasSavedGame     = false

        let duration: TimeInterval = 4.0
        let interval: TimeInterval = 0.05

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.memorizeProgress -= interval / duration

            if self.memorizeProgress <= 0 {
                timer.invalidate()
                self.memorizeLabel = "Shuffling…"
                HapticService.shared.shufflePulse()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        self.trayPieces   = PuzzleGeneratorService.shufflePieces(pieces)
                        self.boardSlots   = [:]
                        self.isMemorizing = false
                        self.memorizeLabel = ""
                        self.gameState    = .playing
                    }
                    self.startTimer()
                }
            }
        }
    }


    @discardableResult
    func placePiece(pieceID: Int, at position: CGPoint, boardSize: CGFloat) -> Bool {
        guard gameState == .playing,
              let piece = allPieces.first(where: { $0.id == pieceID })
        else { return false }

        let ps = boardSize / CGFloat(gridSize)
        let targetX   = CGFloat(piece.correctColumn) * ps
        let targetY   = CGFloat(piece.correctRow)    * ps
        let targetPos = CGPoint(x: targetX, y: targetY)

        let dist = hypot(position.x - targetPos.x, position.y - targetPos.y)

        if dist < ps * 0.4 {
            if let trayIdx = trayPieces.firstIndex(where: { $0.id == pieceID }) {
                trayPieces.remove(at: trayIdx)
            }
            boardSlots[piece.correctIndex] = pieceID
            placedPositions[pieceID] = targetPos
            moveCount += 1
            HapticService.shared.correctPlacement()
            saveCurrentProgress()
            checkCompletion()
            return true
        } else {
            HapticService.shared.incorrectPlacement()
            if boardSlots.values.contains(pieceID) {
                boardSlots.removeValue(forKey: piece.correctIndex)
            }
            placedPositions.removeValue(forKey: pieceID)
            if !trayPieces.contains(where: { $0.id == pieceID }) {
                trayPieces.append(piece)
            }
            return false
        }
    }

    func updatePosition(for pieceID: Int, to position: CGPoint) {
        placedPositions[pieceID] = position
    }


    func restartPuzzle()  { startNewGame(difficulty: difficulty, date: gameDate) }

    func returnToHome() {
        stopTimer()
        saveCurrentProgress()
        gameState = .notStarted
        isMemorizing = false
    }

    func togglePreview() {
        showPreview.toggle()
        if showPreview { stopTimer() } else if gameState == .playing { startTimer() }
    }

    func toggleSound() {
        soundEnabled.toggle()
        GamePersistenceService.saveSoundEnabled(soundEnabled)
    }

    func dismissCelebration() {
        showCelebration = false
        gameState = .notStarted
        GamePersistenceService.clearSavedGame()
        hasSavedGame = false
    }

    func refreshSavedGameStatus() { hasSavedGame = GamePersistenceService.hasSavedGame }


    var gridSize: Int { difficulty.gridSize }
    var formattedTime: String { elapsedTime.mmss }
    var placedCount: Int { boardSlots.count }
    var totalPieces: Int { allPieces.count }
    var completionFraction: Double { totalPieces == 0 ? 0 : Double(placedCount) / Double(totalPieces) }
    func piece(for id: Int) -> PuzzlePiece? { allPieces.first { $0.id == id } }


    private func checkCompletion() {
        guard boardSlots.count == allPieces.count else { return }
        stopTimer()
        gameState = .completed
        showCelebration = false
        HapticService.shared.gameComplete()

        PuzzleGameManager.shared.markCompleted(date: gameDate)
        PuzzleGameManager.shared.saveCompletion(date: gameDate, time: Int(elapsedTime))
        GamePersistenceService.clearSavedGame()
        hasSavedGame = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.onGameFinished?(Int(self.elapsedTime))
        }
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self, self.gameState == .playing else { return }
                self.elapsedTime += 1
            }
    }

    private func stopTimer() { timerCancellable?.cancel(); timerCancellable = nil }

    func saveCurrentProgress() {
        guard gameState == .playing else { return }
        GamePersistenceService.saveGame(SavedGameData(
            difficulty: difficulty,
            imageName: "puzzle_emoji",
            pieceOrder: trayPieces.map { $0.id },
            elapsedTime: elapsedTime,
            moveCount: moveCount,
            startedAt: Date(),
            savedAt: Date()
        ))
        hasSavedGame = true
    }
}
