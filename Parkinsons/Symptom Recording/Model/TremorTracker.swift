import Foundation
import UIKit
import CoreMotion
import BackgroundTasks

final class TremorTracker {
    static let shared = TremorTracker()
    
    private var foregroundTimer: Timer?
    private var isTracking = false
    private let bgTaskIdentifier = "com.mitwpu.team7.tremorTracking"
    
    private(set) var lastMeasurementDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastTremorMeasurementDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastTremorMeasurementDate")
        }
    }
    
    private(set) var isRecordingActive = false
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func registerBackgroundTasks() {
        print("🔊 [TremorTracker] Registering background task with identifier: \(bgTaskIdentifier)")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: bgTaskIdentifier, using: nil) { task in
            self.handleBackgroundAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func start() {
        guard !isTracking else { return }
        isTracking = true
        
        print("🔊 [TremorTracker] Starting TremorTracker. Current App State: \(UIApplication.shared.applicationState == .active ? "Foreground/Active" : "Background/Inactive")")
        
        if UIApplication.shared.applicationState == .active {
            startForegroundTimer()
            checkAndRunMeasurementIfNeeded()
        } else {
            scheduleNextBackgroundTask()
        }
    }
    
    func stop() {
        print("🔊 [TremorTracker] Stopping TremorTracker.")
        isTracking = false
        stopForegroundTimer()
    }
    
    @objc private func appWillEnterForeground() {
        guard isTracking else { return }
        print("🔊 [TremorTracker] App will enter foreground. Resetting foreground timer.")
        stopForegroundTimer()
        startForegroundTimer()
        checkAndRunMeasurementIfNeeded()
    }
    
    @objc private func appDidEnterBackground() {
        guard isTracking else { return }
        print("🔊 [TremorTracker] App did enter background. Stopping foreground timer and scheduling BG task.")
        stopForegroundTimer()
        scheduleNextBackgroundTask()
    }
    
    private func startForegroundTimer() {
        foregroundTimer?.invalidate()
        print("🔊 [TremorTracker] Setting up foreground timer to fire every 5 minutes (300.0 seconds).")
        // Foreground: Track every 5 minutes (300 seconds)
        foregroundTimer = Timer.scheduledTimer(withTimeInterval: 300.0, repeats: true) { [weak self] _ in
            print("🔊 [TremorTracker] Foreground timer fired.")
            self?.runMeasurement()
        }
    }
    
    private func stopForegroundTimer() {
        foregroundTimer?.invalidate()
        foregroundTimer = nil
    }
    
    func getRequiredInterval() -> TimeInterval {
        if UIApplication.shared.applicationState == .active {
            return 300.0 // 5 minutes
        }
        
        let lastForeground = UserDefaults.standard.object(forKey: "lastForegroundTime") as? Date ?? Date()
        let timeSinceForeground = Date().timeIntervalSince(lastForeground)
        
        if timeSinceForeground > 3600.0 {
            print("🔊 [TremorTracker] Last active foreground was \(timeSinceForeground)s ago (> 1 hour). Tracking frequency: 1 hour.")
            return 3600.0 // 1 hour
        } else {
            print("🔊 [TremorTracker] Last active foreground was \(timeSinceForeground)s ago (< 1 hour). Tracking frequency: 10 minutes.")
            return 600.0 // 10 minutes
        }
    }
    
    func checkAndRunMeasurementIfNeeded(completion: ((Bool) -> Void)? = nil) {
        let now = Date()
        let interval = getRequiredInterval()
        
        if let lastDate = lastMeasurementDate {
            let elapsed = now.timeIntervalSince(lastDate)
            print("🔊 [TremorTracker] Checking if measurement is needed. Elapsed since last: \(elapsed)s. Required interval: \(interval)s.")
            if elapsed >= interval {
                runMeasurement(completion: completion)
            } else {
                print("🔊 [TremorTracker] Skipping measurement. Time remaining: \(interval - elapsed)s.")
                completion?(false)
            }
        } else {
            print("🔊 [TremorTracker] No previous measurement found. Running measurement now.")
            runMeasurement(completion: completion)
        }
    }
    
    func runMeasurement(completion: ((Bool) -> Void)? = nil) {
        guard !isRecordingActive else {
            print("⚠️ [TremorTracker] A measurement is already active. Skipping duplicate run.")
            completion?(false)
            return
        }
        
        print("🔊 [TremorTracker] Starting 5-second accelerometer tremor measurement...")
        isRecordingActive = true
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("TremorMeasurementStarted"), object: nil)
        }
        
        // Measure for 5.0 seconds as specified by the user
        TremorMotionManager.shared.recordTremorFrequency(duration: 5.0) { [weak self] result in
            guard let self = self else {
                completion?(false)
                return
            }
            
            TremorDataStore.shared.save(result: result)
            self.lastMeasurementDate = Date()
            self.isRecordingActive = false
            
            switch result {
            case .steady:
                print("🔊 [TremorTracker] Measurement complete: STEADY. Saved to Core Data.")
            case .tremor(let hz):
                print("🔊 [TremorTracker] Measurement complete: TREMOR \(String(format: "%.1f Hz", hz)). Saved to Core Data.")
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("TremorDataUpdated"),
                    object: nil,
                    userInfo: ["result": result]
                )
                completion?(true)
            }
        }
    }
    
    func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: bgTaskIdentifier)
        
        let delay = getRequiredInterval()
        request.earliestBeginDate = Date().addingTimeInterval(delay)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("🔊 [TremorTracker] Successfully submitted background task request for earliest start: \(request.earliestBeginDate?.description ?? "unknown") (in \(delay)s)")
        } catch {
            print("⚠️ [TremorTracker] Could not schedule background task: \(error)")
        }
    }
    
    private func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
        print("🔊 [TremorTracker] Background app refresh task started executing.")
        scheduleNextBackgroundTask()
        
        task.expirationHandler = {
            print("⚠️ [TremorTracker] Background task expired by iOS. Cancelling measurement.")
            TremorMotionManager.shared.cancelRecording()
            self.isRecordingActive = false
            task.setTaskCompleted(success: false)
        }
        
        checkAndRunMeasurementIfNeeded { success in
            print("🔊 [TremorTracker] Background task execution completed. Success: \(success)")
            task.setTaskCompleted(success: success)
        }
    }
}
