//
//  OnboardingFeatureViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 13/02/26.
//

import UIKit

class OnboardingFeatureViewController: UIViewController {

   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var featureName: UILabel!
    @IBOutlet weak var featureDescription: UILabel!
    @IBOutlet weak var continueButtonOutlet: UIButton!
    @IBOutlet weak var skipButtonOutlet: UIButton!
    @IBOutlet weak var progressBar1: UIProgressView!
    @IBOutlet weak var progressBar2: UIProgressView!
    @IBOutlet weak var progressBar3: UIProgressView!
    @IBOutlet weak var progressBar4: UIProgressView!
    
    
    var progressBars: [UIProgressView] = []
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBars = [progressBar1, progressBar2, progressBar3, progressBar4]
        progressBar1.setProgress(1.0, animated: true)
        onboardingChange()
        imageView.layer.cornerRadius = 83
        imageView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    
    
    func onboardingChange() {
        let feature =  features[currentIndex]
       
        imageView.image = feature.image
        featureName.text = feature.name
        featureDescription.text = feature.description
        if currentIndex == features.count - 1 {
            continueButtonOutlet.setTitle("Done", for: .normal)
            skipButtonOutlet.isHidden = true
        } else {
            continueButtonOutlet.setTitle("Continue", for: .normal)
            skipButtonOutlet.isHidden = false
        }
    }

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "HomeTabBar")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            
            sceneDelegate.window?.rootViewController = tabBarVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if currentIndex < features.count - 1 {
            currentIndex += 1
            onboardingChange()
            progressBars[currentIndex].setProgress(1.0, animated: true)
            
        } else {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
           navigateToHome()
            progressBars[currentIndex].setProgress(1.0, animated: true)
        }
    }
    
    
    @IBAction func skipTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
      navigateToHome()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
