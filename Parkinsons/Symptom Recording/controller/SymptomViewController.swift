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
    private var gaitGraphPoints: [(date: Date, value: Double)] = []
    private var tremorFrequencyHz: Double?   // nil = not yet measured, 0.0 = steady, >0 = tremor Hz
    private var todayAggregatedPoints: [AggregatedTremorPoint] = []

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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        requestHealthKitIfNeeded()

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
    }

    /// ✅ Stop motion manager before the VC disappears — prevents callback on deallocated memory
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TremorMotionManager.shared.cancelRecording()
    }

    // MARK: - Tremor helpers

    func samples(for range: TremorRange) -> [TremorSample] {
        let all = TremorDataStore.shared.fetchAll()
        let calendar = Calendar.current
        let now = Date()
        let startDate: Date = {
            switch range {
            case .day:      return calendar.startOfDay(for: now)
            case .week:     return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:    return calendar.date(byAdding: .month, value: -1, to: now)!
            case .sixMonth: return calendar.date(byAdding: .month, value: -6, to: now)!
            case .year:     return calendar.date(byAdding: .year, value: -1, to: now)!
            }
        }()
        return all.filter { $0.date >= startDate }
    }

    private func loadTodayTremorData() {
        let s = TremorDataStore.shared.fetchSamples(for: .day, referenceDate: selectedDate)
        todayAggregatedPoints = s.map { AggregatedTremorPoint(date: $0.date, avgHz: $0.frequencyHz) }
    }

    func aggregatedSamples(for range: TremorRange) -> [(date: Date, value: Double)] {
        let s = samples(for: range)
        guard !s.isEmpty else { return [] }
        let calendar = Calendar.current
        var grouped: [Date: [Double]] = [:]
        for sample in s {
            let keyDate: Date
            switch range {
            case .day:          keyDate = calendar.date(bySetting: .minute, value: 0, of: sample.date)!
            case .week, .month: keyDate = calendar.startOfDay(for: sample.date)
            case .sixMonth, .year: keyDate = calendar.dateInterval(of: .weekOfYear, for: sample.date)!.start
            }
            grouped[keyDate, default: []].append(sample.frequencyHz)
        }
        return grouped
            .map { (date: $0.key, value: $0.value.reduce(0, +) / Double($0.value.count)) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - HealthKit

    private func requestHealthKitIfNeeded() {
        HealthKitManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted { self.fetchGaitDataForSelectedDate() }
            }
        }
    }

    // MARK: - Tremor Data

    private func fetchTremorData() {
        TremorMotionManager.shared.recordTremorFrequency(duration: 5.0) { [weak self] result in
            guard let self = self else { return }

            // ✅ Save BOTH tremor AND steady readings so graph always has data
            TremorDataStore.shared.save(result: result)

            // Update display value
            switch result {
            case .steady:
                self.tremorFrequencyHz = 0.0   // 0.0 = steady sentinel
            case .tremor(let hz):
                self.tremorFrequencyHz = hz
            }

            self.loadTodayTremorData()
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: Section.tremor.rawValue))
            }
        }
    }

    // MARK: - Gait Data

    private func fetchGaitDataForSelectedDate() {
        let start = Calendar.current.startOfDay(for: selectedDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!

        HealthKitManager.shared.fetchWalkingSteadinessSamples(from: start, to: end) { [weak self] samples in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !samples.isEmpty {
                    let avg = samples.map { $0.1 * 100 }.reduce(0, +) / Double(samples.count)
                    self.gaitRangeText = String(format: "%.0f / 100", avg)
                    let calendar = Calendar.current
                    let grouped = Dictionary(grouping: samples) { calendar.startOfDay(for: $0.0) }
                    self.gaitGraphPoints = grouped.map { (date, vals) in
                        (date: date, value: vals.map { $0.1 * 100 }.reduce(0, +) / Double(vals.count))
                    }.sorted { $0.date < $1.date }
                    self.collectionView.reloadSections(IndexSet(integer: Section.gait.rawValue))
                } else {
                    HealthKitManager.shared.fetchWalkingSteadiness(from: start, to: end) { value in
                        DispatchQueue.main.async {
                            if let v = value {
                                self.gaitRangeText = String(format: "%.0f / 100", v)
                                self.gaitGraphPoints = [(date: Date(), value: v)]
                            } else {
                                self.gaitRangeText = "No Data"
                                self.gaitGraphPoints = []
                            }
                            self.collectionView.reloadSections(IndexSet(integer: Section.gait.rawValue))
                        }
                    }
                }
            }
        }
    }

    // MARK: - ViewWillAppear


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        DispatchQueue.main.async { self.scrollToSelectedDate(animated: false) }
    }

    // MARK: - UI Setup

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
        tableViewHeightConstraint.constant = CGFloat(currentDayLogs.count) * rowHeight
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    func registerCells() {
        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        collectionView.register(UINib(nibName: "tremorCard", bundle: nil), forCellWithReuseIdentifier: "tremor_cell")
        collectionView.register(UINib(nibName: "gaitCard", bundle: nil), forCellWithReuseIdentifier: "gait_cell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        tableView.register(UINib(nibName: "SymptomDetailCell", bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
    }

    func updateDataForSelectedDate() {
        if let entry = SymptomLogManager.shared.getLogEntry(for: selectedDate) {
            currentDayLogs = entry.ratings
            currentMode = .history
            editAndSaveButton.setTitle("Edit", for: .normal)
        } else {
            loadDefaultSymptoms()
            currentMode = .entry
            editAndSaveButton.setTitle("Save", for: .normal)
        }
        tableView.reloadData()
        updateTableViewHeight()
        collectionView.reloadData()
    }

    private func loadDefaultSymptoms() {
        currentDayLogs = [
            SymptomRating(name: "Slowed Movement", iconName: "SlowedMovement", selectedIntensity: .notPresent),
            SymptomRating(name: "Tremor", iconName: "tremor", selectedIntensity: .notPresent),
            SymptomRating(name: "Loss of Balance", iconName: "lossOfBalance", selectedIntensity: .notPresent),
            SymptomRating(name: "Facial Stiffness", iconName: "stiffFace", selectedIntensity: .notPresent),
            SymptomRating(name: "Body Stiffness", iconName: "bodyStiffness", selectedIntensity: .notPresent),
            SymptomRating(name: "Gait Disturbance", iconName: "walking", selectedIntensity: .notPresent),
            SymptomRating(name: "Insomnia", iconName: "insomnia", selectedIntensity: .notPresent),
        ]
    }


    @IBAction func editAndSaveTapped(_ sender: UIButton) {
        if currentMode == .history {
            currentMode = .entry
            editAndSaveButton.setTitle("Save", for: .normal)
            if currentDayLogs.isEmpty { loadDefaultSymptoms() }
        } else {
            SymptomLogManager.shared.saveLogEntry(SymptomLogEntry(date: selectedDate, ratings: currentDayLogs))
            currentMode = .history
            editAndSaveButton.setTitle("Edit", for: .normal)
        }
        tableView.reloadData()
        updateTableViewHeight()
    }

    // MARK: - Layout

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
                section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
                return section
            case .tremor:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16)
                return section
            case .gait:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
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

// MARK: - CollectionView

extension SymptomViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let s = Section(rawValue: section) else { return 0 }
        switch s {
        case .calendar: return dates.count
        case .tremor, .gait: return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        switch sectionType {
        case .calendar:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            cell.configure(with: model,
                           isSelected: Calendar.current.isDate(model.date, inSameDayAs: selectedDate),
                           isToday: Calendar.current.isDate(model.date, inSameDayAs: Date()))
            return cell

        case .tremor:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tremor_cell", for: indexPath) as! tremorCard

            // tremorFrequencyHz: nil = not yet recorded, 0.0 = steady, >0 = Hz value
            // Pass nil to card when steady so it shows "Steady" label
            let displayHz: Double? = (tremorFrequencyHz == nil || tremorFrequencyHz == 0.0) ? nil : tremorFrequencyHz
            let isSteady = tremorFrequencyHz == 0.0
            cell.configure(frequencyHz: displayHz, isSteady: isSteady, graphPoints: todayAggregatedPoints)
            return cell

        case .gait:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gait_cell", for: indexPath) as! gaitCard
            cell.configureWithPoints(range: gaitRangeText ?? "Loading…", points: gaitGraphPoints)

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader, indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            let dateString = formattedDateString(for: selectedDate)
            header.configure(title: Calendar.current.isDateInToday(selectedDate) ? "Today, \(dateString)" : dateString)
            header.setTitleAlignment(.center)
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        switch sectionType {
        case .calendar:
            selectedDate = dates[indexPath.row].date
            if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? SectionHeaderView {
                let ds = formattedDateString(for: selectedDate)
                header.configure(title: Calendar.current.isDateInToday(selectedDate) ? "Today, \(ds)" : ds)
            }
            let visibleCal = collectionView.indexPathsForVisibleItems.filter { $0.section == Section.calendar.rawValue }
            collectionView.reloadItems(at: visibleCal)
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
            let ip = IndexPath(item: index, section: Section.calendar.rawValue)
            collectionView.layoutIfNeeded()
            collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: animated)
            collectionView.selectItem(at: ip, animated: animated, scrollPosition: [])
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

// MARK: - TableView

extension SymptomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { currentDayLogs.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rating = currentDayLogs[indexPath.row]
        if currentMode == .entry {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomRatingCell", for: indexPath) as! SymptomRatingCell
            cell.delegate = self
            cell.configure(with: rating)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as! SymptomDetailCell
            cell.configure(with: rating, isEditable: false)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        currentMode == .entry ? 130 : 70
    }
}

extension SymptomViewController: SymptomRatingCellDelegate {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        currentDayLogs[indexPath.row].selectedIntensity = intensity
    }
}
