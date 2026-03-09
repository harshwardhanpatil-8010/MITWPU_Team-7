
import UIKit
import CoreData

class RhythmicWalkingSummaryViewController: UIViewController {

    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    var dateToDisplay: Date?

    private var sectionTitles: [String] = []
    private var sessionsBySection: [[RhythmicSession]] = []

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text          = "No sessions performed"
        label.textColor     = .secondaryLabel
        label.font          = .systemFont(ofSize: 17, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden      = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.layer.cornerRadius = 30
        tableView.clipsToBounds      = true

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = closeButton

        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let targetDate = dateToDisplay {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            let calendar = Calendar.current
            if calendar.isDateInToday(targetDate) {
                navigationItem.title = "Today's Sessions"
            } else if calendar.isDateInYesterday(targetDate) {
                navigationItem.title = "Yesterday's Sessions"
            } else {
                navigationItem.title = formatter.string(from: targetDate)
            }
        } else {
            navigationItem.title = "All Sessions"
        }
        fetchAndGroup()
        tableView.reloadData()
        let isEmpty = sessionsBySection.allSatisfy { $0.isEmpty }
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden  = isEmpty
    }

    private func fetchAndGroup() {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<RhythmicSession> = RhythmicSession.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RhythmicSession.startDate, ascending: true)
        ]
        if let targetDate = dateToDisplay {
            let calendar = Calendar.current
            let start    = calendar.startOfDay(for: targetDate)
            let end      = calendar.date(byAdding: .day, value: 1, to: start)!
            request.predicate = NSPredicate(
                format: "startDate >= %@ AND startDate < %@",
                start as NSDate, end as NSDate
            )
        }

        do {
            let all = try context.fetch(request)
            buildSections(from: all)
        } catch {
            print("[RhythmicWalkingSummaryVC] Core Data fetch error: \(error)")
            sectionTitles     = []
            sessionsBySection = []
        }
    }
    private func buildSections(from sessions: [RhythmicSession]) {
        let calendar  = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"

        var orderedTitles: [String]          = []
        var map: [String: [RhythmicSession]] = [:]

        for session in sessions {
            let date = session.startDate ?? Date()
            let title: String
            if calendar.isDateInToday(date)          { title = ""     }
            else if calendar.isDateInYesterday(date) { title = "" }
            else                                     { title = "" }

            if map[title] == nil {
                orderedTitles.append(title)
                map[title] = []
            }
            map[title]!.append(session)
        }

        sectionTitles     = orderedTitles
        sessionsBySection = orderedTitles.map { map[$0] ?? [] }
    }


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
        summaryVC.isHistoryView = true
        navigationController?.pushViewController(summaryVC, animated: true)
    }


    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

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

        let elapsed = Int(managed.elapsedSeconds)
        let h = elapsed / 3600
        let m = (elapsed % 3600) / 60
        let s = elapsed % 60
        let timeText = h == 0 ? "\(m)min \(s)s" : "\(h)hr \(m)min"

        let distText: String = managed.distanceMeters > 0
            ? String(format: "%.2f km", managed.distanceMeters / 1000.0)
            : ""

        let sessionNum = indexPath.row + 1

        cell.textLabel?.text = "Session \(sessionNum)"
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        let rightText = distText.isEmpty
            ? timeText
            : "\(timeText)  ·  \(distText)"

        if let detail = cell.detailTextLabel {
            detail.text      = rightText
            detail.textColor = .secondaryLabel
            detail.font      = .systemFont(ofSize: 14, weight: .regular)
        } else {
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
