
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
    @objc func dismissWorkoutModal() {
            self.dismiss(animated: true, completion: nil)
        }

    var dateToDisplay: Date?
    var currentSymptomLog: SymptomLogEntry?
    let summarySections = Section.allCases

    private var dailyMedications: [MedicationModel] = []
    private var totalScheduled: Int = 0
    private var totalTaken: Int = 0
    private var medicationObserver: NSObjectProtocol?
    private var selectedWorkoutSummary: DailyWorkoutSummary?

    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "Repeat everyday", progressColorHex: "90AF81")

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

                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -140)

            ])

            symptomTableView.backgroundView = containerView

        } else {

            symptomTableView.backgroundView = nil

        }

    }



    private func setupCollectionView() {

        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.isScrollEnabled = false

        mainCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "EmptyMedicationFooter")

        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")

        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")

        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")

        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)

    }

    

    func loadDataForSelectedDate() {

        let targetDate = dateToDisplay ?? Date()

        currentSymptomLog = SymptomLogManager.shared.getLogEntry(for: targetDate)

        let context = PersistenceController.shared.viewContext



        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()

        logRequest.predicate = NSPredicate(format: "doseDay == %@", targetDate.startOfDay as NSDate)



        do {

            let logs = try context.fetch(logRequest)

            self.totalScheduled = logs.count

            self.totalTaken = logs.filter { $0.doseLogStatus == "taken" }.count



            let formatter = DateFormatter()

            formatter.dateFormat = "h:mm a"



            self.dailyMedications = logs.compactMap { log in

                guard let med = log.medication else { return nil }

                let timeString = formatter.string(from: log.doseScheduledTime ?? log.doseLoggedAt ?? Date())

                return MedicationModel(

                    name: med.medicationName ?? "",

                    time: timeString,

                    detail: med.medicationForm ?? "",

                    iconName: med.medicationIconName ?? "pill",

                    status: DoseStatus(rawValue: log.doseLogStatus ?? "") ?? .none

                )

            }

        } catch {

            self.dailyMedications = []

        }



        selectedWorkoutSummary = DailyWorkoutSummaryStore.shared.fetchSummary(for: targetDate)

        updateTitleUI(with: targetDate)

        symptomTableView.reloadData()

        updateSymptomTableBackground()

        mainCollectionView.reloadData()
        mainCollectionView.collectionViewLayout.invalidateLayout()

    }



    private func updateMedicationBackground(isEmpty: Bool) {

        if isEmpty {

            let containerView = UIView()

            let emptyLabel = UILabel()

            emptyLabel.text = "No medications logged"

            emptyLabel.textColor = .secondaryLabel

            emptyLabel.textAlignment = .center

            emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)

            emptyLabel.translatesAutoresizingMaskIntoConstraints = false

            containerView.addSubview(emptyLabel)

            

            NSLayoutConstraint.activate([

                emptyLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

                // Precisely 145 units above center as per your functional code

                emptyLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -145)

            ])

            mainCollectionView.backgroundView = containerView

        } else {

            mainCollectionView.backgroundView = nil

        }

    }

    

    func generateSummaryLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            let section: NSCollectionLayoutSection
            
            // Let's set a clear variable for height so it's easy to change
            let medicationHeight: CGFloat = 80
            
            switch sectionType {
            case .medicationsSummary:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                
                // UPDATED: Changed height from 80 to medicationHeight (150)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(medicationHeight)), subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 12

                // UPDATED: Footer height now matches the group height
                let footerHeight: CGFloat = self.dailyMedications.isEmpty ? medicationHeight : 0
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(footerHeight))
                
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: footerSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                
                section.boundarySupplementaryItems = [self.createHeaderItem(), footer]
                
            case .exercises:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 4)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(190)), subitems: [item, item])
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [self.createHeaderItem()]
            }
            
            section.contentInsets = .init(top: 8, leading: 16, bottom: 24, trailing: 16)
            return section
        }
    }

    

    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {

        return NSCollectionLayoutBoundarySupplementaryItem(

            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30)),

            elementKind: UICollectionView.elementKindSectionHeader,

            alignment: .top

        )

    }



    private func updateTitleUI(with date: Date) {

        let formatter = DateFormatter()

        formatter.dateFormat = "d MMMM yyyy"

        let dateString = formatter.string(from: date)

        let fullString = "Summary \n\(dateString)"

        let attributedString = NSMutableAttributedString(string: fullString)

        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium)], range: NSRange(location: 0, length: 7))

        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.secondaryLabel], range: NSRange(location: 8, length: dateString.count + 1))

        summaryTitleLabel.attributedText = attributedString

        summaryTitleLabel.numberOfLines = 0

    }



    @IBAction func closeButtonTapped(_ sender: Any) {

        dismiss(animated: true)

    }

}



extension SummaryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return currentSymptomLog?.ratings.count ?? 0

    }

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell,

              let rating = currentSymptomLog?.ratings[indexPath.row] else { return UITableViewCell() }

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
            
        case .medicationsSummary:
            
            return dailyMedications.count // Returns 0 if empty, so NO card shows
            
        case .exercises:
            
            return exerciseData.count
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
            
        case .medicationsSummary:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationSummaryCell", for: indexPath) as! MedicationSummaryCell
            
            let model = dailyMedications[indexPath.item]
            
            cell.configure(with: model, totalTaken: totalTaken, totalScheduled: totalScheduled)
            
            return cell
            
        case .exercises:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
            
            let model = exerciseData[indexPath.item]
            
            cell.configure(with: model)
            
            
            
            if indexPath.item == 0 {
                
                cell.setThemeColor(UIColor(hex: "0088FF"))
                
                let completed = WorkoutManager.shared.completedToday.count
                
                let total = max(DailyWorkoutSummaryStore.shared.totalExercises(for: dateToDisplay ?? Date()), 7)
                
                cell.setProgress(completed: completed, total: total)
                
            } else {
                
                cell.setThemeColor(UIColor(hex: "90AF81"))
                
                if let lastSession = DataStore.shared.sessions.first {
                    
                    let done = lastSession.elapsedSeconds
                    
                    let goal = max(lastSession.requestedDurationSeconds, 1)
                    
                    cell.setProgress(completed: done, total: goal)
                    
                    cell.progressLabel.text = "\(Int((Double(done)/Double(goal))*100))%"
                    
                } else {
                    
                    cell.setProgress(completed: 0, total: 1)
                    
                    cell.progressLabel.text = "0%"
                    
                }
                
            }
            
            return cell
            
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
                    
                    // This line will now work because 'as?' tells Swift
                    
                    // exactly which class (and variables) to look for.
                    
                    workoutVC.shouldHideStartButton = true
                    
                    
                    
                    let navController = UINavigationController(rootViewController: workoutVC)
                    
                    navController.modalPresentationStyle = .pageSheet
                    
                    
                    
                    // Create the "X" button dynamically
                    
                    let closeButton = UIBarButtonItem(
                        
                        image: UIImage(systemName: "xmark"),
                        
                        style: .plain,
                        
                        target: self,
                        
                        action: #selector(dismissWorkoutModal)
                        
                    )
                    
                    closeButton.tintColor = .label
                    
                    workoutVC.navigationItem.leftBarButtonItem = closeButton
                    
                    
                    
                    self.present(navController, animated: true)
                    
                }
                
            }
            
            // 2. Handle Rhythmic Walking
            
            else if selectedExercise.title == "Rhythmic Walking" {
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                
                if let walkingVC = storyboard.instantiateViewController(withIdentifier: "RhythmicWalkingSummaryViewController") as? RhythmicWalkingSummaryViewController {
                    
                    // Pass the selected calendar date so only that day's sessions are shown
                    walkingVC.dateToDisplay = dateToDisplay ?? Date()
                    
                    let navController = UINavigationController(rootViewController: walkingVC)
                    navController.modalPresentationStyle = .pageSheet
                    
                    self.present(navController, animated: true)
                    
                }
                
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionType = summarySections[indexPath.section]
        
        // 1. Handle Headers
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            header.configure(title: sectionType == .exercises ? "Guided Exercise" : "Medications Log")
            header.titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            header.setTitleAlignment(.left)
            return header
        }
        
        // 2. Handle Footers (specifically for medications)
        if kind == UICollectionView.elementKindSectionFooter && sectionType == .medicationsSummary {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyMedicationFooter", for: indexPath)
            
            // Clean up old views
            footer.subviews.forEach { $0.removeFromSuperview() }
            
            if dailyMedications.isEmpty {
                let label = UILabel()
                label.text = "No medications logged"
                label.textColor = .secondaryLabel
                label.font = .systemFont(ofSize: 24, weight: .medium)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                
                footer.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: footer.centerYAnchor, constant: -15)
                ])
            }
            // FIX: Return the footer you just created/configured
            return footer
        }
        
        // 3. Fallback: Swift requires a return for any other case (e.g., Exercise footer)
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyMedicationFooter", for: indexPath)
    }
}
