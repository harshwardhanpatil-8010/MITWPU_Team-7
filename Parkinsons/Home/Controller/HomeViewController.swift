import UIKit

enum Section: Int, CaseIterable {
    case calendar
    case medications
    case exercises
    case symptoms
    case therapeuticGames
}

class HomeViewController: UIViewController, UICollectionViewDelegate, SymptomLogCellDelegate, SymptomLogDetailDelegate {
    
    private let todayViewModel = TodayMedicationViewModel()
    private var todayDoses: [TodayDoseItem] = []
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    private var medicationLoggedObserver: NSObjectProtocol?
    
    let homeSections = Section.allCases
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var hasLoggedSymptomsToday: Bool = false {
        didSet {
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
        MedicationModel(name: "Levodopa", time: "6:00 PM", detail: "1 capsule", iconName: "medication"),
        MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
    ]
    
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday", progressPercentage: 67, progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "2-3 times a week", progressPercentage: 25, progressColorHex: "90AF81")
    ]
    
    var therapeuticGamesData: [TherapeuticGameModel] = [
        TherapeuticGameModel(title: "Mimic the Emoji", description: "Complete your daily challenge!", iconName: "mimicTheEmoji"),
        TherapeuticGameModel(title: "Match the Cards", description: "Complete your daily challenge!", iconName: "cards")
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
        loadRealMedicationData()
        
        medicationLoggedObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MedicationLogged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadRealMedicationData()
        }
    }
    
    deinit {
        if let observer = medicationLoggedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    private func loadRealMedicationData() {
        let myMedications = MedicationDataStore.shared.medications
        todayViewModel.loadTodayMedications(from: myMedications)
        
        todayViewModel.loadLoggedDoses(
            medications: myMedications,
            logs: DoseLogDataStore.shared.logs,
            for: Date()
        )
        
        let unloggedDoses = todayViewModel.todayDoses.filter { dose in
            !todayViewModel.loggedDoses.contains(where: { $0.id == dose.id })
        }
        
        self.todayDoses = unloggedDoses
        self.mainCollectionView.reloadData()
    }
    private func updateDose(_ dose: TodayDoseItem, status: DoseStatus) {
        let log = DoseLog(
            id: UUID(),
            medicationID: dose.medicationID,
            doseID: dose.id,
            scheduledTime: dose.scheduledTime,
            loggedAt: Date(),
            status:status,
            day: Date().startOfDay
        )

        DoseLogDataStore.shared.logDose(log)
       
        loadRealMedicationData()
      
        NotificationCenter.default.post(name: NSNotification.Name("MedicationLogged"), object: nil)
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
    
    func registerCells() {
        mainCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        mainCollectionView.register(UINib(nibName: "MedicationCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MedicationCardCell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
        mainCollectionView.register(UINib(nibName: "SymptomLogCell", bundle: nil), forCellWithReuseIdentifier: "symptom_log_cell")
        mainCollectionView.register(UINib(nibName: "TherapeuticGameCell", bundle: nil), forCellWithReuseIdentifier: "therapeutic_game_cell")
        
        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")

        mainCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "EmptyMedicationFooter")
    }
  
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
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(90))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                let footerHeight: CGFloat = self.todayDoses.isEmpty ? 40 : 0
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(footerHeight))
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: footerSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )

                section.boundarySupplementaryItems = [header, footer]
                
                return section
                
            case .exercises:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(179))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                section.interGroupSpacing = 10
                
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
    
    func symptomLogDidComplete(with ratings: [SymptomRating]) {
        let newLogEntry = SymptomLogEntry(date: Date(), ratings: ratings)
        SymptomLogManager.shared.saveLogEntry(newLogEntry)
        hasLoggedSymptomsToday = true
    }
    
    func symptomLogDidCancel() { }
    
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
            self.present(detailVC, animated: true)
        } else {
            guard let symptomVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogDetailViewController") as? SymptomLogDetailViewController else { return }
            symptomVC.delegate = self
            let navController = UINavigationController(rootViewController: symptomVC)
            navController.modalPresentationStyle = .pageSheet
            self.present(navController, animated: true)
        }
    }
    
    private func handleGamesSelection(at row: Int) {
        let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleExerciseSelection(at row: Int) {
        switch row {
        case 0:
            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "SetGoalVCc") as? SetGoalViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            let newDate = dates[indexPath.row].date
            if !Calendar.current.isDate(newDate, inSameDayAs: selectedDate) {
                selectedDate = newDate
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? SectionHeaderView {
                    let dateString = formattedDateString(for: selectedDate)
                    let isToday = Calendar.current.isDateInToday(selectedDate)
                    header.configure(title: isToday ? "Today, \(dateString)" : dateString)
                }
                let visibleCalendarIndices = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
                collectionView.reloadItems(at: visibleCalendarIndices)
            }

            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else { return }
            summaryVC.dateToDisplay = selectedDate
            let navController = UINavigationController(rootViewController: summaryVC)
            navController.modalPresentationStyle = .pageSheet
            present(navController, animated: true)
            
        case .exercises:
            handleExerciseSelection(at: indexPath.row)
        case .therapeuticGames:
            handleGamesSelection(at: indexPath.row)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func scrollToSelectedDate(animated: Bool) {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            let indexPath = IndexPath(item: index, section: Section.calendar.rawValue)
            mainCollectionView.layoutIfNeeded()
            mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            mainCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch homeSections[section] {
        case .calendar: return dates.count
        case .medications:
            return todayDoses.count
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
            return cell
            
        case .medications:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCardCell", for: indexPath) as! MedicationCardCollectionViewCell
            let doseItem = todayDoses[indexPath.row]
            cell.configure(with: doseItem)
            cell.delegate = self
            return cell
            
        case .exercises:
            let cell = mainCollectionView.dequeueReusableCell(
                    withReuseIdentifier: "exercise_card_cell",
                    for: indexPath
                ) as! ExerciseCardCell

                let model = exerciseData[indexPath.row]
                cell.configure(with: model)

                if indexPath.row == 0 {
                    let completed = WorkoutManager.shared.completedToday.count
                    let total = max(WorkoutManager.shared.exercises.count, 1)
                    cell.setProgress(completed: completed, total: total)

                } else if indexPath.row == 1 {
                    if let lastSession = DataStore.shared.sessions.first {
                        let done = Double(lastSession.elapsedSeconds)
                        let goal = Double(lastSession.requestedDurationSeconds)
                        let percentage = Int((done / max(goal, 1)) * 100)

                        cell.setProgress(completed: Int(done), total: Int(goal))
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
        let sectionType = homeSections[indexPath.section]
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold)
            
            switch sectionType {
            case .calendar:
                let dateString = formattedDateString(for: selectedDate)
                let isToday = Calendar.current.isDateInToday(selectedDate)
                header.configure(title: isToday ? "Today, \(dateString)" : dateString)
                header.setTitleAlignment(.center)
                header.setFont(size: 17, weight: .bold)
            case .medications:
                header.configure(title: "Upcoming Medications")
            case .exercises:
                header.configure(title: "Guided Exercise")
            case .symptoms:
                header.configure(title: "Symptoms")
            case .therapeuticGames:
                header.configure(title: "Therapeutic Games")
            }
            return header
        }
        
        if kind == UICollectionView.elementKindSectionFooter && sectionType == .medications {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyMedicationFooter", for: indexPath)
            
            // Clear previous labels
            footer.subviews.forEach { $0.removeFromSuperview() }
            
            // 1. Check if the master list is actually empty
            let noMedicationsCreated = MedicationDataStore.shared.medications.isEmpty
            
            // 2. Check if there are no more doses left to take today
            let allDosesProcessed = todayDoses.isEmpty
            
            if allDosesProcessed {
                let label = UILabel()
                label.textColor = .systemGray2
                label.font = .systemFont(ofSize: 20, weight: .medium)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                
                // Decide which text to show
                if noMedicationsCreated {
                    label.text = "No Medications Added Yet"
                } else {
                    label.text = "All medications Logged!"
                }
                
                footer.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: footer.centerYAnchor, constant: -15)
                ])
            }
            
            return footer
        }
        return UICollectionReusableView()
    }
}

extension HomeViewController {
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
extension HomeViewController: MedicationCardDelegate {
    func didTapTaken(for dose: TodayDoseItem) {
        updateDose(dose, status: .taken)
    }
    
    func didTapSkipped(for dose: TodayDoseItem) {
        updateDose(dose, status: .skipped)
    }
}
