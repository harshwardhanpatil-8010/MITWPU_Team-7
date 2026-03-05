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
    private var selectedWorkoutSummary: DailyWorkoutSummary?
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Completed", progressColorHex: "0088FF"),
        ExerciseModel(title: "Skipped Exercises", detail: "None",  progressColorHex: "90AF81")
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

        // Fetch DoseLogs for selected date
        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        logRequest.predicate = NSPredicate(
            format: "doseDay == %@",
            targetDate.startOfDay as NSDate
        )

        do {
            let logs = try context.fetch(logRequest)

            self.totalScheduled = logs.count
            self.totalTaken = logs.filter { $0.doseLogStatus == "taken" }.count


            if let firstLog = logs.first,
               let med = firstLog.medication {

                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"

                let timeString = formatter.string(from: firstLog.doseScheduledTime ?? firstLog.doseLoggedAt ?? Date())

                self.primaryMedication = MedicationModel(
                    name: med.medicationName ?? "",
                    time: timeString,
                    detail: med.medicationForm ?? "",
                    iconName: med.medicationIconName ?? "pill",
                    status: DoseStatus(rawValue: firstLog.doseLogStatus ?? "") ?? .none

                )
            } else {
                self.primaryMedication = nil
            }

        } catch {
            print("Failed to fetch logs:", error)
            self.primaryMedication = nil
            self.totalScheduled = 0
            self.totalTaken = 0
        }

        selectedWorkoutSummary = DailyWorkoutSummaryStore.shared.fetchSummary(for: targetDate)
        let completedNames = DailyWorkoutSummaryStore.shared.completedExerciseNames(for: targetDate)
        let skippedNames = DailyWorkoutSummaryStore.shared.skippedExerciseNames(for: targetDate)

        exerciseData[0] = ExerciseModel(
            title: "10-Min Workout",
            detail: formatExerciseNames(prefix: "Done", names: completedNames),
            progressColorHex: "0088FF"
        )
        exerciseData[1] = ExerciseModel(
            title: "Skipped Exercises",
            detail: formatExerciseNames(prefix: "Skipped", names: skippedNames),
            progressColorHex: "90AF81"
        )

        updateTitleUI(with: targetDate)
        symptomTableView.reloadData()
        updateSymptomTableBackground()
        mainCollectionView.reloadData()
    }

    private func formatExerciseNames(prefix: String, names: [String]) -> String {
        guard !names.isEmpty else { return "\(prefix): None" }
        let preview = names.prefix(2).joined(separator: ", ")
        if names.count > 2 {
            return "\(prefix): \(preview) +\(names.count - 2)"
        }
        return "\(prefix): \(preview)"
    }

    
    private func updateTitleUI(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        
        let fullString = "Summary \n\(dateString)"
        let attributedString = NSMutableAttributedString(string: fullString)
        
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        attributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: 7))
        attributedString.addAttributes(regularAttributes, range: NSRange(location: 8, length: dateString.count + 1))
        
        summaryTitleLabel.attributedText = attributedString
        summaryTitleLabel.numberOfLines = 0
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

            let summary = selectedWorkoutSummary
            let targetDate = dateToDisplay ?? Date()
            let persistedTotal = DailyWorkoutSummaryStore.shared.totalExercises(for: targetDate)

            if indexPath.item == 0 {
                let completed = Int(summary?.completedCount ?? 0)
                let total = max(persistedTotal, 1)

                cell.setProgress(completed: completed, total: total)
            } else {
                let skipped = Int(summary?.skippedCount ?? 0)
                let goal = max(persistedTotal, 1)
                let ratio = Double(skipped) / Double(goal)
                let percent = Int(ratio * 100.0)

                cell.setProgress(completed: skipped, total: goal)
                cell.progressLabel.text = "\(percent)%"
            }

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
        let sectionType = summarySections[indexPath.section]
        header.configure(title: sectionType == .exercises ? "Guided Exercise" : "Medications Log")
        header.setTitleAlignment(.left)
        return header
    }
}
