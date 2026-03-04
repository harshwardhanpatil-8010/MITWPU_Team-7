//
//import AVFoundation
//
//class RhythmicAudioManager {
//    static let shared = RhythmicAudioManager()
//    
//    private var audioEngine = AVAudioEngine()
//    private var playerNode = AVAudioPlayerNode()
//    private var timer: Timer?
//    
//    private init() {
//        audioEngine.attach(playerNode)
//        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
//    }
//    
//    func playBeat(fileName: String, bpm: Int) {
//        stop()
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3"),
//              let file = try? AVAudioFile(forReading: url) else {
//            print("Audio file \(fileName) not found.")
//            return
//        }
//        
//        if !audioEngine.isRunning { try? audioEngine.start() }
//        let interval = 60.0 / Double(bpm)
//        
//        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
//            self?.playerNode.scheduleFile(file, at: nil, completionHandler: nil)
//            if !(self?.playerNode.isPlaying ?? false) {
//                self?.playerNode.play()
//            }
//        }
//    }
//    
//    func pause() {
//        playerNode.pause()
//    }
//    
//    func resume() {
//        if !audioEngine.isRunning { try? audioEngine.start() }
//        playerNode.play()
//    }
//    
//    func stop() {
//        timer?.invalidate()
//        timer = nil
//        playerNode.stop()
//    }
//}




//
//  RhythmicAudioManager.swift  (file: AVAudioPlayerNode.swift)
//  Parkinsons
//
//  WHAT WAS BROKEN IN THE PREVIOUS VERSION:
//  -----------------------------------------
//  1. The recursive callback used absolute frame counts (frame, frame+interval,
//     frame+2*interval …). When playerNode.stop()/play() resets the node
//     timeline to zero, those giant frame numbers are millions of samples in
//     the future → nothing plays.
//
//  2. completionCallbackType: .dataConsumed fires the moment the renderer
//     *reads* the buffer, not when the sound is heard. For a 12 ms click at
//     80 BPM the callback fires instantly, causing all beats to be scheduled
//     in one flood → pile-up / silence.
//
//  HOW THIS VERSION FIXES IT:
//  --------------------------
//  • A DispatchSourceTimer fires on a high-priority queue at the beat interval.
//  • Each tick asks the playerNode for its CURRENT render position
//    (playerNode.playerTime(forNodeTime:)) and schedules the next buffer a
//    fixed look-ahead (100 ms) past that point.
//  • Because every schedule call is anchored to the live render clock, pause /
//    resume / BPM changes always work correctly.
//  • All five beat sounds are synthesised entirely in code — no audio files needed.

import AVFoundation

// MARK: - Beat types (drives the UI dropdown automatically)

enum BeatType: String, CaseIterable {
    case click     = "Click"
    case woodblock = "Woodblock"
    case beep      = "Beep"
    case tick      = "Tick"
    case drum      = "Drum"
}

// MARK: - Manager

final class RhythmicAudioManager {

    static let shared = RhythmicAudioManager()

    // MARK: Engine
    private let engine     = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100

    // MARK: State
    private var beatBuffer:  AVAudioPCMBuffer?
    private var currentBPM:  Int      = 80
    private var currentBeat: BeatType = .click
    private var beatTimer:   DispatchSourceTimer?

    private(set) var isPlaying = false
    private(set) var isPaused  = false

    // MARK: Init
    private init() {
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: fmt)
        configureAudioSession()
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[RhythmicAudio] Session error: \(error)")
        }
    }

    // MARK: - Public API

    /// Call whenever the user picks a different beat sound or pace.
    func playBeat(beatType: String, bpm: Int) {
        let type = BeatType(rawValue: beatType) ?? .click
        stopInternal()
        currentBeat = type
        currentBPM  = max(20, min(300, bpm))
        beatBuffer  = makeBeatBuffer(for: type)
        startEngineIfNeeded()
        playerNode.play()
        startTimer()
        isPlaying = true
        isPaused  = false
    }

    func pause() {
        guard isPlaying, !isPaused else { return }
        stopTimer()
        playerNode.pause()
        isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        isPaused = false
        startEngineIfNeeded()
        playerNode.play()
        startTimer()
        isPlaying = true
    }

    func stop() {
        stopInternal()
    }

    // MARK: - Internal

    private func stopInternal() {
        stopTimer()
        playerNode.stop()
        isPlaying = false
        isPaused  = false
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        do { try engine.start() }
        catch { print("[RhythmicAudio] Engine start error: \(error)") }
    }

    // MARK: - Timer-driven scheduling

    private func startTimer() {
        stopTimer()
        guard let buffer = beatBuffer else { return }

        let intervalNs = UInt64((60.0 / Double(currentBPM)) * 1_000_000_000)
        let lookaheadFrames = AVAudioFramePosition(0.1 * sampleRate)  // 100 ms look-ahead

        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
        timer.schedule(deadline: .now(), repeating: .nanoseconds(Int(intervalNs)),
                       leeway: .milliseconds(1))

        timer.setEventHandler { [weak self] in
            guard let self, self.isPlaying, !self.isPaused else { return }
            self.scheduleBeat(buffer: buffer, lookaheadFrames: lookaheadFrames)
        }

        beatTimer = timer
        timer.resume()
    }

    private func stopTimer() {
        beatTimer?.cancel()
        beatTimer = nil
    }

    private func scheduleBeat(buffer: AVAudioPCMBuffer,
                               lookaheadFrames: AVAudioFramePosition) {
        // Anchor to the node's live render clock so pause/resume never desync
        if let nodeTime   = playerNode.lastRenderTime,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            let targetFrame = playerTime.sampleTime + lookaheadFrames
            let schedTime   = AVAudioTime(sampleTime: targetFrame, atRate: sampleRate)
            playerNode.scheduleBuffer(buffer, at: schedTime, options: .interrupts,
                                      completionHandler: nil)
        } else {
            // Node hasn't rendered yet — schedule at a small absolute offset
            let schedTime = AVAudioTime(sampleTime: lookaheadFrames, atRate: sampleRate)
            playerNode.scheduleBuffer(buffer, at: schedTime, options: .interrupts,
                                      completionHandler: nil)
        }
    }

    // MARK: - Beat synthesis (all sounds generated in code)

    private func makeBeatBuffer(for type: BeatType) -> AVAudioPCMBuffer? {
        switch type {
        case .click:     return makeClick()
        case .woodblock: return makeWoodblock()
        case .beep:      return makeBeep()
        case .tick:      return makeTick()
        case .drum:      return makeDrum()
        }
    }

    private func buffer(duration: Double) -> AVAudioPCMBuffer? {
        let fmt    = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frames = AVAudioFrameCount(sampleRate * duration)
        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frames) else { return nil }
        buf.frameLength = frames
        return buf
    }

    // Sharp click — 30 ms, two-tone sine with fast decay
    private func makeClick() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.03) else { return nil }
        let d = buf.floatChannelData![0]
        for i in 0..<Int(buf.frameLength) {
            let t   = Double(i) / sampleRate
            let env = exp(-t / 0.005)
            d[i]    = Float((sin(2 * .pi * 1000 * t) + sin(2 * .pi * 1500 * t)) * 0.45 * env)
        }
        return buf
    }

    // Hollow woodblock — 60 ms, mid-freq tone + transient noise
    private func makeWoodblock() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.06) else { return nil }
        let d = buf.floatChannelData![0]
        for i in 0..<Int(buf.frameLength) {
            let t     = Double(i) / sampleRate
            let env   = exp(-t / 0.02)
            let tone  = sin(2 * .pi * 750 * t) * 0.7
            let noise = Double.random(in: -0.3...0.3) * exp(-t / 0.004)
            d[i]      = Float((tone + noise) * env)
        }
        return buf
    }

    // Pure beep — 120 ms sine with smooth attack/release
    private func makeBeep() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.12) else { return nil }
        let d = buf.floatChannelData![0]
        let atk = 0.008, rel = 0.05
        for i in 0..<Int(buf.frameLength) {
            let t   = Double(i) / sampleRate
            let env = t < atk ? t / atk : exp(-(t - atk) / rel)
            d[i]    = Float(sin(2 * .pi * 880 * t) * env * 0.85)
        }
        return buf
    }

    // Soft tick — 20 ms high-frequency, quiet
    private func makeTick() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.02) else { return nil }
        let d = buf.floatChannelData![0]
        for i in 0..<Int(buf.frameLength) {
            let t   = Double(i) / sampleRate
            let env = exp(-t / 0.004)
            d[i]    = Float(sin(2 * .pi * 2200 * t) * env * 0.75)
        }
        return buf
    }

    // Kick drum — 150 ms, pitch-dropping sine + low noise thump
    private func makeDrum() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.15) else { return nil }
        let d = buf.floatChannelData![0]
        var phase = 0.0
        for i in 0..<Int(buf.frameLength) {
            let t     = Double(i) / sampleRate
            let freq  = 120.0 * exp(-t / 0.04) + 55.0   // drops 175 Hz → 55 Hz
            let env   = exp(-t / 0.07)
            let noise = Double.random(in: -0.2...0.2) * exp(-t / 0.008)
            phase    += 2 * .pi * freq / sampleRate
            d[i]      = Float(sin(phase) * env * 0.9 + noise)
        }
        return buf
    }
}
