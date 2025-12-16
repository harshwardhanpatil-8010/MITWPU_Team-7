import UIKit

class SummaryViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case medicationsSummary
        case exercises
    }
    
    var dateToDisplay: Date?
    
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
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
        
        view.backgroundColor = .systemBackground
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        registerCells()
        
        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)
        loadDataForSelectedDate()
        
        if let date = dateToDisplay {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            let dateString = formatter.string(from: date)
            summaryTitleLabel.text = "Summary \n\(dateString)"
        } else {
            summaryTitleLabel.text = "Summary (No date selected)"
        }
    }
    
    func loadDataForSelectedDate() {
        mainCollectionView.reloadData()
    }
    
    func registerCells() {
        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")
        
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        
        mainCollectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "placeholder_cell")
    }
    
    func generateSummaryLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard sectionIndex < self.summarySections.count else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            
            switch sectionType {
            case .medicationsSummary:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.orthogonalScrollingBehavior = .none
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
                
            case .exercises:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
                
                let groupHeight: CGFloat = 175
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(groupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                section.orthogonalScrollingBehavior = .none
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
                
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension SummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return summarySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch summarySections[section] {
        case .medicationsSummary:
            return 1
        case .exercises:
            return exerciseData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .medicationsSummary:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationSummaryCell", for: indexPath) as? MedicationSummaryCell else {
                fatalError("Could not dequeue MedicationSummaryCell")
            }
            cell.configure(with: medicationData, totalTaken: medicationTakenCount, totalScheduled: medicationScheduledCount)
            return cell
            
        case .exercises:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as? ExerciseCardCell else {
                fatalError("Could not dequeue ExerciseCardCell")
            }
            let model = exerciseData[indexPath.item]
            cell.configure(with: model)
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath
        ) as! SectionHeaderView
        
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .exercises:
            header.configure(title: "Guided Exercise")
            header.setTitleAlignment(.left)
        case .medicationsSummary:
            header.configure(title: "Medications Log")
            header.setTitleAlignment(.left)
        }
        
        return header
    }
}
