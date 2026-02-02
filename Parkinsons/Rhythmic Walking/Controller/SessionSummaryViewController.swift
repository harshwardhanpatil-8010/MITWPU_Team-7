//
//  SessionSummaryViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SessionSummaryViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var walkingUIView: UIView!
    @IBOutlet weak var GaitUIView: UIView!
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var stepsTaken: UILabel!
    @IBOutlet weak var distanceCovered: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var stepsLength: UILabel!
    @IBOutlet weak var walkingAsymmetry: UILabel!
    @IBOutlet weak var walkingSteadiness: UILabel!
    @IBOutlet weak var stepLengthPercent: UILabel!
    @IBOutlet weak var walkingAsymmetryPercent: UILabel!
    @IBOutlet weak var walkingSteadinessPercent: UILabel!
    @IBOutlet weak var goalCompletedTLabel: UIStackView!
    
    var sessionData: RhythmicSession?
    private var progressView: CircularProgressView!
    private var dimmingOverlay: UIView?
    
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: timeContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeContainer.addSubview(progressView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        goalCompletedTLabel.isHidden = true
        if let session = sessionData, session.elapsedSeconds >= session.requestedDurationSeconds {
            showConfetti()
        }
        setupProgressView()
        walkingUIView.applyCardStyle()
        GaitUIView.applyCardStyle()
        loadData()
        progressView.progressColor = UIColor(hex: "90AF81")
        progressView.lineWidth = 15
        progressView.trackColor = UIColor(hex: "90AF81", alpha: 0.3)
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    func loadData() {
        guard let session = sessionData else {
            timeLabel.text = "00:00:00"
            progressView.setProgress(0.0)
            return
        }
        let elapsedSeconds = session.elapsedSeconds
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
        let progress = session.requestedDurationSeconds > 0 ? Float(elapsedSeconds) / Float(session.requestedDurationSeconds) : 1.0
        progressView.setProgress(CGFloat(progress))
        
        stepsTaken.text = "2513"
        distanceCovered.text = "2 km"
        speed.text = "3 km/h"
        stepsLength.text = gaitDemoInfo.stepLengthMeters.description
        walkingAsymmetry.text = gaitDemoInfo.walkingAsymmetryPercent.description
        walkingSteadiness.text = gaitDemoInfo.walkingSteadiness.description
        stepLengthPercent.text = "12 %"
        walkingAsymmetryPercent.text = "0.5 %"
        walkingSteadinessPercent.text = "5 %"
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

//    private func showConfetti() {
//        // 1. Use .dark or .regular for a more noticeable blur
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurEffectView = UIVisualEffectView(effect: nil)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
//        
//        // 2. Setup Confetti Layer
//        let confettiLayer = CAEmitterLayer()
//        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
//        confettiLayer.emitterShape = .line
//        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)
//
//        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow, .systemPink]
//        confettiLayer.emitterCells = colors.map { color in
//            let cell = CAEmitterCell()
//            cell.birthRate = 6
//            cell.lifetime = 10
//            cell.velocity = 180
//            cell.velocityRange = 60
//            cell.emissionLongitude = .pi
//            cell.emissionRange = .pi / 4
//            cell.spin = 3
//            cell.spinRange = 4
//            cell.scale = 0.05
//            cell.scaleRange = 0.03
//            cell.color = color.cgColor
//            cell.contents = defaultConfettiImage().cgImage
//            return cell
//        }
//
//        // Add confetti ABOVE the blur but BELOW the label
//        view.layer.addSublayer(confettiLayer)
//        
//        // 3. Bring your Label to the absolute front
//        view.bringSubviewToFront(goalCompletedTLabel)
//        
//        // 4. Show the Label & Blur with animation
//        goalCompletedTLabel.isHidden = false
//        goalCompletedTLabel.alpha = 1.0
//        goalCompletedTLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        
//        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//            self.goalCompletedTLabel.transform = .identity
//            blurEffectView.effect = blurEffect
//        }, completion: nil)
//
//        // 5. STOP creating new confetti after 4 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
//            confettiLayer.birthRate = 0
//        }
//
//        // 6. WAIT 15 seconds, then fade out
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            UIView.animate(withDuration: 1.5, animations: {
//                self.goalCompletedTLabel.alpha = 0
//                blurEffectView.effect = nil
//                blurEffectView.alpha = 0 // Extra safety to ensure it disappears
//            }) { _ in
//                self.goalCompletedTLabel.isHidden = true
//                blurEffectView.removeFromSuperview()
//                confettiLayer.removeFromSuperlayer()
//            }
//        }
//    }
    
    private func showConfetti() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        blurEffectView.alpha = 0
        view.addSubview(blurEffectView)
        
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 2)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow, .systemPink]
        confettiLayer.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6
            cell.lifetime = 10
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
        view.bringSubviewToFront(goalCompletedTLabel)
        
        // 3. Show with "Soft" intensity
        goalCompletedTLabel.isHidden = false
        goalCompletedTLabel.alpha = 1.0
        goalCompletedTLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.goalCompletedTLabel.transform = .identity
            blurEffectView.alpha = 0.9
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            confettiLayer.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            UIView.animate(withDuration: 1.0, animations: {
                self.goalCompletedTLabel.alpha = 0
                blurEffectView.alpha = 0
            }) { _ in
                self.goalCompletedTLabel.isHidden = true
                blurEffectView.removeFromSuperview()
                confettiLayer.removeFromSuperlayer()
            }
        }
    }
    
    private func defaultConfettiImage() -> UIImage {
        let size = CGSize(width: 32, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.white.cgColor)

            if Bool.random() {
                ctx.fill(CGRect(origin: .zero, size: size))
            } else {
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                ctx.addArc(
                    center: center,
                    radius: radius,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: false
                )
                ctx.fillPath()
            }
        }
    }



    private func drawWhiteSquare() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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
