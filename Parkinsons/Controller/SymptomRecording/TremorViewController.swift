//
//  TremorViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class TremorViewController: UIViewController {

    @IBOutlet weak var TremorImageView: UIImageView!
    @IBOutlet weak var TremorSegmentControl: UISegmentedControl!
    @IBOutlet weak var TremorCardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        TremorCardView.applyCardStyle()
        setupNavigationBar()
        TremorImageView.image = UIImage(named: "Tremor Graph")
    }

    private func setupNavigationBar() {
        // Title
        title = "Tremors"

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
            TremorImageView.image = UIImage(named: "Tremor Graph")

                case 1:
            TremorImageView.image = UIImage(named: "Tremor1")

                case 2:
            TremorImageView.image = UIImage(named: "Tremor2")
                
                case 3:
            TremorImageView.image = UIImage(named: "Tremor3")
            
                case 4:
            TremorImageView.image = UIImage(named: "Tremor4")


                default:
                    break
                }
    }
}

