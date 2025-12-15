//
//  SuccessViewControllerViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var FinishButton: UIButton!
    var timeTaken: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     timeTakenLabel.text = "\(timeTaken!)Secs"
        showConfetti()
        

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
    }

    private func showConfetti() {
         let confettiLayer = CAEmitterLayer()
         confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
         confettiLayer.emitterShape = .line
         confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

         let colors: [UIColor] = [
             .systemRed, .systemBlue, .systemGreen,
             .systemOrange, .systemPurple, .systemYellow
         ]

         confettiLayer.emitterCells = colors.map { color in
             let cell = CAEmitterCell()
             cell.birthRate = 6
             cell.lifetime = 6.0
             cell.velocity = 180
             cell.velocityRange = 60
             cell.emissionLongitude = .pi
             cell.emissionRange = .pi / 4
             cell.spin = 3
             cell.spinRange = 4
             cell.scale = 0.05
             cell.scaleRange = 0.03
             cell.color = color.cgColor
             cell.contents = defaultConfettiImage().cgImage
             return cell
         }

         view.layer.addSublayer(confettiLayer)

         // Stop after 3 seconds (HIG friendly)
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
             confettiLayer.birthRate = 0
         }
     }
    
    private func defaultConfettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20) // ⬅️ bigger
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.white.cgColor)

            if Bool.random() {
                // Rectangle
                ctx.fill(CGRect(origin: .zero, size: size))
            } else {
                // Rounded confetti
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.addArc(center: center,
                           radius: radius,
                           startAngle: 0,
                           endAngle: .pi * 2,
                           clockwise: false)
                ctx.fillPath()
            }
        }
    }



    @IBAction func FinishButtonAction(_ sender: UIButton) {
        
         if let existingLandingVC = self.navigationController?.viewControllers.first(where: { vc in
             return vc is LevelSelectionViewController
         }) {
             // Case 1: SUCCESSFUL POP
             // If LevelSelectionViewController is found, you pop to it.
             // The chevron *should* be visible because HomeVC is still below it.
             self.navigationController?.popToViewController(existingLandingVC, animated: true)
         } else {
             // Case 2: FAILURE (The LevelSelectionViewController was NOT found)
             let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
             let homeVC = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as! LevelSelectionViewController
             // ⭐️ ISSUE: This line replaces the entire navigation stack! ⭐️
             self.navigationController?.setViewControllers([homeVC], animated: true)
         }
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
