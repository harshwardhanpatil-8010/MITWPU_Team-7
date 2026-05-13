import CoreMotion
import Accelerate
import Foundation

final class TremorMotionManager {
    static let shared = TremorMotionManager()
    private let motionManager = CMMotionManager()
    private var isRecording = false
    private var samples: [Double] = []
    private let sampleRate: Double = 100.0
    private var pendingCompletion: ((TremorResult) -> Void)?

    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.qualityOfService = .userInitiated
        return q
    }()
    enum TremorResult {
        case steady
        case tremor(Double)
    }
    func cancelRecording() {
        motionManager.stopDeviceMotionUpdates()
        isRecording = false
        pendingCompletion = nil
        samples.removeAll()
    }

    func recordTremorFrequency(
        duration: TimeInterval = 5.0,
        completion: @escaping (TremorResult) -> Void
    ) {
        guard !isRecording else { return }
        isRecording = true
        pendingCompletion = completion
        samples.removeAll()

        let maxSamples = Int(duration * sampleRate)
        motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, _ in
            guard let self = self, self.isRecording else { return }
            guard let motion = data else { return }

            let ua = motion.userAcceleration
            let magnitude = sqrt(ua.x * ua.x + ua.y * ua.y + ua.z * ua.z)
            self.samples.append(magnitude)

            if self.samples.count >= maxSamples {
                self.motionManager.stopDeviceMotionUpdates()
                let result = self.analyseFrequency()
                DispatchQueue.main.async {
                    guard self.isRecording else { return }
                    self.isRecording = false
                    let cb = self.pendingCompletion
                    self.pendingCompletion = nil
                    cb?(result)
                }
            }
        }
    }

    private func analyseFrequency() -> TremorResult {
        guard samples.count >= 256 else { return .steady }

        let mean = samples.reduce(0, +) / Double(samples.count)
        let centered = samples.map { $0 - mean }

        let filtered = bandPass(centered, low: 3.0, high: 7.0, sampleRate: sampleRate)

        let rms = sqrt(filtered.map { $0 * $0 }.reduce(0, +) / Double(filtered.count))
        if rms < 0.004 { return .steady }
        let n = 1 << Int(floor(log2(Double(filtered.count))))
        let log2n = vDSP_Length(log2(Double(n)))
        guard let setup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else { return .steady }
        defer { vDSP_destroy_fftsetupD(setup) }

        var signal = Array(filtered.prefix(n))
        var window = [Double](repeating: 0, count: n)
        vDSP_hann_windowD(&window, vDSP_Length(n), Int32(vDSP_HANN_NORM))
        vDSP_vmulD(signal, 1, window, 1, &signal, 1, vDSP_Length(n))

        var real = [Double](repeating: 0, count: n / 2)
        var imag = [Double](repeating: 0, count: n / 2)
        var detected: Double?

        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var split = DSPDoubleSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                signal.withUnsafeBufferPointer { sigPtr in
                    sigPtr.baseAddress!.withMemoryRebound(to: DSPDoubleComplex.self, capacity: n) { tc in
                        vDSP_ctozD(tc, 2, &split, 1, vDSP_Length(n / 2))
                    }
                }
                vDSP_fft_zripD(setup, &split, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes = [Double](repeating: 0, count: n / 2)
                vDSP_zvmagsD(&split, 1, &magnitudes, 1, vDSP_Length(n / 2))

                let minBin = Int(3.0 * Double(n) / sampleRate)
                let maxBin = Int(7.0 * Double(n) / sampleRate)
                guard maxBin < magnitudes.count else { return }

                var peakMag = 0.0
                var peakIndex = 0
                for i in minBin...maxBin {
                    if magnitudes[i] > peakMag { peakMag = magnitudes[i]; peakIndex = i }
                }

                let totalEnergy = magnitudes[minBin...maxBin].reduce(0, +)
                let avgEnergy = totalEnergy / Double(maxBin - minBin)
                guard peakMag > avgEnergy * 2.0 else { return }

                detected = Double(peakIndex) * sampleRate / Double(n)
            }
        }

        if let hz = detected {
            return .tremor(hz)
        } else {
            return .steady
        }
    }

    private func bandPass(_ signal: [Double], low: Double, high: Double, sampleRate: Double) -> [Double] {
        let dt = 1.0 / sampleRate
        let rcHigh = 1.0 / (2 * .pi * low)
        let alphaHigh = rcHigh / (rcHigh + dt)
        var highPassed = signal
        for i in 1..<signal.count {
            highPassed[i] = alphaHigh * (highPassed[i - 1] + signal[i] - signal[i - 1])
        }
        let rcLow = 1.0 / (2 * .pi * high)
        let alphaLow = dt / (rcLow + dt)
        var bandPassed = highPassed
        for i in 1..<highPassed.count {
            bandPassed[i] = bandPassed[i - 1] + alphaLow * (highPassed[i] - bandPassed[i - 1])
        }
        return bandPassed
    }
}
