//
//  MotionManager.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import Foundation
import CoreMotion

class MotionManager {
    
    static let shared = MotionManager()
    private let pedometer = CMPedometer()

    private init() {}
    
    private(set) var isRunning = false
    private var startDate: Date?
    
    /// Starts pedometer updates safely
    /// Completion returns: steps, distance, cadence (steps/sec)
    func start(completion: @escaping (_ steps: Int, _ distance: Double, _ cadence: Double?) -> Void) {
        
        // 1️⃣ Check hardware availability
        guard CMPedometer.isStepCountingAvailable(),
              CMPedometer.isDistanceAvailable() else {
            print("⚠️ Pedometer not supported on this device.")
            return
        }
        
        // 2️⃣ Track start date
        startDate = Date()
        isRunning = true
        
        pedometer.startUpdates(from: startDate!) { data, error in
                        
            // 3️⃣ Handle possible errors
            if let error = error {
                print("❌ Pedometer error:", error.localizedDescription)
                return
            }
            
            // 4️⃣ Ensure updates only when running
            guard let d = data, self.isRunning else { return }
            
            let steps = d.numberOfSteps.intValue
            let distance = d.distance?.doubleValue ?? 0.0
            
            // Some devices don’t give cadence (nil)
            let cadence = d.currentCadence?.doubleValue
            
            // 5️⃣ UI updates should be on main thread
            DispatchQueue.main.async {
                completion(steps, distance, cadence)
            }
        }
    }
    
    /// Stop tracking safely
    func stop() {
        guard isRunning else { return } 
        isRunning = false
        pedometer.stopUpdates()
        startDate = nil
    }
    
    /// Optional: reset values when beginning new session
    func reset() {
        stop()
        startDate = nil
    }
}
