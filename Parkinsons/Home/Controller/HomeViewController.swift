//
//
//import UIKit
//import CoreData
//enum Section: Int, CaseIterable {
//    case calendar
//    case medications
//    case exercises
//    case therapeuticGames
//}
//
//class HomeViewController: UIViewController, UICollectionViewDelegate {
//    
//    @IBOutlet weak var NameOfUser: UILabel!
//    private let todayViewModel = TodayMedicationViewModel()
//    private var todayDoses: [TodayDoseItem] = []
//
//    private var noMedicationsCreated: Bool {
//        let context = PersistenceController.shared.viewContext
//        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
//        return ((try? context.count(for: request)) ?? 0) == 0
//    }
//
//
//    @IBOutlet weak var NameLabel: UILabel!
//    @IBOutlet weak var mainCollectionView: UICollectionView!
//    
//    private var medicationLoggedObserver: NSObjectProtocol?
//    private var userProfileUpdatedObserver: NSObjectProtocol?
//    
//    let homeSections = Section.allCases
//    private let separatorView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.systemGray4
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    var dates: [DateModel] = []
//    var selectedDate: Date = Date()
//    
//    var medicationData: [MedicationModel] = [
//        MedicationModel(name: "Levodopa", time: "6:00 PM", detail: "1 capsule", iconName: "medication"),
//        MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
//    ]
//    
//    var exerciseData: [ExerciseModel] = [
//        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday",  progressColorHex: "0088FF"),
//        ExerciseModel(title: "Rhythmic Walking", detail: "Repeat everyday", progressColorHex: "90AF81")
//    ]
//    
//    var therapeuticGamesData: [TherapeuticGameModel] = [
//        TherapeuticGameModel(title: "Mimic the Emoji", description: "Complete your daily challenge!", iconName: "face.smiling", iconColor: .systemOrange),
//           TherapeuticGameModel(title: "Match the Cards", description: "Complete your daily challenge!", iconName: "brain.fill", iconColor: .systemPurple)
//    ]
//    
//    private let floatingBar: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 34
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.1
//        view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        view.layer.shadowRadius = 8
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let savedFull = UserDefaults.standard.string(forKey: "UserFullName") ?? "John"
//        let firstName = savedFull.components(separatedBy: " ").first ?? savedFull
//        self.NameOfUser.text = "Hello \(firstName)!"
//
//        
//
//        updateGreeting()
//
//        registerCells()
//        
//        mainCollectionView.dataSource = self
//        mainCollectionView.delegate = self
//        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
//        
//        dates = HomeDataStore.shared.getDates()
//        loadRealMedicationData()
//        
//        medicationLoggedObserver = NotificationCenter.default.addObserver(
//            forName: NSNotification.Name("MedicationLogged"),
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.loadRealMedicationData()
//        }
//
//        userProfileUpdatedObserver = NotificationCenter.default.addObserver(
//            forName: NSNotification.Name("UserProfileUpdated"),
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            self?.updateGreeting()
//        }
//    }
//    
//    deinit {
//        if let observer = medicationLoggedObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
//        if let observer = userProfileUpdatedObserver {
//            NotificationCenter.default.removeObserver(observer)
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        updateGreeting()
//
//        mainCollectionView.performBatchUpdates({
//            mainCollectionView.reloadData()
//        }, completion: { _ in
//            self.scrollToSelectedDate(animated: false)
//        })
//    }
//
//    @IBAction func profilePageButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "profileViewController") as! profileViewController
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .pageSheet
//        present(nav, animated: true)
//    }
//
//    private func updateGreeting() {
//        if let fullName = UserDefaults.standard.string(forKey: "userName")?
//            .trimmingCharacters(in: .whitespacesAndNewlines),
//           !fullName.isEmpty {
//            let firstName = fullName
//                .split(whereSeparator: { $0.isWhitespace })
//                .first
//                .map(String.init) ?? fullName
//            NameLabel.text = "Hello \(firstName)"
//            NameOfUser.text = "Hello \(firstName)"
//        } else {
//            NameLabel.text = "Hello John"
//            NameOfUser.text = "Hello John"
//        }
//    }
//    private func loadRealMedicationData() {
//        let context = PersistenceController.shared.viewContext
//
//        let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
//        let medications = (try? context.fetch(medRequest)) ?? []
//
//        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
//        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
//
//        logRequest.predicate = NSPredicate(
//            format: "doseScheduledTime >= %@ AND doseScheduledTime < %@",
//            startOfDay as NSDate,
//            endOfDay as NSDate
//        )
//
//        let logs = (try? context.fetch(logRequest)) ?? []
//
//        todayViewModel.loadTodayMedications(from: medications)
//
//        todayViewModel.loadLoggedDoses(
//            medications: medications,
//            logs: logs,
//            for: Date()
//        )
//
//        let unloggedDoses = todayViewModel.todayDoses.filter { dose in
//            !todayViewModel.loggedDoses.contains(where: { $0.id == dose.id })
//        }
//
//        self.todayDoses = unloggedDoses
//        self.mainCollectionView.reloadData()
//    }
//
//    private func updateDose(_ dose: TodayDoseItem, status: DoseStatus) {
//
//            let context = PersistenceController.shared.viewContext
//            let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
//            let medications = (try? context.fetch(medRequest)) ?? []
//
//            MedicationDoseLogger.shared.log(
//                dose: dose,
//                status: status,
//                medications: medications,
//                context: context
//            )
//
//            loadRealMedicationData()
//
//            NotificationCenter.default.post(
//                name: NSNotification.Name("MedicationLogged"),
//                object: nil
//            )
//        }
//    
//
//
//
//    func setupSeparator() {
//        view.addSubview(separatorView)
//        NSLayoutConstraint.activate([
//            separatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 166),
//            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            separatorView.heightAnchor.constraint(equalToConstant: 1)
//        ])
//    }
//    
//    func registerCells() {
//        mainCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
//        mainCollectionView.register(UINib(nibName: "MedicationCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MedicationCardCell")
//        mainCollectionView.register(UINib(nibName: "NoMedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoMedCell")
//        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
//        mainCollectionView.register(UINib(nibName: "TherapeuticGameCell", bundle: nil), forCellWithReuseIdentifier: "therapeutic_game_cell")
//        
//        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
//
//        mainCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "EmptyMedicationFooter")
//    }
//  
//    func generateLayout() -> UICollectionViewLayout {
//        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
//            guard let self = self else { return nil }
//            let sectionType = self.homeSections[sectionIndex]
//            
//            switch sectionType {
//            case .calendar:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(65))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .continuous
//                section.interGroupSpacing = 1
//                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
//                
//                let calendarHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
//                let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: calendarHeaderSize,
//                    elementKind: UICollectionView.elementKindSectionHeader,
//                    alignment: .top
//                )
//                calendarHeader.pinToVisibleBounds = true
//                section.boundarySupplementaryItems = [calendarHeader]
//                return section
//                
//            case .medications:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                let groupSize: NSCollectionLayoutSize
//                if self.noMedicationsCreated {
//                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
//                } else {
//                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(90))
//                }
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = self.noMedicationsCreated ? .none : .groupPaging
//                section.interGroupSpacing = 12
//                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
//                
//                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
//                let header = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: headerSize,
//                    elementKind: UICollectionView.elementKindSectionHeader,
//                    alignment: .top
//                )
//                let footerHeight: CGFloat = (!self.noMedicationsCreated && self.todayDoses.isEmpty) ? 40 : 0
//                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(footerHeight))
//                let footer = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: footerSize,
//                    elementKind: UICollectionView.elementKindSectionFooter,
//                    alignment: .bottom
//                )
//
//                section.boundarySupplementaryItems = [header, footer]
//                
//                return section
//                
//            case .exercises:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(189))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
//                
//                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
//                let header = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: headerSize,
//                    elementKind: UICollectionView.elementKindSectionHeader,
//                    alignment: .top
//                )
//                section.boundarySupplementaryItems = [header]
//                return section
//
//            case .therapeuticGames:
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 4)
//                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
//                section.interGroupSpacing = 10
//                
//                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
//                let header = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: headerSize,
//                    elementKind: UICollectionView.elementKindSectionHeader,
//                    alignment: .top
//                )
//                section.boundarySupplementaryItems = [header]
//                return section
//            }
//        }
//        return layout
//    }
//    
//    
//    private func handleGamesSelection(at row: Int) {
//        switch row {
//        case 1:
//            let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else { return }
//            navigationController?.pushViewController(vc, animated: true)
//            
//        case 0:
//            let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "EmojiLandingScreenID") as? EmojiLandingScreen else { return }
//            navigationController?.pushViewController(vc, animated: true)
//            
//        default:
//            break
//        }
//    }
//    private func handleExerciseSelection(at row: Int) {
//        switch row {
//        case 0:
//            let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "exerciseLandingPage") as? _0minworkoutLandingPageViewController else { return }
//            navigationController?.pushViewController(vc, animated: true)
//        case 1:
//            let storyboard = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(withIdentifier: "SetGoalVCc") as? SetGoalViewController else { return }
//            navigationController?.pushViewController(vc, animated: true)
//        default: break
//        }
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let sectionType = homeSections[indexPath.section]
//        
//        switch sectionType {
//        case .calendar:
//            let model = dates[indexPath.row]
//            let calendar = Calendar.current
//            
//            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
//            
//            if model.date >= tomorrow {
//                collectionView.deselectItem(at: indexPath, animated: false)
//                return
//            }
//
//            let newDate = model.date
//            if !calendar.isDate(newDate, inSameDayAs: selectedDate) {
//                selectedDate = newDate
//                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//                
//                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? SectionHeaderView {
//                    let dateString = formattedDateString(for: selectedDate)
//                    let isToday = calendar.isDateInToday(selectedDate)
//                    header.configure(title: isToday ? "Today, \(dateString)" : dateString)
//                }
//                let visibleCalendarIndices = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
//                collectionView.reloadItems(at: visibleCalendarIndices)
//                collectionView.reloadSections(IndexSet(integer: Section.exercises.rawValue))
//            }
//
//            let storyboard = UIStoryboard(name: "Home", bundle: nil)
//            guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else { return }
//            summaryVC.dateToDisplay = selectedDate
//            let navController = UINavigationController(rootViewController: summaryVC)
//            navController.modalPresentationStyle = .pageSheet
//            present(navController, animated: true)
//            
//        case .exercises:
//            handleExerciseSelection(at: indexPath.row)
//        case .therapeuticGames:
//            handleGamesSelection(at: indexPath.row)
//        default:
//            collectionView.deselectItem(at: indexPath, animated: true)
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        let sectionType = homeSections[indexPath.section]
//        
//        if sectionType == .calendar {
//            let targetDate = dates[indexPath.row].date
//            let isToday = Calendar.current.isDateInToday(targetDate)
//            let isFuture = targetDate > Date() && !isToday
//            
//            return !isFuture
//        }
//        
//        return true
//    }
//    
//    func scrollToSelectedDate(animated: Bool) {
//        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
//            let indexPath = IndexPath(item: index, section: Section.calendar.rawValue)
//            mainCollectionView.layoutIfNeeded()
//            mainCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
//            mainCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
//        }
//    }
//}
//
//extension HomeViewController: UICollectionViewDataSource {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return homeSections.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch homeSections[section] {
//        case .calendar: return dates.count
//        case .medications:
//            return noMedicationsCreated ? 1 : todayDoses.count
//        case .exercises: return exerciseData.count
//        case .therapeuticGames: return therapeuticGamesData.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let sectionType = homeSections[indexPath.section]
//        
//        switch sectionType {
//        case .calendar:
//            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
//            let model = dates[indexPath.row]
//            
//            let calendar = Calendar.current
//            let isSelected = calendar.isDate(model.date, inSameDayAs: selectedDate)
//            let isToday = calendar.isDateInToday(model.date)
//            
//            let isFuture = model.date > calendar.startOfDay(for: Date().addingTimeInterval(86400))
//            cell.configure(with: model, isSelected: isSelected, isToday: isToday, isFuture: isFuture)
//            cell.isUserInteractionEnabled = !isFuture
//            
//            return cell
//            
//        case .medications:
//            if noMedicationsCreated {
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoMedCell", for: indexPath) as! NoMedCollectionViewCell
//                cell.delegate = self
//                return cell
//            }
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MedicationCardCell", for: indexPath) as! MedicationCardCollectionViewCell
//            let doseItem = todayDoses[indexPath.row]
//            cell.configure(with: doseItem)
//            cell.delegate = self
//            return cell
//            
//        case .exercises:
//            let cell = mainCollectionView.dequeueReusableCell(
//                withReuseIdentifier: "exercise_card_cell",
//                for: indexPath
//            ) as! ExerciseCardCell
//            let model = exerciseData[indexPath.row]
//            cell.configure(with: model)
//            if indexPath.row == 0 {
//                cell.setThemeColor(UIColor(hex: "0088FF"))
//                let targetDate = selectedDate
//                let isToday = Calendar.current.isDateInToday(targetDate)
//                let summary = DailyWorkoutSummaryStore.shared.fetchSummary(for: targetDate)
//                let storedCompleted = Int(summary?.completedCount ?? 0)
//                let storedTotal = Int(summary?.totalExercises ?? 0)
//                let completed = isToday ? max(storedCompleted, WorkoutManager.shared.completedToday.count) : storedCompleted
//                let total = max(isToday ? max(storedTotal, WorkoutManager.shared.exercises.count) : storedTotal, 7)
//                cell.setProgress(completed: completed, total: total)
//            } else if indexPath.row == 1 {
//                cell.setThemeColor(UIColor(hex: "90AF81"))
//                if let lastSession = DataStore.shared.sessions.first {
//                    let done = lastSession.elapsedSeconds
//                    let goal = max(lastSession.requestedDurationSeconds, 1)
//                    let percentage = Int((Double(done) / Double(goal)) * 100)
//                    cell.setProgress(completed: done, total: goal)
//                    cell.progressLabel.text = "\(percentage)%"
//                } else {
//                    cell.setProgress(completed: 0, total: 1)
//                    cell.progressLabel.text = "0%"
//                }
//            }
//            return cell
//
//        case .therapeuticGames:
//            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "therapeutic_game_cell", for: indexPath) as! TherapeuticGameCell
//            var calendar = Calendar(identifier: .gregorian)
//            calendar.firstWeekday = 2
//            let now = Date()
//            let comps = calendar.dateComponents([.year, .month], from: now)
//            let firstDayOfMonth = calendar.date(from: comps)!
//            let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
//
//            let today = calendar.startOfDay(for: now)
//            let completionText: String
//            let isTodayCompleted: Bool
//            switch indexPath.item {
//            case 0:
//                let completedCount = (0..<daysInMonth).filter { offset in
//                    guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
//                    return EmojiGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
//                }.count
//                completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
//                isTodayCompleted = EmojiGameManager.shared.isCompleted(date: today)
//            case 1:
//                let completedCount = (0..<daysInMonth).filter { offset in
//                    guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
//                    return DailyGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
//                }.count
//                completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
//                isTodayCompleted = DailyGameManager.shared.isCompleted(date: today)
//            default:
//                completionText = ""
//                isTodayCompleted = false
//            }
//            cell.configure(with: therapeuticGamesData[indexPath.item], completionText: completionText, isTodayCompleted: isTodayCompleted)
//            return cell
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let sectionType = homeSections[indexPath.section]
//        
//        if kind == UICollectionView.elementKindSectionHeader {
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
//            
//            header.setTitleAlignment(.left)
//            header.setFont(size: 20, weight: .bold)
//            header.onInfoTap = nil
//
//            switch sectionType {
//            case .calendar:
//                let dateString = formattedDateString(for: selectedDate)
//                let isToday = Calendar.current.isDateInToday(selectedDate)
//                header.configure(title: isToday ? "Today, \(dateString)" : dateString, showInfoIcon: false)
//                header.setTitleAlignment(.center)
//                header.setFont(size: 17, weight: .bold)
//                
//            case .medications:
//                header.configure(title: "Upcoming Medications", showInfoIcon: false)
//                
//            case .exercises:
//                header.configure(title: "Guided Exercises", showInfoIcon: false)
//                
//            case .therapeuticGames:
//                header.configure(title: "Therapeutic Games", showInfoIcon: true)
//                header.onInfoTap = { [weak self] in
//                    self?.showGamesInfoPopup()
//                }
//            }
//            return header
//        }
//        
//        if kind == UICollectionView.elementKindSectionFooter && sectionType == .medications {
//            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyMedicationFooter", for: indexPath)
//            footer.subviews.forEach { $0.removeFromSuperview() }
//            if !noMedicationsCreated && todayDoses.isEmpty {
//                let label = UILabel()
//                label.text = "All medications Logged!"
//                label.textColor = .systemGray2
//                label.font = .systemFont(ofSize: 20, weight: .medium)
//                label.textAlignment = .center
//                label.translatesAutoresizingMaskIntoConstraints = false
//                footer.addSubview(label)
//                NSLayoutConstraint.activate([
//                    label.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
//                    label.centerYAnchor.constraint(equalTo: footer.centerYAnchor, constant: -15)
//                ])
//            }
//            return footer
//        }
//        return UICollectionReusableView()
//    }
//}
//
//extension HomeViewController {
//    func formattedDateString(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d MMMM yyyy"
//        return formatter.string(from: date)
//    }
//}
//extension HomeViewController: MedicationCardDelegate {
//    func didTapTaken(for dose: TodayDoseItem) {
//        updateDose(dose, status: .taken)
//    }
//    
//    func didTapSkipped(for dose: TodayDoseItem) {
//        updateDose(dose, status: .skipped)
//    }
//}
//extension HomeViewController {
//    private func showGamesInfoPopup() {
//        let alert = UIAlertController(
//            title: "Therapeutic Games",
//            message: "Daily games to enhance memory, focus and facial movement for people with Parkinson’s disease. Mimic the Emoji boosts facial expression by copying emojis. Match the Cards improves memory and attention. Play regularly to keep your mind active!",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Got it", style: .default))
//        self.present(alert, animated: true)
//    }
//}
//
//extension HomeViewController: NoMedCollectionViewCellDelegate {
//    func didTapAddNow() {
//        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddMedVC") as? UIViewController else { return }
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .pageSheet
//        present(nav, animated: true)
//    }
//}




import UIKit
import CoreData
enum Section: Int, CaseIterable {
    case calendar
    case medications
    case exercises
    case therapeuticGames
}

class HomeViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var NameOfUser: UILabel!
    private let todayViewModel = TodayMedicationViewModel()
    private var todayDoses: [TodayDoseItem] = []

    private var noMedicationsCreated: Bool {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        return ((try? context.count(for: request)) ?? 0) == 0
    }


    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    private var medicationLoggedObserver: NSObjectProtocol?
    private var userProfileUpdatedObserver: NSObjectProtocol?
    
    let homeSections = Section.allCases
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    var medicationData: [MedicationModel] = [
        MedicationModel(name: "Levodopa", time: "6:00 PM", detail: "1 capsule", iconName: "medication"),
        MedicationModel(name: "Carbidopa", time: "10:00 AM", detail: "1 capsule", iconName: "pills.fill"),
    ]
    
    var exerciseData: [ExerciseModel] = [
        ExerciseModel(title: "10-Min Workout", detail: "Repeat everyday",  progressColorHex: "0088FF"),
        ExerciseModel(title: "Rhythmic Walking", detail: "Repeat everyday", progressColorHex: "90AF81")
    ]
    
    var therapeuticGamesData: [TherapeuticGameModel] = [
        TherapeuticGameModel(title: "Mimic the Emoji", description: "Complete your daily challenge!", iconName: "face.smiling", iconColor: .systemOrange),
           TherapeuticGameModel(title: "Match the Cards", description: "Complete your daily challenge!", iconName: "brain.fill", iconColor: .systemPurple)
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
        
        let savedFull = UserDefaults.standard.string(forKey: "UserFullName") ?? "John"
        let firstName = savedFull.components(separatedBy: " ").first ?? savedFull
        self.NameOfUser.text = "Hello \(firstName)!"

        

        updateGreeting()

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

        userProfileUpdatedObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UserProfileUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateGreeting()
        }
    }
    
    deinit {
        if let observer = medicationLoggedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = userProfileUpdatedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGreeting()
        // Regenerate layout so the medications section always matches current state
        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
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

    private func updateGreeting() {
        if let fullName = UserDefaults.standard.string(forKey: "userName")?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !fullName.isEmpty {
            let firstName = fullName
                .split(whereSeparator: { $0.isWhitespace })
                .first
                .map(String.init) ?? fullName
            NameLabel.text = "Hello \(firstName)"
            NameOfUser.text = "Hello \(firstName)"
        } else {
            NameLabel.text = "Hello John"
            NameOfUser.text = "Hello John"
        }
    }
    private func loadRealMedicationData() {
        let context = PersistenceController.shared.viewContext

        let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
        let medications = (try? context.fetch(medRequest)) ?? []

        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        logRequest.predicate = NSPredicate(
            format: "doseScheduledTime >= %@ AND doseScheduledTime < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )

        let logs = (try? context.fetch(logRequest)) ?? []

        todayViewModel.loadTodayMedications(from: medications)

        todayViewModel.loadLoggedDoses(
            medications: medications,
            logs: logs,
            for: Date()
        )

        let unloggedDoses = todayViewModel.todayDoses.filter { dose in
            !todayViewModel.loggedDoses.contains(where: { $0.id == dose.id })
        }

        self.todayDoses = unloggedDoses
        self.mainCollectionView.reloadData()
    }

    private func updateDose(_ dose: TodayDoseItem, status: DoseStatus) {

            let context = PersistenceController.shared.viewContext
            let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
            let medications = (try? context.fetch(medRequest)) ?? []

            MedicationDoseLogger.shared.log(
                dose: dose,
                status: status,
                medications: medications,
                context: context
            )

            loadRealMedicationData()

            NotificationCenter.default.post(
                name: NSNotification.Name("MedicationLogged"),
                object: nil
            )
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
        mainCollectionView.register(UINib(nibName: "NoMedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NoMedCell")
        mainCollectionView.register(UINib(nibName: "ExerciseCardCell", bundle: nil), forCellWithReuseIdentifier: "exercise_card_cell")
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

                let groupSize: NSCollectionLayoutSize
                if self.noMedicationsCreated {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                } else {
                    groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(90))
                }
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = self.noMedicationsCreated ? .none : .groupPaging
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                let footerHeight: CGFloat = (!self.noMedicationsCreated && self.todayDoses.isEmpty) ? 40 : 0
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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(189))
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
    
    
    private func handleGamesSelection(at row: Int) {
        switch row {
        case 1:
            let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "matchTheCardsLandingPage") as? LevelSelectionViewController else { return }
            navigationController?.pushViewController(vc, animated: true)
            
        case 0:
            let storyboard = UIStoryboard(name: "MimicTheEmoji", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "EmojiLandingScreenID") as? EmojiLandingScreen else { return }
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
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
            let model = dates[indexPath.row]
            let calendar = Calendar.current
            
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            
            if model.date >= tomorrow {
                collectionView.deselectItem(at: indexPath, animated: false)
                return
            }

            let newDate = model.date
            if !calendar.isDate(newDate, inSameDayAs: selectedDate) {
                selectedDate = newDate
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                
                if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? SectionHeaderView {
                    let dateString = formattedDateString(for: selectedDate)
                    let isToday = calendar.isDateInToday(selectedDate)
                    header.configure(title: isToday ? "Today, \(dateString)" : dateString)
                }
                let visibleCalendarIndices = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
                collectionView.reloadItems(at: visibleCalendarIndices)
                collectionView.reloadSections(IndexSet(integer: Section.exercises.rawValue))
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let sectionType = homeSections[indexPath.section]
        
        if sectionType == .calendar {
            let targetDate = dates[indexPath.row].date
            let isToday = Calendar.current.isDateInToday(targetDate)
            let isFuture = targetDate > Date() && !isToday
            
            return !isFuture
        }
        
        return true
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
            return noMedicationsCreated ? 1 : todayDoses.count
        case .exercises: return exerciseData.count
        case .therapeuticGames: return therapeuticGamesData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = homeSections[indexPath.section]
        
        switch sectionType {
        case .calendar:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            
            let calendar = Calendar.current
            let isSelected = calendar.isDate(model.date, inSameDayAs: selectedDate)
            let isToday = calendar.isDateInToday(model.date)
            
            let isFuture = model.date > calendar.startOfDay(for: Date().addingTimeInterval(86400))
            cell.configure(with: model, isSelected: isSelected, isToday: isToday, isFuture: isFuture)
            cell.isUserInteractionEnabled = !isFuture
            
            return cell
            
        case .medications:
            if noMedicationsCreated {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoMedCell", for: indexPath) as! NoMedCollectionViewCell
                cell.delegate = self
                return cell
            }
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
                cell.setThemeColor(UIColor(hex: "0088FF"))
                let targetDate = selectedDate
                let isToday = Calendar.current.isDateInToday(targetDate)
                let summary = DailyWorkoutSummaryStore.shared.fetchSummary(for: targetDate)
                let storedCompleted = Int(summary?.completedCount ?? 0)
                let storedTotal = Int(summary?.totalExercises ?? 0)
                let completed = isToday ? max(storedCompleted, WorkoutManager.shared.completedToday.count) : storedCompleted
                let total = max(isToday ? max(storedTotal, WorkoutManager.shared.exercises.count) : storedTotal, 7)
                cell.setProgress(completed: completed, total: total)
            } else if indexPath.row == 1 {
                cell.setThemeColor(UIColor(hex: "90AF81"))
                if let lastSession = DataStore.shared.sessions.first {
                    let done = lastSession.elapsedSeconds
                    let goal = max(lastSession.requestedDurationSeconds, 1)
                    let percentage = Int((Double(done) / Double(goal)) * 100)
                    cell.setProgress(completed: done, total: goal)
                    cell.progressLabel.text = "\(percentage)%"
                } else {
                    cell.setProgress(completed: 0, total: 1)
                    cell.progressLabel.text = "0%"
                }
            }
            return cell

        case .therapeuticGames:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "therapeutic_game_cell", for: indexPath) as! TherapeuticGameCell
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = 2
            let now = Date()
            let comps = calendar.dateComponents([.year, .month], from: now)
            let firstDayOfMonth = calendar.date(from: comps)!
            let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

            let today = calendar.startOfDay(for: now)
            let completionText: String
            let isTodayCompleted: Bool
            switch indexPath.item {
            case 0:
                let completedCount = (0..<daysInMonth).filter { offset in
                    guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                    return EmojiGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
                }.count
                completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
                isTodayCompleted = EmojiGameManager.shared.isCompleted(date: today)
            case 1:
                let completedCount = (0..<daysInMonth).filter { offset in
                    guard let date = calendar.date(byAdding: .day, value: offset, to: firstDayOfMonth) else { return false }
                    return DailyGameManager.shared.isCompleted(date: calendar.startOfDay(for: date))
                }.count
                completionText = "\(completedCount)/\(daysInMonth) daily challenges completed"
                isTodayCompleted = DailyGameManager.shared.isCompleted(date: today)
            default:
                completionText = ""
                isTodayCompleted = false
            }
            cell.configure(with: therapeuticGamesData[indexPath.item], completionText: completionText, isTodayCompleted: isTodayCompleted)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionType = homeSections[indexPath.section]
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            
            header.setTitleAlignment(.left)
            header.setFont(size: 20, weight: .bold)
            header.onInfoTap = nil

            switch sectionType {
            case .calendar:
                let dateString = formattedDateString(for: selectedDate)
                let isToday = Calendar.current.isDateInToday(selectedDate)
                header.configure(title: isToday ? "Today, \(dateString)" : dateString, showInfoIcon: false)
                header.setTitleAlignment(.center)
                header.setFont(size: 17, weight: .bold)
                
            case .medications:
                header.configure(title: "Upcoming Medications", showInfoIcon: false)
                
            case .exercises:
                header.configure(title: "Guided Exercises", showInfoIcon: false)
                
            case .therapeuticGames:
                header.configure(title: "Therapeutic Games", showInfoIcon: true)
                header.onInfoTap = { [weak self] in
                    self?.showGamesInfoPopup()
                }
            }
            return header
        }
        
        if kind == UICollectionView.elementKindSectionFooter && sectionType == .medications {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyMedicationFooter", for: indexPath)
            footer.subviews.forEach { $0.removeFromSuperview() }
            if !noMedicationsCreated && todayDoses.isEmpty {
                let label = UILabel()
                label.text = "All medications Logged!"
                label.textColor = .systemGray2
                label.font = .systemFont(ofSize: 20, weight: .medium)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
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
extension HomeViewController {
    private func showGamesInfoPopup() {
        let alert = UIAlertController(
            title: "Therapeutic Games",
            message: "Daily games to enhance memory, focus and facial movement for people with Parkinson’s disease. Mimic the Emoji boosts facial expression by copying emojis. Match the Cards improves memory and attention. Play regularly to keep your mind active!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        self.present(alert, animated: true)
    }
}

extension HomeViewController: AddMedicationDelegate {
    func didUpdateMedication() {
        mainCollectionView.setCollectionViewLayout(generateLayout(), animated: false)
        loadRealMedicationData()
    }
}

extension HomeViewController: NoMedCollectionViewCellDelegate {
    func didTapAddNow() {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddMedVC") as? AddMedicationViewController else { return }
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}
