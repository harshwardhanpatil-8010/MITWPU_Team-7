
import AVFoundation

enum BeatType: String, CaseIterable {
    case click     = "Click"
    case woodblock = "Woodblock"
    case beep      = "Beep"
    case tick      = "Tick"
    case drum      = "Drum"
}

final class RhythmicAudioManager {

    static let shared = RhythmicAudioManager()

    private let engine     = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100

    private var beatBuffer:  AVAudioPCMBuffer?
    private var currentBPM:  Int      = 80
    private var currentBeat: BeatType = .click
    private var beatTimer:   DispatchSourceTimer?

    private(set) var isPlaying = false
    private(set) var isPaused  = false

    private init() {
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: fmt)
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[RhythmicAudio] Session error: \(error)")
        }
    }

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

    private func startTimer() {
        stopTimer()
        guard let buffer = beatBuffer else { return }

        let intervalNs = UInt64((60.0 / Double(currentBPM)) * 1_000_000_000)
        let lookaheadFrames = AVAudioFramePosition(0.1 * sampleRate)  

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
        if let nodeTime   = playerNode.lastRenderTime,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            let targetFrame = playerTime.sampleTime + lookaheadFrames
            let schedTime   = AVAudioTime(sampleTime: targetFrame, atRate: sampleRate)
            playerNode.scheduleBuffer(buffer, at: schedTime, options: .interrupts,
                                      completionHandler: nil)
        } else {
            let schedTime = AVAudioTime(sampleTime: lookaheadFrames, atRate: sampleRate)
            playerNode.scheduleBuffer(buffer, at: schedTime, options: .interrupts,
                                      completionHandler: nil)
        }
    }

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

    private func makeDrum() -> AVAudioPCMBuffer? {
        guard let buf = buffer(duration: 0.15) else { return nil }
        let d = buf.floatChannelData![0]
        var phase = 0.0
        for i in 0..<Int(buf.frameLength) {
            let t     = Double(i) / sampleRate
            let freq  = 120.0 * exp(-t / 0.04) + 55.0 
            let env   = exp(-t / 0.07)
            let noise = Double.random(in: -0.2...0.2) * exp(-t / 0.008)
            phase    += 2 * .pi * freq / sampleRate
            d[i]      = Float(sin(phase) * env * 0.9 + noise)
        }
        return buf
    }
}
