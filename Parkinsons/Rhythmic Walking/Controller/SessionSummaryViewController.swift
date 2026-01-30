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
    var sessionData: RhythmicSession?
    private var progressView: CircularProgressView!
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: timeContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        timeContainer.addSubview(progressView)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let session = sessionData, session.elapsedSeconds >= session.requestedDurationSeconds {
            showGoalCelebration()
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
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if let session = sessionData, session.elapsedSeconds >= session.requestedDurationSeconds {
//            showGoalCelebration()
//        }
//    }
    
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

    private func showGoalCelebration() {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.alpha = 0
        view.addSubview(blurView)
        
        let goalLabel = UILabel()
        goalLabel.text = "Goal Completed!"
        goalLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        goalLabel.textColor = .label
        goalLabel.textAlignment = .center
        goalLabel.center = view.center
        goalLabel.alpha = 0
        view.addSubview(goalLabel)
        
        UIView.animate(withDuration: 0.8) {
            blurView.alpha = 1.0
            goalLabel.alpha = 1.0
        }
        
        let emitter = createConfettiEmitter()
        view.layer.addSublayer(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            UIView.animate(withDuration: 1.0, animations: {
                blurView.alpha = 0
                goalLabel.alpha = 0
                goalLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                blurView.removeFromSuperview()
                goalLabel.removeFromSuperview()
                emitter.removeFromSuperlayer()
            }
        }
    }

//    private func createConfettiEmitter() -> CAEmitterLayer {
//        let emitter = CAEmitterLayer()
//        emitter.emitterPosition = CGPoint(x: view.center.x, y: -10)
//        emitter.emitterShape = .line
//        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
//        
//        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemPurple]
//        emitter.emitterCells = colors.map { color in
//            let cell = CAEmitterCell()
//            cell.birthRate = 4.0
//            cell.lifetime = 8.0
//            cell.velocity = 150
//            cell.velocityRange = 50
//            cell.emissionLongitude = .pi
//            cell.spin = 3
//            cell.scale = 0.05
//            cell.contents = drawWhiteSquare().cgImage
//            cell.color = color.cgColor
//            return cell
//        }
//        return emitter
//    }
    private func createConfettiEmitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.center.x, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)

        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemPurple]

        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 6.0            // Slightly increased birth rate for more density
            cell.lifetime = 8.0
            cell.velocity = 200             // Slightly faster fall
            cell.velocityRange = 80
            cell.emissionLongitude = .pi
            cell.spin = 4
            cell.spinRange = 2              // Adds variety to the rotation speed
            
            // --- SIZE ADJUSTMENTS ---
            cell.scale = 0.5                // Increased from 0.05 to 0.5
            cell.scaleRange = 0.2           // Sizes will vary between 0.3 and 0.7
            // ------------------------
            
            cell.contents = drawWhiteSquare().cgImage
            cell.color = color.cgColor
            return cell
        }

        return emitter
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
