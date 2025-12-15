import UIKit

// Make sure you have the necessary Model structs (MedicationModel, ExerciseModel)
// defined and accessible in your project, likely in separate files.
// Also ensure MedicationSummaryCell, ExerciseCardCell, and SectionHeaderView are available.

class SummaryViewController: UIViewController {
    
    // ⭐️ 1. Define the Section Enum INSIDE the class ⭐️
    enum Section: Int, CaseIterable {
        case medicationsSummary // Order is critical: First section
        case exercises
        // Add other relevant sections for the summary here
    }
    
    // 1. Property to receive the selected date
    var dateToDisplay: Date?
    
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // Use the nested Section enum
    let summarySections = Section.allCases
    
    // 2. MEDICATION SUMMARY DUMMY DATA
    var medicationData: MedicationModel = MedicationModel(
        name: "Carbidopa",
        time: "9:00 AM",
        detail: "1 capsule",
        iconName: "Medication" // Use system icon for placeholder
    )
    var medicationTakenCount: Int = 1
    var medicationScheduledCount: Int = 2
    
    // EXERCISE DUMMY DATA
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
        
        // Set the layout
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
        // In a real app, you would load data based on self.dateToDisplay here.
        mainCollectionView.reloadData()
    }
    
    // 3. Register Cells
    func registerCells() {
        // Register the new Medication Summary Cell
        mainCollectionView.register(UINib(nibName: "medicationSummary", bundle: nil), forCellWithReuseIdentifier: "MedicationSummaryCell")
        
        // Register the Exercise Card Cell
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        
        // Also register the generic header view
        mainCollectionView.register(
            SectionHeaderView.self, // Assuming you have this helper class
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "placeholder_cell")
    }
    
    // 4. Compositional Layout Definition
    func generateSummaryLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard sectionIndex < self.summarySections.count else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            
            switch sectionType {
            case .medicationsSummary:
                // --- MEDICATIONS SUMMARY LAYOUT ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                // Adjust top inset to account for the header height (e.g., set to 8, or adjust as needed)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.orthogonalScrollingBehavior = .none
                
                // ⭐️ HEADER DEFINITION AND ATTACHMENT ⭐️
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                // ⭐️ FIX: Attach the header to the section ⭐️
                section.boundarySupplementaryItems = [header]
                
                return section
                
            case .exercises:
                // --- EXERCISES GRID LAYOUT ---
                // ... (This section remains unchanged as it already had the header attachment)
                
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
    
    // 5. Number of items per section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch summarySections[section] {
        case .medicationsSummary:
            return 1 // Always 1 item for the summary card
        case .exercises:
            return exerciseData.count
        }
    }
    
    // 6. Cell for Item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .medicationsSummary:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationSummaryCell", for: indexPath) as? MedicationSummaryCell else {
                fatalError("Could not dequeue MedicationSummaryCell")
            }
            // Configure with the summary data
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
    
    // 7. Supplementary View (Header)
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
                    // ⭐️ CONFIGURE HEADER FOR MEDICATIONS LOG ⭐️
                    header.configure(title: "Medications Log")
                    header.setTitleAlignment(.left)
                }
        
        return header
    }
}
