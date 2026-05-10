//
//  AppDelegate.swift
//  Parkinsons
//
//  Key additions for medication notifications:
//   1. Registers notification categories on launch (Taken / Skip actions)
//   2. Implements UNUserNotificationCenterDelegate
//      – foreground: presents the full-screen alarm
//      – background action (Taken/Skip): logs the dose without opening the app
//   3. On foregrounding (via SceneDelegate), reschedules notifications
//      so the next day's doses are always queued

import UIKit
import AVFoundation
import HealthKit
import UserNotifications
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: - Exercise JSON Version Check
        let currentJSONVersion = "1.0"
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
                .playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession FAILED: \(error)")
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

                }
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

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Called when a notification arrives while the app is in the FOREGROUND
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // Parse grouped payloads from the notification
        let payloads = MedicationAlarmPayload.parsePayloads(from: userInfo)
        
        // If this isn't a medication notification, show it normally
        guard !payloads.isEmpty else {
            completionHandler([.banner, .sound])
            return
        }

        // Filter out already-logged doses
        let unlogged = payloads.filter { !isDoseAlreadyLogged(doseID: $0.doseID) }
        
        if unlogged.isEmpty {
            // All doses already logged, suppress silently
            completionHandler([])
            return
        }

        // Present full-screen alarm instead of a banner
        MedicationAlarmViewController.present(payloads: unlogged)

        // Suppress the system banner entirely since we're showing our own UI
        completionHandler([])
    }

    // Called when the user TAPS a notification (background / lock screen)
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
            // Inline action (Taken button on the notification banner)
            for payload in payloads {
                logDoseInBackground(payload: payload, status: .taken)
            }
            completionHandler()

        case MedNotifAction.skipped:
            // Inline action (Skip button on the notification banner)
            for payload in payloads {
                logDoseInBackground(payload: payload, status: .skipped)
            }
            completionHandler()

        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body — open app and show alarm
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

    // MARK: - Background dose logging (no UI needed)

    private func logDoseInBackground(payload: MedicationAlarmPayload, status: DoseStatus) {
        // Use a background context so we don't block the main thread
        let context = PersistenceController.shared.newBackgroundContext()
        context.perform {
            let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
            medRequest.predicate = NSPredicate(format: "id == %@", payload.medID as CVarArg)

            guard
                let med      = try? context.fetch(medRequest).first,
                let doseSet  = med.doses as? Set<MedicationDose>,
                let coreDose = doseSet.first(where: { $0.id == payload.doseID })
            else { return }

            // If it's already taken, do nothing.
            // If it's skipped, allow changing to taken.
            // If it's skipped and we're trying to skip again, do nothing.
            if coreDose.doseStatus == "taken" { return }
            if coreDose.doseStatus == "skipped" && status == .skipped { return }

            coreDose.doseStatus = status.rawValue

            let log           = MedicationDoseLog(context: context)
            log.id            = UUID()
            log.doseScheduledTime = payload.scheduledTime
            log.doseDay       = Calendar.current.startOfDay(for: Date())
            log.doseLoggedAt  = Date()
            log.doseLogStatus = status.rawValue
            log.dose          = coreDose
            log.medication    = med

            try? context.save()

            if status == .skipped {
                // If skipped, we still cancel the on-time notifications but schedule a new 15-min follow-up
                MedicationNotificationManager.shared.cancelOnTimeNotification(forDoseID: payload.doseID)
                MedicationNotificationManager.shared.scheduleSkipFollowUp(payload: payload)
            } else {
                // If taken, cancel both on-time and follow-up notifications for this dose
                MedicationNotificationManager.shared.cancelNotifications(forDoseID: payload.doseID)
            }

            // Notify UI on main thread
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .medicationDoseLogged,
                    object: nil,
                    userInfo: ["doseID": payload.doseID]
                )
            }
        }
    }

    // MARK: - Check if already logged (main context)

    private func isDoseAlreadyLogged(doseID: UUID) -> Bool {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<MedicationDose> = MedicationDose.fetchRequest()
        request.predicate  = NSPredicate(format: "id == %@", doseID as CVarArg)
        request.fetchLimit = 1
        guard let dose = try? context.fetch(request).first else { return false }
        // Only consider it fully handled if it's "taken". If it's "skipped", we still want
        // follow-up reminders to be able to present themselves.
        return dose.doseStatus == "taken"
    }
}
