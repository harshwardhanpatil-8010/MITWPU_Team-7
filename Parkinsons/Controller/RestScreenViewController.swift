//
//  RestScreenViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import YouTubeiOSPlayerHelper

class RestScreenViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var playerView: FullScreenYTPlayerView!
    weak var delegate: RestScreenDelegate?
    var currentIndex: Int = 0
    var totalExercises: Int = 0
    var videoID = "jyOk-2DmVnU"
    
      var timer: Timer?
      var totalTime = 60
      
      override func viewDidLoad() {
          super.viewDidLoad()
          backgroundView.layer.cornerRadius = 35
          backgroundView.clipsToBounds = true
        
         
          updateTimerLabel()
          startTimer()
          setupCloseButton()
          load()
          playerView.isUserInteractionEnabled = false
      }
      
    func load() {
           playerView.load(
               withVideoId: videoID,
               playerVars: [
                   "controls": 0,
                   "modestbranding": 1,
                   "playsinline": 1,
                   "rel": 0,
                   "fs": 0,
                   "iv_load_policy": 3,
                   "disablekb": 1,
                   "showinfo": 0,
                   "autoplay": 1,
                   "loop": 1,
                   "playlist": videoID
               ]
           )
       }
      // MARK: - Setup Navigation Button
//      func setupNavigationButton() {
//          let closeButton = UIBarButtonItem(
//              image: UIImage(systemName: "xmark"),
//              style: .plain,
//              target: self,
//              action: #selector(closeButtonTapped)
//          )
//          restNavigation.leftBarButtonItem = closeButton
//      }
      
      // MARK: - Timer Setup
      func startTimer() {
          timer?.invalidate() // stop previous if any
          
          timer = Timer.scheduledTimer(
              timeInterval: 1.0,
              target: self,
              selector: #selector(updateTimer),
              userInfo: nil,
              repeats: true
          )
      }
      
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            timer?.invalidate()
            delegate?.restCompleted(nextIndex: currentIndex + 1)
            navigationController?.popViewController(animated: true)
        }
    }

      
    func updateTimerLabel() {
          timerLabel.text = "\(totalTime)"
      }
    
    func setupCloseButton() {
            // Use the system image for a consistent "close" icon
            let closeImage = UIImage(systemName: "xmark")
            
            let closeButton = UIBarButtonItem(
                image: closeImage,
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped) // This calls the function below when tapped
            )
            
            navigationItem.leftBarButtonItem = closeButton
        }


      // MARK: - Button Actions
      @IBAction func addTimeButtonTapped(_ sender: UIButton) {
          totalTime += 20      // 🔹 Simply add time, timer keeps running
          updateTimerLabel()
      }

      // MARK: - Quit Button Alert
      @objc func closeButtonTapped() {
          let alert = UIAlertController(
              title: "Quit Workout?",
              message: "Are you sure you want to quit the workout?",
              preferredStyle: .alert
          )
          
          alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
              self.dismiss(animated: true)
          }))
          
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          
          present(alert, animated: true)
      }
  }
