//
//  SceneDelegate.swift
//  Parkinsons
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        print("[SCENE] ========================================")
        print("[SCENE] willConnectTo START - \(Date())")

        guard let windowScene = (scene as? UIWindowScene) else {
            print("[SCENE] ERROR: Could not cast scene to UIWindowScene!")
            return
        }

        let window = self.window ?? UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        self.window = window
        window.backgroundColor = .systemBackground

        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        print("[SCENE] hasCompletedOnboarding = \(hasCompletedOnboarding)")

        if hasCompletedOnboarding {
            print("[SCENE] Running Green Screen Diagnostic Test...")
            let diagnosticVC = UIViewController()
            diagnosticVC.view.backgroundColor = .green
            
            let label = UILabel(frame: CGRect(x: 50, y: 200, width: 300, height: 100))
            label.text = "IF YOU SEE THIS, HOME.STORYBOARD IS BROKEN"
            label.numberOfLines = 0
            label.textColor = .white
            diagnosticVC.view.addSubview(label)
            
            window.rootViewController = diagnosticVC
            print("[SCENE] Got diagnostic VC: \(type(of: diagnosticVC))")
            
        } else {
            print("[SCENE] Loading Login storyboard → OnboardingFeatureViewController...")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let featureVC = storyboard.instantiateViewController(withIdentifier: "OnboardingFeatureViewController")
            let navVC = UINavigationController(rootViewController: featureVC)
            navVC.modalPresentationStyle = .fullScreen
            window.rootViewController = navVC
            print("[SCENE] rootViewController set to: \(type(of: navVC))")
        }
        window.makeKeyAndVisible()
        print("[SCENE] window.makeKeyAndVisible() called")
        print("[SCENE] window.rootViewController = \(String(describing: window.rootViewController))")
        print("[SCENE] willConnectTo END")
        print("[SCENE] ========================================")
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        MedicationAlarmScheduler.shared.start()
        
        // DEBUG: Print all windows and their bounds to figure out why the screen is black
        if let windowScene = scene as? UIWindowScene {
            print("[SCENE-DEBUG] --- Window Hierarchy ---")
            for (i, w) in windowScene.windows.enumerated() {
                print("[SCENE-DEBUG] Window \(i): \(type(of: w)) | frame: \(w.frame) | isKey: \(w.isKeyWindow) | rootVC: \(String(describing: w.rootViewController))")
                if let root = w.rootViewController {
                    print("[SCENE-DEBUG]   Root view frame: \(root.view.frame)")
                    if let tab = root as? UITabBarController {
                        print("[SCENE-DEBUG]   TabBar selected index: \(tab.selectedIndex)")
                    }
                }
            }
            print("[SCENE-DEBUG] ------------------------")
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("[SCENE] sceneWillResignActive")
        MedicationAlarmScheduler.shared.stop()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[SCENE] sceneWillEnterForeground START")
        // Reschedule notifications so next-day doses are always queued
        MedicationNotificationManager.shared.rescheduleAll()
        print("[SCENE] sceneWillEnterForeground END")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("[SCENE] sceneDidEnterBackground")
    }
}
