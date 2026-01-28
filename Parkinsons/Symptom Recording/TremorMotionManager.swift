import CoreMotion
import Accelerate
import Foundation

final class TremorMotionManager {
    static let shared = TremorMotionManager()
    private let motionManager = CMMotionManager()
    
    private var samples: [Double] = []
    private let sampleRate: Double = 100.0
    private let queue = OperationQueue()

    func recordFrequency(duration: TimeInterval = 5.0, completion: @escaping (Double?) -> Void) {
        guard motionManager.isDeviceMotionAvailable else {
            completion(nil)
            return
        }

        samples.removeAll()
        let maxSamples = Int(duration * sampleRate)
        motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate

        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] data, error in
            guard let self = self, let motion = data else { return }

            let ua = motion.userAcceleration
            // Combine all axes into a single magnitude value to capture tremor in any direction
            let magnitude = sqrt(pow(ua.x, 2) + pow(ua.y, 2) + pow(ua.z, 2))
            
            self.samples.append(magnitude)

            if self.samples.count >= maxSamples {
                self.motionManager.stopDeviceMotionUpdates()
                let freq = self.calculateDominantFrequency()
                DispatchQueue.main.async {
                    completion(freq)
                }
            }
        }
    }

    private func calculateDominantFrequency() -> Double? {
        // Need enough data for a stable FFT (minimum 2-3 seconds at 100Hz)
        guard samples.count >= 256 else { return nil }

        // 1. Detrending: Remove the mean to center the signal at 0.0
        let mean = samples.reduce(0, +) / Double(samples.count)
        let centered = samples.map { $0 - mean }

        // 2. Apply Band-pass Filter (2Hz - 10Hz covers most Parkinsonian/Essential tremors)
        let filtered = bandPass(centered, low: 2.0, high: 10.0, sampleRate: sampleRate)

        // 3. RMS Check: Ensure there is actually enough movement to analyze
        let rms = sqrt(filtered.map { $0 * $0 }.reduce(0, +) / Double(filtered.count))
        if rms < 0.01 { return nil } // Too still

        // 4. FFT Setup
        let n = 1 << Int(floor(log2(Double(filtered.count)))) // Power of 2
        let log2n = vDSP_Length(log2(Double(n)))
        guard let setup = vDSP_create_fftsetupD(log2n, FFTRadix(kFFTRadix2)) else { return nil }

        var real = Array(filtered.prefix(n))
        var imag = [Double](repeating: 0.0, count: n)
        
        return real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var split = DSPDoubleSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                
                // Perform FFT
                vDSP_fft_zipD(setup, &split, 1, log2n, FFTDirection(FFT_FORWARD))
                
                // Calculate Magnitudes
                var magnitudes = [Double](repeating: 0.0, count: n / 2)
                vDSP_zvmagsD(&split, 1, &magnitudes, 1, vDSP_Length(n / 2))
                vDSP_destroy_fftsetupD(setup)
                
                // 5. Find Peak in the Tremor Range (2Hz to 9Hz)
                let minBin = Int(2.0 * Double(n) / sampleRate)
                let maxBin = Int(9.0 * Double(n) / sampleRate)
                
                guard maxBin < magnitudes.count else { return nil }
                
                var peakMagnitude: Double = 0
                var peakIndex: Int = 0
                
                for i in minBin...maxBin {
                    if magnitudes[i] > peakMagnitude {
                        peakMagnitude = magnitudes[i]
                        peakIndex = i
                    }
                }
                
                // 6. Confidence Check (Peak vs average energy)
                let totalEnergy = magnitudes[minBin...maxBin].reduce(0, +)
                guard peakMagnitude > (totalEnergy / Double(maxBin - minBin)) * 1.5 else { return nil }

                return Double(peakIndex) * sampleRate / Double(n)
            }
        }
    }

    private func bandPass(_ signal: [Double], low: Double, high: Double, sampleRate: Double) -> [Double] {
        let dt = 1.0 / sampleRate
        let rcHigh = 1.0 / (2 * .pi * low)
        let alphaHigh = rcHigh / (rcHigh + dt)
        
        var highPassed = signal
        for i in 1..<signal.count {
            highPassed[i] = alphaHigh * (highPassed[i-1] + signal[i] - signal[i-1])
        }
        
        let rcLow = 1.0 / (2 * .pi * high)
        let alphaLow = dt / (rcLow + dt)
        var bandPassed = highPassed
        for i in 1..<highPassed.count {
            bandPassed[i] = bandPassed[i-1] + alphaLow * (highPassed[i] - bandPassed[i-1])
        }
        return bandPassed
    }
}
