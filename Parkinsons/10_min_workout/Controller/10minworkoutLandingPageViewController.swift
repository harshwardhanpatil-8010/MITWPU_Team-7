import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var progressContainer: UIView!
    @IBOutlet weak var exerciseNumberLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var exercises: [WorkoutExercise] = []

    private var progressView: CircularProgressView!

    private var currentSortedExercises: [WorkoutExercise] {
        let completedSet = WorkoutManager.shared.completedToday
        let topGroup       = exercises.filter { !completedSet.contains($0.id) }
        let completedGroup = exercises.filter {  completedSet.contains($0.id) }
        return topGroup + completedGroup
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let manager = WorkoutManager.shared
        let currentProgress = manager.completedToday.count + manager.skippedToday.count

        // Only run the med check when the workout hasn't started yet.
        // Re-run it every time the medication state has changed since the last check
        // (e.g. user just added meds, or just logged a dose) — this is the
        // "continuous checking" behaviour.
        if currentProgress == 0 {
            let medStateChanged = manager.currentMedState() != manager.lastCheckedMedState

            if medStateChanged {
                // Medication state is different from last time — re-run full check.
                // Show a default list immediately, then the alert regenerates it.
                if manager.exercises.isEmpty {
                    manager.generateDailyWorkout(for: .seated)
                }
                self.exercises = manager.exercises
                collectionView.reloadData()
                updateProgress()
                updateButtonUI()

                checkMedTaken()   // this saves lastCheckedMedState when done
            } else {
                // Med state unchanged — just sync the list, no alert needed.
                if manager.exercises.isEmpty {
                    manager.generateDailyWorkout(for: .seated)
                }
                self.exercises = manager.exercises
                collectionView.reloadData()
                updateProgress()
                updateButtonUI()
            }
        } else {
            // Mid-session — never show the alert, just sync state.
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
        let exercises    = WorkoutManager.shared.exercises
        let completedSet = WorkoutManager.shared.completedToday
        let resumeIndex  = exercises.firstIndex { !completedSet.contains($0.id) } ?? 0

        let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController")
                    as? _0minworkoutCountdownViewController {
            vc.startingIndex = resumeIndex
            vc.exercises     = exercises
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: - Medication & Safety Check  (matches flowchart exactly)
    //
    //  ┌─ Stage ≥ 3?
    //  │    YES → Generate safety alert → Standing or Seated?
    //  │              Seated  → generateDailyWorkout(.seated)   feedback ON
    //  │              Standing → allMedsTaken?
    //  │                           YES → generateDailyWorkout(.standing)  feedback ON
    //  │                           NO  → generateDailyWorkoutIgnoringFeedback(.standing) feedback OFF
    //  │
    //  └─ Stage 1 or 2
    //       Check medication intake status
    //       allMedsTaken?
    //         YES → Mark as ON-period
    //               Standing suggested → generateDailyWorkout(.standing)  feedback ON
    //         NO  → Safety alert → Standing or Seated?
    //               Either → generateDailyWorkoutIgnoringFeedback(position) feedback OFF
    // ─────────────────────────────────────────────────────────────────────────

    private func checkMedTaken() {
        let manager = WorkoutManager.shared

        if manager.diseaseStage >= 3 {
            // ── STAGE ≥ 3 ────────────────────────────────────────────────────
            // Show safety alert, let user pick position.
            // If standing is chosen, check meds before allowing it.
            showStage3SafetyAlert()
        } else {
            // ── STAGE 1 / 2 ──────────────────────────────────────────────────
            // Check medication intake status directly — no "hasMedicationsAdded"
            // gate needed because allMedsTaken already returns false when nothing
            // has been logged, which correctly routes to the safety alert.
            if manager.allMedsTaken {
                // ON period: standing is suggested, full feedback applied.
                manager.generateDailyWorkout(for: .standing)
                manager.lastCheckedMedState = manager.currentMedState()
                refreshWorkoutList()
            } else {
                // Meds not taken in window → safety alert, reduced intensity.
                showStage12MedNotTakenAlert()
            }
        }
    }

    // ── Stage ≥ 3: safety alert ───────────────────────────────────────────────

    private func showStage3SafetyAlert() {
        let alert = UIAlertController(
            title: "Safety Check",
            message: "You are in an advanced stage. Please choose the exercise position that is safest for you today.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Seated (Recommended)", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkout(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })

        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
            self?.checkMedsForStage3Standing()
        })

        present(alert, animated: true)
    }

    /// Stage ≥ 3, standing chosen — check meds before allowing.
    private func checkMedsForStage3Standing() {
        let manager = WorkoutManager.shared

        if manager.allMedsTaken {
            // Meds confirmed → standing with full feedback
            manager.generateDailyWorkout(for: .standing)
            manager.lastCheckedMedState = manager.currentMedState()
            refreshWorkoutList()
        } else {
            // Meds not taken → standing allowed but reduced intensity + no feedback
            showStage3MedNotTakenWarning()
        }
    }

    private func showStage3MedNotTakenWarning() {
        let alert = UIAlertController(
            title: "Medication Not Confirmed",
            message: "Your medication does not appear to have been taken within the required time window. Exercise intensity will be reduced for your safety. Previously saved feedback will NOT be applied this session.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue with Standing", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutIgnoringFeedback(for: .standing)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        alert.addAction(UIAlertAction(title: "Switch to Seated", style: .cancel) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutIgnoringFeedback(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })
        present(alert, animated: true)
    }

    // ── Stage 1/2: meds not taken → safety alert ─────────────────────────────

    private func showStage12MedNotTakenAlert() {
        let alert = UIAlertController(
            title: "Medication Check",
            message: "Your medication does not appear to have been taken within the required time window. Exercise intensity will be reduced. Previously saved feedback will NOT be applied this session.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Standing Exercises", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutIgnoringFeedback(for: .standing)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })

        alert.addAction(UIAlertAction(title: "Seated Exercises (Safer)", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.generateDailyWorkoutIgnoringFeedback(for: .seated)
            manager.lastCheckedMedState = manager.currentMedState()
            self?.refreshWorkoutList()
        })

        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension _0minworkoutLandingPageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }

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

        if let videoID = exercise.videoID {
            cell.loadThumbnail(videoName: videoID)
        }

        let isCompleted = WorkoutManager.shared.completedToday.contains(exercise.id)
        isCompleted ? cell.configureCompleted() : cell.configurePendingOrSkipped()

        return cell
    }
}
