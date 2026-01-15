

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

class HomeViewController: UIViewController, UICollectionViewDelegate , SymptomLogCellDelegate, SymptomLogDetailDelegate {
    
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // MARK: - Section Definition and Data
    
    let homeSections = Section.allCases
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4 // Use a light gray color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressPercentage: 67, progressColorHex: "0088FF" ),
        ExerciseModel(title: "Rhythmic Walking", detail: "2-3 times a week", progressPercentage: 25, progressColorHex: "90AF81" )
    ]
    
    var therapeuticGamesData: [TherapeuticGameModel] = [
        TherapeuticGameModel(
            title: "Mimic the Emoji",
            description: "Complete your daily challenge!",
            iconName: "mimicTheEmoji"
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
        
        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        dates = HomeDataStore.shared.getDates()
        
        //autoSelectToday()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Use performBatchUpdates to ensure reload is finished before scrolling
        mainCollectionView.performBatchUpdates({
            mainCollectionView.reloadData()
        }, completion: { _ in
            self.scrollToSelectedDate(animated: false)
        })
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
            
            separatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 166),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
    }
    
    // MARK: - 3. Cell and Supplementary View Registration
    func registerCells(){
        
        mainCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        
        
        mainCollectionView.register(UINib(nibName: "MedicationCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "medication_card_cell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        mainCollectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "symptom_log_cell")
        mainCollectionView.register(UINib(nibName: "TherapeuticGameCell", bundle: nil), forCellWithReuseIdentifier: "therapeutic_game_cell")
        
        mainCollectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }
    
    // MARK: - 4. Refactored Compositional Layout
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self = self else { return nil }
            let sectionType = self.homeSections[sectionIndex]
            
            switch sectionType {
                
            case .calendar:
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(65))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 1
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
                
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
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
                
                let groupHeight: CGFloat = 179
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
                
            case .symptoms:
                
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
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
                
                let groupHeight: CGFloat = 80
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(groupHeight)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                section.interGroupSpacing = 10
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
        return layout
    }
    
    // MARK: - SymptomLogDetailDelegate Methods
    
    func symptomLogDidComplete(with ratings: [SymptomRating]) {
        
        let newLogEntry = SymptomLogEntry(date: Date(), ratings: ratings)
        SymptomLogManager.shared.saveLogEntry(newLogEntry)
        hasLoggedSymptomsToday = true
        
        
    }
    
    func symptomLogDidCancel() {
        print("Symptom logging canceled.")
    }
    
    // MARK: - SymptomLogCellDelegate Method
    
    func symptomLogCellDidTapLogNow(_ cell: SymptomLogCell) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if hasLoggedSymptomsToday {
            
            guard let todayLog = SymptomLogManager.shared.getLogForToday() else {
                hasLoggedSymptomsToday = false
                return
            }
            
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogHistoryViewController") as? SymptomLogHistoryViewController else { return }
            detailVC.todayLogEntry = todayLog
            detailVC.updateCompletionDelegate = self
            detailVC.modalPresentationStyle = .pageSheet
            self.present(detailVC, animated: true, completion: nil)
        } else {
            guard let symptomVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogDetailViewController") as? SymptomLogDetailViewController else { return }
            symptomVC.delegate = self
            let navController = UINavigationController(rootViewController: symptomVC)
            navController.modalPresentationStyle = .pageSheet
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    private func handleGamesSelection(at row: Int) {
        switch row {
        case 0:
            let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else {
                // ...
                return
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            
            let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else {
                // ...
                return
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("Games item at row \(row) not configured for navigation.")
        }
    }
    
    private func handleExerciseSelection(at row: Int) {
        switch row {
        case 0:
            
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController else {
                return
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        case 1:
            
            let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "SetGoalVCc") as? SetGoalViewController else {
                return
            }
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            print("Exercise item at row \(row) not configured for navigation.")
        }
    }
    
    // MARK: - CollectionView Delegate Selection Control
    
    // ⭐️ NEW: This disables clicking on future dates
    //    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    //        if homeSections[indexPath.section] == .calendar {
    //            let cellDate = dates[indexPath.row].date
    //            let today = Calendar.current.startOfDay(for: Date())
    //            let targetDate = Calendar.current.startOfDay(for: cellDate)
    //
    //            // If the date is after today, don't allow selection
    //            return targetDate <= today
    //        }
    //        return true
    //    }
    
    //
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //          let sectionType = homeSections[indexPath.section]
    //
    //          switch sectionType {
    //          case .calendar:
    //
    //              if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, selectedIndexPath != indexPath {
    //                  collectionView.deselectItem(at: selectedIndexPath, animated: true)
    //              }
    //              selectedDate = dates[indexPath.row].date
    //              collectionView.reloadSections(IndexSet(integer: Section.calendar.rawValue))
    //
    //              let storyboard = UIStoryboard(name: "Home", bundle: nil)
    //              guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else { return }
    //              summaryVC.dateToDisplay = selectedDate
    //              let navController = UINavigationController(rootViewController: summaryVC)
    //              navController.modalPresentationStyle = .pageSheet
    //              present(navController, animated: true, completion: nil)
    //
    //          case .exercises:
    //
    //              handleExerciseSelection(at: indexPath.row)
    //          case .therapeuticGames:
    //              handleGamesSelection(at: indexPath.row)
    //          default:
    //              collectionView.deselectItem(at: indexPath, animated: true)
    //
    //          }
    //      }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            let newDate = dates[indexPath.row].date
            
            // Only proceed if the date actually changed
            if !Calendar.current.isDate(newDate, inSameDayAs: selectedDate) {
                selectedDate = newDate
                
                // Scroll to center first
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? SectionHeaderView {
                        let dateString = formattedDateString(for: selectedDate)
                        let isToday = Calendar.current.isDateInToday(selectedDate)
                        header.configure(title: isToday ? "Today, \(dateString)" : dateString)
                    }
                
                // Update only visible calendar cells (prevents the 'jump' reload)
                let visibleCalendarIndices = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
                collectionView.reloadItems(at: visibleCalendarIndices)
            }

            // Present your modal
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else { return }
            summaryVC.dateToDisplay = selectedDate
            let navController = UINavigationController(rootViewController: summaryVC)
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true, completion: nil)
            
        case .exercises:
            // ⭐️ FIX: Call the exercise handler
            handleExerciseSelection(at: indexPath.row)
            
        case .therapeuticGames:
            // ⭐️ FIX: Call the games handler
            handleGamesSelection(at: indexPath.row)
            
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func scrollToSelectedDate(animated: Bool) {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            let indexPath = IndexPath(item: index, section: Section.calendar.rawValue)
            
            // 1. Ensure the UI has actually finished building the cells
            mainCollectionView.layoutIfNeeded()
            
            // 2. Perform scroll
            self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            
            // 3. Ensure it stays selected
            self.mainCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
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
        case .calendar: return dates.count
        case .medications: return medicationData.count
        case .exercises: return exerciseData.count
        case .symptoms: return 1
        case .therapeuticGames: return therapeuticGamesData.count
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
                   cell.contentView.alpha = 1.0
                   return cell
            
        case .medications:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "medication_card_cell", for: indexPath) as! MedicationCardCollectionViewCell
            cell.configure(with: medicationData[indexPath.row])
            return cell
            
//        case .exercises:
//
//            let cell = mainCollectionView.dequeueReusableCell(
//                withReuseIdentifier: "exercise_card_cell",
//                for: indexPath
//            ) as! ExerciseCardCell
//
//            let model = exerciseData[indexPath.row]
//
//            let completed = WorkoutManager.shared.completedToday.count
//            let total = WorkoutManager.shared.getTodayWorkout().count
//
//            cell.setProgress(completed: completed, total: total)
//            cell.configure(with: model)
//
//            return cell
            
            
//        case .exercises:
//            let cell = mainCollectionView.dequeueReusableCell(
//                withReuseIdentifier: "exercise_card_cell",
//                for: indexPath
//            ) as! ExerciseCardCell
//
//            let model = exerciseData[indexPath.row]
//            
//            // 1. Pass the progress data
//            let completed = WorkoutManager.shared.completedToday.count
//            let total = WorkoutManager.shared.getTodayWorkout().count
//            cell.setProgress(completed: completed, total: total)
//            
//            // 2. Pass the model (which now includes the hex color logic)
//            cell.configure(with: model)
//
//            return cell
//
//        case .exercises:
//            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
//            var model = exerciseData[indexPath.row]
//
//            if indexPath.row == 0 {
//                // --- 10-Min Workout Progress ---
//                let completed = WorkoutManager.shared.completedToday.count
//                let total = WorkoutManager.shared.exercises.count > 0 ? WorkoutManager.shared.exercises.count : 1
//                cell.setProgress(completed: completed, total: total)
//            }
//            } else if indexPath.row == 1 {
//                // --- Rhythmic Walking Progress ---
//                // Get the latest session from your DataStore
//                if let latestSession = DataStore.shared.sessions.first {
//                    let elapsed = latestSession.elapsedSeconds
//                    let goal = latestSession.requestedDurationSeconds > 0 ? latestSession.requestedDurationSeconds : 1
//                    
//                    // Pass the data to the circle
//                    cell.setProgress(completed: elapsed, total: goal)
//                } else {
//                    // No session yet today
//                    cell.setProgress(completed: 0, total: 1)
//                }
//            }
            

            
//            cell.configure(with: model)
//            return cell
//            
        case .exercises:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "exercise_card_cell", for: indexPath) as! ExerciseCardCell
            let model = exerciseData[indexPath.row]

            if indexPath.row == 0 {
                let completed = WorkoutManager.shared.completedToday.count
                let total = WorkoutManager.shared.exercises.count > 0 ? WorkoutManager.shared.exercises.count : 1
                
                cell.setProgress(completed: completed, total: total)
                cell.configure(with: model)
                
            } else if indexPath.row == 1 {
                // 1. Configure cell with basic info (Title, Icon, etc.)
                cell.configure(with: model)
                
                if let lastSession = DataStore.shared.sessions.first {
                    let done = Double(lastSession.elapsedSeconds)
                    let goal = Double(lastSession.requestedDurationSeconds)
                    
                    // 2. Simple Percentage Calculation
                    let percentage = Int((done / goal) * 100)
                    
                    // 3. Update Visuals
                    cell.setProgress(completed: Int(done), total: Int(goal))
                    
                    // 4. FORCE the label to update
                    // Assuming your label inside ExerciseCardCell is called 'percentageLabel'
                    cell.progressLabel.text = "\(percentage)%"
                } else {
                    cell.setProgress(completed: 0, total: 1)
                    cell.progressLabel.text = "0%"
                }
            }
            return cell
            
            
        case .symptoms:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "symptom_log_cell", for: indexPath) as! SymptomLogCell
            cell.delegate = self
            let message = hasLoggedSymptomsToday ? "Your symptoms have been logged today." : "You haven't logged your symptoms today."
            let buttonTitle = hasLoggedSymptomsToday ? "View log" : "Log now"
            cell.configure(with: message, buttonTitle: buttonTitle)
            return cell
            
        case .therapeuticGames:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "therapeutic_game_cell", for: indexPath) as! TherapeuticGameCell
            cell.configure(with: therapeuticGamesData[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            let dateString = formattedDateString(for: selectedDate)
            let isToday = Calendar.current.isDateInToday(selectedDate)
            header.configure(title: isToday ? "Today, \(dateString)" : dateString)
            header.setTitleAlignment(.center)
            
            header.setFont(size: 17, weight: .bold)

        case .medications:
            header.configure(title: "Upcoming Medications")
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold)
            
        case .exercises:
            header.configure(title: "Guided Exercise")
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold)
            
        case .symptoms:
            header.configure(title: "Symptoms")
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold) // Keep standard
            
        case .therapeuticGames:
            header.configure(title: "Therapeutic Games")
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold) // Keep standard
        }
        
        return header
    }
    // MARK: - Navigation Actions
    @IBAction func calendarBarButtonItemTapped(_ sender: UIBarButtonItem) {
        // This assumes your CalendarViewController is in a Storyboard named "Main" or "Home"
        // If you made it via code, use: let vc = CalendarViewController()
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController else { return }
        
        // Wrap in Nav Controller so we can have a 'Close' or 'Done' button
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet// Or .pageSheet based on your preference
        present(nav, animated: true)
    }
}

// MARK: - Helper Extension
extension HomeViewController {
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

}
