//
//  10minworkoutLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

//import UIKit
//
//class _0minworkoutLandingPageViewController: UIViewController{
//
//    @IBOutlet weak var startButtonOutlet: UIButton!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var circularProgressView: UIView!
//    @IBOutlet weak var exerciseNumberLabel: UILabel!
//    var exercises: [Exercise] = []
//    private var progressView: CircularProgressView!
//    private func setupProgressView() {
//        progressView = CircularProgressView(frame: circularProgressView.bounds)
//        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        circularProgressView.addSubview(progressView)
//    }
//   
//    let allExercises = WorkoutManager.shared.exercises
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        exercises = WorkoutManager.shared.getTodayWorkout()
//       setupProgressView()
//        tableView.dataSource = self
//        tableView.reloadData()
//        tableView.layer.cornerRadius = 20
//        tableView.clipsToBounds = true
//        tableView.backgroundColor = UIColor.systemGray6
//        progressView.progressColor = .systemBlue
//        progressView.trackColor = .systemGray5
//        updateProgress()
//   
//        // Do any additional setup after loading the view.
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        exercises = WorkoutManager.shared.getTodayWorkout()
//        tableView.reloadData()
//        updateProgress()
//        updateButtonUI()
//    }
//
//    func updateProgress() {
//        let completed = WorkoutManager.shared.completedToday.count
//        let total = exercises.count
//        exerciseNumberLabel.text = "\(completed)/\(total)"
//        let progress = total == 0 ? 0 : CGFloat(completed) / CGFloat(total)
//        progressView.setProgress(progress)
//        if completed == total && total > 0 {
//           handleWorkoutCompletionUI()
//        } else {
//            progressView.progressColor = .systemBlue
//        }
//    }
//    func updateButtonUI() {
//        let completed = WorkoutManager.shared.completedToday.count
//        let total = exercises.count
//        if total == 0 || completed == 0{
//            startButtonOutlet.setTitle("Start Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        } else if completed < total{
//            startButtonOutlet.setTitle("Resume Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        } else {
//            startButtonOutlet.setTitle("Workout Completed", for: .normal)
//            startButtonOutlet.isEnabled = false
//        }
//    }
//    
//    func handleWorkoutCompletionUI() {
//        progressView.progressColor = .systemBlue
//        startButtonOutlet.setTitle("Workout Completed", for: .normal)
//        startButtonOutlet.isEnabled = false
//    }
//    
//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        let completed = WorkoutManager.shared.completedToday.count
//        let total = exercises.count
//        
//        //Progress of the particular day
//        if completed == total && total > 0 {
//            WorkoutManager.shared.completedToday.removeAll()
//            WorkoutManager.shared.SkippedToday.removeAll()
//        }
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as! _0minworkoutCountdownViewController
//        vc.startingIndex = completed
//        vc.exercises = exercises
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//
//    /*
//    // MARK: - Navigation
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//
//}
//
//extension _0minworkoutLandingPageViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return exercises.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "previewCell", for: indexPath) as! ExerciseTableViewCell
//          
//        let exercise = exercises[indexPath.row]
//        cell.exerciseNameLabel.text = exercise.name
//        cell.repsLabel.text = "\(exercise.reps) reps"
//        cell.selectionStyle = .none
//        cell.isUserInteractionEnabled = false
//        if let videoID = exercise.videoID {
//            cell.loadThumbnail(videoID: videoID)
//        }
//        let completed =  WorkoutManager.shared.completedToday.contains(exercise.id)
//        let skipped = WorkoutManager.shared.SkippedToday.contains(exercise.id)
//        if completed {
//            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
//            cell.checkMarkImageOutlet.tintColor = .systemBlue
//        } else if skipped {
//            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
//            cell.checkMarkImageOutlet.tintColor = .systemGray
//        } else {
//            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark")
//            cell.checkMarkImageOutlet.tintColor = .systemGray
//        }
//        return cell
//    }
//}
import UIKit

class _0minworkoutLandingPageViewController: UIViewController {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var circularProgressView: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    
    var exercises: [WorkoutExercise] = []
    private var progressView: CircularProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.layer.cornerRadius = 20
        tableView.backgroundColor = .systemGray6
        
        progressView = CircularProgressView(frame: circularProgressView.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularProgressView.addSubview(progressView)
    }

    private func refreshData() {
        // Fetches from the corrected Manager
        exercises = WorkoutManager.shared.getTodayWorkout()
        tableView.reloadData()
        
        let completedCount = WorkoutManager.shared.completedToday.count
        let totalCount = exercises.count
        
        exerciseNumberLabel.text = "\(completedCount)/\(totalCount)"
        let progress = totalCount == 0 ? 0 : CGFloat(completedCount) / CGFloat(totalCount)
        progressView.setProgress(progress)
        
        updateButtonUI(completed: completedCount, total: totalCount)
    }

    private func updateButtonUI(completed: Int, total: Int) {
        if total > 0 && completed == total {
            startButtonOutlet.setTitle("Workout Completed", for: .normal)
            startButtonOutlet.isEnabled = false
            startButtonOutlet.alpha = 0.6
        } else {
            let title = completed > 0 ? "Resume Workout" : "Start Workout"
            startButtonOutlet.setTitle(title, for: .normal)
            startButtonOutlet.isEnabled = true
            startButtonOutlet.alpha = 1.0
        }
    }

    @IBAction func StartWorkoutTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
            vc.startingIndex = WorkoutManager.shared.completedToday.count
            vc.exercises = self.exercises
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension _0minworkoutLandingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "previewCell", for: indexPath) as? ExerciseTableViewCell else {
            return UITableViewCell()
        }
        
        let exercise = exercises[indexPath.row]
        let isDone = WorkoutManager.shared.completedToday.contains(exercise.id)
        let isSkipped = WorkoutManager.shared.SkippedToday.contains(exercise.id)
        
        cell.exerciseNameLabel.text = exercise.name
        cell.repsLabel.text = "\(exercise.reps) reps"
        
        // Visual State Logic
        if isDone {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "checkmark.circle.fill")
            cell.checkMarkImageOutlet.tintColor = .systemBlue
        } else if isSkipped {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "xmark.circle")
            cell.checkMarkImageOutlet.tintColor = .systemGray
        } else {
            cell.checkMarkImageOutlet.image = UIImage(systemName: "circle")
            cell.checkMarkImageOutlet.tintColor = .systemGray4
        }
        
        cell.loadThumbnail(videoID: exercise.videoID ?? "")
        return cell
    }
}
