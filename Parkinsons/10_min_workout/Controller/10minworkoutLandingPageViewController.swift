import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    public var shouldHideStartButton: Bool = false
    var displayDate: Date?

    var exercises: [WorkoutExercise] = []
    private var progressView: CircularProgressView!
    private var historicalCompletedNames: Set<String> = []
    private var historicalCompletedCount: Int = 0
    private var historicalTotalCount: Int = 0

    private var isHistoricalMode: Bool {
        guard let displayDate else { return false }
        return shouldHideStartButton && !Calendar.current.isDateInToday(displayDate)
    }

    private var currentSortedExercises: [WorkoutExercise] {
        if isHistoricalMode {
            return exercises
        }
        let completedSet = WorkoutManager.shared.completedToday
        let top       = exercises.filter { !completedSet.contains($0.id) }
        let completed = exercises.filter {  completedSet.contains($0.id) }
        return top + completed
    }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        setupCollectionView()
        startButtonOutlet.isHidden = shouldHideStartButton
        let gradient = navGradientOverlay
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140)
        view.layer.addSublayer(gradient)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isHistoricalMode {
            loadHistoricalWorkout()
            navigationController?.setNavigationBarHidden(false, animated: animated)
            tabBarController?.tabBar.isHidden = true
            return
        }

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



    private func loadHistoricalWorkout() {
        guard let displayDate else { return }

        let summary = DailyWorkoutSummaryStore.shared.fetchSummary(for: displayDate)
        let completedNames = DailyWorkoutSummaryStore.shared.completedExerciseNames(for: displayDate)
        let skippedNames = DailyWorkoutSummaryStore.shared.skippedExerciseNames(for: displayDate)
        let total = max(Int(summary?.totalExercises ?? 0), completedNames.count + skippedNames.count)

        historicalCompletedNames = Set(completedNames)
        historicalCompletedCount = Int(summary?.completedCount ?? Int16(completedNames.count))
        historicalTotalCount = total

        var placeholderExercises: [WorkoutExercise] = []
        let knownNames = completedNames + skippedNames

        for (_, name) in knownNames.enumerated() {
            placeholderExercises.append(
                WorkoutExercise(
                    id: UUID(),
                    name: name,
                    reps: 0,
                    duration: 0,
                    videoID: nil,
                    category: .strength,
                    position: .seated,
                    targetJoints: [],
                    voiceInstruction: nil
                )
            )
        }

        if total > knownNames.count {
            for index in knownNames.count..<total {
                placeholderExercises.append(
                    WorkoutExercise(
                        id: UUID(),
                        name: "Exercise \(index + 1)",
                        reps: 0,
                        duration: 0,
                        videoID: nil,
                        category: .strength,
                        position: .seated,
                        targetJoints: [],
                        voiceInstruction: nil
                    )
                )
            }
        }

        exercises = placeholderExercises
        collectionView.reloadData()
        updateProgress()
        updateButtonUI()
    }

    func updateProgress() {
        view.layoutIfNeeded()
        if isHistoricalMode {
            let total = max(historicalTotalCount, 1)
            exerciseNumberLabel.text = "\(historicalCompletedCount)/\(historicalTotalCount)"
            progressView.setProgress(CGFloat(historicalCompletedCount) / CGFloat(total))
            return
        }
        let completed = WorkoutManager.shared.completedToday.count
        let total     = exercises.count
        exerciseNumberLabel.text = "\(completed)/\(total)"
        progressView.setProgress(total > 0 ? CGFloat(completed) / CGFloat(total) : 0)
    }

    func updateButtonUI() {
        if isHistoricalMode {
            startButtonOutlet.isEnabled = false
            return
        }
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
        let completedSet = Set(WorkoutManager.shared.completedToday)
        let skippedSet   = Set(WorkoutManager.shared.skippedToday)

        let resumeIndex  = allExercises.firstIndex { 
            !completedSet.contains($0.id) && !skippedSet.contains($0.id) 
        }

        if let idx = resumeIndex {
            let countdown = ExerciseCountdownViewController()
            countdown.exercises     = allExercises
            countdown.startingIndex = idx
            navigationController?.pushViewController(countdown, animated: true)
        } else {
            let unresolvedSkipped = WorkoutManager.shared.skippedToday.filter { skippedID in
                Set(allExercises.map(\.id)).contains(skippedID) && !completedSet.contains(skippedID)
            }
            if let skipIdx = allExercises.firstIndex(where: { unresolvedSkipped.contains($0.id) }) {
                let countdown = ExerciseCountdownViewController()
                countdown.exercises     = allExercises
                countdown.startingIndex = skipIdx
                countdown.isRevisitingSkipped = true
                countdown.skippedIndicesToRevisit = allExercises.indices.filter {
                    unresolvedSkipped.contains(allExercises[$0].id)
                }
                navigationController?.pushViewController(countdown, animated: true)
            } else {
                let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "GoodJobViewController") as? _0minworkoutGoodJobViewController {
                    vc.completed = WorkoutManager.shared.completedToday.count
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
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

        let seatedAction = UIAlertAction(
            title: "Seated (Recommended)",
            style: .default
        ) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutReducedWithFeedback(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        }

        let seatedImage = UIImage(
            systemName: "figure.seated.side.left"
        )

        seatedAction.setValue(seatedImage, forKey: "image")

        let standingAction = UIAlertAction(
            title: "Standing",
            style: .default
        ) { [weak self] _ in
            let manager = WorkoutManager.shared

            if manager.allMedsTaken {
                manager.generateDailyWorkout(for: .standing)
            } else {
                manager.generateDailyWorkoutIgnoringFeedback(for: .standing)
            }

            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        }

        let standingImage = UIImage(
            systemName: "figure.stand"
        )

        standingAction.setValue(standingImage, forKey: "image")

        alert.addAction(seatedAction)
        alert.addAction(standingAction)

        present(alert, animated: true)
    }


    private func showStage12SafetyAlert() {
        let alert = UIAlertController(
            title: "Choose Exercise Position",
            message: "How would you like to exercise today?",
            preferredStyle: .alert
        )

        let standingAction = UIAlertAction(
            title: "Standing",
            style: .default
        ) { [weak self] _ in
            let manager = WorkoutManager.shared

            manager.generateDailyWorkout(for: .standing)
            manager.lastCheckedMedState = manager.currentMedState()

            self?.refreshWorkoutList()
        }

        let standingImage = UIImage(
            systemName: "figure.stand"
        )

        standingAction.setValue(
            standingImage,
            forKey: "image"
        )

        let seatedAction = UIAlertAction(
            title: "Seated",
            style: .default
        ) { [weak self] _ in
            let manager = WorkoutManager.shared

            manager.generateDailyWorkout(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()

            self?.refreshWorkoutList()
        }

        let seatedImage = UIImage(
            systemName: "figure.seated.side.left"
        )

        seatedAction.setValue(
            seatedImage,
            forKey: "image"
        )

        alert.addAction(standingAction)
        alert.addAction(seatedAction)

        present(alert, animated: true)
    }
    private var navGradientOverlay: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "0088FF").withAlphaComponent(0.35).cgColor,
            UIColor(hex: "0088FF").withAlphaComponent(0.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        return gradient
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
        if isHistoricalMode {
            cell.repsOutlet.text = ""
        } else {
            cell.repsOutlet.text = (exercise.category == .warmup || exercise.category == .cooldown)
                ? "\(exercise.timerSeconds)s"
                : "\(exercise.reps) Reps"
            cell.loadThumbnail(exercise: exercise)
        }
        let isCompleted = isHistoricalMode
            ? historicalCompletedNames.contains(exercise.name)
            : WorkoutManager.shared.completedToday.contains(exercise.id)
        isCompleted ? cell.configureCompleted() : cell.configurePendingOrSkipped()
        return cell
    }
}
