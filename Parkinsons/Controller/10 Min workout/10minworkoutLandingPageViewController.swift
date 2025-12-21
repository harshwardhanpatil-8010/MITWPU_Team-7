//
//  10minworkoutLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class _0minworkoutLandingPageViewController: UIViewController{

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var circularProgressView: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    var exercises: [Exercise] = []
    private var progressView: CircularProgressView!
    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularProgressView.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularProgressView.addSubview(progressView)
    }
   
    let allExercises = WorkoutManager.shared.exercises
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exercises = WorkoutManager.shared.getTodayWorkout()
       setupProgressView()
        tableView.dataSource = self
        tableView.reloadData()
        tableView.layer.cornerRadius = 20
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor.systemGray6
        progressView.progressColor = .systemBlue
        progressView.trackColor = .systemGray5
        updateProgress()
   
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exercises = WorkoutManager.shared.getTodayWorkout()
        tableView.reloadData()
        updateProgress()
        updateButtonUI()
    }

    func updateProgress() {
        let completed = WorkoutManager.shared.completedToday.count
        let total = exercises.count
        exerciseNumberLabel.text = "\(completed)/\(total)"
        let progress = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)
        progressView.setProgress(progress)
        if completed == total && total > 0 {
           handleWorkoutCompletionUI()
        } else {
            progressView.progressColor = .systemBlue
        }
    }
    func updateButtonUI() {
        let completed = WorkoutManager.shared.completedToday.count
        let total = exercises.count
        if total == 0 || completed == 0{
            startButtonOutlet.setTitle("Start Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        } else if completed < total{
            startButtonOutlet.setTitle("Resume Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        } else {
            startButtonOutlet.setTitle("Workout Completed", for: .normal)
            startButtonOutlet.isEnabled = false
        }
    }
    
    func handleWorkoutCompletionUI() {
        progressView.progressColor = .systemBlue
        startButtonOutlet.setTitle("Workout Completed", for: .normal)
        startButtonOutlet.isEnabled = false
    }
    
    @IBAction func StartWorkoutTapped(_ sender: Any) {
        let completed = WorkoutManager.shared.completedToday.count
        let total = exercises.count
        
        //Progress of the particular day
        if completed == total && total > 0 {
            WorkoutManager.shared.completedToday.removeAll()
            WorkoutManager.shared.SkippedToday.removeAll()
        }
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as! _0minworkoutCountdownViewController
        vc.startingIndex = completed
        vc.exercises = exercises
        navigationController?.pushViewController(vc, animated: true)
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

extension _0minworkoutLandingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previewCell", for: indexPath) as! ExerciseTableViewCell
          
        let exercise = exercises[indexPath.row]
        cell.exerciseNameLabel.text = exercise.name
        cell.repsLabel.text = "\(exercise.reps) reps"
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = false
        if let videoID = exercise.videoID {
            cell.loadThumbnail(videoID: videoID)
        }
        let completed =  WorkoutManager.shared.completedToday.contains(exercise.id)
        let skipped = WorkoutManager.shared.SkippedToday.contains(exercise.id)
        if completed {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
            cell.checkMarkImageOutlet.tintColor = .systemBlue
        } else if skipped {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
            cell.checkMarkImageOutlet.tintColor = .systemGray
        } else {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
            cell.checkMarkImageOutlet.tintColor = .systemGray
        }
        return cell
    }
}
