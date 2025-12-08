//
//  HomeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

// MARK: - 1. New Model Structure (Must be defined outside the ViewController)
// You need to ensure this struct exists in your project, likely in a separate file (MedicationModel.swift).


// NOTE: You must also create the MedicationCardCell.swift and MedicationCardCell.xib files!
// NOTE: You must also create a SectionHeaderView.swift for the header title!

class HomeViewController: UIViewController, UICollectionViewDelegate {

    // Renamed from calenderCollectionView to mainCollectionView
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // MARK: - 2. Section Definition and Data
    enum Section: Int, CaseIterable {
        case calendar
        case medications
        case exercises
    }
    let homeSections = Section.allCases

    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    var medicationData: [MedicationModel] = [
        MedicationModel(name: "Levodopa", time: "6:00 PM",detail: "1 capsule",  iconName: "medication"),
            MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
    ]
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressPercentage: 0 ),
        ExerciseModel(title: "Rhythmic Walking", detail: "2-3 times a week", progressPercentage: 0 )
    ]
    
    private let floatingBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self

        // 🥳 Set the main layout to the new multi-section layout
        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        dates = DataStore.shared.getDates()
        autoSelectToday()
        
        updateDateLabel(with: selectedDate)
    }
    
    // MARK: - 3. Updated Cell Registration
    func registerCells(){
        // Existing calendar cell registration
        mainCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        
        // NEW: Medication card cell registration
        mainCollectionView.register(UINib(nibName: "MedicationCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "medication_card_cell")
        
        // NEW: Header view registration for section titles
        mainCollectionView.register(
            SectionHeaderView.self, // You must create this subclass of UICollectionReusableView
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
    }
    
    // MARK: - 4. Refactored Compositional Layout
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self = self else { return nil }
            let sectionType = self.homeSections[sectionIndex]

            switch sectionType {
            case .exercises:
                    // --- EXERCISES HORIZONTAL LAYOUT (Section 2) ---
                    
                    // Item: Takes 100% of the group's space
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                    // Group: Defines the size of one visible card (e.g., 80% width, 180pt height)
                    let groupWidthFraction: CGFloat = 0.45
                    let groupHeight: CGFloat = 180 // Height needed for a vertical card with a circle/labels
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(groupWidthFraction),
                        heightDimension: .absolute(groupHeight)
                    )
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 12
                    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16) // Spacing below header
                    section.orthogonalScrollingBehavior = .continuous
                
                    
                    // Header: "Guided Exercise" title
                    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                    let header = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: headerSize,
                        elementKind: UICollectionView.elementKindSectionHeader,
                        alignment: .top
                    )
                    section.boundarySupplementaryItems = [header]
                    return section
                
            case .calendar:
                // --- CALENDAR HORIZONTAL LAYOUT (Section 0) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(70))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 4 // Spacing between date cells
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16)
                return section

                case .medications:
                    // --- MEDICATIONS HORIZONTAL LAYOUT (Section 1) ---
                    
                    // Item: Takes 100% of the group's space
                    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    
                // Group: Defines the size of one visible card (INCREASED HEIGHT)
                let groupWidthFraction: CGFloat = 0.9
                    let groupHeight: CGFloat = 140 // ⭐️ INCREASED HEIGHT to 120 (or higher, e.g., 140, if needed)
                    
                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(groupWidthFraction),
                        heightDimension: .absolute(groupHeight) // ⭐️ THIS MUST BE SUFFICIENT
                    )
                    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                    let section = NSCollectionLayoutSection(group: group)
                    section.interGroupSpacing = 12 // Spacing between the horizontal cards
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
                    section.orthogonalScrollingBehavior = .continuous // Enable horizontal scrolling
                    
                    // Header: "Upcoming Medications" title
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
        
            return layout
        }
    
    // Existing functions...
    func autoSelectToday() {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {

            selectedDate = dates[index].date

            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                self.mainCollectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
                self.mainCollectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }
    
    // ... rest of the class ...
}

// MARK: - 5. Updated Data Source Extension
extension HomeViewController: UICollectionViewDataSource {
    
    // NEW: Define the total number of vertical sections (2: Calendar and Medications)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeSections.count
    }
    
    // Updated to return item counts based on the section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch homeSections[section] {
        case .calendar:
            return dates.count
        case .medications:
            return medicationData.count
        case .exercises: // ⭐️ NEW ⭐️
                return exerciseData.count
        }
    }
    
    // Updated to dequeue the correct cell for each section
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            // Existing Calendar Cell Logic
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
            let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
            cell.configure(with: model, isSelected: isSelected, isToday: isToday)
            return cell
            
        case .medications:
            // NEW Medication Card Cell Logic
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "medication_card_cell", for: indexPath) as! MedicationCardCollectionViewCell
            let model = medicationData[indexPath.row]
            cell.configure(with: model)
            return cell
            
        case .exercises: // ⭐️ NEW ⭐️
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
                let model = exerciseData[indexPath.row]
                cell.configure(with: model)
                return cell
        }
    }
    
    // NEW: Function to handle supplementary views (section headers)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderView",
            for: indexPath
        ) as! SectionHeaderView
        
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .medications:
            header.configure(title: "Upcoming Medications")
        case .exercises: // ⭐️ NEW ⭐️
                header.configure(title: "Guided Exercise")
        default:
            header.configure(title: "") // Calendar section doesn't need a title above it
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // You'll handle item selection logic here (e.g., navigating to the detail view)
    }
}

extension HomeViewController {
    // Existing helper functions...
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 28 November 2025
        return formatter.string(from: date)
    }
    
    // Function to update the todayDate label
    func updateDateLabel(with date: Date) {
        let dateString = formattedDateString(for: date)
        let isToday = Calendar.current.isDateInToday(date)
        
        if isToday {
            todayDate.text = "Today, \(dateString)"
        } else {
            todayDate.text = dateString
        }
    }
}
