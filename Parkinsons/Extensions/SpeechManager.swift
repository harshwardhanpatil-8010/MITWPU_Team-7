import AVFoundation

class SpeechManager {

    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {

        let dummyUtterance = AVSpeechUtterance(string: "Initialize")
        dummyUtterance.volume = 0.0
        dummyUtterance.rate = AVSpeechUtteranceMaximumSpeechRate
        dummyUtterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        synthesizer.speak(dummyUtterance)
    }

    func speak(_ text: String) {

        let trimmedText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedText.isEmpty else {
            return
        }

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[SpeechManager] Audio session activation failed: \(error)")
        }

        let utterance = AVSpeechUtterance(
            string: trimmedText
        )

        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())

        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    func stop() {

        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {

        synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {

        synthesizer.continueSpeaking()
    }

}
