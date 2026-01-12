

import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var exercises: [WorkoutExercise] = []
    
    private var progressView: CircularProgressView!
    private var finishedCount: Int {
        return WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
    }
    
    private var currentSortedExercises: [WorkoutExercise] {
        let completedSet = WorkoutManager.shared.completedToday
        let topGroup = exercises.filter { !completedSet.contains($0.id) }
        let completedGroup = exercises.filter { completedSet.contains($0.id) }
        return topGroup + completedGroup
    }
    
    private func setupProgressView() {
        progressView = CircularProgressView(frame: progressContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressContainer.addSubview(progressView)
        
        // Set colors AFTER adding to view hierarchy
        progressView.progressColor = UIColor(hex: "0088FF")
        progressView.trackColor = UIColor(hex: "0088FF", alpha: 0.3)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        self.exercises = WorkoutManager.shared.exercises
        setupCollectionView()
        updateProgress()
        updateButtonUI()
    }
    

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        progressView.frame = progressContainer.bounds
//
//        progressView.trackColor = .systemGray5
//        progressView.progressColor = UIColor(hex: "#0088FF")
//
//    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.exercises = WorkoutManager.shared.exercises
        collectionView.reloadData()
        
        let currentProgress = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
//        if currentProgress == 0 && !hasCheckedSafety {
//            hasCheckedSafety = true
//            checkMedTaken()
//        }
        if currentProgress == 0 && !WorkoutManager.shared.hasCheckedSafetyThisSession {
            WorkoutManager.shared.hasCheckedSafetyThisSession = true
            checkMedTaken()
        }
        updateProgress()
        updateButtonUI()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
   

//    private func setupProgressView() {
//        progressView = CircularProgressView(frame: circularProgressView.bounds)
//        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        circularProgressView.addSubview(progressView)
////        progressView.progressColor = .systemBlue
//        
//    }

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

//    
//    func updateButtonUI() {
//        let finishedCount = WorkoutManager.shared.completedToday.count + WorkoutManager.shared.SkippedToday.count
//        let skippedCount = WorkoutManager.shared.SkippedToday.count
//        let total = exercises.count
//        
//        if finishedCount == 0 {
//            startButtonOutlet.setTitle("Start Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        }
//        else if finishedCount < total || (finishedCount == total && skippedCount > 0) {
//            startButtonOutlet.setTitle("Resume Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        }
//        else {
//            startButtonOutlet.setTitle("Workout Completed", for: .normal)
//            startButtonOutlet.isEnabled = false
//        }
//    }

    func updateButtonUI() {
        let completedCount = WorkoutManager.shared.completedToday.count
        let skippedCount = WorkoutManager.shared.SkippedToday.count
        let total = exercises.count
        
        if completedCount == 0 && skippedCount == 0 {
            startButtonOutlet.setTitle("Start Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        }
        
        else if completedCount < total {
            startButtonOutlet.setTitle("Resume Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        }
        
        else {
            startButtonOutlet.setTitle("Workout Completed", for: .normal)
            startButtonOutlet.isEnabled = false
        }
    }
    
//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
//            vc.startingIndex = finishedCount
//            vc.exercises = WorkoutManager.shared.getTodayWorkout()
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
//            
//            // FIND THE FIRST INCOMPLETE INDEX
//            // We look for the first exercise ID that is NOT in the completedToday list.
//            // This will naturally be either the first skipped exercise or the first "never-seen" exercise.
//            let firstIncompleteIndex = exercises.firstIndex { exercise in
//                !WorkoutManager.shared.completedToday.contains(exercise.id)
//            } ?? 0 // Default to 0 if everything is somehow finished
//            
//            vc.startingIndex = firstIncompleteIndex
//            vc.exercises = WorkoutManager.shared.exercises // Use the master list from Manager
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
    
    
//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
//            
//            // Logic: Find the first exercise ID that is NOT in completedToday.
//            // This will automatically find the first skipped OR first never-touched exercise.
//            let firstIncompleteIndex = exercises.firstIndex { exercise in
//                !WorkoutManager.shared.completedToday.contains(exercise.id)
//            } ?? 0
//
//            vc.startingIndex = firstIncompleteIndex
//            vc.exercises = WorkoutManager.shared.exercises
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
    
    @IBAction func StartWorkoutTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
            
            // Find the first exercise that hasn't been COMPLETED
            // (This includes those that were skipped)
            let firstIncompleteIndex = exercises.firstIndex { exercise in
                !WorkoutManager.shared.completedToday.contains(exercise.id)
            } ?? 0

            vc.startingIndex = firstIncompleteIndex
            vc.exercises = WorkoutManager.shared.exercises
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

    private func refreshWorkoutList() {
        // Sync local array with the manager
        self.exercises = WorkoutManager.shared.exercises
        self.collectionView.reloadData()
        self.updateProgress()
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
        if finishedCount == total && total > 0 {
            WorkoutManager.shared.resetDailyProgress()
        }

        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as? _0minworkoutCountdownViewController {
            vc.startingIndex = finishedCount
            vc.exercises = WorkoutManager.shared.exercises
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

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
