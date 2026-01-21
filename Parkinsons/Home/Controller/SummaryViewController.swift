import UIKit

class SummaryViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case medicationsSummary
        case exercises
    }
    
    @IBOutlet weak var symptomTableView: UITableView!
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var dateToDisplay: Date?
    var currentSymptomLog: SymptomLogEntry?
    let summarySections = Section.allCases
    
    var medicationData: MedicationModel = MedicationModel(
        name: "Carbidopa",
        time: "9:00 AM",
        detail: "1 capsule",
        iconName: "Medication"
    )
    var medicationTakenCount: Int = 1
    var medicationScheduledCount: Int = 2
    
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Completed", progressPercentage: 100, progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "Missed", progressPercentage: 0, progressColorHex: "90AF81")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        loadDataForSelectedDate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        symptomTableView.dataSource = self
        symptomTableView.delegate = self
        symptomTableView.register(UINib(nibName: "SymptomDetailCell", bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        symptomTableView.rowHeight = 60.0
        symptomTableView.separatorStyle = .none
        symptomTableView.isScrollEnabled = false
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)
    }
    
    @objc func loadDataForSelectedDate() {
        let targetDate = dateToDisplay ?? Date()
        
        self.currentSymptomLog = SymptomLogManager.shared.getLogEntry(for: targetDate)
        
        updateTitleUI(with: targetDate)
        symptomTableView.reloadData()
        mainCollectionView.reloadData()
    }
    
    private func updateTitleUI(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        let dateString = formatter.string(from: date)
        
        let fullString = "Summary \n\(dateString)"
        let attributedString = NSMutableAttributedString(string: fullString)
        
        let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20, weight: .bold)]
        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        attributedString.addAttributes(boldAttributes, range: NSRange(location: 0, length: 7))
        attributedString.addAttributes(regularAttributes, range: NSRange(location: 8, length: dateString.count + 1))
        
        summaryTitleLabel.attributedText = attributedString
        summaryTitleLabel.numberOfLines = 0
    }

    func generateSummaryLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard sectionIndex < self.summarySections.count else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            
            switch sectionType {
            case .medicationsSummary:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.boundarySupplementaryItems = [self.createHeaderItem()]
                return section
                
            case .exercises:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = .init(top: 0, leading: 2, bottom: 0, trailing: 4)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(190)), subitems: [item, item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.boundarySupplementaryItems = [self.createHeaderItem()]
                return section
            }
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
        return currentSymptomLog?.ratings.count ?? 0
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
            cell.configure(with: medicationData, totalTaken: medicationTakenCount, totalScheduled: medicationScheduledCount)
            return cell
        case .exercises:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
            let model = exerciseData[indexPath.item]
            cell.setProgress(completed: WorkoutManager.shared.completedToday.count, total: WorkoutManager.shared.getTodayWorkout().count)
            cell.configure(with: model)
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
