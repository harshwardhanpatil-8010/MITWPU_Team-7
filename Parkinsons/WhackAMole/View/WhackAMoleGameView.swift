import SwiftUI
import Combine

// MARK: - Data Models

struct HoleState: Identifiable {
    let id: Int
    var isActive = false
    var isBomb = false
    var wasWhacked = false
}

struct ScorePopup: Identifiable {
    let id = UUID()
    let holeIndex: Int
    let text: String
}

enum WAMGameState { case ready, playing, bombHit, timeUp }

// MARK: - View Model

class WhackAMoleViewModel: ObservableObject {
    @Published var holes: [HoleState]
    @Published var score = 0
    @Published var timeRemaining: Int
    @Published var gameState: WAMGameState = .ready
    @Published var hammerHoleIndex: Int?
    @Published var popups: [ScorePopup] = []

    let totalTime: Int
    let bombChance: Double
    let moleInterval: Double
    let holeCount: Int

    private var countdownTimer: AnyCancellable?
    private var moleTimers: [Int: DispatchWorkItem] = [:]

    init(duration: Int, bombChance: Double, moleInterval: Double, holeCount: Int) {
        self.totalTime = duration
        self.timeRemaining = duration
        self.bombChance = bombChance
        self.moleInterval = moleInterval
        self.holeCount = holeCount
        self.holes = (0..<holeCount).map { HoleState(id: $0) }
    }

    func startGame() {
        gameState = .playing
        score = 0
        timeRemaining = totalTime
        holes = (0..<holeCount).map { HoleState(id: $0) }
        moleTimers.removeAll()
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
        scheduleNextMole()
    }

    private func tick() {
        guard gameState == .playing else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 { endGame(bomb: false) }
    }

    private func scheduleNextMole() {
        guard gameState == .playing else { return }
        let jitter = Double.random(in: -0.2...0.3)
        let delay = max(0.8, moleInterval + jitter)
        let work = DispatchWorkItem { [weak self] in self?.spawnMole() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func spawnMole() {
        guard gameState == .playing else { return }
        let empty = holes.indices.filter { !holes[$0].isActive }
        guard let idx = empty.randomElement() else { scheduleNextMole(); return }
        let isBomb = Double.random(in: 0...1) < bombChance

        // Cancel any pending hide for this hole
        moleTimers[idx]?.cancel()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            holes[idx].isActive = true
            holes[idx].isBomb = isBomb
            holes[idx].wasWhacked = false
        }

        // Every mole stays exactly 2 seconds
        let hideWork = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard self.holes[idx].isActive, !self.holes[idx].wasWhacked else { return }
            withAnimation(.easeIn(duration: 0.3)) {
                self.holes[idx].isActive = false
                self.holes[idx].isBomb = false
            }
        }
        moleTimers[idx] = hideWork
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: hideWork)

        scheduleNextMole()
    }

    func whackHole(_ index: Int) {
        guard gameState == .playing, holes[index].isActive, !holes[index].wasWhacked else { return }
        // Cancel auto-hide
        moleTimers[index]?.cancel()

        if holes[index].isBomb {
            holes[index].wasWhacked = true
            endGame(bomb: true)
            return
        }
        score += 10
        holes[index].wasWhacked = true
        hammerHoleIndex = index
        let popup = ScorePopup(holeIndex: index, text: "+10")
        popups.append(popup)
        withAnimation(.easeIn(duration: 0.15)) {
            holes[index].isActive = false
            holes[index].isBomb = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.hammerHoleIndex = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.popups.removeAll { $0.id == popup.id }
        }
    }

    private func endGame(bomb: Bool) {
        gameState = bomb ? .bombHit : .timeUp
        countdownTimer?.cancel()
        moleTimers.values.forEach { $0.cancel() }
        moleTimers.removeAll()
    }

    func cleanup() {
        countdownTimer?.cancel()
        moleTimers.values.forEach { $0.cancel() }
        moleTimers.removeAll()
    }

    var rowLayout: [[Int]] {
        var result: [[Int]] = []
        var idx = 0
        let perRow: [Int]
        switch holeCount {
        case 5:  perRow = [2, 3]
        case 6:  perRow = [3, 3]
        case 7:  perRow = [3, 4]
        case 8:  perRow = [3, 2, 3]
        case 9:  perRow = [3, 3, 3]
        case 10: perRow = [3, 4, 3]
        default: perRow = [3, 4, 3]
        }
        for count in perRow {
            var row: [Int] = []
            for _ in 0..<count { row.append(idx); idx += 1 }
            result.append(row)
        }
        return result
    }
}

// MARK: - Seed for deterministic random decorations
private struct SeededPos: Identifiable {
    let id: Int
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    let type: Int
}

// MARK: - Main Game View

struct WhackAMoleGameView: View {
    @StateObject var viewModel: WhackAMoleViewModel
    let onGameEnd: (Int, Bool) -> Void

    private let grassMain  = Color(red: 0.42, green: 0.73, blue: 0.28)
    private let grassDark  = Color(red: 0.30, green: 0.58, blue: 0.18)
    private let grassLight = Color(red: 0.52, green: 0.80, blue: 0.35)
    private let dirtMain   = Color(red: 0.55, green: 0.38, blue: 0.20)
    private let dirtDark   = Color(red: 0.40, green: 0.26, blue: 0.12)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    hudBar.padding(.horizontal, 16).padding(.top, 4)
                    Spacer()
                    groundField(geo: geo)
                    Spacer()
                }

                ForEach(viewModel.popups) { popup in
                    Text(popup.text)
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: grassDark, radius: 3)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if viewModel.gameState == .bombHit { bombOverlay }
            }
        }
        .onAppear { viewModel.startGame() }
        .onDisappear { viewModel.cleanup() }
        .onChange(of: viewModel.gameState) { newState in
            if newState == .timeUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onGameEnd(viewModel.score, false) }
            } else if newState == .bombHit {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onGameEnd(viewModel.score, true) }
            }
        }
    }

    // MARK: - HUD

    private var hudBar: some View {
        HStack {
            Text("Score: \(viewModel.score)")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Text("Time: \(viewModel.timeRemaining)s")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .primary)
        }
    }

    // MARK: - Ground Field (centered, dynamic size)

    private func groundField(geo: GeometryProxy) -> some View {
        let fieldW = geo.size.width - 28
        let rows = viewModel.rowLayout
        let count = viewModel.holeCount

        let baseSize: CGFloat = count <= 6 ? 0.22 : (count <= 8 ? 0.19 : 0.17)
        let holeW = min(geo.size.width * baseSize, 88.0)
        let holeH = holeW * 1.2
        let rowGap: CGFloat = max(geo.size.height * 0.04, 28)

        let gridH = CGFloat(rows.count) * holeH + CGFloat(rows.count - 1) * rowGap
        let fieldH = gridH + 70
        let decos = generateDecorations(fieldW: fieldW, fieldH: fieldH, count: 18)

        return ZStack {

            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [grassLight, grassMain, grassMain, grassDark],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: fieldW, height: fieldH)
                .shadow(color: .black.opacity(0.18), radius: 10, y: 5)

            ForEach(decos) { d in
                if d.type == 0 {

                    grassTuft(size: d.size)
                        .offset(x: d.x - fieldW / 2, y: d.y - fieldH / 2)
                        .rotationEffect(.degrees(d.rotation))
                } else if d.type == 1 {

                    Ellipse()
                        .fill(dirtMain.opacity(0.4))
                        .frame(width: d.size * 1.5, height: d.size)
                        .offset(x: d.x - fieldW / 2, y: d.y - fieldH / 2)
                        .rotationEffect(.degrees(d.rotation))
                } else {

                    Ellipse()
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.55), Color(white: 0.4)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: d.size * 0.8, height: d.size * 0.6)
                        .offset(x: d.x - fieldW / 2, y: d.y - fieldH / 2)
                }
            }

            VStack(spacing: rowGap) {
                ForEach(rows, id: \.self) { row in
                    let colGap: CGFloat = row.count >= 4 ? holeW * 0.12 : holeW * 0.35
                    HStack(spacing: colGap) {
                        ForEach(row, id: \.self) { idx in
                            holeView(index: idx, w: holeW, h: holeH)
                        }
                    }
                }
            }
        }
        .frame(width: fieldW, height: fieldH)
    }

    // MARK: - Decorations generator

    private func generateDecorations(fieldW: CGFloat, fieldH: CGFloat, count: Int) -> [SeededPos] {

        let positions: [(CGFloat, CGFloat)] = [
            (0.08, 0.12), (0.85, 0.08), (0.15, 0.88), (0.90, 0.85),
            (0.05, 0.45), (0.92, 0.50), (0.50, 0.05), (0.50, 0.95),
            (0.20, 0.30), (0.75, 0.25), (0.30, 0.70), (0.70, 0.75),
            (0.12, 0.60), (0.88, 0.35), (0.40, 0.15), (0.60, 0.90),
            (0.25, 0.50), (0.78, 0.60)
        ]
        return positions.prefix(count).enumerated().map { (i, pos) in
            SeededPos(
                id: i,
                x: pos.0 * fieldW,
                y: pos.1 * fieldH,
                size: [8, 10, 12, 14, 9, 11][i % 6],
                rotation: [0, 15, -10, 25, -20, 5][i % 6],
                type: i % 3
            )
        }
    }

    // MARK: - Grass Tuft

    private func grassTuft(size: CGFloat) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == 1 ? grassLight : grassDark)
                    .frame(width: 2, height: size + CGFloat(i) * 2)
                    .rotationEffect(.degrees(Double(i - 1) * 15))
            }
        }
    }

    // MARK: - Hole View

    private func holeView(index: Int, w: CGFloat, h: CGFloat) -> some View {
        let hole = viewModel.holes[index]
        let showHammer = viewModel.hammerHoleIndex == index

        return ZStack(alignment: .bottom) {
            VStack(spacing: 0) {

                ZStack(alignment: .bottom) {
                    Color.clear
                    if hole.isActive && !hole.wasWhacked {
                        moleCharacter(isBomb: hole.isBomb, w: w)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .scale(scale: 0.5).combined(with: .opacity)
                            ))
                            .zIndex(1)
                    }
                }
                .frame(width: w * 1.1, height: h * 0.72)
                .clipped()

                ZStack {

                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [dirtMain, dirtDark, grassDark.opacity(0.5)],
                                center: .center, startRadius: w * 0.15,
                                endRadius: w * 0.55
                            )
                        )
                        .frame(width: w * 1.15, height: h * 0.32)

                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 0.1, green: 0.05, blue: 0.02),
                                         Color(red: 0.22, green: 0.13, blue: 0.05)],
                                center: .center, startRadius: 0, endRadius: w * 0.3
                            )
                        )
                        .frame(width: w * 0.7, height: h * 0.17)
                        .offset(y: -h * 0.02)

                    HStack(spacing: w * 0.15) {
                        Circle().fill(dirtMain.opacity(0.6)).frame(width: 5, height: 5)
                            .offset(y: -h * 0.08)
                        Circle().fill(dirtDark.opacity(0.5)).frame(width: 4, height: 4)
                            .offset(y: h * 0.06)
                        Circle().fill(dirtMain.opacity(0.5)).frame(width: 3, height: 3)
                            .offset(y: -h * 0.05)
                    }
                }
                .zIndex(2)
            }

            if showHammer {
                Text("🔨")
                    .font(.system(size: w * 0.65))
                    .scaleEffect(x: -1, y: 1)
                    .rotationEffect(.degrees(30))
                    .offset(x: -w * 0.22, y: -h * 0.55)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: w * 1.15, height: h * 1.05)
        .contentShape(Rectangle())
        .onTapGesture { viewModel.whackHole(index) }
    }

    // MARK: - Mole

    private func moleCharacter(isBomb: Bool, w: CGFloat) -> some View {
        let bodyW = w * 0.52
        let bodyH = w * 0.58

        return VStack(spacing: 0) {
            if isBomb {
                Text("💣")
                    .font(.system(size: w * 0.30))
                    .shadow(color: .red.opacity(0.6), radius: 5)
            }
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: bodyW * 0.45,
                    bottomLeadingRadius: bodyW * 0.12,
                    bottomTrailingRadius: bodyW * 0.12,
                    topTrailingRadius: bodyW * 0.45
                )
                .fill(LinearGradient(
                    colors: [Color(red: 0.52, green: 0.36, blue: 0.22),
                             Color(red: 0.42, green: 0.28, blue: 0.15),
                             Color(red: 0.35, green: 0.22, blue: 0.1)],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: bodyW, height: bodyH)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

                Ellipse()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.85, green: 0.7, blue: 0.52),
                                 Color(red: 0.75, green: 0.58, blue: 0.4)],
                        startPoint: .top, endPoint: .bottom))
                    .frame(width: bodyW * 0.68, height: bodyH * 0.52)
                    .offset(y: bodyH * 0.06)

                VStack(spacing: bodyH * 0.03) {
                    HStack(spacing: bodyW * 0.2) {
                        eyeView(size: bodyW * 0.18)
                        eyeView(size: bodyW * 0.18)
                    }
                    Ellipse()
                        .fill(Color(red: 0.95, green: 0.45, blue: 0.45))
                        .frame(width: bodyW * 0.2, height: bodyW * 0.13)
                        .overlay(
                            Ellipse()
                                .fill(Color.white.opacity(0.4))
                                .frame(width: bodyW * 0.08, height: bodyW * 0.05)
                                .offset(x: -bodyW * 0.03, y: -bodyW * 0.02))
                    HStack(spacing: bodyW * 0.06) {
                        Capsule().fill(Color(red: 0.25, green: 0.13, blue: 0.05))
                            .frame(width: bodyW * 0.04, height: bodyW * 0.02)
                        Capsule().fill(Color(red: 0.25, green: 0.13, blue: 0.05))
                            .frame(width: bodyW * 0.04, height: bodyW * 0.02)
                    }
                }
                .offset(y: -bodyH * 0.08)
            }
        }
    }

    private func eyeView(size: CGFloat) -> some View {
        ZStack {
            Circle().fill(Color.white).frame(width: size, height: size)
            Circle().fill(Color.black).frame(width: size * 0.55, height: size * 0.55).offset(x: -size * 0.05)
            Circle().fill(Color.white).frame(width: size * 0.2, height: size * 0.2).offset(x: -size * 0.12, y: -size * 0.1)
        }
    }

    private var bombOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("💥").font(.system(size: 80))
                Text("BOOM!").font(.system(size: 42, weight: .black, design: .rounded)).foregroundColor(.red)
                Text("You hit a bomb!").font(.system(size: 18, weight: .medium)).foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
}
