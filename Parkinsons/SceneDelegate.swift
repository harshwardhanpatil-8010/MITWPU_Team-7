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
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = self.window ?? UIWindow(windowScene: windowScene)
        window.frame = windowScene.coordinateSpace.bounds
        self.window = window
        window.backgroundColor = .systemBackground

        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if hasCompletedOnboarding {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            

            tabBarVC.view.frame = window.bounds
            tabBarVC.selectedIndex = 0
            

            if let firstTab = tabBarVC.viewControllers?.first {
                firstTab.loadViewIfNeeded()
            }
            
            window.rootViewController = tabBarVC
            
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let featureVC = storyboard.instantiateViewController(withIdentifier: "OnboardingFeatureViewController")
            let navVC = UINavigationController(rootViewController: featureVC)
            navVC.modalPresentationStyle = .fullScreen
            window.rootViewController = navVC
        }
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {
        MedicationAlarmScheduler.shared.start()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        MedicationAlarmScheduler.shared.stop()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
        MedicationNotificationManager.shared.rescheduleAll()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
