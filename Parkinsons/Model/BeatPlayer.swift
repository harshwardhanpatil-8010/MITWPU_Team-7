//
//  BeatPlayer.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation
import AVFoundation

final class BeatPlayer {
    static let shared = BeatPlayer()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    // support loading multiple preloaded buffers keyed by filename
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var timer: DispatchSourceTimer?
    private var isPlaying = false
    private var currentFileKey: String?

    private init() {
        // engine will be started when first buffer is loaded
    }

    /// Load an audio file from bundle (supports subdirectory blue reference)
    /// fileKey: unique key for the buffer (typically fileName)
    /// folder: if your files live in a blue folder, pass "Bundle", else nil
    func loadAudio(fileName: String, type: String = "mp3", folder: String? = "Bundle") throws {
        // 1. build URL (use subdirectory since you said blue folder)
        let url: URL? = Bundle.main.url(forResource: fileName, withExtension: type, subdirectory: folder)
        guard let url = url else {
            throw NSError(domain: "BeatPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(fileName).\(type) not found in bundle subdirectory \(folder ?? "nil")"])
        }

        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let capacity = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else {
            throw NSError(domain: "BeatPlayer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to create PCM buffer"])
        }
        try file.read(into: buffer)

        audioBuffers[fileName] = buffer

        // attach/connect if not already
        if engine.attachedNodes.contains(player) == false {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            try? engine.start()
        }
    }

    /// start beat ticking at bpm using preloaded buffer keyed by fileName
    /// if buffer not loaded, it will attempt to load from `Bundle` subdirectory
    func startBeat(fileName: String, bpm: Int, type: String = "mp3", folder: String? = "Bundle") {
        stopBeat()

        // ensure buffer exists (try to load)
        if audioBuffers[fileName] == nil {
            do {
                try loadAudio(fileName: fileName, type: type, folder: folder)
            } catch {
                print("BeatPlayer load error:", error.localizedDescription)
                return
            }
        }

        guard let buffer = audioBuffers[fileName] else { return }

        currentFileKey = fileName
        let interval = 60.0 / Double(max(1, bpm))

        isPlaying = true

        timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInteractive))
        timer?.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(1))
        timer?.setEventHandler { [weak self] in
            guard let self = self, self.isPlaying else { return }
            // schedule buffer
            self.player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
            if !self.player.isPlaying {
                self.player.play()
            }
        }
        timer?.resume()
    }

    func stopBeat() {
        isPlaying = false
        timer?.cancel()
        timer = nil
        player.stop()
    }

    /// change tempo without unloading buffer
    func updateBPM(to bpm: Int) {
        guard let fileKey = currentFileKey else { return }
        startBeat(fileName: fileKey, bpm: bpm)
    }
}
