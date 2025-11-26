//
//  10minworkoutViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit
import WebKit
class _0minworkoutViewController: UIViewController {
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var workoutNavigation: UINavigationItem!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var repsLabel: UILabel!
    
    @IBOutlet weak var skipButton: UIButton!
    
    var timer: Timer?
    var totalTime = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        workoutNavigation.leftBarButtonItem = closeButton
        Starttimer()
        loadYouTubeVideo()
        configureWebView()
        //updateProgress(step: 1)
       // progressBar(step: 1)
//        let videoID = "gLptmcuCx6Q"   // Replace with your video ID
//        let embedURLString = "https://www.youtube.com/embed/\(videoID)"
//        
//        if let url = URL(string: embedURLString) {
//            let request = URLRequest(url: url)
//            webView.load(request)
            // Do any additional setup after loading the view.
        }
    func configureWebView() {
            let config = WKWebViewConfiguration()
            config.allowsInlineMediaPlayback = true
            config.mediaTypesRequiringUserActionForPlayback = []
            
            webView.configuration.preferences.javaScriptEnabled = true
            webView.configuration.allowsInlineMediaPlayback = true
        }
        
        func loadYouTubeVideo() {
                let embedHTML = """
                <html>
                <body style="margin:0px;padding:0px;">
                <iframe width="560" height="315" src="https://www.youtube.com/embed/gLptmcuCx6Q?si=dWdzzPTE5iYUyxf_" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
                </body>
                </html>
                """

                webView.loadHTMLString(embedHTML, baseURL: nil)
            }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         
         */
    func updateProgress(step: Int) {
        
        stepLabel.text = "1 of 10"
    }
    func Starttimer() {
        totalTime = 60 // Reset to 60 if needed
           timerLabel.text = "\(totalTime)"
           
           timer = Timer.scheduledTimer(timeInterval: 1.0,
                                        target: self,
                                        selector: #selector(updateTimer),
                                        userInfo: nil,
                                        repeats: true)
    }
    @objc func updateTimer() {
        if totalTime > 0 {
            totalTime -= 1
            timerLabel.text = "\(totalTime)"
        } else {
            timer?.invalidate()
            timer = nil
            // You can also navigate to next screen or trigger any action
        }
    }

//    func progressBar(step: Int) {
//        progress_1.progress = 0.0
//    }
    @objc func closeButtonTapped() {
        let alert = UIAlertController(
               title: "Quit Workout?",
               message: "Are you sure you want to quit the workout?",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
               self.dismiss(animated: true) // or pop
           }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

           present(alert, animated: true)
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "10minworkoutViewController", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "RestScreenViewController") as! RestScreenViewController
         navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
              title: "Rest Screen Info",
              message: "This rest screen helps you recover between exercises. You can add extra time, and the timer will continue automatically.",
              preferredStyle: .alert
          )
          
        
          
          present(alert, animated: true)
    }
    func showInfoModal(for exercise: ExerciseDetail) {
        let storyboard = UIStoryboard(name: "10minworkoutViewController", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "InfoModalViewController") as! InfoModalViewController
        modalVC.exerciseDetail = exercise   // 👈 Pass data
        modalVC.modalPresentationStyle = .overCurrentContext
        present(modalVC, animated: true)
    }
}

