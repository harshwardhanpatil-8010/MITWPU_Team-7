//
//  InfoMatchTheCardsViewController.swift
//  Parkinsons
//
//  Created by harshwardhan patil on 08/01/26.
//

import UIKit

class InfoMatchTheCardsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        // Do any additional setup after loading the view.
    }
    func setupCloseButton() {
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.leftBarButtonItem = closeButton
    }
    @objc func closeButtonTapped() {
        dismiss(animated: true)
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
