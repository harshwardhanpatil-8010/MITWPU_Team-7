

import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var circularProgressView: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    // UPDATED: Use the new 'Exercise' model
    var exercises: [WorkoutExercise] = []
    private var progressView: CircularProgressView!
    let finishedCount = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
//    let total = exercises.count
    
    // UPDATED: Logic to keep completed exercises at the bottom of the list
    private var currentSortedExercises: [WorkoutExercise] {
        let completedSet = WorkoutManager.shared.completedToday
        let topGroup = exercises.filter { !completedSet.contains($0.id) }
        let completedGroup = exercises.filter { completedSet.contains($0.id) }
        return topGroup + completedGroup
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Generate the session exercises using the algorithm logic
        WorkoutManager.shared.getTodayWorkout()
        self.exercises = WorkoutManager.shared.exercises
        
        
        setupProgressView()
        setupCollectionView()
        updateProgress()
        updateButtonUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh from manager to capture any changes in completion status
        self.exercises = WorkoutManager.shared.exercises
        collectionView.reloadData()
        let currentProgress = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
        if currentProgress == 0 {
            checkMedTaken()
        }
        updateProgress()
        updateButtonUI()
        tabBarController?.tabBar.isHidden = true
    }
  
   

    private func setupProgressView() {
        progressView = CircularProgressView(frame: circularProgressView.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        circularProgressView.addSubview(progressView)
        progressView.progressColor = .systemBlue
        progressView.trackColor = .systemGray5
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white

        let nib = UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ExerciseCollectionViewCell")

        let layout = createCompositionalLayout()
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(62)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2.5
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    func updateProgress() {
        self.view.layoutIfNeeded()
        
        let completed = WorkoutManager.shared.completedToday.count
        let skipped = WorkoutManager.shared.SkippedToday.count
        let total = exercises.count
        
        exerciseNumberLabel.text = "\(completed)/\(total)"
        
        if total > 0 {
            let totalAdvanced = CGFloat(completed + skipped)
            let progressValue = totalAdvanced / CGFloat(total)
            progressView.setProgress(progressValue)
        } else {
            progressView.setProgress(0)
        }
    }
    
    func updateButtonUI() {
        let finishedCount = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
        let total = exercises.count
        
        if finishedCount == 0 {
            startButtonOutlet.setTitle("Start Workout", for: .normal)
            startButtonOutlet.backgroundColor = .systemBlue
            startButtonOutlet.isEnabled = true
        } else if finishedCount < total {
            startButtonOutlet.setTitle("Resume Workout", for: .normal)
            startButtonOutlet.backgroundColor = .systemOrange
            startButtonOutlet.isEnabled = true
        } else {
            startButtonOutlet.setTitle("Workout Completed", for: .normal)
            startButtonOutlet.isEnabled = false
            startButtonOutlet.backgroundColor = .systemGray
        }
    }

//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        let finishedCount = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
//        let total = exercises.count
//        
//        if finishedCount == total && total > 0 {
//            WorkoutManager.shared.resetDailyProgress()
//        }
//
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
//            
//            vc.startingIndex = finishedCount
//            // Ensure the next VC also uses the [Exercise] type
//            vc.exercises = exercises
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    @IBAction func StartWorkoutTapped(_ sender: Any) {
        
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
            vc.startingIndex = finishedCount
            vc.exercises = WorkoutManager.shared.getTodayWorkout()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

//    private func showPushLimitsAlert() {
//        let alert = UIAlertController(
//            title: "Safety Check",
//            message: "Would you like to push your limits with standing exercises, or play it safe with seated exercises?",
//            preferredStyle: .alert
//        )
//        
//        let standingAction = UIAlertAction(title: "Push Limits (Standing)", style: .default) { _ in
//            WorkoutManager.shared.userWantsToPushLimits = true
//            WorkoutManager.shared.generateDailyWorkout()
//            self.navigateToWorkout()
//        }
//        
//        let seatedAction = UIAlertAction(title: "Play it Safe (Seated)", style: .default) { _ in
//            WorkoutManager.shared.userWantsToPushLimits = false
//            WorkoutManager.shared.generateDailyWorkout()
//            self.navigateToWorkout()
//        }
//        
//        alert.addAction(standingAction)
//        alert.addAction(seatedAction)
//        present(alert, animated: true)
//    }
    
    private func showPushLimitsAlert() {
        let alert = UIAlertController(
            title: "Safety Check",
            message: "Would you like to push your limits with standing exercises, or play it safe with seated exercises?",
            preferredStyle: .alert
        )
        
        let standingAction = UIAlertAction(title: "Push Limits (Standing)", style: .default) { _ in
            WorkoutManager.shared.userWantsToPushLimits = true
            WorkoutManager.shared.generateDailyWorkout()
            self.refreshWorkoutList()
        }
        
        let seatedAction = UIAlertAction(title: "Play it Safe (Seated)", style: .default) { _ in
            WorkoutManager.shared.userWantsToPushLimits = false
            WorkoutManager.shared.generateDailyWorkout()
            self.refreshWorkoutList()
        }
        
        alert.addAction(standingAction)
        alert.addAction(seatedAction)
        
        present(alert, animated: true)
    }

    // Helper method to keep code clean
    private func refreshWorkoutList() {
        // Sync local array with the manager
        self.exercises = WorkoutManager.shared.exercises
        
        // Reload the collection view to show the new exercises
        self.collectionView.reloadData()
        
        // Update progress labels (e.g., "0 of 7 completed")
        self.updateProgress()
        
        // Update the button title (e.g., from "Resume" back to "Start Workout" if needed)
        self.updateButtonUI()
    }
    
    private func checkMedTaken() {
        if !WorkoutManager.shared.allMedsTaken {
            showPushLimitsAlert()
        }
        else {
            navigateToWorkout()
        }
    }
    
    private func navigateToWorkout() {
        let finishedCount = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
        let total = WorkoutManager.shared.exercises.count

        // Reset progress only if they finished the whole thing previously
        if finishedCount == total && total > 0 {
            WorkoutManager.shared.resetDailyProgress()
        }

        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
            vc.startingIndex = finishedCount
            // Ensure the VC gets the most up-to-date exercises from the manager
            vc.exercises = WorkoutManager.shared.exercises
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource
extension _0minworkoutLandingPageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExerciseCollectionViewCell",
            for: indexPath
        ) as! ExerciseListCollectionViewCell

        let exercise = currentSortedExercises[indexPath.item]

        cell.exerciseNameOutlet.text = exercise.name
        
        // Logical check for Reps vs Seconds for UI display
        if exercise.category == .warmup || exercise.category == .cooldown {
            cell.repsOutlet.text = "\(exercise.reps)s"
        } else {
            cell.repsOutlet.text = "\(exercise.reps) Reps"
        }

        if let videoID = exercise.videoID {
            cell.loadThumbnail(videoID: videoID)
        }

        let isCompleted = WorkoutManager.shared.completedToday.contains(exercise.id)

        if isCompleted {
            cell.configureCompleted()
        } else {
            cell.configurePendingOrSkipped()
        }

        return cell
    }
}
