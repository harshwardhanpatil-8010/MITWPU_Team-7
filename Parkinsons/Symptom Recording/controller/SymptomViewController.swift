import UIKit

class SymptomViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editAndSaveButton: UIButton!
    @IBOutlet weak var symptomBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    var currentDayLogs: [SymptomRating] = []
    private var gaitRangeText: String?
    private var tremorFrequencyHz: Double?


    enum Section: Int, CaseIterable {
        case calendar = 0
        case tremor = 1
        case gait = 2
    }

    enum ViewMode {
        case history
        case entry
    }

    var currentMode: ViewMode = .history
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        dates = HomeDataStore.shared.getDates()
        tableView.separatorStyle = .none
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        autoSelectToday()
        
        tableView.dataSource = self
        tableView.delegate = self
                
        setupTableViewUI()
        updateDataForSelectedDate()
        setupSymptomBackgroundUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchTremorData()
        requestHealthKitIfNeeded()
    }
    func samples(for range: TremorRange) -> [TremorSample] {
        let all = TremorDataStore.shared.fetchAll()
        let calendar = Calendar.current
        let now = Date()

        let startDate: Date = {
            switch range {
            case .day:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .sixMonth:
                return calendar.date(byAdding: .month, value: -6, to: now)!
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now)!
            }
        }()

        return all.filter { $0.date >= startDate }
    }
    func aggregatedSamples(
        for range: TremorRange
    ) -> [(date: Date, value: Double)] {

        let samples = samples(for: range)
        guard !samples.isEmpty else { return [] }

        let calendar = Calendar.current
        var grouped: [Date: [Double]] = [:]

        for sample in samples {
            let keyDate: Date

            switch range {
            case .day:
                keyDate = calendar.date(
                    bySetting: .minute,
                    value: 0,
                    of: sample.date
                )!
            case .week, .month:
                keyDate = calendar.startOfDay(for: sample.date)
            case .sixMonth, .year:
                keyDate = calendar.dateInterval(
                    of: .weekOfYear,
                    for: sample.date
                )!.start
            }

            grouped[keyDate, default: []].append(sample.frequencyHz)
        }

        return grouped
            .map { (date: $0.key, value: $0.value.reduce(0, +) / Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }

    private func requestHealthKitIfNeeded() {
        HealthKitManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    self.fetchGaitDataForSelectedDate()
                } else {
                    print("HealthKit permission denied")
                }
            }
        }
    }
    private func fetchTremorData() {

        TremorMotionManager.shared.recordTremorFrequency(duration: 8.0) { [weak self] hz in
            guard let self = self else { return }

            self.tremorFrequencyHz = hz
            if let hz = hz {
                let sample = TremorSample(
                    date: Date(),
                    frequencyHz: hz
                )

                TremorDataStore.shared.save(sample)

            }

            let indexPath = IndexPath(item: 0, section: Section.tremor.rawValue)
            if self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
                self.collectionView.reloadItems(at: [indexPath])
            } else {
                self.collectionView.reloadSections(IndexSet(integer: Section.tremor.rawValue))
            }
        }
    }



    private func reloadTremorSection() {
        collectionView.reloadSections(IndexSet(integer: Section.tremor.rawValue))
    }

    private func fetchGaitDataForSelectedDate() {
        let start = Calendar.current.startOfDay(for: selectedDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        HealthKitManager.shared.fetchWalkingSteadiness(from: start, to: end) { [weak self] steadiness in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let value = steadiness {
                    
                    self.gaitRangeText = String(format: "%.0f / 100", value)
                } else {
                    self.gaitRangeText = "No data"
                }

                self.reloadGaitSection()
            }
        }
    }

    private func reloadGaitSection() {
        collectionView.reloadSections(IndexSet(integer: Section.gait.rawValue))
    }

    private func updateGaitCard(rangeText: String) {

        let gaitSectionIndex = Section.gait.rawValue
        let indexPath = IndexPath(item: 0, section: gaitSectionIndex)

        guard
            let cell = collectionView.cellForItem(at: indexPath) as? gaitCard
        else {
            collectionView.reloadSections(IndexSet(integer: gaitSectionIndex))
            return
        }

        cell.configure(range: rangeText)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        
        DispatchQueue.main.async {
            self.scrollToSelectedDate(animated: false)
        }
    }
    func setupTableViewUI() {
        tableView.layer.cornerRadius = 25
        tableView.layer.masksToBounds = true
        
      
    }
        func setupSymptomBackgroundUI() {
        symptomBackground.layer.cornerRadius = 25
        symptomBackground.layer.shadowColor = UIColor.black.cgColor
        symptomBackground.layer.shadowOffset = CGSize(width: 0, height: 4)
        symptomBackground.layer.shadowOpacity = 0.1
        symptomBackground.layer.shadowRadius = 10
        symptomBackground.layer.masksToBounds = false
    }
    func updateTableViewHeight() {
        let rowHeight: CGFloat = (currentMode == .entry) ? 130 : 70
        let totalRows = CGFloat(currentDayLogs.count)
        
        let calculatedHeight = totalRows * rowHeight
        
        tableViewHeightConstraint.constant = calculatedHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func registerCells() {
        
        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        collectionView.register(UINib(nibName: "tremorCard", bundle: nil), forCellWithReuseIdentifier: "tremor_cell")
        collectionView.register(UINib(nibName: "gaitCard", bundle: nil), forCellWithReuseIdentifier: "gait_cell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
       
        let detailNib = UINib(nibName: "SymptomDetailCell", bundle: nil)
        tableView.register(detailNib, forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        
        let ratingNib = UINib(nibName: "SymptomRatingCell", bundle: nil)
        tableView.register(ratingNib, forCellReuseIdentifier: "SymptomRatingCell")
    }

    func updateDataForSelectedDate() {
        if let entry = SymptomLogManager.shared.getLogEntry(for: selectedDate) {
            self.currentDayLogs = entry.ratings
            self.currentMode = .history
            editAndSaveButton.setTitle("Edit", for: .normal)
        } else {
            
            loadDefaultSymptoms()
            self.currentMode = .entry
            editAndSaveButton.setTitle("Save", for: .normal)
        }
        
        tableView.reloadData()
        updateTableViewHeight()
        collectionView.reloadData()
    }

    private func loadDefaultSymptoms() {
        self.currentDayLogs = [
            SymptomRating(name: "Slowed Movement", iconName: "SlowedMovement", selectedIntensity: .notPresent),
            SymptomRating(name: "Tremor", iconName: "tremor", selectedIntensity: .notPresent),
            SymptomRating(name: "Loss of Balance", iconName: "lossOfBalance", selectedIntensity: .notPresent),
            SymptomRating(name: "Facial Stiffness", iconName: "stiffFace", selectedIntensity: .notPresent),
            SymptomRating(name: "Body Stiffness", iconName: "bodyStiffness", selectedIntensity: .notPresent),
            SymptomRating(name: "Gait Disturbance", iconName: "walking", selectedIntensity: .notPresent),
            SymptomRating(name: "Insomnia", iconName: "insomnia", selectedIntensity: .notPresent)
        ]
    }

   
    @IBAction func editAndSaveTapped(_ sender: UIButton) {
        if currentMode == .history {
            currentMode = .entry
            editAndSaveButton.setTitle("Save", for: .normal)
            
            if currentDayLogs.isEmpty {
                loadDefaultSymptoms()
            }
        } else {
            let newEntry = SymptomLogEntry(date: selectedDate, ratings: currentDayLogs)
            SymptomLogManager.shared.saveLogEntry(newEntry)
            
            currentMode = .history
            editAndSaveButton.setTitle("Edit", for: .normal)
        }
        tableView.reloadData()
        updateTableViewHeight()
    }
   
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .calendar:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(70))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 4
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [calendarHeader]
                return section
                
            case .tremor:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16)
                return section
                
            case .gait:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 0, trailing: 16)
                return section
            }
        }
    }
   
    func autoSelectToday() {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
            selectedDate = dates[index].date
            scrollToSelectedDate(animated: false)
        }
    }

    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

extension SymptomViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .calendar: return dates.count
        case .tremor: return 1
        case .gait: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionType {
        case .calendar:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
            let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
            cell.configure(with: model, isSelected: isSelected, isToday: isToday)
            return cell
            
        case .tremor:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "tremor_cell",
                for: indexPath
            ) as! tremorCard

            cell.configure(frequencyHz: tremorFrequencyHz)
            return cell


            
        case .gait:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gait_cell", for: indexPath) as! gaitCard
            // display steadiness
            cell.configure(range: gaitRangeText ?? "Loading…")
            return cell

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            let dateString = formattedDateString(for: selectedDate)
            let isToday = Calendar.current.isDateInToday(selectedDate)
            header.configure(title: isToday ? "Today, \(dateString)" : dateString)
            header.setTitleAlignment(.center)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { return }

        switch sectionType {
        case .calendar:
            let newDate = dates[indexPath.row].date
            selectedDate = newDate
            
            if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? SectionHeaderView {
                let dateString = formattedDateString(for: selectedDate)
                let isToday = Calendar.current.isDateInToday(selectedDate)
                header.configure(title: isToday ? "Today, \(dateString)" : dateString)
            }
            
            let visibleCalendarIndices = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
            collectionView.reloadItems(at: visibleCalendarIndices)

            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            updateDataForSelectedDate()

        case .tremor:
            navigateToSymptomDetail(type: .tremor)

        case .gait:
            navigateToSymptomDetail(type: .gait)
        }
    }
    func scrollToSelectedDate(animated: Bool) {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            let indexPath = IndexPath(item: index, section: Section.calendar.rawValue)
            
            collectionView.layoutIfNeeded()
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    private func navigateToSymptomDetail(type: Section) {

        let storyboard = UIStoryboard(name: "SymptomRecording", bundle: nil)

        let vc: UIViewController

        switch type {
        case .tremor:
            vc = storyboard.instantiateViewController(withIdentifier: "TremorVC")

        case .gait:
            vc = storyboard.instantiateViewController(withIdentifier: "GaitVC")

        default:
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }

}

extension SymptomViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDayLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rating = currentDayLogs[indexPath.row]
        
        if currentMode == .entry {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomRatingCell", for: indexPath) as? SymptomRatingCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configure(with: rating)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell else {
                return UITableViewCell()
            }
            cell.configure(with: rating, isEditable: false)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return currentMode == .entry ? 130 : 70
    }
}

extension SymptomViewController: SymptomRatingCellDelegate {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
       
        currentDayLogs[indexPath.row].selectedIntensity = intensity
    }
}
