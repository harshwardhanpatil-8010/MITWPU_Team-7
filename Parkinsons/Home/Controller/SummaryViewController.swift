//import UIKit
//import CoreData
//
//class SummaryViewController: UIViewController {
//    
//    enum Section: Int, CaseIterable {
//        case medicationsSummary
//        case exercises
//    }
//    
//    @IBOutlet weak var symptomTableView: UITableView!
//    @IBOutlet weak var summaryTitleLabel: UILabel!
//    @IBOutlet weak var mainCollectionView: UICollectionView!
//    @IBOutlet weak var closeBarButton: UIBarButtonItem!
//    var dateToDisplay: Date?
//    var currentSymptomLog: SymptomLogEntry?
//    let summarySections = Section.allCases
//    
//    private var dailyMedications: [MedicationModel] = []
//    private var totalScheduled: Int = 0
//    private var totalTaken: Int = 0
//    private var medicationObserver: NSObjectProtocol?
//    private var selectedWorkoutSummary: DailyWorkoutSummary?
//    
//    var exerciseData: [ExerciseModel] = [
//
//        ExerciseModel(title: "10-Min Workout", detail: "Tap to view summary", progressColorHex: "0088FF"),
//        ExerciseModel(title: "Rhythmic Walking", detail: "Tap to view summary",  progressColorHex: "90AF81")
//    ]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        
//        medicationObserver = NotificationCenter.default.addObserver(
//            forName: NSNotification.Name("MedicationLogged"),
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.loadDataForSelectedDate()
//        }
//    }
//    
//    deinit {
//        if let observer = medicationObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//        loadDataForSelectedDate()
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        setupTableView()
//        setupCollectionView()
//    }
//    
//    private func setupTableView() {
//        symptomTableView.dataSource = self
//        symptomTableView.delegate = self
//        symptomTableView.register(UINib(nibName: "SymptomDetailCell", bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
//        symptomTableView.rowHeight = 60.0
//        symptomTableView.separatorStyle = .none
//        symptomTableView.isScrollEnabled = false
//    }
//
//    private func updateSymptomTableBackground() {
//        let count = currentSymptomLog?.ratings.count ?? 0
//        if count == 0 {
//            let containerView = UIView(frame: symptomTableView.bounds)
//            let emptyLabel = UILabel()
//            emptyLabel.text = "No symptoms Logged"
//            emptyLabel.textColor = .secondaryLabel
//            emptyLabel.textAlignment = .center
//            emptyLabel.font = .systemFont(ofSize: 24, weight: .medium)
//            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
//            containerView.addSubview(emptyLabel)
//            
//            NSLayoutConstraint.activate([
//                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -140)
//            ])
//            symptomTableView.backgroundView = containerView
//        } else {
//            symptomTableView.backgroundView = nil
//        }
//    }
//
//    private func setupCollectionView() {
//        mainCollectionView.dataSource = self
//        mainCollectionView.delegate = self
//        mainCollectionView.isScrollEnabled = false
//        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")
//        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
//        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
//        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)
//    }
//    
//    func loadDataForSelectedDate() {
//        let targetDate = dateToDisplay ?? Date()
//        currentSymptomLog = SymptomLogManager.shared.getLogEntry(for: targetDate)
//        let context = PersistenceController.shared.viewContext
//
//        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
//        logRequest.predicate = NSPredicate(format: "doseDay == %@", targetDate.startOfDay as NSDate)
//
//
//        do {
//            let logs = try context.fetch(logRequest)
//            self.totalScheduled = logs.count
//            self.totalTaken = logs.filter { $0.doseLogStatus == "taken" }.count
//
//            let formatter = DateFormatter()
//            formatter.dateFormat = "h:mm a"
//
//            self.dailyMedications = logs.compactMap { log in
//                guard let med = log.medication else { return nil }
//                let timeString = formatter.string(from: log.doseScheduledTime ?? log.doseLoggedAt ?? Date())
//                return MedicationModel(
//
//                    name: med.medicationName ?? "",
//                    time: timeString,
//                    detail: med.medicationForm ?? "",
//                    iconName: med.medicationIconName ?? "pill",
//                    status: DoseStatus(rawValue: log.doseLogStatus ?? "") ?? .none
//
//                )
//            }
//        } catch {
//            self.dailyMedications = []
//
//        }
//
//        selectedWorkoutSummary = DailyWorkoutSummaryStore.shared.fetchSummary(for: targetDate)
//        updateTitleUI(with: targetDate)
//        symptomTableView.reloadData()
//        updateSymptomTableBackground()
//        mainCollectionView.reloadData()
//    }
//
//    private func updateMedicationBackground(isEmpty: Bool) {
//        if isEmpty {
//            let containerView = UIView()
//            let emptyLabel = UILabel()
//            emptyLabel.text = "No medication Logged"
//            emptyLabel.textColor = .secondaryLabel
//            emptyLabel.textAlignment = .center
//            emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
//            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
//            containerView.addSubview(emptyLabel)
//            
//            NSLayoutConstraint.activate([
//                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//                // Precisely 145 units above center as per your functional code
//                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -145)
//            ])
//            mainCollectionView.backgroundView = containerView
//        } else {
//            mainCollectionView.backgroundView = nil
//        }
//
//    }
//    
//    func generateSummaryLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, env) -> NSCollectionLayoutSection? in
//            guard let self = self else { return nil }
//            let sectionType = self.summarySections[sectionIndex]
//            let section: NSCollectionLayoutSection
//            
//            switch sectionType {
//            case .medicationsSummary:
//                // Constant Item and Group size regardless of content
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(80)), subitems: [item])
//                section = NSCollectionLayoutSection(group: group)
//                // Constant scrolling behavior allows background to show when count is 0
//                section.orthogonalScrollingBehavior = .groupPaging
//                section.interGroupSpacing = 12
//                
//            case .exercises:
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
//                item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 4)
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(190)), subitems: [item, item])
//                section = NSCollectionLayoutSection(group: group)
//            }
//            
//            section.contentInsets = .init(top: 8, leading: 16, bottom: 24, trailing: 16)
//            section.boundarySupplementaryItems = [self.createHeaderItem()]
//            return section
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let sectionType = summarySections[indexPath.section]
//        
//        if sectionType == .exercises {
//            let selectedExercise = exerciseData[indexPath.item]
//            
//            // 1. Handle 10-Min Workout
//            if selectedExercise.title == "10-Min Workout" {
//                let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
//                if let workoutVC = sb.instantiateViewController(withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController {
//                    workoutVC.shouldHideStartButton = true
//                    // Wrap it in a Navigation Controller so we can add the "X" button
//                    let navController = UINavigationController(rootViewController: workoutVC)
//                    navController.modalPresentationStyle = .pageSheet
//                    
//                    // 2. Create the "X" button dynamically
//                    let closeButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dismissWorkoutModal))
//                    closeButton.image = UIImage(systemName: "xmark") // Standard "X" icon
//                    closeButton.tintColor = .label
//                    
//                    // Inject the button into the landing page's navigation bar
//                    workoutVC.navigationItem.leftBarButtonItem = closeButton
//                    
//                    self.present(navController, animated: true)
//                }
//            }
//            // 3. Handle Rhythmic Walking (Existing logic)
//            else if selectedExercise.title == "Rhythmic Walking" {
//                let storyboard = UIStoryboard(name: "Home", bundle: nil)
//                if let walkingVC = storyboard.instantiateViewController(withIdentifier: "RhythmicWalkingSummaryViewController") as? RhythmicWalkingSummaryViewController {
//                    walkingVC.dateToDisplay       = dateToDisplay
//                    walkingVC.modalPresentationStyle = .pageSheet
//                    self.present(walkingVC, animated: true)
//                }
//            }
//        }
//    }
//
//    // 4. Add this helper function to handle the dismissal
//    @objc func dismissWorkoutModal() {
//        self.dismiss(animated: true, completion: nil)
//    }
//    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//        return NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30)),
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//    }
//
//    private func updateTitleUI(with date: Date) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d MMMM yyyy"
//        let dateString = formatter.string(from: date)
//        let fullString = "Summary \n\(dateString)"
//        let attributedString = NSMutableAttributedString(string: fullString)
//        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium)], range: NSRange(location: 0, length: 7))
//        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.secondaryLabel], range: NSRange(location: 8, length: dateString.count + 1))
//        summaryTitleLabel.attributedText = attributedString
//        summaryTitleLabel.numberOfLines = 0
//    }
//
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        dismiss(animated: true)
//    }
//}
//
//extension SummaryViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentSymptomLog?.ratings.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell,
//              let rating = currentSymptomLog?.ratings[indexPath.row] else { return UITableViewCell() }
//        cell.configure(with: rating, isEditable: false)
//        return cell
//    }
//}
//
//extension SummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return summarySections.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch summarySections[section] {
//        case .medicationsSummary:
//            // Always return at least 1 to keep the 80pt height constant
//            return max(dailyMedications.count, 1)
//        case .exercises:
//            return exerciseData.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let sectionType = summarySections[indexPath.section]
//        switch sectionType {
//        case .medicationsSummary:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationSummaryCell", for: indexPath) as! MedicationSummaryCell
//            
//            if dailyMedications.isEmpty {
//                // Create a "Dummy" model to display the empty text
//                let emptyModel = MedicationModel(
//                    name: "No medication Logged",
//                    time: "",
//                    detail: "",
//                    iconName: ""
//                )
//                cell.configure(with: emptyModel, totalTaken: 0, totalScheduled: 0)
//                
//                // IMPORTANT: Hide the card's background/border if you want it to look like plain text
//                cell.contentView.backgroundColor = .clear
//                cell.layer.shadowOpacity = 0 // Remove shadow
//                // If your cell has a background view or image, hide it here:
//                // cell.backgroundCardView.isHidden = true
//            } else {
//                // Reset cell appearance for real data
//                cell.contentView.backgroundColor = .white // or your original color
//                cell.alpha = 1
//                let model = dailyMedications[indexPath.item]
//                cell.configure(with: model, totalTaken: totalTaken, totalScheduled: totalScheduled)
//            }
//            return cell
//            
//        case .exercises:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
//            let model = exerciseData[indexPath.item]
//            cell.configure(with: model)
//            
//            if indexPath.item == 0 {
//                cell.setThemeColor(UIColor(hex: "0088FF"))
//                let completed = WorkoutManager.shared.completedToday.count
//                let total = max(DailyWorkoutSummaryStore.shared.totalExercises(for: dateToDisplay ?? Date()), 7)
//                cell.setProgress(completed: completed, total: total)
//            } else {
//                cell.setThemeColor(UIColor(hex: "90AF81"))
//                if let lastSession = DataStore.shared.sessions.first {
//                    let done = lastSession.elapsedSeconds
//                    let goal = max(lastSession.requestedDurationSeconds, 1)
//                    cell.setProgress(completed: done, total: goal)
//                    cell.progressLabel.text = "\(Int((Double(done)/Double(goal))*100))%"
//                } else {
//                    cell.setProgress(completed: 0, total: 1)
//                    cell.progressLabel.text = "0%"
//                }
//            }
//            return cell
//        }
//    }
//  
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
//        header.configure(title: summarySections[indexPath.section] == .exercises ? "Guided Exercise" : "Medications Log")
//
//        header.setTitleAlignment(.left)
//        
//        return header
//    }
//}
//





import UIKit
import CoreData

class SummaryViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case medicationsSummary
        case exercises
    }
    
    @IBOutlet weak var symptomTableView: UITableView!
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    
    var dateToDisplay: Date?
    var currentSymptomLog: SymptomLogEntry?
    let summarySections = Section.allCases
    

    private var totalScheduled: Int = 0
    private var totalTaken: Int = 0
    private var primaryMedication: MedicationModel?
    private var medicationObserver: NSObjectProtocol?
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Tap to view summary", progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "Tap to view summary",  progressColorHex: "90AF81")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        medicationObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("MedicationLogged"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadDataForSelectedDate()
            }
    }
    deinit {
        if let observer = medicationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadDataForSelectedDate()
        
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupTableView()
        setupCollectionView()
    }
    
    private func setupTableView() {
        symptomTableView.dataSource = self
        symptomTableView.delegate = self
        symptomTableView.register(UINib(nibName: "SymptomDetailCell", bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        symptomTableView.rowHeight = 60.0
        symptomTableView.separatorStyle = .none
        symptomTableView.isScrollEnabled = false
    }
    private func updateSymptomTableBackground() {
        let count = currentSymptomLog?.ratings.count ?? 0
        
        if count == 0 {
            let containerView = UIView(frame: symptomTableView.bounds)
            
            let emptyLabel = UILabel()
            emptyLabel.text = "No symptoms Logged"
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.font = .systemFont(ofSize: 24, weight: .medium)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(emptyLabel)
            
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -140),
                emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
                emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
            ])
            
            symptomTableView.backgroundView = containerView
        } else {
            symptomTableView.backgroundView = nil
        }
    }
    private func setupCollectionView() {
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)
    }
    
    
    func loadDataForSelectedDate() {
        let targetDate = dateToDisplay ?? Date()
        currentSymptomLog = SymptomLogManager.shared.getLogEntry(for: targetDate)

        let context = PersistenceController.shared.viewContext
        
        // Create the fetch request
        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        
        // Filter by the selected day
        logRequest.predicate = NSPredicate(
            format: "doseDay == %@",
            targetDate.startOfDay as NSDate
        )
        
        // ✅ ADD SORT DESCRIPTOR: Get the most recently logged medication first
        logRequest.sortDescriptors = [NSSortDescriptor(key: "doseLoggedAt", ascending: false)]

        do {
            let logs = try context.fetch(logRequest)

            self.totalScheduled = logs.count
            self.totalTaken = logs.filter { $0.doseLogStatus == "taken" }.count

            // ✅ Now that we sort by date descending, the first log IS the most recent
            if let mostRecentLog = logs.first,
               let med = mostRecentLog.medication {

                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"

                // Use the actual logged time for the summary display
                let timeString = formatter.string(from: mostRecentLog.doseLoggedAt ?? Date())

                self.primaryMedication = MedicationModel(
                    name: med.medicationName ?? "",
                    time: timeString,
                    detail: med.medicationForm ?? "",
                    iconName: med.medicationIconName ?? "pill",
                    status: DoseStatus(rawValue: mostRecentLog.doseLogStatus ?? "") ?? .none
                )
            } else {
                self.primaryMedication = nil
            }

        } catch {
            print("Failed to fetch logs: \(error)")
            self.primaryMedication = nil
            self.totalScheduled = 0
            self.totalTaken = 0
        }

        updateTitleUI(with: targetDate)
        symptomTableView.reloadData()
        updateSymptomTableBackground()
        mainCollectionView.reloadData()
    }
    
    private func updateTitleUI(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let rawDate = formatter.string(from: date)

        // Prefix "Today, " when the selected date is today
        let dateString = Calendar.current.isDateInToday(date)
            ? "Today, \(rawDate)"
            : rawDate

        let fullString       = "Summary \n\(dateString)"
        let attributedString = NSMutableAttributedString(string: fullString)

        // Apply regular (small, secondary) style to the ENTIRE string first —
        // this ensures every character including the last digit of the year is covered.
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        attributedString.addAttributes(regularAttributes,
                                       range: NSRange(location: 0, length: fullString.count))

        // Then override just "Summary" (7 chars) with the bold style.
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.label
        ]
        attributedString.addAttributes(boldAttributes,
                                       range: NSRange(location: 0, length: 7))

        summaryTitleLabel.attributedText = attributedString
        summaryTitleLabel.numberOfLines  = 0
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func generateSummaryLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard sectionIndex < self.summarySections.count else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            let section: NSCollectionLayoutSection
            
            switch sectionType {
            case .medicationsSummary:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                
            case .exercises:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 4)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(190)), subitems: [item, item])
                section = NSCollectionLayoutSection(group: group)
            }
            
            section.contentInsets = .init(top: 8, leading: 16, bottom: 24, trailing: 16)
            section.boundarySupplementaryItems = [self.createHeaderItem()]
            return section
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = summarySections[indexPath.section]
        
        if sectionType == .exercises {
            let selectedExercise = exerciseData[indexPath.item]
            
            // 1. Handle 10-Min Workout
            if selectedExercise.title == "10-Min Workout" {
                let sb = UIStoryboard(name: "10 minworkout", bundle: nil)
                if let workoutVC = sb.instantiateViewController(withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController {
                    workoutVC.shouldHideStartButton = true
                    // Wrap it in a Navigation Controller so we can add the "X" button
                    let navController = UINavigationController(rootViewController: workoutVC)
                    navController.modalPresentationStyle = .pageSheet
                    
                    // 2. Create the "X" button dynamically
                    let closeButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dismissWorkoutModal))
                    closeButton.image = UIImage(systemName: "xmark") // Standard "X" icon
                    closeButton.tintColor = .label
                    
                    // Inject the button into the landing page's navigation bar
                    workoutVC.navigationItem.leftBarButtonItem = closeButton
                    
                    self.present(navController, animated: true)
                }
            }
            // 3. Handle Rhythmic Walking (Existing logic)
            else if selectedExercise.title == "Rhythmic Walking" {
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                if let walkingVC = storyboard.instantiateViewController(withIdentifier: "RhythmicWalkingSummaryViewController") as? RhythmicWalkingSummaryViewController {
                    walkingVC.dateToDisplay       = dateToDisplay
                    walkingVC.modalPresentationStyle = .pageSheet
                    self.present(walkingVC, animated: true)
                }
            }
        }
    }

    // 4. Add this helper function to handle the dismissal
    @objc func dismissWorkoutModal() {
        self.dismiss(animated: true, completion: nil)
    }
    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension SummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = currentSymptomLog?.ratings.count ?? 0
            return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell,
              let rating = currentSymptomLog?.ratings[indexPath.row] else {
            return UITableViewCell()
        }
        cell.configure(with: rating, isEditable: false)
        return cell
    }
}

extension SummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return summarySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch summarySections[section] {
        case .medicationsSummary: return 1
        case .exercises: return exerciseData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .medicationsSummary:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationSummaryCell", for: indexPath) as! MedicationSummaryCell
            
            if let model = primaryMedication {
                cell.configure(with: model, totalTaken: totalTaken, totalScheduled: totalScheduled)
            } else {
                let emptyModel = MedicationModel(name: "No Medications", time: "--:--", detail: "None logged", iconName: "pill")
                cell.configure(with: emptyModel, totalTaken: 0, totalScheduled: 0)
            }
            return cell
            
        case .exercises:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "exercise_card_cell",
                for: indexPath
            ) as! ExerciseCardCell

            let model = exerciseData[indexPath.item]
            cell.configure(with: model)

            // 1. Logic for 10-Min Workout (Progress based on completed exercises)
            if indexPath.item == 0 {
                let completed = WorkoutManager.shared.completedToday.count
                let total = max(WorkoutManager.shared.exercises.count, 1) // Avoid division by zero
                
                cell.setProgress(completed: completed, total: total)
            }
            // 2. Logic for Rhythmic Walking (Progress based on session duration)
            else if indexPath.item == 1 {
                if let lastSession = DataStore.shared.sessions.first {
                    let done = lastSession.elapsedSeconds
                    let goal = max(lastSession.requestedDurationSeconds, 1)
                    let percentage = Int((Double(done) / Double(goal)) * 100)

                    cell.setProgress(completed: done, total: goal)
                    cell.progressLabel.text = "\(percentage)%"
                } else {
                    // No session exists yet today
                    cell.setProgress(completed: 0, total: 1)
                    cell.progressLabel.text = "0%"
                }
            }

            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
        let sectionType = summarySections[indexPath.section]
        
        // 1. Determine the title based on the section
        let title = sectionType == .exercises ? "Guided Exercise" : "Medications Log"
        
        // 2. Configure the header with the title
        header.configure(title: title)
        
        // 3. Set the font to Bold and Size 20
        header.setFont(size: 20, weight: .bold)
        
        // 4. Ensure it is left-aligned
        header.setTitleAlignment(.left)
        
        return header
    }
}
