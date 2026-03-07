import UIKit

class SymptomViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editAndSaveButton: UIButton!
    @IBOutlet weak var symptomBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    // Removed dates array as it was used for the calendar
    var selectedDate: Date = Date()
    var currentDayLogs: [SymptomRating] = []
    private var gaitRangeText: String?
    private var gaitGraphPoints: [(date: Date, value: Double)] = []
    private var tremorFrequencyHz: Double?
    private var todayAggregatedPoints: [AggregatedTremorPoint] = []

    // 1. Updated Sections: Removed .calendar
    enum Section: Int, CaseIterable {
        case tremor = 0
        case gait = 1
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
        tableView.separatorStyle = .none
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TremorMotionManager.shared.cancelRecording()
    }

    // MARK: - Tremor/Gait Helpers (Logic remains same, focusing on Today)

    private func loadTodayTremorData() {
        let s = TremorDataStore.shared.fetchSamples(for: .day, referenceDate: selectedDate)
        todayAggregatedPoints = s.map { AggregatedTremorPoint(date: $0.date, avgHz: $0.frequencyHz) }
    }

    private func requestHealthKitIfNeeded() {
        HealthKitManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted { self.fetchGaitDataForSelectedDate() }
            }
        }
    }

    private func fetchTremorData() {
        TremorMotionManager.shared.recordTremorFrequency(duration: 5.0) { [weak self] result in
            guard let self = self else { return }
            TremorDataStore.shared.save(result: result)
            switch result {
            case .steady: self.tremorFrequencyHz = 0.0
            case .tremor(let hz): self.tremorFrequencyHz = hz
            }
            self.loadTodayTremorData()
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: Section.tremor.rawValue))
            }
        }
    }

    private func fetchGaitDataForSelectedDate() {
        let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: selectedDate))!
        let start = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: end)!

        HealthKitManager.shared.fetchWalkingSteadinessSamples(from: start, to: end) { [weak self] samples in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !samples.isEmpty {
                    let points = samples.sorted { $0.0 < $1.0 }.map { (date: $0.0, value: min(max($0.1 * 100, 0), 100)) }
                    let avg = points.map { $0.value }.reduce(0, +) / Double(points.count)
                    self.gaitRangeText = String(format: "%.0f / 100", avg)
                    self.gaitGraphPoints = points
                } else {
                    self.gaitRangeText = "No Data"
                    self.gaitGraphPoints = []
                }
                self.collectionView.reloadSections(IndexSet(integer: Section.gait.rawValue))
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
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
        // Removed calendar cell registration
        collectionView.register(UINib(nibName: "tremorCard", bundle: nil), forCellWithReuseIdentifier: "tremor_cell")
        collectionView.register(UINib(nibName: "gaitCard", bundle: nil), forCellWithReuseIdentifier: "gait_cell")
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

    // 2. Updated Layout: Removed calendar case
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .tremor:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 12, trailing: 16)
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
}

// MARK: - CollectionView

extension SymptomViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        switch sectionType {
        case .tremor:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tremor_cell", for: indexPath) as! tremorCard
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        switch sectionType {
        case .tremor:
            navigateToSymptomDetail(type: .tremor)
        case .gait:
            navigateToSymptomDetail(type: .gait)
        }
    }

    private func navigateToSymptomDetail(type: Section) {
        let sb = UIStoryboard(name: "SymptomRecording", bundle: nil)
        switch type {
        case .tremor:
            let vc = sb.instantiateViewController(withIdentifier: "TremorVC") as! TremorViewController
            vc.selectedDate = selectedDate
            navigationController?.pushViewController(vc, animated: true)
        case .gait:
            navigationController?.pushViewController(sb.instantiateViewController(withIdentifier: "GaitVC"), animated: true)
        }
    }
}

// MARK: - TableView (Remains mostly same)
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
