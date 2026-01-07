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
    @IBOutlet var progressBars: [UIProgressView]!
    
   
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBars.first?.setProgress(1, animated: true)
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
            skipButtonOutlet.isEnabled = false
            skipButtonOutlet.isHidden = true
        } else {
            continueButtonOutlet.setTitle("Continue", for: .normal)
            skipButtonOutlet.isHidden = false
        }
    }
    func navigateToHomeScreen() {
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
<<<<<<< HEAD:Parkinsons/Login/Controller/OnboardingViewController.swift
        guard let mainTabBarController = homeStoryboard.instantiateInitialViewController() else{
            return
        }
        if let window = view.window {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
=======
        
        guard let mainTabBarController = homeStoryboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from Home storyboard.")
            return
        }
        
        // Change the root view controller to the main app interface
        if let window = view.window {
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
>>>>>>> 7d17d64 (new):Parkinsons/Controller/Login/OnboardingViewController.swift
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
        }
        if continueButtonOutlet.title(for: .normal) == "Done" {
            progressBars.last?.setProgress(1.0, animated: true)
                navigateToHomeScreen()
            
        }
        
    }
    
    
    @IBAction func skipTapped(_ sender: UIButton) {
        navigateToHomeScreen()
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
