//import UIKit
//
//class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {
//
//    @IBOutlet weak var startButtonOutlet: UIButton!
//    @IBOutlet weak var progressContainer: UIView!
//    @IBOutlet weak var exerciseNumberLabel: UILabel!
//    @IBOutlet weak var collectionView: UICollectionView!
//    public var shouldHideStartButton: Bool = false
//
//    var exercises: [WorkoutExercise] = []
//    private var progressView: CircularProgressView!
//
//    private var currentSortedExercises: [WorkoutExercise] {
//        let completedSet = WorkoutManager.shared.completedToday
//        let top       = exercises.filter { !completedSet.contains($0.id) }
//        let completed = exercises.filter {  completedSet.contains($0.id) }
//        return top + completed
//    }
//
//    // MARK: - Setup
//
//    private func setupProgressView() {
//        progressView = CircularProgressView(frame: progressContainer.bounds)
//        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        progressContainer.addSubview(progressView)
//        progressView.progressColor = UIColor(hex: "0088FF")
//        progressView.trackColor    = UIColor(hex: "0088FF", alpha: 0.3)
//    }
//
//    private func setupCollectionView() {
//        collectionView.dataSource  = self
//        collectionView.delegate    = self
//        collectionView.backgroundColor = .white
//        let nib = UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: "ExerciseCollectionViewCell")
//        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: false)
//    }
//
//    private func createCompositionalLayout() -> UICollectionViewLayout {
//        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .fractionalHeight(1.0))
//        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                               heightDimension: .absolute(62))
//        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        let section   = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 2.5
//        return UICollectionViewCompositionalLayout(section: section)
//    }
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupProgressView()
//        setupCollectionView()
//        startButtonOutlet.isHidden = shouldHideStartButton
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let manager = WorkoutManager.shared
//        let currentProgress = manager.completedToday.count + manager.skippedToday.count
//
//        if currentProgress == 0 {
//            if manager.exercises.isEmpty {
//                let fallbackPosition = manager.loadLastWorkoutPosition() ?? .seated
//                manager.generateDailyWorkout(for: fallbackPosition)
//            }
//
//            self.exercises = manager.exercises
//            collectionView.reloadData()
//            updateProgress()
//            updateButtonUI()
//
//
//            if !shouldHideStartButton {
//                let medStateChanged = manager.currentMedState() != manager.lastCheckedMedState
//                if medStateChanged {
//                    checkMedTaken()
//                }
//            }
//            
//        } else {
//            self.exercises = manager.exercises
//            collectionView.reloadData()
//            updateProgress()
//            updateButtonUI()
//        }
//
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//
//        tabBarController?.tabBar.isHidden = true
//        
//       
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//
//    // MARK: - Progress & Button UI
//
//    func updateProgress() {
//        view.layoutIfNeeded()
//        let completed = WorkoutManager.shared.completedToday.count
//        let total     = exercises.count
//        exerciseNumberLabel.text = "\(completed)/\(total)"
//        progressView.setProgress(total > 0 ? CGFloat(completed) / CGFloat(total) : 0)
//    }
//
//    func updateButtonUI() {
//        let completed = WorkoutManager.shared.completedToday.count
//        let skipped   = WorkoutManager.shared.skippedToday.count
//        let total     = exercises.count
//
//        if completed == 0 && skipped == 0 {
//            startButtonOutlet.setTitle("Start Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        } else if completed < total {
//            startButtonOutlet.setTitle("Resume Workout", for: .normal)
//            startButtonOutlet.isEnabled = true
//        } else {
//            startButtonOutlet.setTitle("Workout Completed", for: .normal)
//            startButtonOutlet.isEnabled = false
//        }
//    }
//
//    private func refreshWorkoutList() {
//        self.exercises = WorkoutManager.shared.exercises
//        collectionView.reloadData()
//        updateProgress()
//        updateButtonUI()
//    }
//
//    // MARK: - Start Workout
//
//    @IBAction func StartWorkoutTapped(_ sender: Any) {
//        navigateToWorkout()
//    }
//
//    private func navigateToWorkout() {
//        let exercises    = WorkoutManager.shared.exercises
//        let completedSet = WorkoutManager.shared.completedToday
//        let resumeIndex  = exercises.firstIndex { !completedSet.contains($0.id) } ?? 0
//
//        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController")
//                    as? _0minworkoutCountdownViewController {
//            vc.startingIndex = resumeIndex
//            vc.exercises     = exercises
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//
//
//
//    private func checkMedTaken() {
//        let manager = WorkoutManager.shared
//
//        if manager.diseaseStage >= 3 {
//            showStage3PositionAlert()
//        } else {
//            if manager.allMedsTaken {
//                manager.generateDailyWorkout(for: .standing)
//                manager.lastCheckedMedState = manager.currentMedState()
//                refreshWorkoutList()
//            } else {
//                showStage12SafetyAlert()
//            }
//        }
//    }
//
//    private func showStage3PositionAlert() {
//        let alert = UIAlertController(
//            title: "Choose Exercise Position",
//            message: "Would you like to perform standing or seated exercises today?",
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Seated (Recommended)", style: .default) { [weak self] _ in
//            let manager = WorkoutManager.shared
//            
//            manager.generateDailyWorkoutReducedWithFeedback(for: .seated)
//            manager.lastCheckedMedState = manager.currentMedState()
//            self?.refreshWorkoutList()
//        })
//
//        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
//            let manager = WorkoutManager.shared
//            if manager.allMedsTaken {
//
//                manager.generateDailyWorkout(for: .standing)
//            } else {
//
//                manager.generateDailyWorkoutIgnoringFeedback(for: .standing)
//            }
//            manager.lastCheckedMedState = manager.currentMedState()
//            self?.refreshWorkoutList()
//        })
//
//        present(alert, animated: true)
//    }
//
//    private func showStage12SafetyAlert() {
//        let alert = UIAlertController(
//            title: "Choose Exercise Position",
//            message: "How would you like to exercise today?",
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
//            let manager = WorkoutManager.shared
//            manager.generateDailyWorkout(for: .standing)
//            manager.lastCheckedMedState = manager.currentMedState()
//            self?.refreshWorkoutList()
//        })
//
//        alert.addAction(UIAlertAction(title: "Seated", style: .default) { [weak self] _ in
//            let manager = WorkoutManager.shared
//            manager.generateDailyWorkout(for: .seated)
//            manager.lastCheckedMedState = manager.currentMedState()
//            self?.refreshWorkoutList()
//        })
//
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//
//extension _0minworkoutLandingPageViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView,
//                        numberOfItemsInSection section: Int) -> Int {
//        return exercises.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "ExerciseCollectionViewCell",
//            for: indexPath
//        ) as! ExerciseListCollectionViewCell
//
//        let exercise = currentSortedExercises[indexPath.item]
//        cell.exerciseNameOutlet.text = exercise.name
//        cell.repsOutlet.text = (exercise.category == .warmup || exercise.category == .cooldown)
//            ? "\(exercise.timerSeconds)s"
//            : "\(exercise.reps) Reps"
//        cell.loadThumbnail(exercise: exercise)
//
//
//        let isCompleted = WorkoutManager.shared.completedToday.contains(exercise.id)
//        isCompleted ? cell.configureCompleted() : cell.configurePendingOrSkipped()
//
//        return cell
//    }
//}




import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    public var shouldHideStartButton: Bool = false

    var exercises: [WorkoutExercise] = []
    private var progressView: CircularProgressView!

    private var currentSortedExercises: [WorkoutExercise] {
        let completedSet = WorkoutManager.shared.completedToday
        let top       = exercises.filter { !completedSet.contains($0.id) }
        let completed = exercises.filter {  completedSet.contains($0.id) }
        return top + completed
    }

    // MARK: - Setup

    private func setupProgressView() {
        progressView = CircularProgressView(frame: progressContainer.bounds)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        progressContainer.addSubview(progressView)
        progressView.progressColor = UIColor(hex: "0088FF")
        progressView.trackColor    = UIColor(hex: "0088FF", alpha: 0.3)
    }

    private func setupCollectionView() {
        collectionView.dataSource  = self
        collectionView.delegate    = self
        collectionView.backgroundColor = .white
        let nib = UINib(nibName: "ExerciseListCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ExerciseCollectionViewCell")
        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: false)
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(62))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section   = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2.5
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        setupCollectionView()
        startButtonOutlet.isHidden = shouldHideStartButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let manager = WorkoutManager.shared
        let currentProgress = manager.completedToday.count + manager.skippedToday.count

        if currentProgress == 0 {
            if manager.exercises.isEmpty {
                let fallbackPosition = manager.loadLastWorkoutPosition() ?? .seated
                manager.generateDailyWorkout(for: fallbackPosition)
            }
            self.exercises = manager.exercises
            collectionView.reloadData()
            updateProgress()
            updateButtonUI()

            if !shouldHideStartButton {
                let medStateChanged = manager.currentMedState() != manager.lastCheckedMedState
                if medStateChanged { checkMedTaken() }
            }
        } else {
            self.exercises = manager.exercises
            collectionView.reloadData()
            updateProgress()
            updateButtonUI()
        }

        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Progress & Button UI

    func updateProgress() {
        view.layoutIfNeeded()
        let completed = WorkoutManager.shared.completedToday.count
        let total     = exercises.count
        exerciseNumberLabel.text = "\(completed)/\(total)"
        progressView.setProgress(total > 0 ? CGFloat(completed) / CGFloat(total) : 0)
    }

    func updateButtonUI() {
        let completed = WorkoutManager.shared.completedToday.count
        let skipped   = WorkoutManager.shared.skippedToday.count
        let total     = exercises.count

        if completed == 0 && skipped == 0 {
            startButtonOutlet.setTitle("Start Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        } else if completed < total {
            startButtonOutlet.setTitle("Resume Workout", for: .normal)
            startButtonOutlet.isEnabled = true
        } else {
            startButtonOutlet.setTitle("Workout Completed", for: .normal)
            startButtonOutlet.isEnabled = false
        }
    }

    private func refreshWorkoutList() {
        self.exercises = WorkoutManager.shared.exercises
        collectionView.reloadData()
        updateProgress()
        updateButtonUI()
    }

    // MARK: - Start Workout

    @IBAction func StartWorkoutTapped(_ sender: Any) {
        navigateToWorkout()
    }

    private func navigateToWorkout() {
        let allExercises = WorkoutManager.shared.exercises
        let completedSet = WorkoutManager.shared.completedToday
        let resumeIndex  = allExercises.firstIndex { !completedSet.contains($0.id) } ?? 0

        // Push the code-based countdown VC directly — no storyboard ID needed.
        let countdown = ExerciseCountdownViewController()
        countdown.exercises     = allExercises
        countdown.startingIndex = resumeIndex
        navigationController?.pushViewController(countdown, animated: true)
    }

    // MARK: - Med / position alerts

    private func checkMedTaken() {
        let manager = WorkoutManager.shared
        if manager.diseaseStage >= 3 {
            showStage3PositionAlert()
        } else {
            if manager.allMedsTaken {
                manager.generateDailyWorkout(for: .standing)
                manager.lastCheckedMedState = manager.currentMedState()
                refreshWorkoutList()
            } else {
                showStage12SafetyAlert()
            }
        }
    }

    private func showStage3PositionAlert() {
        let alert = UIAlertController(
            title: "Choose Exercise Position",
            message: "Would you like to perform standing or seated exercises today?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Seated (Recommended)", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutReducedWithFeedback(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            if manager.allMedsTaken {
                manager.generateDailyWorkout(for: .standing)
            } else {
                manager.generateDailyWorkoutIgnoringFeedback(for: .standing)
            }
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        present(alert, animated: true)
    }

    private func showStage12SafetyAlert() {
        let alert = UIAlertController(
            title: "Choose Exercise Position",
            message: "How would you like to exercise today?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkout(for: .standing)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        alert.addAction(UIAlertAction(title: "Seated", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkout(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension _0minworkoutLandingPageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { exercises.count }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ExerciseCollectionViewCell",
            for: indexPath
        ) as! ExerciseListCollectionViewCell

        let exercise = currentSortedExercises[indexPath.item]
        cell.exerciseNameOutlet.text = exercise.name
        cell.repsOutlet.text = (exercise.category == .warmup || exercise.category == .cooldown)
            ? "\(exercise.timerSeconds)s"
            : "\(exercise.reps) Reps"
        cell.loadThumbnail(exercise: exercise)

        let isCompleted = WorkoutManager.shared.completedToday.contains(exercise.id)
        isCompleted ? cell.configureCompleted() : cell.configurePendingOrSkipped()

        return cell
    }
}
