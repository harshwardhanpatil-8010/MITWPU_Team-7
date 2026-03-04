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

        // Detect if medication state has changed since the last safety check.
        // This handles cases like: user dismissed the alert, added meds, came back.
        let medStateChanged = manager.currentMedState() != manager.lastCheckedMedState

        // Re-run the safety check if:
        //  • No exercises have been done yet (session hasn't started), AND
        //  • Either the check hasn't run at all, OR the medication state changed since last check
        let shouldRecheck = currentProgress == 0 && (!manager.hasCheckedSafetyThisSession || medStateChanged)

        if shouldRecheck {
            manager.hasCheckedSafetyThisSession = true
            manager.lastCheckedMedState = manager.currentMedState()

            // Generate a default workout immediately so the list is visible
            // before the alert appears. The alert may regenerate with a different
            // position — refreshWorkoutList() inside each action updates everything.
            if manager.exercises.isEmpty {
                manager.generateDailyWorkout()
            }
            self.exercises = manager.exercises
            collectionView.reloadData()
            updateProgress()
            updateButtonUI()

            // Show safety/medication alert. Each action calls generate + refreshWorkoutList().
            checkMedTaken()

        } else {
            // Mid-session or returning from workout — sync current state.
            self.exercises = manager.exercises

            if self.exercises.isEmpty {
                manager.generateDailyWorkout()
                self.exercises = manager.exercises
            }

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
    // MARK: - FIG. 2 Safety & Medication Check  (matches flowchart exactly)
    // ─────────────────────────────────────────────────────────────────────────
    //
    //  Full decision tree:
    //
    //  ┌─ Stage ≥ 3? ─YES─► Safety alert
    //  │                       └─► Standing or Seated?
    //  │                             ├─ Seated ──────────────────────────────► generateDailyWorkout()              (feedback considered)
    //  │                             └─ Standing ─► allMedsTaken?
    //  │                                             ├─ YES ─────────────────► generateDailyWorkout()              (feedback considered)
    //  │                                             └─ NO  ─────────────────► generateDailyWorkoutIgnoringFeedback() (feedback NOT considered)
    //  │
    //  └─ Stage 1 or 2
    //       └─► hasMedicationsAdded?
    //             ├─ NO  ─► Ask position (no meds in app)
    //             │           ├─ Standing ──────────────────────────────────► generateDailyWorkout()              (feedback considered)
    //             │           └─ Seated ────────────────────────────────────► generateDailyWorkout()              (feedback considered)
    //             │
    //             └─ YES ─► allMedsTaken in time window?
    //                         ├─ YES ─► ON-period ──────────────────────────► generateDailyWorkout()              (feedback considered)
    //                         └─ NO  ─► Standing or Seated?
    //                                     ├─ Standing ──────────────────────► generateDailyWorkoutIgnoringFeedback() (feedback NOT considered)
    //                                     └─ Seated ────────────────────────► generateDailyWorkoutIgnoringFeedback() (feedback NOT considered)

    private func checkMedTaken() {
        let manager = WorkoutManager.shared

        if manager.diseaseStage >= 3 {
            // ── STAGE ≥ 3 PATH ───────────────────────────────────────────────
            showStage3PositionChoice()

        } else {
            // ── STAGE 1 / 2 PATH ─────────────────────────────────────────────

            guard manager.hasMedicationsAdded else {
                // No medications set up in the app at all.
                // We can't do a medication check, so just ask the user
                // which position they prefer. Feedback IS considered because
                // we have no reason to penalise them — we simply don't know
                // their medication state.
                showNoMedicationPositionAlert()
                return
            }

            if manager.allMedsTaken {
                // All scheduled doses taken in the last 3 hrs → ON period
                manager.userWantsToPushLimits = false
                manager.generateDailyWorkout()          // feedback considered
                refreshWorkoutList()
            } else {
                // Meds NOT taken in window → standing/seated choice
                // Feedback NOT considered on either branch
                showStage12MedNotTakenAlert()
            }
        }
    }

    // ── Stage ≥ 3 alerts ─────────────────────────────────────────────────────

 
   
    private func showStage3PositionChoice() {
        let alert = UIAlertController(
            title: "Choose Exercise Position",
            message: "Would you like to perform standing or seated exercises?",
            preferredStyle: .alert
        )

        // Seated → feedback IS considered (progressive algorithm applied)
        alert.addAction(UIAlertAction(title: "Seated (Recommended)", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = false
            manager.generateDailyWorkout()         // feedback considered
            self?.refreshWorkoutList()
        })

        // Standing → need to check meds first
        alert.addAction(UIAlertAction(title: "Standing", style: .default) { [weak self] _ in
            self?.checkMedsForStage3Standing()
        })

        present(alert, animated: true)
    }

    /// Stage ≥ 3, standing chosen: check medication window before allowing.
    private func checkMedsForStage3Standing() {
        let manager = WorkoutManager.shared

        if manager.allMedsTaken {
            // Meds confirmed in window → allow standing with full feedback algorithm
            manager.userWantsToPushLimits = true
            manager.generateDailyWorkout()         // feedback considered
            refreshWorkoutList()
        } else {
            // Meds NOT taken → standing allowed but feedback NOT considered
            showStage3MedNotTakenWarning()
        }
    }

    /// Stage ≥ 3, standing chosen, meds NOT taken: warn user, reduce intensity.
    private func showStage3MedNotTakenWarning() {
        let alert = UIAlertController(
            title: "Medication Not Confirmed",
            message: "Your medication does not appear to have been taken within the required time window. Exercise intensity will be reduced for your safety. Your previously saved difficulty feedback will NOT be applied this session.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = true    // user still wants standing
            manager.generateDailyWorkoutIgnoringFeedback()   // feedback NOT considered
            self?.refreshWorkoutList()
        })
        alert.addAction(UIAlertAction(title: "Switch to Seated", style: .cancel) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = false
            manager.generateDailyWorkoutIgnoringFeedback()   // feedback NOT considered
            self?.refreshWorkoutList()
        })
        present(alert, animated: true)
    }

    // ── No medication added alert ────────────────────────────────────────────

    /// Stage 1 or 2, no medications set up in the app at all.
    /// We can't do a medication check so we simply ask for position preference.
    /// Since we have no negative medication signal, feedback IS considered.
    private func showNoMedicationPositionAlert() {
        let alert = UIAlertController(
            title: "How are you feeling today?",
            message: "No medication has been set up in the app. Choose the exercise position that feels right for you today.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Standing Exercises", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = true
            manager.generateDailyWorkout()          // feedback considered
            self?.refreshWorkoutList()
        })

        alert.addAction(UIAlertAction(title: "Seated Exercises", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = false
            manager.generateDailyWorkout()          // feedback considered
            self?.refreshWorkoutList()
        })

        present(alert, animated: true)
    }

    // ── Stage 1/2 alerts ─────────────────────────────────────────────────────

    /// Stage 1 or 2, meds NOT taken in window:
    /// Give user the standing/seated choice. Feedback NOT considered on either branch.
    private func showStage12MedNotTakenAlert() {
        let alert = UIAlertController(
            title: "Medication Check",
            message: "Your medication does not appear to have been taken within the required time window. You may still exercise, but intensity will be reduced and previously saved feedback will NOT be applied this session.",
            preferredStyle: .alert
        )

        // Standing → reduced intensity, feedback NOT considered
        alert.addAction(UIAlertAction(title: "Standing Exercises", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = true
            manager.generateDailyWorkoutIgnoringFeedback()
            self?.refreshWorkoutList()
        })

        // Seated → reduced intensity, feedback NOT considered
        alert.addAction(UIAlertAction(title: "Seated Exercises (Safer)", style: .default) { [weak self] _ in
            let manager = WorkoutManager.shared
            manager.userWantsToPushLimits = false
            manager.generateDailyWorkoutIgnoringFeedback()
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
            ? "\(exercise.reps)s"
            : "\(exercise.reps) Reps"

        if let videoID = exercise.videoID {
            cell.loadThumbnail(videoName: videoID)
        }

        let isCompleted = WorkoutManager.shared.completedToday.contains(exercise.id)
        isCompleted ? cell.configureCompleted() : cell.configurePendingOrSkipped()

        return cell
    }
}
