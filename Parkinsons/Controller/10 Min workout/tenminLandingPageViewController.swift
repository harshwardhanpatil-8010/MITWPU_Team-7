//
//  tenminLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class tenminLandingPageViewController: UIViewController {
    var exercises: [Exercise] = []
    @IBOutlet weak var UICollectionViewOutlet: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        exercises = WorkoutManager.shared.getTodayWorkout()
        // Do any additional setup after loading the 
    }
    
   

    
    
}
