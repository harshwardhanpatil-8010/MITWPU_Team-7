//
//  RestScreenViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class RestScreenViewController: UIViewController {

    @IBOutlet weak var restNavigation: UINavigationItem!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var addTimeButton: UIButton!
    
    
      var timer: Timer?
      var totalTime = 60
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          setupNavigationButton()
          //updateTimerLabel()
          startTimer()
      }
      
      // MARK: - Setup Navigation Button
      func setupNavigationButton() {
          let closeButton = UIBarButtonItem(
              image: UIImage(systemName: "xmark"),
              style: .plain,
              target: self,
              action: #selector(closeButtonTapped)
          )
          restNavigation.leftBarButtonItem = closeButton
      }
      
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
              //updateTimerLabel()
          } else {
              timer?.invalidate()
              timer = nil
              dismiss(animated: true)
          }
      }
      
      func updateTimerLabel() {
          timerLabel.text = "\(totalTime)sec"
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
