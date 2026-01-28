
import AVFoundation

class RhythmicAudioManager {
    static let shared = RhythmicAudioManager()
    
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var timer: Timer?
    
    private init() {
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
    }
    
    func playBeat(fileName: String, bpm: Int) {
        stop()
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3"),
              let file = try? AVAudioFile(forReading: url) else {
            print("Audio file \(fileName) not found.")
            return
        }
        
        if !audioEngine.isRunning { try? audioEngine.start() }
        let interval = 60.0 / Double(bpm)
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playerNode.scheduleFile(file, at: nil, completionHandler: nil)
            if !(self?.playerNode.isPlaying ?? false) {
                self?.playerNode.play()
            }
        }
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func resume() {
        if !audioEngine.isRunning { try? audioEngine.start() }
        playerNode.play()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        playerNode.stop()
    }
}
