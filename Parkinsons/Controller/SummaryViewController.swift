import UIKit

// NOTE: Assuming the 'Section' enum and 'ExerciseModel' struct are accessible here (e.g., defined outside the class).
// If not, you must define them here or import the file where they live.

class SummaryViewController: UIViewController {
    
    // 1. Property to receive the selected date
    var dateToDisplay: Date?

    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // Filter the sections to only include those relevant for the summary view
    let summarySections = Section.allCases.filter { $0 == .exercises } // ⭐️ CHANGE: Only include .exercises ⭐️
    
    // ⭐️ 1. POPULATE DUMMY DATA ⭐️
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Completed", progressPercentage: 100, progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "Missed", progressPercentage: 0, progressColorHex: "90AF81")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // ⭐️ IMPORTANT: Call loadDataForSelectedDate and generateSummaryLayout AFTER they are defined.
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        registerCells()
        
        // The definitions for these functions must be moved outside viewDidLoad
        mainCollectionView.setCollectionViewLayout(generateSummaryLayout(), animated: false)
        loadDataForSelectedDate()
        
        if let date = dateToDisplay {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            let dateString = formatter.string(from: date)
            summaryTitleLabel.text = "Summary \n\(dateString)" // Simplified format
        } else {
            summaryTitleLabel.text = "Summary (No date selected)"
        }
    }
    
    func loadDataForSelectedDate() {
        // In a real app, you would load data based on self.dateToDisplay here.
        // For now, we use the placeholder data defined above.
        mainCollectionView.reloadData() // Tell the collection view to load the data
    }

    // ⭐️ 2. IMPLEMENT THE LAYOUT FUNCTION OUTSIDE viewDidLoad ⭐️
    func generateSummaryLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, env) -> NSCollectionLayoutSection? in
            guard sectionIndex < self.summarySections.count else { return nil }
            let sectionType = self.summarySections[sectionIndex]
            
            switch sectionType {
            case .exercises:
                // --- EXERCISES GRID LAYOUT (Section 2) ---
                // 1. Define the Item: Half the width of the group (1.0), and full height.
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Add some trailing inset to create space between the two cards
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)

                // 2. Define the Group: Full width and fixed height (to hold two items side-by-side).
                let groupHeight: CGFloat = 175
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), // The entire section width
                    heightDimension: .absolute(groupHeight)
                )
                // 3. Create a Horizontal Group containing two items.
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item]) // Two items side-by-side

                // 4. Define the Section:
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0 // Spacing is now handled by the item's contentInsets (trailing 12)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                // ⭐️ MODIFICATION: Set orthogonalScrollingBehavior to .none ⭐️
                section.orthogonalScrollingBehavior = .none // <-- Stacks groups vertically

                // ... (header definition remains unchanged) ...
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                return section
                
                
            default:
                // Return nil for any sections we don't handle or don't want to show
                return nil
            }
        }
    }
    
    func registerCells() {
        // Make sure you register the ExerciseCardCell
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        
        // Also register the generic header view
        mainCollectionView.register(
            SectionHeaderView.self, // Assuming you have this helper class
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }
    
    // (Optional but good practice)
    @objc func dismissTapped() {
        self.dismiss(animated: true)
    }
}


// MARK: - UICollectionViewDataSource & Delegate
extension SummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return summarySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch summarySections[section] {
        case .exercises:
            // ⭐️ 3. Return the count of the data ⭐️
            return exerciseData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .exercises:
            // ⭐️ 4. Dequeue and configure the exercise cell ⭐️
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as? ExerciseCardCell else {
                 fatalError("Could not dequeue ExerciseCardCell")
            }
            let model = exerciseData[indexPath.item]
            cell.configure(with: model)
            return cell
            
        default:
            // This case should ideally not be reached if summarySections is filtered correctly.
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeholder_cell", for: indexPath) // Use a dummy cell
            return cell
        }
    }
    
    // ⭐️ 5. Implement the Header View Configuration ⭐️
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath
        ) as! SectionHeaderView // Assuming SectionHeaderView exists
        
        let sectionType = summarySections[indexPath.section]
        
        switch sectionType {
        case .exercises:
            header.configure(title: "Guided Exercise")
            header.setTitleAlignment(.left)
        default:
            break
        }
        
        return header
    }
}
