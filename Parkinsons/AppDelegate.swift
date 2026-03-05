import UIKit
import AVFoundation
import HealthKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // MARK: - Exercise JSON Version Check
        //
        // Every time you update workout_exercises.json, bump the version number below.
        // On first launch (or after a JSON update), the app reloads exercises from
        // the new JSON. This preserves ALL other UserDefaults (disease stage, feedback,
        // position history, medication data) while forcing a fresh exercise set.

        let currentJSONVersion = "1.0"   // ← BUMP THIS every time you update workout_exercises.json
        let storedJSONVersion  = UserDefaults.standard.string(forKey: "loadedExerciseJSONVersion")

        if storedJSONVersion != currentJSONVersion {
            // JSON has been updated (or this is first ever launch).
            // Reset only exercise session state — preserve everything else.
            WorkoutManager.shared.resetDailyProgress()
            WorkoutManager.shared.lastCheckedMedState  = .unknown   // was hasCheckedSafetyThisSession
            WorkoutManager.shared.userWantsToPushLimits = false
            WorkoutManager.shared.exercises             = []

            UserDefaults.standard.set(currentJSONVersion, forKey: "loadedExerciseJSONVersion")

         
        }

        // NOTE: We do NOT call generateDailyWorkout() here.
        // The LandingPage's viewWillAppear triggers the med-state check and
        // calls generateDailyWorkout(for:) AFTER the user has chosen a position.

        // MARK: - Audio Session

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }

        // MARK: - HealthKit

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HealthKitManagerRhythmic.shared.requestAuthorization { granted in
                print("HealthKit granted: \(granted)")
                guard granted else { return }

                let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                let predicate = HKQuery.predicateForSamples(
                    withStart: Date().addingTimeInterval(-86400),
                    end: Date(),
                    options: []
                )
                let query = HKStatisticsQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, stats, _ in
                    print("✅ Steps in last 24hrs: \(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)")
                }
                HealthKitManagerRhythmic.shared.healthStore.execute(query)
            }
        }

        HealthKitManagerRhythmic.shared.requestAuthorization { granted in
            print("HealthKit granted: \(granted)")
            HealthKitManagerRhythmic.shared.checkAuthorizationStatus()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
