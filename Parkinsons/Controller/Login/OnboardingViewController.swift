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
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "HomePage"
        ) as! HomeViewController

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
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
