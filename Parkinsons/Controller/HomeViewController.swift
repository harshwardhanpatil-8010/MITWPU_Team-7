//
//  HomeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

// MARK: - Dummy Data Models (Assumed to exist elsewhere in the project)
/*
struct DateModel { let date: Date }
struct MedicationModel {
    let name: String
    let time: String
    let detail: String
    let iconName: String
}
struct ExerciseModel {
    let title: String
    let detail: String
    let progressPercentage: Int
}
struct TherapeuticGameModel {
    let title: String
    let description: String
    let iconName: String
}
class DataStore {
    static let shared = DataStore()
    // Helper to generate some dummy dates
    func getDates() -> [DateModel] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [DateModel] = []
        for i in -15...15 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                dates.append(DateModel(date: date))
            }
        }
        return dates
    }
}
// Assume CalenderCollectionViewCell and SectionHeaderView have `configure(title:)`
// and `configure(with:isSelected:isToday:)` methods respectively.
*/


class HomeViewController: UIViewController, UICollectionViewDelegate {

    // ⭐️ Removed: @IBOutlet weak var todayDate: UILabel! ⭐️
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // MARK: - Section Definition and Data
    enum Section: Int, CaseIterable {
        case calendar
        case medications
        case exercises
        case symptoms
        case therapeuticGames
    }
    let homeSections = Section.allCases

    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    var medicationData: [MedicationModel] = [
        MedicationModel(name: "Levodopa", time: "6:00 PM",detail: "1 capsule",  iconName: "medication"),
        MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
    ]
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressPercentage: 67 ),
        ExerciseModel(title: "Rhythmic Walking", detail: "2-3 times a week", progressPercentage: 25 )
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
        
        // ⭐️ Removed: updateDateLabel(with: selectedDate) ⭐️
    }
    
    @IBAction func profilePageButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! profileViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
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
    
    // MARK: - 4. Refactored Compositional Layout (Calendar Header is now Sticky)
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16)
                
                // ⭐️ NEW: Header for the Calendar Section ⭐️
                let calendarHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: calendarHeaderSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                // ⭐️ CRITICAL: Make the calendar header sticky (pinned) ⭐️
                calendarHeader.pinToVisibleBounds = true
                
                section.boundarySupplementaryItems = [calendarHeader]
                return section

            case .medications:
                // --- MEDICATIONS HORIZONTAL LAYOUT (Section 1) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
//                let groupWidthFraction: CGFloat = 0.9
//                let groupHeight: CGFloat = 140
//
//                let groupSize = NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(groupWidthFraction),
//                    heightDimension: .absolute(groupHeight)
//                )
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(130))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16)
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
                // --- EXERCISES HORIZONTAL LAYOUT (Section 2) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupWidthFraction: CGFloat = 0.45
                let groupHeight: CGFloat = 180
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(groupWidthFraction),
                    heightDimension: .absolute(groupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                return section
                
            case .therapeuticGames:
                // --- GAMES HORIZONTAL LAYOUT (Section 4) ---
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupWidthFraction: CGFloat = 0.47
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(groupWidthFraction),
                    heightDimension: .absolute(170)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 30, trailing: 16)
                section.orthogonalScrollingBehavior = .groupPaging

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

    // Function to update selectedDate when a date cell is tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if homeSections[indexPath.section] == .calendar {
            // Deselect the previously selected item (optional, depending on CalenderCollectionViewCell logic)
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, selectedIndexPath != indexPath {
                collectionView.deselectItem(at: selectedIndexPath, animated: true)
            }
            
            selectedDate = dates[indexPath.row].date
            
            // Reload the calendar header to update the "Today, Date" title dynamically
            collectionView.reloadSections(IndexSet(integer: Section.calendar.rawValue))
            
            // TODO: Reload other content sections (medications, exercises) if their data is date-dependent
            // self.mainCollectionView.reloadSections(IndexSet(integersIn: 1..<self.homeSections.count))
            
        } else {
             // Handle item selection in content sections
             // ...
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
            let message = "You haven't logged your symptoms today"
            let buttonTitle = "Log now"
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
            // ⭐️ Content Header: Left Aligned ⭐️
            header.configure(title: "Upcoming Medications")
            header.setTitleAlignment(.left)
            
        case .exercises:
            // ⭐️ Content Header: Left Aligned ⭐️
            header.configure(title: "Guided Exercise")
            header.setTitleAlignment(.left)
            
        case .symptoms:
            // ⭐️ Content Header: Left Aligned ⭐️
            header.configure(title: "Symptoms")
            header.setTitleAlignment(.left)
            
        case .therapeuticGames:
            // ⭐️ Content Header: Left Aligned ⭐️
            header.configure(title: "Therapeutic Games")
            header.setTitleAlignment(.left)
        }
        
        // Optional: Hide info button for all headers unless explicitly needed
        // header.infoButton.isHidden = true
        
        return header
    }
    
    
    
    
    
    
}



 
extension HomeViewController {
    // Helper function moved here and kept for use in the dynamic header logic
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 28 November 2025
        return formatter.string(from: date)
    }
    
    // ⭐️ Removed: updateDateLabel(with:) function ⭐️
}
