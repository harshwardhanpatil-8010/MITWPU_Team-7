// AppDelegate.swift
// Parkinsons

import UIKit
import AVFoundation
import HealthKit
import UserNotifications
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // MARK: - Exercise JSON Version Check
        let currentJSONVersion = "1.0"   // ← BUMP every time you update workout_exercises.json
        let storedJSONVersion  = UserDefaults.standard.string(forKey: "loadedExerciseJSONVersion")
        if storedJSONVersion != currentJSONVersion {
            WorkoutManager.shared.resetAllExercises()
            WorkoutManager.shared.syncSessionPersistence()
            UserDefaults.standard.set(currentJSONVersion, forKey: "loadedExerciseJSONVersion")
        }

        // NOTE: We do NOT call generateDailyWorkout() here.
        // The LandingPage's viewWillAppear triggers the med-state check and
        // calls generateDailyWorkout(for:) AFTER the user has chosen a position.

        // MARK: - Audio Session
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession FAILED: \(error)")
        }

        // Warm up SpeechManager to prevent initial hang
        DispatchQueue.main.async {
            _ = SpeechManager.shared
        }

        // MARK: - HealthKit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            HealthKitManagerRhythmic.shared.requestAuthorization { granted in
                print("HealthKit granted: \(granted)")
                guard granted else { return }
                let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                let predicate = HKQuery.predicateForSamples(
                    withStart: Date().addingTimeInterval(-86400), end: Date(), options: []
                )
                let query = HKStatisticsQuery(
                    quantityType: type,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, _, _ in }
                HealthKitManagerRhythmic.shared.healthStore.execute(query)
            }
        }
        HealthKitManagerRhythmic.shared.requestAuthorization { granted in
            print("[HealthKit] Authorization granted: \(granted)")
        }

        // MARK: - Medication Notifications
        MedicationNotificationManager.shared.registerCategories()
        UNUserNotificationCenter.current().delegate = self
        MedicationNotificationManager.shared.requestPermissionAndScheduleAll()

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Notification fires while app is OPEN → show full-screen alarm
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        let payloads = MedicationAlarmPayload.parsePayloads(from: userInfo)

        guard !payloads.isEmpty else {
            completionHandler([.banner, .sound])
            return
        }

        let unlogged = payloads.filter { !isDoseAlreadyLogged(doseID: $0.doseID) }
        guard !unlogged.isEmpty else {
            completionHandler([])
            return
        }

        MedicationAlarmViewController.present(payloads: unlogged)
        completionHandler([])   // suppress system banner — we show our own alarm UI
    }

    // User taps notification or action button (background / lock screen / terminated)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionID = response.actionIdentifier
        let payloads = MedicationAlarmPayload.parsePayloads(from: userInfo)

        guard !payloads.isEmpty else {
            completionHandler()
            return
        }

        switch actionID {
        case MedNotifAction.taken:
            for payload in payloads { logDoseInBackground(payload: payload, status: .taken) }
            completionHandler()

        case MedNotifAction.skipped:
            for payload in payloads { logDoseInBackground(payload: payload, status: .skipped) }
            completionHandler()

        case UNNotificationDefaultActionIdentifier:
            // Body tap → open app → show alarm screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let unlogged = payloads.filter { !self.isDoseAlreadyLogged(doseID: $0.doseID) }
                if !unlogged.isEmpty {
                    MedicationAlarmViewController.present(payloads: unlogged)
                }
                completionHandler()
            }

        default:
            completionHandler()
        }
    }

    // MARK: - Background logging (no UI)

    private func logDoseInBackground(payload: MedicationAlarmPayload, status: DoseStatus) {
        let context = PersistenceController.shared.newBackgroundContext()
        context.perform {
            let req: NSFetchRequest<Medication> = Medication.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", payload.medID as CVarArg)

            guard
                let med      = try? context.fetch(req).first,
                let doseSet  = med.doses as? Set<MedicationDose>,
                let coreDose = doseSet.first(where: { $0.id == payload.doseID })
            else { return }

            // Already taken → nothing to do
            if coreDose.doseStatus == "taken" { return }
            // Already skipped and trying to skip again → nothing to do
            if coreDose.doseStatus == "skipped" && status == .skipped { return }

            coreDose.doseStatus   = status.rawValue
            let log               = MedicationDoseLog(context: context)
            log.id                = UUID()
            log.doseScheduledTime = payload.scheduledTime
            log.doseDay           = Calendar.current.startOfDay(for: Date())
            log.doseLoggedAt      = Date()
            log.doseLogStatus     = status.rawValue
            log.dose              = coreDose
            log.medication        = med

            try? context.save()

            if status == .skipped {
                // Keep the follow-up reminder alive but reschedule it to 15 min from now
                MedicationNotificationManager.shared.cancelOnTimeNotification(forDoseID: payload.doseID)
                MedicationNotificationManager.shared.scheduleSkipFollowUp(payload: payload)
            } else {
                // Taken → cancel everything
                MedicationNotificationManager.shared.cancelNotifications(forDoseID: payload.doseID)
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("MedicationLogged"),
                    object: nil,
                    userInfo: ["doseID": payload.doseID]
                )
            }
        }
    }

    // MARK: - Logged check
    // Only suppresses alarm if "taken" — if "skipped" we still want the follow-up alarm to show.
    private func isDoseAlreadyLogged(doseID: UUID) -> Bool {
        let context = PersistenceController.shared.viewContext
        let req: NSFetchRequest<MedicationDose> = MedicationDose.fetchRequest()
        req.predicate  = NSPredicate(format: "id == %@", doseID as CVarArg)
        req.fetchLimit = 1
        guard let dose = try? context.fetch(req).first else { return false }
        return dose.doseStatus == "taken"
    }
}
