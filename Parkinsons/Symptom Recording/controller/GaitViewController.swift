//
//  GaitViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class GaitViewController: UIViewController {

    @IBOutlet weak var GaitImageView: UIImageView!
    @IBOutlet weak var GaitSegmentControl: UISegmentedControl!
    @IBOutlet weak var GaitCardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        GaitCardView.applyCardStyle()
        setupNavigationBar()
        GaitImageView.image = UIImage(named: "Gait Graph")
    }

    private func setupNavigationBar() {
        // Title
        title = "Gait Disturbance"

        // Back button
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
                case 0:
            GaitImageView.image = UIImage(named: "Gait Graph")

                case 1:
            GaitImageView.image = UIImage(named: "Gait1")

                case 2:
            GaitImageView.image = UIImage(named: "Gait2")
                
                case 3:
                GaitImageView.image = UIImage(named: "Gait3")
            
                case 4:
                GaitImageView.image = UIImage(named: "Gait4")


                default:
                    break
                }
    }
}

