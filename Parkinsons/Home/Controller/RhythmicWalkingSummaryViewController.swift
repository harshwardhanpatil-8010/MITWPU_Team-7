//
////  DATA MODEL — what lives where:
////  ┌──────────────────────────────┬────────────────────────────────────────────┐
////  │ Core Data (RhythmicSession)  │  UserDefaults (keyed by session UUID)      │
////  ├──────────────────────────────┼────────────────────────────────────────────┤
////  │ id            UUID           │  beat_<uuid>  String  (e.g. "Click")       │
////  │ startDate     Date           │  pace_<uuid>  String  (e.g. "Slow")        │
////  │ endDate       Date?          │                                            │
////  │ requestedDuration  Int32     │                                            │
////  │ elapsedSeconds     Int32     │                                            │
////  │ steps              Int32     ← written by HealthKitManagerRhythmic        │
////  │ distanceMeters     Double    ← written by HealthKitManagerRhythmic        │
////  │ stepLengthMeters   Double    ← written by HealthKitManagerRhythmic        │
////  │ walkingAsymmetry   Double    ← written by HealthKitManagerRhythmic        │
////  │ walkingSteadiness  Double    ← written by HealthKitManagerRhythmic        │
////  └──────────────────────────────┴────────────────────────────────────────────┘
////
////  This VC:
////  • Fetches ALL RhythmicSession records directly from Core Data (all history)
////  • Groups them into date sections ("Today", "Yesterday", "12 May 2025" …)
////  • Displays Session #, elapsed time, and distance (if already fetched) per row
////  • On tap → builds RhythmicSessionDTO (beat/pace from UserDefaults),
////    passes it to SessionSummaryViewController which:
////      1. Instantly populates labels from cached Core Data HealthKit values
////      2. Re-fires a live HealthKit fetch and refreshes the labels when done
//
//import UIKit
//import CoreData
//
//class RhythmicWalkingSummaryViewController: UIViewController {
//
//    // MARK: - Outlets
//    @IBOutlet weak var closeBarButton: UIBarButtonItem!
//    @IBOutlet weak var tableView: UITableView!
//
//    // MARK: - Public input
//
//    /// Set this before presenting. When non-nil, only sessions for that calendar
//    /// day are fetched and shown. When nil (e.g. presented without a date context)
//    /// all sessions across all time are shown grouped by date.
//    var dateToDisplay: Date?
//
//    // MARK: - Private state
//
//    /// Ordered section header strings, e.g. ["Today", "Yesterday", "3 June 2025"]
//    private var sectionTitles: [String] = []
//
//    /// Sessions grouped in the same order as sectionTitles, newest-first within each day
//    private var sessionsBySection: [[RhythmicSession]] = []
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate   = self
//        tableView.layer.cornerRadius = 30
//        tableView.clipsToBounds      = true
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchAndGroup()
//        tableView.reloadData()
//    }
//
//    // MARK: - Core Data fetch
//
//    private func fetchAndGroup() {
//        let context = PersistenceController.shared.viewContext
//        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
//        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \RhythmicSession.startDate, ascending: false)
//        ]
//
//        // If a specific date was provided (tapped from calendar/summary),
//        // restrict the fetch to that calendar day only.
//        if let targetDate = dateToDisplay {
//            let calendar = Calendar.current
//            let start    = calendar.startOfDay(for: targetDate)
//            let end      = calendar.date(byAdding: .day, value: 1, to: start)!
//            request.predicate = NSPredicate(
//                format: "startDate >= %@ AND startDate < %@",
//                start as NSDate, end as NSDate
//            )
//        }
//        // If no date is provided, no predicate → fetch all sessions (all-time history)
//
//        do {
//            let all = try context.fetch(request)
//            buildSections(from: all)
//        } catch {
//            print("[RhythmicWalkingSummaryVC] Core Data fetch error: \(error)")
//            sectionTitles     = []
//            sessionsBySection = []
//        }
//    }
//
//    /// Groups an already-sorted (newest-first) array into calendar-day sections.
//    private func buildSections(from sessions: [RhythmicSession]) {
//        let calendar  = Calendar.current
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d MMMM yyyy"
//
//        var orderedTitles: [String]          = []
//        var map: [String: [RhythmicSession]] = [:]
//
//        for session in sessions {
//            let date = session.startDate ?? Date()
//            let title: String
//            if calendar.isDateInToday(date)          { title = "Today"     }
//            else if calendar.isDateInYesterday(date) { title = "Yesterday" }
//            else                                     { title = formatter.string(from: date) }
//
//            if map[title] == nil {
//                orderedTitles.append(title)
//                map[title] = []
//            }
//            map[title]!.append(session)
//        }
//
//        sectionTitles     = orderedTitles
//        sessionsBySection = orderedTitles.map { map[$0] ?? [] }
//    }
//
//    // MARK: - Build DTO from Core Data managed object
//    //
//    // All timing fields come straight from Core Data.
//    // beat & pace are NOT stored in Core Data — they were saved to UserDefaults
//    // by RhythmicSessionDTO.saveExtras() when the session was first created.
//
//    private func makeDTO(from managed: RhythmicSession, sessionNumber: Int) -> RhythmicSessionDTO {
//        let uid = managed.id ?? UUID()
//        let key = uid.uuidString
//        return RhythmicSessionDTO(
//            id:                       uid,
//            sessionNumber:            sessionNumber,
//            startDate:                managed.startDate ?? Date(),
//            endDate:                  managed.endDate,
//            requestedDurationSeconds: Int(managed.requestedDuration),
//            elapsedSeconds:           Int(managed.elapsedSeconds),
//            beat: UserDefaults.standard.string(forKey: "beat_\(key)") ?? "Click",
//            pace: UserDefaults.standard.string(forKey: "pace_\(key)") ?? "Slow"
//        )
//    }
//
//    // MARK: - Navigate to SessionSummaryViewController
//
//    private func openDetail(for managed: RhythmicSession, sessionNumber: Int) {
//        let dto = makeDTO(from: managed, sessionNumber: sessionNumber)
//
//        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
//        guard let summaryVC = sb.instantiateViewController(
//            withIdentifier: "SessionSummaryVC"
//        ) as? SessionSummaryViewController else {
//            print("[RhythmicWalkingSummaryVC] Could not instantiate SessionSummaryVC")
//            return
//        }
//
//        // SessionSummaryViewController.loadData() will:
//        //   1. Show cached HealthKit values already in Core Data immediately
//        //      (steps, distanceMeters, stepLengthMeters, walkingAsymmetry, walkingSteadiness)
//        //   2. Fire HealthKitManagerRhythmic.fetchFullSummary() in the background
//        //      and refresh labels + save any new values back to Core Data
//        summaryVC.sessionData = dto
//
//        let nav = UINavigationController(rootViewController: summaryVC)
//        nav.modalPresentationStyle = .pageSheet
//        present(nav, animated: true)
//    }
//
//    // MARK: - Actions
//
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        dismiss(animated: true)
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension RhythmicWalkingSummaryViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        sectionTitles.count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   numberOfRowsInSection section: Int) -> Int {
//        sessionsBySection[section].count
//    }
//
//    func tableView(_ tableView: UITableView,
//                   titleForHeaderInSection section: Int) -> String? {
//        sectionTitles[section]
//    }
//
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell    = tableView.dequeueReusableCell(withIdentifier: "sessionCell",
//                                                    for: indexPath)
//        let managed = sessionsBySection[indexPath.section][indexPath.row]
//
//        // ── Elapsed time (from Core Data) ────────────────────────────────
//        let elapsed = Int(managed.elapsedSeconds)
//        let h = elapsed / 3600
//        let m = (elapsed % 3600) / 60
//        let s = elapsed % 60
//        let timeText = h == 0 ? "\(m)min \(s)s" : "\(h)hr \(m)min"
//
//        // ── Distance (from Core Data, written back by HealthKitManagerRhythmic)
//        // Only show if HealthKit has already fetched data for this session
//        let distText: String = managed.distanceMeters > 0
//            ? String(format: "%.2f km", managed.distanceMeters / 1000.0)
//            : ""
//
//        // ── Session number: position within the section, 1-based ────────
//        let sessionNum = indexPath.row + 1
//
//        // ── Populate labels ──────────────────────────────────────────────
//        cell.textLabel?.text = "Session \(sessionNum)"
//        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)
//
//        let rightText = distText.isEmpty
//            ? timeText
//            : "\(timeText)  ·  \(distText)"
//
//        if let detail = cell.detailTextLabel {
//            // Works automatically when Storyboard cell style = "Right Detail"
//            detail.text      = rightText
//            detail.textColor = .secondaryLabel
//            detail.font      = .systemFont(ofSize: 14, weight: .regular)
//        } else {
//            // Fallback: programmatic right-aligned label for "Basic" style cells
//            let tag = 9_002
//            let rightLabel: UILabel
//            if let existing = cell.contentView.viewWithTag(tag) as? UILabel {
//                rightLabel = existing
//            } else {
//                rightLabel = UILabel()
//                rightLabel.tag           = tag
//                rightLabel.textAlignment = .right
//                rightLabel.textColor     = .secondaryLabel
//                rightLabel.font          = .systemFont(ofSize: 14, weight: .regular)
//                rightLabel.translatesAutoresizingMaskIntoConstraints = false
//                cell.contentView.addSubview(rightLabel)
//                NSLayoutConstraint.activate([
//                    rightLabel.centerYAnchor.constraint(
//                        equalTo: cell.contentView.centerYAnchor),
//                    rightLabel.trailingAnchor.constraint(
//                        equalTo: cell.contentView.trailingAnchor, constant: -16)
//                ])
//            }
//            rightLabel.text = rightText
//        }
//
//        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension RhythmicWalkingSummaryViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView,
//                   didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let managed = sessionsBySection[indexPath.section][indexPath.row]
//        openDetail(for: managed, sessionNumber: indexPath.row + 1)
//    }
//
//    func tableView(_ tableView: UITableView,
//                   heightForHeaderInSection section: Int) -> CGFloat { 36 }
//
//    func tableView(_ tableView: UITableView,
//                   willDisplayHeaderView view: UIView,
//                   forSection section: Int) {
//        guard let header = view as? UITableViewHeaderFooterView else { return }
//        header.textLabel?.font      = .systemFont(ofSize: 13, weight: .semibold)
//        header.textLabel?.textColor = .secondaryLabel
//    }
//}






//import UIKit
//
//class RhythmicWalkingSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//
//    @IBOutlet weak var closeBarButton: UIBarButtonItem!
//    @IBOutlet weak var tableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 1. Set the delegates so the table knows where to get data
//        tableView.dataSource = self
//        tableView.delegate = self
//
//        // Optional: Match the styling from the previous screen
//        tableView.layer.cornerRadius = 30
//        tableView.clipsToBounds = true
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Refresh the data whenever the view appears
//        tableView.reloadData()
//    }
//
//    @IBAction func closeButtonTapped(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    // MARK: - TableView DataSource
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return DataStore.shared.sessions.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // Ensure the identifier "sessionCell" matches your Storyboard cell identifier
//        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
//
//        let session = DataStore.shared.sessions[indexPath.row]
//        let walked = session.elapsedSeconds
//        let hrs  = walked / 3600
//        let mins = walked % 3600 / 60
//        let secs = walked % 60
//
//        // Identical formatting logic
//        if hrs == 0 {
//            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(mins)min \(secs)s"
//        } else {
//            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(hrs)hrs \(mins)min"
//        }
//
//        return cell
//    }
//
//    // MARK: - TableView Delegate
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        // Navigate to the specific details of this session if needed
//        let selectedSession = DataStore.shared.sessions[indexPath.row]
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
////        if let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController {
////            summaryVC.sessionData = selectedSession
////            let nav = UINavigationController(rootViewController: summaryVC)
////            nav.modalPresentationStyle = .formSheet
////            present(nav, animated: true)
// //       }
//    }
//}




//
//  RhythmicWalkingSummaryViewController.swift
//  Parkinsons
//
//  DATA MODEL — what lives where:
//  ┌──────────────────────────────┬────────────────────────────────────────────┐
//  │ Core Data (RhythmicSession)  │  UserDefaults (keyed by session UUID)      │
//  ├──────────────────────────────┼────────────────────────────────────────────┤
//  │ id            UUID           │  beat_<uuid>  String  (e.g. "Click")       │
//  │ startDate     Date           │  pace_<uuid>  String  (e.g. "Slow")        │
//  │ endDate       Date?          │                                            │
//  │ requestedDuration  Int32     │                                            │
//  │ elapsedSeconds     Int32     │                                            │
//  │ steps              Int32     ← written by HealthKitManagerRhythmic        │
//  │ distanceMeters     Double    ← written by HealthKitManagerRhythmic        │
//  │ stepLengthMeters   Double    ← written by HealthKitManagerRhythmic        │
//  │ walkingAsymmetry   Double    ← written by HealthKitManagerRhythmic        │
//  │ walkingSteadiness  Double    ← written by HealthKitManagerRhythmic        │
//  └──────────────────────────────┴────────────────────────────────────────────┘
//
//  This VC:
//  • Fetches ALL RhythmicSession records directly from Core Data (all history)
//  • Groups them into date sections ("Today", "Yesterday", "12 May 2025" …)
//  • Displays Session #, elapsed time, and distance (if already fetched) per row
//  • On tap → builds RhythmicSessionDTO (beat/pace from UserDefaults),
//    passes it to SessionSummaryViewController which:
//      1. Instantly populates labels from cached Core Data HealthKit values
//      2. Re-fires a live HealthKit fetch and refreshes the labels when done

import UIKit
import CoreData

class RhythmicWalkingSummaryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Public input

    /// Set this before presenting. When non-nil, only sessions for that calendar
    /// day are fetched and shown. When nil (e.g. presented without a date context)
    /// all sessions across all time are shown grouped by date.
    var dateToDisplay: Date?

    // MARK: - Private state

    /// Ordered section header strings, e.g. ["Today", "Yesterday", "3 June 2025"]
    private var sectionTitles: [String] = []

    /// Sessions grouped in the same order as sectionTitles, newest-first within each day
    private var sessionsBySection: [[RhythmicSession]] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.layer.cornerRadius = 30
        tableView.clipsToBounds      = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndGroup()
        tableView.reloadData()
    }

    // MARK: - Core Data fetch

    private func fetchAndGroup() {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RhythmicSession.startDate, ascending: false)
        ]

        // If a specific date was provided (tapped from calendar/summary),
        // restrict the fetch to that calendar day only.
        if let targetDate = dateToDisplay {
            let calendar = Calendar.current
            let start    = calendar.startOfDay(for: targetDate)
            let end      = calendar.date(byAdding: .day, value: 1, to: start)!
            request.predicate = NSPredicate(
                format: "startDate >= %@ AND startDate < %@",
                start as NSDate, end as NSDate
            )
        }
        // If no date is provided, no predicate → fetch all sessions (all-time history)

        do {
            let all = try context.fetch(request)
            buildSections(from: all)
        } catch {
            print("[RhythmicWalkingSummaryVC] Core Data fetch error: \(error)")
            sectionTitles     = []
            sessionsBySection = []
        }
    }

    /// Groups an already-sorted (newest-first) array into calendar-day sections.
    private func buildSections(from sessions: [RhythmicSession]) {
        let calendar  = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"

        var orderedTitles: [String]          = []
        var map: [String: [RhythmicSession]] = [:]

        for session in sessions {
            let date = session.startDate ?? Date()
            let title: String
            if calendar.isDateInToday(date)          { title = "Today"     }
            else if calendar.isDateInYesterday(date) { title = "Yesterday" }
            else                                     { title = formatter.string(from: date) }

            if map[title] == nil {
                orderedTitles.append(title)
                map[title] = []
            }
            map[title]!.append(session)
        }

        sectionTitles     = orderedTitles
        sessionsBySection = orderedTitles.map { map[$0] ?? [] }
    }

    // MARK: - Build DTO from Core Data managed object
    //
    // All timing fields come straight from Core Data.
    // beat & pace are NOT stored in Core Data — they were saved to UserDefaults
    // by RhythmicSessionDTO.saveExtras() when the session was first created.

    private func makeDTO(from managed: RhythmicSession, sessionNumber: Int) -> RhythmicSessionDTO {
        let uid = managed.id ?? UUID()
        let key = uid.uuidString
        return RhythmicSessionDTO(
            id:                       uid,
            sessionNumber:            sessionNumber,
            startDate:                managed.startDate ?? Date(),
            endDate:                  managed.endDate,
            requestedDurationSeconds: Int(managed.requestedDuration),
            elapsedSeconds:           Int(managed.elapsedSeconds),
            beat: UserDefaults.standard.string(forKey: "beat_\(key)") ?? "Click",
            pace: UserDefaults.standard.string(forKey: "pace_\(key)") ?? "Slow"
        )
    }

    // MARK: - Navigate to SessionSummaryViewController

    private func openDetail(for managed: RhythmicSession, sessionNumber: Int) {
        let dto = makeDTO(from: managed, sessionNumber: sessionNumber)

        let sb = UIStoryboard(name: "Rhythmic Walking", bundle: nil)
        guard let summaryVC = sb.instantiateViewController(
            withIdentifier: "SessionSummaryVC"
        ) as? SessionSummaryViewController else {
            print("[RhythmicWalkingSummaryVC] Could not instantiate SessionSummaryVC")
            return
        }

        summaryVC.sessionData = dto

        // Set title BEFORE pushing so viewDidLoad sees it and does not overwrite it
        summaryVC.navigationItem.title = "Session \(sessionNumber)"

        // Push onto the existing nav stack so the back button works automatically
        navigationController?.pushViewController(summaryVC, animated: true)
    }

    // MARK: - Actions

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RhythmicWalkingSummaryViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        sessionsBySection[section].count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell    = tableView.dequeueReusableCell(withIdentifier: "sessionCell",
                                                    for: indexPath)
        let managed = sessionsBySection[indexPath.section][indexPath.row]

        // ── Elapsed time (from Core Data) ────────────────────────────────
        let elapsed = Int(managed.elapsedSeconds)
        let h = elapsed / 3600
        let m = (elapsed % 3600) / 60
        let s = elapsed % 60
        let timeText = h == 0 ? "\(m)min \(s)s" : "\(h)hr \(m)min"

        // ── Distance (from Core Data, written back by HealthKitManagerRhythmic)
        // Only show if HealthKit has already fetched data for this session
        let distText: String = managed.distanceMeters > 0
            ? String(format: "%.2f km", managed.distanceMeters / 1000.0)
            : ""

        // ── Session number: position within the section, 1-based ────────
        let sessionNum = indexPath.row + 1

        // ── Populate labels ──────────────────────────────────────────────
        cell.textLabel?.text = "Session \(sessionNum)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        let rightText = distText.isEmpty
            ? timeText
            : "\(timeText)  ·  \(distText)"

        if let detail = cell.detailTextLabel {
            // Works automatically when Storyboard cell style = "Right Detail"
            detail.text      = rightText
            detail.textColor = .secondaryLabel
            detail.font      = .systemFont(ofSize: 14, weight: .regular)
        } else {
            // Fallback: programmatic right-aligned label for "Basic" style cells
            let tag = 9_002
            let rightLabel: UILabel
            if let existing = cell.contentView.viewWithTag(tag) as? UILabel {
                rightLabel = existing
            } else {
                rightLabel = UILabel()
                rightLabel.tag           = tag
                rightLabel.textAlignment = .right
                rightLabel.textColor     = .secondaryLabel
                rightLabel.font          = .systemFont(ofSize: 14, weight: .regular)
                rightLabel.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(rightLabel)
                NSLayoutConstraint.activate([
                    rightLabel.centerYAnchor.constraint(
                        equalTo: cell.contentView.centerYAnchor),
                    rightLabel.trailingAnchor.constraint(
                        equalTo: cell.contentView.trailingAnchor, constant: -16)
                ])
            }
            rightLabel.text = rightText
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RhythmicWalkingSummaryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let managed = sessionsBySection[indexPath.section][indexPath.row]
        openDetail(for: managed, sessionNumber: indexPath.row + 1)
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat { 36 }

    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font      = .systemFont(ofSize: 13, weight: .semibold)
        header.textLabel?.textColor = .secondaryLabel
    }
}
