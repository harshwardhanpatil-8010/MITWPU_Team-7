//
//  HomeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

enum Section: Int, CaseIterable {
    case calendar
    case medications
    case exercises
    case symptoms
    case therapeuticGames
}
// Make sure SymptomLogDetailDelegate is defined in HomeViewController.swift
// or imported from SymptomLogDetailViewController.swift

// Assuming SymptomLogDetailDelegate is defined here or imported:
// protocol SymptomLogDetailDelegate: AnyObject { ... }

class HomeViewController: UIViewController, UICollectionViewDelegate , SymptomLogCellDelegate, SymptomLogDetailDelegate { // ⭐️ Added SymptomLogDetailDelegate ⭐️
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // MARK: - Section Definition and Data
    
    let homeSections = Section.allCases
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4 // Use a light gray color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // Data Source/State property
    var hasLoggedSymptomsToday: Bool = false {
        didSet {
            // When the status changes, reload the section
            if let index = homeSections.firstIndex(of: .symptoms) {
                mainCollectionView.reloadSections(IndexSet(integer: index))
            } else {
                mainCollectionView.reloadData()
            }
        }
    }
    
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    var medicationData: [MedicationModel] = [
        MedicationModel(name: "Levodopa", time: "6:00 PM",detail: "1 capsule",  iconName: "medication"),
        MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
    ]
    var exerciseData: [ExerciseModel] = [
// ⭐️ MODIFIED: Added progressColorHex: "0088FF" ⭐️
ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressPercentage: 67, progressColorHex: "0088FF" ),
// ⭐️ MODIFIED: Added progressColorHex: "90AF81" ⭐️
ExerciseModel(title: "Rhythmic Walking", detail: "2-3 times a week", progressPercentage: 25, progressColorHex: "90AF81" )
]
    var therapeuticGamesData: [TherapeuticGameModel] = [
        TherapeuticGameModel(
            title: "Mimic the Emoji",
            description: "Complete your daily challenge!",
            iconName: "smiley"
        ),
        TherapeuticGameModel(
            title: "Match the Cards",
            description: "Complete your daily challenge!",
            iconName: "cards"
        )
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
        
        // Set the main layout
        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        dates = DataStore.shared.getDates()
        autoSelectToday()
        setupSeparator()
    }
    
    @IBAction func profilePageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! profileViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    func setupSeparator() {
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            // Position the top edge 166 points from the top of the HomeViewController's view
            separatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 166),
            
            // Horizontal position with 16 points inset on both sides
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Define the height of the separator line
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Ensure the collection view content starts below the separator if necessary
        // (Based on your current layout, the calendar section header starts below 166 points,
        // so this is a good insertion point for a fixed element.)
    }
    // MARK: - 3. Cell and Supplementary View Registration
    func registerCells(){
        // Existing calendar cell registration
        mainCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        
        // Content cell registrations
        mainCollectionView.register(UINib(nibName: "MedicationCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "medication_card_cell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        mainCollectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "symptom_log_cell")
        mainCollectionView.register(UINib(nibName: "TherapeuticGameCell", bundle: nil), forCellWithReuseIdentifier: "therapeutic_game_cell")
        
        // Header view registration for ALL section titles (including the new dynamic calendar header)
        mainCollectionView.register(
            SectionHeaderView.self, // Must be created
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }
    func viewLogTapped() {
        // ... (Instantiate SymptomLogHistoryViewController) ...
       // let historyVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogHistoryViewController") as! SymptomLogHistoryViewController
        
        // 1. Pass the CURRENT log data (assuming you store it in HomeVC/Manager)
        // Assuming 'currentDayLog' holds the current data source:
        //historyVC.todayLogEntry = self.currentDayLog
        
        // 2. **CRITICAL FIX:** Set the update delegate to self
      //  historyVC.updateDelegate = self
        
        // ... (Present modally) ...
    }
    // MARK: - 4. Refactored Compositional Layout
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self = self else { return nil }
            let sectionType = self.homeSections[sectionIndex]
            
            switch sectionType {
                
            case .calendar:
                // --- CALENDAR HORIZONTAL LAYOUT (Section 0) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(70))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 4
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                
                let calendarHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: calendarHeaderSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                calendarHeader.pinToVisibleBounds = true
                
                section.boundarySupplementaryItems = [calendarHeader]
                return section
                
            case .medications:
                // --- MEDICATIONS HORIZONTAL LAYOUT (Section 1) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                return section
                
            case .exercises:
                // --- EXERCISES GRID LAYOUT (Section 2) ---
                // 1. Define the Item: Half the width of the group (1.0), and full height.
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Add some trailing inset to create space between the two cards
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)

                // 2. Define the Group: Full width and fixed height (to hold two items side-by-side).
                let groupHeight: CGFloat = 185
                
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
                
            case .symptoms:
                // --- SYMPTOMS VERTICAL LAYOUT (Section 3) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                return section
                
            case .therapeuticGames:
                // --- GAMES GRID LAYOUT (Section 4) ---
                
                // 1. Define the Item: Half the width of the group, and full height.
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // Adjust insets to create a gap between the cards and keep the overall section insets clean.
                // The total width is 1.0, so 0.5 for each item.
                // We'll use a trailing inset on the item for the space between the cards.
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4) // 12pt space between cards
                
                // 2. Define the Group: Full width and fixed height (170) to hold two items side-by-side.
                let groupHeight: CGFloat = 170
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), // Full width of the section
                    heightDimension: .absolute(groupHeight)
                )
                
                // 3. Create a Horizontal Group containing two items.
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                
                // NOTE: We remove the contentInsets from the group, as section insets and item insets are sufficient.
                
                // 4. Define the Section:
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 30, trailing: 16)
                
                // ⭐️ MODIFICATION: Set orthogonalScrollingBehavior to .none ⭐️
                section.orthogonalScrollingBehavior = .none // <-- This disables horizontal scrolling
                
                // ... (header definition remains unchanged) ...
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
    
    // MARK: - SymptomLogDetailDelegate Methods (Receiving Data)
    
    func symptomLogDidComplete(with ratings: [SymptomRating]) {
        // Data is received here! Mark state as true.
        let newLogEntry = SymptomLogEntry(date: Date(), ratings: ratings)
            
            // 2. ⭐️ SAVE THE DATA USING THE MANAGER ⭐️
            SymptomLogManager.shared.saveLogEntry(newLogEntry)
            
            // 3. Update the state property, which triggers the UI reload
            hasLoggedSymptomsToday = true
    }
    
    func symptomLogDidCancel() {
        print("Symptom logging canceled.")
    }
    
    // MARK: - SymptomLogCellDelegate Method (Handling Button Tap)
    
    func symptomLogCellDidTapLogNow(_ cell: SymptomLogCell) {
                
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
                
        if hasLoggedSymptomsToday {
            // Case 1: Logged today -> Navigate directly to Today's Detail View
                    
            // 1. ⭐️ LOAD TODAY'S DATA FROM MANAGER ⭐️
            guard let todayLog = SymptomLogManager.shared.getLogForToday() else {
                print("❌ Warning: Logged status is TRUE, but could not find today's log in persistence. Falling back to Log Now.")
                hasLoggedSymptomsToday = false
                return
            }

            // 2. Instantiate the Detail VC
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogHistoryViewController") as? SymptomLogHistoryViewController else {
                print("Error: Could not instantiate SymptomLogHistoryViewController.")
                return
            }
                    
            // 3. ⭐️ PASS THE DATA ⭐️
            detailVC.todayLogEntry = todayLog
            
            // 4. ⭐️ CRITICAL FIX: Set the HomeViewController as the update delegate for the History VC ⭐️
            detailVC.updateCompletionDelegate = self

            // 5. Present Modally
            detailVC.modalPresentationStyle = .pageSheet
            self.present(detailVC, animated: true, completion: nil)
                    
        } else {
            // Case 2: Not logged today -> Open the Logging Modal (Existing Logic)
            
            // ... (existing code to present SymptomLogDetailViewController, remains unchanged) ...
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let symptomVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogDetailViewController") as? SymptomLogDetailViewController else {
                print("Error: Could not instantiate SymptomLogDetailViewController.")
                return
            }
                    
            symptomVC.delegate = self
                    
            let navController = UINavigationController(rootViewController: symptomVC)
            navController.modalPresentationStyle = .pageSheet
                    
            self.present(navController, animated: true, completion: nil)
        }
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
    
    // Function to update selectedDate when a date cell is tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if homeSections[indexPath.section] == .calendar {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
            }
            
            selectedDate = dates[indexPath.row].date
            
            // Reload the calendar header to update the "Today, Date" title dynamically
            collectionView.reloadSections(IndexSet(integer: Section.calendar.rawValue))
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil) // Assuming HomeViewController is in "Home.storyboard"
                        
                        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else {
                            print("Error: Could not instantiate SummaryViewController.")
                            return
                        }
                        
                        // Pass the newly selected date to the SummaryViewController
                        summaryVC.dateToDisplay = selectedDate
                        
                        // Wrap in a navigation controller (optional, but good practice for a modal sheet)
                        let navController = UINavigationController(rootViewController: summaryVC)
                        navController.modalPresentationStyle = .pageSheet // Present as a partial sheet
                        
                        present(navController, animated: true, completion: nil)
        } else {
            // Handle item selection in content sections
        }
    }
}

// MARK: - 5. Updated Data Source Extension
extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch homeSections[section] {
        case .calendar:
            return dates.count
        case .medications:
            return medicationData.count
        case .exercises:
            return exerciseData.count
        case .symptoms:
            return 1
        case .therapeuticGames:
            return therapeuticGamesData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
            let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
            cell.configure(with: model, isSelected: isSelected, isToday: isToday)
            return cell
            
        case .medications:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "medication_card_cell", for: indexPath) as! MedicationCardCollectionViewCell
            let model = medicationData[indexPath.row]
            cell.configure(with: model)
            return cell
            
        case .exercises:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
            let model = exerciseData[indexPath.row]
            cell.configure(with: model)
            return cell
            
        case .symptoms:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "symptom_log_cell", for: indexPath) as! SymptomLogCell
            
            cell.delegate = self
            
            let message: String
            let buttonTitle: String
            
            if hasLoggedSymptomsToday {
                message = "Your symptoms have been logged today."
                buttonTitle = "View log"
            } else {
                message = "You haven't logged your symptoms today."
                buttonTitle = "Log now"
            }
            cell.configure(with: message, buttonTitle: buttonTitle)
            return cell
            
        case .therapeuticGames:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "therapeutic_game_cell", for: indexPath) as! TherapeuticGameCell
            let game = therapeuticGamesData[indexPath.item]
            cell.configure(with: game)
            return cell
        }
    }
    
    // ⭐️ Updated Function to handle dynamic calendar header title ⭐️
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
        case .calendar:
            // ⭐️ Calendar Header: Centered ⭐️
            let dateString = formattedDateString(for: selectedDate)
            let isToday = Calendar.current.isDateInToday(selectedDate)
            
            let title = isToday ? "Today, \(dateString)" : dateString
            header.configure(title: title)
            
            // ⭐️ CRITICAL: Set Alignment to Center ⭐️
            header.setTitleAlignment(.center)
            
        case .medications:
            header.configure(title: "Upcoming Medications")
            header.setTitleAlignment(.left)
            
        case .exercises:
            header.configure(title: "Guided Exercise")
            header.setTitleAlignment(.left)
            
        case .symptoms:
            header.configure(title: "Symptoms")
            header.setTitleAlignment(.left)
            
        case .therapeuticGames:
            header.configure(title: "Therapeutic Games")
            header.setTitleAlignment(.left)
        }
        
        return header
    }
}


// MARK: - Helper Extension
extension HomeViewController {
    // Helper function kept for use in the dynamic header logic
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 28 November 2025
        return formatter.string(from: date)
    }
   
}
