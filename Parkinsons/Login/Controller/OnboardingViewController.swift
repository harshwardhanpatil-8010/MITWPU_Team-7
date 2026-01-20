//
//  OnboardingViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class OnboardingViewController: UIViewController {

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
        
    }
    
    func navigateToHomeScreen() {
        let homeStoryboard = UIStoryboard(name: :"Home", bundle: nil)
        guard let mainTabBarController = homeStoryboard.instantiateInitialViewController()  else {
            return
        }
        if let window = view.window {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
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

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if currentIndex < features.count - 1 {
            currentIndex += 1
            onboardingChange()
            progressBars[currentIndex].setProgress(1.0, animated: true)
            
        } else {
            dismiss(animated: true)
            progressBars[currentIndex].setProgress(1.0, animated: true)
        } if continueButtonOutlet.title(for: .normal) == "Done" {
            progressBars.last?.setProgress(1.0, animated: true)
            navigateToHomeScreen()
        }
    }
    
    
    @IBAction func skipTapped(_ sender: UIButton) {
        navigateToHomeScreen()
    }
    
   

}
